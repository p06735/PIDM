# Spec — Perfil

## 1. Captura

Referência visual: `specs/img/perfil_figma.png` (print do Figma, 183×843, retrato).

Tela de perfil do usuário logado. É a **tela inicial do app** nesta entrega (a aba "Perfil" da barra inferior fica ativa). Daqui o usuário vê suas receitas publicadas e salvas e abre o fluxo "Nova Receita".

Estilo:
- Fundo creme claro; cartões brancos com cantos arredondados (~12px) e sombra leve.
- Cor de destaque terracota (botão "Editar Perfil", aba ativa, botão "+" de "Criar Receita", item ativo da barra inferior, coração).
- Nome "Você", título da AppBar e títulos das receitas em fonte serifada; demais textos em sans-serif.
- Etiquetas das receitas: verde-claro (categoria) e bege (dificuldade).

## 2. Elementos

Ordem de cima para baixo. **[T]** = tocável.

| # | Elemento | Descrição |
|---|---|---|
| E1 | **[T]** Menu (☰) | Canto superior esquerdo da AppBar. |
| E2 | Título da AppBar | "Receitou", serifado, centralizado. |
| E3 | **[T]** Notificações (sino) | Canto superior direito da AppBar. |
| E4 | Foto de perfil | Círculo (~96px) com borda clara. |
| E5 | Nome e bio | "Você" (serifado, negrito) e a bio "Explorando novos sabores na cozinha. Amante de massas e pães artesanais. 🍝🥖", centralizados. |
| E6 | Estatísticas | Três colunas: **Postagens**, **Seguidores** (245), **Seguindo** (180), número em negrito acima do rótulo em caixa alta. |
| E7 | **[T]** Botão "Editar Perfil" | Pílula preenchida terracota com ícone de lápis. |
| E8 | **[T]** Botão "Compartilhar" | Pílula com contorno terracota e ícone de compartilhar. |
| E9 | **[T]** Abas "Minhas Receitas" / "Salvas" | Aba ativa em terracota, negrito e sublinhada. |
| E10 | **[T]** Cartão "Criar Receita" | Só na aba "Minhas Receitas", primeiro item. Fundo bege com borda tracejada, círculo terracota com "+", título "Criar Receita" (terracota) e "Compartilhe sua próxima criação culinária". |
| E11 | **[T]** Cartão de receita | Foto (proporção ~3:2), **[T]** coração no canto superior direito, etiquetas (categoria e, se houver, dificuldade), título serifado, tempo (ícone de relógio) à esquerda e curtidas (ícone de coração) à direita. |
| E12 | **[T]** Barra inferior | Feed, Pesquisar, Criar, Explorar e Perfil (ativo: círculo terracota com ícone e texto brancos). |

Layout: AppBar fixa no topo, barra inferior fixa embaixo, o resto rola.

## 3. Dados

Modelo de exibição `ReceitaResumo` (lido pelo `ReceitaRepository`):

| Campo | Tipo | Regra |
|---|---|---|
| `id` | `String` | Único. |
| `titulo` | `String` | Do Passo 1. |
| `categoria` | `String` | Rótulo da categoria (ex.: "Prato Principal", "Pães"). |
| `dificuldade` | `String?` | Só nas receitas de exemplo. |
| `tempo` | `String?` | Ex.: "24h", "1h 30m". Só nas receitas de exemplo; receita nova não mostra tempo. |
| `curtidas` | `int` | Receita nova começa com 0. Exibição: 1200 → "1.2k". |
| `foto` | `String?` | Caminho da foto de capa ou asset de exemplo; sem foto, mostra ilustração padrão (fundo bege com ícone de prato). |
| `salva` | `bool` | Coração cheio = salva. |

Dados fixos do perfil: nome "Você", bio do item E5, Seguidores 245, Seguindo 180.
**Postagens** = 10 (base) + número de receitas em "Minhas Receitas" (com as 2 de exemplo, aparece **12**, como no Figma).

Receitas de exemplo (sempre presentes, abaixo das publicadas): "Pão de Fermentação Natural Básico" (Pães, Demorado, 24h, 1.2k, salva) e "Tagliatelle Artesanal com Pomodoro" (Massas, Médio, 1h 30m, 850). As receitas publicadas pelo fluxo aparecem **acima** delas, da mais nova para a mais antiga.

Persistência: publicadas e estado "salva" ficam em `shared_preferences`; ao reabrir o app, continuam lá.

## 4. Navegação (botões que mudam de tela)

| Botão | Tela que abre | O que ela mostra |
|---|---|---|
| E10 "Criar Receita" | **Nova Receita — Passo 1 (Informações Básicas)** | Formulário vazio: foto de capa, título, categoria (Prato Principal selecionada) e história; indicador "Passo 1 de 3". |
| E12 "Criar" | **Nova Receita — Passo 1** | O mesmo que E10. |
| Fluxo Nova Receita fechado pelo X | **Perfil** | Sem receita nova (e com aviso "Rascunho salvo" se o usuário salvou). |
| Fluxo concluído com "Publicar" | **Perfil**, aba "Minhas Receitas" | Receita nova no topo, Postagens +1, aviso "Receita publicada!". |
| E9 "Salvas" | Mesma tela, aba "Salvas" | Só as receitas com coração cheio, sem o cartão "Criar Receita". Sem nenhuma: "Nenhuma receita salva ainda. Toque no ♥ de uma receita para guardá-la aqui." |
| E9 "Minhas Receitas" | Mesma tela, aba "Minhas Receitas" | Cartão "Criar Receita" seguido das receitas do usuário. |
| E1, E3, E7, E8, E11 (toque no cartão), E12 Feed/Pesquisar/Explorar | Fica no Perfil | Aviso "Em breve" (telas fora do escopo). |
| E12 "Perfil" | Fica no Perfil | Rola para o topo. |

## 5. Critérios de aceitação

- CA01. Ao abrir o app, aparece o Perfil com foto, "Você", bio, Postagens 12, Seguidores 245, Seguindo 180, os dois botões, a aba "Minhas Receitas" ativa, o cartão "Criar Receita" e as duas receitas de exemplo; "Perfil" ativo na barra inferior.
- CA02. Tocar em "Criar Receita" (ou "Criar" na barra) abre o Passo 1 vazio.
- CA03. Depois de publicar, o Perfil mostra a nova receita no topo de "Minhas Receitas", com a foto de capa (ou a ilustração padrão), a etiqueta da categoria, o título e 0 curtidas, Postagens 13 e o aviso "Receita publicada!".
- CA04. Fechar o fluxo pelo X (descartando) volta ao Perfil sem receita nova e com Postagens inalterado.
- CA05. Tocar em "Salvas" mostra só as receitas com coração cheio; tocar no coração de uma receita a adiciona ou remove de "Salvas" na hora.
- CA06. Botões fora do escopo mostram "Em breve" e não mudam de tela.
- CA07. Tocar duas vezes rápido em "Criar Receita" abre **um** Passo 1 só (voltar pelo X leva direto ao Perfil).
- CA08. Fechar e reabrir o app mantém as receitas publicadas e o estado "salva".
- CA09. Com a fonte do sistema em 200% numa tela de 320 px, nada estoura a tela.

## 6. Limite (fora do escopo)

- Telas Feed, Pesquisar, Explorar, notificações, menu, editar perfil e compartilhamento.
- Detalhe da receita (toque no cartão), editar ou apagar receita publicada.
- Login, contas reais e contagem real de seguidores/curtidas.
- Modo paisagem, tablet e tema escuro.
