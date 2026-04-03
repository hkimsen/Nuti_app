import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../widgets/base_bottom_sheet.dart';

class AddFoodScreen extends StatefulWidget {
  final String mealType;

  const AddFoodScreen({super.key, required this.mealType});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final primaryPurple = const Color(0xFFD1C4E9);

  String search = "";

  final List<Map<String, dynamic>> foods = [
  {
    "name": "Trứng luộc",
    "kcal": 155,
    "carb": 1,
    "protein": 13,
    "fat": 11,
  },
  {
    "name": "Bánh mì",
    "kcal": 200,
    "carb": 40,
    "protein": 6,
    "fat": 2,
  },
];

void _showFoodBottomSheet(Map<String, dynamic> food) {
  final controller = TextEditingController(text: "100");

  double gram = 100;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          final ratio = gram / 100;
          final kcal =
              (food["kcal"] as num).toDouble() * (gram / 100);
          final carb = (food["carb"] as num).toDouble() * ratio;
          final protein = (food["protein"] as num).toDouble() * ratio;
          final fat = (food["fat"] as num).toDouble() * ratio;

          return BaseBottomSheet(
            title: food["name"],
            isEdit: true,
            onCancel: () => Navigator.pop(context),
            onSave: () {
              print("Add ${food["name"]} - $gram g");
              Navigator.pop(context);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGramInput(controller, (value) {
                  setState(() {
                    gram = double.tryParse(value) ?? 0;
                  });
                }),
                const SizedBox(height: 20),
                _buildAnimatedMacroSection(carb, protein, fat, kcal),
                const SizedBox(height: 10), // 👈 thêm dòng này
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildAnimatedMacroSection(
    double carb, double protein, double fat, double kcal) {
  final total = carb + protein + fat;

  return Container(
    padding: const EdgeInsets.fromLTRB(90, 20, 90, 20), // Tăng padding để thoáng hơn
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 10,
        ),
      ],
    ),
    child: Row(
      children: [
        // 🍩 CHART + KCAL
        SizedBox(
          width: 130, // Điều chỉnh lại size chart một chút
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: carb,
                      color: const Color(0xFF90CAF9),
                      radius: 20, // Độ dày của vòng tròn
                      title: "",
                    ),
                    PieChartSectionData(
                      value: protein,
                      color: const Color(0xFFA5D6A7),
                      radius: 20,
                      title: "",
                    ),
                    PieChartSectionData(
                      value: fat,
                      color: const Color(0xFFFFCC80),
                      radius: 20,
                      title: "",
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${kcal.toInt()}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "kcal",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width:40), 

        // 📊 LEGEND (Phần chú thích)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa cụm chú thích theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment.stretch, // BẮT BUỘC: Để Row bên trong chiếm hết chiều ngang
            children: [
              _legendItem("Tinh bột", const Color(0xFF90CAF9), carb),
              _legendItem("Đạm", const Color(0xFFA5D6A7), protein),
              _legendItem("Béo", const Color(0xFFFFCC80), fat),
            ],
          ),
        ),
      ],
    ),
  );
}

  List<Map<String, dynamic>> get filteredFoods {
    return foods
        .where((food) =>
            food["name"].toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  String get mealTitle {
    switch (widget.mealType) {
      case "breakfast":
        return "Bữa sáng";
      case "lunch":
        return "Bữa trưa";
      case "dinner":
        return "Bữa tối";
      default:
        return "Bữa ăn";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [
          _buildHeader(),
          _buildSearch(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            "Thêm món - $mealTitle",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => search = value),
        decoration: InputDecoration(
          hintText: "Tìm món ăn...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _buildList() {
    return ListView.builder(
      itemCount: filteredFoods.length,
      itemBuilder: (context, index) {
        final food = filteredFoods[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _showFoodBottomSheet(food);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    food["name"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "100 g - ${food["kcal"]} kcal",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // ================= GRAM INPUT =================
  Widget _buildGramInput(
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: "Khối lượng (gram)",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  // ================= MACRO CHART =================
Widget _buildMacroChart(Map<String, dynamic> food) {
  final carb = (food["carb"] as num).toDouble();
  final protein = (food["protein"] as num).toDouble();
  final fat = (food["fat"] as num).toDouble();

  return SizedBox(
    height: 180,
    child: PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: carb,
            color: Colors.blue,
            title: "Carb",
          ),
          PieChartSectionData(
            value: protein,
            color: Colors.green,
            title: "Protein",
          ),
          PieChartSectionData(
            value: fat,
            color: Colors.orange,
            title: "Fat",
          ),
        ],
      ),
    ),
  );
}

  // ================= GRAM INPUT =================


Widget _legendItem(String label, Color color, double value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0), // Tạo khoảng cách dọc giữa các dòng
    child: Row(
      children: [
        // Chấm màu đại diện
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle, // Hình tròn nhìn sẽ hiện đại hơn
          ),
        ),
        const SizedBox(width: 8),
        // Tên chú thích
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        
        // CÂY GẬY THẦN KỲ: Đẩy mọi thứ sau nó về bên phải
        const Spacer(), 
        
        // Giá trị số
        Text(
          "${value.toInt()}g",
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}

}