import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String messageTxt;
  final String titlemessageTxt;
  final String imagePath; // Path to the image
  final double imageSize; // Size of the image

  const CustomDialog({
    super.key,
    required this.messageTxt,
    required this.titlemessageTxt,
    required this.imagePath, // Image path required
    this.imageSize = 50.0, // Default image size to 50
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Displaying the image
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16), // Space between image and message
            /// Title Error message
            Text(
              titlemessageTxt,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16), // Space between title and message
            /// Error message
            Text(
              messageTxt,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16), // Space between message and button
            /// Okay button
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth * 0.9, // 90% of the available width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BF63),
                    foregroundColor: Colors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded rectangle
                    ),
                  ),
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
