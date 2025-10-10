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
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: controller.selectedScreenIndex.value,
backgroundColor: Colors.grey[100],
        height: 60,
indicatorColor: Colors.grey[100],
        onDestinationSelected: controller.changeScreen,
        destinations: [
          NavigationDestination(selectedIcon: Icon(Icons.home,color: EColors.primary,), icon:  Icon(Icons.home), label: "home",),
          NavigationDestination(
            icon: Obx(()=> Icon(Icons.shopping_bag_outlined,color: controller.selectedScreenIndex.value == 1? EColors.primary : null,)),
            label: "",

          ),
          NavigationDestination(
            icon: Icon(Icons.list_rounded),
            label: "Setting",
          ),
        ],
      ),
      body: Obx(() => controller.screens[controller.selectedScreenIndex.value]),
    );
  }
}
