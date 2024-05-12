import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];
  static const String openAIAPIKey = 'your api key';

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

 if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        content = utf8.decode(content.codeUnits);
        messages.add({
          'role': 'DJANI AI',
          'content': content,
        });
        return content;
      }
      return 'Téléchargement des données...';
    } catch (e) {
      if (e is http.ClientException) {
        return 'Erreur de connexion à https://djani.ai.com';
      }

      return 'Une erreur s\'est produite: $e';
    }
  }
}
