import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';

/// Purpose : Helper untuk parsing dan kalkulasi budget estimasi dari keterangan aktivitas.
/// Caller : SuggestionPage, AddDays
/// Dependencies : Activity model, Day model
/// Main Functions : parseBudget, calculateDayBudget, calculateTripBudget
/// Side Effects : None

class BudgetHelper {
  static final RegExp _budgetPattern =
      RegExp(r'Estimasi:\s*Rp\s*([\d.]+)');

  /// Parse angka budget dari keterangan aktivitas.
  /// Return null jika tidak ditemukan pattern "Estimasi: Rp XXX".
  static int? parseBudget(String keterangan) {
    final match = _budgetPattern.firstMatch(keterangan);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll('.', '');
    return int.tryParse(raw);
  }

  /// Hitung total budget dari semua aktivitas di satu hari.
  static int calculateDayBudget(List<Activity> activities) {
    int total = 0;
    for (final activity in activities) {
      final budget = parseBudget(activity.keterangan);
      if (budget != null) {
        total += budget;
      }
    }
    return total;
  }

  /// Hitung total budget dari semua hari dalam satu itinerary.
  static int calculateTripBudget(List<Day> days) {
    int total = 0;
    for (final day in days) {
      total += calculateDayBudget(day.activities);
    }
    return total;
  }

  /// Format angka budget ke string "Rp X.XXX.XXX".
  static String formatRupiah(int amount) {
    final raw = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = raw.length - 1; i >= 0; i--) {
      buffer.write(raw[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}
