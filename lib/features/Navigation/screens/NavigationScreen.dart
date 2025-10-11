import 'package:expiry_wise_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/navigation_controller.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        ()=> NavigationBar(
          shadowColor: Colors.grey,
          elevation: 15,
          selectedIndex: controller.selectedScreenIndex.value,
        backgroundColor: Colors.grey[100],
          height: 60,
        indicatorColor: Colors.grey[100],
          onDestinationSelected: controller.changeScreen,
          destinations: [
            NavigationDestination(selectedIcon: Icon( Icons.home,color: EColors.primary,size: 28,), icon:  Icon(Icons.home,), label: "Home",),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined,),
              label: "All Items",selectedIcon: Icon(Icons.shopping_bag_outlined,color: EColors.primary,size: 28,),

            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings,color: EColors.primary,size: 28,),
              icon: Icon(Icons.settings),
              label: "Setting",
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedScreenIndex.value]),
    );
  }
}
