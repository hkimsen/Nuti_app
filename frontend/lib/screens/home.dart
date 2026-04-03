import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

// IMPORT bottom sheet của bạn
import '../widgets/base_bottom_sheet.dart';
import 'add_food.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();

  double currentWeight = 60;
  double calorie = 1200;
  double goal = 2000;

  List<double> rawWeights = [60, 60, 59, 59, 58, 58, 57];
  List<FlSpot> get filteredWeightData {
    List<FlSpot> result = [];

    for (int i = 1; i < rawWeights.length; i++) {
      if (rawWeights[i] != rawWeights[i - 1]) {
        result.add(FlSpot(i.toDouble(), rawWeights[i]));
      }
    }

  return result;
}

  final primaryPurple = const Color(0xFFD1C4E9);
  final lightPurple = const Color(0xFFEDE7F6);
  final pastelGreen = const Color(0xFFA5D6A7);

  // ================= DATE =================
  void _changeDay(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

 String get formattedDate {
  final weekday = DateFormat.EEEE('vi').format(selectedDate);
  final date = DateFormat('dd/MM/yyyy').format(selectedDate);
  return "$weekday, $date";
}

  // ================= BOTTOM SHEET =================
  void _showWeightSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BaseBottomSheet(
          title: "Cập nhật cân nặng",
          isEdit: true,
          onCancel: () => Navigator.pop(context),
          onSave: () {
            setState(() {
              currentWeight =
                  double.tryParse(controller.text) ?? currentWeight;
              rawWeights.add(currentWeight);
            });

            Navigator.pop(context);
          },
          child: Column(
            children: [
              buildField("Cân nặng (kg)", controller, true),
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _changeDay(1);
        } else if (details.primaryVelocity! > 0) {
          _changeDay(-1);
        }
      },
      child: Column(
        children: [
          _buildHeader(), // ✅ FIXED

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildAppleCalories(calorie, goal),
                  const SizedBox(height: 16),
                  _buildMealSection(), // 👈 update ở đây
                  const SizedBox(height: 20),
                  _buildWeightHeader(),
                  const SizedBox(height: 10),
                  _buildChart(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => _changeDay(-1),
            ),
            GestureDetector(
              onTap: _pickDate,
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _changeDay(1),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CALO =================
  Widget _buildAppleCalories(double current, double target) {
  final progress = (current / target).clamp(0.0, 1.0);

  return Container(
    width: 220,
    height: 190,
    decoration: BoxDecoration(
      color: const Color(0xFFEDE7F6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic, // 🔥 mượt hơn linear
      builder: (context, animatedProgress, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 🍏 Apple progress
            CustomPaint(
              size: const Size(230, 180),
              painter: AppleProgressPainter(animatedProgress),
            ),

            // 🔢 kcal animate luôn
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: current),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, animatedValue, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${animatedValue.toInt()}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "kcal",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    ),
  );
}


  // ================= MEAL =================
Widget _buildMealSection() {
  final meals = [
    {"name": "Trứng luộc", "gram": 100, "kcal": 155},
    {"name": "Bánh mì", "gram": 80, "kcal": 200},
  ];

  int total =
      meals.fold(0, (sum, item) => sum + (item["kcal"] as int));

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 HEADER + BUTTON
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Bữa ăn",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onSelected: (value) {
                _navigateToAddFood(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "breakfast",
                  child: Text("Bữa sáng"),
                ),
                const PopupMenuItem(
                  value: "lunch",
                  child: Text("Bữa trưa"),
                ),
                const PopupMenuItem(
                  value: "dinner",
                  child: Text("Bữa tối"),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 🔥 TITLE MEAL HIỆN TẠI
        Text(
          "Bữa sáng - $total kcal",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // 🔥 LIST FOOD
        ...meals.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(e["name"].toString()),
                  Text("${e["gram"]}g"),
                  Text("${e["kcal"]} kcal"),
                ],
              ),
            )),
      ],
    ),
  );
}
  void _navigateToAddFood(String mealType) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddFoodScreen(mealType: mealType),
    ),
  );
}
  // ================= WEIGHT =================
  Widget _buildWeightHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Cân nặng: ${currentWeight.toStringAsFixed(1)} kg",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: pastelGreen),
            onPressed: _showWeightSheet,
          ),
        ],
      ),
    );
  }

  // ================= CHART =================
  Widget _buildChart() {
    return Container(
      height: 220, // 🔥 FIX: set height cố định
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: filteredWeightData,
              isCurved: true,
              color: pastelGreen,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
class AppleProgressPainter extends CustomPainter {
  final double progress;

  AppleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    // 🔥 shape quả táo chuẩn hơn
    path.moveTo(w * 0.5, h * 0.22);

    // lõm trên trái
    path.cubicTo(
      w * 0.35, h * 0.05,
      w * 0.1, h * 0.25,
      w * 0.15, h * 0.55,
    );

    // thân trái xuống đáy
    path.cubicTo(
      w * 0.2, h * 0.85,
      w * 0.4, h * 0.95,
      w * 0.5, h * 0.9,
    );

    // đáy qua phải
    path.cubicTo(
      w * 0.6, h * 0.95,
      w * 0.8, h * 0.85,
      w * 0.85, h * 0.55,
    );

    // thân phải lên top
    path.cubicTo(
      w * 0.9, h * 0.25,
      w * 0.65, h * 0.05,
      w * 0.5, h * 0.22,
    );

    // 🎨 nền
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, bgPaint);

    // 🎯 progress
    final metric = path.computeMetrics().first;
    final extractPath =
        metric.extractPath(0, metric.length * progress);

    final progressPaint = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(extractPath, progressPaint);

    // 🌿 cuống
    final stemPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.5, h * 0.15),
      Offset(w * 0.52, h * 0.02),
      stemPaint,
    );

    // 🍃 lá
    final leafPath = Path();
    leafPath.moveTo(w * 0.52, h * 0.08);
    leafPath.cubicTo(
      w * 0.8, h * 0.0,
      w * 0.9, h * 0.2,
      w * 0.6, h * 0.18,
    );

    canvas.drawPath(
      leafPath,
      Paint()
        ..color = const Color(0xFFA5D6A7)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant AppleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}