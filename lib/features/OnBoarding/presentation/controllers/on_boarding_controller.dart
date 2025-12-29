import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';


 final onBoardingPageProvider = StateNotifierProvider<OnBoardingController, int>((ref){
  return OnBoardingController(0);
});

class OnBoardingController extends StateNotifier<int>{

  final pageController = PageController(initialPage: 0,);

  OnBoardingController(super.state);

  void pageChange(int index){
    state = index;
  }

}