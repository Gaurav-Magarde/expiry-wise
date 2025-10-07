import 'package:expiry_wise_app/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:expiry_wise_app/utils/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../utils/constants/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100]  ,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
          
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200,width: double.infinity,  child: Image.asset("assets/logo/appLogo.png")),
              SizedBox(height: 16),
          
              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormFieldWidget(prefixIcon: Icon(LucideIcons.mail), hint: "Email"),
                    SizedBox(height: 16),
                    TextFormFieldWidget(
                      prefixIcon: Icon(LucideIcons.lock)  ,
                      hint: "Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                    SizedBox(height: 16),
                    TextFormFieldWidget(
                      prefixIcon: Icon(LucideIcons.shieldCheck) ,
                      hint: "confirm Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
          
                      style: ElevatedButton.styleFrom(),
                      child: Text("Sign Up",style: Theme.of(context).textTheme.titleLarge!.apply(color: Colors.white),),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.blueGrey, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "OR",
                            style: Theme.of(context).textTheme.titleMedium!
                                .apply(color: Colors.blueGrey),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            height: 2,
                            color: Colors.blueGrey,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16,),
              OutlinedButton(
          
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(width: 4,color: Colors.blueGrey),
                    ),
                    backgroundColor: Colors.white
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology_outlined),
                    SizedBox(width: 8,height: 48,),
                    Text("Continue with Google",style: Theme.of(context).textTheme.titleMedium,),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Row(children: [
                Text("Already have an account?",style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.grey),maxLines: 1,),
                TextButton(onPressed: (){
                  Get.off(()=>SignUpScreen());
                },style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 0)), child: Text("Log in",style: Theme.of(context).textTheme.titleMedium!.apply(color: EColors.primary)),)
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
