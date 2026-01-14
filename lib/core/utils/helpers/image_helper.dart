import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
class ImageHelper{
  
  static Widget giveImage({required String? imagePath,required String? imagePathNetwork,}){
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/img_1.webp', fit: BoxFit.cover,);
        },
      );
    }

    if (imagePathNetwork != null && imagePathNetwork.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePathNetwork,
        fit: BoxFit.cover,

        placeholder: (context, url) => const Center(
            child: SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
            )
        ),

        errorWidget: (context, url, error) => Image.asset('assets/images/img_1.webp', fit: BoxFit.cover,),
      );
    }
    return Image.asset('assets/images/img_1.webp', fit: BoxFit.cover,);
  }


  static Widget giveAddImage({required String? imagePath,required String? imagePathNetwork,}){
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/tap_to_add_img.webp', fit: BoxFit.cover,);
        },
      );
    }

    if (imagePathNetwork != null && imagePathNetwork.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePathNetwork,
        fit: BoxFit.cover,

        placeholder: (context, url) => const Center(
            child: SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
            )
        ),

        errorWidget: (context, url, error) => Image.asset('assets/images/tap_to_add_img.webp', fit: BoxFit.cover,),
      );
    }

    return Image.asset('assets/images/tap_to_add_img.webp', fit: BoxFit.cover,);
  }

  static Widget giveProductImage({required String? imagePath,required String? imagePathNetwork,required String category}){
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        cacheWidth: 200,
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return giveCategoryIcon(category);
        },
      );
    }

    if (imagePathNetwork != null && imagePathNetwork.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePathNetwork,
        fit: BoxFit.cover,

        placeholder: (context, url) => const Center(
            child: SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
            )
        ),

        errorWidget: (context, url, error) => giveCategoryIcon(category),
      );
    }

    return giveCategoryIcon(category);
  }


  static Icon giveCategoryIcon(String category) {
    const double kIconSize = 24.0;

    switch (category.toLowerCase().trim()) {

      case 'grocery':
      // Shopping Cart ya Basket best hai
        return const Icon(Icons.shopping_cart_rounded, color: Colors.orange, size: kIconSize);

      case 'vegetables':
      // Material me 'Carrot' nahi hai, isliye 'Eco' (Leaf) ya 'Nutrition' use karna padega
        return const Icon(Icons.eco_rounded, color: Colors.green, size: kIconSize);

      case 'dairy':
      // 'Cheese' nahi hai, isliye 'Egg' ya 'Drink' (Milk) close option hai
        return const Icon(Icons.egg_alt_rounded, color: Colors.blue, size: kIconSize);
    // Note: Agar egg_alt error de, to Icons.local_drink_rounded use karna

      case 'medicine':
      // Ye perfect hai
        return const Icon(Icons.medication_rounded, color: Colors.redAccent, size: kIconSize);

      case 'personalcare':
      case 'personal care':
      // 'Spa' (Leaf/Flower) ya 'Clean Hands' sabse sahi hai
        return const Icon(Icons.spa_rounded, color: Colors.purple, size: kIconSize);

      case 'electronics':
      // Devices best hai
        return const Icon(Icons.devices_other_rounded, color: Colors.indigo, size: kIconSize);

      case 'documents':
      // Description ya Folder
        return const Icon(Icons.description_rounded, color: Colors.brown, size: kIconSize);

      case 'subscriptions':
      // Card Membership
        return const Icon(Icons.card_membership_rounded, color: Colors.teal, size: kIconSize);

      case 'others':
      default:
        return const Icon(Icons.category_rounded, color: Colors.grey, size: kIconSize);
    }
  }
}