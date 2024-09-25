import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_application/authentication/passwordreset_screen.dart';
import 'package:user_application/pages/change_email.dart';
import 'package:user_application/pages/profile_page.dart';
import 'package:user_application/pages/trips_page.dart';
import 'package:user_application/pages/home_page.dart';
import '../methods/fetchUserData.dart';
import '../widgets/error_dialog.dart';


// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int selectedIndex = 2;
  bool isPasswordVisible = false; // Track password visibility

  File? _imageFile; // File to store the selected image
  Uint8List? _image; // Image data for in-memory image
  String? profileUrl; // URL for profile image from Firebase Storage

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripsScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData.fetchUserName().then((name) {
      _nameController.text = name;
    });
    fetchUserData.fetchUserEmail().then((email) {
      _emailController.text = email;
    });
    fetchUserData.fetchUserNumber().then((phone) {
      _phoneController.text = phone;
    });
    fetchUserData.fetchUserProfilePicture().then((url) {
      setState(() {
        profileUrl = url;
      });
    });
  }

  var auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;


  changePassword({email, oldPassword, newPassword}) async{
    var cred = EmailAuthProvider.credential(email: email, password: oldPassword);

    await currentUser!.reauthenticateWithCredential(cred).then((value){
      currentUser!.updatePassword(newPassword);
    }).catchError((error){
      print(error.toString());
    });
  }

  //Function's Working
  void selectImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imageFile = File(image.path); // Set _imageFile only if image is not null
        });
        // Log the path safely
        if (_imageFile != null) {
          print("Selected image: ${_imageFile!.path}");
        } else {
          print("Image file is null after setting.");
        }
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e"); // Log any error that occurs
    }
  }

  //For Profile Picture -- Still not working
  Future<void> _pickAndUploadProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');

        try {
          await storageRef.putFile(_imageFile!);
          String downloadUrl = await storageRef.getDownloadURL();

          // Update user's profile picture URL in Firebase Database
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(user.uid);

          await userRef.update({'profileUrl': downloadUrl});

          // Set the new profile URL in the app
          setState(() {
            profileUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } catch (e) {
          showErrorDialog(context, "Failed to upload profile picture: $e");
        }
      }
    }
  }

  Future<void> _showPasswordDialogAndSave() async {
    TextEditingController passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents dialog dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter your password to confirm changes.'),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                String password = passwordController.text.trim();

                if (password.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Re-authenticate user with email and password
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: password,
                    );

                    try {
                      await user.reauthenticateWithCredential(credential);
                      // Password is correct; proceed to update the data
                      print("Re-authentication successful");

                      // Call the method to save the updated user information
                      await _updateUserInfo();

                      // Close the dialog after success
                      Navigator.of(context).pop();
                    } on FirebaseAuthException catch (e) {
                      // Handle incorrect password
                      print("Re-authentication failed: ${e.message}");
                      showErrorDialog(context, "Incorrect password. Please try again.");
                    }
                  }
                } else {
                  // If password field is empty
                  showErrorDialog(context, "Please enter your password.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in
      showErrorDialog(context, "User is not logged in.");
      return;
    }

    try {
      final User? curuser = FirebaseAuth.instance.currentUser;

      // Reference to Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

        // Update user information in the database
        await userRef.update({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      // Handle errors
      print("Error updating profile: $e");
      showErrorDialog(context, "Error updating profile. Please try again.");
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color iconBGColor = const Color.fromARGB(255, 204, 245, 215);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
          // -- IMAGE with ICON
          Stack(
          children: [
            CircleAvatar(
              radius: 65.0,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!) // Use FileImage for local images
                  : NetworkImage(profileUrl ?? 'https://via.placeholder.com/150') as ImageProvider,
            ),
          Positioned(
            bottom: 0,
            left: 90,
            child: Container(
              width: 30, // Width of the container
              height: 30, // Height of the container
              decoration: const BoxDecoration(
                color: Colors.white, // Background color of the container
                shape: BoxShape.circle, // Makes the background circular
              ),
              child: Center(
                child: IconButton(
                  onPressed: selectImage,
                  icon: const Icon(Icons.add_a_photo, color: Colors.grey), // Icon color
                  iconSize: 17, // Size of the icon
                ),
              ),
            ),
          ),
          ],
        ),

        const SizedBox(height: 50),
        // -- Form Fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: const Text("Name"),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: iconBGColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: iconBGColor, width: 2.0),
                  ),
                ),
              ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(
          label: const Text("Phone"),
          prefixIcon: const Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: iconBGColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: iconBGColor, width: 2.0),
          ),
        ),
      ),
      const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => ChangeEmailPage(),
                        ));
                  }, // Show password dialog and save
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Background color of the button
                    foregroundColor: Colors.black, // Color of the text and icon on the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                      side: BorderSide(
                        color: iconBGColor, // Border color
                        width: 2.0, // Border width
                      ),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Padding inside the button
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Wrap content size
                    children: <Widget>[
                      const Icon(Icons.email, color: Color.fromARGB(255, 77, 87, 88)), // Leading icon
                      const SizedBox(width: 10), // Space between leading icon and text
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft, // Align text to the left
                          child: Text(
                            "Change Email Address",
                            style: TextStyle(
                              fontSize: 16, // Adjust font size
                            ),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8, // Adjust this value to change thickness
                        child: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(150, 75, 201, 104)), // Trailing icon
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => const PasswordResetScreen(),
                ));
          }, // Show password dialog and save
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Background color of the button
          foregroundColor: Colors.black, // Color of the text and icon on the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            side: BorderSide(
              color: iconBGColor, // Border color
              width: 2.0, // Border width
             ),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Padding inside the button
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Wrap content size
            children: <Widget>[
              const Icon(Icons.lock, color: Color.fromARGB(255, 77, 87, 88)), // Leading icon
              const SizedBox(width: 10), // Space between leading icon and text
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 16, // Adjust font size
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8, // Adjust this value to change thickness
                child: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(150, 75, 201, 104)), // Trailing icon
              ),
            ],
          ),
        ),
      ),
              const SizedBox(height: 100),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showPasswordDialogAndSave, // Show password dialog and save
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 75, 201, 104), // Background color of the button
              foregroundColor: Colors.white, // Color of the text and icon on the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Padding inside the button
            ),
            child: const Text("Save"),
        ),
      ),
      ],
    ),
    ),
    ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        enableFeedback: false,
      ),
    );
  }
}