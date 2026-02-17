import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/route_controller.dart';

class ScreenRedirect extends ConsumerStatefulWidget{
  const ScreenRedirect({super.key});



  @override
  ConsumerState<ScreenRedirect> createState() {
    return _ScreenRedirect();
  }

}

class _ScreenRedirect extends ConsumerState<ScreenRedirect>{

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
        body: Center(child: CircularProgressIndicator( color: EColors.primary,),),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() async {
      ref.read(screenRedirectProvider).screenRedirect();
    });

  }



}