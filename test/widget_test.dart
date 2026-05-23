import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planora/app/app.dart';

void main() {
  testWidgets('App shell loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PlanoraApp()));
    
    expect(find.byType(PlanoraApp), findsOneWidget);
  });
}
