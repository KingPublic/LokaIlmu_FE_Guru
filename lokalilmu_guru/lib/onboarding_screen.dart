// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'register.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();
//   int _currentPage = 0;

//   final List<Map<String, String>> onboardingData = [
//     {
//       'title': 'Selamat Datang!',
//       'desc': 'Ini adalah halaman onboarding pertama kamu.',
//     },
//     {
//       'title': 'Akses Mudah',
//       'desc': 'Dapatkan kemudahan akses ilmu pengetahuan.',
//     },
//     {
//       'title': 'Gabung Sekarang',
//       'desc': 'Yuk mulai dan daftarkan dirimu!',
//     },
//   ];

//   void _nextPage() {
//     if (_currentPage < onboardingData.length - 1) {
//       _controller.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//     } else {
//       _finishOnboarding();
//     }
//   }

//   Future<void> _finishOnboarding() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('seenOnboarding', true);

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const RegisterScreen()),
//     );
//   }

//   Widget _buildDotIndicator(int index) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: _currentPage == index ? 12 : 8,
//       height: _currentPage == index ? 12 : 8,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: _currentPage == index ? Colors.blueAccent : Colors.grey,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView.builder(
//         controller: _controller,
//         itemCount: onboardingData.length,
//         onPageChanged: (index) {
//           setState(() => _currentPage = index);
//         },
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 //  Gantikan Container ini dengan animasi atau SVG nanti
//                 Expanded(
//                   child: Center(
//                     child: Container(
//                       width: 200,
//                       height: 200,
//                       color: Colors.amber[200],
//                       child: const Center(child: Text("Animasi di sini")),
//                     ),
//                   ),
//                 ),
//                 Text(
//                   onboardingData[index]['title']!,
//                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   onboardingData[index]['desc']!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     onboardingData.length,
//                     (i) => _buildDotIndicator(i),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _nextPage,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Text(
//                     _currentPage == onboardingData.length - 1 ? 'Selesai' : 'Lanjut',
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
