import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


class SnackBarService {

  static void showToast(String message) {

    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center, // Text
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        backgroundColor: Colors.white,

        behavior: SnackBarBehavior.floating,

        width: 200,

        elevation: 0,
        duration: const Duration(seconds: 2),

        shape: const StadiumBorder(side: BorderSide(color: Colors.black54)),
      ),
    );
  }
  // SUCCESS
  static void showSuccess(String message) {
    _showSnackBar(
        message,
        color: EColors.accentPrimary,
        icon: Icons.check_circle_outline
    );
  }

  // ERROR
  static void showError(String message) {
    _showSnackBar(
        message,
        color: Colors.red.shade600,
        icon: Icons.error_outline
    );
  }

  // GENERAL MESSAGE
  static void showMessage(String message) {
    _showSnackBar(
        message,
        color: Colors.grey.shade900,
        icon: Icons.info_outline
    );
  }

  // INTERNAL HELPER
  static void _showSnackBar(String message, {required Color color, required IconData icon}) {
    // Remove current snackbar if one is already showing (optional)
    scaffoldMessengerKey.currentState?.removeCurrentSnackBar();

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    fontSize: 13
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Makes it float above bottom nav
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}