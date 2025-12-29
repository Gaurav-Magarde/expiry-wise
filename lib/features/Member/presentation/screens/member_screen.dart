import 'package:expiry_wise_app/features/Member/presentation/controllers/member_controller.dart';
import 'package:expiry_wise_app/features/Member/presentation/widgets/member_card.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/shimmers/members_card_shimmer.dart';

class MemberScreen extends ConsumerWidget {
  const MemberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Members")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
        child: Consumer(
          builder: (_, ref, __) {
            final list = ref.watch(memberStateProvider);
            final userId = ref
                .read(currentUserProvider)
                .when(
                  data: (data) {
                    return data == null ? '' : data.id;
                  },
                  error: (e, s) {
                    return '';
                  },
                  loading: () {
                    return '';
                  },
                );
            return list.when(
              data: (data) {
                if (data.member.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/img_6.png'),
                        SizedBox(height: 16),
                        Text(
                          "No Members added yet!",
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                            color: EColors.primaryDark,
                            fontWeightDelta: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start invite members and collaborating.",
                          style: Theme.of(context).textTheme.titleSmall!.apply(
                            color: EColors.primaryDark,
                            fontWeightDelta: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: data.member.length,
                  separatorBuilder: (_, __) {
                    return SizedBox(height: 4);
                  },
                  itemBuilder: (context, index) {
                    final mem = data.member[index];

                    return MemberCard(mem, userId);
                  },
                );
              },
              error: (e, s) => Text("Error"),
              loading: () => MembersCardShimmer(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EColors.primary,
        child: Icon(Icons.person_add_rounded, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
