class StreakCalculationResult {
  const StreakCalculationResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletedDays,
    required this.lastCompletedDate,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCompletedDays;
  final String? lastCompletedDate; // YYYY-MM-DD
}

class StreakEngine {
  /// Parses YYYY-MM-DD into DateTime
  static DateTime parseLocalDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Formats DateTime as YYYY-MM-DD
  static String formatLocalDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Calculates days difference between two dates (ignoring time)
  static int daysBetween(DateTime a, DateTime b) {
    final dateA = DateTime(a.year, a.month, a.day);
    final dateB = DateTime(b.year, b.month, b.day);
    return dateB.difference(dateA).inDays;
  }

  /// Computes streak state from a list of completed dates (unique YYYY-MM-DD)
  /// as of a referenceDate (defaults to today)
  static StreakCalculationResult computeStreak({
    required List<String> completedDates,
    DateTime? referenceDate,
  }) {
    if (completedDates.isEmpty) {
      return const StreakCalculationResult(
        currentStreak: 0,
        longestStreak: 0,
        totalCompletedDays: 0,
        lastCompletedDate: null,
      );
    }

    // Sort unique dates ascending
    final sortedUniqueDates = completedDates.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    int longestStreak = 0;
    int rollingStreak = 0;
    DateTime? prevDate;

    for (final dateStr in sortedUniqueDates) {
      final curDate = parseLocalDate(dateStr);
      if (prevDate == null) {
        rollingStreak = 1;
      } else {
        final diff = daysBetween(prevDate, curDate);
        if (diff == 1) {
          rollingStreak++;
        } else if (diff > 1) {
          rollingStreak = 1;
        }
        // diff == 0 shouldn't happen because we called toSet()
      }
      if (rollingStreak > longestStreak) {
        longestStreak = rollingStreak;
      }
      prevDate = curDate;
    }

    // Now determine current active streak relative to referenceDate
    final ref = referenceDate ?? DateTime.now();
    final lastCompletedStr = sortedUniqueDates.last;
    final lastCompletedDate = parseLocalDate(lastCompletedStr);
    final diffFromRef = daysBetween(lastCompletedDate, ref);

    int currentStreak = 0;
    if (diffFromRef == 0 || diffFromRef == 1) {
      // Completed today or yesterday => streak is still alive
      // Count backwards from lastCompletedDate
      currentStreak = 1;
      for (int i = sortedUniqueDates.length - 1; i > 0; i--) {
        final curr = parseLocalDate(sortedUniqueDates[i]);
        final prev = parseLocalDate(sortedUniqueDates[i - 1]);
        if (daysBetween(prev, curr) == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    } else {
      // More than 1 full calendar day passed without qualifying completion => streak reset to 0
      currentStreak = 0;
    }

    return StreakCalculationResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompletedDays: sortedUniqueDates.length,
      lastCompletedDate: lastCompletedStr,
    );
  }
}
