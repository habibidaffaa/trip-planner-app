import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_controller.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:iterasi1/widget/text_dialog.dart';
import 'package:provider/provider.dart';

class ActivityTrashPhotoPage extends StatefulWidget {
  final Activity activity;
  const ActivityTrashPhotoPage({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivityTrashPhotoPageState createState() => _ActivityTrashPhotoPageState();
}

class _ActivityTrashPhotoPageState extends State<ActivityTrashPhotoPage> {
  late final PhotoController controller;

  List<File> get removedImages => (widget.activity.removedImages ?? const [])
      .where((path) => path.isNotEmpty)
      .map((path) => File(path))
      .toList();

  @override
  void initState() {
    super.initState();
    // Force create new instance with unique tag to avoid GetX reuse
    controller = Get.put(PhotoController(), tag: 'trash_${widget.activity.id}');
    controller.activity = widget.activity;
    controller.itineraryProvider =
        Provider.of<ItineraryProvider>(context, listen: false);
    _deleteExpiredPhotos();
  }

  @override
  void dispose() {
    Get.delete<PhotoController>(tag: 'trash_${widget.activity.id}');
    super.dispose();
  }

  Future<void> _deleteExpiredPhotos() async {
    await controller.deleteExpiredPhotos();
    if (mounted) {
      setState(() {});
    }
  }

  void _confirmPermanentlyDelete(File file) {
    log('_confirmPermanentlyDelete called for: ${file.path}');
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Hapus permanen?',
        message: 'Foto ini akan dihapus permanen dan tidak bisa dikembalikan.',
        confirmLabel: 'Hapus',
        onConfirm: () async {
          log('onConfirm callback triggered for: ${file.path}');
          try {
            await controller.permanentlyDeletePhoto(file);
            log('permanentlyDeletePhoto completed');
          } catch (e) {
            log('permanentlyDeletePhoto error: $e');
          }
          if (mounted) {
            setState(() {});
            log('setState called');
          }
        },
        cancelLabel: 'Batal',
      ),
    );
  }

  void _confirmRestorePhoto(File file) {
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Pulihkan foto?',
        message: 'Foto ini akan dikembalikan ke jurnal aktivitas.',
        confirmLabel: 'Pulihkan',
        onConfirm: () async {
          await controller.returnPhoto(file);
          if (mounted) {
            setState(() {});
          }
        },
        cancelLabel: 'Batal',
      ),
    );
  }

  void _confirmPermanentlyDeleteSelected() {
    final count = controller.selectedTrashPhotos.length;
    if (count == 0) return;
    log('_confirmPermanentlyDeleteSelected called for $count photos');
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Hapus $count foto permanen?',
        message:
            '$count foto akan dihapus permanen dan tidak bisa dikembalikan.',
        confirmLabel: 'Hapus',
        onConfirm: () async {
          log('onConfirm for selected triggered');
          try {
            await controller.permanentlyDeleteSelected();
            log('permanentlyDeleteSelected completed');
          } catch (e) {
            log('permanentlyDeleteSelected error: $e');
          }
          if (mounted) {
            setState(() {});
            log('setState called for selected');
          }
        },
      ),
    );
  }

  void _confirmRestoreSelected() {
    final count = controller.selectedTrashPhotos.length;
    if (count == 0) return;
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Pulihkan $count foto?',
        message: '$count foto akan dikembalikan ke jurnal aktivitas.',
        confirmLabel: 'Pulihkan',
        onConfirm: () async {
          for (final file in List<File>.from(controller.selectedTrashPhotos)) {
            await controller.returnPhoto(file);
          }
          controller.exitTrashSelection();
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  void _showImageDialog(File imageFile) {
    final image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final imageWidth = info.image.width;
          final imageHeight = info.image.height;
          final aspectRatio = imageWidth / imageHeight;
          final maxDialogWidth = MediaQuery.of(context).size.width * 0.9;
          final maxDialogHeight = MediaQuery.of(context).size.height * 0.8;

          double dialogWidth, dialogHeight;
          if (aspectRatio > 1) {
            dialogWidth = maxDialogWidth;
            dialogHeight = dialogWidth / aspectRatio;
          } else {
            dialogHeight = maxDialogHeight;
            dialogWidth = dialogHeight * aspectRatio;
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: dialogWidth,
                        height: dialogHeight,
                        child: Ink(
                          color: Colors.transparent,
                          child: image,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.isTrashSelectionMode.value) {
          controller.exitTrashSelection();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: CustomColor.paper,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Obx(
                  () => controller.isTrashSelectionMode.value
                      ? _buildSelectionHeader()
                      : Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        CustomColor.ocean900.withOpacity(0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: CustomColor.ocean900,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const IterasiKicker(
                                    'foto terhapus',
                                    color: CustomColor.muted,
                                  ),
                                  IterasiDisplay(
                                    'Foto Terhapus',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              Container(
                height: 1,
                color: CustomColor.ocean900.withOpacity(0.08),
              ),

              // Grid
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: removedImages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 48,
                                  color: CustomColor.muted.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                IterasiBody(
                                  'Tidak ada foto yang dihapus',
                                  color: CustomColor.muted,
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: removedImages.length,
                          itemBuilder: (context, index) {
                            final file = removedImages[index];
                            return _buildTrashPhotoItem(file);
                          },
                        ),
                ),
              ),

              // Bottom action bar
              Obx(
                () => controller.isTrashSelectionMode.value
                    ? _buildSelectionActionBar()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrashPhotoItem(File file) {
    final remainingDays = controller.getRemainingDays(file.path);
    final isExpiring = remainingDays <= 3;

    return GestureDetector(
      onTap: () {
        if (controller.isTrashSelectionMode.value) {
          controller.toggleTrashSelection(file);
        } else {
          _showImageDialog(file);
        }
      },
      onLongPress: () {
        if (!controller.isTrashSelectionMode.value) {
          controller.enterTrashSelection(file);
        }
      },
      child: Obx(() {
        final selected = controller.isTrashSelected(file);
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: selected
                    ? Border.all(
                        color: CustomColor.coral500,
                        width: 3,
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Remaining days badge
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$remainingDays hari lagi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isExpiring ? CustomColor.coral500 : Colors.black,
                  ),
                ),
              ),
            ),
            // Selection checkbox
            if (selected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: CustomColor.coral500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSelectionHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controller.exitTrashSelection(),
          behavior: HitTestBehavior.opaque,
          child: const IterasiKicker(
            'batal',
            color: CustomColor.coral700,
          ),
        ),
        Expanded(
          child: Center(
            child: Obx(
              () => IterasiKicker(
                '${controller.selectedTrashPhotos.length} dipilih',
                color: CustomColor.muted,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => controller.selectAllTrash(removedImages),
          behavior: HitTestBehavior.opaque,
          child: const IterasiKicker(
            'pilih semua',
            color: CustomColor.ocean900,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CustomColor.paper.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: CustomColor.ocean900.withOpacity(0.10),
          ),
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: CustomColor.ocean900,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            // Restore
            Expanded(
              child: InkWell(
                onTap: _confirmRestoreSelected,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restore,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pulihkan',
                      style: bodyStyle.copyWith(
                        color: Colors.white,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withOpacity(0.18),
            ),
            // Delete permanently
            Expanded(
              child: InkWell(
                onTap: _confirmPermanentlyDeleteSelected,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_forever,
                      color: CustomColor.coral500,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        'Hapus ${controller.selectedTrashPhotos.length}',
                        style: bodyStyle.copyWith(
                          color: CustomColor.coral500,
                          fontWeight: medium,
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
    );
  }
}
