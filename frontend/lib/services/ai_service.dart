import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String baseUrl = "http://localhost:8080";

  Future<String> getMealPlan(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/ai/recommend'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return res.body;
  }
}