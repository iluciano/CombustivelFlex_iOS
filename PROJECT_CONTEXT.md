# Contexto do Projeto - Combustível Flex iOS

Atualizado em 2026-05-08.

## Objetivo

Criar uma versão iOS nativa em SwiftUI do app Android Combustível Flex, mantendo a identidade visual e as regras de negócio, mas adaptando navegação e interações para padrões naturais do iOS.

O iOS permanece em repositório separado:

- GitHub: `iluciano/CombustivelFlex_iOS`
- Caminho local: `/Users/igorluciano/Documents/projetos/CombustivelFlex_iOS`

## Decisões

- Manter arquitetura simples: `Views`, `ViewModels`, `Models`, `Services`, `Components` e `Theme`.
- Usar SwiftUI moderno com `TabView` e `NavigationStack`.
- Evitar dependências externas no começo.
- Manter regras de negócio isoladas em services testáveis.
- Usar `Decimal` para valores monetários nas próximas etapas.
- AdMob, notificações e MapKit ficam para etapas separadas após o MVP sem dependências.

## Estado Atual

O projeto compila com `xcodebuild` usando destino genérico de simulador.

Comando validado:

```bash
xcodebuild -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -destination 'generic/platform=iOS Simulator' build
```

Observação: nesta máquina o `xcodebuild -showdestinations` mostrou apenas destinos genéricos, sem um simulador nomeado como `iPhone 16`.

## Estrutura Atual

- `CombustivelFlex/App/CombustivelFlexApp.swift`: entrada do app.
- `CombustivelFlex/Views/RootTabView.swift`: abas principais.
- `CombustivelFlex/Views/StartView.swift`: tela inicial com atalhos, alinhada ao fluxo Android.
- `CombustivelFlex/Views/CalculatorView.swift`: formulário de preços e consumos.
- `CombustivelFlex/Views/ResultView.swift`: tela própria de resultado.
- `CombustivelFlex/Views/HistoryView.swift`: placeholder de histórico.
- `CombustivelFlex/Views/StationsView.swift`: placeholder de postos próximos.
- `CombustivelFlex/Views/MoreView.swift`: atalhos de dicas e configurações.
- `CombustivelFlex/ViewModels/CalculatorViewModel.swift`: estado da calculadora.
- `CombustivelFlex/Services/FuelCalculationService.swift`: cálculo inicial.
- `CombustivelFlex/Services/HistoryStore.swift`: stub de histórico.
- `CombustivelFlex/Services/SettingsStore.swift`: stub de configurações.
- `CombustivelFlex/Models/FuelCalculation.swift`: tipos de entrada/resultado.
- `CombustivelFlex/Models/CalculationHistoryItem.swift`: item do histórico.
- `CombustivelFlex/Models/AppTab.swift`: metadados das abas.
- `CombustivelFlex/Components/`: componentes reutilizáveis.
- `CombustivelFlex/Theme/AppTheme.swift`: cores, espaçamentos e raios.

## Fluxo Atual

1. App abre em `RootTabView`.
2. Aba `Início` mostra `StartView`.
3. `Calcular combustível` navega para `CalculatorView`.
4. `CalculatorView` valida preços maiores que zero e calcula pela regra simples atual.
5. Resultado abre em `ResultView`, separado da tela de cálculo.
6. `Recalcular` volta para a calculadora.
7. Atalhos de Histórico e Postos trocam a aba ativa.
8. Dicas e Configurações ainda usam placeholders.

## Regra Atual Implementada

O cálculo atual ainda é simples:

- Usa regra dos 70%.
- Etanol vence quando `precoEtanol / precoGasolina < 0.7`.
- Valida apenas gasolina e etanol maiores que zero.

Ainda não foi migrada a regra completa do Android.

## Regra Completa a Migrar

Regras do Android que devem entrar na próxima etapa:

- Preços e consumos devem ser maiores que zero.
- Consumo deve ser informado para os dois combustíveis ou para nenhum.
- Se houver consumo de gasolina e etanol, usar custo por km:
  `precoEtanol * consumoGasolina < precoGasolina * consumoEtanol`.
- Se não houver consumo, usar regra de 70%.
- Calcular economia estimada.
- Salvar resultado válido no histórico.
- Usar consumo padrão salvo quando existir.
- Se consumos informados forem diferentes dos padrões, perguntar se deve atualizar os padrões.

## Funcionalidades Planejadas

- Testes unitários para `FuelCalculationService`.
- Persistência real de histórico em `HistoryStore` com `UserDefaults` e `Codable`, limite de 25 itens.
- `SettingsStore` com `@AppStorage` ou `UserDefaults`.
- Evolução de `HistoryView`, `SettingsView`, `TipsView` e `StationsView`.
- Migração dos assets reais do Android para `Assets.xcassets`.
- App Icon e Launch Screen.
- AdMob iOS somente depois do MVP estável sem dependências.
- Postos próximos com MapKit/CoreLocation apenas quando a funcionalidade for priorizada.

## Assets Necessários

Assets bitmap a buscar/migrar do Android:

- `new_header_road.png`
- `new_stations_hero.png`
- `car.png`
- `desertroad4k.png`
- `ic_launcher.png`
- `ic_local_gas_station_black_48dp.png`

Enquanto o asset real da estrada não estiver no repo, `StartView` usa um cabeçalho desenhado em SwiftUI apenas como substituto visual.

## Cores Base

- Background: `#F6F8FC`
- Surface: `#FFFFFF`
- Texto primário: `#101828`
- Texto secundário: `#475467`
- Texto muted: `#98A2B3`
- Divider: `#E4E7EC`
- Azul: `#1473F8`
- Laranja: `#FF7A00`
- Verde: `#0F9F5A`
- Verde claro: `#ECFDF3`

## Dúvidas Pendentes

- Qual será o Bundle ID final?
- Existe App Store ID para avaliação/compartilhamento?
- Existem assets em alta resolução fora do projeto Android?
- A primeira versão iOS deve sair sem anúncios?
- Postos próximos permanece "em breve" no MVP ou já deve usar MapKit/CoreLocation?
- O lembrete de preços deve agendar notificações locais ou permanecer preferência visual?
- A unidade `R$/km` deve afetar cálculo, labels ou permanecer futura?

## Próximo Passo Recomendado

Implementar a regra completa em `FuelCalculationService` com testes unitários antes de evoluir persistência, histórico e configurações.
