import 'dart:async';

import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';

final memberStateProvider = AsyncNotifierProvider(() {
  return MemberController();
});

class MemberController extends AsyncNotifier<MemberState> {
  late MemberRepository _memberRepo;
  late AsyncValue _currentSpace;

  @override
  Future<MemberState> build() async {
    _memberRepo = ref.read(memberRepoProvider);
    final curr = await ref.watch(currentSpaceProvider.future);
    if (curr == null) {
      SnackBarService.showError('No space found');
      return MemberState([]);
    }
    final currentSpaceId = curr.id;
    final list = await _memberRepo.fetchAllMemberOfSpace(
      spaceId: currentSpaceId,
    );
    return MemberState(list);
  }

  /// Remove member from space
  Future<void> removeMemberFromSpace({required MemberModel member}) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      final isInternet = ref.read(isInternetConnectedProvider);
      final user = ref.read(currentUserProvider).value;
      if (user == null || user.id.isEmpty) {
        SnackBarService.showError('user not found');
        return;
      }
      if (member.role == MemberRole.member.name && member.userId != user.id) {
        SnackBarService.showMessage('Only Admin can manage members');
        return;
      }
      if (!isInternet && user.userType == 'google') {
        SnackBarService.showError(
          'removing member failed.please check internet connection',
        );
        return;
      }
      await _memberRepo.removeMemberFromSpace(
        member: member,
        isInternet: isInternet,
        user: user,
      );

      final updatedList = currentState.member
          .where((mem) => mem.id != member.id)
          .toList();
      state = AsyncData(currentState.copyWith(member: updatedList));
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('Removing member failed $e');
    }
  }

  Future<void> changeMemberRole({required MemberModel member}) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      final isInternet = ref.read(isInternetConnectedProvider);
      final user = ref.read(currentUserProvider).value;
      if (user == null || user.id.isEmpty) {
        SnackBarService.showError('user not found');
        return;
      }
      if (member.role == MemberRole.member.name) {
        SnackBarService.showMessage('Only Admin can manage members');
        return;
      }
      await _memberRepo.changeMemberRole(
        member: member,
        isInternet: isInternet,
        user: user,
      );

      ref.invalidateSelf();
    } catch (e) {
      SnackBarService.showError('change role of ${member.name} failed $e');
    }
  }
}

class MemberState {
  final List<MemberModel> member;

  MemberState(this.member);

  MemberState copyWith({required List<MemberModel> member}) {
    return MemberState(member);
  }
}
