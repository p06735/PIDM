# Spec — Nova Receita · Passo 2: Ingredientes

## 1. Captura

Referência visual: `specs/img/nova_receita_passo2.png` (captura fornecida, 365×634, retrato).

Segunda tela do fluxo de criação de receita em 3 passos (**Informações → Ingredientes → Método**). O usuário chega aqui ao tocar em "Continuar" no Passo 1 com um título válido. Aqui ele monta a lista de ingredientes, e cada item tem uma quantidade e uma descrição.

**Padronização com o Passo 1 (decisão final).** A captura tinha um visual próprio (indicador "PASSO 2 DE 3", seta de voltar na AppBar, título terracota à direita e botão verde-oliva). Ficou decidido seguir o padrão do Passo 1, então esta tela usa os mesmos componentes dele: AppBar só com o X e título centralizado, o mesmo indicador de 3 rótulos, o mesmo cabeçalho serifado e o mesmo rodapé. A captura continua valendo para o conteúdo e a disposição da lista de ingredientes.

Estilo:
- Fundo creme claro; campos com fundo bege, borda bege e cantos arredondados (~8px).
- Cor de destaque terracota (barra de progresso, rótulo do passo ativo, botão "Adicionar Ingrediente", botão "Continuar").
- Títulos em fonte serifada ("Nova Receita", "Lista de Ingredientes"); demais textos em sans-serif.

## 2. Elementos

Ordem de cima para baixo. **[T]** = tocável.

| # | Elemento | Descrição |
|---|---|---|
| E1 | **[T]** Botão fechar (X) | Ícone no canto superior esquerdo da AppBar. |
| E2 | Título da AppBar | "Nova Receita", serifado, centralizado. |
| E3 | Indicador de progresso | Rótulos "Informações", "Ingredientes" (ativo, terracota, negrito), "Método"; barra preenchida em 2/3; legenda "Passo 2 de 3". Não tocável. |
| E4 | Cabeçalho da seção | "Lista de Ingredientes" (serifado, grande) + subtítulo "Quais ingredientes são necessários para preparar essa delícia? Liste-os com clareza." |
| E5 | **[T]** Campo "Qtd" (por linha) | Campo estreito (~30% da largura) à esquerda; placeholder "Qtd"; uma linha. |
| E6 | **[T]** Campo de descrição (por linha) | Campo largo à direita da quantidade; placeholder "Ex: Gramas de Manteiga..."; o texto quebra em várias linhas e o campo cresce em altura. |
| E7 | **[T]** Botão remover (lixeira, por linha) | Ícone à direita da linha. Não aparece na linha vazia do fim da lista. |
| E8 | **[T]** Botão "+ Adicionar Ingrediente" | Pílula com contorno terracota, centralizada abaixo da lista. |
| E9 | **[T]** Botão "← Voltar" | Botão de texto, rodapé fixo à esquerda (mesma posição e estilo do "Salvar Rascunho" do Passo 1). |
| E10 | **[T]** Botão "Continuar →" | Botão preenchido terracota, em pílula, rodapé fixo à direita. |

Uma **linha de ingrediente** é o conjunto E5 + E6 + E7. A lista mostra as linhas na ordem em que foram criadas.

Comportamento de layout: a AppBar (E1–E2) e o indicador (E3) ficam fixos no topo, o rodapé (E9–E10) fica fixo embaixo e o conteúdo (E4–E8) rola entre eles. Com o teclado aberto, o rodapé sobe acima do teclado e o campo focado continua visível. Os avisos (ex.: "Ingrediente removido") aparecem **acima do rodapé**, sem cobrir os botões.

Fonte grande (acessibilidade): com o texto do sistema ampliado, nada é cortado nem estoura a tela (os rótulos do indicador e o texto dos botões encolhem com reticências).

## 3. Dados

Novo modelo `Ingrediente`:

| Campo | Tipo | Obrigatório | Limite / regra | Padrão |
|---|---|---|---|---|
| `quantidade` | `String` | Não | máx. 10 caracteres; texto livre (ex.: "2", "1/2", "200 g", "a gosto") | `""` |
| `descricao` | `String` | **Sim** (para a linha contar) | máx. 80 caracteres (entrada bloqueada no limite); uma linha lógica | `""` |

Campo novo em `ReceitaRascunho` (compartilhado pelos 3 passos):

| Campo | Tipo | Obrigatório p/ Continuar | Limite / regra | Padrão |
|---|---|---|---|---|
| `ingredientes` | `List<Ingrediente>` | **Sim** | Pelo menos 1 ingrediente com descrição; máx. 50 | `[]` |

Regras de linha (sempre após `trim()`):
- **Linha vazia:** quantidade e descrição vazias. É ignorada ao continuar e ao salvar, e nunca gera erro.
- **Linha válida:** descrição preenchida. A quantidade pode ficar vazia.
- **Linha incompleta:** quantidade preenchida e descrição vazia. Impede o "Continuar".
- **Texto colado com quebra de linha** na descrição vira uma linha só, com um espaço no lugar de cada quebra.

Mensagens:
- Nenhum ingrediente válido: "Adicione pelo menos um ingrediente." (abaixo da lista)
- Linha incompleta: "Descreva o ingrediente." (abaixo do campo de descrição da linha)
- Limite de linhas: "Você atingiu o limite de 50 ingredientes."
- Remoção: "Ingrediente removido", com a ação "Desfazer".

