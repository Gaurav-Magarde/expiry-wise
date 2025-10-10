import 'package:expiry_wise_app/features/Navigation/screens/NavigationScreen.dart';
import 'package:expiry_wise_app/utils/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'features/OnBoarding/screens/on_boarding_screen.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return GetMaterialApp(

      theme: EAppTheme.lightTheme,
      title: "expiry-wise",
      debugShowCheckedModeBanner: false,
      home: const NavigationScreen(),
    );

  }
}

class AppStartScreen extends StatelessWidget{
  const AppStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child :ElevatedButton(onPressed: (){},child: Text('Add products'),)));
  }
}