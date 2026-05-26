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
  bool _showTitleValidationMessage =
      false; // Variabel kontrol untuk pesan validasi judul

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
      print('start time : $_selectedStartTime');
      _selectedEndTime = widget.initialActivity!.endTimeOfDay;
      print('end time : $_selectedEndTime');
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
      setState(
        () {
          _selectedStartTime = picked;
          _validateEndTime();
        },
      );
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(
        () {
          _selectedEndTime = picked;
          _validateEndTime();
        },
      );
    }
  }

  void _validateEndTime() {
    setState(
      () {
        _isEndTimeValid = _selectedEndTime.hour > _selectedStartTime.hour ||
            (_selectedEndTime.hour == _selectedStartTime.hour &&
                _selectedEndTime.minute > _selectedStartTime.minute);
      },
    );
  }

  void _submitActivity() {
    if (!_isEndTimeValid || !_isTitleValid || !_isLokasiValid) {
      return;
    }

    final locale = MaterialLocalizations.of(context);
    final newActivity = Activity(
      id: widget.initialActivity?.id,
      activityName: titleController.text,
      lokasi: lokasiController.text,
      startActivityTime: locale
          .formatTimeOfDay(
            _selectedStartTime,
            alwaysUse24HourFormat: true,
          )
          .replaceAll(':', '.'),
      endActivityTime: locale
          .formatTimeOfDay(
            _selectedEndTime,
            alwaysUse24HourFormat: true,
          )
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
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        // toolbarHeight: 118,
        backgroundColor: CustomColor.primaryColor500,
        title: Text(
          'Tambah Aktivitas',
          style: primaryTextStyle.copyWith(
            fontWeight: semibold,
            fontSize: 18,
            // fontFamily: 'poppins_bold',
            color: CustomColor.whiteColor,
          ),
          // itineraryProvider.itinerary.title,
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: BackButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: CustomColor.whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    children: [
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
                                  ? CustomColor.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                          if (_showTitleValidationMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Judul tidak boleh kosong',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
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

                            log("Lokasi dipilih: $value");
                            log("isCustom: $isCustom");
                            log("fromAutocomplete: $fromAutocomplete");
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mulai',
                                  style: TextStyle(
                                    color: CustomColor.blackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () => _selectStartTime(context),
                                    child: Container(
                                      width: 145,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: CustomColor.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedStartTime
                                                    .format(context),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 20,
                                                  color: CustomColor.blackColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.access_time,
                                              size: 25,
                                              color: CustomColor.borderColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: CustomColor.blackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () => _selectEndTime(context),
                                    child: Container(
                                      width: 145,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: CustomColor.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedEndTime
                                                    .format(context),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 20,
                                                  color: CustomColor.blackColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Icon(
                                              Icons.access_time,
                                              size: 25,
                                              color: CustomColor.borderColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!_isEndTimeValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Waktu Selesai tidak boleh mendahului Waktu Mulai!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              horizontal: 15,
                              vertical: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: AppTheme.actionPanelDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
