import 'package:expiry_wise_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

import '../widgets/home_cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 2,
        title: Text("Home"),
        shadowColor: Colors.grey,
        centerTitle: true,
        leading: Icon(Icons.list_rounded),
        actions: [Icon(Icons.notifications_off_outlined)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(),
                  color: EColors.accentPrimary.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You have three items expiring soon!",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.apply(color: Colors.black87),
                      ),
                      SizedBox(height: 8,),
                      SizedBox(width: 90,height: 40, child: Center(
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child:  Center(child: Text("view details",style: Theme.of(context).textTheme.labelLarge,)),
                        ),
                      ))
                    ],
                   ),
                ),
              ),
              SizedBox(height: 16,),
              HomeCards(sectionHeading: 'Recently Added', itemName: 'Milk', categoriesName: 'Groceries',),
              SizedBox(height: 16,),
              HomeCards(sectionHeading: 'Expiring soon', itemName: 'Wheat', categoriesName: 'Groceries',)
            ],
          ),
        ),
      ),
    );
  }
}
