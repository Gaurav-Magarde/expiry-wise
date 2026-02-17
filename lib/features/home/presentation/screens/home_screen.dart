import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/widgets/pantry_status_card_widget.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../expenses/presentation/widgets/homescreen_chart_widget.dart';
import '../../../voice_command/presentation/screens/bottom_sheet_voice_command.dart';
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
            const InventoryValueCard(),
            Consumer(builder:(_,ref,_){
              final expenses = ref.watch(expenseStreamProvider).value;
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
      floatingActionButton:  SpeedDial(
        icon: Icons.menu_outlined,
         foregroundColor: Colors.white,
        activeIcon: Icons.close,
        backgroundColor: EColors.primary, // Tera Brand Color
        overlayColor: Colors.white,
        overlayOpacity: 0.4,
        children:[
          SpeedDialChild(

            child: const Icon(Icons.list),
            onTap: (){
              context.pushNamed(
                MYRoute.quickListScreen,
                queryParameters: {},
              );



            }
          ),
          SpeedDialChild(
            child: const Icon(Icons.mic),
            foregroundColor: EColors.primary,elevation: 5,
            onTap: (){
          showModalBottomSheet(context: context, builder: (context){

            return const BottomSheetMic();
          },
          backgroundColor: Colors.white,isDismissible: true);
            }

          ),
        ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSize buildPreferredSize() => PreferredSize(
    preferredSize: const Size(double.infinity, 50),
    child: ClipRRect(
      child: Container(decoration: const BoxDecoration(color: Colors.green)),
    ),
  );
}


