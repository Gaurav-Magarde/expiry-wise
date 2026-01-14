import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_state.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_card_model.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../../Member/data/models/member_model.dart';
import '../../../User/data/models/user_model.dart';
import '../../../User/presentation/controllers/user_controller.dart';
import '../../data/model/space_model.dart';

final spaceControllerProvider =
    AsyncNotifierProvider.autoDispose<SpaceController, SpaceState>(
      SpaceController.new,
    );

class SpaceController extends AsyncNotifier<SpaceState> {
  @override
  Future<SpaceState> build() async {
    final sqf = ref.read(spaceRepoProvider);
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return SpaceState([]);
    final list = await sqf.fetchAllSpaces(userId: user.id);
    return SpaceState(list);
  }

  Future<SpaceModel?> giveDefaultSpace() async {
    final link = ref.keepAlive();
    try {
      final prefs = ref.read(prefsServiceProvider);
      final spaceId = await prefs.getString("current_space");
      final user = await ref.read(currentUserProvider.future);
      if (user == null || user.id.isEmpty) return null;
      final sqf = ref.read(sqfLiteSetupProvider);

      if (spaceId != null) {
        final space = await sqf.findSpace(userId: user.id, spaceId: spaceId);
        if (space != null) {
          return space;
        }
      }
      final space = await sqf.findFirstSpace(userId: user.id);
      if (space != null) {
        prefs.changeCurrentSpace(space.id);
        return space;
      }
      return null;
    } catch (e) {
      rethrow;
    } finally {
      link.close();
    }
  }

