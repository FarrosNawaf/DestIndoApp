import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyDPptntdbZwMbJXsjYLDd1gQzfyYt6oK1I';

  static Future<Map<String, dynamic>> generateTravelRecommendations(
      String city) async {
    final prompt =
        "Kamu AI yang dapat memberikan rekomendasi wisata dan kuliner berdasarkan nama kota yang dimasukkan. Model harus mengembalikan respons dalam format JSON dengan struktur sebagai berikut:\n\n" +
            "Input: Nama kota\n\n" +
            "Output (JSON):\n" +
            "{\n  \"city\": \"$city\",\n  \"recommended_places\": [\n    {\n      \"name\": \"Nama Tempat Wisata\",\n      \"category\": \"Kategori (Alam, Sejarah, Modern, dll.)\",\n      \"description\": \"Deskripsi singkat tentang tempat ini\",\n      \"estimated_cost\": \"Estimasi biaya masuk atau transportasi\"\n    }\n  ],\n  \"must_try_foods\": [\n    {\n      \"name\": \"Nama Makanan Khas\",\n      \"description\": \"Deskripsi singkat makanan ini\",\n      \"estimated_price\": \"Estimasi harga makanan\"\n    }\n  ],\n  \"estimated_total_budget\": \"Estimasi total pengeluaran untuk perjalanan\"\n}";

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(prompt),
      ]),
    ]);
    final message = city;
    final content = Content.text(message);

   try {
      final response = await chat.sendMessage(content);
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      if (responseText.isEmpty) {
        return {"error": "Gagal mendapatkan rekomendasi wisata"};
      }

      RegExp jsonPattern = RegExp(r'\{.*\}', dotAll: true);
      final match = jsonPattern.firstMatch(responseText);

      if (match != null) {
        final jsonResponse = json.decode(match.group(0)!);
        return jsonResponse;
      }
      return jsonDecode(responseText);
    } catch (e) {
      return {"error": "Gagal mendapatkan rekomendasi wisata\n$e"};
    }
  }
}
