import 'package:flutter/material.dart';

class Foods extends StatelessWidget {
  const Foods({super.key});

  @override
  Widget build(BuildContext context) {
    final foods = ["Chicken Salad", "Oatmeal", "Salmon", "Eggs"];

    return Scaffold(
      appBar: AppBar(title: const Text("Foods")),
      body: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (_, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(foods[index]),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}