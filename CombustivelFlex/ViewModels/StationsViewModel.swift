import CoreLocation
import FirebaseFirestore
import Foundation

@MainActor
final class StationsViewModel: NSObject, ObservableObject {
    @Published private(set) var stations: [FuelStation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var locationPermissionDenied = false
    @Published private(set) var errorMessage: String?

    private static let boundingBoxRadiusKilometers = 100.0
    private static let maximumStationsCount = 10

    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func start() {
        errorMessage = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationPermissionDenied = false
            requestCurrentLocation()
        case .denied, .restricted:
            locationPermissionDenied = true
            isLoading = false
        @unknown default:
            locationPermissionDenied = true
            isLoading = false
        }
    }

    func requestPermission() {
        errorMessage = nil
        locationPermissionDenied = false
        locationManager.requestWhenInUseAuthorization()
    }

    func refresh() {
        start()
    }

    func mapsURL(for station: FuelStation) -> URL? {
        URL(string: "https://www.google.com/maps/search/?api=1&query=\(station.latitude),\(station.longitude)")
    }

    func routeMapsURL(for station: FuelStation) -> URL? {
        let encodedName = station.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Posto"
        return URL(string: "http://maps.apple.com/?daddr=\(station.latitude),\(station.longitude)&q=\(encodedName)&dirflg=d")
    }

    func nearbyGasStationsMapsURL() -> URL? {
        let query = "posto de combustível"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "posto%20de%20combustivel"

        guard let currentLocation else {
            return URL(string: "http://maps.apple.com/?q=\(query)")
        }

        return URL(
            string: "http://maps.apple.com/?q=\(query)&ll=\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
        )
    }

    private func requestCurrentLocation() {
        isLoading = true
        locationManager.requestLocation()
    }

