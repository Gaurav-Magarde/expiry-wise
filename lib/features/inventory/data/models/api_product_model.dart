class ApiProductModel {
  ApiProductModel({
    required this.name,
    required this.photoUrl,
    required this.quantity,
    required this.unit,
  });

  final String name;
  final String photoUrl;
  final double quantity;
  final String unit;

  factory ApiProductModel.fromMap(Map<String, dynamic> json) {

    final Map<String, dynamic> data = (json['product'] is Map)
        ? json['product']
        : json;

    String parsedName =
        data['product_name'] ??
            data['product_name_en'] ?? // English
            data['product_name_hi'] ?? // Hindi
            data['product_name_fr'] ?? // French
            data['generic_name'] ??
            data['abbreviated_product_name'] ??
            'Unknown Item';

    String parsedImage =
        data['image_front_url'] ??
            data['image_url'] ??
            data['image_front_small_url'] ??
            data['image_small_url'] ??
            data['image_thumb_url'] ??
            '';

    double? qty = _parseToDouble(data['product_quantity']);
    String? unt = data['quantity_unit'];


    if (qty == null || unt == null) {
      final String rawQuantity = (data['quantity'] ?? data['net_weight'] ?? "").toString();


      final match = RegExp(r'([0-9]+(\.[0-9]+)?)').firstMatch(rawQuantity);

      if (match != null) {

        qty ??= double.tryParse(match.group(0) ?? "1");

        unt ??= rawQuantity.replaceAll(match.group(0)!, "").trim();
      }
    }

    return ApiProductModel(
      name: parsedName,
      photoUrl: parsedImage,
      quantity: qty ?? 1.0,
      unit: (unt == null || unt.isEmpty) ? 'pcs' : unt, // Default 'pcs'
    );
  }

  // --- Helper: Safe Double Parsing ---
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {

      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }
    return null;
  }
}