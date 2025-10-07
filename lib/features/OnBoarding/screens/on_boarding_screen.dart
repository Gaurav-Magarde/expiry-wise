import 'package:flutter/material.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: PageController(initialPage: 0,),
        scrollBehavior: MaterialScrollBehavior(),
        scrollDirection: Axis.horizontal,
        children: [
          Center(child: Image.asset("assets/OnBoarding/onBoarding1.png")),

          Center(child: Image.asset("assets/OnBoarding/onBoarding2.png")),
          Center(child: Image.asset("assets/OnBoarding/onBoarding3.png")),
        ],
      ),
    );
  }
}
