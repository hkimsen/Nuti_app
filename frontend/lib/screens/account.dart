import 'package:flutter/material.dart';
import '../widgets/base_bottom_sheet.dart';
import '../services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SheetType {
  account,
  personal,
  password,
}

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String gender = "";
  String goal = "";
  double? height;
  double? weight;
  double? bmi;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "";
      lastName = prefs.getString('lastName') ?? "";
      email = prefs.getString('email') ?? "";
      phone = prefs.getString('phone') ?? "";
      gender = prefs.getString('gender') ?? "";
      goal = prefs.getString('goal') ?? "";
      height = prefs.getDouble('height');
      weight = prefs.getDouble('weight');
      bmi = prefs.getDouble('bmi');
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayName = "$firstName $lastName".trim();
    if (displayName.isEmpty) displayName = "Người dùng";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFFD1C4E9),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= MENU =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Column(
              children: [
                _menuItem(
                  icon: Icons.account_circle_outlined,
                  title: "Thông tin tài khoản",
                  onTap: () => _openSheet(context, SheetType.account),
                ),
                const Divider(),

                _menuItem(
                  icon: Icons.person_outline,
                  title: "Thông tin cá nhân",
                  onTap: () => _openSheet(context, SheetType.personal),
                ),
                const Divider(),

                _menuItem(
                  icon: Icons.lock_outline,
                  title: "Đổi mật khẩu",
                  onTap: () => _openSheet(context, SheetType.password),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ================= LOGOUT =================
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 191, 29, 18),
                side: const BorderSide(color: Color.fromARGB(255, 191, 29, 18)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                _confirmLogout(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Đăng xuất"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU ITEM =================
  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  // ================= OPEN SHEET =================
  void _openSheet(BuildContext context, SheetType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetContent(
        type: type,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        gender: gender,
        goal: goal,
        height: height,
        weight: weight,
      ),
    );
  }

  // ================= CONFIRM LOGOUT =================
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đăng xuất", textAlign: TextAlign.center),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.of(context).pushReplacementNamed('/get-started');
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}

//
// ================= SHEET CONTENT (🔥 CORE) =================
//
class _SheetContent extends StatefulWidget {
  final SheetType type;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String goal;
  final double? height;
  final double? weight;

  const _SheetContent({
    required this.type,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.goal,
    required this.height,
    required this.weight,
  });

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  bool isEdit = false;
  final aiService = AiService();

  // controllers
  late TextEditingController ho;
  late TextEditingController ten;
  late TextEditingController email;
  late TextEditingController phone;

  late TextEditingController height;
  late TextEditingController weight;

  late String gender;
  late String goal;

  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    ho = TextEditingController(text: widget.firstName);
    ten = TextEditingController(text: widget.lastName);
    email = TextEditingController(text: widget.email);
    phone = TextEditingController(text: widget.phone);
    height = TextEditingController(text: widget.height?.toString() ?? "170");
    weight = TextEditingController(text: widget.weight?.toString() ?? "65");
    gender = widget.gender.isEmpty ? "Nam" : widget.gender;
    goal = widget.goal.isEmpty ? "Giảm cân" : widget.goal;
  }

  @override
  void dispose() {
    ho.dispose();
    ten.dispose();
    email.dispose();
    phone.dispose();
    height.dispose();
    weight.dispose();
    oldPass.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }
  
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

  // ================= TITLE =================
  String get title {
    switch (widget.type) {
      case SheetType.account:
        return "Thông tin tài khoản";
      case SheetType.personal:
        return "Thông tin cá nhân";
      case SheetType.password:
        return "Đổi mật khẩu";
    }
  }

  // ================= CONTENT =================
  Widget buildContent() {
    switch (widget.type) {
      case SheetType.account:
        return Column(
          children: [
            buildField("Họ", ho, isEdit),
            buildField("Tên", ten, isEdit),
            buildField("Email", email, isEdit),
            buildField("Số điện thoại", phone, isEdit),
          ],
        );

      case SheetType.personal:
        return Column(
          children: [
            buildField("Chiều cao", height, isEdit),
            buildField("Cân nặng", weight, isEdit),
            buildDropdown(
              "Giới tính",
              gender,
              ["Nam", "Nữ"],
              isEdit,
              (v) => setState(() => gender = v),
            ),
            buildDropdown(
              "Mục tiêu",
              goal,
              ["Giảm cân", "Giữ dáng", "Tăng cân"],
              isEdit,
              (v) => setState(() => goal = v),
            ),
          ],
        );

      case SheetType.password:
        return Column(
          children: [
            buildField("Mật khẩu cũ", oldPass, isEdit, isPassword: true),
            buildField("Mật khẩu mới", newPass, isEdit, isPassword: true),
            buildField("Nhập lại mật khẩu", confirmPass, isEdit,
                isPassword: true),
          ],
        );
    }
  }

  void cancel() {
    setState(() => isEdit = false);
  }

 void save() async {
  if (widget.type == SheetType.account) {
    // ===== SAVE ACCOUNT INFO =====
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception("User não foi autenticado");
      }

      print("DEBUG: Saving account - userId=$userId, firstName=${ho.text}, lastName=${ten.text}, email=${email.text}, phone=${phone.text}");

      // Save to backend
      final response = await aiService.saveUserAccount(
        userId: userId,
        firstName: ho.text,
        lastName: ten.text,
        email: email.text,
        phone: phone.text,
      );
      
      print("DEBUG: Backend response: $response");

      // Save to local storage
      prefs.setString('firstName', ho.text);
      prefs.setString('lastName', ten.text);
      prefs.setString('email', email.text);
      prefs.setString('phone', phone.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lưu thông tin tài khoản thành công")),
        );
        setState(() => isEdit = false);
      }
    } catch (e) {
      print("DEBUG: Error saving account: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    }
    return;
  }

  if (widget.type == SheetType.personal) {
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);

    // ===== VALIDATE =====
    if (h == null || w == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nhập sai chiều cao hoặc cân nặng")),
      );
      return;
    }

    // ===== CALCULATE BMI =====
    final bmi = calculateBMI(w, h);
    final category = getBMICategory(bmi);

    // ===== SHOW RESULT =====
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "BMI: ${bmi.toStringAsFixed(1)} ($category)",
        ),
      ),
    );

    // ===== SAVE BACKEND =====
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    }
  }

  if (widget.type == SheetType.password) {
    if (newPass.text != confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }
  }

  setState(() => isEdit = false);
}

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: title,
      isEdit: isEdit,
      onEdit: () => setState(() => isEdit = true),
      onCancel: cancel,
      onSave: save,
      child: buildContent(),
    );
  }
}