import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final aiService = AiService();
  final heightCtrl = TextEditingController(text: "170");
  final weightCtrl = TextEditingController(text: "65");
  String gender = "Nam";
  String goal = "Giảm cân";
  bool isLoading = false;

  final primaryPurple = const Color(0xFFD1C4E9);

  double calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return "Thiếu cân";
    if (bmi < 25) return "Bình thường";
    if (bmi < 30) return "Thừa cân";
    return "Béo phì";
  }

  Future<void> _handleSave() async {
    // Validate inputs
    final h = double.tryParse(heightCtrl.text);
    final w = double.tryParse(weightCtrl.text);

    if (h == null || w == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đúng chiều cao và cân nặng")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception("User không được xác thực");
      }

      // Calculate BMI
      final bmi = calculateBMI(w, h);

      // Save to backend
      await aiService.saveUserHealth(
        userId: userId,
        height: h,
        weight: w,
        bmi: bmi,
        gender: gender,
        goal: goal,
      );

      // Save to local storage
      prefs.setDouble('height', h);
      prefs.setDouble('weight', w);
      prefs.setDouble('bmi', bmi);
      prefs.setString('gender', gender);
      prefs.setString('goal', goal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu thành công. BMI: ${bmi.toStringAsFixed(1)}")),
      );

      // Go to home
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  "Thông tin cá nhân",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Height
                  const Text(
                    "Chiều cao (cm)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: heightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: "cm",
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Weight
                  const Text(
                    "Cân nặng (kg)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: "kg",
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Gender
                  const Text(
                    "Giới tính",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      value: gender,
                      items: const [
                        DropdownMenuItem(value: "Nam", child: Text("Nam")),
                        DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                      ],
                      onChanged: (v) => setState(() => gender = v ?? "Nam"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Goal
                  const Text(
                    "Mục tiêu",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      value: goal,
                      items: const [
                        DropdownMenuItem(value: "Giảm cân", child: Text("Giảm cân")),
                        DropdownMenuItem(value: "Giữ dáng", child: Text("Giữ dáng")),
                        DropdownMenuItem(value: "Tăng cân", child: Text("Tăng cân")),
                      ],
                      onChanged: (v) => setState(() => goal = v ?? "Giảm cân"),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      onPressed: isLoading ? null : _handleSave,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Lưu",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
