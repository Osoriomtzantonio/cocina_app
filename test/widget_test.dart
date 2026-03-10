import 'package:flutter_test/flutter_test.dart';
import 'package:cocina_app/main.dart';

void main() {
  testWidgets('CocinaApp inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const CocinaApp());
    expect(find.text('CocinaApp'), findsAny);
  });
}
