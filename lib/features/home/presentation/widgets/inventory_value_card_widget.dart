import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InventoryValueCard extends ConsumerWidget {

  const InventoryValueCard({super.key,});

  @override
  Widget build(BuildContext context,ref) {
    final items = ref.watch(itemsStreamProvider).value;
    double totalValue = _getTotal(items);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3436),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Text Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Value',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₹ ${totalValue.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }

  double _getTotal(List<ItemModel>? items) {
    if(items==null)return 0;
    double sum = 0.0;
    for(final item in items){
     if(item.finished==0) sum+= item.price??0;

    }
    return sum;
  }
}