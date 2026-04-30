import 'package:flutter_test/flutter_test.dart';
import 'package:beam_reserve/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BeamReserveApp());
    expect(find.byType(BeamReserveApp), findsOneWidget);
  });
}
