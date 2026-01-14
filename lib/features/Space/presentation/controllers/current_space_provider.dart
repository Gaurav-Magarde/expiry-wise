import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/services/Connectivity/internet_connectivity.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../User/data/models/user_model.dart';



final currentSpaceProfileProvider = StateProvider<MemberRole>((ref)=>MemberRole.member);

final currentSpaceProvider = AsyncNotifierProvider<CurrentSpace, SpaceModel?>(
  CurrentSpace.new,
);

class CurrentSpace extends AsyncNotifier<SpaceModel?> {
  CurrentSpace();

  @override
  Future<SpaceModel?> build() async {
    try {
      final userState = ref.watch(currentUserProvider);

      final space = await loadCurrentSpace();

      if (space == null) {
         return null;
      }

      if(userState.value != null) {
        await _updateRole(space, userState.value!);
      }

      return space;
    } catch (e) {
      SnackBarService.showError('Something went wrong!. $e');
      return null;
    }
  }

  Future<SpaceModel?> loadCurrentSpace() async {
    try {
      final spaceController = ref.read(spaceControllerProvider.notifier);
      return await spaceController.giveDefaultSpace();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changeCurrentSpace({required SpaceModel space}) async {
    try {
      final spaceRepo = ref.read(spaceRepoProvider);

      // 1. Repo me change karo
      await spaceRepo.changeCurrentSpace(spaceID: space.id);

      // 2. State update karo
      state = AsyncData(space);

      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        await _updateRole(space, user);
      }

    } catch (e) {
      SnackBarService.showError('Space change failed. $e');
    }
  }

  Future<void> _updateRole(SpaceModel space, UserModel user) async {
    try {
      final isInternet =  ref.read(isInternetConnectedProvider);
      MemberModel? currentMember;
      if(user.userType=='google' && isInternet){
       currentMember = await  ref.read(fireStoreServiceProvider).fetchSingleMemberFromSpace(spaceId: space.id, userId: user.id);
        print('object    ${currentMember?.role}');
      }
      else{

        currentMember = await ref.read(sqfLiteSetupProvider).fetchSingleMemberFromLocal(spaceId: space.id,userId: user.id);
      }
      final currentProfile = ref.read(currentSpaceProfileProvider.notifier);
      if(currentMember==null){
        currentProfile.state = MemberRole.member;
        return;
      }
      currentProfile.state = currentMember.role == MemberRole.admin.name ?MemberRole.admin :MemberRole.member;

    } catch (e) {
      ref.read(currentSpaceProfileProvider.notifier).state = MemberRole.member;
    }
  }
}