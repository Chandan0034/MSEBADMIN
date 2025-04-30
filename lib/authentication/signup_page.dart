import 'package:admin/authentication/firebase_auth_service.dart';
import 'package:flutter/material.dart';

import '../Worker/worker_home_page.dart';
import '../pages/dashboard_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isObscure = true;
  bool _isLoading = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedValue;
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // location.getLiveLocation();
  }

  Future<void> _registerUser() async {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user already exists in Firestore
      bool userExists = await _authService.checkUserExists(_emailController.text.trim(),selectedValue!);

      if (userExists) {
        // Show error if user already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists. Please log in.")),
        );
      } else {
        // Register the user if they do not exist
        bool register=await _authService.registerUser(
          _emailController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _passwordController.text.trim(),
          selectedValue!,
        );

        // Navigate to DashboardPage on successful registration
        if(register){
          if(selectedValue=="admin"){
            Navigator.of(context).pushAndRemoveUntil(
              _noTransitionRoute(DashboardPage()),
                  (Route<dynamic> route) => false,
            );
          }else{
            Navigator.of(context).pushAndRemoveUntil(
              _noTransitionRoute(WorkerHomePage()),
                  (Route<dynamic> route) => false,
            );
          }
        }else{

        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey, // Wrap your fields with the Form widget
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
                      'Create an Account',
                      style: TextStyle(
                        color: Color(0xFF1D1517),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // First Name TextField
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
                  TextFormField(
                    controller: _firstNameController,
                    decoration: _buildInputDecoration('First Name', Icons.account_circle_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill the First Name field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Last Name TextField
                  TextFormField(
                    controller: _lastNameController,
                    decoration: _buildInputDecoration('Last Name', Icons.account_circle_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill the Last Name field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('Email', Icons.mail),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill the Email field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: _buildInputDecoration(
                      'Password',
                      Icons.lock,
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill the Password field';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _isLoading ? null : _registerUser, // Disable if loading
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
                          'Register',
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
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      Text(
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
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(_noTransitionRoute(const LoginPage()));
                      },
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF1D1517),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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

  InputDecoration _buildInputDecoration(String hintText, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.withOpacity(.2),
      hintText: hintText,
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
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
    );
  }
}

Route _noTransitionRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
