// ============================================================
// Sabor — Protótipo (arquivo único para DartPad)
// Convertido a partir de um design React (Claude Design) embutido em um
// HTML "standalone". Cole este código em https://dartpad.dev
// (selecione o modo "Flutter" no topo antes de rodar).
//
// Fidelidade ao design original:
// - Paleta de cores: convertida com a fórmula real OKLCH -> sRGB
//   (o design usa oklch(L% C H) para praticamente toda cor de destaque).
// - Fontes: o design usa "Caprasimo" (títulos) e "Figtree" (corpo), fontes
//   customizadas via @font-face. DartPad não carrega fontes externas sem
//   o pacote google_fonts, então aqui uso a fonte padrão do sistema com
//   peso maior para aproximar os títulos.
// - Fotos/vídeos: o design original usa placeholders com um rótulo
//   monoespaçado (ex: "foto: risoto") em vez de imagens reais — mantive
//   esse mesmo comportamento aqui (nenhuma URL de imagem é chamada).
// - Sem backend: like/salvar/seguir/criar ficam em memória (setState).
// ============================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const SaborApp());
}

// ─────────────────────────────────────────────────────────────
// Conversão OKLCH -> Color (fórmula de Björn Ottosson / css-color-4)
// l: 0..1   c: chroma (geralmente 0..0.4)   h: matiz em graus
// ─────────────────────────────────────────────────────────────
Color oklch(double l, double c, double h) {
  final hRad = h * math.pi / 180;
  final a = c * math.cos(hRad);
  final b = c * math.sin(hRad);

  final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
  final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
  final s_ = l - 0.0894841775 * a - 1.2914855480 * b;

  final ll = l_ * l_ * l_;
  final mm = m_ * m_ * m_;
  final ss = s_ * s_ * s_;

  final r = 4.0767416621 * ll - 3.3077115913 * mm + 0.2309699292 * ss;
  final g = -1.2684380046 * ll + 2.6097574011 * mm - 0.3413193965 * ss;
  final bch = -0.0041960863 * ll - 0.7034186147 * mm + 1.7076147010 * ss;

  double gamma(double x) {
    x = x.clamp(0.0, 1.0);
    return x <= 0.0031308 ? x * 12.92 : 1.055 * math.pow(x, 1 / 2.4) - 0.055;
  }

  final rr = (gamma(r) * 255).round().clamp(0, 255);
  final gg = (gamma(g) * 255).round().clamp(0, 255);
  final bb = (gamma(bch) * 255).round().clamp(0, 255);
  return Color.fromARGB(255, rr, gg, bb);
}

// ─────────────────────────────────────────────────────────────
// Tokens de design (valores hex reais do :root do CSS original)
// ─────────────────────────────────────────────────────────────
const Color kBg = Color(0xFFF5EAD8);
const Color kSurface = Color(0xFFEBDDC5);
const Color kText = Color(0xFF201E1D);
const Color kAccent = Color(0xFFC67139);
const Color kAccent600 = Color(0xFFB2622D);
const Color kAccent2 = Color(0xFF7A8A5E);
const Color kDivider = Color(0x29201E1D); // ~16% opacity
const Color kMuted = Color(0x8C201E1D); // ~55% opacity
const Color kVerifiedBlue = Color(0xFF2F7FD6);

// ─────────────────────────────────────────────────────────────
// Modelos de dados
// ─────────────────────────────────────────────────────────────
class ChefM {
  final String id, name, specialty, followers, bio, rating;
  final bool verified;
  final Color avatarColor;
  ChefM({
    required this.id,
    required this.name,
    this.verified = false,
    required this.avatarColor,
    this.specialty = '',
    this.followers = '',
    this.bio = '',
    this.rating = '',
  });
}

class StepM {
  final String desc, mediaLabel;
  final Color color;
  StepM(this.desc, this.color, this.mediaLabel);
}

class CommentM {
  final String name, text;
  final Color avatarColor;
  CommentM(this.name, this.text, this.avatarColor);
}

class RecipeM {
  final String id, title, chefId, imgLabel, category, time, difficulty, servings, stars;
  final Color color;
  final bool trending;
  final int likes, commentsCount;
  final List<String> ingredients;
  final List<StepM> steps;
  final List<CommentM> comments;
  RecipeM({
    required this.id,
    required this.title,
    required this.chefId,
    required this.color,
    required this.imgLabel,
    required this.category,
    required this.time,
    required this.difficulty,
    required this.servings,
    required this.stars,
    required this.trending,
    required this.likes,
    required this.commentsCount,
    required this.ingredients,
    required this.steps,
    required this.comments,
  });
}

