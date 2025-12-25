import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_2048_game/main.dart';
import 'package:liquid_2048_game/features/game/presentation/providers/game_provider.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({'high_score': 0});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const Liquid2048App(),
      ),
    );

    // Verify that the home screen loads with the title
    expect(find.text('LIQUID'), findsOneWidget);
    expect(find.text('2048'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
