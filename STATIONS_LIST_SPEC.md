# Especificação — Tela de Postos Próximos

> Documento técnico para replicar a lógica da tela de postos do app Android
> no app iOS. Cobre: query Firestore, filtragem, ordenação, formatações e UX.

---

## Estrutura do Firestore

**Coleção:** `postos`

Cada documento tem os seguintes campos:

| Campo | Tipo | Descrição |
|---|---|---|
| `nome` | String | Nome do posto |
| `bandeira` | String | Marca (ex: `ipiranga`, `shell`, `br`, `ale`, `totalenergies`) |
| `latitude` | Number | Latitude geográfica |
| `longitude` | Number | Longitude geográfica |
| `preco_gasolina` | Number | Preço da gasolina comum (R$) |
| `preco_etanol` | Number | Preço do etanol (R$) |
| `rua` | String | Logradouro |
| `numero` | String | Número |
| `bairro` | String | Bairro |
| `cidade` | String | Cidade |
| `estado` | String | UF |
| `data_ultima_coleta` | String | Data no formato `YYYY-MM-DD` (ex: `"2026-05-08"`) |

---

## Query Firestore — Bounding Box

**Problema que motivou a decisão:** a coleção tem 6.431 documentos. Uma busca
sem filtro leria tudo a cada acesso, estourando o limite gratuito do Firestore
com apenas ~8 usuários/dia.

**Solução adotada:** bounding box de ~100 km ao redor do usuário.

### Lógica de cálculo

```
latDelta = 100.0 / 111.0                          // ~0.9 graus
lonDelta = 100.0 / (111.0 * cos(userLat em rad))  // varia com a latitude

minLat = userLat - latDelta
maxLat = userLat + latDelta
minLon = userLon - lonDelta
maxLon = userLon + lonDelta
```

### Query no Firestore

Filtrar **latitude no servidor**:
```
collection("postos")
  .whereGreaterThan("latitude", minLat)
  .whereLessThan("latitude", maxLat)
```

> Firestore só suporta range filter em um campo por query. Por isso a longitude
> é filtrada no cliente após receber os resultados.

### Filtragem client-side após receber os documentos

Para cada documento retornado:
1. Ignorar se `latitude` ou `longitude` forem nulos
2. Ignorar se `longitude` estiver fora de `[minLon, maxLon]`
3. Calcular distância exata entre usuário e posto (fórmula Haversine ou equivalente nativo do SO)
4. Armazenar a distância no modelo

### Ordenação e limite

```
- Ordenar lista pelo campo distância (crescente)
- Exibir apenas os 10 primeiros (subList / prefix)
```

---

## Modelo de Dados — Posto

Campos mínimos necessários para a tela de lista e detalhe:

```swift
struct Posto {
    var id: String
    var nome: String
    var bandeira: String
    var latitude: Double
    var longitude: Double
    var precoGasolinaComum: Double
    var precoEtanol: Double
    var rua: String?
    var numero: String?
    var bairro: String?
    var cidade: String?
    var estado: String?
    var dataUltimaColeta: String?  // já formatada: "DD/MM/YYYY"
    var distanciaMetros: Double    // calculada localmente, não vem do Firestore
}
```

---

## Formatações

### Data de coleta

- Campo raw do Firestore: `"2026-05-08"` (formato ISO `YYYY-MM-DD`)
- Exibir como: `"DD/MM/YYYY"` → `"08/05/2026"`
- Fallback quando ausente ou nulo: usar `"08/05/2026"`

```
func formatDataColeta(_ raw: String?) -> String {
    guard let raw = raw, !raw.isEmpty else { return "08/05/2026" }
    let parts = raw.split(separator: "-")
    if parts.count == 3 && parts[0].count == 4 {
        return "\(parts[2])/\(parts[1])/\(parts[0])"
    }
    return raw
}
```

### Distância

```
< 1000 m  →  "850 m"
≥ 1000 m  →  "1,2 km"  (1 casa decimal, vírgula como separador)
```

### Preço

```
Padrão brasileiro: "R$ 5,79"
Locale: pt_BR
```

---

## UX — Tela de Lista

### Cada item da lista exibe:
- Logo/ícone da bandeira (à esquerda)
- Nome do posto (bold)
- Distância (abaixo do nome, cinza)
- Preço da gasolina comum (direita, azul, bold)
- Label "Gasolina comum" (abaixo do preço, cinza pequeno)
- Preço do etanol (abaixo, verde, bold)
- Label "Etanol" (abaixo, cinza pequeno)
- Chevron `>` (extrema direita)
- **Linha inferior:** texto `"Data de coleta: DD/MM/YYYY"` + ícone de info (círculo com "i")

### Ícone de info (data de coleta):
- Fica imediatamente ao lado do texto da data (não usar layout que expanda o texto)
- Ao tocar: abre um alerta/popup com:
  - **Título:** `"Dados da ANP"`
  - **Mensagem:** `"Os preços exibidos são coletados pela ANP (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis) e representam a média de preços praticados pelos postos na data indicada."`
  - Botão: `"OK"`

### Estados da tela:
| Estado | Exibição |
|---|---|
| Carregando | Indicador de progresso + texto "Buscando postos..." |
| Lista com resultados | RecyclerView / List com os 10 postos |
| Nenhum posto encontrado | Ícone + "Nenhum posto encontrado" + subtítulo |
| Erro de localização | Texto de erro centralizado |
| Erro de rede/Firestore | Texto de erro centralizado |

### Botão "VER NO MAPA":
- Fixo na parte inferior da tela (fora da lista, sempre visível)
- Abre o app de mapas nativo com query `"posto de combustível"` e coordenadas do usuário

### Linha de localização (topo do card):
- Exibe `"Localização atual"` com ícone de pin
- Clicável — ao tocar, atualiza a localização e recarrega a lista

---

## Fluxo Completo

```
1. Verificar permissão de localização
   ├── Negada → exibir mensagem pedindo permissão
   └── Concedida → obter localização atual

2. Obter localização
   ├── Tentar última localização conhecida (cache)
   └── Se nula → solicitar localização fresca (alta precisão)

3. Calcular bounding box (~100 km ao redor do usuário)

4. Query no Firestore com filtro de latitude

5. Para cada documento retornado:
   ├── Ignorar se lat/lon nulos
   ├── Ignorar se longitude fora do bounding box
   ├── Calcular distância exata
   └── Adicionar à lista local

6. Ordenar por distância (crescente)

7. Pegar os 10 primeiros

8. Exibir na lista
```

---

## Observações para iOS

- Usar `CLLocationManager` para permissão e localização (equivalente ao `FusedLocationProviderClient`)
- Usar `CLLocation.distance(from:)` para calcular distância entre coordenadas (equivalente ao `Location.distanceBetween()`)
- O SDK do Firebase para iOS (`FirebaseFirestore`) tem a mesma API de `whereGreaterThan` / `whereLessThan`
- O campo `data_ultima_coleta` pode ou não estar presente nos documentos — sempre tratar como opcional com fallback
