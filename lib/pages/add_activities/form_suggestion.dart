import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_activities/suggestion_page.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_env.dart';
import 'package:iterasi1/widget/iterasi_chip.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:provider/provider.dart';

import '../../widget/loading_overlay.dart';

class FormSuggestion extends StatefulWidget {
  final List<DateTime> selectedDays;

  const FormSuggestion({super.key, required this.selectedDays});

  @override
  FormSuggestionState createState() => FormSuggestionState();
}

class FormSuggestionState extends State<FormSuggestion> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Trip type — label bersih (dikirim ke prompt) → emoji (tampilan chip).
  final Map<String, String> _vibeOptions = const {
    'Healing': '🌿',
    'Adventure': '⛰️',
    'Santai': '😌',
    'Kuliner': '🍜',
    'Romantic': '💕',
    'Explore hidden gem': '🗺️',
    'Nightlife': '🌃',
    'Family trip': '👨‍👩‍👧',
  };
  final Set<String> _selectedVibes = {};

  final List<String> _paceOptions = const ['Santai', 'Balanced', 'Padat'];
  String? _selectedPace;

  final List<String> _companionOptions = const [
    'Solo',
    'Couple',
    'Teman',
    'Keluarga',
    'Anak kecil',
  ];
  String? _selectedCompanion;

  final Map<String, int> _companionDefaultPeople = const {
    'Solo': 1,
    'Couple': 2,
    'Teman': 3,
    'Keluarga': 4,
    'Anak kecil': 3,
  };
  int _numberOfPeople = 1;
  final TextEditingController _peopleController = TextEditingController(text: '1');

  final String _googleMapsApiKey = AppEnv.gmapsApiKey;

  void _toggleVibe(String vibe) {
    setState(() {
      if (_selectedVibes.contains(vibe)) {
        _selectedVibes.remove(vibe);
      } else if (_selectedVibes.length < 2) {
        _selectedVibes.add(vibe);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleMapsApiKey&components=country:id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          return [];
        }
        final predictions = data['predictions'] as List? ?? [];
        return predictions.map<Map<String, dynamic>>((p) {
          return {'description': p['description'], 'place_id': p['place_id']};
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final fmt = DateFormat('dd MMM', 'id_ID');
    return '${fmt.format(widget.selectedDays.first)} – ${fmt.format(widget.selectedDays.last)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomColor.ocean900.withOpacity(0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: CustomColor.ocean900,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: IterasiMono(
                        'step 2 of 3',
                        style: TextStyle(fontSize: 11),
                        color: CustomColor.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Hero
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IterasiKicker(_dateLabel, color: CustomColor.coral700),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: displayStyle.copyWith(
                        fontSize: 32,
                        color: CustomColor.ocean900,
                      ),
                      children: [
                        const TextSpan(text: 'Ceritakan '),
                        TextSpan(
                          text: 'tripmu.',
                          style: displayStyle.copyWith(
                            fontSize: 32,
                            // fontStyle: FontStyle.italic,
                            color: CustomColor.ocean900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  IterasiBody(
                    'Trip Planner akan menyusun dua rancangan untuk kamu pilih.',
                    color: CustomColor.ocean700,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fields
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  IterasiKicker('LOKASI BERANGKAT', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildAutocompleteField(
                      _departureController, 'Masukkan kota asal',
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  IterasiKicker('LOKASI TUJUAN', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildAutocompleteField(
                      _destinationController, 'Masukkan kota tujuan',
                      icon: Icons.flag_outlined),
                  const SizedBox(height: 20),
                  IterasiKicker('TRIP SEPERTI APA?', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildVibeChips(),
                  const SizedBox(height: 6),
                  const IterasiMono(
                    'Pilih maks. 2',
                    style: TextStyle(fontSize: 10),
                    color: CustomColor.muted,
                  ),
                  const SizedBox(height: 20),
                  IterasiKicker('GAYA PERJALANAN', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildSingleSelectChips(
                    _paceOptions,
                    _selectedPace,
                    (value) => setState(() => _selectedPace = value),
                  ),
                  const SizedBox(height: 20),
                  IterasiKicker('PERGI DENGAN SIAPA', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildSingleSelectChips(
                    _companionOptions,
                    _selectedCompanion,
                    (value) => setState(() {
                      _selectedCompanion = value;
                      if (value != null &&
                          _companionDefaultPeople.containsKey(value)) {
                        _numberOfPeople = _companionDefaultPeople[value]!;
                        _peopleController.text = _numberOfPeople.toString();
                      }
                    }),
                  ),
                  const SizedBox(height: 20),
                  IterasiKicker('JUMLAH ORANG', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildPeopleStepper(),
                  const SizedBox(height: 20),
                  IterasiKicker('CATATAN TAMBAHAN', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildNotesField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(
    TextEditingController controller,
    String hint, {
    required IconData icon,
  }) {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      shadowColor: CustomColor.shadowSoft,
      elevation: 2,
      child: TypeAheadField<Map<String, dynamic>>(
        controller: controller,
        suggestionsCallback: _getSuggestions,
        itemBuilder: (context, suggestion) {
          return ListTile(
            dense: true,
            title: Text(
              suggestion['description'],
              style: bodyStyle.copyWith(fontSize: 13),
            ),
          );
        },
        onSelected: (suggestion) {
          setState(() {
            controller.text = suggestion['description'];
          });
        },
        builder: (context, child, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (value) => setState(() {}),
            style: bodyStyle.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: bodyStyle.copyWith(
                color: CustomColor.muted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Icon(icon, size: 18, color: CustomColor.coral600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CustomColor.ocean900.withOpacity(0.15),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: CustomColor.ocean900,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      color: CustomColor.muted,
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showOutsideIndonesiaDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CustomColor.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const IterasiDisplay(
          'Destinasi di luar Indonesia',
          style: TextStyle(fontSize: 20),
          color: CustomColor.ocean900,
        ),
        content: IterasiBody(
          'Trip Planner saat ini hanya mendukung destinasi wisata di Indonesia. Pilih kota tujuan yang ada di Indonesia.',
          color: CustomColor.muted,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.ocean900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Mengerti',
              style: bodyStyle.copyWith(
                color: CustomColor.paper,
                fontWeight: semibold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _vibeOptions.entries.map((entry) {
        final label = entry.key;
        final displayLabel = '$label ${entry.value}';
        final isSelected = _selectedVibes.contains(label);
        return GestureDetector(
          onTap: () => _toggleVibe(label),
          child: isSelected
              ? IterasiChip.coral(label: displayLabel)
              : IterasiChip.outline(label: displayLabel),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips(
    List<String> options,
    String? selected,
    ValueChanged<String?> onSelect,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : option),
          child: isSelected
              ? IterasiChip.coral(label: option)
              : IterasiChip.outline(label: option),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.sand100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.sand300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        style: bodyStyle.copyWith(fontSize: 14, color: CustomColor.ocean900),
        decoration: InputDecoration.collapsed(
          hintText:
              'Preferensi khusus, pantangan, atau hal yang ingin kamu hindari...',
          hintStyle: bodyStyle.copyWith(
            color: CustomColor.muted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleStepper() {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      shadowColor: CustomColor.shadowSoft,
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CustomColor.ocean900.withOpacity(0.15),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_numberOfPeople > 1) {
                  setState(() {
                    _numberOfPeople--;
                    _peopleController.text = _numberOfPeople.toString();
                  });
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _numberOfPeople > 1
                      ? CustomColor.ocean900
                      : CustomColor.muted.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 18),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _peopleController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: bodyStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semibold,
                  color: CustomColor.ocean900,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed >= 1) {
                    setState(() => _numberOfPeople = parsed);
                  }
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_numberOfPeople < 99) {
                  setState(() {
                    _numberOfPeople++;
                    _peopleController.text = _numberOfPeople.toString();
                  });
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: CustomColor.ocean900,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isFormValid = _departureController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isFormValid
            ? () async {
                LoadingOverlay.show(context, isDark: true);
                try {
                  List<Itinerary> results = await context
                      .read<ItineraryProvider>()
                      .generateItineraryByAi(
                        departure: _departureController.text,
                        destination: _destinationController.text,
                        dates: widget.selectedDays,
                        numberOfPeople: _numberOfPeople,
                        vibes: _selectedVibes.toList(),
                        notes: _notesController.text,
                        pace: _selectedPace ?? '',
                        companions: _selectedCompanion ?? '',
                      );
                  LoadingOverlay.hide();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SuggestionPage(
                          itineraries: results,
                          selectedDays: widget.selectedDays,
                        ),
                      ),
                    );
                  }
                } catch (err) {
                  LoadingOverlay.hide();
                  if (!mounted) return;
                  if (err.toString().contains('OUTSIDE_INDONESIA')) {
                    _showOutsideIndonesiaDialog();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err.toString())),
                    );
                  }
                }
              }
            : null,
        icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
        label: Text(
          'Generate itinerary',
          style: bodyStyle.copyWith(
            color: Colors.white,
            fontWeight: semibold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFormValid ? CustomColor.ocean900 : CustomColor.muted,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