class CollectionM {
  final String title;
  final int count;
  final Color color;
  CollectionM(this.title, this.count, this.color);
}

// ─────────────────────────────────────────────────────────────
// Dados mockados (traduzidos 1:1 do design original)
// ─────────────────────────────────────────────────────────────
final List<String> categories = ['Massas', 'Vegana', 'Doces', 'Saladas', 'Carnes', 'Sopas'];

final Map<String, Color> catColors = {
  'Massas': oklch(0.72, .07, 40),
  'Vegana': oklch(0.76, .1, 130),
  'Doces': oklch(0.70, .1, 60),
  'Saladas': oklch(0.78, .08, 130),
  'Carnes': oklch(0.58, .1, 30),
  'Sopas': oklch(0.66, .07, 90),
};

final List<ChefM> chefs = [
  ChefM(id: 'c1', name: 'Marina Rossi', verified: true, avatarColor: oklch(0.58, .12, 30), specialty: 'Cozinha italiana', followers: '48.2k', bio: 'Chef executiva há 15 anos, especialista em massas artesanais.', rating: '4.9'),
  ChefM(id: 'c2', name: 'Diego Alves', verified: true, avatarColor: oklch(0.55, .1, 140), specialty: 'Culinária vegana', followers: '31.6k', bio: 'Cozinha baseada em plantas, sabor sem culpa.', rating: '4.8'),
  ChefM(id: 'c3', name: 'Helena Cruz', verified: true, avatarColor: oklch(0.56, .12, 260), specialty: 'Confeitaria', followers: '62.9k', bio: 'Doces de autor e técnicas de confeitaria francesa.', rating: '5.0'),
  ChefM(id: 'c4', name: 'Tomás Ferreira', verified: true, avatarColor: oklch(0.54, .11, 90), specialty: 'Churrasco & carnes', followers: '27.3k', bio: 'Do fogo de chão à alta gastronomia com carnes.', rating: '4.7'),
  ChefM(id: 'u1', name: 'Ana Souza', verified: false, avatarColor: oklch(0.60, .08, 200)),
  ChefM(id: 'me', name: 'Você', verified: false, avatarColor: oklch(0.62, .1, 50)),
];

