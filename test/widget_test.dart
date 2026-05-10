import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:beam_reserve/main.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-key',
    );
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const BeamReserveApp());
    await tester.pump();
    expect(find.byType(BeamReserveApp), findsOneWidget);
  });
}