Persistência: `ingredientes` entra no `toJson`/`fromJson` do rascunho e é salvo pelo `RascunhoRepository` junto com os campos do Passo 1. Sem chamada de rede neste passo.

## 4. Critérios de aceitação

**Estado inicial**
- CA01. Na primeira vez que o usuário chega ao passo, aparecem "Ingredientes" destacado no indicador, a barra em 2/3, "Passo 2 de 3", o cabeçalho "Lista de Ingredientes" com o subtítulo e **uma linha vazia** com os placeholders "Qtd" e "Ex: Gramas de Manteiga...", sem lixeira.
- CA02. Se o rascunho já tem ingredientes, as linhas aparecem preenchidas na mesma ordem, seguidas de uma linha vazia.

**E9 — Voltar ("← Voltar" do rodapé ou voltar do sistema)**
- CA03. Ao tocar em voltar, aparece o Passo 1 com foto, título, categoria e história preenchidos como antes, sem diálogo de confirmação.
- CA04. Ao avançar de novo para o Passo 2, aparecem os mesmos ingredientes que estavam na tela antes de voltar, inclusive linhas incompletas.

**E1 — Fechar (X)**
- CA05. Ao tocar no X sem nenhuma alteração não salva no rascunho (em qualquer passo), o fluxo inteiro fecha e o usuário volta à tela de onde abriu "Nova Receita".
- CA06. Ao tocar no X com alterações não salvas, aparece o mesmo diálogo do Passo 1: "Descartar receita?", com "Salvar rascunho", "Descartar" e "Cancelar".
- CA07. "Salvar rascunho" mostra o aviso "Rascunho salvo" e fecha o fluxo; "Descartar" fecha o fluxo sem salvar; "Cancelar" fecha o diálogo e mantém a tela como estava.

**E5 / E6 — Campos da linha**
- CA08. Ao tocar em um campo, ele recebe foco (borda terracota) e o teclado abre.
- CA09. Ao digitar em qualquer campo da linha vazia, a lixeira aparece nessa linha e **uma nova linha vazia** surge logo abaixo. Ao apagar tudo o que digitou, a linha extra some. Sempre existe exatamente uma linha vazia no fim da lista (exceto no limite de 50).
- CA10. Ao confirmar no teclado ("próximo") o campo Qtd, o foco vai para a descrição da mesma linha; ao confirmar a descrição, o foco vai para o Qtd da linha seguinte.
- CA11. Ao digitar o 11º caractere em Qtd ou o 81º na descrição, nada é inserido.
- CA12. Uma descrição longa quebra em várias linhas e o campo cresce em altura; o campo Qtd da mesma linha fica alinhado ao topo. Uma descrição curta ocupa só uma linha.

**E7 — Remover**
- CA13. Ao tocar na lixeira, a linha some da lista e aparece o aviso "Ingrediente removido" com a ação "Desfazer".
- CA14. Ao tocar em "Desfazer", a linha volta para a mesma posição, com o mesmo conteúdo.

**E8 — Adicionar Ingrediente**
- CA15. Ao tocar em "Adicionar Ingrediente", o campo Qtd da linha vazia do fim da lista recebe foco, o teclado abre e a tela rola até ela. Nenhuma linha vazia extra é criada.
- CA16. Com 50 linhas preenchidas, não existe linha vazia, e tocar em "Adicionar Ingrediente" mostra o aviso "Você atingiu o limite de 50 ingredientes."

**E10 — Continuar**
- CA17. Ao tocar em "Continuar" com pelo menos um ingrediente válido e nenhuma linha incompleta, as linhas vazias são descartadas, a lista é gravada no rascunho (com espaços das pontas removidos) e aparece a tela do Passo 3 (Método) com "Método" destacado, a barra em 3/3 e "Passo 3 de 3".
- CA18. Ao tocar em "Continuar" sem nenhum ingrediente válido, aparece abaixo da lista a mensagem "Adicione pelo menos um ingrediente." e o campo de descrição da primeira linha recebe foco.
- CA19. Ao tocar em "Continuar" com linhas incompletas, cada uma fica com borda vermelha na descrição e a mensagem "Descreva o ingrediente.", e a tela rola até a primeira delas. A mensagem de uma linha some assim que o usuário digita na descrição dela.

**Indicador de progresso (E3)**
- CA20. Ao tocar no indicador, nada muda na tela (elemento não tocável).

**Avisos, limite e acessibilidade**
- CA21. O aviso "Ingrediente removido" aparece acima do rodapé; "Voltar" e "Continuar" continuam visíveis e tocáveis.
- CA22. Se, com o aviso de remoção ainda aberto, a lista for preenchida até 50 ingredientes, tocar em "Desfazer" mostra "Você atingiu o limite de 50 ingredientes." e o item removido não volta.
- CA23. Ao colar na descrição um texto com quebra de linha, o campo mostra o texto em uma linha só, com espaço no lugar da quebra.
- CA24. Com a fonte do sistema em 200% numa tela de 320 px de largura, a tela funciona sem nenhum texto estourando a tela.

## 5. Limite (fora do escopo)

- Tela do Passo 3 (Método); apenas a navegação até ela é coberta (tela provisória).
- Reordenar ingredientes (arrastar), agrupar em seções (ex.: "Massa", "Cobertura") e ingredientes opcionais.
- Unidade como campo separado, conversão de unidades, sugestões ou autocompletar de ingredientes.
- Escalar porções e lista de compras.
- Botão "Salvar Rascunho" nesta tela (salvar só pelo diálogo do X).
- Modo paisagem, tablet e tema escuro.
