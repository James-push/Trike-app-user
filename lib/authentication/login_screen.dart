import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_application/authentication/passwordreset_screen.dart';
import 'package:user_application/authentication/registration_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:user_application/global.dart';
import 'package:user_application/widgets/main_screen.dart';
import 'package:user_application/widgets/error_dialog.dart';
import 'package:user_application/widgets/loading_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../methods/signInWithGoogle.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool isPasswordVisible = false; // Add this boolean to track the password visibility


  String emailError = '';
  String passwordError = '';

  @override
  void initState() {
    super.initState();

    // Overlay the status bar and navigation bar
   // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Optionally, you can also hide the status bar with the code below:
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Colors.transparent, // Transparent status bar
       systemNavigationBarColor: Colors.transparent, // Transparent navigation bar
     ));
  }

  @override
  void dispose() {
    // Reset the system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  validateLogInForm() async {
    final String email = emailTextEditingController.text.trim();
    final String password = passwordTextEditingController.text.trim();

    // RegEx patterns
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    final RegExp passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[!@#$&*~])(?=.*[0-9])(?=.*[a-z]).{8,}$');

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

    // Check for internet connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
            titlemessageTxt: "No Internet Connection.",
            messageTxt: "Couldn't connect to app. Please check your connection and try again.",
            icon: Icons.signal_wifi_statusbar_connected_no_internet_4_rounded, // Icon of your choice
            iconSize: 60, // Example of setting a larger icon size
          );
        },
      );
      return; // Exit early if there's no connection
    }

    if (!hasError) {
      try {
        await loginUserNow();
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
            showDialog(
              context: context,
              builder: (context) {
                return ErrorDialog(
                  titlemessageTxt: "An error occurred.",
                  messageTxt: "Unexpected error occurred. Please try again later.",
                  icon: Icons.error_outline_rounded, // Icon of your choice
                  iconSize: 60, // Example of setting a larger icon size
                );
              },
            );
          }
        });
      }
    }
  }

  loginUserNow() async {
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ErrorDialog(
                        titlemessageTxt: "Connection Error",
                        messageTxt: "Please check your internet connection and try again..",
                        icon: Icons.signal_wifi_bad_rounded, // Icon of your choice
                        iconSize: 60, // Example of setting a larger icon size
                      );
                    },
                  );
                  break;
                case 'too-many-requests':
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ErrorDialog(
                        titlemessageTxt: "Too Many Attempts.",
                        messageTxt: "Your account has been temporarily disabled due to multiple failed login attempts. Please try again later.",
                        icon: Icons.lock_outline_rounded, // Icon of your choice
                        iconSize: 60, // Example of setting a larger icon size
                      );
                    },
                  );
                default:
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ErrorDialog(
                        titlemessageTxt: "An Error Occurred",
                        messageTxt: "There was an unexpected error occurred. Please try again.",
                        icon: Icons.error_outline_rounded, // Icon of your choice
                        iconSize: 60, // Example of setting a larger icon size
                      );
                    },
                  );
                  break;

              }
            } else {
              // Handle any other errors
              setState(() {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ErrorDialog(
                      titlemessageTxt: "An Error Occurred",
                      messageTxt: "There was an unexpected error occurred. Please try again.",
                      icon: Icons.error_outline_rounded, // Icon of your choice
                      iconSize: 60, // Example of setting a larger icon size
                    );
                  },
                );

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

              toast.showToastMsg("Logged in Successfully", context);
              // Redirects user to homepage if user's account is not blocked
              Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));

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
              // Use a Container with padding for the text
              Container(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05), // 5% padding from the left
                child: const Text(
                  "Sign In",
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
              const SizedBox(height: 20),
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
                    const SizedBox(height: 10),
                    // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PasswordResetScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                    const SizedBox(height: 30,),
                    // Log in button
                    ElevatedButton(
                      onPressed: () {
                        validateLogInForm();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.35,
                              vertical: 15
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: const Text(
                          "Sign In",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400
                          )
                      ),
                    ),
                    const SizedBox(height: 30),

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
                                  "Or Sign in with",
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

                    const SizedBox(height: 170),
                    // Sign up link
                    TextButton(
                      onPressed: null, // No action needed for the button itself
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.black87, // Style for the first part of the text
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Sign Up",
                              style: const TextStyle(
                                color: Colors.green, // Different color for the clickable text
                                fontWeight: FontWeight.normal, // Make the text bold
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const RegistrationScreen()));
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
