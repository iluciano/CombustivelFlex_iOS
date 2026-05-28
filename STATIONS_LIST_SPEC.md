# Especificação — Tela de Postos Próximos (iOS)

> Documento técnico completo para implementar a tela de postos do app iOS.
> Cobre: query Firestore, filtragem, ordenação, formatações, favoritos e UX.
>
> **Versão Android de referência:** 1.3.0 (versionCode 31)

---

## Índice

1. [Estrutura do Firestore](#1-estrutura-do-firestore)
2. [Modelo de Dados — Posto](#2-modelo-de-dados--posto)
3. [Query Firestore — Bounding Box](#3-query-firestore--bounding-box)
4. [Formatações](#4-formatações)
5. [Tela de Lista — Postos Próximos](#5-tela-de-lista--postos-próximos)
6. [Tela de Detalhe do Posto](#6-tela-de-detalhe-do-posto)
7. [Sistema de Favoritos](#7-sistema-de-favoritos)
8. [Fluxo Completo](#8-fluxo-completo)
9. [Equivalências iOS ↔ Android](#9-equivalências-ios--android)

---

## 1. Estrutura do Firestore

**Coleção:** `postos` (6.431 documentos)

| Campo | Tipo | Descrição |
|---|---|---|
| `nome` | String | Nome do posto |
| `bandeira` | String | Marca: `ipiranga`, `shell`, `br`, `ale`, `totalenergies` |
| `latitude` | Number | Latitude geográfica |
| `longitude` | Number | Longitude geográfica |
| `preco_gasolina` | Number | Preço da gasolina comum (R$) |
| `preco_etanol` | Number | Preço do etanol (R$) |
| `rua` | String | Logradouro |
| `numero` | String | Número |
| `bairro` | String | Bairro |
| `cidade` | String | Cidade |
| `estado` | String | UF |
| `data_ultima_coleta` | String | Data formato `YYYY-MM-DD` (ex: `"2026-05-08"`) |

---

## 2. Modelo de Dados — Posto

```swift
struct Posto: Codable, Identifiable, Equatable {
    var id: String
    var nome: String
    var bandeira: String?
    var latitude: Double
    var longitude: Double
    var precoGasolinaComum: Double   // 0 se ausente
    var precoEtanol: Double          // 0 se ausente
    var rua: String?
    var numero: String?
    var bairro: String?
    var cidade: String?
    var estado: String?
    var dataUltimaColeta: String?    // já formatada: "DD/MM/YYYY"
    var distanciaMetros: Double      // calculada localmente, não vem do Firestore

    static func == (lhs: Posto, rhs: Posto) -> Bool {
        lhs.id == rhs.id
    }
}
```

### Parsing do Firestore

```swift
func parsePostoFromDocument(_ doc: QueryDocumentSnapshot,
                             userLat: Double,
                             userLon: Double) -> Posto? {
    guard let lat = doc.data()["latitude"] as? Double,
          let lon = doc.data()["longitude"] as? Double else { return nil }

    var posto = Posto(
        id: doc.documentID,
        nome: doc.data()["nome"] as? String ?? "",
        bandeira: doc.data()["bandeira"] as? String,
        latitude: lat,
        longitude: lon,
        precoGasolinaComum: doc.data()["preco_gasolina"] as? Double ?? 0,
        precoEtanol: doc.data()["preco_etanol"] as? Double ?? 0,
        rua: doc.data()["rua"] as? String,
        numero: doc.data()["numero"] as? String,
        bairro: doc.data()["bairro"] as? String,
        cidade: doc.data()["cidade"] as? String,
        estado: doc.data()["estado"] as? String,
        dataUltimaColeta: formatDataColeta(doc.data()["data_ultima_coleta"] as? String),
        distanciaMetros: 0
    )

    let userLocation = CLLocation(latitude: userLat, longitude: userLon)
    let postoLocation = CLLocation(latitude: lat, longitude: lon)
    posto.distanciaMetros = userLocation.distance(from: postoLocation)

    return posto
}
```

---

## 3. Query Firestore — Bounding Box

### Por que bounding box?

A coleção tem 6.431 documentos. Uma busca sem filtro leria **tudo** a cada
acesso, estourando o limite gratuito do Firestore com apenas ~8 usuários/dia.
O bounding box reduz as leituras em ~97%.

### Cálculo do bounding box (~100 km)

```swift
let latDelta = 100.0 / 111.0
let lonDelta = 100.0 / (111.0 * cos(userLat * .pi / 180.0))

let minLat = userLat - latDelta
let maxLat = userLat + latDelta
let minLon = userLon - lonDelta
let maxLon = userLon + lonDelta
```

### Query no Firestore

Filtrar **latitude no servidor** (Firestore não suporta range em dois campos):

```swift
Firestore.firestore()
    .collection("postos")
    .whereField("latitude", isGreaterThan: minLat)
    .whereField("latitude", isLessThan: maxLat)
    .getDocuments { snapshot, error in
        // filtrar longitude client-side
    }
```

### Processamento client-side após receber os documentos

```swift
var postos: [Posto] = []

for doc in snapshot.documents {
    guard let lat = doc.data()["latitude"] as? Double,
          let lon = doc.data()["longitude"] as? Double else { continue }

    // Filtro de longitude client-side
    guard lon >= minLon && lon <= maxLon else { continue }

    guard let posto = parsePostoFromDocument(doc, userLat: userLat, userLon: userLon) else { continue }
    postos.append(posto)
}

// Ordenar do mais próximo ao mais distante
postos.sort { $0.distanciaMetros < $1.distanciaMetros }

// Exibir apenas os 10 primeiros
let closest = Array(postos.prefix(10))
```

---

## 4. Formatações

### Data de coleta

Campo raw do Firestore: `"2026-05-08"` → exibir como `"08/05/2026"`

```swift
func formatDataColeta(_ raw: String?) -> String {
    guard let raw = raw, !raw.isEmpty else { return "08/05/2026" }
    let parts = raw.split(separator: "-")
    guard parts.count == 3, parts[0].count == 4 else { return raw }
    return "\(parts[2])/\(parts[1])/\(parts[0])"
}
```

Fallback quando campo ausente ou nulo: `"08/05/2026"`

### Distância

```swift
func formatDistancia(_ metros: Double) -> String {
    if metros < 1000 {
        return "\(Int(metros)) m"
    }
    let km = metros / 1000.0
    let formatted = String(format: "%.1f", km).replacingOccurrences(of: ".", with: ",")
    return "\(formatted) km"
}
```

Exemplos: `"850 m"` / `"1,2 km"`

### Preço

```swift
func formatPreco(_ valor: Double) -> String {
    guard valor > 0 else { return "—" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "pt_BR")
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    let formatted = formatter.string(from: NSNumber(value: valor)) ?? "—"
    return "R$ \(formatted)"
}
```

Exemplo: `"R$ 5,79"`

### Endereço completo (tela de detalhe)

```swift
func buildAddress(_ posto: Posto) -> String {
    var parts: [String] = []

    var firstLine = ""
    if let rua = posto.rua, !rua.isEmpty {
        firstLine = rua
        if let numero = posto.numero, !numero.isEmpty {
            firstLine += ", \(numero)"
        }
    }
    if !firstLine.isEmpty { parts.append(firstLine) }

    if let bairro = posto.bairro, !bairro.isEmpty {
        parts.append(bairro)
    }

    var cityLine = ""
    if let cidade = posto.cidade, !cidade.isEmpty {
        cityLine = cidade
        if let estado = posto.estado, !estado.isEmpty {
            cityLine += " - \(estado)"
        }
    }
    if !cityLine.isEmpty { parts.append(cityLine) }

    return parts.isEmpty ? "Endereço não disponível" : parts.joined(separator: "\n")
}
```

---

## 5. Tela de Lista — Postos Próximos

### Layout geral

```
┌─────────────────────────────────────────────┐
│  [← Voltar]   POSTOS PRÓXIMOS               │  ← header fora do card
├─────────────────────────────────────────────┤
│  Card branco:                               │
│  ┌─────────────────────────────────────┐    │
│  │  [Próximos]  [Favoritos]            │    │  ← tabs segmentadas
│  │  ─────────────────────────────────  │    │
│  │  📍 Localização atual     [↻]       │    │  ← linha de localização
│  │                                     │    │  (oculta na aba Favoritos)
│  │  ┌── item posto ──────────────────┐ │    │
│  │  │ [logo] Nome do Posto    R$ 5,79│ │    │
│  │  │        1,2 km           Gasolina│ │    │
│  │  │                         R$ 3,89│ │    │
│  │  │                           Etanol│ │    │
│  │  │  Data de coleta: 08/05/2026 [ℹ]│ │    │
│  │  └─────────────────────────────── ┘ │    │
│  │   ... (até 10 itens)                │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  [       VER NO MAPA       ]                │  ← botão fixo abaixo
└─────────────────────────────────────────────┘
```

### Tabs segmentadas (Próximos / Favoritos)

Dois botões estilo "pill" no topo do card:

| Estado | Estilo |
|---|---|
| Ativo | Fundo azul (`#007AFF` ou cor primária do app), texto branco, bold |
| Inativo | Fundo transparente, texto cinza, normal |

Comportamento:
- **Próximos:** exibe linha "Localização atual + ↻", carrega lista do Firestore
- **Favoritos:** oculta linha "Localização atual", carrega lista local de favoritos

### Linha "Localização atual"

- Ícone de pin de localização à esquerda
- Texto `"Localização atual"` (cinza)
- Ícone de refresh circular `↻` imediatamente à direita do texto
- Clicável em qualquer ponto da linha — recarrega a localização e refaz a query
- **Ocultar completamente** quando a aba Favoritos estiver ativa

### Cada item da lista exibe

```
[logo/inicial]  Nome do Posto                    R$ 5,79
                1,2 km                           Gasolina comum
                                                 R$ 3,89
                                                 Etanol
─────────────────────────────────────────────────────────
Data de coleta: 08/05/2026  [ℹ]
```

Detalhes:
- Logo da bandeira à esquerda. Se bandeira desconhecida: círculo cinza com `"?"`
- Nome bold, distância em cinza abaixo
- Preços à direita, com label abaixo (cinza, fonte pequena)
- **Ícone `[ℹ]` deve ficar imediatamente ao lado do texto da data** — não usar
  `Spacer()` entre eles nem `frame(maxWidth: .infinity)` no texto da data

### Ícone de info (data de coleta)

Ao tocar exibe `Alert`:

```swift
Alert(
    title: Text("Dados da ANP"),
    message: Text("Os preços exibidos são coletados pela ANP (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis) com base em pesquisas realizadas periodicamente nos postos de combustível.\n\nA data de coleta indica quando essas informações foram registradas pela agência."),
    dismissButton: .default(Text("OK"))
)
```

### Bandeiras suportadas

| `bandeira` | Asset |
|---|---|
| `"ipiranga"` | `ic_brand_ipiranga` |
| `"shell"` | `ic_brand_shell` |
| `"ale"` | `ic_brand_ale` |
| `"vibra"` | `ic_brand_vibra` |
| qualquer outro | círculo cinza `#98A2B3` com texto `"?"` |

### Estados da tela

| Estado | Exibição |
|---|---|
| Carregando | `ProgressView` + `"Buscando postos próximos…"` |
| Lista com resultados | lista dos até 10 postos |
| Nenhum posto próximo | ícone + `"Nenhum posto encontrado"` + subtítulo |
| Nenhum favorito | ícone + `"Nenhum favorito ainda"` + `"Abra um posto e toque no coração para salvá-lo aqui."` |
| Erro de localização | `"Não foi possível obter a localização."` centralizado |
| Erro Firestore | `"Erro ao buscar postos. Verifique sua conexão."` centralizado |
| Permissão negada | `"Permissão de localização necessária para mostrar postos próximos."` |

### Botão "VER NO MAPA"

- Fixo abaixo da lista (fora do scroll), sempre visível
- Abre o app de mapas com a localização do usuário e query `"posto de combustível"`:

```swift
let coordinate = "\(userLat),\(userLon)"
let url = URL(string: "maps://?q=posto+de+combustivel&sll=\(coordinate)")!
UIApplication.shared.open(url)
```

---

## 6. Tela de Detalhe do Posto

### Layout geral

```
┌─────────────────────────────────────────────┐
│  [← Voltar]                    [♡]          │  ← topo: voltar (esq) + coração (dir)
├─────────────────────────────────────────────┤
│  Card branco:                               │
│  ┌─────────────────────────────────────┐    │
│  │  Data de coleta: 08/05/2026  [ℹ]    │    │  ← topo do card
│  │                                     │    │
│  │        [Logo da bandeira]           │    │
│  │                                     │    │
│  │    Nome do Posto                    │    │
│  │    1,2 km de você                   │    │
│  │                                     │    │
│  │  Gasolina         R$ 5,79           │    │
│  │  Etanol           R$ 3,89           │    │
│  │                                     │    │
│  │  Endereço                           │    │
│  │  Rua Exemplo, 123                   │    │
│  │  Bairro - Cidade - UF               │    │
│  │                                     │    │
│  │  [      VER NO MAPA      ]          │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ────────────────────────────────────────   │  ← divider (visível só quando ad carregou)
│  [Anúncio nativo]                           │  ← visibility controlada pelo load do ad
└─────────────────────────────────────────────┘
```

### Ícone de coração (favorito)

- Posicionado no canto superior direito do cabeçalho
- Dois estados visuais:
  - **Contorno preto** (`♡`) — posto não favoritado
  - **Preenchido vermelho** (`♥`, cor `#E53935`) — posto favoritado
- Ao tocar: alternar estado + salvar/remover dos favoritos + exibir feedback

```swift
// SF Symbols equivalentes:
Image(systemName: isFavorite ? "heart.fill" : "heart")
    .foregroundColor(isFavorite ? Color(hex: "#E53935") : .black)
    .frame(width: 48, height: 48)
```

### Feedback ao favoritar/desfavoritar

Usar `Toast` ou overlay customizado equivalente ao `Snackbar` do Android:

| Ação | Mensagem | Cor de fundo |
|---|---|---|
| Adicionar | `"Posto adicionado aos favoritos"` | Azul (`#007AFF`) |
| Remover | `"Posto removido dos favoritos"` | Cinza escuro (`#4A4A4A`) |

- Duração: ~2 segundos (equivalente a `Snackbar.LENGTH_SHORT`)
- Texto branco, aparece na parte inferior da tela
- Não há botão de ação — apenas informativo

Implementação sugerida (SwiftUI):

```swift
struct ToastView: View {
    let message: String
    let backgroundColor: Color

    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}
```

Exibir com animação de fade in/out na parte inferior da tela e remover após 2s.

### Data de coleta no detalhe

- Exibido no **topo do card**, antes do logo
- Mesmo formato e mesmo ícone `[ℹ]` com o mesmo alert da lista

### Anúncio nativo

- Container do anúncio e divider acima ficam **ocultos** até o ad carregar
- Ao carregar: exibir divider + anúncio abaixo do card principal
- Formato: Native Ad (título, corpo, ícone, media, CTA)
- **Nunca usar Banner Ad** nesta tela

---

## 7. Sistema de Favoritos

### Visão geral

Favoritos são persistidos **localmente** em `UserDefaults` (equivalente ao
`SharedPreferences` do Android). Sobrevivem ao fechamento do app, reinício do
aparelho, e qualquer outra situação exceto limpeza de dados do app ou desinstalação.

### Dados persistidos

Duas chaves em `UserDefaults`:

| Chave | Tipo | Conteúdo |
|---|---|---|
| `"favorite_ids"` | `[String]` | Array de IDs dos postos favoritados |
| `"posto_<id>"` | `String` | JSON com todos os campos do posto |

Armazenar o posto completo (não só o ID) para que a aba Favoritos exiba os
dados sem precisar refazer a query no Firestore.

### FavoritesManager (Swift)

```swift
class FavoritesManager {
    private static let defaults = UserDefaults.standard
    private static let idsKey = "favorite_ids"

    static func isFavorite(_ postoId: String) -> Bool {
        return getIds().contains(postoId)
    }

    static func addFavorite(_ posto: Posto) {
        var ids = getIds()
        guard !ids.contains(posto.id) else { return }
        ids.append(posto.id)
        defaults.set(ids, forKey: idsKey)
        if let data = try? JSONEncoder().encode(posto),
           let json = String(data: data, encoding: .utf8) {
            defaults.set(json, forKey: "posto_\(posto.id)")
        }
    }

    static func removeFavorite(_ postoId: String) {
        var ids = getIds()
        ids.removeAll { $0 == postoId }
        defaults.set(ids, forKey: idsKey)
        defaults.removeObject(forKey: "posto_\(postoId)")
    }

    static func getFavorites() -> [Posto] {
        return getIds().compactMap { id in
            guard let json = defaults.string(forKey: "posto_\(id)"),
                  let data = json.data(using: .utf8),
                  let posto = try? JSONDecoder().decode(Posto.self, from: data) else { return nil }
            return posto
        }
    }

    private static func getIds() -> [String] {
        return defaults.stringArray(forKey: idsKey) ?? []
    }
}
```

> **Nota:** Para que `Posto` seja codificável com `JSONEncoder`, o struct deve
> conformar a `Codable` (já incluído na definição da Seção 2).

### Sincronização da lista de favoritos

A aba Favoritos deve ser **recarregada sempre que a tela de lista aparecer**
(equivalente ao `onResume()` do Android):

```swift
// SwiftUI: usar .onAppear na View da lista ou no TabView
.onAppear {
    if currentMode == .favoritos {
        favorites = FavoritesManager.getFavorites()
    }
}

// UIKit: sobrescrever viewWillAppear
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if currentMode == .favoritos {
        loadFavorites()
    }
}
```

### Estado da aba Favoritos quando vazia

Exibir view de estado vazio centralizada:
- Ícone de coração (outline)
- Título: `"Nenhum favorito ainda"`
- Subtítulo: `"Abra um posto e toque no coração para salvá-lo aqui."`

---

## 8. Fluxo Completo

```
TELA DE LISTA
─────────────────────────────────────────────────────

1. Ao abrir a tela:
   ├── Verificar permissão de localização (CLLocationManager)
   │   ├── Não determinada → pedir permissão
   │   ├── Negada → exibir mensagem de erro
   │   └── Concedida → continuar
   └── Carregar aba selecionada (padrão: Próximos)

2. Aba "Próximos" selecionada:
   ├── Exibir "Buscando postos próximos…"
   ├── Obter localização:
   │   ├── Tentar lastKnownLocation (cache)
   │   └── Se nil → requestLocation (alta precisão)
   ├── Calcular bounding box (~100 km)
   ├── Query Firestore (filtro latitude no servidor)
   ├── Para cada doc: filtrar longitude, calcular distância
   ├── Ordenar por distância (crescente)
   ├── Pegar prefix(10)
   └── Exibir lista ou estado vazio

3. Aba "Favoritos" selecionada:
   ├── Ocultar linha "Localização atual"
   ├── Carregar FavoritesManager.getFavorites()
   └── Exibir lista ou estado vazio de favoritos

4. Tocar no item da lista:
   └── Navegar para Tela de Detalhe passando o Posto

5. Tocar em "↻" (refresh):
   └── Repetir passo 2

─────────────────────────────────────────────────────
TELA DE DETALHE
─────────────────────────────────────────────────────

1. Ao abrir:
   ├── Exibir dados do posto (passados pela lista)
   ├── Verificar se ID do posto está em FavoritesManager
   └── Definir ícone do coração (outline ou filled)

2. Tocar no coração:
   ├── Se não favoritado:
   │   ├── FavoritesManager.addFavorite(posto)
   │   ├── Atualizar ícone → filled vermelho
   │   └── Exibir toast azul: "Posto adicionado aos favoritos"
   └── Se favoritado:
       ├── FavoritesManager.removeFavorite(posto.id)
       ├── Atualizar ícone → outline preto
       └── Exibir toast cinza: "Posto removido dos favoritos"

3. Ao sair (voltar para lista):
   └── Lista atualiza favoritos via onAppear/viewWillAppear
```

---

## 9. Equivalências iOS ↔ Android

| Android | iOS |
|---|---|
| `FusedLocationProviderClient` | `CLLocationManager` |
| `Location.distanceBetween()` | `CLLocation.distance(from:)` |
| `SharedPreferences` | `UserDefaults` |
| `Parcelable` | `Codable` |
| `RecyclerView` + `Adapter` | `List` (SwiftUI) ou `UITableView` (UIKit) |
| `Snackbar` | Toast customizado ou `SPIndicator` (lib) |
| `AlertDialog` | `Alert` (SwiftUI) ou `UIAlertController` (UIKit) |
| `Intent.ACTION_VIEW` (maps) | `UIApplication.shared.open(mapsURL)` |
| `getColor(R.color.new_blue)` | `Color.blue` / `Color(hex: "007AFF")` |
| `android:fitsSystemWindows` | `.ignoresSafeArea()` controlado + `.safeAreaInset` |
| `visibility="gone"` | `.opacity(0)` + `allowsHitTesting(false)` ou `if show { View }` |
| `ContextCompat.getColor` | `UIColor(named:)` ou `Color(...)` |

### Estrutura do Firestore SDK (Firebase iOS)

```swift
import FirebaseFirestore

let db = Firestore.firestore()

db.collection("postos")
  .whereField("latitude", isGreaterThan: minLat)
  .whereField("latitude", isLessThan: maxLat)
  .getDocuments { snapshot, error in
      guard let snapshot = snapshot, error == nil else {
          // tratar erro
          return
      }
      for doc in snapshot.documents {
          // parsear
      }
  }
```

### Dependências necessárias (Package.swift ou CocoaPods)

```ruby
# CocoaPods
pod 'Firebase/Firestore'
pod 'Firebase/Auth'     # se necessário

# Swift Package Manager
// https://github.com/firebase/firebase-ios-sdk
// Produtos: FirebaseFirestore
```

---

> **Atenção:** `google-services.json` é exclusivo do Android. Para iOS, usar
> `GoogleService-Info.plist`, gerado no Firebase Console, na seção do app iOS.
> Nunca commitar esse arquivo — contém chaves privadas.
