import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:user_application/authentication/login_screen.dart';
import 'package:user_application/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user_application/widgets/loading_dialog.dart';
import 'package:user_application/pages/home_page.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  String nameError = '';
  String phoneError = '';
  String emailError = '';
  String passwordError = '';

  validateSignUpForm() {
    final String name = userNameTextEditingController.text.trim();
    final String phone = userPhoneTextEditingController.text.trim();
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();

    // RegEx patterns
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]{3,}$');
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      nameError = '';
      phoneError = '';
      emailError = '';
      passwordError = '';
    });

    bool hasError = false;

    if (!nameRegExp.hasMatch(name)) {
      setState(() {
        nameError = "Name must be at least 3 letters or more characters.";
      });
      hasError = true;
    }

    if (phone.length != 11) {
      setState(() {
        phoneError = "Invalid phone number. Must be exactly 11 digits.";
      });
      hasError = true;
    }

    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        emailError = "Invalid email address.";
      });
      hasError = true;
    }

    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passwordError = "Password should be: "
            "\nAt least 8 characters long "
            "\nMinimum one uppercase"
            "\nMinimum one number"
            "\nMinimum one symbol";
      });
      hasError = true;
    }

    if (!hasError) {
      signUpUserNow();
    }
  }

  signUpUserNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageTxt: "Please wait..."),
    );

    try {
      final User? firebaseUser = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      )).user;

      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
      };

      await FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid).set(userDataMap);

      Navigator.pop(context);
      snackBar.showSnackBarMsg("Account created successfully", context);

      // Redirects user to homepage if user's account is valid
      Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
    } on FirebaseAuthException catch (ex) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      setState(() {
        emailError = ex.message ?? "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 52,),
              Image.asset(
                "assets/images/signup.webp",
                width: MediaQuery.of(context).size.width * .6,
              ),
              const SizedBox(height: 10,),
              const Text(
                "Hello!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900
                ),
              ),
              const Text(
                "Create new Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Username Text Field
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: nameError.isEmpty ? null : nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22,),
                    // User Phone Text Field
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: phoneError.isEmpty ? null : phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22,),
                    // Email Text Field
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: emailError.isEmpty ? null : emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22,),
                    // Password Text Field
                    TextField(
                      obscureText: true,
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: passwordError.isEmpty ? null : passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 42,),
                    // Register button
                    ElevatedButton(
                      onPressed: () {
                        validateSignUpForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 130, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: const Text(
                          "Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 0.1),

              //Text Button that redirects users with existing account to log in screen
              TextButton(
                onPressed: null, // No action needed for the button itself
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: Colors.grey, // Style for the first part of the text
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Login here",
                        style: const TextStyle(
                          color: Colors.blue, // Different color for the clickable text
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
