import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String messageTxt;
  final String titlemessageTxt;
  final IconData icon; // Icon to be displayed
  final double iconSize; // Size of the icon

  const ErrorDialog({
    super.key,
    required this.messageTxt,
    required this.titlemessageTxt,
    required this.icon, // Icon is required
    this.iconSize = 50.0, // Default icon size to 50
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
            // Circle with Icon inside
            Container(
              width: iconSize + 50, // Slightly larger than icon size for padding
              height: iconSize + 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.shade300, // Outline color
                  width: 2, // Outline width
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Colors.red.shade300, // Red icon color
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between icon and title

            /// Title message
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
                      backgroundColor: Colors.red.shade300, // Button color
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
