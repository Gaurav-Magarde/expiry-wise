import 'package:cached_network_image/cached_network_image.dart';
import 'package:expiry_wise_app/features/Member/presentation/controllers/member_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/member_model.dart';

class MemberCard extends ConsumerWidget {
  const MemberCard(this.member, this.userId, {super.key});

  final MemberModel member;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String changeRoleTO = member.role == 'admin' ? 'member' : 'admin';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey.shade100,
                    child: Consumer(
                      builder: (_, ref, __) {
                        final photo = member.photo;
                        if (photo.isEmpty || !photo.startsWith('http')) {
                          return Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade400,
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          placeholder: (_, _) {
                            return const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.userId == userId ? "You" : member.name,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (member.role == 'admin')
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Admin',
                            style: Theme.of(context).textTheme.labelSmall!
                                .apply(
                                  color: EColors.primary,
                                  fontWeightDelta: 2,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
            itemBuilder: (context) => <PopupMenuItem>[
              PopupMenuItem(
                value: 'delete',
                onTap: () async {
                  final controller = ref.read(memberStateProvider.notifier);
                  await controller.removeMemberFromSpace(member: member);
                },
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    const  SizedBox(width: 12),
                    Text(
                      member.userId == userId ? "Exit Space" : "Remove User",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'changeRole',
                onTap: () async {
                  final controller = ref.read(memberStateProvider.notifier);
                  await controller.changeMemberRole(member: member);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                    const  SizedBox(width: 12),
                    Text(
                      "Make $changeRoleTO",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
