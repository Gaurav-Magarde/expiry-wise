
import 'package:expiry_wise_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/loaders/full_screen_loader.dart';


class LoginButtons extends ConsumerWidget {
  const LoginButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final controller = ref.watch(authControllerProvider.notifier);
    ref.watch(isLoginProvider.notifier);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: EColors.primaryDark),

          onPressed: () async {
            final isLoginController = ref.read(isLoginProvider.notifier);
            if(isLoginController.state) return;
            FullScreenLoader.showLoader(context, '');
            try{
              isLoginController.state = true;
              await controller.continueWithGoogle();
            }catch(e){
              SnackBarService.showError('google login failed');
            }finally{
              if(context.mounted) FullScreenLoader.stopLoader(context);
              isLoginController.state = false;
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 16,backgroundColor: Colors.white, child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset("assets/images/googleImg.png",),
              )),

              const Expanded(
                child: Text(
                  "Continue with Google",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const  Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal:  8.0),
              child: Text("OR"),
            ),
            Expanded(child: Divider())
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: EColors.primary),
          onPressed: () async {
            final isLoginController = ref.read(isLoginProvider.notifier);
            if(isLoginController.state) return;
            try{
              isLoginController.state = true;
              await controller.continueAsGuest();
            }catch(e){
              SnackBarService.showError("google login failed");
            }finally{
              isLoginController.state = false;
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            CircleAvatar(radius: 16,backgroundColor: EColors.primary,child: Padding(
              padding: const EdgeInsets.all(4.0),
              child:Image.asset("assets/images/guestImg.png"))),

              Expanded(
                child: Text(
                  "Continue As guest",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
