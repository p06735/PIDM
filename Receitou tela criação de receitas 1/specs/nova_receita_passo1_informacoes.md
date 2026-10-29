# Spec — Nova Receita · Passo 1: Informações Básicas

## 1. Captura

Referência visual: `specs/img/nova_receita_passo1.png` (captura fornecida, 224×640, retrato).

Primeira tela do fluxo de criação de receita em 3 passos (**Informações → Ingredientes → Método**). O usuário chega aqui a partir da ação "Nova Receita" e define foto de capa, título, categoria e história da receita.

Estilo observado:
- Fundo creme claro; cartões/campos com borda bege e cantos arredondados (~8px).
- Cor de destaque terracota (barra de progresso, chip selecionado, botão "Continuar", rótulo do passo ativo).
- Títulos em fonte serifada ("Nova Receita", "Informações Básicas"); demais textos em sans-serif.

## 2. Elementos

Ordem de cima para baixo. **[T]** = tocável.

| # | Elemento | Descrição |
|---|---|---|
| E1 | **[T]** Botão fechar (X) | Ícone no canto superior esquerdo da AppBar. |
| E2 | Título da AppBar | "Nova Receita", serifado, centralizado. |
| E3 | Indicador de progresso | Rótulos "Informações" (ativo, terracota, negrito), "Ingredientes", "Método" (cinza); barra preenchida em 1/3; legenda "Passo 1 de 3". Não tocável. |
| E4 | Cabeçalho da seção | "Informações Básicas" (serifado, grande) + subtítulo "Comece dando um rosto e um nome para a sua criação culinária." |
| E5 | **[T]** Área de foto de capa | Caixa tracejada (proporção ~4:3) com ícone de câmera+, texto "Adicionar Foto de Capa" e "Formatos recomendados: JPG, PNG (Paisagem)". Com foto: exibe a imagem preenchendo a área e um botão **[T]** remover (X) no canto. |
| E6 | **[T]** Campo "Título da Receita" | Rótulo acima; placeholder "Ex: Risoto de Cogumelos Selvagens"; uma linha. |
| E7 | **[T]** Chips "Categoria Principal" | Seleção única, em linhas com quebra: Prato Principal, Sobremesa, Aperitivo, Café da Manhã, Bebidas. Selecionado = fundo terracota e texto branco; demais = fundo bege e texto escuro. |
| E8 | **[T]** Campo "História ou Descrição" | Multilinha (~4 linhas visíveis); placeholder "O que torna esta receita especial? Conte a inspiração por trás dela..."; contador "n/500" abaixo à direita. |
| E9 | **[T]** Botão "Salvar Rascunho" | Botão de texto, rodapé fixo à esquerda. |
| E10 | **[T]** Botão "Continuar →" | Botão preenchido terracota, em pílula, rodapé fixo à direita. |

Comportamento de layout: o conteúdo (E3–E8) rola; AppBar (E1–E2) e rodapé (E9–E10) ficam fixos. Com o teclado aberto, o rodapé sobe acima do teclado e o campo focado continua visível.

## 3. Dados

Modelo `ReceitaRascunho` (compartilhado pelos 3 passos; este passo preenche apenas os campos abaixo):

| Campo | Tipo | Obrigatório p/ Continuar | Limite / regra | Padrão |
|---|---|---|---|---|
| `id` | `String?` | — | Gerado no 1º salvamento de rascunho | `null` |
| `fotoCapa` | `File?` / caminho local | Não | JPG ou PNG; máx. 10 MB | `null` |
| `titulo` | `String` | **Sim** | 3–60 caracteres após `trim()` | `""` |
| `categoria` | `enum Categoria { pratoPrincipal, sobremesa, aperitivo, cafeDaManha, bebidas }` | **Sim** | Exatamente uma | `pratoPrincipal` |
| `historia` | `String` | Não | máx. 500 caracteres (entrada bloqueada no limite) | `""` |
| `atualizadoEm` | `DateTime` | — | Atualizado a cada salvamento | — |

