import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_application/pages/about_page.dart';
import 'package:user_application/pages/edit_profile.dart';
import 'package:user_application/pages/trips_page.dart';
import 'package:user_application/pages/home_page.dart';
import '../methods/fetchUserData.dart';
import '../methods/user_service.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Error dialog
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => ErrorDialog(messageTxt: message),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile; // Store the selected image here
  int selectedIndex = 2;

  final String? profileUrl = null; // Assume this value comes from user data (null means no profile picture)

  // Function to request permission for camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    // Request permission to access the gallery or camera
    PermissionStatus permissionStatus;

    if (source == ImageSource.camera) {
      permissionStatus = await Permission.camera.request();
    } else {
      permissionStatus = await Permission.photos.request();
    }

    if (permissionStatus.isGranted) {
      // Pick image from the specified source
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } else {
      // Permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied. Please enable it from settings.')),
      );
    }
  }

  // Show dialog to choose between camera and gallery
  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Navigate to HomeScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
      // Navigate to Trips Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripsScreen()),
        );
        break;
      case 2:
      // Navigate to ProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  Future<void> logOut(BuildContext context) async {

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Logging out...")

    );
    // Introduce a small delay (e.g., 1 second) to ensure the dialog is displayed
    await Future.delayed(const Duration(seconds: 1));

    try {
      await UserService.instance.logout(context);
      // Navigate to login or splash screen
      Navigator.pushReplacementNamed(context, '/login'); //navigates to login screen
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show an error message
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData.fetchUserName(); // Fetch user's full name on widget load
  }

  // Function to show the log-out confirmation dialog
  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to Log out?"),
            actions: <Widget>[
              TextButton(
                child: const Text("YES"),
                  onPressed: () => logOut(context)
              ),
              TextButton(
                child: const Text("CANCEL"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {

    double height = 15;
    FontWeight fontWeight = FontWeight.normal;
    Color containerColor = const Color.fromARGB(150, 242, 242, 242);
    Color iconColor = const Color.fromARGB(255, 75, 201, 104);
    Color iconBGColor = const Color.fromARGB(255, 204, 245, 215);

    bool _isSwitched = false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default back button
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the left and right
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30), // Add spacing at the top
            Stack(
              children: [
                const CircleAvatar(
                  radius: 64,
                  backgroundImage: NetworkImage(
                    'https://img.freepik.com/premium-vector/default-avatar-profile-icon-social-media-user-image-gray-avatar-icon-blank-profile-silhouette-vector-illustration_561158-3383.jpg',
                  ),
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
                        onPressed: () {
                          // Your onPressed logic here
                        },
                        icon: const Icon(Icons.add_a_photo, color: Colors.grey), // Icon color
                        iconSize: 17, // Size of the icon
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<String>(
                future: fetchUserData.fetchUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching name'));
                  }
                  return Column(
                    children: [
                      Text(
                        snapshot.data ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 50),
                      // Account Settings Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor, // Background color for the list items
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (context) => const EditProfilePage(),
                                        ));
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          //Notification
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.notifications,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Notification',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle Allow Notifications tap
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          //Support
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.help,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Support',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle Allow Notifications tap
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: height),
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: iconBGColor,
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.info,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'About',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (context) => AboutPage(),
                                        ));
                                  },
                                )
                              ],
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 200, // Adjust the width as needed
                              child: const Divider(
                                color: Color.fromARGB(255, 240, 240, 240), // Line color
                                thickness: 1, // Line thickness
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          //Log out
                          Container(
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 36, // Adjust the width as needed
                                    height: 36, // Adjust the height as needed
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 242, 209, 207),
                                      shape: BoxShape.circle, // Makes the container circular
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.logout_rounded,
                                        size: 18,
                                        color: Color.fromARGB(255, 200, 68, 65),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontWeight: fontWeight,
                                    ),
                                  ),
                                  trailing: Container(
                                    width: 36,
                                    height: 36,
                                    child: const Center(
                                      child: Icon(
                                        Icons.circle_outlined,
                                        size: 18,
                                        color: Color.fromARGB(255, 200, 68, 65),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _showLogOutDialog();
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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




