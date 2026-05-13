# Contexto do Projeto - Combustível Flex iOS

Atualizado em 2026-05-13.

## Local

- Repositório: `iluciano/CombustivelFlex_iOS`
- Caminho local: `/Users/iluciano/Documents/projetos/CombustivelFlex_iOS`
- Branch atual: `main`
- Último commit remoto conhecido: `97cc7c0 Update production context`

## Regras de Trabalho

- Pode executar testes pelo terminal/Codex quando necessário.
- Validar mudanças relevantes com `xcodebuild test` e builds de produção com `xcodebuild build/archive`.
- Manter SwiftUI moderno. Dependência externa atual: Google Mobile Ads via Swift Package Manager.
- Preservar arquitetura simples por pastas: `Views`, `ViewModels`, `Models`, `Services`, `Components`, `Theme`.

## Estado Atual

O app compila e está com o fluxo principal do MVP implementado:

- Tela inicial com imagem real de estrada no topo e menu estilo Android.
- Tela de cálculo com imagem real no topo, card principal, máscara nos inputs, botão `Calcular`, botão `Limpar` e banner dentro do card.
- Resultado em tela própria dentro de card, com botão `Recalcular` limpando os campos ao voltar para cálculo e banner dentro do card.
- Histórico local funcionando dentro de card, incluindo limpar histórico.
- Postos próximos com tela “em breve” e imagem própria.
- Dicas de economia dentro de card principal, com cards estilo Android e banner dentro do card.
- Configurações dentro de card principal, com unidade visual, consumo padrão, notificações, lembrete, avaliar, compartilhar, versão e banner dentro do card.
- Consumos padrão de Configurações são carregados automaticamente na tela de cálculo.
- Ao calcular com consumos diferentes dos padrões salvos, o app pergunta se deve salvar/substituir o padrão.
- Google AdMob integrado:
- banners em Calcular, Resultado, Configurações e Dicas, dentro do card principal de cada tela;
  - anúncio nativo avançado na aba Mais, dentro do card principal.
- Postos próximos não usa o padrão de card principal por decisão de layout.
- Anúncios só ocupam espaço quando carregados; quando o AdMob não entrega criativo, a UI não exibe bloco branco.
- Rodapé com cores adaptativas para modo claro/escuro.
- Inputs numéricos com texto escuro explícito e máscara ajustada para permitir apagar naturalmente.
- Configurações não exibem consumos padrão falsos; os cards ficam sem valor até o usuário salvar.
- Tela Mais usa cards separados no estilo Android, com contraste próprio em modo claro/escuro.
- AdMob aguarda a inicialização do SDK antes de chamar `load` em banners e native advanced.
- iPhone travado em portrait para preservar o layout atual.
- Bundle Identifier configurado para App Store: `br.com.igorluciano.combustivelflex`.
- Team configurado no projeto Xcode: `WK7S77VS67`.
- App Icon configurado em `AppIcon.appiconset` e conectado ao target via `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`.
- `UIRequiresFullScreen = true` configurado no `Info.plist`.

## Validação

Builds/testes validados por Codex:

```bash
xcodebuild test -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -destination 'platform=iOS Simulator,name=iPhone 17' -quiet
xcodebuild build -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -configuration Release -destination 'generic/platform=iOS' -quiet
xcodebuild archive -project CombustivelFlex.xcodeproj -scheme CombustivelFlex -configuration Release -destination 'generic/platform=iOS' -archivePath build/CombustivelFlex-1.0.2.xcarchive -quiet
```

Testes:

- Existe target `CombustivelFlexTests`.
- Existe `FuelCalculationServiceTests`.
- Existe `NumericInputMaskTests`.
- Testes unitários passaram via terminal no simulador `iPhone 17`.

Archive:

- `build/CombustivelFlex-1.0.2.xcarchive` foi gerado com sucesso.
- O archive contém dSYMs do app e dos frameworks Google:
  - `CombustivelFlex.app.dSYM`
  - `GoogleMobileAds.framework.dSYM`
  - `UserMessagingPlatform.framework.dSYM`

## Preparação App Store

Status em 2026-05-09:

- App criado/preparado no App Store Connect com Bundle ID `br.com.igorluciano.combustivelflex`.
- Archive local no Mac antigo falhou no upload porque o ambiente estava em:
  - Xcode `16.2`;
  - iOS SDK `18.2`.
- O App Store Connect exigiu build com:
  - Xcode `26` ou superior;
  - iOS SDK `26` ou superior.
- Esse bloqueio é de ambiente, não de código. O Mac antigo não roda Xcode 26.

No Mac novo:

