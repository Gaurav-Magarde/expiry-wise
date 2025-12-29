import 'package:expiry_wise_app/routes/presentation/controllers/navigationState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../features/Profile/presentation/screens/profile_screen.dart';
import '../../../features/inventory/presentation/screens/all_items_screen.dart';
import '../../../features/inventory/presentation/screens/home_screen.dart';

final navigationProvider =  StateNotifierProvider.autoDispose((ref)=>NavigationController(NavigationState(0)));

class NavigationController extends StateNotifier<NavigationState> {

  static int selectedScreenIndex = 0;
 static final List<Widget> screens = [

   HomeScreen(),
    AllItemsScreen(),
    ProfileScreen()
 ];

  NavigationController(super.state);

   void changeScreen(int index){
    state = NavigationState(index);

  }

  Widget  get currentScreen => screens[state.screenIndex];

}
