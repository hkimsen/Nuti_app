// import 'package:flutter/material.dart';
// import 'home.dart';
// import 'foods.dart';
// import 'account.dart';

// class Root extends StatefulWidget {
//   const Root({super.key});

//   @override
//   State<Root> createState() => _RootState();
// }

// class _RootState extends State<Root> {
//   int currentIndex = 0;

//   final List<Widget> pages = const [
//     Home(),
//     Foods(),
//     Account(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: currentIndex,
//         onDestinationSelected: (index) {
//           setState(() => currentIndex = index);
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home),
//             label: "Home",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.restaurant_outlined),
//             selectedIcon: Icon(Icons.restaurant),
//             label: "Foods",
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_outline),
//             selectedIcon: Icon(Icons.person),
//             label: "Account",
//           ),
//         ],
//       ),
//     );
//   }
// }