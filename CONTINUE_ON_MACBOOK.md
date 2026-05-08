# Continuacao no MacBook - Combustivel Flex iOS

Este repositorio contem o inicio da versao iOS nativa em SwiftUI do app Combustivel Flex.

## Decisao de organizacao

A melhor direcao para seguir e manter o iOS como projeto separado do Android.

Motivos:

- O projeto iOS tem estrutura, build, signing e assets proprios do Xcode.
- Evita misturar Gradle/Android Studio com Xcode no mesmo fluxo diario.
- Facilita publicar releases independentes e configurar CI especifico para iOS.
- Mantem o Android estavel enquanto a versao iOS evolui.

O codigo iOS esta no repositorio separado `iluciano/CombustivelFlex_iOS`.

## Como abrir no MacBook

1. Clone o repositorio:

```bash
git clone https://github.com/iluciano/CombustivelFlex_iOS.git
cd CombustivelFlex_iOS
```

2. Abra o arquivo:

```bash
open CombustivelFlex.xcodeproj
```

3. No Xcode, selecione o target `CombustivelFlex`.
4. Ajuste o `Team` em `Signing & Capabilities`.
5. Rode em um simulador iPhone recente.

## Estado atual

O app SwiftUI inicial possui:

- `CombustivelFlexApp` como ponto de entrada.
- `RootTabView` com abas: Inicio, Historico, Postos e Mais.
- `HomeView` com formulario inicial de gasolina, etanol e consumos.
- Componentes reutilizaveis em `Components/`.
- Tema centralizado em `Theme/AppTheme.swift`.
- Models iniciais em `Models/`.
- Services iniciais em `Services/`.
- ViewModel inicial em `ViewModels/HomeViewModel.swift`.

Ainda nao foram implementadas todas as regras do app Android. O calculo atual e apenas um preview simples pela regra dos 70%.

## Proximos passos recomendados

1. Abrir o projeto no Xcode e corrigir qualquer ajuste automatico que o Xcode sugerir.
2. Definir o Bundle ID final do app iOS.
3. Configurar Signing & Capabilities com a conta Apple Developer.
4. Rodar o app no simulador e confirmar a navegacao inicial.
5. Implementar testes unitarios para `FuelCalculationService`.
6. Migrar a regra completa:
   - validacao de precos maiores que zero;
   - consumo informado para os dois combustiveis ou para nenhum;
   - calculo por custo por km quando houver consumo;
   - regra de 70% quando nao houver consumo;
   - economia estimada.
7. Implementar persistencia real em `HistoryStore` com `UserDefaults` e `Codable`.
8. Implementar `SettingsStore` com `@AppStorage` ou `UserDefaults`.
9. Evoluir `HistoryView`, `SettingsView`, `TipsView` e `StationsView`.
10. Migrar assets reais do Android para `Assets.xcassets`.
11. Adicionar App Icon e Launch Screen.
12. Integrar AdMob iOS somente depois que o MVP sem dependencias estiver estavel.

## Arquivos importantes

- `IOS_MIGRATION_PLAN.md`: plano de migracao gerado a partir do app Android.
- `CombustivelFlex.xcodeproj`: projeto Xcode inicial.
- `CombustivelFlex/App/CombustivelFlexApp.swift`: entrada do app.
- `CombustivelFlex/Views/RootTabView.swift`: navegacao principal.
- `CombustivelFlex/Views/HomeView.swift`: tela inicial de calculo.
- `CombustivelFlex/Theme/AppTheme.swift`: cores, espacamentos e radius.
- `CombustivelFlex/Models/FuelCalculation.swift`: models de calculo.
- `CombustivelFlex/Services/FuelCalculationService.swift`: service inicial de calculo.
- `CombustivelFlex/ViewModels/HomeViewModel.swift`: estado da Home.

## Observacoes para o Codex no MacBook

Ao continuar:

- Priorize compilar no Xcode antes de adicionar novas features.
- Nao adicione dependencias externas no comeco.
- Preserve a identidade visual do Android, mas adapte interacoes ao padrao iOS.
- Use `Decimal` para valores monetarios quando implementar a regra completa.
- Mantenha as regras de negocio isoladas em services testaveis.
- So integre AdMob, notificacoes e MapKit em etapas separadas.

## Comando util de verificacao

No MacBook, depois de abrir o projeto, tambem da para validar pelo terminal:

```bash
xcodebuild -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Se o simulador `iPhone 16` nao existir, escolha um destino disponivel:

```bash
xcodebuild -showdestinations -project CombustivelFlex.xcodeproj -scheme CombustivelFlex
```
