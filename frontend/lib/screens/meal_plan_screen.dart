import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nutrition_app/services/ai_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final timeValueCtrl = TextEditingController(text: "7");

  String gender = "Nam";
  String goal = "Giảm cân";
  String timeUnit = "Ngày";

  double? bmi;
  int? tdee;
  int? dailyCalories;
  List<Map<String, dynamic>> planData = [];

  bool isLoading = false;
  String error = "";

  Future<void> generatePlan() async {
    final h = double.tryParse(heightCtrl.text.trim());
    final w = double.tryParse(weightCtrl.text.trim());
    final age = int.tryParse(ageCtrl.text.trim());
    final timeValue = int.tryParse(timeValueCtrl.text.trim());

    if (h == null || w == null || age == null || timeValue == null || timeValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đúng chiều cao, cân nặng, tuổi và thời gian.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
      planData = [];
    });

    try {
      final ai = AiService();
      final res = await ai.getMealPlan({
        "height": h,
        "weight": w,
        "age": age,
        "gender": gender,
        "goal": goal,
        "timeValue": timeValue,
        "timeUnit": timeUnit,
      });

      final decoded = jsonDecode(res);
      final data = decoded is String ? jsonDecode(decoded) : decoded;

      setState(() {
        bmi = (data["bmi"] as num?)?.toDouble();
        tdee = (data["tdee"] as num?)?.toInt();
        dailyCalories = (data["dailyCalories"] as num?)?.toInt();
        planData = List<Map<String, dynamic>>.from(data["plan"] ?? []);
      });
    } catch (e) {
      setState(() => error = "Không thể tạo lộ trình ăn uống: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _numberField(String label, TextEditingController ctrl, {String? suffix}) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _selectionField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  int _calcMealCalories(List meals) {
    return meals.fold<int>(0, (sum, m) => sum + ((m["cal"] as num?)?.toInt() ?? 0));
  }

  Widget _buildMealGroup(String title, List meals, Color accent) {
    final total = _calcMealCalories(meals);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text("$total kcal", style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            Text("Chưa có món", style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
          else
            ...meals.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${m["name"] ?? "Món ăn"} • ${(m["grams"] ?? 0)}g",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        "${(m["cal"] ?? 0)} kcal",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildPlanDay(Map<String, dynamic> day) {
    final meals = (day["meals"] as Map<String, dynamic>?) ?? {};
    final breakfast = (meals["breakfast"] as List?) ?? [];
    final lunch = (meals["lunch"] as List?) ?? [];
    final dinner = (meals["dinner"] as List?) ?? [];
    final total = _calcMealCalories(breakfast) + _calcMealCalories(lunch) + _calcMealCalories(dinner);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Ngày ${day["day"]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A5ACD).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text("$total kcal", style: const TextStyle(color: Color(0xFF6A5ACD), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildMealGroup("Bữa sáng", breakfast, const Color(0xFFFFB74D)),
            _buildMealGroup("Bữa trưa", lunch, const Color(0xFF66BB6A)),
            _buildMealGroup("Bữa tối", dinner, const Color(0xFF7986CB)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (bmi == null && tdee == null && dailyCalories == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _summaryItem("BMI", bmi?.toStringAsFixed(1) ?? "--")),
          Expanded(child: _summaryItem("TDEE", tdee != null ? "${tdee!}" : "--", suffix: "kcal")),
          Expanded(child: _summaryItem("Mục tiêu/ngày", dailyCalories != null ? "${dailyCalories!}" : "--", suffix: "kcal")),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, {String suffix = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          suffix.isEmpty ? value : "$value $suffix",
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Gợi ý lộ trình ăn uống"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _numberField("Chiều cao", heightCtrl, suffix: "cm")),
                      const SizedBox(width: 10),
                      Expanded(child: _numberField("Cân nặng", weightCtrl, suffix: "kg")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _numberField("Tuổi", ageCtrl)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selectionField(
                          label: "Giới tính",
                          value: gender,
                          items: const ["Nam", "Nữ"],
                          onChanged: (v) => setState(() => gender = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _selectionField(
                          label: "Mục tiêu",
                          value: goal,
                          items: const ["Giảm cân", "Giữ dáng", "Tăng cân"],
                          onChanged: (v) => setState(() => goal = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selectionField(
                          label: "Đơn vị",
                          value: timeUnit,
                          items: const ["Ngày", "Tuần", "Tháng"],
                          onChanged: (v) => setState(() => timeUnit = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _numberField("Thời gian", timeValueCtrl),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : generatePlan,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(isLoading ? "Đang tạo kế hoạch..." : "Tạo meal plan"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (error.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(error, style: TextStyle(color: Colors.red.shade700)),
              ),
            if (isLoading) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
            if (!isLoading && planData.isNotEmpty) ...[
              _buildSummaryCard(),
              const SizedBox(height: 14),
              ...planData.map(_buildPlanDay),
            ],
          ],
        ),
      ),
    );
  }
}
