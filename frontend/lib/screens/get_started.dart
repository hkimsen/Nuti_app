import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9), // 🔥 nền tím pastel
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 LOGO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 70,
                  color: Colors.white, // 🔥 contrast tốt
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 TITLE
              const Text(
                "Nuti Health",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 50),

              // 🔥 LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // nền trắng
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: const Color(0xFFA5D6A7), width: 1), // viền xanh lá pastel
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth');
                  },
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      color: const Color(0xFFA5D6A7), 
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA5D6A7), // xanh lá pastel
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/auth-signup');
                  },
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(
                      color: Colors.white, // 🔥 contrast rõ
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}