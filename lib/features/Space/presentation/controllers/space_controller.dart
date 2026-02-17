import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/domain/space_repository_interface.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/spaceServices/space_services.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_state.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_card_model.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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

  SpaceController();

  late ISpaceRepository spaceRepository;
  late SpaceUseCases spaceServices;
  @override
  Future<SpaceState> build() async {
    final sqf = ref.read(spaceRepoProvider);
    spaceRepository = ref.watch(spaceRepoProvider);
    spaceServices = ref.watch(spaceUseCaseProvider);
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return SpaceState([]);
    final list = await sqf.fetchAllSpaces(userId: user.id);
    return SpaceState(list);
  }


  Future<bool> addNewSpace() async {
    final link = ref.keepAlive();
    try {
      final isUser = ref.read(currentUserProvider).value;
      final name  = ref.read(spaceNameProvider);
      await spaceServices.addNewSpaceUseCase(name: name,user: isUser
      );

      if (state.isLoading || state.hasError) {
        SnackBarService.showError('space created failed');
        return true;
      }
      final newSpaces = state.value?.allSpaces;
      if (newSpaces == null || !ref.mounted) {
        SnackBarService.showError('space created failed');
        return true;
      }
      ref.invalidateSelf();
      ref.invalidate(currentSpaceProvider);
      return true;
    } catch (e) {
      SnackBarService.showError('Space adding failed $e');
      return false;
    } finally {
      link.close();
    }
  }

  Future<void> deleteSpace({required String spaceId}) async {
    final link = ref.keepAlive();

    try {
      final user = ref.read(currentUserProvider).value;
      final spaceService = ref.read(spaceUseCaseProvider);

       await spaceService.deleteSpaceUseCase(spaceId: spaceId, user: user);
        ref.invalidateSelf();

    } catch (e) {
      SnackBarService.showError('Space deletion failed');
    } finally {
      link.close();
      ref.invalidate(currentSpaceProvider);
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
      final name = ref.read(spaceNameProvider);

      UserModel? user = ref.read(currentUserProvider).value;
      await ref.read(spaceUseCaseProvider).renameSpaceUseCase(space: space, user: user, newName: name);
      if (state.isLoading || state.hasError || !ref.mounted) {
        SnackBarService.showMessage('something went wrong');
        return;
      }
      ref.invalidateSelf();
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('changing space name failed.');
    }
  }

  Future<void> removeMemberFromSpace({required spaceId}) async {
    try {
      UserModel? user = ref.read(currentUserProvider).value;
     await  ref.read(spaceUseCaseProvider).exitSpaceUseCase(user: user, spaceId: spaceId);

      ref.invalidateSelf(asReload: true);
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showError('exit space failed. $e');
    }
  }
}

final spaceCardProvider = FutureProvider.family
    .autoDispose<SpaceCardModel, String>((ref, spaceId) async {
      final spaceService = ref.read(spaceUseCaseProvider);
      final spaceCard = await spaceService.getSpaceCardModel(spaceId: spaceId);
      return spaceCard;
    });

final isSpaceCreatingProvider = StateProvider<bool>((ref) => false);
final spaceNameProvider = StateProvider<String>((ref) => '');

final joinCodeTextProvider = StateProvider<String>((ref) => "");

final joinSpaceProvider = Provider((ref) {
  return JoinSpaceController(ref,);
});

/// [JOIN SPACE JoinSpaceController]
class JoinSpaceController {
  JoinSpaceController(this.ref);
  final Ref ref;
  Future<void> joinSpaceByCode() async {
    try {
      final user = ref.read(currentUserProvider).value;
      final code = ref.read(joinCodeTextProvider);
      final spaceService = ref.read(spaceUseCaseProvider);
      await spaceService.joinSpaceUseCase(
        spaceId: code,
        user: user,
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
