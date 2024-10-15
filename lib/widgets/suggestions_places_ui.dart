import 'package:flutter/material.dart';
import 'package:user_application/model/suggestions_model.dart';

class SuggestionsPlacesUI extends StatelessWidget {
  final SuggestionsModel? suggestionsPlacesData;
  final VoidCallback onTap; // Changed to VoidCallback for clarity

  SuggestionsPlacesUI({
    super.key,
    this.suggestionsPlacesData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap, // Directly use the callback
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
        foregroundColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.grey.withOpacity(0.2), // Slight overlay on tap
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestionsPlacesData?.title ?? 'No Title',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600, // Slightly bolder
                  ),
                ),
                Text(
                  suggestionsPlacesData?.address ?? 'No Address',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/arrow_up.png',
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }
}
