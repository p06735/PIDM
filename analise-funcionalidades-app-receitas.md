# Análise de Funcionalidades — App Social de Receitas

Baseado nas funcionalidades definidas: Feed, Search, Explore, Profile, Create (criação passo a passo), visualização social de receitas, perfis verificados de chef.

## O que resolve / para quem

As features sugerem um problema implícito: consumo de receitas hoje é fragmentado (Pinterest, YouTube, blogs, Instagram) e sem camada social nativa em torno de comida. O app tenta unificar descoberta + criação + prova social + curadoria de autoridade (chef verificado) em um lugar.

O usuário-alvo parece ser duplo: quem cozinha casualmente e busca inspiração (Feed/Explore) e quem cria conteúdo de receita, inclusive profissionais (Create + verificação).

**Ponto fraco:** o app tenta servir dois usuários com necessidades opostas — consumidor passivo e criador/chef — na mesma estrutura de navegação, sem que os requisitos definidos indiquem qual dos dois é prioridade. Um Instagram de receitas para amadores e uma plataforma de autoridade para chefs profissionais não têm as mesmas exigências de moderação, ranking ou verificação.

## O que funciona bem

- **Separação Feed x Explore**: decisão de arquitetura de informação correta. Distingue descoberta orientada por rede/algoritmo (Feed, quem eu sigo) de descoberta orientada por busca/categoria (Explore, o que existe). Evita a confusão comum em apps de receita que misturam as duas coisas, prejudicando quem ainda não segue ninguém.

- **Criação passo a passo**: é a decisão de UX mais alinhada ao domínio. Receita é sequencial por natureza (ingredientes → método → tempo), então o formato de criação espelha o formato de consumo. Reduz fricção cognitiva tanto de quem cria quanto de quem segue o passo a passo depois.

## O que é frustrante

**Perfis verificados de chef sem função definida no ranking.** A lista de funcionalidades não especifica como a verificação se reflete em Feed e Explore. Se um chef verificado e um usuário amador postam a mesma receita e o app trata os dois de forma idêntica, a verificação vira um selo decorativo sem função real — a feature existe, mas não faz nada. Se não é tratada de forma idêntica, falta uma regra de priorização que ainda não foi definida.

## Ideia de melhoria concreta

Definir a verificação como um **filtro/modo explícito**, não como selo passivo: dar ao usuário um toggle em Explore (ex: "Mostrar apenas chefs verificados") ou um separador visual claro entre conteúdo de rede social e conteúdo de autoridade curada.

Isso resolve o problema dos dois públicos com uma única navegação — em vez de forçar um Feed misto a servir tanto o usuário casual quanto quem busca autoridade profissional, a distinção fica visível e acionável pelo próprio usuário, sem exigir um algoritmo de ranking complexo por trás.
