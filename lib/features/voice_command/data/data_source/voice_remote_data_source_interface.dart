import 'package:expiry_wise_app/features/voice_command/data/data_source/gemini_remote_data_source_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/constants/ApiKeys.dart';
import '../../../../core/constants/constants.dart';

abstract interface class IVoiceRemoteDataSource {
  Future<Map<String, dynamic>> processCommand({required String command});
}

final voiceRemoteProvider = Provider<IVoiceRemoteDataSource>((ref) {
  final apiKey = ApiKeys.geminiApi;
  final systemRules = getSystemPrompt();
  final model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: apiKey,
    systemInstruction: Content.system(systemRules),
  );
  return GeminiRemoteDataSource(model);
});

String getSystemPrompt() {
  String today = DateTime.now().toIso8601String().split('T')[0];

  return '''
  Role: You are a smart data parser. Convert user commands into strict JSON.
  Current Date: $today

  ---------------------------------------------------
   CRITICAL: INTENTION DETECTION RULES (READ CAREFULLY)
  ---------------------------------------------------
  
  1. INVENTORY (Past Tense / Completed Action):
     - Put item here ONLY IF user has ALREADY bought it or has it in hand.
     - Keywords to watch: "Bought", "Purchased", "Added", "Laya", "Le aaya", "Aa gaya", "Stock me daal de", "Add [Item]".
     - Example: "Doodh laya hu" -> Inventory.
     - Example: "Add 5kg Rice" -> Inventory (Implies adding to stock).

  2. QUICK_LIST (Future Tense / Pending Action):
     - Put item here IF user needs to buy it later or stock is finished.
     - Keywords to watch: "Need", "Buy", "Purchase", "Lana hai", "Khatam ho gaya", "Out of stock", "Likh le", "Yaad dila", "Reminder", "Shopping list".
     - Example: "Doodh lana hai" -> Quick List.
     - Example: "Chini khatam ho gayi" -> Quick List.
     - Example: "Add Soap to shopping list" -> Quick List.

  3. EXPENSE (Spending Money):
     - Money spent on bills, services, or consumed food.
     - Keywords: "Paid", "Bill bhara", "Kharch kiye", "Spent".

  ---------------------------------------------------

  STRICT JSON OUTPUT FORMAT (Use these exact keys):
  {
    "inventory": [
      {
        "name": "Item Name",
        "quantity": "Quantity (e.g. 1 L, 2 kg) - default '1'",
        "expiry": "${DateFormatPattern.dateformatPattern} (Estimate for perishable, else null)",
        "price": 0.0 (Price if mentioned, else null),
        "category": "grocery/vegetables/dairy/medicine/personalCare/electronics/documents/subscriptions/others"
      }
    ],
    "expense": [
      {
        "title": "Expense Name",
        "amount": 0.0,
        "paid_date": "$today",
        "category": " grocery/bills/transport/health/shopping/household/education/entertainment/others"
      }
    ],
    "quick_list": [
      {
        "title": "Item Name"
      }
    ]
  }

  Rules:
  - Return ONLY raw JSON. No markdown (```json). No extra text.
  - If a value is missing, use null (except for required fields).
  - Convert Hinglish terms to English (e.g., 'Bijli' -> 'Electricity').
  - STRICTLY follow the Intention Rules above.
  ''';
}
