import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';


 final onBoardingPageProvider = StateNotifierProvider.autoDispose<OnBoardingController, int>((ref){
  return OnBoardingController(0);
});

class OnBoardingController extends StateNotifier<int>{

  final pageController = PageController(initialPage: 0,);

  OnBoardingController(super.state);
   @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  void pageChange(int index){
    state = index;
  }

}