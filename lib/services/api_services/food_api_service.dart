import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final foodApiProvider = Provider<FoodApiService>((ref)=>FoodApiService());

class FoodApiService{

  static get instance => FoodApiService();
  static const  String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';

  Future<Map<String,dynamic>?> getProductByBarcode(String barcode)async{

    final url = Uri.parse('$_baseUrl/$barcode');
    final response  = await http.get(url);
    if(response.statusCode == 200){

      final productData = jsonDecode(response.body);
      if(productData['status']==1){
        return productData['product'];
      }else{
        return null;
      }
    }else{
      return null;
    }

  }


}