# Contexto do Projeto - Combustível Flex iOS

Atualizado em 2026-05-09.

## Local

- Repositório: `iluciano/CombustivelFlex_iOS`
- Caminho local: `/Users/igorluciano/Documents/projetos/CombustivelFlex_iOS`
- Branch atual: `main`

## Regras de Trabalho

- Não executar testes pelo terminal/Codex neste projeto. O usuário executa testes pelo Xcode.
- Pode rodar apenas build do app com `xcodebuild build`.
- Manter SwiftUI moderno. Dependência externa atual: Google Mobile Ads via Swift Package Manager.
- Preservar arquitetura simples por pastas: `Views`, `ViewModels`, `Models`, `Services`, `Components`, `Theme`.

## Estado Atual

O app compila e está com o fluxo principal do MVP implementado:

- Tela inicial com imagem real de estrada no topo e menu estilo Android.
- Tela de cálculo com imagem real no topo, máscara nos inputs, botão `Calcular` e botão `Limpar`.
- Resultado em tela própria, com botão `Recalcular` limpando os campos ao voltar para cálculo.
- Histórico local funcionando, incluindo limpar histórico.
- Postos próximos com tela “em breve” e imagem própria.
- Dicas de economia com cards estilo Android.
- Configurações com unidade visual, consumo padrão, notificações, lembrete, avaliar, compartilhar e versão.
- Consumos padrão de Configurações são carregados automaticamente na tela de cálculo.
- Ao calcular com consumos diferentes dos padrões salvos, o app pergunta se deve salvar/substituir o padrão.
- Google AdMob integrado:
  - banners em Calcular, Resultado, Configurações e Dicas;
  - anúncio nativo avançado na aba Mais.

## Validação

Build validado por Codex:

```bash
xcodebuild build -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -destination 'generic/platform=iOS Simulator' -quiet
```

Testes:

- Existe target `CombustivelFlexTests`.
- Existe `FuelCalculationServiceTests`.
- Testes unitários passaram quando executados pelo usuário no Xcode.
- Não rodar `xcodebuild test` pelo terminal, pois travou o sistema anteriormente.

## Regra de Cálculo

Implementada em `CombustivelFlex/Services/FuelCalculationService.swift`.

- Preços devem ser maiores que zero.
- Consumos devem ser ambos preenchidos ou ambos vazios.
- Sem consumo: usa regra dos 70%.
- Com consumo: usa custo por km.
- Em empate, recomenda gasolina.
- Retorna combustível recomendado, base do cálculo, razão/custos e economia estimada.

## Persistência

- `HistoryStore`: salva histórico local com `UserDefaults + Codable`, limite de 25 itens.
- `SettingsStore`: salva preferências com `UserDefaults`.
- Configurações salvas hoje:
  - unidade visual (`R$/L` ou `R$/km`);
  - consumo padrão gasolina;
  - consumo padrão etanol;
  - notificações habilitadas;
  - lembrar de revisar preços.

## AdMob

SDK: `GoogleMobileAds` via Swift Package Manager.

App ID configurado no `Info.plist` gerado:

- `ca-app-pub-1199102836233471~1616819670`

Arquivos principais:

- `AdMobConfig.swift`: IDs de anúncios.
- `AdMobBannerView.swift`: banner SwiftUI com banner adaptativo.
- `AdMobNativeAdView.swift`: native advanced ad usado na tela Mais.

IDs configurados:

- Calcular: `ca-app-pub-1199102836233471/5444833758`
- Resultado: `ca-app-pub-1199102836233471/9755164144`
- Configurações: `ca-app-pub-1199102836233471/9891345223`
- Dicas: `ca-app-pub-1199102836233471/8394430723`
- Mais native advanced: `ca-app-pub-1199102836233471/6566343739`

Observação: antes de distribuição, revisar exigências finais do AdMob, consentimento/privacidade e SKAdNetwork conforme documentação vigente.

## Assets

Assets adicionados:

- `road_header`: imagem real da estrada usada no topo da tela inicial e da tela de cálculo.
- `stations_hero`: imagem da tela de postos próximos.

Ainda pendente:

- App Icon final.
- Launch Screen.
- Avaliar app e compartilhar com amigos com links reais quando houver App Store ID.

## Navegação

- `RootTabView` controla as abas principais.
- Aba `Início` usa `NavigationPath` com rotas:
  - `.calculator`
  - `.tips`
  - `.settings`
- Ao voltar para a aba `Início` pelo rodapé, a navegação da Home é resetada para a primeira tela.
- Histórico e Postos na tela inicial trocam diretamente a aba ativa.

## Próximo Passo Recomendado

Validar manualmente no simulador:

1. Fluxo da tela inicial para Calcular, Dicas e Configurações.
2. Voltar pelo rodapé para Início e confirmar que os menus continuam funcionando.
3. Configurações -> consumo padrão -> Calculadora.
4. Cálculo -> pergunta para salvar/substituir consumo padrão -> Resultado -> Recalcular.

Depois disso, próximos blocos naturais:

- Ajustar App Icon e Launch Screen.
- Evoluir notificações reais.
- Implementar avaliação/compartilhamento quando houver links da loja.
- Validar anúncios em device/simulador pelo Xcode e checar políticas/consentimento AdMob.
- Preparar primeiro build de distribuição.
