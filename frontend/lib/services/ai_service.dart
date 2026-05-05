import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  final String baseUrl = "http://localhost:8080";

 Future<String> getMealPlan(Map<String, dynamic> data) async {
  final res = await http.post(
    //Uri.parse("http://10.0.2.2:8080/api/recommend"),
    Uri.parse("http://localhost:8080/api/recommend"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  return res.body;
}

  Future<List<Map<String, dynamic>>> getFoods() async {
    final res = await http.get(
      Uri.parse("$baseUrl/foods"),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception("Failed to load foods: ${res.statusCode}");
    }
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Signup failed: ${res.body}");
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Login failed: ${res.body}");
    }
  }

  Future<String> saveUserAccount({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    print("DEBUG AI_SERVICE: Calling POST /api/user/account with userId=$userId");
    
    final res = await http.post(
      Uri.parse("$baseUrl/api/user/account"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
      }),
    );

    print("DEBUG AI_SERVICE: Response status=${res.statusCode}, body=${res.body}");

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception("Failed to save account: ${res.statusCode} - ${res.body}");
    }
  }

  Future<String> saveUserHealth({
    required int userId,
    required double height,
    required double weight,
    required double bmi,
    required String gender,
    required String goal,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/user/health"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "height": height,
        "weight": weight,
        "bmi": bmi,
        "gender": gender,
        "goal": goal,
      }),
    );

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception("Failed to save health: ${res.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getUserData(int userId) async {
    print("DEBUG AI_SERVICE: Getting user data for userId=$userId");
    
    final res = await http.get(
      Uri.parse("$baseUrl/api/user/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    print("DEBUG AI_SERVICE: Response status=${res.statusCode}");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to get user data: ${res.statusCode}");
    }
  }

  Future<String> addMeal({
    required int userId,
    required int foodId,
    required String foodName,
    required String mealType,
    required double gram,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/meals"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "foodId": foodId,
        "foodName": foodName,
        "mealType": mealType,
        "gram": gram,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fat": fat,
        "date": DateTime.now().toIso8601String().split('T')[0],
      }),
    );

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception("Failed to add meal: ${res.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getUserMeals(int userId, {String? date}) async {
    String url = "$baseUrl/api/meals/user/$userId";
    if (date != null) {
      url += "?date=$date";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception("Failed to load meals: ${res.statusCode}");
    }
  }

  Future<Map<String, dynamic>> saveDailyWeight({
    required int userId,
    required double weight,
    required String date,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/weights"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "weight": weight,
        "date": date,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to save daily weight: ${res.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> getWeightHistory(
    int userId, {
    String? from,
    String? to,
  }) async {
    String url = "$baseUrl/api/weights/user/$userId";
    final params = <String>[];
    if (from != null) params.add("from=$from");
    if (to != null) params.add("to=$to");
    if (params.isNotEmpty) {
      url += "?${params.join('&')}";
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else {
      throw Exception("Failed to load weight history: ${res.statusCode}");
    }
  }
}