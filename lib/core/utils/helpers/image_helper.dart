import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
class ImageHelper{
  
  static Widget giveImage({required String? imagePath,required String? imagePathNetwork,}){
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/img_1.png', fit: BoxFit.cover,);
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

        errorWidget: (context, url, error) => Image.asset('assets/images/img_1.png', fit: BoxFit.cover,),
      );
    }
    return Image.asset('assets/images/img_1.png', fit: BoxFit.cover,);
  }


  static Widget giveAddImage({required String? imagePath,required String? imagePathNetwork,}){
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/tap_to_add_img.png', fit: BoxFit.cover,);
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

        errorWidget: (context, url, error) => Image.asset('assets/images/tap_to_add_img.png', fit: BoxFit.cover,),
      );
    }

    return Image.asset('assets/images/tap_to_add_img.png', fit: BoxFit.cover,);
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
        return const Icon(FontAwesome.basket_shopping_solid, color: Colors.orange, size: kIconSize);

      case 'vegetables':
        return const Icon(FontAwesome.carrot_solid, color: Colors.green, size: kIconSize); // Leaf ya Carrot best hai

      case 'dairy':
        return const Icon(FontAwesome.cheese_solid, color: Colors.blue, size: kIconSize); // Cheese/Milk representation

      case 'medicine':
        return const Icon(FontAwesome.pills_solid, color: Colors.redAccent, size: kIconSize); // Pills best hai

      case 'personalcare':
      case 'personal care':
        return const Icon(FontAwesome.pump_soap_solid, color: Colors.purple, size: kIconSize); // Soap/Lotion

      case 'electronics':
        return const Icon(FontAwesome.plug_solid, color: Colors.indigo, size: kIconSize);

      case 'documents':
        return const Icon(FontAwesome.file_contract_solid, color: Colors.brown, size: kIconSize);

      case 'subscriptions':
        return const Icon(FontAwesome.credit_card_solid, color: Colors.teal, size: kIconSize);

      case 'others':
      default:
        return const Icon(FontAwesome.box_open_solid, color: Colors.grey, size: kIconSize);
    }
  }
}