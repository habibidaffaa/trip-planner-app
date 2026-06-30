import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:iterasi1/widget/location_autocomplete_field.dart';
import 'package:iterasi1/widget/text_field_wirdget.dart';

import '../../model/activity.dart';
import '../../model/alert_save_dialog_result.dart';

class AddActivities extends StatefulWidget {
  final Activity? initialActivity;
  final Function(Activity)? onSubmit;

  const AddActivities({this.initialActivity, this.onSubmit, super.key});

  @override
  _AddActivitiesState createState() => _AddActivitiesState();
}

class _AddActivitiesState extends State<AddActivities> {
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  bool _isEndTimeValid = true;
  bool _isTitleValid = true;
  bool _showTitleValidationMessage = false;
  bool _titleHadContent = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  String? lokasi;
  double? latitude;
  double? longitude;
  bool _isLokasiValid = true;
  bool _showLokasiValidationMessage = false;
  bool _lokasiHadContent = false;
  bool _isCustomLocation = false;
  bool _isFromAutocomplete = false;

  static const _quickTimes = ['06.00', '08.00', '12.00', '19.30'];

  @override
  void initState() {
    super.initState();
    if (widget.initialActivity != null) {
      titleController.text = widget.initialActivity!.activityName;
      lokasiController.text = widget.initialActivity!.lokasi;
      keteranganController.text = widget.initialActivity!.keterangan;
      catatanController.text = widget.initialActivity!.catatan ?? '';
      _selectedStartTime = widget.initialActivity!.startTimeOfDay;
      _isCustomLocation = widget.initialActivity!.isCustomLocation;
      _isFromAutocomplete = !_isCustomLocation;
      _selectedEndTime = widget.initialActivity!.endTimeOfDay;
      _titleHadContent = true;
      _lokasiHadContent = true;
    }
    titleController.addListener(() {
      _validateTitle(showMessage: true);
    });
    lokasiController.addListener(() {
      _validateLocation(showMessage: true);
    });
    _validateTitle();
    _validateLocation();
  }

  void _validateTitle({bool showMessage = false}) {
    setState(() {
      final hasContent = titleController.text.trim().isNotEmpty;
      if (titleController.text.isNotEmpty) {
        _titleHadContent = true;
      }
      _isTitleValid = hasContent;
      _showTitleValidationMessage = _titleHadContent && !hasContent;
    });
  }

