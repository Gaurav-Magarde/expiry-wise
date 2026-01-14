import 'package:expiry_wise_app/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';

import 'inventory_status_card_widget.dart';

class CardsHelperWidget extends StatelessWidget {
  const CardsHelperWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DetailCard(
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B), // Pastel Red (Ye modern hai)
              Color(0xFFFF8E53), // // Very Light Pink
            ],
          ),
          Icons.error_outline_rounded,
          'Expired',
          SelectedContainer.expired,
        ),
        const SizedBox(width: 16),
        DetailCard(
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6D365), // Warm Soft Yellow
              Color(0xFFFDA085), // Soft Orange/Peach
            ],
          ),
          Icons.warning_amber_outlined,
          'Expiring soon',
          SelectedContainer.expiring,
        ),
        const SizedBox(width: 16),
        DetailCard(
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FACFE), // Bright Sky Blue
              Color(0xFF00F2FE), // Cyan/Aqua
            ],
          ),
          Icons.access_time_outlined,
          'Recently Added',
          SelectedContainer.recent,
        ),
      ],
    );
  }
}