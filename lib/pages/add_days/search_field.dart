import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class SearchField extends StatefulWidget {
  final String initialText;
  final Function(String) onSubmit;
  final Function(String) onValueChange;

  SearchField(
      {required this.initialText,
      required this.onSubmit,
      required this.onValueChange,
      Key? key})
      : super(key: key);

  @override
  State createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController controller;

  void _submitTitle() {
    widget.onSubmit(controller.text.trim());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: true,
      textInputAction: TextInputAction.done,
      controller: controller,
      onChanged: widget.onValueChange,
      onSubmitted: (_) => _submitTitle(),
      onEditingComplete: _submitTitle,
      style: monoStyle.copyWith(
        color: CustomColor.ocean900,
        fontSize: 15,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: CustomColor.paper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: IconButton(
          onPressed: _submitTitle,
          icon: const Icon(
            Icons.check,
            color: CustomColor.ocean900,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: CustomColor.ocean900.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: CustomColor.ocean900),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: CustomColor.ocean900.withOpacity(0.15),
          ),
        ),
      ),
    );
  }
}
