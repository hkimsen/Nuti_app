import 'package:flutter/material.dart';

class MealScreen extends StatelessWidget {
  final double bmi;

  const MealScreen({super.key, required this.bmi});

  final List<String> meals = const [
    "Breakfast: Oatmeal",
    "Lunch: Chicken Salad",
    "Dinner: Salmon & Veggies"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal Plan")),
      body: ListView.builder(
        itemCount: meals.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(meals[index]),
          );
        },
      ),
    );
  }
}