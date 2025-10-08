import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController{
  static OnBoardingController controller = Get.find<OnBoardingController>();

  RxInt selectedPage = 0.obs;
  final PageController pageController = PageController();

  void pageChanged(int val){
    try{
      selectedPage.value = val;
    }catch(e){
      if(kDebugMode) print(e.toString());
    }
  }
}