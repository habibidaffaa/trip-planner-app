import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/location_autocomplete_field.dart';
import 'package:iterasi1/widget/text_field_wirdget.dart';

import '../../model/activity.dart';

class AddActivities extends StatefulWidget {
  final Activity? initialActivity;
  final Function(Activity) onSubmit;

  const AddActivities(
      {this.initialActivity, required this.onSubmit, super.key});

  @override
  _AddActivitiesState createState() => _AddActivitiesState();
}

class _AddActivitiesState extends State<AddActivities> {
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  bool _isEndTimeValid = true;
  bool _isTitleValid = true;
  bool _showTitleValidationMessage = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  String? lokasi;
  double? latitude;
  double? longitude;
  bool _isLokasiValid = true;
  bool _isCustomLocation = false;
  bool _isFromAutocomplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialActivity != null) {
      titleController.text = widget.initialActivity!.activityName;
      lokasiController.text = widget.initialActivity!.lokasi;
      keteranganController.text = widget.initialActivity!.keterangan;
      _selectedStartTime = widget.initialActivity!.startTimeOfDay;
      _isCustomLocation = widget.initialActivity!.isCustomLocation;
      _isFromAutocomplete = !_isCustomLocation;
      _selectedEndTime = widget.initialActivity!.endTimeOfDay;
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
      _isTitleValid = titleController.text.trim().isNotEmpty;
      _showTitleValidationMessage = showMessage && !_isTitleValid;
    });
  }

  void _validateLocation({bool showMessage = false}) {
    setState(() {
      _isLokasiValid = lokasiController.text.trim().isNotEmpty;
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

  void _submitActivity() {
    if (!_isEndTimeValid || !_isTitleValid || !_isLokasiValid) return;

    final locale = MaterialLocalizations.of(context);
    final newActivity = Activity(
      id: widget.initialActivity?.id,
      activityName: titleController.text,
      lokasi: lokasiController.text,
      startActivityTime: locale
          .formatTimeOfDay(_selectedStartTime, alwaysUse24HourFormat: true)
          .replaceAll(':', '.'),
      endActivityTime: locale
          .formatTimeOfDay(_selectedEndTime, alwaysUse24HourFormat: true)
          .replaceAll(':', '.'),
      keterangan: keteranganController.text,
      images: List<String>.from(widget.initialActivity?.images ?? []),
      removedImages:
          List<String>.from(widget.initialActivity?.removedImages ?? []),
      isCustomLocation: _isCustomLocation,
      latitude: widget.initialActivity?.latitude,
      longtitude: widget.initialActivity?.longtitude,
    );

    log(newActivity.startActivityTime);
    log(newActivity.toJson().toString());

    widget.onSubmit(newActivity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _isEndTimeValid &&
        _isTitleValid &&
        (_isCustomLocation
            ? _isLokasiValid
            : (_isLokasiValid && _isFromAutocomplete));

    return Scaffold(
      backgroundColor: CustomColor.softOffWhite,
      appBar: AppBar(
        backgroundColor: CustomColor.brandElectric,
        foregroundColor: CustomColor.whiteColor,
        title: Text(
          'Tambah Aktivitas',
          style: headingTextStyle.copyWith(
            fontWeight: semibold,
            fontSize: 18,
            color: CustomColor.whiteColor,
            letterSpacing: -0.36,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: BackButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: CustomColor.whiteColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    children: [
                      // Title field
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
                                  ? CustomColor.inputBorderColor
                                  : Theme.of(context).colorScheme.error,
                            ),
                            focusedBorder: AppTheme.inputBorder(
                              _isTitleValid
                                  ? CustomColor.brandElectric
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          if (_showTitleValidationMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Judul tidak boleh kosong',
                                style: primaryTextStyle.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                            _isLokasiValid = isCustom
                                ? value.trim().isNotEmpty
                                : fromAutocomplete && value.trim().isNotEmpty;
                            log("Lokasi: $value | isCustom: $isCustom | fromAuto: $fromAutocomplete");
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Time pickers
                      Row(
                        children: [
                          Expanded(
                            child: _TimePicker(
                              label: 'Mulai',
                              time: _selectedStartTime,
                              onTap: () => _selectStartTime(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TimePicker(
                              label: 'Selesai',
                              time: _selectedEndTime,
                              onTap: () => _selectEndTime(context),
                              hasError: !_isEndTimeValid,
                            ),
                          ),
                        ],
                      ),
                      if (!_isEndTimeValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Waktu Selesai tidak boleh mendahului Waktu Mulai!',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom save button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: AppTheme.actionPanelDecoration(),
              child: ElevatedButton(
                onPressed: isFormValid ? _submitActivity : null,
                child: Text(
                  'Simpan Aktivitas',
                  style: primaryTextStyle.copyWith(
                    fontWeight: semibold,
                    fontSize: 16,
                    color: CustomColor.whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final bool hasError;

  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(
            color: CustomColor.pitchBlack,
            fontWeight: medium,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: CustomColor.whiteColor,
              border: Border.all(
                color: hasError
                    ? Theme.of(context).colorScheme.error
                    : CustomColor.inputBorderGray,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: primaryTextStyle.copyWith(
                    fontSize: 20,
                    fontWeight: medium,
                    color: CustomColor.pitchBlack,
                  ),
                ),
                const Icon(
                  Icons.access_time_outlined,
                  size: 22,
                  color: CustomColor.inputBorderGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
