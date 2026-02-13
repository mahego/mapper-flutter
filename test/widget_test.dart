import 'package:flutter_test/flutter_test.dart';
import 'package:mapper/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MapperApp());
    expect(find.text('Mapper'), findsOneWidget);
  });
}
