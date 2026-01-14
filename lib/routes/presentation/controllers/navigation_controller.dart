import 'package:expiry_wise_app/routes/presentation/controllers/navigationState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../features/Profile/presentation/screens/profile_screen.dart';
import '../../../features/expenses/presentation/screens/all_expenses.dart';
import '../../../features/inventory/presentation/screens/all_items/all_items_screen.dart';
import '../../../features/home/presentation/screens/home_screen.dart';

final navigationProvider =  StateNotifierProvider.autoDispose((ref)=>NavigationController(NavigationState(0)));

class NavigationController extends StateNotifier<NavigationState> {

  static int selectedScreenIndex = 0;
 static final List<Widget> screens = [

   const HomeScreen(),
    const AllItemsScreen(),
    const AllExpenses(),
    const ProfileScreen(),
 ];

  NavigationController(super.state);

   void changeScreen(int index){
    state = NavigationState(index);

  }

  Widget  get currentScreen => screens[state.screenIndex];

}
