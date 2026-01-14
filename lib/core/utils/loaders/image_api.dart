import 'dart:convert';
import 'dart:io';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/core/constants/ApiKeys.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' ;
import 'package:path/path.dart' as path;

final apiImageProvider = Provider((ref)=>ImageService(ref));

class ImageService {
  static const String apiKey = ApiKeys.imageApi ;
  final Ref _ref;
  ImageService(this._ref);
  Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse("https://api.imgbb.com/1/upload");


      final request = http.MultipartRequest("POST", uri)
        ..fields['key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));


      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final json = jsonDecode(responseData.body);


        return json['data']['url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> saveImage(File imageFile) async {
    try {
        final directory = await getApplicationDocumentsDirectory();
        String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final newPath = path.join(directory.path,fileName);
        await imageFile.copy(newPath);
        return newPath;
    } catch (e) {
      return null;
    }
  }


  Future<void> startSmartSync() async {
    final itemStream = _ref.read(itemsStreamProvider).value ?? [];
    for (ItemModel item in itemStream) {

      if (item.image.isNotEmpty && File(item.image).existsSync()) {
        continue;
      }

      if (item.imageNetwork.isNotEmpty) {
        try {
          final imgFile = await DefaultCacheManager().getSingleFile(item.imageNetwork);
          String? savedPath = await saveImage(imgFile);


          await Future.delayed(const Duration(milliseconds: 50));

        } catch (e) {
        }
      }
    }
  }

  Future<void> deleteLocalImage(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return;

    try {
      final file = File(localPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}