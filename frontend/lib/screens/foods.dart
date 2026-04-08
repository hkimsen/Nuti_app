import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nutrition_app/services/ai_service.dart';

class Foods extends StatefulWidget {
  const Foods({super.key});

  @override
  State<Foods> createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  List foods = [];
  bool isLoading = true;

  final String baseUrl = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  Future<void> fetchFoods() async {
    final res = await http.get(Uri.parse('$baseUrl/foods'));

    setState(() {
      foods = json.decode(res.body);
      isLoading = false;
    });
  }

  // 🎯 MỤC 2: recommend
  Future<void> recommendFoods() async {
    final res = await http.get(
      Uri.parse('$baseUrl/foods/recommend?targetCalories=150'),
    );

    setState(() {
      foods = json.decode(res.body);
    });
  }

  Future<void> callAI() async {
    final ai = AiService();

    final result = await ai.getMealPlan({
      "weight": 65,
      "height": 170,
      "bmi": 22,
      "goal": "lose",
      "days": 7
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AI Meal Plan"),
        content: SingleChildScrollView(
          child: Text(result),
        ),
      ),
    );
  }

  // 🔄 MỤC 4: swap
  Future<void> swapFood(double calories) async {
    final res = await http.get(
      Uri.parse('$baseUrl/foods/swap?calories=$calories'),
    );

    final result = json.decode(res.body);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Gợi ý món tương đương"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: result.length,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text(result[i]['name']),
                subtitle: Text("${result[i]['calories']} kcal"),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foods"),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: recommendFoods, // 🎯 recommend
          ),
          IconButton(
            icon: Icon(Icons.smart_toy),
            onPressed: callAI,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: foods.length,
              itemBuilder: (_, index) {
                final food = foods[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(food['name']),
                    subtitle: Text("${food['calories']} kcal"),
                    trailing: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => swapFood(food['calories']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}