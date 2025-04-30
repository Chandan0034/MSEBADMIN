import 'package:admin/pages/report_update_screen.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 25,),
            AppBarLayout(),
            Expanded(child: const ReportUpdateScreen()),
          ],
        ),
      ),
    );;
  }
}

class AppBarLayout extends StatelessWidget {
  const AppBarLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color with opacity
            spreadRadius: 2, // Spread radius (how far the shadow spreads)
            blurRadius: 10, // Blur radius (how soft the shadow is)
            offset: Offset(0, 3), // Offset (x, y): x -> horizontal, y -> vertical
          ),
        ],
      ),
      height: 70,
      // Height of the custom app bar
      // color: Colors.white,
      // Background color
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // Side padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Spacing between elements
        crossAxisAlignment: CrossAxisAlignment.center,
        // Vertical alignment
        children: [
          // Leading icon (e.g., a globe icon for language)
          // Container(
          //   margin: EdgeInsets.only(top: 8),
          //   width: 32,
          //   height: 32,
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFF1F9FF),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: IconButton(
          //     icon: const Icon(Icons.language, color: Colors.black),
          //     iconSize: 18,
          //     onPressed: () {
          //       // Add action for leading icon
          //     },
          //   ),
          // ),
          // Title (Image + Text)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Image/logo.png',
                  height: 37,
                  width: 37,
                  fit: BoxFit.contain,
                ),
                const Text(
                  " Admin",

                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,
                    fontSize: 23,

                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Action icon (e.g., notification button)
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.language, color: Colors.black),
                iconSize: 25,
                onPressed: () {
                  // Add action for notifications
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
