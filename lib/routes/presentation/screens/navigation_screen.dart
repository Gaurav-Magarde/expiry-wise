import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart'; // GNav Import jaruri hai

import '../controllers/navigation_controller.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    final navigationController = ref.read(navigationProvider.notifier);

    return PopScope(
      canPop: navigationState.screenIndex == 0,
      onPopInvokedWithResult: (m,n) async {
        if (navigationState.screenIndex != 0) {
          navigationController.changeScreen(0);
        }

      },
      child: Scaffold(
        body: navigationController.currentScreen,

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.grey.shade100,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8, // Icon aur Text ke beech gap
              activeColor: Colors.white, // Selected hone par text/icon color
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: EColors.primary, // Tera Brand Color (Selected BG)
              color: Colors.grey[600], // Unselected Icon color

              selectedIndex: navigationState.screenIndex,

              onTabChange: (index) {
                navigationController.changeScreen(index);
              },

              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.shopping_bag_rounded, // Inventory ke liye badhiya icon
                  text: 'Inventory',
                ),
                GButton(
                  icon: Icons.account_balance_wallet_outlined,
                  text: 'Expense',
                ),
                GButton(
                  icon: Icons.settings_rounded,
                  text: 'Setting',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}