final List<RecipeM> recipes = [
  RecipeM(
    id: 'r1', title: 'Risoto de cogumelos silvestres', chefId: 'c1',
    color: oklch(0.72, .07, 40), imgLabel: 'foto: risoto', category: 'Massas',
    time: '35 min', difficulty: 'Médio', servings: '2 porções', stars: '★ 4.9',
    trending: true, likes: 842, commentsCount: 56,
    ingredients: ['320g de arroz arbóreo', '1L de caldo de legumes', '200g de cogumelos mistos', '1 cebola picada', '80g de parmesão ralado', 'Vinho branco a gosto'],
    steps: [
      StepM('Refogue a cebola até dourar levemente.', oklch(0.75, .05, 40), 'foto: passo 1'),
      StepM('Adicione o arroz e deixe nacarar por 2 minutos.', oklch(0.73, .06, 40), 'foto: passo 2'),
      StepM('Acrescente o caldo pouco a pouco, mexendo sempre.', oklch(0.71, .06, 40), 'vídeo: passo 3'),
      StepM('Finalize com cogumelos salteados e parmesão.', oklch(0.69, .06, 40), 'foto: passo 4'),
    ],
    comments: [
      CommentM('Julia P.', 'Ficou incrível, super cremoso!', oklch(0.70, .08, 20)),
      CommentM('Renato M.', 'Substituí por cogumelos portobello e funcionou bem.', oklch(0.65, .08, 200)),
    ],
  ),
  RecipeM(
    id: 'r2', title: 'Bowl vegano de quinoa e legumes', chefId: 'c2',
    color: oklch(0.76, .1, 130), imgLabel: 'foto: bowl vegano', category: 'Vegana',
    time: '25 min', difficulty: 'Fácil', servings: '1 porção', stars: '★ 4.7',
    trending: true, likes: 611, commentsCount: 34,
    ingredients: ['1 xícara de quinoa cozida', '1/2 abobrinha em fatias', '1 cenoura ralada', '1/2 abacate', 'Grão-de-bico assado', 'Molho de tahine'],
    steps: [
      StepM('Cozinhe a quinoa e reserve.', oklch(0.78, .08, 130), 'foto: passo 1'),
      StepM('Grelhe a abobrinha até dourar.', oklch(0.76, .09, 130), 'vídeo: passo 2'),
      StepM('Monte o bowl com todos os ingredientes.', oklch(0.74, .09, 130), 'foto: passo 3'),
    ],
    comments: [
      CommentM('Bia F.', 'Leve e saboroso, virou rotina aqui.', oklch(0.70, .08, 20)),
    ],
  ),
  RecipeM(
    id: 'r3', title: 'Tarte tatin de maçã', chefId: 'c3',
    color: oklch(0.70, .1, 60), imgLabel: 'foto: tarte tatin', category: 'Doces',
    time: '55 min', difficulty: 'Médio', servings: '6 porções', stars: '★ 5.0',
    trending: true, likes: 1204, commentsCount: 98,
    ingredients: ['6 maçãs médias', '150g de açúcar', '80g de manteiga', '1 disco de massa folhada', 'Canela a gosto'],
    steps: [
      StepM('Caramelize o açúcar com a manteiga na frigideira.', oklch(0.72, .08, 60), 'foto: passo 1'),
      StepM('Disponha as maçãs cortadas sobre o caramelo.', oklch(0.70, .09, 60), 'vídeo: passo 2'),
      StepM('Cubra com a massa e leve ao forno por 30 min.', oklch(0.68, .09, 60), 'foto: passo 3'),
      StepM('Desenforme virando sobre um prato.', oklch(0.66, .09, 60), 'foto: passo 4'),
    ],
    comments: [
      CommentM('Carla S.', 'A massa ficou perfeitamente crocante.', oklch(0.70, .08, 20)),
      CommentM('Pedro L.', 'Dica: deixar caramelizar bem antes de virar.', oklch(0.65, .08, 200)),
    ],
  ),
  RecipeM(
    id: 'r4', title: 'Costela ao fogo de chão', chefId: 'c4',
    color: oklch(0.58, .1, 30), imgLabel: 'foto: costela', category: 'Carnes',
    time: '6h', difficulty: 'Avançado', servings: '8 porções', stars: '★ 4.8',
    trending: false, likes: 733, commentsCount: 41,
    ingredients: ['2kg de costela bovina', 'Sal grosso a gosto', 'Alecrim fresco', 'Alho em lascas'],
    steps: [
      StepM('Tempere a costela com sal grosso na véspera.', oklch(0.60, .08, 30), 'foto: passo 1'),
      StepM('Leve ao fogo de chão por 5 a 6 horas.', oklch(0.58, .08, 30), 'vídeo: passo 2'),
    ],
    comments: [
      CommentM('Marcos T.', 'Resultado de churrasqueiro profissional.', oklch(0.70, .08, 20)),
    ],
  ),
  RecipeM(
    id: 'r5', title: 'Salada caprese com burrata', chefId: 'c1',
    color: oklch(0.78, .08, 130), imgLabel: 'foto: caprese', category: 'Saladas',
    time: '10 min', difficulty: 'Fácil', servings: '2 porções', stars: '★ 4.6',
    trending: false, likes: 298, commentsCount: 19,
    ingredients: ['2 tomates maduros', '1 burrata fresca', 'Manjericão fresco', 'Azeite extra virgem', 'Flor de sal'],
    steps: [
      StepM('Corte os tomates em rodelas e disponha no prato.', oklch(0.80, .06, 130), 'foto: passo 1'),
      StepM('Adicione a burrata no centro e finalize com azeite e manjericão.', oklch(0.78, .07, 130), 'foto: passo 2'),
    ],
    comments: [
      CommentM('Sofia R.', 'Simples e deliciosa, uso muito no verão.', oklch(0.70, .08, 20)),
    ],
  ),
  RecipeM(
    id: 'r6', title: 'Panquecas de banana', chefId: 'me',
    color: oklch(0.74, .08, 70), imgLabel: 'foto: panquecas', category: 'Doces',
    time: '20 min', difficulty: 'Fácil', servings: '2 porções', stars: '★ 4.5',
    trending: false, likes: 87, commentsCount: 6,
    ingredients: ['2 bananas maduras', '2 ovos', '1 xícara de farinha de aveia', 'Canela a gosto'],
    steps: [
      StepM('Amasse as bananas e misture com os ovos.', oklch(0.76, .06, 70), 'foto: passo 1'),
      StepM('Adicione a farinha de aveia e misture bem.', oklch(0.74, .07, 70), 'foto: passo 2'),
      StepM('Cozinhe em fogo médio até dourar dos dois lados.', oklch(0.72, .07, 70), 'vídeo: passo 3'),
    ],
    comments: [
      CommentM('Você mesmo', 'Receita de família, sempre funciona.', oklch(0.70, .08, 20)),
    ],
  ),
  RecipeM(
    id: 'r7', title: 'Espaguete à carbonara', chefId: 'me',
    color: oklch(0.76, .06, 60), imgLabel: 'foto: carbonara', category: 'Massas',
    time: '20 min', difficulty: 'Fácil', servings: '2 porções', stars: '★ 4.6',
    trending: false, likes: 64, commentsCount: 4,
    ingredients: ['200g de espaguete', '2 ovos', '100g de pancetta', '60g de pecorino', 'Pimenta preta'],
    steps: [
      StepM('Cozinhe o espaguete em água salgada.', oklch(0.78, .05, 60), 'foto: passo 1'),
      StepM('Frite a pancetta até dourar.', oklch(0.76, .05, 60), 'foto: passo 2'),
      StepM('Misture ovos e pecorino, combine tudo fora do fogo.', oklch(0.74, .06, 60), 'vídeo: passo 3'),
    ],
    comments: [],
  ),
];