    private func loadStations(near location: CLLocation) {
        isLoading = true
        errorMessage = nil
        let boundingBox = boundingBox(around: location.coordinate)

        Firestore.firestore()
            .collection("postos")
            .whereField("latitude", isGreaterThan: boundingBox.minLatitude)
            .whereField("latitude", isLessThan: boundingBox.maxLatitude)
            .getDocuments { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.isLoading = false

                if let error {
                    self.errorMessage = "Não foi possível carregar os postos. Verifique sua conexão e tente novamente."
                    #if DEBUG
                    print("Firestore stations error: \(error.localizedDescription)")
                    #endif
                    return
                }

                let documents = snapshot?.documents ?? []
                let loadedStations = documents.compactMap { document in
                    self.makeStation(from: document, userLocation: location, boundingBox: boundingBox)
                }
                let sortedStations = loadedStations.sorted {
                    ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude)
                }
                let nearestStations = Array(sortedStations.prefix(Self.maximumStationsCount))

                #if DEBUG
                print("Firestore postos documents in latitude box: \(documents.count), parsed in bounding box: \(loadedStations.count), displayed: \(nearestStations.count)")
                #endif

                if !documents.isEmpty && loadedStations.isEmpty {
                    self.errorMessage = "Os postos foram encontrados, mas os dados estão em um formato diferente do esperado."
                }

                self.stations = nearestStations
            }
        }
    }

    private func makeStation(
        from document: QueryDocumentSnapshot,
        userLocation: CLLocation,
        boundingBox: StationBoundingBox
    ) -> FuelStation? {
        let data = document.data()

        guard let name = stringValue(data, keys: ["nome", "name", "Nome", "posto", "razao_social"]),
              let coordinate = coordinateValue(data),
              let regularGasolinePrice = doubleValue(
                data,
                keys: [
                    "preco_gasolina_comum",
                    "precoGasolinaComum",
                    "gasolina_comum",
                    "gasolinaComum",
                    "preco_gasolina",
                    "precoGasolina",
                    "gasolina"
                ]
              ) else {
            #if DEBUG
            print("Skipped posto \(document.documentID). Keys: \(Array(data.keys).sorted())")
            #endif
            return nil
        }

        guard coordinate.longitude >= boundingBox.minLongitude,
              coordinate.longitude <= boundingBox.maxLongitude else {
            return nil
        }

        let stationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return FuelStation(
            id: document.documentID,
            name: name,
            brand: FuelStationBrand(rawValue: stringValue(data, keys: ["bandeira", "brand", "marca"]) ?? ""),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            regularGasolinePrice: regularGasolinePrice,
            additiveGasolinePrice: doubleValue(data, keys: ["preco_gasolina_aditivada", "precoGasolinaAditivada", "gasolina_aditivada", "gasolinaAditivada"]),
            ethanolPrice: doubleValue(data, keys: ["preco_etanol", "precoEtanol", "etanol"]),
            address: addressValue(data),
            updatedAt: formattedUpdatedAt(data, keys: ["atualizado_em", "atualizadoEm", "updated_at", "updatedAt"]),
            collectionDate: formattedUpdatedAt(data, keys: ["data_ultima_coleta", "dataUltimaColeta", "data_coleta", "dataColeta"]),
            distanceMeters: stationLocation.distance(from: userLocation)
        )
    }

    private func addressValue(_ data: [String: Any]) -> String? {
        if let address = data["endereco"] as? [String: Any] {
            return addressValue(address)
        }

        let street = stringValue(data, keys: ["rua", "logradouro"])
        let number = stringValue(data, keys: ["numero", "number"])
        let neighborhood = stringValue(data, keys: ["bairro", "neighborhood"])
        let city = stringValue(data, keys: ["cidade", "city"])
        let state = stringValue(data, keys: ["uf", "estado", "state"])
        let line1 = [street, number].compactMap { $0 }.joined(separator: ", ")
        let line2 = [neighborhood, city, state].compactMap { $0 }.joined(separator: " - ")
        let lines = [line1, line2].filter { !$0.isEmpty }

        if !lines.isEmpty {
            return lines.joined(separator: "\n")
        }

        if let address = stringValue(data, keys: ["endereco", "address"]) {
            let city = stringValue(data, keys: ["cidade", "city"])
            let state = stringValue(data, keys: ["uf", "estado", "state"])
            let cityState = [city, state].compactMap { $0 }.joined(separator: " - ")

            if cityState.isEmpty {
                return address
            }

            return "\(address)\n\(cityState)"
        }

        return nil
    }

    private func boundingBox(around coordinate: CLLocationCoordinate2D) -> StationBoundingBox {
        let latitudeDelta = Self.boundingBoxRadiusKilometers / 111.0
        let latitudeRadians = coordinate.latitude * .pi / 180
        let longitudeDenominator = max(111.0 * cos(latitudeRadians), 0.01)
        let longitudeDelta = Self.boundingBoxRadiusKilometers / longitudeDenominator

        return StationBoundingBox(
            minLatitude: coordinate.latitude - latitudeDelta,
            maxLatitude: coordinate.latitude + latitudeDelta,
            minLongitude: coordinate.longitude - longitudeDelta,
            maxLongitude: coordinate.longitude + longitudeDelta
        )
    }

    private func stringValue(_ data: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = data[key] as? String, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
        }

        return nil
    }

    private func coordinateValue(_ data: [String: Any]) -> (latitude: Double, longitude: Double)? {
        if let latitude = doubleValue(data, keys: ["latitude", "lat", "Latitude"]),
           let longitude = doubleValue(data, keys: ["longitude", "lng", "lon", "long", "Longitude"]) {
            return (latitude, longitude)
        }

        for key in ["localizacao", "location", "coordenadas", "geo", "geopoint"] {
            if let geoPoint = data[key] as? GeoPoint {
                return (geoPoint.latitude, geoPoint.longitude)
            }

            if let coordinate = data[key] as? [String: Any],
               let latitude = doubleValue(coordinate, keys: ["latitude", "lat"]),
               let longitude = doubleValue(coordinate, keys: ["longitude", "lng", "lon", "long"]) {
                return (latitude, longitude)
            }
        }

        return nil
    }

    private func doubleValue(_ data: [String: Any], keys: [String]) -> Double? {
        for key in keys {
            if let value = doubleValue(data[key]) {
                return value
            }
        }

        return nil
    }

    private func doubleValue(_ value: Any?) -> Double? {
        if let value = value as? Double {
            return value
        }

        if let value = value as? NSNumber {
            return value.doubleValue
        }

        if let value = value as? String {
            return Double(value.replacingOccurrences(of: ",", with: "."))
        }

        return nil
    }

    private func formattedUpdatedAt(_ data: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = formattedUpdatedAt(data[key]) {
                return value
            }
        }

        return nil
    }

    private func formattedUpdatedAt(_ value: Any?) -> String? {
        if let value = value as? String {
            return formattedDateString(value)
        }

        if let timestamp = value as? Timestamp {
            return timestamp.dateValue().formatted(.dateTime.day().month().year())
        }

        return nil
    }

    private func formattedDateString(_ value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let inputFormats = ["yyyy-MM-dd", "yyyy/MM/dd", "dd/MM/yyyy", "dd-MM-yyyy"]
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "pt_BR")
        outputFormatter.dateFormat = "dd/MM/yyyy"

        for inputFormat in inputFormats {
            let inputFormatter = DateFormatter()
            inputFormatter.locale = Locale(identifier: "pt_BR")
            inputFormatter.dateFormat = inputFormat

            if let date = inputFormatter.date(from: trimmedValue) {
                return outputFormatter.string(from: date)
            }
        }

        return trimmedValue
    }
}

private struct StationBoundingBox {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double
}

extension StationsViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationPermissionDenied = false
                requestCurrentLocation()
            case .denied, .restricted:
                locationPermissionDenied = true
                isLoading = false
            case .notDetermined:
                break
            @unknown default:
                locationPermissionDenied = true
                isLoading = false
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        Task { @MainActor in
            currentLocation = location
            loadStations(near: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isLoading = false
            errorMessage = "Não foi possível obter sua localização atual. Tente novamente."

            #if DEBUG
            print("Location error: \(error.localizedDescription)")
            #endif
        }
    }
}
