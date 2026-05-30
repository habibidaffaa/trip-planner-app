import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class IterasiConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const IterasiConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CustomColor.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        title,
        style: displayStyle.copyWith(fontSize: 20, color: CustomColor.ocean900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: bodyStyle.copyWith(fontSize: 14, color: CustomColor.muted),
          ),
          const SizedBox(height: 20),
          // Buttons kept side by side (equal width) so they never stack.
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    side: BorderSide(
                      color: CustomColor.ocean900.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: bodyStyle.copyWith(
                      color: CustomColor.ocean900,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.coral500,
                    foregroundColor: CustomColor.paper,
                    minimumSize: const Size(0, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    confirmLabel,
                    style: bodyStyle.copyWith(
                      color: CustomColor.paper,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
    );
  }
}

Future<T?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  const TextDialogWidget({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  State<TextDialogWidget> createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;
  String? errorText;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    isButtonEnabled = _isInputValid(widget.value);
  }

  bool _isInputValid(String input) {
    return input.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: CustomColor.paper,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: const BoxDecoration(
            color: CustomColor.ocean900,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Text(
            widget.title,
            style: bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: semibold,
              color: CustomColor.paper,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {
                  isButtonEnabled = _isInputValid(value);
                  if (!isButtonEnabled) {
                    errorText = "Judul tidak boleh kosong!";
                  } else {
                    errorText = null;
                  }
                });
              },
              decoration: InputDecoration(
                filled: true,
                hintStyle: bodyStyle.copyWith(
                  fontSize: 14,
                  color: CustomColor.muted,
                ),
                hintText: 'Masukan Judul Perjalanan Anda',
                errorText: errorText,
                fillColor: CustomColor.whiteColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CustomColor.coral500,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return CustomColor.muted;
                      }
                      return CustomColor.coral500;
                    },
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                onPressed: isButtonEnabled
                    ? () {
                        Navigator.of(context).pop(controller.text);
                      }
                    : null,
                child: Text(
                  'Selesai',
                  style: bodyStyle.copyWith(
                    color: CustomColor.paper,
                    fontWeight: semibold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
