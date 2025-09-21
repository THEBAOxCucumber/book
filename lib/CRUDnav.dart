// import 'package:flutter/material.dart';
// import 'booktell.dart';
// // import 'screen2.dart';
// // import 'screen3.dart';

// class Crudnav extends StatelessWidget {
//   final VoidCallback onToggleTheme;
//   const Crudnav({super.key, required this.onToggleTheme});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home Page")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: Text("Go to Screen 1"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => BookTellScreen(onToggleTheme: onToggleTheme,)),
//                 );
//               },
//             ),
//             ElevatedButton(
//               child: Text("Go to Screen 2"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => BookTellScreen(onToggleTheme: onToggleTheme,)),
//                 );
//               },
//             ),
//             ElevatedButton(
//               child: Text("Go to Screen 3"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => BookTellScreen(onToggleTheme: onToggleTheme,)),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }