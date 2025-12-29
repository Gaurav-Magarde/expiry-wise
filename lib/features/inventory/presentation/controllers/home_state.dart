import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';

import '../../data/models/item_model.dart';

class HomeState {
  HomeState( {
    required this.name,
    this.isRecentLoading = false,
    this.isExpiringLoading = false,
    required this.recentlyAdded,
    required this.expiringSoon,

  });

  final List<ItemModel> recentlyAdded;
  final List<ItemModel> expiringSoon;
  final String name;
  final bool isRecentLoading;
  final bool isExpiringLoading;

  copyWith({
    bool? isSpaceLoading,
    String? name,
    bool? isRecentLoading,
    bool? isExpiringLoading,
    List<ItemModel>? recentlyAdded,
    List<ItemModel>? expiringSoon,
    List<SpaceModel>? allSpaces
  }) {
    return HomeState(
      isExpiringLoading: isExpiringLoading??this.isExpiringLoading,
      isRecentLoading: isRecentLoading??this.isRecentLoading,
      name: name ?? this.name,
      recentlyAdded: recentlyAdded ?? this.recentlyAdded,
      expiringSoon: expiringSoon ?? this.expiringSoon,
    );
  }
}
