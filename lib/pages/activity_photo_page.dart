// ignore_for_file: unused_element

import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_controller.dart';
import 'package:iterasi1/pages/activity_trash_photo_page.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ActivityPhotoPage extends StatefulWidget {
  final Activity activity;
  final int dayIndex;
  const ActivityPhotoPage({
    Key? key,
    required this.activity,
    required this.dayIndex,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivityPhotoPageState createState() => _ActivityPhotoPageState();
}

class _ActivityPhotoPageState extends State<ActivityPhotoPage> {
  final controller = Get.put(PhotoController());
  final _fileNameFormatter = DateFormat('yyyyMMdd_HHmmss');
  static const MethodChannel _mediaScannerChannel =
      MethodChannel('trip_planner/media_scanner');

  late ItineraryProvider itineraryProvider =
      Provider.of<ItineraryProvider>(context, listen: false);

  String _buildFileName(String sourcePath) {
    final String extension = path_lib.extension(sourcePath).toLowerCase();
    final String safeExtension = extension.isEmpty ? '.jpg' : extension;
    return 'TP_${_fileNameFormatter.format(DateTime.now())}$safeExtension';
  }

  Future<File?> _saveToTripPlannerAlbum(
      File sourceFile, String fileName) async {
    try {
      final Directory albumDir =
          Directory('/storage/emulated/0/Pictures/Trip Planner');
      if (!await albumDir.exists()) {
        await albumDir.create(recursive: true);
      }
      final File albumFile = File('${albumDir.path}/$fileName');
      final copiedFile = await sourceFile.copy(albumFile.path);
      try {
        await _mediaScannerChannel.invokeMethod('scanFile', {
          'path': copiedFile.path,
        });
      } catch (e) {
        log('Media scanner failed for ${copiedFile.path}: $e');
      }
      return copiedFile;
    } catch (e) {
      log('Failed to save file to Trip Planner album: $e');
      return null;
    }
  }

  Future<File> _saveToInternalStorage(File sourceFile, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return sourceFile.copy('${appDir.path}/$fileName');
  }

  _saveCameraImage() async {
    final picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.camera);
    if (imagePicked != null && imagePicked.path.isNotEmpty) {
      log('Camera image picked: ${imagePicked.path}');
      final File imageFile = File(imagePicked.path);
      final fileName = _buildFileName(imageFile.path);
      final savedImage = await _saveToInternalStorage(imageFile, fileName);
      await _saveToTripPlannerAlbum(savedImage, fileName);
      log('Image saved to: ${savedImage.path}');
      if (!widget.activity.images!.contains(savedImage.path)) {
        log('Image added to activity images: ${savedImage.path}');
        itineraryProvider.addPhotoActivity(
            activity: widget.activity, pathImage: savedImage.path);
        // Refresh from cache only — running a full gallery sync here would
        // re-import the just-saved camera photo and show it twice.
        controller.loadCachedImagesOnly();
        log('Image added to local image list: ${savedImage.path}');
      } else {
        log('Image already exists in activity images: ${savedImage.path}');
      }
    } else {
      log('Camera image path is null or empty');
    }
  }

  _saveGalleryImage() async {
    final picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null && imagePicked.path.isNotEmpty) {
      log('Gallery image picked: ${imagePicked.path}');
      final File imageFile = File(imagePicked.path);
      final fileName = _buildFileName(imageFile.path);
      final savedImage = await _saveToInternalStorage(imageFile, fileName);
      log('Image saved to: ${savedImage.path}');
      if (!widget.activity.images!.contains(savedImage.path)) {
        log('Image added to activity images: ${savedImage.path}');
        itineraryProvider.addPhotoActivity(
            activity: widget.activity, pathImage: savedImage.path);
        controller.loadCachedImagesOnly();
        log('Image added to local image list: ${savedImage.path}');
      } else {
        log('Image already exists in activity images: ${savedImage.path}');
      }
    } else {
      log('Gallery image path is null or empty');
    }
  }

  @override
  void initState() {
    controller.itineraryProvider = itineraryProvider;
    // ignore: avoid_print
    print('widget : ${widget.activity.startDateTime}');
    // ignore: avoid_print
    print('widget 2 : ${widget.activity.startActivityTime}');
    controller.activity = widget.activity;
    controller.activityDate =
        itineraryProvider.itinerary.days[widget.dayIndex].date;
    // Permission is handled by photo_manager/image_picker on demand — no
    // manageExternalStorage request here (it caused gallery access to fail).
    cleanUpImages();
    controller.image.value =
        controller.convertPathsToFiles(widget.activity.images!);
    log('Initial images: ${widget.activity.images}');
    controller.loadImage();
    super.initState();
  }

  void cleanUpImages() {
    log('Cleaning up images...');
    widget.activity.images = widget.activity.images!
        .where((image) => image.isNotEmpty)
        .toSet()
        .toList();
    log('Cleaned images: ${widget.activity.images}');
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
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.85),
            builder: (BuildContext dialogContext) {
              return Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Full-screen layer: tapping anywhere outside the photo
                    // closes the viewer.
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        // Absorb taps on the photo so it doesn't dismiss.
                        onTap: () {},
                        child: SizedBox(
                          width: dialogWidth,
                          height: dialogHeight,
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
    final photoCount = widget.activity.images?.length ?? 0;

    return Scaffold(
      backgroundColor: CustomColor.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header
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
                  const Expanded(
                    child: Center(
                      child: IterasiKicker(
                        'jurnal aktivitas',
                        color: CustomColor.muted,
                      ),
                    ),
                  ),
                  // Balances the back button so the kicker stays centered.
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Hero section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IterasiKicker(
                    '${widget.activity.startActivityTime} · hari ${widget.dayIndex + 1}',
                    color: CustomColor.coral700,
                  ),
                  const SizedBox(height: 4),
                  IterasiDisplay(
                    widget.activity.activityName,
                    style: const TextStyle(
                        fontSize: 22, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 2),
                  IterasiMono(
                    '${widget.activity.lokasi} · $photoCount foto',
                    color: CustomColor.muted,
                  ),
                ],
              ),
            ),

            // Photo grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.syncGalleryIncremental(force: true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    if (controller.isLoading.isTrue) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: CustomColor.coral500,
                                size: 200,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (controller.image.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color:
                                          CustomColor.sand300.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera_outlined,
                                      size: 30,
                                      color: CustomColor.coral500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  IterasiDisplay(
                                    'Belum ada foto.',
                                    style: const TextStyle(fontSize: 22),
                                    color: CustomColor.ocean900,
                                  ),
                                  const SizedBox(height: 8),
                                  IterasiBody(
                                    'Saat sampai sini, ambil 1–2 jepretan — biar jurnal trip-mu hidup.',
                                    color: CustomColor.ocean700,
                                    maxLines: 3,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: MasonryView(
                        listOfItem: controller.image,
                        numberOfColumn: 3,
                        itemBuilder: (item) {
                          final file = item as File;
                          return GestureDetector(
                            onTap: () => _showImageDialog(file),
                            onLongPress: () {
                              controller.showDeleteConfirmationDialog(
                                  context, file);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  // Camera
                  GestureDetector(
                    onTap: () async => await _saveCameraImage(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CustomColor.ocean900.withOpacity(0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: CustomColor.ocean900,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Gallery pill
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async => await _saveGalleryImage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColor.ocean900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Tambah dari galeri',
                        style: bodyStyle.copyWith(
                          color: Colors.white,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Trash
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityTrashPhotoPage(
                            activity: widget.activity,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: CustomColor.coral500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
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
