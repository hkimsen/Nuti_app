import 'package:flutter/material.dart';
import '../widgets/base_bottom_sheet.dart';

enum SheetType {
  account,
  personal,
  password,
}

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.person, size: 40),
                ),
                SizedBox(height: 10),
                Text(
                  "Kim Sen",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("123"),
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
      builder: (_) => _SheetContent(type: type),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã đăng xuất")),
              );
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

  const _SheetContent({required this.type});

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  bool isEdit = false;

  // controllers
  final ho = TextEditingController(text: "Kim");
  final ten = TextEditingController(text: "Sen");
  final email = TextEditingController(text: "user@gmail.com");
  final phone = TextEditingController(text: "0123456789");

  final height = TextEditingController(text: "170");
  final weight = TextEditingController(text: "65");

  String gender = "Nam";
  String goal = "Giảm cân";

  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

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

  void save() {
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