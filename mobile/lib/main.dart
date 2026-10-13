import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'models/devotional.dart';
import 'services/devotional_service.dart';
import 'services/saved_store.dart';
import 'services/voice_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VozDaFeApp());
}

const _ink = Color(0xFF253D51);
const _deep = Color(0xFF163B50);
const _cream = Color(0xFFFAF8F3);
const _sand = Color(0xFFE8D3AD);
const _muted = Color(0xFF657984);

class VozDaFeApp extends StatelessWidget {
  const VozDaFeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voz da Fé',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _cream,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _deep,
            surface: _cream,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: _cream,
            foregroundColor: _ink,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(18),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: _deep,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        home: const VozDaFeHome(),
      );
}

class VozDaFeHome extends StatefulWidget {
  const VozDaFeHome({super.key});

  @override
  State<VozDaFeHome> createState() => _VozDaFeHomeState();
}

class _VozDaFeHomeState extends State<VozDaFeHome> {
  final _message = TextEditingController();
  final _voice = VoiceEngine();
  final _store = SavedStore();
  final _service = const DevotionalService();
  List<Devotional> _saved = [];
  Devotional? _result;
  int _tab = 0;
  bool _busy = false;
  bool _listening = false;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final items = await _store.load();
      if (mounted) setState(() => _saved = items);
    } catch (_) {
      if (mounted) _notice('Não foi possível carregar os favoritos.');
    }
  }

  @override
  void dispose() {
    _message.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _generate() async {
    if (_busy) return;
    final text = _message.text.trim();
    if (text.isEmpty) {
      _notice('Escreva ou conte como você está se sentindo.');
      return;
    }
    if (text.length > 500) {
      _notice('Sua mensagem deve ter até 500 caracteres.');
      return;
    }

    await _voice.stopListening();
    if (!mounted) return;
    setState(() {
      _busy = true;
      _listening = false;
    });
    FocusScope.of(context).unfocus();

    try {
      final item = await _service.generate(text);
      if (!mounted) return;
      setState(() => _result = item);
    } catch (error) {
      _notice('Não foi possível gerar a mensagem: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_listening || _voice.isListening) {
      await _voice.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }
    try {
      final ready = await _voice.listen(
        onText: (text) {
          if (!mounted) return;
          _message.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
          setState(() {});
        },
        onListeningChanged: (listening) {
          if (mounted) setState(() => _listening = listening);
        },
      );
      if (!ready) {
        _notice('Ative o microfone e o reconhecimento de fala nas permissões.');
      }
    } catch (_) {
      _notice('O reconhecimento de voz não está disponível neste aparelho.');
      if (mounted) setState(() => _listening = false);
    }
  }

  Future<void> _play(Devotional item) async {
    if (_playingId == item.id) {
      await _voice.stopSpeaking();
      if (mounted) setState(() => _playingId = null);
      return;
    }

    await _voice.stopSpeaking();
    if (!mounted) return;
    setState(() => _playingId = item.id);
    try {
      await _voice.speak(item.speechText);
    } catch (_) {
      _notice('Não foi possível reproduzir a voz neste aparelho.');
    } finally {
      if (mounted && _playingId == item.id) {
        setState(() => _playingId = null);
      }
    }
  }

  bool _isSaved(Devotional item) =>
      _saved.any((saved) => saved.id == item.id);

  Future<void> _toggleSaved(Devotional item) async {
    final next = List<Devotional>.from(_saved);
    if (_isSaved(item)) {
      next.removeWhere((saved) => saved.id == item.id);
    } else {
      next.insert(0, item);
    }

    try {
      await _store.save(next);
      if (!mounted) return;
      setState(() => _saved = next);
      _notice(_isSaved(item) ? 'Salvo nos favoritos.' : 'Removido dos favoritos.');
    } catch (_) {
      _notice('Não foi possível atualizar os favoritos.');
    }
  }

  Future<void> _share(Devotional item) async {
    try {
      await Share.share(item.shareText, subject: 'Voz da Fé');
    } catch (_) {
      _notice('Compartilhamento indisponível neste dispositivo.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Salvos',
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: _tab == 0 ? _home() : _favorites(),
            ),
          ),
        ),
      );

  Widget _home() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _brand(),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [_deep, Color(0xFF3D6176)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.light_mode_outlined, color: _sand, size: 32),
                  SizedBox(height: 22),
                  Text(
                    'Existe uma palavra\npara o seu hoje.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      height: 1.16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Compartilhe o que está no seu coração e encontre uma leitura bíblica, reflexão e oração.',
                    style: TextStyle(color: Color(0xFFE4EAE8), height: 1.55),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            const Text(
              'Como está seu coração?',
              style: TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escreva livremente ou toque no microfone para falar.',
              style: TextStyle(color: _muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 6,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Hoje eu estou me sentindo...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: _listening ? 'Parar gravação' : 'Ditar mensagem',
                  onPressed: _busy ? null : _toggleMicrophone,
                  icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
                ),
                const SizedBox(width: 10),
                if (_listening)
                  const Expanded(
                    child: Text(
                      'Ouvindo sua voz...',
                      style: TextStyle(color: _deep, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      'Toque para falar',
                      style: TextStyle(color: _muted),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _busy ? null : _generate,
                    child: _busy
                        ? const SizedBox(
                            height: 19,
                            width: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Receber minha palavra'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (_result != null) _devotionalCard(_result!),
            const SizedBox(height: 20),
            const Text(
              'Este espaço oferece reflexão espiritual, não substitui apoio profissional. Em momentos difíceis, procure alguém de confiança.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12, height: 1.55),
            ),
          ],
        ),
      );

  Widget _favorites() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _brand(),
            const SizedBox(height: 28),
            const Text(
              'Palavras guardadas',
              style: TextStyle(
                color: _ink,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Volte às reflexões que tocaram seu coração.',
              style: TextStyle(color: _muted),
            ),
            const SizedBox(height: 24),
            if (_saved.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 58,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.bookmark_border, size: 48, color: _muted),
                    SizedBox(height: 12),
                    Text(
                      'Você ainda não salvou reflexões.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _ink, fontSize: 16),
                    ),
                  ],
                ),
              ),
            for (final item in _saved) ...[
              _devotionalCard(item),
              const SizedBox(height: 17),
            ],
          ],
        ),
      );

  Widget _brand() => Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEEE6D7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: _deep),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voz da Fé',
                style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Um momento de paz',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ],
      );

  Widget _devotionalCard(Devotional item) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFFF0EDE5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories_outlined, color: _deep),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'SUA PALAVRA',
                    style: TextStyle(
                      color: _deep,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (item.isLocal)
                  const Text(
                    'No dispositivo',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              item.title,
              style: const TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 19),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F2EB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_outlined, color: _deep),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leitura bíblica sugerida',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        Text(
                          item.verseReference,
                          style: const TextStyle(
                            color: _deep,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _section('Reflexão', item.reflection),
            const SizedBox(height: 21),
            _section('Oração', item.prayer),
            const SizedBox(height: 21),
            _section('Um passo para hoje', item.practice),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFECE7DD)),
            const SizedBox(height: 5),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _play(item),
                  icon: Icon(
                    _playingId == item.id
                        ? Icons.stop_rounded
                        : Icons.volume_up_outlined,
                  ),
                  label: Text(
                    _playingId == item.id ? 'Parar' : 'Ouvir',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _toggleSaved(item),
                  icon: Icon(
                    _isSaved(item) ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  label: Text(_isSaved(item) ? 'Salvo' : 'Salvar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _share(item),
                  icon: const Icon(Icons.ios_share_outlined),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _section(String label, String content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _deep,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              height: 1.65,
            ),
          ),
        ],
      );
}
