import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class UserReviewPage extends StatefulWidget {
  const UserReviewPage({super.key});

  @override
  State<UserReviewPage> createState() => _UserReviewPageState();
}

class _UserReviewPageState extends State<UserReviewPage> {
  final _formKey = GlobalKey<FormState>();

  int? _q1aScore;
  String? _q1bFitAnswer;
  int? _q2aScore;
  String? _q2bFitAnswer;

  final TextEditingController _q1cReasonController = TextEditingController();
  final TextEditingController _q1dSuggestionController =
      TextEditingController();
  final TextEditingController _q2cReasonController = TextEditingController();
  final TextEditingController _q2dSuggestionController =
      TextEditingController();
  final Set<String> _q3aImprovementAreas = {};
  String? _q3aErrorText;
  final TextEditingController _q3bExpectationController =
      TextEditingController();
  final TextEditingController _additionalNoteController =
      TextEditingController();

  static const List<String> _q3AreaOptions = [
    'Warna',
    'Tipografi',
    'Ikon',
    'Jarak/Spacing',
    'Konsistensi Komponen',
    'Hierarki Informasi',
    'Responsif Mobile',
  ];

  static const List<String> _fitAnswerOptions = ['Ya', 'Sebagian', 'Tidak'];

  @override
  void dispose() {
    _q1cReasonController.dispose();
    _q1dSuggestionController.dispose();
    _q2cReasonController.dispose();
    _q2dSuggestionController.dispose();
    _q3bExpectationController.dispose();
    _additionalNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.surface,
      appBar: AppBar(
        title: Text(
          'Form User Review',
          style: primaryTextStyle.copyWith(
            color: CustomColor.whiteColor,
            fontWeight: semibold,
          ),
        ),
        backgroundColor: CustomColor.primary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionContainer(
                title: 'Q1. Evaluasi fitur rekomendasi itinerary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q1a. Seberapa membantu fitur rekomendasi itinerary dalam memberi gambaran perjalanan Anda?',
                      style: primaryTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _q1aScore,
                      decoration: _inputDecoration('Pilih skala 1 - 5'),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 - Sangat tidak membantu'),
                        ),
                        DropdownMenuItem(
                            value: 2, child: Text('2 - Tidak membantu')),
                        DropdownMenuItem(
                            value: 3, child: Text('3 - Cukup membantu')),
                        DropdownMenuItem(value: 4, child: Text('4 - Membantu')),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5 - Sangat membantu'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _q1aScore = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Skala wajib dipilih.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Q1b. Apakah rekomendasi itinerary sudah menjawab kebutuhan utama Anda saat merencanakan perjalanan?',
                      style: primaryTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _q1bFitAnswer,
                      decoration: _inputDecoration('Pilih jawaban'),
                      items: _fitAnswerOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _q1bFitAnswer = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Jawaban wajib dipilih.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _q1cReasonController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Q1c. Jelaskan alasan jawaban Anda untuk fitur rekomendasi itinerary.',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Penjelasan wajib diisi.';
                        }
                        if (text.length < 10) {
                          return 'Mohon isi minimal 10 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _q1dSuggestionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Q1d. Apakah ada saran untuk pengembangan pada fitur ini? (opsional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionContainer(
                title: 'Q2. Evaluasi fitur input lokasi (Google Maps API)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q2a. Seberapa mudah fitur input lokasi (Google Maps API) digunakan untuk menemukan tujuan?',
                      style: primaryTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _q2aScore,
                      decoration: _inputDecoration('Pilih skala 1 - 5'),
                      items: const [
                        DropdownMenuItem(
                            value: 1, child: Text('1 - Sangat sulit')),
                        DropdownMenuItem(value: 2, child: Text('2 - Sulit')),
                        DropdownMenuItem(
                            value: 3, child: Text('3 - Cukup mudah')),
                        DropdownMenuItem(value: 4, child: Text('4 - Mudah')),
                        DropdownMenuItem(
                            value: 5, child: Text('5 - Sangat mudah')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _q2aScore = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Skala wajib dipilih.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Q2b. Apakah fitur input lokasi membantu mempercepat proses perencanaan perjalanan Anda?',
                      style: primaryTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _q2bFitAnswer,
                      decoration: _inputDecoration('Pilih jawaban'),
                      items: _fitAnswerOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _q2bFitAnswer = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Jawaban wajib dipilih.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _q2cReasonController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Q2c. Jelaskan kendala atau hal yang paling membantu dari fitur input lokasi.',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Penjelasan wajib diisi.';
                        }
                        if (text.length < 10) {
                          return 'Mohon isi minimal 10 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _q2dSuggestionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Q2d. Apakah ada saran untuk pengembangan pada fitur ini? (opsional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionContainer(
                title: 'Q3. Evaluasi estetika tampilan aplikasi',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q3a. Bagian tampilan mana yang paling perlu ditingkatkan? (boleh pilih lebih dari satu)',
                      style: primaryTextStyle.copyWith(
                        fontSize: 13,
                        fontWeight: medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _q3AreaOptions.map((option) {
                        final isSelected =
                            _q3aImprovementAreas.contains(option);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(option),
                          selectedColor: CustomColor.primaryColor200,
                          checkmarkColor: CustomColor.primaryColor800,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _q3aImprovementAreas.add(option);
                              } else {
                                _q3aImprovementAreas.remove(option);
                              }
                              if (_q3aImprovementAreas.isNotEmpty) {
                                _q3aErrorText = null;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    if (_q3aErrorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _q3aErrorText!,
                        style: primaryTextStyle.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _q3bExpectationController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        'Q3b. Perubahan seperti apa yang Anda harapkan pada tampilan aplikasi?',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Masukan perbaikan tampilan wajib diisi.';
                        }
                        if (text.length < 10) {
                          return 'Mohon isi minimal 10 karakter.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _sectionContainer(
                title: 'Catatan tambahan (opsional)',
                child: TextFormField(
                  controller: _additionalNoteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: _inputDecoration('Masukan tambahan Anda'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitReview,
                  child: Text(
                    'Kirim Review',
                    style: primaryTextStyle.copyWith(
                      color: CustomColor.whiteColor,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: primaryTextStyle.copyWith(
        color: CustomColor.subtitleTextColor,
        fontSize: 13,
      ),
      filled: true,
      fillColor: CustomColor.whiteColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: CustomColor.disabledColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: CustomColor.primary, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: CustomColor.disabledColor),
      ),
    );
  }

  Widget _sectionContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CustomColor.primaryColor50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.primaryColor100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: primaryTextStyle.copyWith(
              fontWeight: semibold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  void _submitReview() {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (_q3aImprovementAreas.isEmpty) {
      setState(() {
        _q3aErrorText = 'Pilih minimal 1 area yang ingin ditingkatkan.';
      });
    }

    if (!isFormValid || _q3aImprovementAreas.isEmpty) {
      return;
    }

    final q1Suggestion = _q1dSuggestionController.text.trim();
    final q2Suggestion = _q2dSuggestionController.text.trim();
    final additionalNote = _additionalNoteController.text.trim();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terima kasih atas review Anda'),
          content: Text(
            'Validasi tersimpan.\n\n'
            'Q1a (Skala): $_q1aScore/5\n'
            'Q1b (Jawaban): $_q1bFitAnswer\n'
            'Q2a (Skala): $_q2aScore/5\n'
            'Q2b (Jawaban): $_q2bFitAnswer\n'
            'Q3a (Area): ${_q3aImprovementAreas.join(', ')}'
            '${q1Suggestion.isEmpty ? '' : '\n\nSaran Q1d:\n$q1Suggestion'}'
            '${q2Suggestion.isEmpty ? '\n' : '\n\nSaran Q2d:\n$q2Suggestion'}'
            '${additionalNote.isEmpty ? '' : '\n\nCatatan tambahan:\n$additionalNote'}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
