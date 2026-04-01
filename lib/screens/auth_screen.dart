import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;

  const AuthScreen({super.key, required this.initialTab});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final primaryPurple = const Color(0xFFD1C4E9);
  final pastelGreen = const Color(0xFFA5D6A7);

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLogin(),
                _buildRegister(),
              ],
            ),
          ),
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
          // back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Text(
            "Welcome",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB =================
  Widget _buildTabBar() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: TabBar(
      controller: _tabController,

      // 🔥 underline indicator
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 3,
          color: Color(0xFFD1C4E9), // tím pastel
        ),
        insets: EdgeInsets.symmetric(horizontal: 40),
      ),

      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,

      labelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

      tabs: const [
        Tab(text: "Đăng nhập"),
        Tab(text: "Đăng ký"),
      ],
    ),
  );
}

  // ================= LOGIN =================
  Widget _buildLogin() {
    return _buildForm(
      isRegister: false,
    );
  }

  // ================= REGISTER =================
  Widget _buildRegister() {
    return _buildForm(
      isRegister: true,
    );
  }

  // ================= FORM =================
  Widget _buildForm({required bool isRegister}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isRegister)
            _buildTextField("Tên", Icons.person),

          if (isRegister) const SizedBox(height: 16),

          _buildTextField("Email", Icons.email),

          const SizedBox(height: 16),

          _buildTextField("Mật khẩu", Icons.lock, isPassword: true),

          if (isRegister) const SizedBox(height: 16),

          if (isRegister)
            _buildTextField("Xác nhận mật khẩu", Icons.lock, isPassword: true),

          const SizedBox(height: 24),

          _buildButton(isRegister),
        ],
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _buildTextField(String label, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),

        labelText: label,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryPurple, width: 2),
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _buildButton(bool isRegister) {
    return SizedBox(
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
        onPressed: () {},
        child: Text(
          isRegister ? "Đăng ký" : "Đăng nhập",
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white, // contrast đẹp
          ),
        ),
      ),
    );
  }
}