import 'dart:async';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Member/domain/member_repository_interface.dart';
import 'package:expiry_wise_app/features/Member/presentation/controllers/services/member_usecases.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final memberStateProvider = AsyncNotifierProvider(() {
  return MemberController();
});

class MemberController extends AsyncNotifier<MemberState> {
  late IMemberRepository _memberRepo;

  @override
  Future<MemberState> build() async {
    _memberRepo = ref.read(memberRepoProvider);
    final curr = await ref.watch(currentSpaceProvider.future);
    if (curr == null) {
      return MemberState([]);
    }
    final currentSpaceId = curr.id;
    final list = await _memberRepo.fetchAllMemberRemote(
      spaceId: currentSpaceId,
    );
    return MemberState(list);
  }

  /// Remove member from space
  Future<void> removeMemberFromSpace({required MemberModel member}) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      final user = ref.read(currentUserProvider).value;
      await ref
          .read(memberUseCaseProvider)
          .removeMemberUseCase(
            user: user,
            member: member,
          );
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('Removing member failed $e');
    }
  }


  Future<void> changeMemberRole({required MemberModel member}) async {
    try {
      final currentState = state.value;
      if (currentState == null) return;
      final currentMemberRole = ref.read(currentSpaceProfileProvider);
      final user = ref.read(currentUserProvider).value;
      final newRole = member.role != MemberRole.member.name
          ? MemberRole.member
          : MemberRole.admin;
      await ref
          .read(memberUseCaseProvider)
          .changeMemberRoleUseCase(
            user: user,
            currentMemberRole: currentMemberRole,
            changingMember: member,
            newRole: newRole,
          );
      ref.invalidateSelf();
      ref.invalidate(currentSpaceProvider);
      ref.invalidate(currentSpaceProfileProvider);
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
