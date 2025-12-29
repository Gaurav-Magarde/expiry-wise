import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

import '../widgets/login_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(

            child: Image.asset(
              "assets/images/login_page_img.png",
              fit: BoxFit.cover,
            ),
          ),
      SizedBox(height: 16,),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Welcome Back!",
                            style: Theme.of(context).textTheme.headlineMedium!
                                .apply(
                                  color: EColors.primaryDark,
                                  fontWeightDelta: 3,
                                ),
                          ),
                          Text(
                            'Track your expiry dates with ease',
                            style: Theme.of(context).textTheme.titleMedium!
                                .apply(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  SizedBox(height: 16),
                  LoginButtons(),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'By continuing you Agree with Terms and Conditions.Terms & condition',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.apply(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
