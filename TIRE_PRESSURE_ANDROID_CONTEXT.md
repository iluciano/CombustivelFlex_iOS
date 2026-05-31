# Contexto Android — Calibragem dos Pneus

Este documento resume as alterações feitas hoje no app iOS para replicação na versão Android do Combustível Flex.

## Menu Inicial

- Remover o destaque da opção **Postos próximos**.
- Remover o selo **Novo** de **Postos próximos**.
- Adicionar o destaque visual na opção **Manutenção**.
- Adicionar o selo **Novo** na opção **Manutenção**.

## Tela Manutenção

Adicionar o item **Calibragem dos pneus** logo abaixo de **Troca de óleo**.

Texto do item:
- Título: `Calibragem dos pneus`
- Subtítulo: `Calibre e economize combustível`
- Ícone: usar um ícone azul relacionado a pressão/calibragem/pneu.

Não adicionar ainda o item **Revisões**.

## Fluxo Calibragem dos Pneus

Criar um fluxo dentro de Manutenção com:

1. Resumo da calibragem
2. Nova calibragem
3. Medir pneus
4. Calibragem salva
5. Histórico de calibragens
6. Detalhes da calibragem
7. Editar calibragem
8. Excluir calibragem

Todas as telas devem seguir o padrão visual do app: conteúdo em cards brancos, fundo claro, botões azuis principais e navegação consistente com as outras telas de manutenção.

## Modelo de Dados

Criar um registro local para calibragem:

```kotlin
data class TirePressureRecord(
    val timestamp: Long,
    val date: String,          // dd/MM/yyyy
    val km: Int?,              // opcional
    val wasFueled: Boolean,
    val tireCondition: String, // "Frio" ou "Quente"
    val frontLeft: Int,
    val frontRight: Int,
    val rearLeft: Int,
    val rearRight: Int
)
```

Persistência:
- Local, semelhante ao histórico de troca de óleo.
- Guardar uma lista com limite de 25 registros.
- O registro mais recente deve alimentar a tela de resumo.
- Implementar `save`, `update`, `delete`, `getHistory` e `getLatest`.

## Tela Resumo

Primeira tela ao clicar em **Calibragem dos pneus**.

Se não houver registro:
- Mostrar status: `Nenhuma calibragem registrada`
- Mensagem: `Registre a pressão recomendada para acompanhar melhor os pneus.`
- Mostrar botão: `+ Registrar calibragem`
- Mostrar botão: `Histórico`
- Mostrar card de dica sobre pressão correta.

Se houver registro:
- Mostrar status verde:
  - Título: `Tudo certo!`
  - Mensagem: `Suas pressões recomendadas estão salvas.`
- Mostrar carro no centro da tela.
- Mostrar cards das pressões ao redor do carro:
  - Dianteiro esquerdo
  - Dianteiro direito
  - Traseiro esquerdo
  - Traseiro direito
- Mostrar:
  - `Última calibragem`: data do último registro
  - `Próxima verificação`: 7 dias após a data da calibragem
- Mostrar botão: `+ Registrar calibragem`
- Mostrar botão: `Histórico`

## Imagem do Carro

Usar uma imagem de carro visto de cima, posicionada verticalmente no centro.

No iOS foi usado o arquivo:
- `carro_app.png`

No Android, inserir uma imagem equivalente no `drawable` e posicionar entre os cards de pressão.

## Dica Educativa

Exibir a dica em um card informativo, preferencialmente azul claro com ícone de informação:

```text
A pressão correta varia de acordo com o veículo, pneu e carga.
Use sempre a pressão indicada pelo fabricante do carro.

Para melhor precisão, calibre com os pneus frios:
carro parado há pelo menos 3 horas ou rodando menos de 2 km.
```

Em telas menores ou durante cadastro, pode usar uma versão compacta:

```text
Use sempre a pressão indicada pelo fabricante. Para melhor precisão, calibre com pneus frios.
```

## Tela Nova Calibragem

Campos:
- `Data da calibragem`
- `Quilometragem (opcional)`
- `Abastecido?`
  - `Sim`
  - `Não`
- `Condição dos pneus`
  - `Frio`
  - `Quente`

