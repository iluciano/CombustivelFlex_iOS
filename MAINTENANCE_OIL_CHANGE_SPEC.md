# Especificação — Manutenção & Troca de Óleo (iOS)

> Documento técnico para replicar no app iOS tudo que foi implementado na versão
> Android **1.4.0 (versionCode 32)**. Cobre: nova seção Manutenção, fluxo completo
> de Troca de óleo (registro, histórico, detalhe, edição, exclusão), abas no
> Histórico da calculadora e anúncios nativos.
>
> Padrão visual: **todas as telas usam cards brancos** com cantos arredondados e
> sombra leve, títulos de seção fora do card, sobre fundo cinza claro (`#F6F8FC`).

---

## Índice

1. [Mudança na Calculadora — Histórico em abas](#1-calculadora--histórico-em-abas)
2. [Navegação — aba Manutenção](#2-navegação--aba-manutenção)
3. [Tela Manutenção (hub)](#3-tela-manutenção-hub)
4. [Modelo de dados — OilChangeRecord](#4-modelo-de-dados--oilchangerecord)
5. [Persistência — OilChangeStore](#5-persistência--oilchangestore)
6. [Tela principal — Acompanhamento da Troca de Óleo](#6-tela-principal--acompanhamento)
7. [Fluxo de Registro (3 telas)](#7-fluxo-de-registro-3-telas)
8. [Tela Histórico de trocas](#8-tela-histórico-de-trocas)
9. [Tela Detalhe da troca](#9-tela-detalhe-da-troca)
10. [Tela Editar troca](#10-tela-editar-troca)
11. [Tela Excluir troca](#11-tela-excluir-troca)
12. [Anúncios Nativos (AdMob)](#12-anúncios-nativos-admob)
13. [Ícones](#13-ícones)
14. [Segurança de inputs](#14-segurança-de-inputs)
15. [Paleta de cores](#15-paleta-de-cores)

---

## 1. Calculadora — Histórico em abas

A tela de cálculo agora tem **duas abas no topo do card**: **Calcular** | **Histórico**
(mesmo padrão de abas segmentadas usado na lista de postos).

- **Aba Calcular**: formulário da calculadora (preços + consumo + botões Calcular/Limpar)
- **Aba Histórico**: lista dos últimos 25 cálculos salvos, com botão "Limpar" (confirmação via alert)
- A aba **Histórico foi REMOVIDA da barra de navegação inferior** (rodapé). O rodapé
  da calculadora passou a ter 3 itens: **Início, Postos, Mais** (+ a aba Manutenção, ver seção 2)
- O card "Histórico" na tela inicial abre a calculadora já com a aba Histórico selecionada
  (no Android via flag `EXTRA_OPEN_HISTORY`; no iOS, passar um parâmetro de inicialização)

```swift
enum CalcTab { case calcular, historico }

// SwiftUI: segmented control no topo do card
Picker("", selection: $selectedTab) {
    Text("Calcular").tag(CalcTab.calcular)
    Text("Histórico").tag(CalcTab.historico)
}
.pickerStyle(.segmented)
```

> Estilo das abas: ativa = fundo azul (`#1473F8`), texto branco bold; inativa = fundo
> transparente, texto cinza (`#98A2B3`). Replicar o mesmo estilo em todas as abas do app.

---

## 2. Navegação — aba Manutenção

Foi adicionada uma aba **Manutenção** na barra inferior de **todas as telas**, entre
**Postos** e **Mais**. Ordem final do rodapé:

```
[ Início ]  [ Postos ]  [ Manutenção ]  [ Mais ]
```

- Ícone: **toolbox** (Font Awesome `fa-solid fa-toolbox`) — ver seção 13
- Também foi adicionado um **card "Manutenção"** na tela inicial (lista de opções),
  logo após "Postos próximos", com ícone toolbox azul, abrindo a tela Manutenção

---

## 3. Tela Manutenção (hub)

Tela simples que lista as opções de manutenção. **Por ora só existe "Troca de óleo".**

```
┌─────────────────────────────────────┐
│  Manutenção                         │  ← título fora do card
│  Acompanhe as manutenções do carro  │  ← subtítulo
├─────────────────────────────────────┤
│  Card branco:                       │
│  ┌───────────────────────────────┐  │
│  │ [oil-can] Troca de óleo     > │  │  ← opção clicável
│  │           Registre e acompanhe │  │
│  └───────────────────────────────┘  │
│  [ divider + anúncio nativo ]       │  ← oculto até carregar (ver seção 12)
└─────────────────────────────────────┘
  [ Início ] [ Postos ] [Manutenção] [Mais]
```

- Ícone da opção: **oil-can** laranja (`#FF7A00`)
- Toque na opção → tela de Acompanhamento (seção 6)

---

## 4. Modelo de dados — OilChangeRecord

```swift
struct OilChangeRecord: Codable, Identifiable {
    var id: Double { timestamp }      // timestamp é a chave única

    var timestamp: Double             // epoch ms — gerado ao salvar; identifica o registro
    var date: String                  // "DD/MM/YYYY" — data da troca
    var km: Int                       // km do carro na troca
    var nextKm: Int                   // km ALVO da próxima troca (ABSOLUTO = km + intervalo)
    var nextDate: String              // "DD/MM/YYYY" — data prevista da próxima troca

    var changedEngineOil: Bool        // óleo do motor
    var changedOilFilter: Bool        // filtro de óleo
    var changedAirFilter: Bool        // filtro de ar
    var changedFuelFilter: Bool       // filtro de combustível
    var changedCabinFilter: Bool      // filtro de cabine
    var changedBrakeFluid: Bool       // fluído de freio
    var changedSparkPlugs: Bool       // velas de ignição

    var oilType: String               // tipo do óleo (opcional, max 50 chars)
    var notes: String                 // observações (opcional, max 120 chars)
}
```

> **REGRA IMPORTANTE — nextKm é absoluto.** O usuário digita no formulário o
> **intervalo** (ex: 5.000 km). O valor armazenado em `nextKm` é
> `km + intervalo`. Exemplo: km atual 210.000 + intervalo 5.000 → `nextKm = 215.000`.
> Todas as telas que exibem "próxima troca" mostram `nextKm` direto (já absoluto).

---

## 5. Persistência — OilChangeStore

Persistência **local** via `UserDefaults` (equivalente ao `SharedPreferences` do Android).
Sobrevive a fechar o app e reiniciar o aparelho. Guarda no máximo **25 registros**.

```swift
enum OilChangeStore {
    private static let key = "oil_change_history"
    private static let maxHistory = 25

    static func getHistory() -> [OilChangeRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([OilChangeRecord].self, from: data)
        else { return [] }
        return list
    }

    /// Adiciona um novo registro no topo da lista.
    static func save(_ record: OilChangeRecord) {
        var r = record
        r.timestamp = Date().timeIntervalSince1970 * 1000
        var history = getHistory()
        history.insert(r, at: 0)
        if history.count > maxHistory { history = Array(history.prefix(maxHistory)) }
        persist(history)
    }

    /// Substitui um registro existente (mesmo timestamp).
    static func update(_ updated: OilChangeRecord) {
        var history = getHistory()
        if let idx = history.firstIndex(where: { $0.timestamp == updated.timestamp }) {
            history[idx] = updated
        }
        persist(history)
    }

    /// Remove um registro pelo timestamp.
    static func delete(timestamp: Double) {
        var history = getHistory()
        history.removeAll { $0.timestamp == timestamp }
        persist(history)
    }

    /// O registro mais recente (topo) — usado na tela de acompanhamento.
    static func getLatest() -> OilChangeRecord? { getHistory().first }

    private static func persist(_ history: [OilChangeRecord]) {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
```

> O Android armazena o histórico como um array JSON + uma cópia do "latest". No iOS,
> basta o array (o `latest` é sempre `history.first`). O registro mais recente é
> sempre o exibido na tela de acompanhamento.

---

## 6. Tela principal — Acompanhamento

Mostra o **último registro** (`getLatest()`). Se não houver registro, mostra estado vazio.

```
┌─────────────────────────────────────────────┐
│  ← Troca de óleo                            │
├─────────────────────────────────────────────┤
│  Card branco:                               │
│  ┌─[status, fundo colorido]──────────────┐  │
│  │ [oil-can] Tudo em dia!                │  │  ← verde/laranja/vermelho
│  │           Seu óleo está dentro do prazo│  │
│  └────────────────────────────────────────┘  │
│  Próxima troca em                           │
│  183  🕐 dias                               │  ← contagem regressiva
│  ━━━━━━━━━━━●━━━━━━━━━━  (barra progresso)  │
│  209.456 km          219.456 km             │
│  Última troca        Próxima troca prevista  │
│  ─────────────────────────────────────────  │
│  [oil-can] Última troca               >     │
│            30/05/2026 • 209.456 km          │
│  [🕐] Próxima troca prevista          >     │
│       30/11/2026 • 219.456 km               │
│  Itens trocados na última troca             │
│  ✓ Óleo do motor  ✓ Filtro de óleo ✓ ...   │  ← chips verdes
│  [   + REGISTRAR NOVA TROCA   ]             │
│  [        VER HISTÓRICO         ]           │
│  [ divider + anúncio nativo ]               │  ← ver seção 12
└─────────────────────────────────────────────┘
```

### Lógica de status (cor do bloco superior + barra)

```swift
let daysRemaining = daysBetween(today, record.nextDate)   // pode ser negativo
let status: OilStatus
if daysRemaining > 30      { status = .ok }       // verde  — "Tudo em dia!"
else if daysRemaining >= 0 { status = .due }      // laranja — "Troca próxima!"
else                       { status = .overdue }  // vermelho — "Troca atrasada!"
```

| Status | Cor fundo | Cor texto/ícone | Título | Mensagem |
|---|---|---|---|---|
| OK (>30 dias) | `#ECFDF3` | `#0F9F5A` | Tudo em dia! | Seu óleo está dentro do prazo recomendado. |
| Próxima (0–30) | `#FFF7ED` | `#FF7A00` | Troca próxima! | Sua troca de óleo está se aproximando. |
| Atrasada (<0) | `#FFEBEE` | `#E53935` | Troca atrasada! | Seu óleo ultrapassou o prazo recomendado. |
| Vazio | `#F2F4F7` | `#475467` | Nenhuma troca registrada | Registre a primeira troca para começar a acompanhar. |

- **Contagem de dias**: se `>= 0` mostra "N dias"; se negativo mostra "N dias de atraso" (valor absoluto)
- **Barra de progresso**: `(hoje - dataTroca) / (proxData - dataTroca)`, limitado a 0–100%.
  Cor verde/laranja/vermelho conforme status.
- **Estado vazio**: oculta a seção de progresso e itens; mostra placeholder na linha "Última troca"
- Botão "Registrar nova troca" e a linha "Última troca" → abrem o fluxo de registro (seção 7)
- "Ver histórico" → tela de Histórico (seção 8)
- **Chips de item**: fundo `#ECFDF3`, texto verde `#0F9F5A`, prefixo "✓ "

### Formatação de km

Padrão brasileiro com separador de milhar **ponto**: `209.456 km`.

```swift
let fmt = NumberFormatter()
fmt.numberStyle = .decimal
fmt.locale = Locale(identifier: "pt_BR")
fmt.maximumFractionDigits = 0
let kmText = (fmt.string(from: NSNumber(value: km)) ?? "0") + " km"  // "209.456 km"
```

---

## 7. Fluxo de Registro (3 telas)

`Registrar → Itens trocados → Confirmação`. Os dados das telas 1→2 trafegam em
memória (não persistir até a tela 2). **Só persiste em `OilChangeStore.save()` na tela 2.**

### Tela 7.1 — Registrar Nova Troca

Formulário dentro de card. Campos (na ordem):

| Campo | Tipo | Regra |
|---|---|---|
| **Data da troca** | Date picker | Obrigatório. Default = hoje. Sem digitação manual. |
| **Km atual do veículo** | Texto numérico c/ máscara | Obrigatório. Máscara `###.###` (ver seção 14). |
| **Próxima troca em** | Toggle "Por km / Por data" | Apenas alterna rótulos de obrigatoriedade |
| **Km para próxima troca** | Texto numérico c/ máscara | Default **5.000**. É o **intervalo** a somar ao km atual. |
| **Data prevista** | Date picker | Default = data da troca **+ 6 meses**. Recalcula ao mudar a data da troca (se não editada manualmente). |
| **Tipo de óleo** | Texto livre | Opcional. Placeholder "Ex: 5W30 Sintético". Max 50 chars. |
| **Observações** | Texto livre multilinha | Opcional. Placeholder "Ex: Local, marca do óleo, etc.". Max 120 chars + contador "0/120". |

- Botão **"Continuar"** (fixo no rodapé): valida obrigatórios (data + km > 0). Se ok, passa
  para a tela de Itens carregando: `date, km, nextKm (=km+intervalo), nextDate, oilType, notes`.

```swift
// Cálculo do nextKm ao continuar:
var interval = parseKm(nextKmField)         // ver seção 14
if interval <= 0 { interval = 5000 }
let nextKm = km + interval                  // ABSOLUTO

var nextDate = nextDateField
if nextDate.isEmpty { nextDate = addMonths(date, 6) }
```

### Tela 7.2 — Itens Trocados

```
Selecione os itens que foram substituídos nesta troca.
─────────────────────────────────────────
☑ Óleo do motor          (marcado por default)
☑ Filtro de óleo         (marcado por default)
☐ Filtro de ar
☐ Filtro de combustível
☐ Filtro de cabine
☐ Fluído de freio
☐ Velas de ignição
─────────────────────────────────────────
[ℹ] Marque apenas os itens que foram realmente trocados.
[          Salvar troca          ]
```

- Lista de 7 checkboxes; **Óleo do motor** e **Filtro de óleo** vêm marcados por default
- Aviso informativo (ícone info azul) abaixo da lista
- Botão **"Salvar troca"**: monta o `OilChangeRecord` completo, chama `OilChangeStore.save()`
  **mesmo que nenhum item esteja marcado**, e segue para Confirmação

### Tela 7.3 — Confirmação

```
        ✓  (círculo verde grande)
   Troca registrada com sucesso!
   Sua manutenção está em dia.
─────────────────────────────────────
Data da troca:    10/05/2026
Km atual:         45.200 km
Próxima troca:    50.200 km ou 10/11/2026
Itens trocados:
✓ Óleo do motor
✓ Filtro de óleo
✓ Filtro de ar
─────────────────────────────────────
[      Voltar para resumo      ]
[        Ver histórico          ]
```

- Lê o último registro salvo (`getLatest()`)
- "Próxima troca": `"{nextKm} km ou {nextDate}"`
- Itens com checkmark verde (mesmo estilo dos chips, aqui em lista vertical)
- "Voltar para resumo" → tela de Acompanhamento (limpar o stack do fluxo de registro)
- "Ver histórico" → tela de Histórico

---

## 8. Tela Histórico de trocas

```
┌─────────────────────────────────────────────┐
│  ← Histórico de trocas                      │
├─────────────────────────────────────────────┤
│  Card branco:                               │
│  [ Todos ] [ Óleo ] [ Filtros ]            │  ← chips de filtro (segmented)
│  ─────────────────────────────────────────  │
│  ┌─[card de troca, clicável]─────────────┐  │
│  │ 10/05/2026 • 45.200 km             >  │  │  ← data+km bold
│  │ Próxima: 50.200 km ou 10/11/2026      │  │
│  │ Óleo • Filtro de óleo • Filtro de ar  │  │  ← itens separados por •
│  └────────────────────────────────────────┘  │
│  ... (mais cards)                           │
│  [        + Nova troca         ]            │  ← botão fixo
└─────────────────────────────────────────────┘
  [ Início ] [ Postos ] [Manutenção] [Mais]
```

### Filtros

```swift
enum HistoryFilter { case todos, oleo, filtros }

func matches(_ r: OilChangeRecord, _ f: HistoryFilter) -> Bool {
    switch f {
    case .todos:   return true
    case .oleo:    return r.changedEngineOil
    case .filtros: return r.changedOilFilter || r.changedAirFilter
                       || r.changedFuelFilter || r.changedCabinFilter
    }
}
```

- **Todos**: todas as trocas
- **Óleo**: trocas com `changedEngineOil == true`
- **Filtros**: trocas com qualquer filtro marcado
- Lista vazia (após filtro) → texto "Nenhuma troca registrada ainda."
- Toque no card → tela de Detalhe (passar `timestamp`)
- "+ Nova troca" → fluxo de registro (tela 7.1)
- Recarregar a lista ao voltar para a tela (`onAppear`/`viewWillAppear`) — reflete edições/exclusões

---

## 9. Tela Detalhe da troca

Recebe um `timestamp`, busca o registro em `getHistory()`.

```
┌─────────────────────────────────────┐
│  ← Detalhes da troca                │
├─────────────────────────────────────┤
│  Data da troca                      │
│  10/05/2026                         │
│  Km atual                           │
│  45.200 km                          │
│  Km para próxima troca              │
│  50.200 km ou 10/11/2026            │
│  Observações        (só se houver)  │
│  Trocado na concessionária          │
│  Tipo de óleo       (só se houver)  │
│  5W30 Sintético - Shell Helix Ultra │
│  ─────────────────────────────────  │
│  Itens trocados                     │
│  ✓ Óleo do motor                    │
│  ✓ Filtro de óleo                   │
│  ✓ Filtro de ar                     │
│  [          Editar          ]       │  ← azul (secundário)
│  [          Excluir          ]      │  ← vermelho (contorno)
└─────────────────────────────────────┘
```

- **Observações** e **Tipo de óleo**: exibidos **apenas se preenchidos** (label + valor ocultos quando vazios)
- "Km para próxima troca": `"{nextKm} km ou {nextDate}"`
- Itens com checkmark verde (lista vertical)
- **Editar** → tela de Edição (passar `timestamp`)
- **Excluir** → tela de Exclusão (passar `timestamp`)
- Ao voltar (`onAppear`), recarregar o registro. Se ele não existir mais (foi excluído), fechar a tela.

---

## 10. Tela Editar troca

Recebe `timestamp`, pré-preenche o formulário. **Mantém as mesmas regras e tipos do cadastro.**

```
┌─────────────────────────────────────┐
│  ← Editar troca                     │
├─────────────────────────────────────┤
│  Data da troca    [10/05/2026  📅]  │
│  Km atual         [45.200 km     ]  │
│  Km para próxima  [5.000 km      ]  │  ← INTERVALO (nextKm - km)
│  Data prevista    [10/11/2026  📅]  │
│  Tipo de óleo     (só se preenchido)│
│  Observações      (só se preenchido)│
│  Itens trocados                     │
│  ☑ Óleo do motor                    │
│  ☑ Filtro de óleo                   │
│  ☑ Filtro de ar  ...                │
│  [     Salvar alterações     ]      │
└─────────────────────────────────────┘
```

- **Pré-preenchimento do "Km para próxima troca"**: mostrar o **intervalo**, não o absoluto:
  ```swift
  let interval = record.nextKm > record.km ? record.nextKm - record.km : 5000
  nextKmField = format(interval)   // ex: "5.000"
  ```
- Tipo de óleo / Observações: aparecem só se já estavam preenchidos no registro original
- Datas via date picker; Km com máscara (seção 14); validação de obrigatórios igual ao cadastro
- **"Salvar alterações"**: monta `OilChangeRecord` com o **mesmo `timestamp`** e
  `nextKm = km + intervalo`; chama `OilChangeStore.update()`; volta para o Detalhe
- O Detalhe recarrega em `onAppear` e mostra os dados atualizados

---

## 11. Tela Excluir troca

Recebe `timestamp`. Tela de confirmação (não é um simples alert — é uma tela inteira em card).

```
┌─────────────────────────────────────┐
│  ← Excluir troca                    │
├─────────────────────────────────────┤
│           ⚠️  (triângulo laranja)    │
│   Tem certeza que deseja excluir     │
│           esta troca?                │
│  ┌───────────────────────────────┐  │
│  │ Data: 10/05/2026              │  │  ← card cinza
│  │ Km atual: 45.200 km           │  │
│  └───────────────────────────────┘  │
│  [        Excluir troca        ]    │  ← botão vermelho sólido
│  [          Cancelar            ]   │  ← botão azul (secundário)
└─────────────────────────────────────┘
```

- Ícone de aviso (triângulo) laranja `#FF7A00`, grande, centralizado
- Card cinza com a **data** e o **km** da troca a ser excluída
- **"Excluir troca"** → `OilChangeStore.delete(timestamp:)` + volta para o Histórico
  (remover Detalhe e Exclusão do stack de navegação)
- **"Cancelar"** → volta (sem alterar nada)

---

## 12. Anúncios Nativos (AdMob)

Formato **Native Advanced** (Google Mobile Ads SDK para iOS — `GADNativeAd`). **Nunca usar banner.**

| Tela | Ad Unit ID |
|---|---|
| Manutenção (hub) | `ca-app-pub-1199102836233471/7477718691` |
| Troca de óleo (acompanhamento) | `ca-app-pub-1199102836233471/7477718691` |

- O container do anúncio + um divider acima ficam **ocultos** até o anúncio carregar.
- Layout do anúncio (mesmo das demais telas): badge "Patrocinado", ícone + headline + body,
  mídia opcional, botão CTA.
- Destruir o anúncio ao sair da tela (no iOS, `GADNativeAd` é liberado via ARC; garantir
  que a referência seja zerada / o `GADNativeAdView` removido).

```swift
// Pseudocódigo iOS (GADAdLoader)
let adLoader = GADAdLoader(
    adUnitID: "ca-app-pub-1199102836233471/7477718691",
    rootViewController: self,
    adTypes: [.native],
    options: nil)
adLoader.delegate = self
adLoader.load(GADRequest())

// no delegate didReceive nativeAd:
//   preencher o GADNativeAdView, tornar container + divider visíveis
```

> **App ID AdMob** (Info.plist `GADApplicationIdentifier`): `ca-app-pub-1199102836233471~8079530547`

---

## 13. Ícones

Foram trocados para ícones do **Font Awesome 6 Solid**:

| Uso | Ícone FA | SF Symbol equivalente (alternativa) |
|---|---|---|
| Manutenção (rodapé, card inicial) | `fa-solid fa-toolbox` | `wrench.and.screwdriver.fill` ou `toolbox` |
| Troca de óleo (opção, status, última troca) | `fa-solid fa-oil-can` | `oilcan.fill` (iOS 16+) |

> Se for usar os mesmos SVGs do Android para fidelidade visual, importe os assets
> `toolbox` e `oil-can` do Font Awesome como PDF/SVG no asset catalog. Caso contrário,
> use os SF Symbols equivalentes acima.

---

## 14. Segurança de inputs

Tomar os mesmos cuidados da versão Android para evitar entradas maliciosas/inconsistentes:

- **Datas**: sempre via date picker nativo — **nunca** campo de texto editável. Elimina
  qualquer parsing de string arbitrária.
- **Quilometragem**: campo numérico com máscara. Aceitar **somente dígitos**, formatar com
  separador de milhar, limitar a um teto (Android usa 9.999.999).
  ```swift
  func parseKm(_ text: String) -> Int {
      let digits = text.filter { $0.isNumber }        // remove tudo que não é dígito
      return Int(digits) ?? 0
  }
  func formatKm(_ value: Int) -> String {
      let fmt = NumberFormatter()
      fmt.numberStyle = .decimal
      fmt.locale = Locale(identifier: "pt_BR")
      return fmt.string(from: NSNumber(value: min(value, 9_999_999))) ?? "0"
  }
  ```
- **Textos livres** (tipo de óleo, observações):
  - Aplicar `maxLength` no campo (50 e 120 respectivamente)
  - Sanitizar removendo caracteres de controle ASCII antes de salvar:
    ```swift
    func sanitize(_ input: String, maxLength: Int) -> String {
        let cleaned = input.unicodeScalars
            .filter { !($0.value < 0x20 && $0 != "\n") && $0.value != 0x7F }
        var s = String(String.UnicodeScalarView(cleaned))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if s.count > maxLength { s = String(s.prefix(maxLength)) }
        return s
    }
    ```
- Como tudo é persistido em JSON via `Codable`, não há concatenação de SQL/strings —
  sem risco de injection na camada de dados.

---

## 15. Paleta de cores

Reaproveitar as cores já existentes no app iOS (devem espelhar o Android):

| Nome | Hex | Uso |
|---|---|---|
| Fundo | `#F6F8FC` | Background das telas |
| Surface | `#FFFFFF` | Cards e rodapé |
| Texto primário | `#101828` | Títulos, valores |
| Texto secundário | `#475467` | Subtítulos, labels |
| Texto muted | `#98A2B3` | Placeholders, abas inativas |
| Divider | `#E4E7EC` | Linhas separadoras |
| Azul (primário) | `#1473F8` | Abas ativas, botões, links |
| Laranja | `#FF7A00` | Status "próxima", ícone oil-can, aviso de exclusão |
| Laranja claro | `#FFF7ED` | Fundo status "próxima" |
| Verde | `#0F9F5A` | Status "ok", chips de item, checkmark |
| Verde claro | `#ECFDF3` | Fundo status "ok", fundo chips |
| Vermelho | `#E53935` | Status "atrasada", botão excluir |
| Vermelho claro | `#FFEBEE` | Fundo status "atrasada" |
| Panel | `#F2F4F7` | Fundo status vazio, card cinza de exclusão |

---

## Checklist de implementação iOS

- [ ] Calculadora: abas Calcular/Histórico; remover Histórico do rodapé; abrir Histórico via card inicial
- [ ] Adicionar aba Manutenção (rodapé de todas as telas) + card na inicial
- [ ] Tela Manutenção (hub) com opção Troca de óleo
- [ ] `OilChangeRecord` (Codable) + `OilChangeStore` (UserDefaults, máx 25)
- [ ] Tela de Acompanhamento (status, progresso, itens, botões)
- [ ] Fluxo de registro: Registrar → Itens → Confirmação
- [ ] Tela Histórico com filtros Todos/Óleo/Filtros
- [ ] Tela Detalhe (campos opcionais condicionais)
- [ ] Tela Editar (campo "próxima troca" = intervalo; salva absoluto)
- [ ] Tela Excluir (confirmação em card)
- [ ] `nextKm = km + intervalo` em registro e edição
- [ ] Anúncios nativos em Manutenção e Troca de óleo
- [ ] Ícones toolbox / oil-can
- [ ] Máscara de km, date pickers, sanitização de texto

---

> **Lembrete:** no iOS, o arquivo de configuração do Firebase/AdMob é o
> `GoogleService-Info.plist` (não `google-services.json`). Não commitar chaves privadas.
