import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../../../inventory/domain/item_model.dart';

// ️ Helper: Crash Proof Date Parser
DateTime _safeParse(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return DateTime(2099); // Future date fallback
  return DateFormat(DateFormatPattern.dateformatPattern).tryParse(dateStr) ?? DateTime(2099);
}

// Helper: Get Midnight Time
DateTime _getMidnight(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

final recentlyItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final allItemsAsync = ref.watch(itemsStreamProvider);

  return allItemsAsync.whenData((list) {
    // 1. Filter: Not Finished & Not Deleted
    final recent = list.where((item) => item.finished == 0 ).toList();

    // 2. Sort: Newest First (Desc)
    recent.sort((a, b) {
      final dateA = _safeParse(a.addedDate);
      final dateB = _safeParse(b.addedDate);
      return dateB.compareTo(dateA);
    });

    return recent.take(10).toList();
  });
});

final expiredItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final allItemsAsync = ref.watch(itemsStreamProvider);

  return allItemsAsync.whenData((list) {
    final today = _getMidnight(DateTime.now());

    final expired = list.where((item) {
      if (item.finished != 0 || item.expiryDate == null) return false;

      final expiryDate = _safeParse(item.expiryDate);

      return expiryDate.isBefore(today);
    }).toList();

    expired.sort((a, b) {
      final dateA = _safeParse(a.expiryDate);
      final dateB = _safeParse(b.expiryDate);
      return dateA.compareTo(dateB);
    });

    return expired;
  });
});

final expiringSoonItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final allItemsAsync = ref.watch(itemsStreamProvider);

  return allItemsAsync.whenData((list) {
    final today = _getMidnight(DateTime.now());
    final next7Days = today.add(const Duration(days: 7));

    final expiring = list.where((item) {
      if (item.finished != 0 ||  item.expiryDate == null) return false;

      final expiryDate = _safeParse(item.expiryDate);

      return !expiryDate.isBefore(today) && expiryDate.isBefore(next7Days);
    }).toList();

    expiring.sort((a, b) {
      final dateA = _safeParse(a.expiryDate);
      final dateB = _safeParse(b.expiryDate);
      return dateA.compareTo(dateB);
    });

    return expiring;
  });
});

final selectedContainerProvider = StateProvider<SelectedContainer>((ref) => SelectedContainer.expired);
final micSpeechProvider = StateProvider<String?>((ref) => null);

enum SelectedContainer {
  expired,
  expiring,
  recent
}