  Future<bool> addNewSpace() async {
    final link = ref.keepAlive();
    try {
      final spaceRepo = ref.read(spaceRepoProvider);
      final name = ref.read(spaceNameProvider);
      if (name.trim().isEmpty) {
        SnackBarService.showError('Enter space name');
        return false;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      final isUser = ref.read(currentUserProvider).value;
      if (isUser == null || isUser.id.isEmpty) {
        SnackBarService.showError(
          'something went wrong please try again later',
        );
        return true;
      }
      final newSpace = await spaceRepo.createSpace(
        user: isUser,
        spaceName: name,
        isInternet: isInternet,
        isUser: isUser.id,
      );
      if (newSpace == null) {
        SnackBarService.showError('space created failed');
        return true;
      }
      if (state.isLoading || state.hasError) {
        SnackBarService.showError('space created failed');
        return true;
      }

      final newSpaces = state.value?.allSpaces;
      if (newSpaces == null || !ref.mounted) {
        SnackBarService.showError('space created failed');
        return true;
      }
      newSpaces.add(newSpace);
      state = AsyncData(SpaceState.copyWith(allSpaces: newSpaces));
      SnackBarService.showSuccess('Space $name successfully added');
      ref.invalidate(currentSpaceProvider);
      return true;
    } catch (e) {
      SnackBarService.showError('Space adding failed $e');
    } finally {
      link.close();
    }
    return true;
  }

  Future<void> deleteSpace({required String spaceId}) async {
    final link = ref.keepAlive();

    try {
      final user = ref.read(currentUserProvider).value;
      final spaceRepo = ref.read(spaceRepoProvider);
      final isInternet = ref.read(isInternetConnectedProvider);

      if (user == null || user.id.isEmpty) {
        SnackBarService.showError('user not found');
        return;
      }
      final isDeleted = await spaceRepo.deleteSpace(
        userId: user.id,
        spaceId: spaceId,
        isInternet: isInternet,
        user: user,
      );

      if (isDeleted == 1) {
        if (state.value == null) return;
        final newList = state.value!.allSpaces
            .where((s) => s.id != spaceId)
            .toList();
        if (!ref.mounted) return;

        state = AsyncData(SpaceState.copyWith(allSpaces: newList));
      }
    } catch (e) {
      SnackBarService.showError('Space deletion failed');
    } finally {
      link.close();
      ref.invalidate(currentSpaceProvider);
    }
  }

  Future<bool> canSpaceDeleted({required String spaceId}) async {
    try {
      final spaceRepo = ref.read(currentSpaceProvider).value;
      if (spaceRepo == null) {
        SnackBarService.showError('No space found');
        return false;
      }
      if (spaceRepo.id == spaceId) {
        SnackBarService.showMessage('Default space cannot be deleted');

        return false;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if (!isInternet) {
        SnackBarService.showMessage('check your internet connection');
        return false;
      }
      final user = ref.read(currentUserProvider).value;

      if (user == null) {
        SnackBarService.showError('user not found.please try again later');
        return false;
      }
      MemberModel? member = await ref
          .read(fireStoreServiceProvider)
          .fetchSingleMemberFromSpace(spaceId: spaceId, userId: user.id);
      if (member == null) {
        SnackBarService.showError('user not found.please try again later');
        return false;
      }
      if (member.role == MemberRole.member.name) {
        SnackBarService.showMessage('only admin can delete space');
        return false;
      }
      return true;
    } catch (e) {
      throw " ";
    }
  }

  Future<void> changeSpace({required SpaceModel space}) async {
    try {
      final currSpace = ref.read(currentSpaceProvider.notifier);
      await currSpace.changeCurrentSpace(space: space);
    } catch (e) {
      SnackBarService.showMessage('change space failed');
    }
  }

  Future<void> changeSpaceName({required SpaceModel space}) async {
    try {
      final spaceRepo = ref.read(spaceRepoProvider);
      final name = ref.read(spaceNameProvider);
      if (name.trim().isEmpty) {
        SnackBarService.showError('Enter space name');
        return;
      }
      bool isInternet = ref.read(isInternetConnectedProvider);
      UserModel? user = ref.read(currentUserProvider).value;
      if (user == null || user.id.isEmpty) {
        SnackBarService.showError("No user found");
        return;
      }
      MemberModel? member = await ref
          .read(fireStoreServiceProvider)
          .fetchSingleMemberFromSpace(spaceId: space.id, userId: user.id);
      if (member == null) {
        SnackBarService.showError('user not found.please try again later');
        return;
      }
      if (member.role == MemberRole.member.name) {
        SnackBarService.showMessage('only admin can Edit space');
        return;
      }
      await spaceRepo.changeSpaceName(
        spaceId: space.id,
        newName: name,
        isInternet: isInternet,
        user: user,
      );
      if (state.isLoading || state.hasError || !ref.mounted) {
        SnackBarService.showMessage("something went wrong");
        return;
      }
      final newSpaces = state.value!.allSpaces;
      final list = newSpaces.map((curr) {
        if (curr.id == space.id) {
          final sp = SpaceModel(
            userId: curr.userId,
            name: name,
            id: curr.id,
            updatedAt: DateTime.now().toString(),
          );
          return sp;
        }
        SnackBarService.showMessage('space name changed');
        return curr;
      }).toList();
      state = AsyncData(SpaceState.copyWith(allSpaces: list));
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('changing space name failed.');
    }
  }

  Future<void> removeMemberFromSpace({required spaceId}) async {
    try {
      bool isInternet = ref.read(isInternetConnectedProvider);
      UserModel? user = ref.read(currentUserProvider).value;
      if (user == null || user.id.isEmpty) {
        SnackBarService.showError("No user found");
        return;
      }
      final currUserId = user.id;
      final members = await ref
          .read(sqfLiteSetupProvider)
          .fetchMemberFromLocal(spaceId: spaceId);
      MemberModel? currMember;
      for (final mem in members) {
        if (mem.userId == currUserId) {
          currMember = mem;
          break;
        }
      }
      if (currMember == null) {
        SnackBarService.showError('No user found');
        return;
      }
      final memberRepo = ref.read(memberRepoProvider);
      await memberRepo.removeMemberFromSpace(
        member: currMember,
        isInternet: isInternet,
        user: user,
      );
      if (!ref.mounted) return;

      ref.invalidateSelf(asReload: true);
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('exit space failed. $e');
    }
  }
}

final spaceCardProvider = FutureProvider.family
    .autoDispose<SpaceCardModel, String>((ref, spaceId) async {
      final sqf = ref.read(sqfLiteSetupProvider);
      final members = await sqf.fetchMemberBySpace(spaceId: spaceId);
      return members;
    });

final isSpaceCreatingProvider = StateProvider<bool>((ref) => false);
final spaceNameProvider = StateProvider<String>((ref) => '');

final joinCodeTextProvider = StateProvider<String>((ref) => "");

final joinSpaceProvider = Provider((ref) {
  final spaceRepo = ref.read(spaceRepoProvider);
  return JoinSpaceController(ref, spaceRepo);
});

/// [JOIN SPACE JoinSpaceController]
class JoinSpaceController {
  JoinSpaceController(this.ref, this._spaceRepository);
  final SpaceRepository _spaceRepository;
  final Ref ref;
  Future<void> joinSpaceByCode() async {
    try {
      final user = ref.read(currentUserProvider).value;
      final code = ref.read(joinCodeTextProvider);
      if (user == null) {
        SnackBarService.showMessage('user not found');
        return;
      }
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final userId = firebaseUser?.uid;
      final isInternet = ref.read(isInternetConnectedProvider);

      if (userId == null || user.userType == 'guest') {
        SnackBarService.showMessage('Please login first to join new spaces');
        return;
      }
      final member = MemberModel(
        photo: user.photoUrl,
        name: user.name,
        spaceID: code,
        id: Uuid().v4(),
        userId: user.id,
        role: MemberRole.member.name,
      );
      await _spaceRepository.joinNewSpace(
        member: member,
        isInternet: isInternet,
        isUser: user,
      );
    } catch (e) {
      SnackBarService.showError('Space join failed $e');
    }
  }
}

final addNewSpaceLoadingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);
final defaultSpaceLoadingProvider = StateProvider<bool>((ref) => false);
final isSpaceJoining = StateProvider.autoDispose<bool>((ref) => false);
