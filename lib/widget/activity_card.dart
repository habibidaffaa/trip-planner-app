import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityCard extends StatelessWidget {
  final Activity data;
  final int selectedDayIndex;
  final int activityIndex;
  final void Function() onDismiss;
  final void Function() onUndo;
  final ScaffoldMessengerState snackbarHandler;

  const ActivityCard({
    super.key,
    required this.data,
    required this.selectedDayIndex,
    required this.activityIndex,
    required this.onDismiss,
    required this.onUndo,
    required this.snackbarHandler,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> openGoogleMaps(String placeName) async {
      String query = Uri.encodeComponent(placeName);
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=$query";
      final Uri url = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
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
            content: const Text(
                "Aplikasi memerlukan izin untuk mengakses galeri."),
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

    void showActivityDetailDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: CustomColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            title: Container(
              alignment: Alignment.center,
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomColor.boardroomNavy,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DETAIL AKTIVITAS',
                    style: primaryTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: semibold,
                      letterSpacing: 1.0,
                      color: CustomColor.lilacAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.activityName,
                    style: headingTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: semibold,
                      color: CustomColor.whiteColor,
                      letterSpacing: -0.36,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DetailRow(
                            icon: Icons.place_outlined,
                            label: 'Lokasi',
                            value: data.lokasi,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.schedule_outlined,
                            label: 'Waktu',
                            value:
                                '${data.startActivityTime} – ${data.endActivityTime}',
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.notes_outlined,
                            label: 'Keterangan',
                            value: data.keterangan,
                            singleLine: false,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    decoration: BoxDecoration(
                      color: CustomColor.softOffWhite,
                      border: Border(
                        top: BorderSide(color: CustomColor.lightCoolGray),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                requestGalleryPermission(data);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.perm_media_outlined,
                                        color: CustomColor.boardroomNavy,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Galeri',
                                      style: primaryTextStyle.copyWith(
                                        fontWeight: semibold,
                                        fontSize: 14,
                                        color: CustomColor.boardroomNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!data.isCustomLocation) ...[
                              Container(
                                width: 1,
                                height: 24,
                                color: CustomColor.lightCoolGray,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  openGoogleMaps(data.lokasi);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.map_outlined,
                                          color: CustomColor.boardroomNavy,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Map',
                                        style: primaryTextStyle.copyWith(
                                          fontWeight: semibold,
                                          fontSize: 14,
                                          color: CustomColor.boardroomNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddActivities(
                                    initialActivity: data,
                                    onSubmit: (newActivity) {
                                      context
                                          .read<ItineraryProvider>()
                                          .updateActivity(
                                            updatedDayIndex: selectedDayIndex,
                                            updatedActivityIndex: activityIndex,
                                            newActivity: newActivity,
                                          );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: const BoxDecoration(
                              color: CustomColor.brandElectric,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Edit Aktivitas',
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 15,
                                color: CustomColor.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: const [],
          );
        },
      );
    }

    return Stack(
      children: [
        InkWell(
          onTap: showActivityDetailDialog,
          child: Container(
            decoration: AppTheme.softCardDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: CustomColor.whiteColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location row
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: CustomColor.inputBorderGray,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            data.lokasi,
                            style: primaryTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: medium,
                              color: CustomColor.subtitleTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Activity name
                    Text(
                      data.activityName,
                      style: headingTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semibold,
                        color: CustomColor.boardroomNavy,
                        letterSpacing: -0.36,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Time row
                    Row(
                      children: [
                        _TimeChip(label: 'MULAI', time: data.startActivityTime),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 32,
                          color: CustomColor.lightCoolGray,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: CustomColor.lightCoolGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${AppHelper.calculateDurationInMinutes(data.startActivityTime, data.endActivityTime)} min',
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              color: CustomColor.boardroomNavy,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 32,
                          color: CustomColor.lightCoolGray,
                        ),
                        const SizedBox(width: 8),
                        _TimeChip(
                            label: 'SELESAI', time: data.endActivityTime),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Delete icon
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: () {
              snackbarHandler.removeCurrentSnackBar();
              onDismiss();
              snackbarHandler.showSnackBar(
                SnackBar(
                  content: const Text("Item dihapus!"),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      onUndo();
                      snackbarHandler.removeCurrentSnackBar();
                    },
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.delete_outline,
                size: 16,
                color: CustomColor.inputBorderGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;

  const _TimeChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(
            fontWeight: semibold,
            fontSize: 10,
            color: CustomColor.brandElectric,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          time,
          style: primaryTextStyle.copyWith(
            fontWeight: medium,
            fontSize: 14,
            color: CustomColor.pitchBlack,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool singleLine;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.singleLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: CustomColor.brandElectric, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: primaryTextStyle.copyWith(
                fontSize: 11,
                fontWeight: semibold,
                color: CustomColor.brandElectric,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: regular,
            color: CustomColor.pitchBlack,
          ),
          maxLines: singleLine ? 1 : null,
          overflow: singleLine ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}
