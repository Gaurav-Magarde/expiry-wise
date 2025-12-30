import 'package:cached_network_image/cached_network_image.dart';
import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state_controller.dart';
import 'package:expiry_wise_app/features/Profile/presentation/widgets/profileSection.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/loaders/full_screen_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../widgets/alert_box_delete_user.dart';
import '../widgets/heading_section.dart';
import '../widgets/setting_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final profileController = ref.read(profileStateProvider.notifier);
    final userController = ref.watch(currentUserProvider).value;
    final currentUserType = userController?.userType ?? '';
    final loginText = currentUserType == 'guest' ? "Login" : 'Log out';
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin:const  EdgeInsets.only(top: 50,bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.shade200,),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const  SizedBox(width: 30,),
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Consumer(
                        builder: (_, ref, __) {
                          final photo = ref.watch(
                            profileStateProvider.select((s) => s.photoUrl),
                          );
                          if (photo.isEmpty || !photo.startsWith('http')) {
                            return Icon(Icons.person, size: 50);
                          }
                          return CachedNetworkImage(
                            height: 80,
                            width: 80,
                            imageUrl: photo,
                            placeholder: (_, _) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) =>
                                Icon(Icons.person, size: 50),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 24,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Consumer(
                          builder: (_, ref, __) {
                            final name = ref.watch(
                              profileStateProvider.select((s) => s.name),
                            );
                            final mail = ref.watch(
                              profileStateProvider.select((s) => s.email),
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .apply(fontWeightDelta: 3),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const  SizedBox(height: 4),
                                Text(
                                  mail,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .apply(color: Colors.purple),
                                  overflow: TextOverflow.ellipsis,

                                ),
                                const SizedBox(height: 8,)
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1,thickness: .5,color: Colors.grey.shade500,),
            const SizedBox(height: 16,)
,
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: Column(
                children: [

                  const HeadingSection(heading: "Account Details", buttonName: ''),
                  const SizedBox(height: 8),

                  const ProfileSection(),
                  const SizedBox(height: 8),

                  Consumer(
                    builder: (context, ref, child) {
                      return const  HeadingSection(heading: "WORKSPACE", buttonName: '');
                    },
                  ),
                  const SizedBox(height: 8),

                  Container(
                    margin:const  EdgeInsets.symmetric(horizontal: 0),
                    padding:const  EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 3),
                            blurStyle: BlurStyle.outer,
                            blurRadius: 7,
                            color: Colors.grey.shade200,
                          ),
                        ],
                        border:const  Border(),
                        borderRadius: BorderRadius.circular(8),),
                    child: Column(children: [
                      Consumer(
                        builder: (context, ref, child) {
                          return SettingTile(
                            onTap: () {
                              MYRoute.appRouter.pushNamed(MYRoute.memberScreen);
                            },

                            icon: Icons.people_outline,
                            iconColor: Colors.purple.shade400,
                            backgroundColor: Colors.purple.shade100,
                            title: "Manage member",
                            subTitle: 'Manage members and friends',
                            suffixWidget: Icon(
                              Icons.chevron_right,
                                color:Colors.grey.shade700
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      SettingTile(


                        icon: Icons.person_add_alt_1,
                        iconColor: Colors.green.shade400,
                        backgroundColor: Colors.green.shade100,
                        title: "Invite Member",
                        onTap: () {
                          context.pushNamed(MYRoute.inviteMemberScreen);
                        },
                        subTitle: 'Add family member and friends',
                        suffixWidget: Icon(Icons.add, color:Colors.grey.shade700),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      SettingTile(
                        onTap: () {
                          ref.invalidate(spaceControllerProvider);
                          context.pushNamed(MYRoute.spaceScreen);
                        },


                        icon: Icons.space_dashboard_sharp,
                        iconColor: Colors.pinkAccent.shade400,
                        backgroundColor: Colors.pink.shade50,
                        title: "My Spaces",
                        subTitle: 'manage all your spaces',
                        suffixWidget: Icon(
                          Icons.chevron_right,color:Colors.grey.shade700
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      SettingTile(
                        onTap: () async {
                          context.pushNamed(MYRoute.joinSpaceScreen);
                        },


                        icon: Icons.add_circle_sharp,
                        iconColor: Colors.lightBlue.shade400,
                        backgroundColor: Colors.lightBlue.shade100,
                        title: "Join new space",
                        subTitle: 'Add more places to manage different places',
                        suffixWidget: IconButton(
                          icon: Icon(Icons.add, color:Colors.grey.shade700),
                          onPressed: () {},
                        ),
                      ),

                    ],),
                  ),
                  const  SizedBox(height: 8),

                  Consumer(
                    builder: (context, ref, child) {
                      return const HeadingSection(heading: "PREFERENCES", buttonName: '');
                    },
                  ),
                  const SizedBox(height: 8),

                  Container(
                    margin:const  EdgeInsets.symmetric(horizontal: 0),
                    padding:const  EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 3),
                            blurStyle: BlurStyle.outer,
                            blurRadius: 7,
                            color: Colors.grey.shade200,
                          ),
                        ],
                        border:const  Border(),
                        borderRadius: BorderRadius.circular(8),),
                    child: Column(children: [

                      Consumer(
                        builder: (_, ref, __) {
                          final notification = ref.watch(
                            profileStateProvider.select((s) => s.notification),
                          );
                          return SettingTile(
                            onTap: () {},


                            icon: Icons.notifications_active,
                            iconColor: Colors.cyanAccent.shade400,
                            backgroundColor: Colors.cyanAccent.shade100,
                            title: "Notification alerts",
                            subTitle: 'send me notification before expires',
                            suffixWidget: CupertinoSwitch(
                              value: notification,
                              activeTrackColor: EColors.accentPrimary,

                              onChanged: (v) async {
                                await ref
                                    .read(profileStateProvider.notifier)
                                    .changeNotificationAlert(v);
                              },
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      SettingTile(


                        icon: Icons.alarm_sharp,
                        iconColor: Colors.deepOrange.shade400,
                        backgroundColor: Colors.deepOrange.shade100,
                        onTap: () async {
                          final TimeOfDay initialTime = await profileController
                              .getNotificationTime();
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    // Clock ka background
                                    dialBackgroundColor: Colors.grey[200],
                                    // Ghadi ki sui ka color (Hand)
                                    dialHandColor: EColors.accentPrimary,

                                    // AM/PM button colors
                                    // dayPeriodTextColor: Colors.green,
                                    hourMinuteTextColor: EColors.accentPrimary,

                                    dayPeriodColor: EColors.accentPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedTime == null) return;
                          await profileController.setNotificationTime(pickedTime);
                        },

                        title: "Time",
                        subTitle: 'Select notification time ',
                        suffixWidget: Consumer(
                          builder: (_, ref, __) {
                            final time = ref.watch(
                              profileStateProvider.select(
                                    (s) => s.notificationTime,
                              ),
                            );
                            return Text(
                              time.format(context),
                              style: Theme.of(context).textTheme.titleMedium!.apply(
                                color: EColors.accentPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      Consumer(
                        builder: (_, ref, __) {
                          final autoSync = ref.watch(
                            profileStateProvider.select((S) => S.autoSync),
                          );
                          return SettingTile(
                            icon: Icons.sync_lock,
                            iconColor: Colors.yellowAccent.shade400,
                            backgroundColor: Colors.yellowAccent.shade100,
                            title: "Auto sync",
                            subTitle: 'auto sync the items',
                            suffixWidget: CupertinoSwitch(
                              value: autoSync,
                              activeTrackColor: EColors.accentPrimary,
                              onChanged: (v) async {
                                await ref
                                    .read(profileStateProvider.notifier)
                                    .changeAutoSync(v);
                              },
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(height: 1, color: Colors.grey[300]),
                      ),
                      SettingTile(
                        icon: Icons.sync,
                        iconColor: Colors.green.shade400,
                        backgroundColor: Colors.green.shade100,
                        title: "Manual Sync",
                        subTitle: 'sync products manual  ',
                        suffixWidget: TextButton(
                          onPressed: () async {
                            await profileController.manualSync();
                          },
                          child: Text(
                            "sync now",
                            style: Theme.of(context).textTheme.labelLarge!.apply(
                                color:Colors.grey.shade700
                            ),
                          ),
                        ),
                      ),
                    ],),
                  ),

                  const  SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: ElevatedButton(
                          onPressed: (){_loginButtonHelper(ref, context);},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.exit_to_app_sharp,color: Colors.white,size: 20,),
                              const SizedBox(width: 8,),
                              Text(loginText),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>const  AlertBoxDeleteUser(),
                  );
                },
                child: Text(

                  "Delete Account",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.apply(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_loginButtonHelper(WidgetRef ref,context) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.id.isEmpty) {
      SnackBarService.showError('user not found!');
      return;
    }
    if (currentUser.userType == 'google') {
  try{
      FullScreenLoader.showLoader(context, 'you logging out.please wait!');
      final controller = ref.read(profileStateProvider.notifier);
      await controller.logOutUser();
  }catch(e){
    SnackBarService.showError('logout failed!');
  }finally{
    FullScreenLoader.stopLoader(context);
  }
    } else if (currentUser.userType == 'guest') {
      try{
      final loginController = ref.read(loginStateProvider.notifier);
      await loginController.continueWithGoogle();
    }catch(e){
        SnackBarService.showError('login failed!');

      }
  }
}
