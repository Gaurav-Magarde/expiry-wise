import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_items_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/colors.dart';

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _BarcodeScanScreen();
  }
}

class _BarcodeScanScreen extends ConsumerState<BarcodeScanScreen> {
  bool isScanCompleted = false;
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _BarcodeScanScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              torchEnabled: true,
              returnImage: false,
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (detect) {
              if (!isScanCompleted) {
                final barcodes = detect.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    isScanCompleted = true;
                    final String code = barcode.rawValue!;
                    ref.read(scannedBarcodeProvider.notifier).state = code;
                    if (context.mounted) {
                      context.pop();
                    }
                    setState(() {
                      isScanCompleted = true;
                    });
                    break;
                  }
                }
              }
            },
          ),
          Positioned(
            top: 60,
            left: 25,
            child: IconButton(
              onPressed: () {
                if(context.mounted) context.pop();
              },
              icon: Icon(Icons.arrow_back_sharp,color: EColors.light,),
            ),
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height*.15,
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
