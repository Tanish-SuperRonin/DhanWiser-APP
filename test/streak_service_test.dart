import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dhanwiser_fixed/services/streak_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('StreakService records check-in and tracks streak and clean ledger status', () async {
    // Initial check-in with clean balances
    final info1 = await StreakService.recordDailyCheckIn(youOwe: 0.0, owedToYou: 0.0);
    expect(info1.streakDays, 1);
    expect(info1.dailyTip, isNotEmpty);
    expect(info1.ledgerStatus, contains('Clean Ledger'));

    // Second check-in on same day preserves streak
    final info2 = await StreakService.recordDailyCheckIn(youOwe: 150.0, owedToYou: 0.0);
    expect(info2.streakDays, 1);
    expect(info2.ledgerStatus, contains('Dues Pending'));
  });

  test('StreakService handles receivables status correctly', () async {
    final info = await StreakService.recordDailyCheckIn(youOwe: 0.0, owedToYou: 250.0);
    expect(info.ledgerStatus, contains('Outstanding Receivables'));
    expect(info.dailyTip, isNotEmpty);
  });
}
