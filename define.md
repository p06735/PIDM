# Define — App Social de Receitas

## 1. Persona

**A nossa persona:**

- **Contexto:** Marina, 29 anos, trabalha período integral e cozinha para si e pro companheiro de terça a domingo; usa o celular pra buscar receita direto no fogão, geralmente à noite depois do trabalho, com pouco tempo de planejamento
- **Objetivo:** decidir rápido o que cozinhar no dia e ter uma receita confiável pra seguir sem precisar testar e errar
- **Dores:** já perdeu receita salva no Instagram que sumiu do feed; segue pins do Pinterest que levam a blogs cheios de anúncio antes da receita aparecer; não sabe se quem postou a receita realmente testou ou só reproduziu de outro lugar

## 2. Problem statement

**Problem statement:**

Marina precisa de um lugar único para descobrir e seguir receitas confiáveis porque hoje esse conteúdo está espalhado entre Pinterest, YouTube, Instagram e blogs sem camada social nem curadoria de autoridade, mas hoje não há como diferenciar, dentro do mesmo app, uma receita validada por um chef verificado de uma postagem amadora sem histórico.

## 3. Escopo do MVP

**O escopo:**

**Must (essencial)**
- Feed personalizado com receitas de quem o usuário segue
- Criação de receita em passo a passo (ingredientes, método, tempo)
- Filtro/toggle em Explore para mostrar apenas chefs verificados
- Perfil com histórico de receitas publicadas pelo usuário
- Salvar/favoritar receita de outro usuário para acessar depois

**Should (importante)**
- Avaliação/comentários nas receitas
- Selo visual de chef verificado dentro do Feed

**Could (desejável)**
- Notificações de novo conteúdo de quem o usuário segue
- Lista de compras gerada automaticamente a partir da receita

## 4. User stories

**User stories:**

1. Como Marina, eu quero ver um feed com receitas de quem eu sigo para que eu descubra o que cozinhar sem precisar abrir outro app.
2. Como criadora de receita, eu quero publicar minha receita em passos com ingredientes e tempo para que quem for cozinhar não se perca no meio do preparo.
3. Como Marina buscando uma receita confiável antes de cozinhar, eu quero filtrar o Explore para mostrar só chefs verificados para que eu saiba que aquele conteúdo tem curadoria de autoridade.
4. Como Marina, eu quero acessar meu perfil e ver minhas receitas publicadas para que eu não perca o que já salvei ou criei.
5. Como Marina, eu quero salvar uma receita que encontrei no app para que eu não a perca como já perdi receitas salvas no Instagram.

Receitou vs. TudoGostoso

O que a Receitou resolve? 
Tudo Gostoso resolve “tenho um ingrediente, quero uma receita testada” — é busca e consumo, ponto final. Não tem grafo social, não tem perfil que você segue, não tem senso de quem cozinhou o quê. Nosso app resolve a pergunta que o Tudo Gostoso nunca fez: “de quem eu confio essa receita”.

O que funciona bem? 
Busca por ingrediente e categorização por tipo de prato são fortes e testadas há mais de uma década. O app permite buscar pratos de acordo com os ingredientes disponíveis, organizado em categorias como bolos, carnes, aves, peixes e frutos do mar.
O que é frustrante (no Tudo Gostoso)?

Reclamação recorrente e concentrada: excesso de anúncio dificultando a leitura da receita, e dificuldade de excluir conta ou dados. Usuários relatam que o site ficou quase impossível de ler devido ao excesso de propaganda, e outros relatam não conseguir excluir a conta ou fazer login por problemas de acesso ao e-mail cadastrado. Isso é sintoma de modelo de negócio ads-first brigando com experiência de uso — não é bug, é escolha estrutural deles.

Ideia de melhoria pro app: 
Não vendemos “sem anúncio” como diferencial — isso é commodity até você precisar monetizar, e aí você vai enfrentar a mesma tensão. O ponto de ataque real é: Tudo Gostoso não tem conceito de “autoria confiável no tempo” — é só receita isolada com nota. Perfil verificado realmente como filtro é uma coisa que estruturalmente o Tudo Gostoso não pode copiar sem reconstruir o produto inteiro, porque eles são publisher, não rede.

Receitou vs. Cookpad

O que meu app resolve? 
A separação estrutural Feed/Explore e o conceito de chef verificado como camada de autoridade — Cookpad trata todo mundo como “cozinheiro caseiro” igual, sem hierarquia de expertise.

O que funciona bem? 
Usuários descrevem o Cookpad como direto ao ponto: buscar por ingrediente ou receita, encontrar em formato claro e salvar. 

O que é frustrante (no Cookpad)?
Um usuário relata ficar olhando pra barra de busca sem saber o que pedir quando não tem uma ideia clara do prato, sugerindo que falta uma navegação por categoria/humor além de busca por ingrediente. Estrutural, mais grave: a função de importar receitas de redes sociais gerou reação negativa de criadores de conteúdo no Japão sobre respeito e atribuição de autoria — a empresa recebeu diversas opiniões sobre o impacto da funcionalidade nos criadores que publicam receitas, e chegou a renomear o recurso em resposta à polêmica. Isso é o problema clássico de UGC agregado: quando facilita demais “importar” conteúdo de terceiro, você desvaloriza quem cria original.

Ideia de melhoria pro app: 
Autoria e verificação são fatores diferenciais para quem posta receitas, protegendo sua origem, qualidade e originalidade.
