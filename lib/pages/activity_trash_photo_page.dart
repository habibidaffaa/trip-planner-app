import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:get/get.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_controller.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:iterasi1/widget/text_dialog.dart';

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
  final controller = Get.put(PhotoController());

  List<File> get removedImages => (widget.activity.removedImages ?? const [])
      .where((path) => path.isNotEmpty)
      .map((path) => File(path))
      .toList();

  Future<void> _confirmRestorePhoto(File file) async {
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
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IterasiKicker(
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

            Container(
              height: 1,
              color: CustomColor.ocean900.withOpacity(0.08),
            ),

            // Grid
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                        : MasonryView(
                            listOfItem: removedImages,
                            numberOfColumn: 2,
                            itemBuilder: (item) {
                              final file = item as File;
                              return GestureDetector(
                                onTap: () => _showImageDialog(file),
                                onLongPress: () => _confirmRestorePhoto(file),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
