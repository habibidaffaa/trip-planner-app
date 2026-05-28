// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/alert_save_dialog_result.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/pages/add_days/app_bar_itinerary_title.dart';
import 'package:iterasi1/pages/add_days/search_field.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/pages/itinerary_list.dart';
import 'package:iterasi1/pages/pdf/preview_pdf_page.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/activity_card.dart';
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
  late Widget appBarTitle;
  late List<Widget> actionIcon;

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
          await _safeDeleteFile(removedPath);
        }
      }
    }

    final removedPaths = itineraryProvider.getAllRemovedPhotoPaths();
    itineraryProvider.purgeRemovedPhotoReferences(removedPaths,
        shouldNotify: false);
  }

  Future<void> requestGalleryPermission(Activity activity) async {
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityPhotoPage(
            dayIndex: selectedDayIndex,
            activity: activity,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Perizinan Ditolak"),
          content:
              const Text("Aplikasi memerlukan izin untuk mengakses galeri."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    snackbarHandler = ScaffoldMessenger.of(context);
    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    if (isEditing) {
      appBarTitle = SearchField(
        initialText: _pendingTitle,
        onSubmit: _submitItineraryTitle,
        onValueChange: (newTitle) {
          _pendingTitle = newTitle;
        },
      );
      actionIcon = [];
    } else {
      appBarTitle =
          AppBarItineraryTitle(title: itineraryProvider.itinerary.title);
      actionIcon = [
        IconButton(
          icon: const Icon(Icons.mode_edit_outlined),
          onPressed: () {
            setState(() {
              _pendingTitle = itineraryProvider.itinerary.title;
              isEditing = true;
            });
          },
        ),
      ];
    }

    return LoaderOverlay(
      child: WillPopScope(
        onWillPop: handleBackBehaviour,
        child: Scaffold(
          backgroundColor: CustomColor.softOffWhite,
          appBar: AppBar(
            surfaceTintColor: CustomColor.transparentColor,
            title: appBarTitle,
            actions: actionIcon,
            centerTitle: true,
            backgroundColor: CustomColor.brandElectric,
            foregroundColor: CustomColor.whiteColor,
            elevation: 0,
            titleTextStyle: headingTextStyle.copyWith(
              fontWeight: semibold,
              fontSize: 18,
              color: CustomColor.whiteColor,
              letterSpacing: -0.36,
            ),
            leading: Padding(
              padding: const EdgeInsets.all(3.0),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: CustomColor.whiteColor,
                ),
                onPressed: () {
                  handleBackBehaviour().then(
                    (shouldPop) {
                      if (shouldPop) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(ItineraryList.route),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day tabs
                  Container(
                    color: CustomColor.whiteColor,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 64,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _DayTab(
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
                                const SizedBox(width: 8),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              log(itineraryProvider.itinerary.days
                                  .map((e) => e.getDatetime())
                                  .toList()
                                  .toString());
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SelectDate(
                                      isNewItinerary: false,
                                      initialDates: itineraryProvider
                                          .itinerary.days
                                          .map((e) => e.getDatetime())
                                          .toList(),
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: CustomColor.brandElectric,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: CustomColor.whiteColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: CustomColor.lightCoolGray),
                  // Activity list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: FutureBuilder<List<Activity>>(
                        future: itineraryProvider.getSortedActivity(
                            itineraryProvider
                                .itinerary.days[selectedDayIndex].activities),
                        builder: (context, snapshot) {
                          final data = snapshot.data;
                          if (data != null) {
                            if (data.isEmpty) {
                              return _EmptyDayState();
                            }
                            return ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 0),
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final currentActivity = data[index].copy();
                                print(
                                    'activity card : ${data[index].startDateTime}');
                                return ActivityCard(
                                  snackbarHandler: snackbarHandler,
                                  data: data[index],
                                  selectedDayIndex: selectedDayIndex,
                                  activityIndex: index,
                                  onUndo: () {
                                    itineraryProvider.insertNewActivity(
                                        activities: data,
                                        newActivity: currentActivity);
                                  },
                                  onDismiss: () {
                                    itineraryProvider.removeActivity(
                                        activities: data,
                                        removedHashCode: data[index].hashCode);
                                  },
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemCount: data.length,
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Bottom action panel
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: AppTheme.actionPanelDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  print(itineraryProvider.itinerary
                                      .days[selectedDayIndex].activities);
                                  return AddActivities(
                                    onSubmit: (newActivity) {
                                      itineraryProvider.insertNewActivity(
                                          activities: itineraryProvider
                                              .itinerary
                                              .days[selectedDayIndex]
                                              .activities,
                                          newActivity: newActivity);
                                      log("${itineraryProvider.itinerary.days[selectedDayIndex].activities.length}");
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Tambah Aktivitas',
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              fontSize: 15,
                              color: CustomColor.whiteColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ActionIconButton(
                        icon: Icons.print_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => PdfPreviewPage(
                                  itinerary: itineraryProvider.itinerary),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _ActionIconButton(
                        icon: Icons.save_outlined,
                        onTap: saveAndExit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                  Icons.warning_rounded,
                  size: 36,
                  color: CustomColor.warningColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Konfirmasi Perubahan",
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
            "Itinerary Anda telah diubah. Simpan sebelum keluar?",
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
                    onTap: () => Navigator.of(context)
                        .pop(AlertSaveDialogResult.saveWithoutQuit),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor.warningColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Keluar Tanpa Simpan",
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
                    onTap: () => Navigator.of(context)
                        .pop(AlertSaveDialogResult.saveAndQuit),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor.brandElectric,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Simpan & Keluar",
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

// Day tab widget
class _DayTab extends StatelessWidget {
  final int index;
  final String tanggal;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayTab({
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
    final formatted = DateFormat("dd MMM").format(parsedDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color:
                  isSelected ? CustomColor.brandElectric : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hari ${index + 1}',
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 13,
                color: isSelected
                    ? CustomColor.brandElectric
                    : CustomColor.inputBorderGray,
              ),
            ),
            Text(
              formatted,
              style: primaryTextStyle.copyWith(
                fontSize: 11,
                color: isSelected
                    ? CustomColor.brandElectric
                    : CustomColor.inputBorderGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Circular icon action button
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        height: 48,
        width: 48,
        decoration: const BoxDecoration(
          color: CustomColor.lightCoolGray,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: CustomColor.boardroomNavy),
      ),
    );
  }
}

// Empty day state
class _EmptyDayState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 40,
            color: CustomColor.inputBorderGray,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada aktivitas',
            style: primaryTextStyle.copyWith(
              fontSize: 15,
              fontWeight: medium,
              color: CustomColor.subtitleTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan aktivitas untuk hari ini',
            style: primaryTextStyle.copyWith(
              fontSize: 13,
              color: CustomColor.inputBorderGray,
            ),
          ),
        ],
      ),
    );
  }
}
