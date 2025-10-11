import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../All Items/screens/all_items_screen.dart';
import '../../Home/screen/home_screen.dart';

class NavigationController extends GetxController{

  RxInt selectedScreenIndex = 0.obs;

  final List<Widget> screens = [
    HomeScreen(),
    AllItemsScreen()
  ];

  void changeScreen(int index){
    if(kDebugMode) print(index);
    selectedScreenIndex.value = index;
  }
}