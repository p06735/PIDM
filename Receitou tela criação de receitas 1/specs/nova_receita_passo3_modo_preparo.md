# Spec — Nova Receita · Passo 3: Modo de Preparo

## 1. Captura

Referência visual: `specs/img/nova_receita_passo3_figma.png` (print do Figma, 287×778, retrato).

Última tela do fluxo de criação de receita em 3 passos (**Informações → Ingredientes → Método**). O usuário chega aqui ao tocar em "Continuar" no Passo 2 com pelo menos um ingrediente válido. Aqui ele descreve o preparo em passos numerados, cada um com texto e fotos opcionais, e publica a receita.

**Padronização com os Passos 1 e 2.** O print mostra o indicador em 3 barras segmentadas e o título "Nova Receita" pequeno e terracota. Seguindo a decisão do Passo 2, esta tela usa os componentes compartilhados do fluxo: AppBar só com o X e título centralizado, o mesmo indicador de 3 rótulos com "Passo 3 de 3", o mesmo cabeçalho serifado e o mesmo rodapé. O print vale para o conteúdo e a disposição dos cartões de passo e para o botão "Publicar".

Estilo:
- Fundo creme claro; cartões de passo brancos com cantos arredondados (~12px) e sombra leve.
- Selo do número do passo: círculo verde-claro com o número em verde-oliva; rótulo "PASSO" em verde-oliva, caixa alta, espaçado.
- Campo de texto com fundo bege e cantos arredondados; área de mídia com borda tracejada rosada.
- Botão "Publicar" terracota com ícone de check.

## 2. Elementos

Ordem de cima para baixo. **[T]** = tocável.

| # | Elemento | Descrição |
|---|---|---|
| E1 | **[T]** Botão fechar (X) | Ícone no canto superior esquerdo da AppBar. |
| E2 | Título da AppBar | "Nova Receita", serifado, centralizado. |
| E3 | Indicador de progresso | Rótulos "Informações", "Ingredientes", "Método" (ativo, terracota, negrito); barra cheia (3/3); legenda "Passo 3 de 3". Não tocável. |
| E4 | Cabeçalho | "Modo de Preparo" (serifado, grande) + subtítulo "Explique passo a passo como preparar sua obra-prima." |
| E5 | Cartão de passo | Um por passo, na ordem. Contém E6–E9. |
| E6 | Selo + rótulo | Círculo com o número do passo (1, 2, 3…) e o texto "PASSO". |
| E7 | **[T]** Botão remover (lixeira) | Canto superior direito do cartão. Não aparece quando existe só um cartão. |
| E8 | **[T]** Campo de descrição | Multilinha (mín. 3 linhas visíveis, cresce até 8); placeholder "Descreva as ações necessárias para este passo..."; contador "n/1000" só a partir de 900 caracteres. |
| E9 | **[T]** Área de mídia | **Sem mídia:** botão tracejado na largura do cartão com ícone de câmera+ e "Adicionar foto ou vídeo". **Com mídia:** miniaturas quadradas (~70px) lado a lado, cada uma com um **[T]** X para remover; vídeos mostram um ícone de play sobre fundo escuro; depois delas, um quadrado tracejado **[T]** "Mais fotos" (some ao chegar a 5 mídias). |
| E10 | **[T]** Botão "+ Adicionar passo" | Pílula com contorno terracota, na largura do conteúdo, abaixo do último cartão. |
| E11 | **[T]** Botão "Voltar" | Botão de texto, rodapé fixo à esquerda. |
| E12 | **[T]** Botão "Publicar ✓" | Botão preenchido terracota, em pílula, rodapé fixo à direita. Enquanto publica, mostra um indicador de carregamento no lugar do texto e fica desativado. |

Layout: AppBar e indicador fixos no topo, rodapé fixo embaixo, conteúdo (E4–E10) rola entre eles. Com o teclado aberto, o rodapé sobe e o campo focado continua visível. Avisos (SnackBar) aparecem acima do rodapé.

## 3. Dados

Novo modelo `PassoPreparo`:

| Campo | Tipo | Obrigatório | Limite / regra | Padrão |
|---|---|---|---|---|
| `descricao` | `String` | Sim, se o passo tiver mídia | máx. 1000 caracteres (entrada bloqueada no limite) | `""` |
| `midias` | `List<Midia>` (`caminho` + `video`) | Não | máx. 5 por passo; fotos JPG/PNG/WEBP ou vídeos MP4/MOV (formato decidido pelo nome do arquivo) | `[]` |

Campos novos em `ReceitaRascunho`:

| Campo | Tipo | Regra | Padrão |
|---|---|---|---|
| `passos` | `List<PassoPreparo>` | Para publicar: pelo menos 1 passo com descrição; máx. 30 | `[]` |

Regras de cartão (após `trim()`):
- **Vazio:** sem descrição e sem mídia. É ignorado ao publicar.
- **Válido:** com descrição (mídia opcional).
- **Incompleto:** com mídia e sem descrição. Impede publicar.

Mensagens:
- Nenhum passo válido: "Descreva pelo menos um passo." (abaixo do primeiro cartão, e o campo dele recebe foco)
- Cartão incompleto: "Descreva este passo." (abaixo do campo do cartão)
- Limite de passos: "Você atingiu o limite de 30 passos."
- Limite de mídias: "Cada passo pode ter até 5 fotos ou vídeos."
- Formato inválido: "Use fotos JPG, PNG ou WEBP, ou vídeos MP4 ou MOV."
- Remoção: "Passo removido", com a ação "Desfazer".
- Sucesso: "Receita publicada!" (mostrado na tela de Perfil)

