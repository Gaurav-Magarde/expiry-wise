import 'package:expiry_wise_app/features/OnBoarding/controllers/on_boarding_controller.dart';
import 'package:expiry_wise_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            SizedBox(
              height: 600,

              child: PageView(
                physics: BouncingScrollPhysics(),
                padEnds: true,
                onPageChanged:
                  controller.pageChanged
               ,
                controller: controller.pageController,
                scrollBehavior: MaterialScrollBehavior(),
                scrollDirection: Axis.horizontal,
                children: [
                  Center(child: Image.asset("assets/OnBoarding/onBoarding1.png")),

                  Center(child: Image.asset("assets/OnBoarding/onBoarding2.png")),
                  Center(child: Image.asset("assets/OnBoarding/onBoarding3.png")),
                ],
              ),
            ),
            Obx(
              () {
                if(controller.selectedPage.value!=2){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2,color: Colors.blueGrey),
                            color: controller.selectedPage.value==0 ? EColors.primary : Colors.white
                        ),
                      ),
                      SizedBox(width: 16,),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2,color: Colors.blueGrey),
                            color: controller.selectedPage.value==1 ? EColors.primary : Colors.white
                        ),
                      ),
                      SizedBox(width: 16,),

                       Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2,color: Colors.blueGrey),
                            color:  Colors.white
                        ),
                                           )
                    ],
                  );
                }
                return ElevatedButton(onPressed: (){}, child: Text("data"));
              }
            )
          ],
        ),
      ),
    );
  }
}
