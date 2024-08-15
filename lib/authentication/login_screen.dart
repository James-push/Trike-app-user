import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_application/authentication/passwordreset_screen.dart';
import 'package:user_application/authentication/registration_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:user_application/global.dart';
import 'package:user_application/pages/home_page.dart';
import 'package:user_application/widgets/error_dialog.dart';
import 'package:user_application/widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  //change example 1

  String emailError = '';
  String passwordError = '';

  validateLogInForm() async {
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();

    // RegEx patterns
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

    setState(() {
      emailError = '';
      passwordError = '';
    });

    bool hasError = false;

    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        emailError = "Invalid email address.";
      });
      hasError = true;
    }

    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passwordError = "Invalid password.";
      });
      hasError = true;
    }

    if (!hasError) {
      try {
        await LogInUserNow();
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            emailError = "Couldn't find your Trike Account";
          } else if (e.code == 'wrong-password') {
            passwordError = "Incorrect email or password.";
          } else if (e.code == 'invalid-credential') {
            emailError = "Incorrect email or password.";
            passwordError = "Incorrect email or password.";
          } else {
            showErrorDialog(context, "An error occurred. Please try again.");
          }
        });
      }
    }
  }

  LogInUserNow() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Please wait...")

    );

    try {
      final User? firebaseUser = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()
          ).catchError((error) {
            Navigator.pop(context);

            //exception handling
            if (error is FirebaseAuthException) {
              switch (error.code) {
                case 'invalid-email':
                  emailError = "Invalid email.";
                  break;
                case 'user-disabled':
                  emailError = "This user has been disabled.";
                  break;
                case 'invalid-credential':
                  emailError = "Incorrect email or password.";
                  passwordError = "Incorrect email or password.";
                  break;
                case 'wrong-password':
                  passwordError = "Incorrect password. Please try again.";
                  break;
                case 'network-request-failed':
                  showErrorDialog(context, "Connection error. Please check your internet connection and try again.");
                  break;
                case 'too-many-requests':
                  showErrorDialog(context, "Your account has been temporarily disabled due to multiple failed login attempts. Please try again later.");
                default:
                  showErrorDialog(context, "An error occurred. Please try again.");
                  break;
              }
            } else {
              // Handle any other errors
              setState(() {
                showErrorDialog(context, "An unexpected error occurred. Please try again.");
              });
            }
          })
      ).user;

      //fetching the user's information
      if (firebaseUser != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid);
        await ref.once().then((dataSnapshot) {
          if (dataSnapshot.snapshot.value != null) {
            if ((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no") {
              userName = (dataSnapshot.snapshot.value as Map)["name"];
              userPhone = (dataSnapshot.snapshot.value as Map)["phone"];

              snackBar.showSnackBarMsg("Logged in Successfully", context);
              // Redirects user to homepage if user's account is not blocked
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));

            } else {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              setState(() {
                passwordError = "Your account is blocked. Contact admin: jssjmssantos@gmail.com";
              });
            }
          } else {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            setState(() {
              passwordError = "Your account doesn't exist.";
            });
          }
        });
      }

    } on FirebaseAuthException catch (ex) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      setState(() {
        passwordError = ex.message ?? "An error occurred. Please try again.";
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 52,),
              Image.asset(
                "assets/images/signin.webp",
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
                "Sign into your Account",
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
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
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
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PasswordResetScreen()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                    const SizedBox(height: 62,),
                    // Log in button
                    ElevatedButton(
                      onPressed: () {
                        validateLogInForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: const Text(
                          "Log in",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    // Sign up link
                    TextButton(
                      onPressed: null, // No action needed for the button itself
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.grey, // Style for the first part of the text
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Register",
                              style: const TextStyle(
                                color: Colors.blue, // Different color for the clickable text
                                fontWeight: FontWeight.bold, // Make the text bold
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => RegistrationScreen()));
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
