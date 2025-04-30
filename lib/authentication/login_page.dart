import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:admin/authentication/signup_page.dart';
import 'package:flutter/material.dart';

import '../Worker/worker_home_page.dart';
import '../pages/dashboard_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
} 

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  bool _isLoading = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  String? selectedValue;
  // Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _passwordError; // Variable to hold password error message
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // location.getLiveLocation();
  }
  Future<void> _loginUser() async {
    setState(() {
      _passwordError = null; // Reset error message on login attempt
    });

    // Validate the form first
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading state
      });

      try {
        bool userExists = await _authService.checkUserExists(_emailController.text.trim(),selectedValue!);

        if (!userExists) {
          // Show error if user does not exist
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User does not exist. Please register.")),
          );
        } else {
          // Proceed to login if user exists
          bool loginSuccess = await _authService.loginUser(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          if (!loginSuccess) {
            // Set password error if login fails
            setState(() {
              _passwordError = 'Password is incorrect. Please try again.'; // Set the password error message
            });
            // Trigger a rebuild of the password field to show the error
            _formKey.currentState!.validate(); // Re-validate to show the error
          } else {
            // Navigate to DashboardPage on successful login
            if(selectedValue=="admin"){
              Navigator.of(context).pushAndRemoveUntil(
                _noTransitionRoute(const DashboardPage()),
                    (Route<dynamic> route) => false,
              );
            }else{
              Navigator.of(context).pushAndRemoveUntil(
                _noTransitionRoute(const WorkerHomePage()),
                    (Route<dynamic> route) => false,
              );
            }
          }
        }
      } catch (e) {
        // Display error message for any other failed login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      }
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (_passwordError != null) {
      return _passwordError; // Return the password error message if set
    }
    return null; // Return null if no errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 70),
                  const Center(
                    child: Text(
                      'Hey there,',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  DropdownButton<String>(
                    value: selectedValue,
                    hint: Text('Select an option'),
                    items: <String>['admin', 'worker']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue; // Update the selected value
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  // Email TextField with validation
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(.4),
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                        color: Color(0xFF544E4E),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      prefixIcon: const Icon(Icons.mail),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password TextField with validation
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(.5),
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF544E4E),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black.withOpacity(.5),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _isLoading ? null : _loginUser,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : const Color(0xFF37718E),
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4C95ADFE),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider and OR text
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      const Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(
                        'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                      ),
                      const SizedBox(width: 20),
                      _buildSocialIcon(
                        'https://cdn-icons-png.flaticon.com/512/145/145802.png',
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Sign Up prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF544E4E),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                              _noTransitionRoute(SignupPage())
                          );
                        },
                        child: const Text(
                          ' Sign Up',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF37718E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSocialIcon(String url) {
    return Container(
      height: 45,
      width: 45,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.network(
          url,
          width: 25,
          height: 25,
        ),
      ),
    );
  }
  Route _noTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );
  }
}
