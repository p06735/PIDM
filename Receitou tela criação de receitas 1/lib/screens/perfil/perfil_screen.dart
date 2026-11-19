import 'package:flutter/material.dart';

import '../../data/receita_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/imagem_local.dart';
import '../nova_receita/nova_receita_fluxo.dart';
import '../nova_receita/nova_receita_informacoes_screen.dart';
import '../nova_receita/widgets/componentes_fluxo.dart';

/// Perfil do usuário (tela inicial).
/// Spec: specs/perfil.md
class PerfilScreen extends StatefulWidget {
  static const postagensBase = 10;

  final ReceitaRepository receitas;

  PerfilScreen({super.key, ReceitaRepository? receitas})
    : receitas = receitas ?? ReceitaRepository();

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _rolagem = ScrollController();

  List<ReceitaResumo> _minhas = const [];
  Set<String> _salvas = {};
  bool _abaSalvas = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final minhas = await widget.receitas.minhasReceitas();
    final salvas = await widget.receitas.salvas();
    if (!mounted) return;
    setState(() {
      _minhas = minhas;
      _salvas = salvas;
    });
  }

  Future<void> _alternarSalva(ReceitaResumo receita) async {
    final salva = !_salvas.contains(receita.id);
    setState(() => salva ? _salvas.add(receita.id) : _salvas.remove(receita.id));
    await widget.receitas.definirSalva(receita.id, salva);
  }

  void _emBreve() => avisar(context, 'Em breve');

  bool _abrindoFluxo = false;

  /// Abre "Nova Receita" (Passo 1). Ao voltar — publicando ou fechando pelo
  /// X — recarrega a lista para mostrar a receita nova.
  Future<void> _criarReceita() async {
    // Dois toques rápidos abririam dois fluxos empilhados.
    if (_abrindoFluxo) return;
    _abrindoFluxo = true;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NovaReceitaInformacoesScreen(),
      ),
    );
    _abrindoFluxo = false;
    if (!mounted) return;
    await _carregar();
    if (!mounted) return;
    setState(() => _abaSalvas = false);
    _irParaTopo();
  }

  void _irParaTopo() {
    if (!_rolagem.hasClients) return;
    _rolagem.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _abaSalvas
        ? _minhas.where((r) => _salvas.contains(r.id)).toList()
        : _minhas;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: _emBreve,
        ),
        title: const Text('Receitou'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notificações',
            onPressed: _emBreve,
          ),
        ],
      ),
      body: ListView(
        controller: _rolagem,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Cabecalho(
            postagens: PerfilScreen.postagensBase + _minhas.length,
            onEditar: _emBreve,
            onCompartilhar: _emBreve,
          ),
          const SizedBox(height: 24),
          _Abas(
            salvas: _abaSalvas,
            onMudar: (salvas) => setState(() => _abaSalvas = salvas),
          ),
          const SizedBox(height: 20),
          if (!_abaSalvas) ...[
            _CartaoCriar(onTap: _criarReceita),
            const SizedBox(height: 20),
          ],
          if (_abaSalvas && lista.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Text(
                'Nenhuma receita salva ainda. Toque no ♥ de uma receita '
                'para guardá-la aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),
          for (final receita in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _CartaoReceita(
                key: ValueKey(receita.id),
                receita: receita,
                salva: _salvas.contains(receita.id),
                onSalvar: () => _alternarSalva(receita),
                onTap: _emBreve,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _BarraInferior(
        onFeed: _emBreve,
        onPesquisar: _emBreve,
        onCriar: _criarReceita,
        onExplorar: _emBreve,
        onPerfil: _irParaTopo,
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final int postagens;
  final VoidCallback onEditar;
  final VoidCallback onCompartilhar;

  const _Cabecalho({
    required this.postagens,
    required this.onEditar,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 8)],
          ),
          child: const ClipOval(child: ImagemLocal('assets/img/avatar.png')),
        ),
        const SizedBox(height: 12),
        const Text(
          'Você',
          style: TextStyle(
            fontFamily: AppTheme.fonteSerifada,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.texto,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explorando novos sabores na cozinha.\n'
          'Amante de massas e pães artesanais. 🍝🥖',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.texto, height: 1.35),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _Estatistica(valor: '$postagens', rotulo: 'POSTAGENS'),
            const _Estatistica(valor: '245', rotulo: 'SEGUIDORES'),
            const _Estatistica(valor: '180', rotulo: 'SEGUINDO'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text(
                  'Editar Perfil',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracota,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCompartilhar,
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text(
                  'Compartilhar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.texto,
                  side: const BorderSide(color: AppColors.terracota),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Estatistica extends StatelessWidget {
  final String valor;
  final String rotulo;

  const _Estatistica({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.terracota,
            ),
          ),
          Text(
            rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _Abas extends StatelessWidget {
  final bool salvas;
  final ValueChanged<bool> onMudar;

  const _Abas({required this.salvas, required this.onMudar});

  @override
  Widget build(BuildContext context) {
    Widget aba(String texto, bool ativa, bool valor) => InkWell(
      onTap: () => onMudar(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ativa ? AppColors.terracota : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ativa ? AppColors.terracota : AppColors.texto,
          ),
        ),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borda)),
      ),
      child: Row(
        children: [
          Flexible(child: aba('Minhas Receitas', !salvas, false)),
          Flexible(child: aba('Salvas', salvas, true)),
        ],
      ),
    );
  }
}

class _CartaoCriar extends StatelessWidget {
  final VoidCallback onTap;

  const _CartaoCriar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.superficie,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: CustomPaint(
          painter: const BordaTracejada(raio: 12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.terracota,
                  child: Icon(Icons.add, color: Colors.white, size: 28),
                ),
                SizedBox(height: 14),
                Text(
                  'Criar Receita',
                  style: TextStyle(
                    fontFamily: AppTheme.fonteSerifada,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.terracota,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Compartilhe sua próxima criação culinária',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.texto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoReceita extends StatelessWidget {
  final ReceitaResumo receita;
  final bool salva;
  final VoidCallback onSalvar;
  final VoidCallback onTap;

  const _CartaoReceita({
    super.key,
    required this.receita,
    required this.salva,
    required this.onSalvar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorsExtra.cartao,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  receita.foto != null
                      ? ImagemLocal(receita.foto!)
                      : const ColoredBox(
                          color: AppColors.superficie,
                          child: Icon(
                            Icons.restaurant,
                            size: 48,
                            color: AppColors.borda,
                          ),
                        ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: salva ? 'Remover dos salvos' : 'Salvar',
                        onPressed: onSalvar,
                        icon: Icon(
                          salva ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.terracota,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Etiqueta(
                        receita.categoria,
                        cor: AppColorsExtra.verdeClaro,
                      ),
                      if (receita.dificuldade != null)
                        _Etiqueta(
                          receita.dificuldade!,
                          cor: AppColors.superficie,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    receita.titulo,
                    style: const TextStyle(
                      fontFamily: AppTheme.fonteSerifada,
                      fontSize: 18,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (receita.tempo != null) ...[
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.texto,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          receita.tempo!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                      const Spacer(),
                      const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.texto,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        receita.curtidasFormatadas,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;

  const _Etiqueta(this.texto, {required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: AppColors.texto),
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  final VoidCallback onFeed;
  final VoidCallback onPesquisar;
  final VoidCallback onCriar;
  final VoidCallback onExplorar;
  final VoidCallback onPerfil;

  const _BarraInferior({
    required this.onFeed,
    required this.onPesquisar,
    required this.onCriar,
    required this.onExplorar,
    required this.onPerfil,
  });

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icone, String rotulo, VoidCallback onTap,
        {bool ativo = false}) {
      final cor = ativo ? Colors.white : AppColors.texto;
      return Expanded(
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            height: 60,
            decoration: ativo
                ? const BoxDecoration(
                    color: AppColors.terracota,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, size: 20, color: cor),
                const SizedBox(height: 2),
                Text(
                  rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: cor,
                    fontWeight: ativo ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fundo,
        border: Border(top: BorderSide(color: AppColors.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              item(Icons.home_outlined, 'Feed', onFeed),
              item(Icons.search, 'Pesquisar', onPesquisar),
              item(Icons.add_circle_outline, 'Criar', onCriar),
              item(Icons.explore_outlined, 'Explorar', onExplorar),
              item(Icons.person, 'Perfil', onPerfil, ativo: true),
            ],
          ),
        ),
      ),
    );
  }
}
