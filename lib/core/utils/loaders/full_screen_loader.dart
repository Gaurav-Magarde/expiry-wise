import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';

class FullScreenLoader {
  static showLoader(context, String text) {
    return showDialog(
      fullscreenDialog: true,
      barrierDismissible: false,
      context: context,
      builder: (t) => PopScope(
        canPop: false,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white.withAlpha(200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: EColors.primary),
              const SizedBox(height: 20),
              Text(
                text,
                style: Theme.of(context).textTheme.titleMedium!.apply(
                  color: EColors.primary,
                  fontWeightDelta: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void stopLoader(BuildContext context){
    context.pop();
  }
}


