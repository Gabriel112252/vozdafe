import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vozdafe/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mostra a tela inicial', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VozDaFeApp());
    await tester.pump();
    expect(find.text('Voz da Fé'), findsOneWidget);
    expect(find.text('Como está seu coração?'), findsOneWidget);
  });
}
