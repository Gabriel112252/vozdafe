import 'package:flutter_test/flutter_test.dart';
import 'package:vozdafe/models/devotional.dart';
import 'package:vozdafe/services/devotional_service.dart';

void main() {
  test('seleciona o tema ansiedade', () {
    final result = LocalDevotionalGenerator.generate(
      'Hoje estou ansioso e preocupado',
    );
    expect(result.theme, 'ansiedade');
    expect(result.verseReference, 'Filipenses 4:6-7');
    expect(result.isLocal, isTrue);
  });

  test('seleciona tema de gratidão com acentos', () {
    final result = LocalDevotionalGenerator.generate(
      'Tenho muita gratidão pelas conquistas',
    );
    expect(result.theme, 'gratidao');
  });

  test('pode salvar e recuperar uma reflexão via JSON', () {
    final result = LocalDevotionalGenerator.generate('Estou triste');
    final decoded = Devotional.fromJson(result.toJson());
    expect(decoded.id, result.id);
    expect(decoded.prayer, result.prayer);
    expect(decoded.isLocal, isTrue);
  });

  test('tema neutro usa esperança', () {
    final result = LocalDevotionalGenerator.generate('Estou aqui hoje');
    expect(result.theme, 'esperanca');
  });
}
