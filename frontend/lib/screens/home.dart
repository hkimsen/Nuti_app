import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/ai_service.dart';
import 'add_food.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final aiService = AiService();
  DateTime selectedDate = DateTime.now();

  int? userId;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>>? meals;
  bool isLoading = true;
  String? error;

  final primaryPurple = const Color(0xFFD1C4E9);
  final lightPurple = const Color(0xFFEDE7F6);
  final pastelGreen = const Color(0xFFA5D6A7);
  final lightGreen = const Color(0xFFE8F5E9);
  final warningOrange = const Color(0xFFFFB74D);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          error = "Người dùng không được xác thực";
          isLoading = false;
        });
        return;
      }

      final selectedDateIso = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Load user data
      final user = await aiService.getUserData(userId!);

      // Apply daily weight override if exists (stored locally by date)
      final overridden = await _applyDailyWeightOverride(prefs, user, selectedDateIso);

      // Load meals for selected date
      final mealsList = await aiService.getUserMeals(userId!, date: selectedDateIso);

      setState(() {
        userData = overridden;
        meals = mealsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Lỗi: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _changeDay(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
      isLoading = true;
      error = null;
    });
    _loadData();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
        error = null;
      });
      _loadData();
    }
  }

  Future<Map<String, dynamic>> _applyDailyWeightOverride(
    SharedPreferences prefs,
    Map<String, dynamic> user,
    String dateIso,
  ) async {
    final raw = prefs.getString('weightLogs');
    if (raw == null || raw.isEmpty) return user;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return user;
      final wRaw = decoded[dateIso];
      if (wRaw == null) return user;

      final weight = (wRaw as num).toDouble();
      final heightRaw = user['height'];
      if (heightRaw is num && heightRaw.toDouble() > 0) {
        final heightM = heightRaw.toDouble() / 100.0;
        final bmi = weight / (heightM * heightM);
        return {
          ...user,
          'weight': weight,
          'bmi': bmi,
        };
      }

      return {
        ...user,
        'weight': weight,
      };
    } catch (_) {
      return user;
    }
  }

  Future<void> _promptUpdateDailyWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final dateIso = DateFormat('yyyy-MM-dd').format(selectedDate);
    final current = userData?['weight'];

    final controller = TextEditingController(
      text: current is num ? current.toString() : '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cập nhật cân nặng (${DateFormat('dd/MM/yyyy').format(selectedDate)})"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Cân nặng (kg)",
            hintText: "Ví dụ: 65.5",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          FilledButton(
            onPressed: () {
              final w = double.tryParse(controller.text.trim().replaceAll(',', '.'));
              if (w == null || w <= 0) return;
              Navigator.pop(context, w);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null) return;

    Map<String, dynamic> logs = {};
    final raw = prefs.getString('weightLogs');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          logs = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    logs[dateIso] = result;
    await prefs.setString('weightLogs', jsonEncode(logs));

    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });
    await _loadData();
  }

  String get formattedDate {
    final weekday = DateFormat.EEEE('vi').format(selectedDate);
    final date = DateFormat('dd/MM/yyyy').format(selectedDate);
    return "$weekday, $date";
  }

  // Calculate TDEE and recommended calories
  double calculateTDEE() {
    if (userData?['weight'] == null || userData?['height'] == null) return 0;

    final weight = (userData!['weight'] as num).toDouble();
    final height = (userData!['height'] as num).toDouble();
    final gender = userData!['gender'] ?? 'Nam';

    // Mifflin-St Jeor equation
    double bmr;
    if (gender == 'Nữ') {
      bmr = 10 * weight + 6.25 * height - 5 * 30 - 161;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * 30 + 5;
    }

    // Activity factor (sedentary)
    const activityFactor = 1.2;
    double tdee = bmr * activityFactor;

    // Adjust for goal
    final goal = userData!['goal'] ?? 'Giảm cân';
    if (goal == 'Giảm cân') {
      tdee = tdee * 0.85; // 15% deficit
    } else if (goal == 'Tăng cân') {
      tdee = tdee * 1.1; // 10% surplus
    }

    return tdee;
  }

  double getTotalCalories() {
    if (meals == null) return 0;
    return meals!.fold(0, (sum, meal) => sum + ((meal['calories'] as num).toDouble()));
  }

  List<Map<String, dynamic>> getMealsForType(String type) {
    if (meals == null) return [];
    return meals!.where((m) => m['mealType'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || userData == null) {
      return Scaffold(
        body: Center(
          child: Text(error ?? "Không thể tải dữ liệu"),
        ),
      );
    }

    final tdee = calculateTDEE();
    final currentCalories = getTotalCalories();
    final progress = tdee <= 0 ? 0.0 : (currentCalories / tdee);
    final displayName = "${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}".trim();

    return Column(
      children: [
        _buildHeader(displayName),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // BMI Card
                _buildBMICard(),
                const SizedBox(height: 16),
                // Calories Card
                _buildCaloriesCard(currentCalories, tdee, progress),
                const SizedBox(height: 16),
                // Meals Section
                _buildMealsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String displayName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _changeDay(-1),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _changeDay(1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Xin chào, $displayName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _promptUpdateDailyWeight,
                icon: const Icon(Icons.monitor_weight_outlined, size: 18),
                label: const Text("Cập nhật cân nặng theo ngày"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    final bmi = userData!['bmi'] as num?;
    final weight = userData!['weight'] as num?;
    final height = userData!['height'] as num?;
    final bmiValue = bmi?.toDouble();

    String getBMIStatus(double bmi) {
      if (bmi < 18.5) return "Thiếu cân";
      if (bmi < 25) return "Bình thường";
      if (bmi < 30) return "Thừa cân";
      return "Béo phì";
    }

    Color getBMIColor(double bmi) {
      if (bmi < 18.5) return Colors.blue;
      if (bmi < 25) return pastelGreen;
      if (bmi < 30) return warningOrange;
      return Colors.red;
    }

    final bmiStatus = bmiValue != null ? getBMIStatus(bmiValue) : "Chưa có dữ liệu";
    final bmiColor = bmiValue != null ? getBMIColor(bmiValue) : Colors.grey;
    final bmiProgress = bmiValue == null ? 0.0 : ((bmiValue - 15) / 20).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightPurple,
            primaryPurple.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Chỉ số cơ thể",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2142),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bmiColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  bmiStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: bmiColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: CircularProgressIndicator(
                        value: bmiProgress,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withOpacity(0.65),
                        valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                      ),
                    ),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.92),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bmi?.toStringAsFixed(1) ?? "N/A",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F1A2D),
                          ),
                        ),
                        const Text(
                          "BMI",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bmiValue != null
                          ? "BMI của bạn đang ở mức $bmiStatus"
                          : "Cập nhật cân nặng và chiều cao để có BMI",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Color(0xFF3F3A52),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: bmiProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.65),
                        valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "15",
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        Text(
                          "18.5",
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        Text(
                          "25",
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        Text(
                          "35",
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBodyInfoTag(
                  label: "Cân nặng",
                  value: "${weight?.toStringAsFixed(1) ?? 'N/A'} kg",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBodyInfoTag(
                  label: "Chiều cao",
                  value: "${height?.toStringAsFixed(0) ?? 'N/A'} cm",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyInfoTag({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(double current, double target, double progress) {
    final displayProgress = progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lượng Calo Hôm Nay",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieItem("Đã tiêu thụ", current.toInt(), Colors.blue),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey.shade300,
              ),
              _buildCalorieItem("Mục tiêu", target.toInt(), pastelGreen),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: displayProgress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                displayProgress >= 1.0 ? Colors.orange : pastelGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "${(displayProgress * 100).toStringAsFixed(0)}% hoàn thành",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          "kcal",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsSection() {
    final breakfastMeals = getMealsForType("breakfast");
    final lunchMeals = getMealsForType("lunch");
    final dinnerMeals = getMealsForType("dinner");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Bữa ăn trong ngày",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Theo dõi chi tiết từng bữa để kiểm soát calo",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                tooltip: "Thêm món ăn",
                offset: const Offset(0, 42),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pastelGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                onSelected: (value) => _navigateToAddFood(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "breakfast", child: Text("Bữa sáng")),
                  const PopupMenuItem(value: "lunch", child: Text("Bữa trưa")),
                  const PopupMenuItem(value: "dinner", child: Text("Bữa tối")),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMealTypeSection(
            title: "Bữa sáng",
            icon: Icons.wb_sunny_rounded,
            accent: const Color(0xFFFFB74D),
            meals: breakfastMeals,
          ),
          const SizedBox(height: 10),
          _buildMealTypeSection(
            title: "Bữa trưa",
            icon: Icons.lunch_dining_rounded,
            accent: const Color(0xFF66BB6A),
            meals: lunchMeals,
          ),
          const SizedBox(height: 10),
          _buildMealTypeSection(
            title: "Bữa tối",
            icon: Icons.nightlight_round,
            accent: const Color(0xFF7986CB),
            meals: dinnerMeals,
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection({
    required String title,
    required IconData icon,
    required Color accent,
    required List<Map<String, dynamic>> meals,
  }) {
    final totalCal = meals.fold(0.0, (sum, m) => sum + ((m['calories'] as num).toDouble()));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _buildMealMetaChip("${meals.length} món", accent),
              const SizedBox(width: 6),
              _buildMealMetaChip("${totalCal.toInt()} kcal", accent),
            ],
          ),
          if (meals.isEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  "Chưa có món ăn trong bữa này",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            ...meals.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${meal['foodName']}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${(meal['gram'] as num).toInt()}g",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${(meal['calories'] as num).toInt()} kcal",
                        style: TextStyle(
                          fontSize: 12,
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealMetaChip(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _navigateToAddFood(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(mealType: mealType),
      ),
    ).then((_) => _loadData()); // Reload after adding food
  }
}


