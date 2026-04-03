import 'package:flutter/material.dart';

//
// ================= BASE SHEET =================
//
class BaseBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.isEdit = false,
    this.onEdit,
    this.onCancel,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75, // ✅ 75%
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ✅ scroll khi dài
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: child,
                ),                ),
              ),

              // ACTIONS
        Padding(
          padding: const EdgeInsets.only(bottom: 10), // 🔥 áp dụng cho tất cả
          child: Row(
            children: [
              // VIEW MODE
              if (!isEdit)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD1C4E9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onEdit,
                      child: const Text(
                        "Chỉnh sửa",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                ),

              // EDIT MODE
              if (isEdit) ...[
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onCancel,
                      child: const Text(
                        "Hủy",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB39DDB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onSave,
                      child: const Text(
                        "Lưu",
                        style: TextStyle(
                          color: Colors.black,
                          //fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        )
            ],
          ),
        );
      },
    );
  }
}

//
// ================= FIELD =================
//
Widget buildField(
    String label, TextEditingController ctrl, bool isEdit,
    {bool isPassword = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: ctrl,
      enabled: isEdit,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

//
// ================= DROPDOWN FIELD =================
//
Widget buildDropdown(
    String label,
    String value,
    List<String> items,
    bool isEdit,
    Function(String) onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: isEdit ? (v) => onChanged(v!) : null,
        ),
      ),
    ),
  );
}

//
// ================= ACCOUNT INFO =================
//
class AccountInfoSheet extends StatefulWidget {
  const AccountInfoSheet({super.key});

  @override
  State<AccountInfoSheet> createState() => _AccountInfoSheetState();
}

class _AccountInfoSheetState extends State<AccountInfoSheet> {
  bool isEdit = false;

  final ho = TextEditingController(text: "Kim");
  final ten = TextEditingController(text: "Sen");
  final email = TextEditingController(text: "user@gmail.com");
  final phone = TextEditingController(text: "0123456789");

  late String oldHo;
  late String oldTen;
  late String oldEmail;
  late String oldPhone;

  @override
  void initState() {
    super.initState();
    oldHo = ho.text;
    oldTen = ten.text;
    oldEmail = email.text;
    oldPhone = phone.text;
  }

  void cancel() {
    ho.text = oldHo;
    ten.text = oldTen;
    email.text = oldEmail;
    phone.text = oldPhone;
    setState(() => isEdit = false);
  }

  void save() {
    oldHo = ho.text;
    oldTen = ten.text;
    oldEmail = email.text;
    oldPhone = phone.text;
    setState(() => isEdit = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: "Thông tin tài khoản",
      isEdit: isEdit,
      onEdit: () => setState(() => isEdit = true),
      onCancel: cancel,
      onSave: save,
      child: Column(
        children: [
          buildField("Họ", ho, isEdit),
          buildField("Tên", ten, isEdit),
          buildField("Email", email, isEdit),
          buildField("Số điện thoại", phone, isEdit),
        ],
      ),
    );
  }
}

//
// ================= PERSONAL INFO =================
//
class PersonalInfoSheet extends StatefulWidget {
  const PersonalInfoSheet({super.key});

  @override
  State<PersonalInfoSheet> createState() => _PersonalInfoSheetState();
}

class _PersonalInfoSheetState extends State<PersonalInfoSheet> {
  bool isEdit = false;

  final height = TextEditingController(text: "170");
  final weight = TextEditingController(text: "65");

  String gender = "Nam";
  String goal = "Giảm cân";

  late String oldGender;
  late String oldGoal;
  late String oldHeight;
  late String oldWeight;

  @override
  void initState() {
    super.initState();
    oldGender = gender;
    oldGoal = goal;
    oldHeight = height.text;
    oldWeight = weight.text;
  }

  void cancel() {
    gender = oldGender;
    goal = oldGoal;
    height.text = oldHeight;
    weight.text = oldWeight;
    setState(() => isEdit = false);
  }

  void save() {
    oldGender = gender;
    oldGoal = goal;
    oldHeight = height.text;
    oldWeight = weight.text;
    setState(() => isEdit = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: "Thông tin cá nhân",
      isEdit: isEdit,
      onEdit: () => setState(() => isEdit = true),
      onCancel: cancel,
      onSave: save,
      child: Column(
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
      ),
    );
  }
}

//
// ================= CHANGE PASSWORD =================
//
class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  bool isEdit = false;

  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  void cancel() {
    oldPass.clear();
    newPass.clear();
    confirmPass.clear();
    setState(() => isEdit = false);
  }

  void save() {
    if (newPass.text != confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }
    setState(() => isEdit = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: "Đổi mật khẩu",
      isEdit: isEdit,
      onEdit: () => setState(() => isEdit = true),
      onCancel: cancel,
      onSave: save,
      child: Column(
        children: [
          buildField("Mật khẩu cũ", oldPass, isEdit, isPassword: true),
          buildField("Mật khẩu mới", newPass, isEdit, isPassword: true),
          buildField("Nhập lại mật khẩu", confirmPass, isEdit,
              isPassword: true),
        ],
      ),
    );
  }
}