  void _validateLocation({bool showMessage = false}) {
    setState(() {
      final hasContent = lokasiController.text.trim().isNotEmpty;
      if (lokasiController.text.isNotEmpty) {
        _lokasiHadContent = true;
      }
      _isLokasiValid = hasContent;
      _showLokasiValidationMessage = _lokasiHadContent && !hasContent;
    });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        _validateEndTime();
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
        _validateEndTime();
      });
    }
  }

  void _validateEndTime() {
    setState(() {
      _isEndTimeValid = _selectedEndTime.hour > _selectedStartTime.hour ||
          (_selectedEndTime.hour == _selectedStartTime.hour &&
              _selectedEndTime.minute > _selectedStartTime.minute);
    });
  }

  void _applyQuickTime(String timeStr) {
    final parts = timeStr.split('.');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    setState(() {
      _selectedStartTime = TimeOfDay(hour: h, minute: m);
      _validateEndTime();
    });
  }

  bool _hasUnsavedChanges() {
    final initial = widget.initialActivity;
    if (initial == null) {
      return titleController.text.trim().isNotEmpty ||
          lokasiController.text.trim().isNotEmpty ||
          keteranganController.text.trim().isNotEmpty ||
          catatanController.text.trim().isNotEmpty;
    }
    final locale = MaterialLocalizations.of(context);
    final currentStartTime = locale
        .formatTimeOfDay(_selectedStartTime, alwaysUse24HourFormat: true)
        .replaceAll(':', '.');
    final currentEndTime = locale
        .formatTimeOfDay(_selectedEndTime, alwaysUse24HourFormat: true)
        .replaceAll(':', '.');

    return titleController.text.trim() != initial.activityName ||
        lokasiController.text.trim() != initial.lokasi ||
        keteranganController.text.trim() != initial.keterangan ||
        catatanController.text.trim() != (initial.catatan ?? '') ||
        currentStartTime != initial.startActivityTime ||
        currentEndTime != initial.endActivityTime ||
        _isCustomLocation != initial.isCustomLocation;
  }

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges()) {
      Navigator.of(context).pop();
      return;
    }
    final result = await _showSaveDialog();
    if (!mounted) return;
    if (result == AlertSaveDialogResult.saveAndQuit) {
      _submitActivity();
    } else if (result == AlertSaveDialogResult.saveWithoutQuit) {
      Navigator.of(context).pop();
    }
  }

  Future<AlertSaveDialogResult?> _showSaveDialog() {
    return showDialog<AlertSaveDialogResult?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  color: CustomColor.danger.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 36,
                  color: CustomColor.danger,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Konfirmasi Perubahan",
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(
                  color: CustomColor.ocean900,
                  fontSize: 18,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          content: Text(
            "Aktivitas Anda telah diubah. Simpan sebelum keluar?",
            style: bodyStyle.copyWith(
              fontSize: 14,
              color: CustomColor.muted,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveWithoutQuit),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: CustomColor.danger.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        "Keluar Tanpa Simpan",
                        textAlign: TextAlign.center,
                        style: bodyStyle.copyWith(
                          fontSize: 12,
                          fontWeight: semibold,
                          color: CustomColor.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveAndQuit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.ocean900,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Simpan & Keluar",
                        textAlign: TextAlign.center,
                        style: bodyStyle.copyWith(
                          fontSize: 12,
                          fontWeight: semibold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitActivity() {
    if (!_isEndTimeValid || !_isTitleValid || !_isLokasiValid) return;

    final locale = MaterialLocalizations.of(context);
    final newActivity = Activity(
      id: widget.initialActivity?.id,
      activityName: titleController.text.trim(),
      lokasi: lokasiController.text.trim(),
      startActivityTime: locale
          .formatTimeOfDay(_selectedStartTime, alwaysUse24HourFormat: true)
          .replaceAll(':', '.'),
      endActivityTime: locale
          .formatTimeOfDay(_selectedEndTime, alwaysUse24HourFormat: true)
          .replaceAll(':', '.'),
      keterangan: keteranganController.text.trim(),
      images: List<String>.from(widget.initialActivity?.images ?? []),
      removedImages:
          List<String>.from(widget.initialActivity?.removedImages ?? []),
      isCustomLocation: _isCustomLocation,
      latitude: widget.initialActivity?.latitude,
      longtitude: widget.initialActivity?.longtitude,
      catatan: catatanController.text.trim(),
    );

    log(newActivity.startActivityTime);
    log(newActivity.toJson().toString());

    Navigator.of(context).pop(newActivity);
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _isEndTimeValid && _isTitleValid && _isLokasiValid;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: CustomColor.paper,
        body: SafeArea(
          child: Column(
            children: [
              // Custom header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleBack(),
                      child: Text(
                        'Batal',
                        style: monoStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semibold,
                          color: CustomColor.muted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          IterasiKicker(
                            'aktivitas',
                            color: CustomColor.muted,
                          ),
                          IterasiDisplay(
                            widget.initialActivity != null
                                ? 'Edit Aktivitas'
                                : 'Aktivitas Baru',
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: isFormValid ? _submitActivity : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFormValid
                              ? CustomColor.ocean900
                              : CustomColor.muted,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Simpan',
                          style: bodyStyle.copyWith(
                            color: Colors.white,
                            fontWeight: semibold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 1,
                color: CustomColor.ocean900.withOpacity(0.08),
              ),

              // Form
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    // Time section
                    IterasiKicker(
                      'JAM MULAI · FORMAT 24H',
                      color: CustomColor.muted,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: CustomColor.ocean900.withOpacity(0.12),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _TimePickerButton(
                              label: 'Mulai',
                              time: _selectedStartTime,
                              onTap: () => _selectStartTime(context),
                              hasError: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: CustomColor.coral600,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _TimePickerButton(
                              label: 'Selesai',
                              time: _selectedEndTime,
                              onTap: () => _selectEndTime(context),
                              hasError: !_isEndTimeValid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isEndTimeValid)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Waktu Selesai tidak boleh mendahului Waktu Mulai!',
                          style: bodyStyle.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),

                    // Quick-tap chips
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _quickTimes.map((t) {
                        return GestureDetector(
                          onTap: () => _applyQuickTime(t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CustomColor.ocean900.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IterasiMono(
                              t,
                              style: const TextStyle(fontSize: 12),
                              color: CustomColor.ocean700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Nama field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFieldWidget(
                          label: 'Judul',
                          hintText: 'Cth. Persiapan Berangkat',
                          controller: titleController,
                          required: false,
                          border: AppTheme.inputBorder(
                            _isTitleValid
                                ? CustomColor.muted
                                : Theme.of(context).colorScheme.error,
                          ),
                          focusedBorder: AppTheme.inputBorder(
                            _isTitleValid
                                ? CustomColor.ocean900
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        if (_showTitleValidationMessage)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Judul tidak boleh kosong',
                              style: bodyStyle.copyWith(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Lokasi
                    LocationAutocompleteField(
                      initialIsCustomLocation: _isCustomLocation,
                      controller: lokasiController,
                      isValid: _isLokasiValid,
                      onLocationChanged: (value, isCustom,
                          {bool fromAutocomplete = false}) {
                        setState(() {
                          lokasi = value;
                          _isCustomLocation = isCustom;
                          _isFromAutocomplete = fromAutocomplete;
                          final hasContent = value.trim().isNotEmpty;
                          if (value.isNotEmpty) {
                            _lokasiHadContent = true;
                          }
                          _isLokasiValid = isCustom
                              ? hasContent
                              : fromAutocomplete && hasContent;
                          _showLokasiValidationMessage =
                              _lokasiHadContent && !hasContent;
                          log("Lokasi: $value | isCustom: $isCustom | fromAuto: $fromAutocomplete");
                        });
                      },
                    ),
                    if (_showLokasiValidationMessage)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Lokasi tidak boleh kosong',
                          style: bodyStyle.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Keterangan
                    TextFieldWidget(
                      label: 'Keterangan',
                      hintText:
                          'Cth. Pastikan semua barang tidak ada yang tertinggal',
                      controller: keteranganController,
                      required: false,
                      keyboardType: TextInputType.multiline,
                      minLines: 4,
                      maxLines: null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Catatan (opsional)
                    IterasiKicker('CATATAN TAMBAHAN (OPSIONAL)',
                        color: CustomColor.muted),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: CustomColor.sand100,
                        border: Border.all(color: CustomColor.sand300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: catatanController,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                        style: bodyStyle.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan…',
                          hintStyle: bodyStyle.copyWith(
                              color: CustomColor.sand700, fontSize: 14),
                          prefixIcon: const Padding(
                            padding:
                                EdgeInsets.only(left: 12, right: 8, top: 14),
                            child: Icon(Icons.access_time_outlined,
                                size: 18, color: CustomColor.sand700),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 40),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.fromLTRB(0, 12, 16, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final bool hasError;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(
              color: CustomColor.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: monoStyle.copyWith(
              fontSize: 22,
              fontWeight: semibold,
              color: hasError ? CustomColor.danger : CustomColor.coral700,
            ),
          ),
        ],
      ),
    );
  }
}
