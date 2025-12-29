import 'package:expiry_wise_app/features/OnBoarding/presentation/controllers/on_boarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/route.dart';
import '../../../../services/local_db/prefs_service.dart';
import '../../../../core/theme/colors.dart';

class OnBoardingScreen extends ConsumerWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final notifier = ref.watch(onBoardingPageProvider.notifier);
    final selectedPage = ref.watch(onBoardingPageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height*.9,
            child: PageView(
              physics: BouncingScrollPhysics(),
              padEnds: true,
              onPageChanged: (int index) {
                notifier.pageChange(index);
              },
              controller: notifier.pageController,
              scrollBehavior: MaterialScrollBehavior(),
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Image.asset("assets/images/onboarding1.png",fit: BoxFit.fitWidth,),
                ),

                Center(
                  child: Image.asset("assets/images/on_boarding2.png",fit: BoxFit.fitWidth,),
                ),
                Center(
                  child: Image.asset("assets/images/on_boarding3.png",fit: BoxFit.cover,),
                ),
              ],
            ),
          ),

          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {

              if (selectedPage != 2) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Colors.blueGrey),
                        color: selectedPage == 0
                            ? EColors.primary
                            : Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Colors.blueGrey),
                        color: selectedPage == 1
                            ? EColors.primary
                            : Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),

                    Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Colors.blueGrey),
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              }
              return SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () async {
                    {
                      final prefs = ref.read(prefsServiceProvider);
                      await prefs.setIsFirst(true);
                      if (context.mounted) {
                        context.goNamed(MYRoute.screenRedirect);
                      }
                    }
                  },
                  child: Text("Continue"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
