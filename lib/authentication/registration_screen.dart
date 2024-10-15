import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:user_application/authentication/login_screen.dart';
import 'package:user_application/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user_application/widgets/loading_dialog.dart';
import '../methods/signInWithGoogle.dart';
import '../widgets/main_screen.dart';

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

  bool isPasswordVisible = false; // Add this boolean to track the password visibility

  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  String confirmPasswordError = ''; // Add error for confirm password field

  validateSignUpForm() async {
    final String name = userNameTextEditingController.text.trim();
    final String phone = userPhoneTextEditingController.text.trim();
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();
    final String confirmPassword = confirmPasswordTextEditingController.text.trim();

    // RegEx patterns
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z ]{3,}$');
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~.])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      nameError = '';
      phoneError = '';
      emailError = '';
      passwordError = '';
      confirmPasswordError = '';
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
        passwordError = "Password must be at least 8 characters long, include an \nuppercase letter, a number, and a special character.";
      });
      hasError = true;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = "Passwords do not match.";
        passwordError = "Passwords do not match.";
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
      toast.showToastMsg("Account created successfully", context);

      // Redirects user to homepage if user's account is valid
      Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50,),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous screen
                },
              ),
              const SizedBox(height: 40),
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), // 5% padding from the left
                child: const Text(
                  "Sign Up",
                  textAlign: TextAlign.left, // Align to the left
                  style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), // 5% padding from the left
                child: const Text(
                  "Lorem Ipsum is simply dummy text of the\nLorem Ipsum has been the industry's",
                  textAlign: TextAlign.left, // Align to the left
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey
                  ),
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
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: nameError.isEmpty ? null : nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
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
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: phoneError.isEmpty ? null : phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
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
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: emailError.isEmpty ? null : emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
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
                      obscureText: !isPasswordVisible,
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: passwordError.isEmpty ? null : passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 22,),
                    // Confirm Password Text Field
                    TextField(
                      obscureText: !isPasswordVisible,
                      controller: confirmPasswordTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                        errorText: confirmPasswordError.isEmpty ? null : confirmPasswordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Register button
                    ElevatedButton(
                      onPressed: () {
                        validateSignUpForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.335,
                              vertical: 15
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Or Sign up with",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,),

                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    OutlinedButton(
                      onPressed: () {
                        AuthService.signInWithGoogle(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200, // Set background color
                        minimumSize: const Size(50, 50), // Adjust size for icon-only button
                        padding: const EdgeInsets.all(8), // Adjust padding
                        side: const BorderSide(
                          color: Colors.transparent, // Optional: keep border the same as background
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Image.asset(
                        "assets/images/google_icon.webp",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
              //Text Button that redirects users with existing account to log in screen
              Align(
                alignment: Alignment.center, // Align the button to the right
                child: TextButton(
                  onPressed: null, // No action needed for the button itself
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14, // Style for the first part of the text
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign In",
                          style: const TextStyle(
                            color: Colors.green, // Different color for the clickable text
                            fontWeight: FontWeight.w200, // Make the text bold
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
                            },
                        ),
                      ],
                    ),
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