Mensagens de validação:
- Título vazio: "Dê um nome à sua receita."
- Título com 1–2 caracteres: "O título precisa ter pelo menos 3 caracteres."
- Arquivo inválido: "Use uma imagem JPG ou PNG de até 10 MB."

Persistência: rascunho salvo localmente (armazenamento do dispositivo). Sem chamada de rede neste passo.

## 4. Critérios de aceitação

**Estado inicial**
- CA01. Ao abrir a tela, aparecem o passo "Informações" destacado, a barra em 1/3, "Passo 1 de 3", a área de foto vazia, os campos vazios com placeholders e o chip "Prato Principal" selecionado.

**E1 — Fechar (X)**
- CA02. Ao tocar no X sem nenhuma alteração, a tela fecha e o usuário volta à tela anterior.
- CA03. Ao tocar no X com alterações não salvas, aparece o diálogo "Descartar receita?" com as opções "Salvar rascunho", "Descartar" e "Cancelar".
- CA04. Ao tocar em "Descartar" no diálogo, a tela fecha e as alterações são perdidas.
- CA05. Ao tocar em "Salvar rascunho" no diálogo, aparece o aviso "Rascunho salvo" e a tela fecha.
- CA06. Ao tocar em "Cancelar" no diálogo, o diálogo some e a tela permanece com os dados preenchidos.

**E5 — Foto de capa**
- CA07. Ao tocar na área de foto, aparece uma folha inferior com as opções "Tirar foto" e "Escolher da galeria".
- CA08. Ao escolher uma imagem JPG/PNG válida, a imagem aparece preenchendo a área de foto, com o botão de remover no canto.
- CA09. Ao escolher um arquivo inválido (formato ou tamanho), aparece o aviso "Use uma imagem JPG ou PNG de até 10 MB." e a área continua como estava.
- CA10. Ao tocar na área com foto já escolhida, aparece a mesma folha inferior para trocar a imagem.
- CA11. Ao tocar no botão remover da foto, a área volta ao estado vazio com ícone e textos originais.

**E6 — Título**
- CA12. Ao tocar no campo de título, o campo recebe foco (borda terracota), o teclado abre e o placeholder continua visível até a digitação.
- CA13. Ao digitar o 61º caractere, nada é inserido e o texto fica em 60 caracteres.

**E7 — Categoria**
- CA14. Ao tocar em um chip não selecionado, ele fica terracota com texto branco e o chip anterior volta ao estilo bege.
- CA15. Ao tocar no chip já selecionado, ele continua selecionado (nunca fica sem categoria).

**E8 — História**
- CA16. Ao tocar no campo de história, o campo recebe foco, o teclado abre e o campo rola para ficar visível acima do rodapé.
- CA17. Ao digitar no campo, o contador abaixo mostra "n/500" atualizado; ao atingir 500, nenhum caractere a mais é inserido.

**E9 — Salvar Rascunho**
- CA18. Ao tocar em "Salvar Rascunho", aparece o aviso "Rascunho salvo" e a tela permanece aberta com os dados preenchidos (vale mesmo com título vazio).

**E10 — Continuar**
- CA19. Ao tocar em "Continuar" com título válido, aparece a tela do Passo 2 (Ingredientes) com "Ingredientes" destacado, a barra em 2/3 e "Passo 2 de 3".
- CA20. Ao tocar em "Continuar" com título vazio ou inválido, o campo de título fica com borda vermelha e a mensagem de erro correspondente aparece abaixo dele, e a tela rola até o campo.
- CA21. Ao voltar do Passo 2 para este passo, aparecem os mesmos foto, título, categoria e história preenchidos anteriormente.

**Indicador de progresso (E3)**
- CA22. Ao tocar nos rótulos do indicador, nada muda na tela (elemento não tocável).

## 5. Limite (fora do escopo)

- Telas dos Passos 2 (Ingredientes) e 3 (Método) — apenas a navegação até o Passo 2 é coberta.
- Recorte/edição de imagem, upload para servidor e sincronização em nuvem.
- Lista de rascunhos e retomada de rascunho a partir de outra tela.
- Categorias personalizadas ou múltiplas categorias.
- Modo paisagem, tablet e tema escuro.
