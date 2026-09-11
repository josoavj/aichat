import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/providers/focus_provider.dart';

void main() {
  group('FocusProvider', () {
    late FocusProvider focusProvider;

    setUp(() {
      focusProvider = FocusProvider();
    });

    test('Initial state should be correct', () {
      expect(focusProvider.isActive, false);
      expect(focusProvider.secondsRemaining, 25 * 60);
      expect(focusProvider.completedCycles, 0);
    });

    test('startTimer should update state', () {
      focusProvider.startTimer(10);
      expect(focusProvider.isActive, true);
      expect(focusProvider.secondsRemaining, 10 * 60);
    });

    test('stopTimer should pause the timer', () {
      focusProvider.startTimer();
      focusProvider.stopTimer();
      expect(focusProvider.isActive, false);
    });

    test('resetTimer should reset to 25 minutes', () {
      focusProvider.startTimer(10);
      focusProvider.resetTimer();
      expect(focusProvider.isActive, false);
      expect(focusProvider.secondsRemaining, 25 * 60);
    });

    test('timerString should format correctly', () {
      focusProvider.startTimer(5);
      expect(focusProvider.timerString, '05:00');
    });
  });
}