final List<CollectionM> collections = [
  CollectionM('Jantares em 20 minutos', 12, oklch(0.55, .1, 30)),
  CollectionM('Fim de semana em família', 8, oklch(0.52, .09, 140)),
  CollectionM('Sobremesas de chef', 15, oklch(0.50, .1, 280)),
];

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
  return parts.map((w) => w[0]).join().toUpperCase();
}

// ─────────────────────────────────────────────────────────────
// App raiz
// ─────────────────────────────────────────────────────────────
class SaborApp extends StatelessWidget {
  const SaborApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabor — Protótipo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorSchemeSeed: kAccent,
        textTheme: ThemeData.light().textTheme.apply(bodyColor: kText, displayColor: kText),
      ),
      home: const RootShell(),
    );
  }
}

class ViewState {
  final String screen;
  final String? id;
  const ViewState(this.screen, [this.id]);
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  String activeTab = 'feed';
  ViewState? view;
  int createStep = 0;
  String createCategory = categories[0];
  final Set<String> liked = {};
  final Set<String> saved = {};
  final Set<String> following = {};
  String profileTab = 'recipes';
  String searchQuery = '';
  String searchCategory = 'Todas';

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  List<TextEditingController> ingredientCtrls = [TextEditingController()];
  List<TextEditingController> stepCtrls = [TextEditingController()];

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    for (final c in ingredientCtrls) {
      c.dispose();
    }
    for (final c in stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void setTab(String tab) => setState(() {
        activeTab = tab;
        view = null;
      });
  void openRecipe(String id) => setState(() => view = ViewState('recipe', id));
  void openChef(String id) => setState(() => view = ViewState('chef', id));
  void goBack() => setState(() => view = null);

  void startCreate() => setState(() {
        view = const ViewState('create');
        createStep = 0;
        createCategory = categories[0];
        titleCtrl.clear();
        descCtrl.clear();
        for (final c in ingredientCtrls) {
          c.dispose();
        }
        for (final c in stepCtrls) {
          c.dispose();
        }
        ingredientCtrls = [TextEditingController()];
        stepCtrls = [TextEditingController()];
      });

  void prevStep() => setState(() {
        if (createStep == 0) {
          view = null;
        } else {
          createStep -= 1;
        }
      });

  void nextStepOrPublish() => setState(() {
        if (createStep >= 3) {
          view = null;
          activeTab = 'profile';
        } else {
          createStep += 1;
        }
      });

  void toggleLike(String id) => setState(() => liked.contains(id) ? liked.remove(id) : liked.add(id));
  void toggleSave(String id) => setState(() => saved.contains(id) ? saved.remove(id) : saved.add(id));
  void toggleFollow(String id) => setState(() => following.contains(id) ? following.remove(id) : following.add(id));

  void addIngredient() => setState(() => ingredientCtrls.add(TextEditingController()));
  void removeIngredient(int i) => setState(() {
        if (ingredientCtrls.length > 1) ingredientCtrls.removeAt(i).dispose();
      });
  void addStep() => setState(() => stepCtrls.add(TextEditingController()));
  void removeStep(int i) => setState(() {
        if (stepCtrls.length > 1) stepCtrls.removeAt(i).dispose();
      });

  ChefM findChef(String id) => chefs.firstWhere((c) => c.id == id, orElse: () => ChefM(id: id, name: '', avatarColor: kAccent));
  String timeAgoFor(int i) => const ['2h', '5h', '1d', '2d', '3d', '1sem', '2sem'][i % 7];

  @override
  Widget build(BuildContext context) {
    final showTabBar = view == null;
    final isCreate = view?.screen == 'create';
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBody()),
            if (showTabBar) Align(alignment: Alignment.bottomCenter, child: _buildTabBar()),
            if (isCreate) Align(alignment: Alignment.bottomCenter, child: _buildWizardFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (view == null) {
      switch (activeTab) {
        case 'search':
          return _buildSearch();
        case 'explore':
          return _buildExplore();
        case 'profile':
          return _buildProfile();
        default:
          return _buildFeed();
      }
    }
    switch (view!.screen) {
      case 'recipe':
        return _buildRecipeDetail(view!.id!);
      case 'chef':
        return _buildChefProfile(view!.id!);
      case 'create':
        return _buildCreateWizard();
    }
    return _buildFeed();
  }

  // ── widgets auxiliares ──────────────────────────────────────
  Widget photoPlaceholder({required Color color, String? label, double height = 120, double radius = 14}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.15) ?? color],
          ),
        ),
        child: label == null
            ? null
            : Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.78), borderRadius: BorderRadius.circular(6)),
                  child: Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF291E14))),
                ),
              ),
      ),
    );
  }

  Widget _gridCard(RecipeM r, VoidCallback onTap, {String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          photoPlaceholder(color: r.color, label: r.imgLabel, height: 120, radius: 14),
          const SizedBox(height: 6),
          Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: kMuted)),
          ],
        ],
      ),
    );
  }

  Widget _statBlock(String value, String label) => Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      );

  Widget _statBox(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            Text(label, style: const TextStyle(fontSize: 10.5, color: kMuted)),
          ],
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDivider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDivider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccent)),
      );

  Widget _mediaSlot({required double height, required String label}) => GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Protótipo: upload de mídia não é funcional aqui.')),
        ),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kDivider)),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_photo_alternate_outlined, color: kMuted),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: kMuted, fontSize: 12.5)),
            ],
          ),
        ),
      );

  // ── FEED ─────────────────────────────────────────────────────
  Widget _buildFeed() {
    final shortChefs = chefs.where((c) => c.verified).take(4).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(9)),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('Sabor', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.3)),
                ],
              ),
              const Icon(Icons.notifications_none, size: 22),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            itemCount: shortChefs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final chef = shortChefs[i];
              return GestureDetector(
                onTap: () => openChef(chef.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [kAccent, kAccent.withOpacity(0.55)]),
                      ),
                      child: CircleAvatar(
                        backgroundColor: chef.avatarColor,
                        child: Text(initialsOf(chef.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 64,
                      child: Text(chef.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: kMuted)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            children: List.generate(recipes.length, (i) {
              final r = recipes[i];
              final chef = findChef(r.chefId);
              final isLiked = liked.contains(r.id);
              final isSaved = saved.contains(r.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => openChef(chef.id),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 16, backgroundColor: chef.avatarColor, child: Text(initialsOf(chef.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                          const SizedBox(width: 9),
                          Text(chef.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          if (chef.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: kVerifiedBlue),
                          ],
                          const SizedBox(width: 6),
                          Text('· ${timeAgoFor(i)}', style: const TextStyle(fontSize: 12, color: kMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(onTap: () => openRecipe(r.id), child: photoPlaceholder(color: r.color, label: r.imgLabel, height: 210, radius: 18)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => openRecipe(r.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, height: 1.25)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(r.stars, style: const TextStyle(fontSize: 12.5, color: kMuted)),
                              const SizedBox(width: 6),
                              Text('· ${r.time}', style: const TextStyle(fontSize: 12.5, color: kMuted)),
                              const SizedBox(width: 6),
                              Text('· ${r.difficulty}', style: const TextStyle(fontSize: 12.5, color: kMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => toggleLike(r.id),
                              child: Row(
                                children: [
                                  Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 21, color: isLiked ? kAccent : kText),
                                  const SizedBox(width: 5),
                                  Text('${r.likes + (isLiked ? 1 : 0)}', style: const TextStyle(fontSize: 12.5, color: kMuted)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            Row(
                              children: [
                                const Icon(Icons.mode_comment_outlined, size: 20),
                                const SizedBox(width: 5),
                                Text('${r.commentsCount}', style: const TextStyle(fontSize: 12.5, color: kMuted)),
                              ],
                            ),
                            const SizedBox(width: 18),
                            const Icon(Icons.send_outlined, size: 20),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => toggleSave(r.id),
                          child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── SEARCH ───────────────────────────────────────────────────
  Widget _buildSearch() {
    var results = recipes.where((r) {
      if (searchCategory != 'Todas' && r.category != searchCategory) return false;
      if (searchQuery.trim().isNotEmpty && !r.title.toLowerCase().contains(searchQuery.trim().toLowerCase())) return false;
      return true;
    }).toList();
    final label = (searchQuery.isNotEmpty || searchCategory != 'Todas') ? '${results.length} resultados' : 'Buscas populares';

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pesquisar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar receitas, ingredientes...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            children: ['Todas', ...categories].map((cat) {
              final active = searchCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => searchCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? kAccent : kSurface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: active ? kAccent : kDivider),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : kMuted)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kMuted, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
                children: results.map((r) => _gridCard(r, () => openRecipe(r.id), subtitle: findChef(r.chefId).name)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── EXPLORE ──────────────────────────────────────────────────
  Widget _buildExplore() {
    final verifiedFull = chefs.where((c) => c.verified).toList();
    final trending = recipes.where((r) => r.trending).toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 4), child: Text('Explorar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: const [
              Text('Chefs verificados', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              SizedBox(width: 6),
              Icon(Icons.verified, size: 13, color: kVerifiedBlue),
            ],
          ),
        ),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: verifiedFull.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final chef = verifiedFull[i];
              final isFollowing = following.contains(chef.id);
              return Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => openChef(chef.id),
                      child: Column(
                        children: [
                          CircleAvatar(radius: 28, backgroundColor: chef.avatarColor, child: Text(initialsOf(chef.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                          const SizedBox(height: 6),
                          Text(chef.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(chef.specialty, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: kMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => toggleFollow(chef.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: isFollowing ? kSurface : kAccent, borderRadius: BorderRadius.circular(100)),
                        child: Text(isFollowing ? 'Seguindo' : 'Seguir', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isFollowing ? kMuted : Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 18, 20, 10), child: Text('Em alta agora', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final r = trending[i];
              return SizedBox(width: 170, child: _gridCard(r, () => openRecipe(r.id), subtitle: findChef(r.chefId).name));
            },
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 18, 20, 10), child: Text('Categorias', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: categories
                .map((cat) => Container(
                      decoration: BoxDecoration(color: catColors[cat], borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      child: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coleções editoriais', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              ...collections.map((col) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 90,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(color: col.color, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(col.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text('${col.count} receitas', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ── PROFILE (próprio) ───────────────────────────────────────
  Widget _buildProfile() {
    final myRecipes = recipes.where((r) => r.chefId == 'me').toList();
    final savedRecipes = recipes.where((r) => saved.contains(r.id)).toList();
    final grid = profileTab == 'recipes' ? myRecipes : savedRecipes;

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              CircleAvatar(radius: 42, backgroundColor: kAccent.withOpacity(0.85), child: const Text('VC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 26))),
              const SizedBox(height: 10),
              const Text('Você', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              const SizedBox(height: 4),
              const Text('Cozinhando o dia a dia, um prato de cada vez 🍳', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: kMuted)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statBlock('${myRecipes.length}', 'Receitas'),
                  const SizedBox(width: 28),
                  _statBlock('312', 'Seguidores'),
                  const SizedBox(width: 28),
                  _statBlock('89', 'Seguindo'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), side: const BorderSide(color: kDivider)),
                      child: const Text('Editar perfil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: startCreate,
                      style: ElevatedButton.styleFrom(backgroundColor: kAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                      child: const Text('Criar receita', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kDivider))),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => profileTab = 'recipes'),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: profileTab == 'recipes' ? kAccent : Colors.transparent, width: 2))),
                    child: Text('Minhas receitas', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: profileTab == 'recipes' ? kText : kMuted)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => profileTab = 'saved'),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: profileTab == 'saved' ? kAccent : Colors.transparent, width: 2))),
                    child: Text('Salvas', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: profileTab == 'saved' ? kText : kMuted)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: grid.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Nenhuma receita salva ainda.', style: TextStyle(color: kMuted, fontSize: 13.5))),
                )
              : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: grid.map((r) => _gridCard(r, () => openRecipe(r.id))).toList(),
                ),
        ),
      ],
    );
  }

  // ── CHEF PROFILE ─────────────────────────────────────────────
  Widget _buildChefProfile(String id) {
    final chef = findChef(id);
    final chefRecipes = recipes.where((r) => r.chefId == id).toList();
    final isFollowing = following.contains(id);
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), child: GestureDetector(onTap: goBack, child: const Icon(Icons.arrow_back_ios_new, size: 20))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(radius: 44, backgroundColor: chef.avatarColor, child: Text(initialsOf(chef.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 30))),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified, size: 20, color: kVerifiedBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(chef.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(100)),
                child: const Text('Chef verificado', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: kVerifiedBlue)),
              ),
              const SizedBox(height: 8),
              Text(chef.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: kMuted)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statBlock('${chefRecipes.length}', 'Receitas'),
                  const SizedBox(width: 28),
                  _statBlock(chef.followers, 'Seguidores'),
                  const SizedBox(width: 28),
                  _statBlock(chef.rating, 'Avaliação'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => toggleFollow(id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: isFollowing ? kSurface : kAccent, borderRadius: BorderRadius.circular(100)),
                        child: Text(isFollowing ? 'Seguindo' : 'Seguir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isFollowing ? kMuted : Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(color: kDivider)),
                      child: const Text('Mensagem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receitas de ${chef.name}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: chefRecipes.map((r) => _gridCard(r, () => openRecipe(r.id))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RECIPE DETAIL ────────────────────────────────────────────
  Widget _buildRecipeDetail(String id) {
    final r = recipes.firstWhere((x) => x.id == id);
    final chef = findChef(r.chefId);
    final isLiked = liked.contains(id);
    final isSaved = saved.contains(id);
    final isFollowing = following.contains(r.chefId);
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Stack(
          children: [
            photoPlaceholder(color: r.color, height: 260, radius: 0),
            Positioned(
              top: 16,
              left: 20,
              child: GestureDetector(
                onTap: goBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(100)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, size: 14),
                    SizedBox(width: 6),
                    Text('vídeo da receita', style: TextStyle(fontFamily: 'monospace', fontSize: 10.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, height: 1.25)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => openChef(chef.id),
                child: Row(
                  children: [
                    CircleAvatar(radius: 17, backgroundColor: chef.avatarColor, child: Text(initialsOf(chef.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                    const SizedBox(width: 9),
                    Text(chef.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (chef.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: kVerifiedBlue),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () => toggleFollow(chef.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: isFollowing ? kSurface : kAccent, borderRadius: BorderRadius.circular(100)),
                        child: Text(isFollowing ? 'Seguindo' : 'Seguir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isFollowing ? kMuted : Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: kDivider), bottom: BorderSide(color: kDivider))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => toggleLike(id),
                      child: Row(
                        children: [
                          Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 21, color: isLiked ? kAccent : kText),
                          const SizedBox(width: 5),
                          Text('${r.likes + (isLiked ? 1 : 0)}', style: const TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                    Text('${r.stars} · ${r.commentsCount} avaliações', style: const TextStyle(fontSize: 13, color: kMuted)),
                    GestureDetector(onTap: () => toggleSave(id), child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20)),
                    const Icon(Icons.send_outlined, size: 20),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(child: _statBox(r.time, 'tempo')),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox(r.difficulty, 'dificuldade')),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox(r.servings, 'porções')),
                ],
              ),
              const SizedBox(height: 22),
              const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 10),
              ...r.ingredients.map((ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(ing, style: const TextStyle(fontSize: 13.5))),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              const Text('Modo de preparo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 12),
              ...List.generate(r.steps.length, (i) {
                final st = r.steps[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(st.desc, style: const TextStyle(fontSize: 13.5, height: 1.55)),
                            const SizedBox(height: 8),
                            photoPlaceholder(color: st.color, label: st.mediaLabel, height: 110, radius: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),
              const Text('Comentários', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 12),
              ...r.comments.map((cm) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 15, backgroundColor: cm.avatarColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cm.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(cm.text, style: const TextStyle(fontSize: 13, color: kMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              if (r.comments.isNotEmpty)
                Text('Ver todos os ${r.commentsCount} comentários', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kAccent)),
            ],
          ),
        ),
      ],
    );
  }

  // ── CREATE WIZARD ────────────────────────────────────────────
  Widget _buildCreateWizard() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: prevStep, child: const Icon(Icons.arrow_back_ios_new, size: 18)),
              const Text('Nova receita', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: kMuted)),
              const SizedBox(width: 18),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Row(
            children: List.generate(4, (i) {
              final active = i <= createStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(color: active ? kAccent : kDivider, borderRadius: BorderRadius.circular(100)),
                ),
              );
            }),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0), child: _wizardStepContent()),
      ],
    );
  }

  Widget _wizardStepContent() {
    switch (createStep) {
      case 0:
        return _wizardStep0();
      case 1:
        return _wizardStep1();
      case 2:
        return _wizardStep2();
      default:
        return _wizardStep3();
    }
  }

  Widget _wizardStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informações básicas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 16),
        const Text('FOTO DE CAPA', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kMuted)),
        const SizedBox(height: 8),
        _mediaSlot(height: 180, label: 'Adicionar foto ou vídeo de capa'),
        const SizedBox(height: 18),
        const Text('TÍTULO DA RECEITA', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kMuted)),
        const SizedBox(height: 8),
        TextField(controller: titleCtrl, decoration: _inputDecoration('Ex: Risoto de cogumelos')),
        const SizedBox(height: 16),
        const Text('CATEGORIA', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final active = createCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => createCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kAccent : kSurface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: active ? kAccent : kDivider),
                ),
                child: Text(cat, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: active ? Colors.white : kMuted)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('DESCRIÇÃO', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kMuted)),
        const SizedBox(height: 8),
        TextField(controller: descCtrl, maxLines: 4, decoration: _inputDecoration('Conte um pouco sobre esta receita...')),
      ],
    );
  }

  Widget _wizardStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 16),
        ...List.generate(
          ingredientCtrls.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(child: TextField(controller: ingredientCtrls[i], decoration: _inputDecoration('Ex: 200g de arroz arbóreo'))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => removeIngredient(i),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: addIngredient,
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider, width: 1.5)),
            child: const Text('+ Adicionar ingrediente', style: TextStyle(color: kAccent, fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ),
      ],
    );
  }

  Widget _wizardStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Modo de preparo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 16),
        ...List.generate(
          stepCtrls.length,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.only(bottom: 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kDivider))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Passo ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    GestureDetector(onTap: () => removeStep(i), child: const Text('Remover', style: TextStyle(fontSize: 12, color: kMuted))),
                  ],
                ),
                const SizedBox(height: 8),
                _mediaSlot(height: 120, label: 'Adicionar foto ou vídeo do passo'),
                const SizedBox(height: 8),
                TextField(controller: stepCtrls[i], maxLines: 3, decoration: _inputDecoration('Descreva este passo...')),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: addStep,
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: kDivider, width: 1.5)),
            child: const Text('+ Adicionar passo', style: TextStyle(color: kAccent, fontWeight: FontWeight.w600, fontSize: 13.5)),
          ),
        ),
      ],
    );
  }

  Widget _wizardStep3() {
    final title = titleCtrl.text.trim().isEmpty ? 'Receita sem título' : titleCtrl.text.trim();
    final description = descCtrl.text.trim().isEmpty ? 'Sem descrição adicionada.' : descCtrl.text.trim();
    final ingCount = ingredientCtrls.where((c) => c.text.trim().isNotEmpty).length;
    final stepCount = stepCtrls.where((c) => c.text.trim().isNotEmpty).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revisão', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 16),
        Container(height: 150, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19)),
        const SizedBox(height: 4),
        Text(createCategory, style: const TextStyle(fontSize: 12.5, color: kMuted)),
        const SizedBox(height: 10),
        Text(description, style: const TextStyle(fontSize: 13.5, color: kMuted, height: 1.5)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statBox('$ingCount', 'ingredientes')),
            const SizedBox(width: 10),
            Expanded(child: _statBox('$stepCount', 'passos')),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Passos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        ...List.generate(stepCtrls.length, (i) {
          final text = stepCtrls[i].text.trim().isEmpty ? '(sem descrição)' : stepCtrls[i].text.trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: kMuted))),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWizardFooter() {
    final label = createStep >= 3 ? 'Publicar receita' : 'Continuar';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(color: kBg, border: Border(top: BorderSide(color: kDivider))),
      child: ElevatedButton(
        onPressed: nextStepOrPublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }

  // ── TAB BAR ──────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
      decoration: BoxDecoration(color: kBg.withOpacity(0.96), border: const Border(top: BorderSide(color: kDivider))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Feed', active: activeTab == 'feed', onTap: () => setTab('feed')),
          _tabItem(icon: Icons.search, activeIcon: Icons.search, label: 'Pesquisar', active: activeTab == 'search', onTap: () => setTab('search')),
          GestureDetector(
            onTap: startCreate,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: kAccent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: kAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          _tabItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explorar', active: activeTab == 'explore', onTap: () => setTab('explore')),
          _tabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil', active: activeTab == 'profile', onTap: () => setTab('profile')),
        ],
      ),
    );
  }

  Widget _tabItem({required IconData icon, required IconData activeIcon, required String label, required bool active, required VoidCallback onTap}) {
    final color = active ? kAccent : kMuted;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? activeIcon : icon, color: color, size: 23),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