Persistência: ao publicar, a receita (com `passos`) é gravada pelo `ReceitaRepository` na lista de receitas publicadas (local, `shared_preferences`); se a receita tinha um rascunho salvo, ele é apagado. Sem chamada de rede.

## 4. Navegação (botões que mudam de tela)

| Botão | Tela que abre | O que ela mostra |
|---|---|---|
| E1 X (sem alterações não salvas) | **Perfil** (tela de onde o fluxo foi aberto) | Perfil sem mudanças. |
| E1 X (com alterações) | Diálogo "Descartar receita?" | "Salvar rascunho" (aviso "Rascunho salvo" e volta ao Perfil), "Descartar" (volta ao Perfil sem salvar) ou "Cancelar" (fica no Passo 3). |
| E11 Voltar / voltar do sistema | **Passo 2 — Ingredientes** | A lista de ingredientes como estava. Os passos digitados no Passo 3 ficam guardados e reaparecem ao avançar de novo. |
| E12 Publicar (válido) | **Perfil**, aba "Minhas Receitas" | A nova receita no topo da lista (foto de capa ou ilustração padrão, etiqueta da categoria, título, curtidas 0), o contador "Postagens" com +1 e o aviso "Receita publicada!". |
| E12 Publicar (inválido) | Fica no Passo 3 | Mensagens de erro da seção 3. |

## 5. Critérios de aceitação

**Estado inicial**
- CA01. Na primeira vez no passo, aparecem "Método" destacado, barra cheia, "Passo 3 de 3", o cabeçalho "Modo de Preparo" com o subtítulo e **um cartão** "1 PASSO" vazio, com o placeholder e o botão "Adicionar foto ou vídeo", sem lixeira.
- CA02. Se o rascunho já tem passos (voltou e avançou de novo), os cartões aparecem com o mesmo texto e mídias, na mesma ordem.

**E10 — Adicionar passo**
- CA03. Ao tocar em "Adicionar passo", aparece um novo cartão vazio no fim com o número seguinte, a tela rola até ele e o campo recebe foco. A lixeira passa a aparecer em todos os cartões.
- CA04. Com 30 cartões, tocar em "Adicionar passo" mostra "Você atingiu o limite de 30 passos." e nenhum cartão é criado.

**E7 — Remover**
- CA05. Ao tocar na lixeira, o cartão some, os seguintes são renumerados e aparece "Passo removido" com "Desfazer".
- CA06. "Desfazer" devolve o cartão à mesma posição com o mesmo texto e mídias, e a numeração se ajusta.

**E8 — Descrição**
- CA07. Ao tocar no campo, ele recebe foco (borda terracota) e o teclado abre. Enter insere quebra de linha.
- CA08. O 1001º caractere não é inserido.

**E9 — Mídia**
- CA09. Ao tocar em "Adicionar foto ou vídeo" (ou "Mais fotos"), abre a seleção de mídia do sistema (várias de uma vez). As escolhidas aparecem como miniaturas e o botão vira o quadrado "Mais fotos".
- CA10. Ao passar de 5 mídias no cartão, só as primeiras até completar 5 entram e aparece "Cada passo pode ter até 5 fotos ou vídeos.". Com 5, o quadrado "Mais fotos" some.
- CA11. Ao tocar no X de uma miniatura, ela some; sem nenhuma, volta o botão "Adicionar foto ou vídeo".
- CA12. Arquivo de formato não aceito é ignorado com o aviso de formato.

**E12 — Publicar**
- CA13. Com pelo menos um passo válido e nenhum incompleto: cartões vazios são descartados, a receita é publicada e abre o **Perfil** com a receita no topo de "Minhas Receitas", "Postagens" +1 e o aviso "Receita publicada!".
- CA14. Sem passo válido: aparece "Descreva pelo menos um passo." e o campo do primeiro cartão recebe foco. Nada é publicado.
- CA15. Com cartão incompleto: ele mostra "Descreva este passo." com borda vermelha e a tela rola até ele. A mensagem some ao digitar no campo.
- CA16. **Toque duplo rápido** em "Publicar" publica **uma única** receita (o botão fica desativado com carregamento após o primeiro toque).

**E11 — Voltar**
- CA17. "Voltar" abre o Passo 2 com os ingredientes como estavam, sem diálogo. Ao avançar de novo, o Passo 3 mostra os mesmos passos com texto ou mídia (inclusive incompletos), na mesma ordem. Cartões totalmente vazios não são guardados, para não contar como alteração não salva.
- CA18. Se o usuário voltar ao Passo 1, mudar o título e avançar até publicar, o Perfil mostra o **título novo**.

**E1 — Fechar**
- CA19. X segue o mesmo diálogo dos Passos 1 e 2; ao fechar, o fluxo inteiro some e aparece o Perfil sem a receita.

**Outros**
- CA20. Tocar no indicador não faz nada.
- CA21. Com a fonte do sistema em 200% numa tela de 320 px, nada estoura a tela.

## 6. Limite (fora do escopo)

- Reordenar passos (arrastar), tempo/temporizador por passo, ingredientes vinculados ao passo.
- Editar ou recortar fotos; reproduzir vídeos (só miniatura com ícone de play).
- Upload para servidor, moderação e visibilidade (pública/privada).
- Pré-visualização da receita antes de publicar.
- Modo paisagem, tablet e tema escuro.
