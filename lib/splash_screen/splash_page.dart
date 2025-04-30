import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Worker/worker_home_page.dart';
import '../authentication/login_page.dart';
import '../pages/dashboard_page.dart';
class SecondSplashPage extends StatefulWidget {
  @override
  State<SecondSplashPage> createState() => _SecondSplashPageState();
}
class _SecondSplashPageState extends State<SecondSplashPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;  // To track if loading is in progress

  void getStarted(BuildContext context) async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String? userType = await _authService.getUserType(currentUser.email!);

      setState(() {
        _isLoading = false;  // Hide loading indicator once user type is fetched
      });

      if (userType == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()), // Admin Dashboard Page
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WorkerHomePage()), // Worker Page
        );
      }
    } else {
      setState(() {
        _isLoading = false;  // Hide loading indicator if the user is not logged in
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Login Page for unsigned users
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // Logo Section
            Column(
              children: [
                Image.asset(
                  'assets/Image/splash_screen_logo.png', // Add your logo image here
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
              ],
            ),
            Spacer(),
            // Get Started Button with Progress Indicator inside
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: 200,  // Fixed width for button
                child: InkWell(
                  onTap: _isLoading ? null : () {  // Disable button if loading
                    getStarted(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                        width: 24, // Set a fixed size for progress indicator
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,  // Adjust the thickness of the indicator
                        ),
                      )
                          : const Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: "Poppins"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
