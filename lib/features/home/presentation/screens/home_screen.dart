import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/home/presentation/controllers/home_controller.dart';
import 'package:expiry_wise_app/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/widgets/status_cards_helper_widget.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/widgets/no_space_home_screen_widget.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/widgets/pantry_status_card_widget.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../services/sync_services/local_firebase_syncing.dart';
import '../../../expenses/presentation/widgets/homescreen_chart_widget.dart';
import '../../../inventory/data/models/item_model.dart';
import 'inventory_status/widgets/selected_items_card_widget.dart';
import '../widgets/inventory_value_card_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const AppBarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(child: Column(
          children: [
            const PantryStatusContainer(),
            const InventoryValueCard(totalValue: 5489),
            Consumer(builder:(_,ref,_){
              final expenses = ref.watch(expenseStateController).value;
              if(expenses!=null) {
                expenses.where((exp){
                final date = DateFormat(DateFormatPattern.dateformatPattern).tryParse(exp.expenseDate);
                final now = DateTime.now();
                return date!=null && now.subtract(Duration(days:  now.day,hours: now.hour,minutes: now.minute)).isAfter(date);
              });
              }
              return ExpensePieChart(expenses: expenses?? const [],);
            })
          ],
        ),),
      ),
      floatingActionButton: AddItemFloatingButton( () {
        context.pushNamed(
          MYRoute.quickListScreen,
          queryParameters: {},
        );
      },Icons.playlist_add_check_rounded,'Quick List'),
    );
  }

  PreferredSize buildPreferredSize() => PreferredSize(
    preferredSize: Size(double.infinity, 50),
    child: ClipRRect(
      child: Container(decoration: BoxDecoration(color: Colors.green)),
    ),
  );
}


