import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentSpaceProvider = AsyncNotifierProvider<CurrentSpace, SpaceModel?>(
  CurrentSpace.new,
);

class CurrentSpace extends AsyncNotifier<SpaceModel?> {
  CurrentSpace();
  @override
  Future<SpaceModel?> build() async {
    try{
      final space = await loadCurrentSpace();
      ref.watch(currentUserProvider);
      if (space == null) {
        SnackBarService.showError(
            'No Space found.Please create to store products');
        return null;
      }
      return space;
    }catch(e){
      SnackBarService.showError(
          'Something went wrong!. $e');
      return null;

    }
  }

  Future<SpaceModel?> loadCurrentSpace() async {
    try{
      final spaceController = ref.read(spaceControllerProvider.notifier);

      return await spaceController.giveDefaultSpace();
    }catch(e){
      rethrow;
    }
  }

  Future<void> changeCurrentSpace({required SpaceModel space}) async{
    try{
      final spaceRepo = ref.read(spaceRepoProvider);
      await spaceRepo.changeCurrentSpace(spaceID: space.id);
      state = AsyncData(space);
    }catch(e){
      SnackBarService.showError('Space change failed. $e');
    }
  }
}
