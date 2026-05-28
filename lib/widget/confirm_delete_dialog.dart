import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              color: CustomColor.warningColor.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.delete_rounded,
              size: 36,
              color: CustomColor.warningColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: headingTextStyle.copyWith(
              color: CustomColor.boardroomNavy,
              fontSize: 16,
              fontWeight: semibold,
              letterSpacing: -0.32,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: primaryTextStyle.copyWith(
          fontSize: 14,
          color: CustomColor.subtitleTextColor,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.of(context).pop(true),
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomColor.warningColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Hapus",
                    textAlign: TextAlign.center,
                    style: primaryTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: semibold,
                      color: CustomColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomColor.brandElectric,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Batal",
                    textAlign: TextAlign.center,
                    style: primaryTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: semibold,
                      color: CustomColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          title: title,
          message: message,
        );
      },
    );
  }
}
