import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:iterasi1/widget/text_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityCard extends StatelessWidget {
  final Activity data;
  final int selectedDayIndex;
  final int activityIndex;
  final bool isFirst;
  final void Function() onDismiss;
  final void Function() onUndo;
  final ScaffoldMessengerState snackbarHandler;

  const ActivityCard({
    super.key,
    required this.data,
    required this.selectedDayIndex,
    required this.activityIndex,
    this.isFirst = false,
    required this.onDismiss,
    required this.onUndo,
    required this.snackbarHandler,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> openGoogleMaps(String placeName) async {
      final query = Uri.encodeComponent(placeName);
      final url =
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    void openPhotoPage(Activity activity) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityPhotoPage(
            dayIndex: selectedDayIndex,
            activity: activity,
          ),
        ),
      );
    }

    void confirmDeleteActivity() {
      snackbarHandler.removeCurrentSnackBar();
      showDialog(
        context: context,
        builder: (_) => IterasiConfirmDialog(
          title: 'Hapus aktivitas?',
          message:
              'Aktivitas "${data.activityName}" akan dihapus dari hari ini.',
          confirmLabel: 'Hapus',
          onConfirm: onDismiss,
        ),
      );
    }

    void showActivityDetailDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: CustomColor.paper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          title: Container(
            alignment: Alignment.center,
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: CustomColor.ocean900,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DETAIL AKTIVITAS',
                  style: monoStyle.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.22 * 11,
                    color: CustomColor.sand300,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.activityName,
                  style: displayStyle.copyWith(
                    fontSize: 18,
                    color: CustomColor.paper,
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
                        if (data.catatan != null &&
                            data.catatan!.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.sticky_note_2_outlined,
                            label: 'Catatan Tambahan',
                            value: data.catatan!,
                            singleLine: false,
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  decoration: BoxDecoration(
                    color: CustomColor.paper,
                    border: Border(
                      top: BorderSide(
                        color: CustomColor.ocean900.withOpacity(0.10),
                      ),
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
                              openPhotoPage(data);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.perm_media_outlined,
                                      color: CustomColor.ocean900, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Galeri',
                                    style: bodyStyle.copyWith(
                                      fontWeight: semibold,
                                      fontSize: 14,
                                      color: CustomColor.ocean900,
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
                              color: CustomColor.ocean900.withOpacity(0.10),
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
                                        color: CustomColor.ocean900, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Map',
                                      style: bodyStyle.copyWith(
                                        fontWeight: semibold,
                                        fontSize: 14,
                                        color: CustomColor.ocean900,
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
                          final provider = context.read<ItineraryProvider>();
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .push<Activity>(
                            MaterialPageRoute(
                              builder: (_) => AddActivities(
                                initialActivity: data,
                              ),
                            ),
                          )
                              .then((newActivity) {
                            if (newActivity != null) {
                              provider.updateActivity(
                                updatedDayIndex: selectedDayIndex,
                                updatedActivityIndex: activityIndex,
                                newActivity: newActivity,
                              );
                            }
                          });
                        },
                        child: Container(
                          height: 48,
                          decoration: const BoxDecoration(
                            color: CustomColor.coral500,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Edit Aktivitas',
                            style: bodyStyle.copyWith(
                              fontWeight: semibold,
                              fontSize: 15,
                              color: CustomColor.paper,
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
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column: dot + line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _TimelineDot(isFirst: isFirst),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: CustomColor.ocean900.withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card body
          Expanded(
            child: GestureDetector(
              onTap: showActivityDetailDialog,
              onLongPress: confirmDeleteActivity,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CustomColor.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColor.ocean900.withOpacity(0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.shadowSoft,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          data.startActivityTime,
                          style: monoStyle.copyWith(
                            fontSize: 12,
                            color: CustomColor.coral700,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: confirmDeleteActivity,
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: CustomColor.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.activityName,
                      style: bodyStyle.copyWith(
                        fontWeight: medium,
                        fontSize: 15,
                        color: CustomColor.ocean900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.lokasi,
                      style: monoStyle.copyWith(
                        fontSize: 12,
                        color: CustomColor.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!data.isCustomLocation) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => openGoogleMaps(data.lokasi),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: CustomColor.ocean50,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: CustomColor.ocean900.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            'Lihat di peta',
                            style: monoStyle.copyWith(
                              fontSize: 11,
                              color: CustomColor.ocean700,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${AppHelper.calculateDurationInMinutes(data.startActivityTime, data.endActivityTime)} min  ·  ${data.endActivityTime}',
                      style: monoStyle.copyWith(
                        fontSize: 11,
                        color: CustomColor.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final bool isFirst;
  const _TimelineDot({required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isFirst ? CustomColor.coral500 : CustomColor.ocean300,
        shape: BoxShape.circle,
        border: Border.all(color: CustomColor.paper, width: 2),
      ),
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
            Icon(icon, color: CustomColor.coral500, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: monoStyle.copyWith(
                fontSize: 11,
                letterSpacing: 0.22 * 11,
                color: CustomColor.coral500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: bodyStyle.copyWith(
            fontSize: 14,
            fontWeight: regular,
            color: CustomColor.ocean900,
          ),
          maxLines: singleLine ? 1 : null,
          overflow: singleLine ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}
