import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'personal_info_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;

  const AuthScreen({super.key, required this.initialTab});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final aiService = AiService();

  final primaryPurple = const Color(0xFFD1C4E9);
  final pastelGreen = const Color(0xFFA5D6A7);

  // Login fields
  final emailLoginCtrl = TextEditingController();
  final passwordLoginCtrl = TextEditingController();

  // Signup fields
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailSignupCtrl = TextEditingController();
  final passwordSignupCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool isLoadingLogin = false;
  bool isLoadingSignup = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    emailLoginCtrl.dispose();
    passwordLoginCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailSignupCtrl.dispose();
    passwordSignupCtrl.dispose();
    confirmPasswordCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (emailLoginCtrl.text.isEmpty || passwordLoginCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    setState(() => isLoadingLogin = true);

    try {
      final result = await aiService.login(
        email: emailLoginCtrl.text,
        password: passwordLoginCtrl.text,
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', result['id']);
      prefs.setString('firstName', result['firstName'] ?? '');
      prefs.setString('lastName', result['lastName'] ?? '');
      prefs.setString('email', result['email'] ?? '');
      prefs.setString('phone', result['phone'] ?? '');

      // Check if user has health info
      if (result['height'] == null) {
        // Needs to fill personal info
        Navigator.of(context).pushReplacementNamed('/personal-info');
      } else {
        // Has health info, go to home
        prefs.setDouble('height', (result['height'] as num).toDouble());
        prefs.setDouble('weight', (result['weight'] as num).toDouble());
        prefs.setDouble('bmi', (result['bmi'] as num).toDouble());
        prefs.setString('gender', result['gender'] ?? '');
        prefs.setString('goal', result['goal'] ?? '');

        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoadingLogin = false);
    }
  }

  Future<void> _handleSignup() async {
    if (firstNameCtrl.text.isEmpty ||
        lastNameCtrl.text.isEmpty ||
        emailSignupCtrl.text.isEmpty ||
        passwordSignupCtrl.text.isEmpty ||
        confirmPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (passwordSignupCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }

    setState(() => isLoadingSignup = true);

    try {
      await aiService.signup(
        firstName: firstNameCtrl.text,
        lastName: lastNameCtrl.text,
        email: emailSignupCtrl.text,
        password: passwordSignupCtrl.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công, vui lòng đăng nhập")),
      );

      // Pre-fill login form with signup email
      emailLoginCtrl.text = emailSignupCtrl.text;
      passwordLoginCtrl.text = passwordSignupCtrl.text;

      // Clear signup form
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailSignupCtrl.clear();
      passwordSignupCtrl.clear();
      confirmPasswordCtrl.clear();

      // Switch to login tab
      _tabController.animateTo(0, duration: const Duration(milliseconds: 300));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoadingSignup = false);
    }
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
                _buildSignup(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3,
            color: Color(0xFFD1C4E9),
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

  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField("Email", Icons.email, emailLoginCtrl),
          const SizedBox(height: 16),
          _buildTextField("Mật khẩu", Icons.lock, passwordLoginCtrl,
              isPassword: true),
          const SizedBox(height: 24),
          _buildButton(
            "Đăng nhập",
            isLoadingLogin,
            _handleLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildSignup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField("Tên", Icons.person, firstNameCtrl),
          const SizedBox(height: 16),
          _buildTextField("Họ", Icons.person_outline, lastNameCtrl),
          const SizedBox(height: 16),
          _buildTextField("Email", Icons.email, emailSignupCtrl),
          const SizedBox(height: 16),
          _buildTextField("Mật khẩu", Icons.lock, passwordSignupCtrl,
              isPassword: true),
          const SizedBox(height: 16),
          _buildTextField("Xác nhận mật khẩu", Icons.lock, confirmPasswordCtrl,
              isPassword: true),
          const SizedBox(height: 24),
          _buildButton(
            "Đăng ký",
            isLoadingSignup,
            _handleSignup,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
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

  Widget _buildButton(
    String label,
    bool isLoading,
    VoidCallback onPressed,
  ) {
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
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
