// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/alert_save_dialog_result.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/pages/add_days/search_field.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/pages/itinerary_list.dart';
import 'package:iterasi1/pages/pdf/preview_pdf_page.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/thumbnail_storage.dart';
import 'package:iterasi1/widget/activity_card.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../model/activity.dart';
import '../../provider/itinerary_provider.dart';

class AddDays extends StatefulWidget {
  const AddDays({Key? key}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
  late ItineraryProvider itineraryProvider;
  late DatabaseProvider databaseProvider;

  int selectedDayIndex = 0;
  bool isEditing = false;

  late ScaffoldMessengerState snackbarHandler;
  String _pendingTitle = '';

  void _submitItineraryTitle(String newTitle) {
    final trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) {
      snackbarHandler
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Judul itinerary tidak boleh kosong')),
        );
      return;
    }
    itineraryProvider.setNewItineraryTitle(trimmedTitle, shouldNotify: true);
    _pendingTitle = trimmedTitle;
    setState(() {
      isEditing = false;
    });
  }

  bool _commitPendingTitleIfAny() {
    if (!isEditing) return true;
    final trimmedTitle = _pendingTitle.trim();
    if (trimmedTitle.isEmpty) {
      snackbarHandler
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Judul itinerary tidak boleh kosong')),
        );
      return false;
    }
    itineraryProvider.setNewItineraryTitle(trimmedTitle, shouldNotify: true);
    setState(() {
      isEditing = false;
    });
    return true;
  }

  Future<void> _safeDeleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      log('Failed deleting file: $filePath, error: $e');
    }
  }

  String? _extractAutoPhotoHash(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    if (!fileName.startsWith('AUTO_')) return null;
    final extensionIndex = fileName.lastIndexOf('.');
    final rawHash = extensionIndex > 5
        ? fileName.substring(5, extensionIndex)
        : fileName.substring(5);
    if (rawHash.isEmpty) return null;
    return itineraryProvider.normalizeHiddenPhotoHash(rawHash);
  }

  Future<void> _finalizeRemovedPhotos() async {
    for (final day in itineraryProvider.itinerary.days) {
      for (final activity in day.activities) {
        final removedPaths =
            List<String>.from(activity.removedImages ?? const <String>[]);
        for (final removedPath in removedPaths) {
          final hiddenHash = _extractAutoPhotoHash(removedPath);
          if (hiddenHash != null) {
            itineraryProvider.addHiddenPhotoHashForActivity(
              activity: activity,
              hash: hiddenHash,
              shouldNotify: false,
            );
          }
        }
      }
    }
  }

  Future<void> requestGalleryPermission(Activity activity) async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!mounted) return;

    // Full or limited access — both let the user attach photos.
    if (result.isAuth || result == PermissionState.limited) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityPhotoPage(
            dayIndex: selectedDayIndex,
            activity: activity,
          ),
        ),
      );
      return;
    }

    // Denied — offer a shortcut to the system settings.
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CustomColor.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const IterasiDisplay(
          'Izin galeri diperlukan',
          style: TextStyle(fontSize: 18),
          color: CustomColor.ocean900,
        ),
        content: IterasiBody(
          'Trip Planner membutuhkan akses ke galeri untuk melampirkan foto aktivitas. Buka pengaturan untuk mengizinkan.',
          color: CustomColor.muted,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: bodyStyle.copyWith(color: CustomColor.muted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              PhotoManager.openSetting();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColor.ocean900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Buka Pengaturan',
              style: bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editThumbnail() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      final id = itineraryProvider.itinerary.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final path = await persistThumbnail(File(picked.path), id);
      itineraryProvider.setThumbnail(path);
    }
  }

  String _dayRangeText() {
    final days = itineraryProvider.itinerary.days;
    if (days.isEmpty) return '';
    final fmt = DateFormat('d MMM', 'id_ID');
    final first = _parseDate(days.first.date);
    final last = _parseDate(days.last.date);
    return '${fmt.format(first)} – ${fmt.format(last)}';
  }

  DateTime _parseDate(String ddMMyyyy) {
    final parts = ddMMyyyy.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  String _dayLabel(int index) {
    final day = itineraryProvider.itinerary.days[index];
    final date = _parseDate(day.date);
    return DateFormat('EEE, d MMM', 'id_ID').format(date);
  }

  void _navigateToSelectDate() {
    log(itineraryProvider.itinerary.days
        .map((e) => e.getDatetime())
        .toList()
        .toString());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectDate(
          isNewItinerary: false,
          initialDates: itineraryProvider.itinerary.days
              .map((e) => e.getDatetime())
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showChangeDateConfirmationDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: CustomColor.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                color: CustomColor.coral500.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 36,
                color: CustomColor.coral500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ubah Tanggal Perjalanan?',
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
          'Apakah kamu ingin mengubah tanggal perjalanan? Rencana yang sudah kamu susun mungkin akan hilang.',
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
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _navigateToSelectDate();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      side: BorderSide(
                        color: CustomColor.ocean900.withOpacity(0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Lanjut',
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
                    onPressed: () => Navigator.of(dialogContext).pop(),
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
                      'Batal',
                      style: bodyStyle.copyWith(
                        color: CustomColor.paper,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    snackbarHandler = ScaffoldMessenger.of(context);
    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    return LoaderOverlay(
      child: WillPopScope(
        onWillPop: handleBackBehaviour,
        child: Scaffold(
          backgroundColor: CustomColor.paper,
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          // Back button
                          _CircleBackButton(onTap: () {
                            handleBackBehaviour().then((shouldPop) {
                              if (shouldPop) {
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName(ItineraryList.route),
                                );
                              }
                            });
                          }),
                          const SizedBox(width: 8),
                          // Title / edit area
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IterasiMono(
                                  _dayRangeText(),
                                  style: const TextStyle(fontSize: 11),
                                  color: CustomColor.muted,
                                ),
                                const SizedBox(height: 2),
                                if (isEditing)
                                  SearchField(
                                    initialText: _pendingTitle,
                                    onSubmit: _submitItineraryTitle,
                                    onValueChange: (newTitle) {
                                      _pendingTitle = newTitle;
                                    },
                                  )
                                else
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _pendingTitle =
                                          itineraryProvider.itinerary.title;
                                      isEditing = true;
                                    }),
                                    child: IterasiDisplay(
                                      itineraryProvider.itinerary.title,
                                      style: const TextStyle(fontSize: 17),
                                      maxLines: 1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Thumbnail edit button
                          // IconButton(
                          //   icon: const Icon(
                          //     Icons.camera_alt_outlined,
                          //     size: 18,
                          //     color: CustomColor.muted,
                          //   ),
                          //   onPressed: _editThumbnail,
                          //   padding: EdgeInsets.zero,
                          //   constraints: const BoxConstraints(
                          //     minWidth: 32,
                          //     minHeight: 32,
                          //   ),
                          // ),
                          // const SizedBox(width: 4),
                          // Save pill
                          GestureDetector(
                            onTap: () {
                              if (!isEditing) {
                                saveAndExit();
                              } else {
                                _submitItineraryTitle(_pendingTitle);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: CustomColor.ocean900,
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

                    // Day chips row
                    Container(
                      color: CustomColor.paper,
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 52,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return _DayChip(
                                  index: index,
                                  tanggal: itineraryProvider
                                      .itinerary.days[index].date,
                                  isSelected: index == selectedDayIndex,
                                  onTap: () =>
                                      setState(() => selectedDayIndex = index),
                                );
                              },
                              itemCount:
                                  itineraryProvider.itinerary.days.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 8,
                            child: InkWell(
                              onTap: () {
                                final hasActivities = itineraryProvider
                                    .itinerary.days
                                    .any((day) => day.activities.isNotEmpty);
                                if (hasActivities) {
                                  _showChangeDateConfirmationDialog();
                                } else {
                                  _navigateToSelectDate();
                                }
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: CustomColor.coral500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 1,
                      color: CustomColor.ocean900.withOpacity(0.06),
                    ),

                    // Big day header
                    if (itineraryProvider.itinerary.days.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IterasiKicker(
                              'hari ${selectedDayIndex + 1} · ${_dayLabel(selectedDayIndex)}',
                              color: CustomColor.coral700,
                            ),
                            const SizedBox(height: 4),
                            IterasiDisplay(
                              'Hari ${selectedDayIndex + 1}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Activity list
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: () {
                          final data = List<Activity>.from(itineraryProvider
                              .itinerary.days[selectedDayIndex].activities)
                            ..sort((a, b) =>
                                a.startDateTime.compareTo(b.startDateTime));
                          if (data.isEmpty) {
                            return _EmptyDayState();
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final currentActivity = data[index].copy();
                              final originalActivities = itineraryProvider
                                  .itinerary.days[selectedDayIndex].activities;
                              final originalIndex =
                                  originalActivities.indexOf(data[index]);
                              return ActivityCard(
                                snackbarHandler: snackbarHandler,
                                data: data[index],
                                selectedDayIndex: selectedDayIndex,
                                activityIndex: originalIndex,
                                onUndo: () {
                                  itineraryProvider.insertNewActivity(
                                      activities: data,
                                      newActivity: currentActivity);
                                },
                                onDismiss: () {
                                  final originalActivities = itineraryProvider
                                      .itinerary
                                      .days[selectedDayIndex]
                                      .activities;
                                  final originalIndex =
                                      originalActivities.indexOf(data[index]);
                                  if (originalIndex != -1) {
                                    itineraryProvider.removeActivity(
                                      removedDayIndex: selectedDayIndex,
                                      removedActivityIndex: originalIndex,
                                    );
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemCount: data.length,
                          );
                        }(),
                      ),
                    ),
                  ],
                ),

                // Bottom action bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: CustomColor.paper.withOpacity(0.95),
                      border: Border(
                        top: BorderSide(
                          color: CustomColor.ocean900.withOpacity(0.10),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push<Activity>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddActivities();
                                  },
                                ),
                              ).then((newActivity) {
                                if (newActivity != null) {
                                  itineraryProvider.insertNewActivity(
                                      activities: itineraryProvider.itinerary
                                          .days[selectedDayIndex].activities,
                                      newActivity: newActivity);
                                  log("${itineraryProvider.itinerary.days[selectedDayIndex].activities.length}");
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColor.ocean900,
                              minimumSize: const Size(double.infinity, 50),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Tambah aktivitas',
                              style: bodyStyle.copyWith(
                                color: Colors.white,
                                fontWeight: semibold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => PdfPreviewPage(
                                    itinerary: itineraryProvider.itinerary),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: CustomColor.ocean900.withOpacity(0.25),
                            ),
                            minimumSize: const Size(0, 50),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          icon: const Icon(
                            Icons.share_outlined,
                            size: 16,
                            color: CustomColor.ocean900,
                          ),
                          label: Text(
                            'Bagikan PDF',
                            style: bodyStyle.copyWith(
                              color: CustomColor.ocean900,
                              fontWeight: medium,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<AlertSaveDialogResult?> showAlertSaveDialog(BuildContext context) {
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
            "Itinerary Anda telah diubah. Simpan sebelum keluar?",
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

  Future<bool> persistCurrentItinerary() async {
    FocusScope.of(context).unfocus();
    if (!_commitPendingTitleIfAny()) return false;
    context.loaderOverlay.show();
    try {
      await _finalizeRemovedPhotos();
      await databaseProvider.insertItinerary(
          itinerary: itineraryProvider.itinerary);
      itineraryProvider.syncInitialItinerary();
      return true;
    } catch (_) {
      snackbarHandler
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
              content: Text('Gagal menyimpan itinerary. Coba lagi.')),
        );
      return false;
    } finally {
      if (mounted) context.loaderOverlay.hide();
    }
  }

  Future<void> saveAndExit() async {
    final didPersist = await persistCurrentItinerary();
    if (!didPersist || !mounted) return;
    Navigator.popUntil(context, ModalRoute.withName(ItineraryList.route));
  }

  Future<bool> handleBackBehaviour() async {
    final hasPendingTitleChange =
        isEditing && _pendingTitle.trim() != itineraryProvider.itinerary.title;
    if (itineraryProvider.isDataChanged || hasPendingTitleChange) {
      final resultSaveDialog = await showAlertSaveDialog(context);
      late bool shouldPop;
      if (resultSaveDialog == AlertSaveDialogResult.saveWithoutQuit) {
        shouldPop = true;
      } else if (resultSaveDialog == AlertSaveDialogResult.saveAndQuit) {
        await saveAndExit();
        shouldPop = false;
      } else {
        shouldPop = false;
      }
      if (shouldPop) snackbarHandler.removeCurrentSnackBar();
      return shouldPop;
    } else {
      snackbarHandler.removeCurrentSnackBar();
      return true;
    }
  }
}

class _CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _DayChip extends StatelessWidget {
  final int index;
  final String tanggal;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.index,
    required this.tanggal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = tanggal.split('/');
    final parsedDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
    final dayAbbr = DateFormat('EEE', 'id_ID').format(parsedDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.ocean900 : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? null
              : Border.all(
                  color: CustomColor.ocean900.withOpacity(0.15),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'D${index + 1}',
              style: monoStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : CustomColor.ocean900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              dayAbbr,
              style: bodyStyle.copyWith(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : CustomColor.ocean700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: CustomColor.muted.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          IterasiBody(
            'Belum ada aktivitas',
            style: const TextStyle(fontSize: 15),
            color: CustomColor.muted,
          ),
          const SizedBox(height: 4),
          IterasiBody(
            'Tambahkan aktivitas untuk hari ini',
            style: const TextStyle(fontSize: 13),
            color: CustomColor.muted,
          ),
        ],
      ),
    );
  }
}
