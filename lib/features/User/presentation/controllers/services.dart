import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Member/domain/member_repository_interface.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/Space/domain/space_repository_interface.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/domain/expense_repository_interface.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/features/quick_list/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/domain/quick_list_repo_interface.dart';
import 'package:expiry_wise_app/services/local_db/local_transaction_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../Member/data/models/member_model.dart';
import '../../../Space/data/model/space_model.dart';
import '../../../Space/presentation/controllers/spaceServices/space_services.dart';
import '../../../inventory/domain/item_model.dart';
import '../../data/models/user_model.dart';

final userServiceProvider = Provider((ref) {
  final spaceRepository = ref.read(spaceRepoProvider);
  final userRepository = ref.read(userRepoProvider);
  final spaceService = ref.read(spaceUseCaseProvider);
  return UserServices(
    spaceService: spaceService,
    spaceRepository: spaceRepository,
    userRepository: userRepository,
  );
});

class UserServices {
  UserServices({
    required this.spaceService,
    required this.userRepository,
    required this.spaceRepository,
  });
  final IUserRepository userRepository;
  final ISpaceRepository spaceRepository;
  final SpaceUseCases spaceService;

  Future<UserModel?> loadUserOnLogin(String id, String email) async {
    try {
      final user = await userRepository.getUserDetailRemote(id: id);
      if (user == null) {
        return null;
      }
      List<String> spaceIds = await userRepository.fetchSpacesFromUserRemote(
        id,
      );
      List<SpaceModel> spaces = await spaceRepository.getSpacesRemote(
        spaceId: spaceIds,
      );
      await userRepository.saveUserLocally(user: user);
      for (var space in spaces) {
        await spaceService.loadSpaceFromRemoteUseCase(space: space);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw const TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<void> changeName({
    required String newName,
    required UserModel? user,
  }) async {
    try {
      if (newName.trim().isEmpty) {
        throw Exception('invalid user name');
      }
      if (user == null || user.id.isEmpty) {
        throw Exception('user not found');
      }
      Map<String, dynamic> map = {'name': newName};
      await userRepository.updateUserLocal(map, user.id);
      if (user.userType == 'google') {
        final newUser = UserModel(
          photoUrl: user.photoUrl,
          userType: user.userType,
          name: newName,
          email: user.email,
          updatedAt: user.updatedAt,
          id: user.id,
        );
        await userRepository.saveUserToRemote(user: newUser);
      }
    } catch (e) {
      throw Exception('Name changed failed .${e.toString()}');
    }
  }
}
