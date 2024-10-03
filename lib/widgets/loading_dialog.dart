import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String messageTxt;

  const LoadingDialog({super.key, required this.messageTxt});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Row(
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              messageTxt,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: const SizedBox.shrink(), // Keeps the dialog size manageable
    );
  }
}
