import 'package:shared_preferences/shared_preferences.dart';

class DailyStreakInfo {
  final int streakDays;
  final bool checkedInToday;
  final String dailyTip;
  final String ledgerStatus;

  const DailyStreakInfo({
    required this.streakDays,
    required this.checkedInToday,
    required this.dailyTip,
    required this.ledgerStatus,
  });
}

class StreakService {
  static const String _keyLastCheckInDate = 'dhanwiser_last_checkin_date';
  static const String _keyStreakCount = 'dhanwiser_streak_count';

  static const List<String> _dailyTips = [
    '💡 Clean Ledger Rule: Settling group dues within 24 hours maintains a 100% Swift Settler status.',
    '⚡ Zero UPI Fees: DhanWiser direct UPI settlements incur ₹0 gateway fees with instant confirmation.',
    '🧾 Photo Receipts: Attaching proof pictures speeds up group settlement approvals by over 80%.',
    '📊 Split Precision: Custom percentages prevent disputes for shared groceries and travel costs.',
    '🤝 Circle Transparency: Keeping active groups updated ensures no friend is left carrying debts.',
    '🔒 Smart Verification: Always confirm receipt in the Activity tab before marking tabs as cleared.',
    '🎯 Group Milestones: Unlock the "Zero Balance Guardian" badge by keeping dues clear for 30 days.',
  ];

  static Future<DailyStreakInfo> recordDailyCheckIn({
    required double youOwe,
    required double owedToYou,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final lastDateStr = prefs.getString(_keyLastCheckInDate);
    int currentStreak = prefs.getInt(_keyStreakCount) ?? 0;
    bool isNewToday = false;

    if (lastDateStr == null) {
      currentStreak = 1;
      isNewToday = true;
      await prefs.setString(_keyLastCheckInDate, todayStr);
      await prefs.setInt(_keyStreakCount, currentStreak);
    } else if (lastDateStr != todayStr) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null) {
        final differenceInDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;

        if (differenceInDays == 1) {
          currentStreak += 1;
        } else if (differenceInDays > 1) {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }
      isNewToday = true;
      await prefs.setString(_keyLastCheckInDate, todayStr);
      await prefs.setInt(_keyStreakCount, currentStreak);
    }

    // Pick tip based on day of year
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tip = _dailyTips[dayOfYear % _dailyTips.length];

    String statusText;
    if (youOwe < 0.01 && owedToYou < 0.01) {
      statusText = '✨ Clean Ledger • All balances perfectly square';
    } else if (youOwe > 0.01) {
      statusText = '⚡ Dues Pending • Review & settle with 1 tap';
    } else {
      statusText = '💰 Outstanding Receivables • Friends owe you';
    }

    return DailyStreakInfo(
      streakDays: currentStreak < 1 ? 1 : currentStreak,
      checkedInToday: isNewToday,
      dailyTip: tip,
      ledgerStatus: statusText,
    );
  }
}
