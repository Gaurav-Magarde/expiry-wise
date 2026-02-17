import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Member/domain/member_repository_interface.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/spaceServices/space_services.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

final memberUseCaseProvider = Provider<MemberUseCase>((ref){
  final memberRepository = ref.read(memberRepoProvider);
  final spaceUseCase = ref.read(spaceUseCaseProvider);
  return MemberUseCase(memberRepository: memberRepository, spaceUseCases: spaceUseCase);
});

class MemberUseCase {
  final IMemberRepository memberRepository;
  final SpaceUseCases spaceUseCases;

  const MemberUseCase({required this.memberRepository,required this.spaceUseCases,});

  Future<void> changeMemberRoleUseCase({
    required UserModel? user,
    required MemberRole currentMemberRole,
    required MemberModel changingMember,
    required MemberRole newRole,
  }) async {
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
    }
    if (currentMemberRole.name == MemberRole.member.name) {
      throw Exception('Only Admin can manage members');
    }
    final currMember = await memberRepository.getSpaceMemberFromLocal(userId: user.id, spaceId:  changingMember.spaceID);
    if (  currMember==null) {
      throw Exception('User not found something went wrong!');
    }
    if (  currMember.role  == MemberRole.member.name) {
      throw Exception('Only Admin can manage members');
    }
    final member = MemberModel(
      role: newRole.name,
      name: changingMember.name,
      spaceID: changingMember.spaceID,
      id: changingMember.id,
      userId: changingMember.userId,
      photo: changingMember.photo,
    );
    await memberRepository.changeMemberRoleLocal(member: member);
    if (user.userType == 'google') {
      try{
        await memberRepository.changeMemberRoleRemote(member: member);
      }catch(e){
        throw Exception('remote sync failed');
      }
    }

  }


  Future<void> removeMemberUseCase({
    required UserModel? user,
    required MemberModel member,
  }) async {
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
    }
    if( member.userId == user.id) {
      await spaceUseCases.exitSpaceUseCase(user: user, spaceId: member.spaceID);
      return;
    }
    final currMember = await memberRepository.getSpaceMemberFromLocal(userId: user.id, spaceId:  member.spaceID);
    if(currMember==null) {
      throw Exception('User not found something went wrong!');
    }
    if(currMember.role  == MemberRole.member.name) {
      throw Exception('Only Admin can manage members');
    }
    await memberRepository.removeMemberFromSpaceLocal(memberId: member.id);
    if(user.userType=='google'){
      await memberRepository.removeMemberFromSpaceRemote(member: member);
    }
  }
}
