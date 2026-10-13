import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/devotional.dart';

class DevotionalService {
  const DevotionalService();

  static const String apiBaseUrl =
      String.fromEnvironment('VOZ_DA_FE_API_URL', defaultValue: '');

  Future<Devotional> generate(String message) async {
    final text = message.trim();
    if (text.isEmpty) throw ArgumentError('Conte como você está se sentindo.');
    if (text.length > 500) {
      throw ArgumentError('Use no máximo 500 caracteres.');
    }

    if (apiBaseUrl.isNotEmpty) {
      try {
        final base = apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
        final response = await http.post(
          Uri.parse(base + '/api/analyze'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'message': text}),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          return Devotional.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
          );
        }
        if (response.statusCode == 422) {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          throw ArgumentError(body['error'] ?? 'Mensagem inválida.');
        }
      } on ArgumentError {
        rethrow;
      } catch (_) {
        // If the service is unreachable, use carefully curated local content.
      }
    }
    return LocalDevotionalGenerator.generate(text);
  }
}

class LocalDevotionalGenerator {
  static const Map<String, Map<String, Object>> _themes = {
    'ansiedade': {
      'keywords': ['ansiedade', 'ansioso', 'ansiosa', 'medo', 'preocupado', 'preocupada', 'preocupacao', 'nervoso', 'estresse', 'inseguro'],
      'title': 'Você não precisa carregar tudo sozinho',
      'verse': 'Filipenses 4:6-7',
      'reflection': 'Nem todas as respostas precisam chegar hoje. Quando o futuro pesa, a oração pode ser um espaço para reconhecer seus limites e encontrar paz para o próximo passo. Deus conhece aquilo que você ainda não consegue organizar em palavras. Caminhe um dia de cada vez.',
      'prayer': 'Senhor, entrego a Ti as preocupações que apertam meu coração. Dá-me serenidade para o que não controlo, coragem para o que posso fazer e sabedoria para reconhecer Tua presença hoje. Amém.',
      'practice': 'Anote uma preocupação e uma pequena ação possível para hoje.',
    },
    'tristeza': {
      'keywords': ['triste', 'tristeza', 'chorar', 'sozinho', 'sozinha', 'solida', 'solitario', 'luto', 'perda', 'saudade', 'desanimado', 'desanimada'],
      'title': 'Há acolhimento para o seu coração',
      'verse': 'Salmos 34:18',
      'reflection': 'A tristeza não é sinal de pouca fé. Existem dias em que o coração precisa de silêncio, cuidado e companhia. A Escritura apresenta um Deus próximo de quem está ferido. Você não precisa fingir força: permita-se ser cuidado e peça ajuda a alguém de confiança.',
      'prayer': 'Deus de consolo, recebe minhas lágrimas e a dor que ainda não sei explicar. Aproxima de mim pessoas que tragam cuidado e renova, pouco a pouco, minha esperança. Amém.',
      'practice': 'Converse com alguém de confiança e permita-se descansar sem culpa.',
    },
    'gratidao': {
      'keywords': ['grato', 'grata', 'obrigado', 'obrigada', 'gratidao', 'feliz', 'alegria', 'conquista', 'vitoria'],
      'title': 'Reconheça as pequenas bênçãos',
      'verse': '1 Tessalonicenses 5:18',
      'reflection': 'A gratidão nos ajuda a perceber a graça no cotidiano: nas pessoas, no alimento, nas portas abertas e até nos pequenos recomeços. Celebre o bem que chegou sem esquecer daqueles que precisam de apoio. A alegria cresce quando é compartilhada.',
      'prayer': 'Pai, obrigado pelas dádivas que recebi, inclusive as discretas. Ensina-me a viver com generosidade e a transformar minha alegria em cuidado pelo próximo. Amém.',
      'practice': 'Agradeça diretamente a uma pessoa que fez diferença no seu dia.',
    },
    'decisao': {
      'keywords': ['decisao', 'decidir', 'escolher', 'escolha', 'trabalho', 'emprego', 'caminho', 'duvida', 'futuro', 'mudanca'],
      'title': 'Sabedoria para o próximo passo',
      'verse': 'Tiago 1:5',
      'reflection': 'Não é preciso conhecer o caminho inteiro para dar um passo responsável. Buscar sabedoria inclui orar, ouvir conselhos e examinar as opções com calma. A fé não elimina a necessidade de decidir; ela pode ajudar a fazê-lo com honestidade e coragem.',
      'prayer': 'Senhor, orienta meu coração nesta escolha. Dá-me clareza para avaliar caminhos, humildade para buscar bons conselhos e paz para agir com responsabilidade. Amém.',
      'practice': 'Escreva duas opções e converse sobre elas com alguém sensato.',
    },
    'esperanca': {
      'keywords': ['esperanca', 'cansado', 'cansada', 'dificil', 'dificuldade', 'fracasso', 'recomecar', 'recomeco', 'desmotivado'],
      'title': 'Ainda há um novo começo',
      'verse': 'Isaías 40:31',
      'reflection': 'O cansaço pode tornar tudo mais distante, mas não define seu valor nem seu futuro. A imagem bíblica da esperança fala de forças renovadas. Respeite o ritmo do seu corpo, procure apoio e lembre-se: recomeços também acontecem em passos pequenos.',
      'prayer': 'Deus, renova minha esperança quando as forças parecem pequenas. Ajuda-me a descansar, aceitar cuidado e encontrar coragem para continuar. Amém.',
      'practice': 'Escolha uma tarefa pequena e possível, sem exigir perfeição.',
    },
  };

  static String _normalize(String text) {
    var value = text.toLowerCase();
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to =   'aaaaaeeeeiiiiooooouuuuc';
    for (var i = 0; i < from.length; i++) {
      value = value.replaceAll(from[i], to[i]);
    }
    return value;
  }

  static Devotional generate(String message) {
    final normalized = _normalize(message);
    var bestName = 'esperanca';
    var bestScore = 0;
    for (final entry in _themes.entries) {
      final keywords = entry.value['keywords'] as List<String>;
      final score = keywords.where((word) {
        return RegExp('(^|[^a-z])' + RegExp.escape(word) + '([^a-z]|$)')
            .hasMatch(normalized);
      }).length;
      if (score > bestScore) {
        bestScore = score;
        bestName = entry.key;
      }
    }

    final item = _themes[bestName]!;
    return Devotional(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      theme: bestName,
      title: item['title']! as String,
      verseReference: item['verse']! as String,
      reflection: item['reflection']! as String,
      prayer: item['prayer']! as String,
      practice: item['practice']! as String,
      createdAt: DateTime.now(),
      isLocal: true,
    );
  }
}
