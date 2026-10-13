class Devotional {
  const Devotional({
    required this.id,
    required this.theme,
    required this.title,
    required this.verseReference,
    required this.reflection,
    required this.prayer,
    required this.practice,
    required this.createdAt,
    this.isLocal = false,
  });

  final String id;
  final String theme;
  final String title;
  final String verseReference;
  final String reflection;
  final String prayer;
  final String practice;
  final DateTime createdAt;
  final bool isLocal;

  factory Devotional.fromJson(Map<String, dynamic> data) {
    String read(String key) => (data[key] ?? '').toString();
    return Devotional(
      id: read('id').isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : read('id'),
      theme: read('theme'),
      title: read('title'),
      verseReference: read('verse_reference'),
      reflection: read('reflection'),
      prayer: read('prayer'),
      practice: read('practice'),
      createdAt: DateTime.tryParse(read('created_at')) ?? DateTime.now(),
      isLocal: data['is_local'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'theme': theme,
        'title': title,
        'verse_reference': verseReference,
        'reflection': reflection,
        'prayer': prayer,
        'practice': practice,
        'created_at': createdAt.toUtc().toIso8601String(),
        'is_local': isLocal,
      };

  String get speechText =>
      '$title. Leitura sugerida: $verseReference. '
      'Reflexão. $reflection. Oração. $prayer. '
      'Um passo para hoje. $practice';

  String get shareText =>
      'Voz da Fé\n\n$title\n'
      'Leitura sugerida: $verseReference\n\n'
      'Reflexão\n$reflection\n\n'
      'Oração\n$prayer\n\n'
      'Para hoje\n$practice';
}
