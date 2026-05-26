import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import '../resource/theme.dart';
import '../utilities/app_env.dart';

class LocationAutocompleteField extends StatefulWidget {
  final Function(String location, bool isCustom, {bool fromAutocomplete})
      onLocationChanged;

  final bool initialIsCustomLocation;

  final bool isValid;
  final TextEditingController controller;

  const LocationAutocompleteField({
    Key? key,
    required this.onLocationChanged,
    required this.isValid,
    required this.controller,
    this.initialIsCustomLocation = false,
  }) : super(key: key);

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final String _apiKey = AppEnv.gmapsApiKey;
  bool isCustomLocation = false;

  InputDecoration _buildDecoration({
    required String hintText,
    bool showError = false,
  }) {
    final borderColor = showError
        ? Theme.of(context).colorScheme.error
        : CustomColor.inputBorderColor;

    return InputDecoration(
      hintText: hintText,
      suffixIcon: widget.controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.controller.clear();
                widget.onLocationChanged('', isCustomLocation,
                    fromAutocomplete: false);
              },
            )
          : null,
      enabledBorder: AppTheme.inputBorder(borderColor),
      focusedBorder: AppTheme.inputBorder(
        showError ? Theme.of(context).colorScheme.error : CustomColor.primary,
      ),
      errorBorder: AppTheme.inputBorder(Theme.of(context).colorScheme.error),
      focusedErrorBorder:
          AppTheme.inputBorder(Theme.of(context).colorScheme.error),
    ).applyDefaults(Theme.of(context).inputDecorationTheme);
  }

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&language=id';

    final response = await http.get(Uri.parse(url));

    final data = json.decode(response.body);

    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      return [];
    }

    final predictions = data['predictions'] as List? ?? [];

    return predictions.map<Map<String, dynamic>>((p) {
      return {
        'description': p['description'],
        'place_id': p['place_id'],
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    isCustomLocation = widget.initialIsCustomLocation;
    widget.controller.addListener(() {
      setState(() {}); // untuk update tombol clear
    });
  }

  @override
  void didUpdateWidget(covariant LocationAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIsCustomLocation != widget.initialIsCustomLocation) {
      setState(() {
        isCustomLocation = widget.initialIsCustomLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lokasi",
              style: TextStyle(
                color: CustomColor.blackColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Gunakan lokasi manual",
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomColor.subtitleTextColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: Transform.scale(
                      scale: 0.7, // kecilin (0.7, 0.8, dll)
                      child: Switch.adaptive(
                        value: isCustomLocation,
                        onChanged: (value) {
                          setState(() {
                            isCustomLocation = value;
                            widget.controller.clear();
                            widget.onLocationChanged(
                                '', value); // kosongkan saat ganti mode
                          });
                        },
                        activeColor: CustomColor.primaryColor700,
                        inactiveTrackColor: CustomColor.disabledColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        isCustomLocation ? _buildManualField() : _buildAutocompleteField(),
      ],
    );
  }

  Widget _buildManualField() {
    return TextField(
      controller: widget.controller,
      onChanged: (value) {
        widget.onLocationChanged(value, true, fromAutocomplete: false);
      },
      decoration: _buildDecoration(
        hintText: 'Contoh: Rumah Nenek, Rest Area KM 57',
        showError: !widget.isValid,
      ),
    );
  }

  Widget _buildAutocompleteField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: widget.controller,
      suggestionsCallback: _getSuggestions,
      errorBuilder: (context, error) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Error: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion['description']),
        );
      },
      onSelected: (suggestion) {
        widget.controller.text = suggestion['description'];
        widget.onLocationChanged(
          suggestion['description'],
          false,
          fromAutocomplete: true, // ✅ ditambahkan
        );
      },
      builder: (context, child, focusNode) {
        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          decoration: _buildDecoration(
            hintText: 'Cth. Bandara Juanda, Monas, Hotel Majapahit',
            showError: !widget.isValid,
          ),
        );
      },
    );
  }
}