Ao selecionar **Quente**, mostrar alert:

```text
Atenção: pneus quentes podem indicar pressão maior.
Use como referência a pressão recomendada pelo fabricante com pneus frios.
```

Botão principal:
- `Continuar`

## Tela Medir Pneus

Título:

```text
Qual a pressão recomendada do seu carro?
```

Dica logo abaixo:

```text
Confira essa informação na etiqueta da porta do motorista,
na tampa do combustível ou no manual do veículo.
```

Campos:
- `Dianteiro esq.`
- `Dianteiro dir.`
- `Traseiro esq.`
- `Traseiro dir.`

Cada campo aceita apenas números e mostra unidade `psi`.

Layout:
- Carro no centro.
- Dois campos à esquerda.
- Dois campos à direita.

Após preencher os 4 valores, mostrar o bloco:

```text
Pressão recomendada
Dianteiro: 32 psi • Traseiro: 30 psi
```

Se os valores dianteiros forem diferentes, mostrar `32/33`.
Se os traseiros forem diferentes, mostrar `30/31`.

Botão:
- `Salvar`

O botão só deve ficar habilitado quando os 4 campos tiverem valor válido.

## Tela Calibragem Salva

Mostrar:
- Ícone verde de sucesso.
- Texto: `Calibragem salva com sucesso!`
- Data.
- Km.
- Condição.
- Pressões:
  - Dianteiro esquerdo
  - Dianteiro direito
  - Traseiro esquerdo
  - Traseiro direito

Botão principal:
- `Voltar para resumo`

## Tela Histórico

Título:
- `Histórico de calibragens`

Cada item da lista deve mostrar:
- Data
- Quilometragem
- Resumo das pressões:
  - `DE 32`
  - `DD 32`
  - `TE 30`
  - `TD 30`

Cada item deve abrir a tela de detalhes.

Botão:
- `+ Nova calibragem`

Estado vazio:
- `Nenhuma calibragem registrada ainda.`

## Tela Detalhes

Título:
- `Detalhes da calibragem`

Mostrar:
- Data
- Quilometragem
- Abastecido: `Sim` ou `Não`
- Condição dos pneus: `Frio` ou `Quente`
- Pressões dos 4 pneus

Botões:
- `Editar`
- `Excluir`

O botão **Excluir** deve abrir o mesmo fluxo de confirmação usado em troca de óleo.

## Tela Editar

Título:
- `Editar calibragem`

Layout:
- Carro no centro.
- Campos das pressões ao redor.
- Campo `Data da calibragem`.
- Campo `Quilometragem`.
- Campo `Abastecido?`.
- Campo `Condição dos pneus`.

Ao selecionar **Quente**, mostrar o mesmo alert da tela de nova calibragem.

Botão:
- `Salvar alterações`

Ao salvar:
- Atualizar o registro existente.
- Voltar para a tela anterior.

## Tela Excluir

Seguir o mesmo padrão da exclusão de troca de óleo:
- Ícone de alerta.
- Pergunta: `Tem certeza que deseja excluir esta calibragem?`
- Resumo do registro.
- Botão vermelho: `Excluir calibragem`
- Botão secundário: `Cancelar`

Ao excluir:
- Remover o registro da persistência local.
- Voltar para a tela de histórico/detalhes de forma natural.

## Textos e Ortografia

Usar sempre:
- `Calibragem dos pneus`
- `Calibre e economize combustível`
- `Quilometragem`
- `Dianteiro esquerdo`
- `Dianteiro direito`
- `Traseiro esquerdo`
- `Traseiro direito`
- `Condição dos pneus`
- `Pressão recomendada`

Corrigir ortografia sempre que encontrar textos antigos ou inconsistentes.

## Observações de UX

- Evitar textos cortados em cards.
- Usar subtítulos curtos em menus.
- Manter botões grandes, claros e com boa área de toque.
- Desabilitar botões de avanço/salvar quando o formulário estiver incompleto.
- A dica de pneus frios deve aparecer sem atrapalhar o fluxo principal.
- O fluxo deve ser simples: registrar dados gerais, informar pressão recomendada, salvar e depois acompanhar no resumo.