1. Clonar/puxar `main` do repositório.
2. Instalar Xcode 26 ou superior.
3. Abrir `CombustivelFlex.xcodeproj`.
4. Em `Xcode > Settings > Locations`, selecionar o Xcode novo em `Command Line Tools`.
5. Conferir em `Signing & Capabilities`:
   - Team: `WK7S77VS67`;
   - Bundle Identifier: `br.com.igorluciano.combustivelflex`;
   - Signing automático habilitado.
6. Rodar o app em simulador/dispositivo e confirmar:
   - App Icon aparece corretamente;
   - fluxo principal abre;
   - anúncios não sobrepõem a tab bar;
   - tela Mais não acusa problemas no AdMob native validator.
7. Fazer `Product > Archive`.
8. Confirmar no archive os dSYMs de `GoogleMobileAds.framework` e `UserMessagingPlatform.framework`.
9. No Organizer, validar e enviar para App Store Connect.
10. Se houver erro de ícone no App Store Connect, confirmar no target:
   - `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`;
   - `Assets.xcassets/AppIcon.appiconset` possui `AppIcon-1024x1024@1x.png`.

Versão atual preparada para produção:

- `MARKETING_VERSION = 1.0.2`
- `CURRENT_PROJECT_VERSION = 4`

Archive local gerado em `build/CombustivelFlex-1.0.2.xcarchive`.

Observação sobre dSYMs:

- O Swift Package do Google Mobile Ads não inclui dSYMs prontos nos XCFrameworks baixados.
- O script `scripts/add_google_dsyms_to_archive.sh` gera dSYMs compatíveis a partir dos binários dentro do archive.
- O scheme compartilhado `CombustivelFlex.xcscheme` possui Post-action de Archive chamando esse script.
- Se o Organizer ainda acusar dSYM ausente, rodar manualmente:

```bash
scripts/add_google_dsyms_to_archive.sh build/CombustivelFlex-1.0.2.xcarchive
```

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

App ID configurado em `CombustivelFlex/Info.plist` explícito:

- `ca-app-pub-1199102836233471~1616819670`

Arquivos principais:

- `AdMobConfig.swift`: IDs de anúncios.
- `AdMobBannerView.swift`: banner SwiftUI com banner adaptativo, `rootViewController` explícito, carregamento protegido e espaço reservado apenas quando há anúncio carregado.
- `AdMobNativeAdView.swift`: native advanced ad usado na tela Mais com `MediaView` de 120x120, carregamento protegido e espaço reservado apenas quando há anúncio carregado.
- `scripts/add_google_dsyms_to_archive.sh`: pós-processa o `.xcarchive` para incluir dSYMs do `GoogleMobileAds.framework` e `UserMessagingPlatform.framework`.

IDs configurados:

- Calcular: `ca-app-pub-1199102836233471/5444833758`
- Resultado: `ca-app-pub-1199102836233471/9755164144`
- Configurações: `ca-app-pub-1199102836233471/9891345223`
- Dicas: `ca-app-pub-1199102836233471/8394430723`
- Mais native advanced: `ca-app-pub-1199102836233471/6566343739`

Observação: antes de distribuição, revisar exigências finais do AdMob, consentimento/privacidade, ATT se aplicável e SKAdNetwork conforme documentação vigente.

## Assets

Assets adicionados:

- `road_header`: imagem real da estrada usada no topo da tela inicial e da tela de cálculo.
- `stations_hero`: imagem da tela de postos próximos.
- `AppIcon.appiconset`: ícone final do app com tamanhos iPhone/iPad/App Store, incluindo `1024x1024`.

Ainda pendente:

- Launch Screen.
- Avaliar app e compartilhar com amigos com links reais quando houver App Store ID.
- Screenshots para App Store.
- Textos/metadados da loja.
- Declaração de privacidade/App Privacy.

## Navegação

- `RootTabView` controla as abas principais.
- Aba `Início` usa `NavigationPath` com rotas:
  - `.calculator`
  - `.tips`
  - `.settings`
- Ao voltar para a aba `Início` pelo rodapé, a navegação da Home é resetada para a primeira tela.
- Histórico e Postos na tela inicial trocam diretamente a aba ativa.

## Próximo Passo Recomendado

Validar manualmente no simulador/Xcode:

1. Fluxo da tela inicial para Calcular, Dicas e Configurações.
2. Voltar pelo rodapé para Início e confirmar que os menus continuam funcionando.
3. Configurações -> consumo padrão -> Calculadora.
4. Cálculo -> pergunta para salvar/substituir consumo padrão -> Resultado -> Recalcular.
5. AdMob validator nas telas com anúncios, especialmente aba Mais.
6. Modo claro/escuro do rodapé.

Depois disso, próximos blocos naturais:

- Ajustar Launch Screen.
- Evoluir notificações reais.
- Implementar avaliação/compartilhamento quando houver links da loja.
- Validar anúncios em device/simulador pelo Xcode e checar políticas/consentimento AdMob.
- Enviar versão `1.0.2 (4)` para App Store Connect.
