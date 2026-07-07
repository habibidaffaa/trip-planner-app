import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/widget/text_dialog.dart';
import 'package:provider/provider.dart';

class PhotoController extends GetxController {
  RxList<File> image = <File>[].obs;
  RxBool isLoading = true.obs;
  late Activity activity;
  late ItineraryProvider itineraryProvider =
      Provider.of<ItineraryProvider>(Get.context!, listen: false);

  // Multi-select state.
  RxBool isSelectionMode = false.obs;
  RxList<File> selectedPhotos = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  bool isSelected(File file) =>
      selectedPhotos.any((selected) => selected.path == file.path);

  void enterSelection(File file) {
    selectedPhotos.assignAll([file]);
    isSelectionMode.value = true;
  }

  void toggleSelection(File file) {
    if (isSelected(file)) {
      selectedPhotos.removeWhere((selected) => selected.path == file.path);
      if (selectedPhotos.isEmpty) {
        exitSelection();
      }
    } else {
      selectedPhotos.add(file);
    }
  }

  void selectAll() {
    selectedPhotos.assignAll(image);
  }

  void exitSelection() {
    selectedPhotos.clear();
    isSelectionMode.value = false;
  }

  Future<void> deleteSelected() async {
    for (final file in List<File>.from(selectedPhotos)) {
      itineraryProvider.removePhotoActivity(
        activity: activity,
        pathImage: file.path,
      );
    }
    exitSelection();
    loadCachedImagesOnly();
  }

  Future<void> loadImage() async {
    isLoading.value = true;
    loadCachedImagesOnly();
    isLoading.value = false;
  }

  void loadCachedImagesOnly() {
    final imagesave = itineraryProvider.getImage(activity);
    final filteredA = imagesave
        .where((item) => !(activity.removedImages?.contains(item) ?? false))
        .toList();
    final filedb = convertPathsToFiles(filteredA);
    image.value = filedb;
  }

  List<File> convertPathsToFiles(List<String> paths) {
    log('Converting paths to files: $paths');
    List<File> files = [];
    for (String path in paths) {
      if (path.isNotEmpty) {
        // Periksa jika path tidak kosong
        File file = File(path);
        if (file.existsSync()) {
          // Pastikan file ada di lokasi yang diberikan
          files.add(file);
        } else {
          log('File does not exist at path: $path');
        }
      } else {
        log('Encountered empty path in list: $paths');
      }
    }
    return files;
  }

  Future<void> deletePhoto(File image) async {
    itineraryProvider.removePhotoActivity(
      activity: activity,
      pathImage: image.path,
    );
    loadImage();
  }

  Future<void> returnPhoto(File image) async {
    itineraryProvider.returnPhotoActivity(
      activity: activity,
      pathImage: image.path,
    );
    loadImage();
  }

  Future<void> permanentlyDeletePhoto(File image) async {
    log('Controller.permanentlyDeletePhoto called for: ${image.path}');
    log('Activity removedImages before: ${activity.removedImages}');
    await itineraryProvider.permanentlyDeletePhoto(
      activity: activity,
      pathImage: image.path,
    );
    log('Activity removedImages after: ${activity.removedImages}');
    loadRemovedImages();
  }

  Future<void> permanentlyDeleteSelected() async {
    log('Controller.permanentlyDeleteSelected called');
    log('selectedPhotos count: ${selectedPhotos.length}');
    log('selectedTrashPhotos count: ${selectedTrashPhotos.length}');
    final filesToDelete = List<File>.from(selectedTrashPhotos);
    log('filesToDelete count: ${filesToDelete.length}');
    for (final file in filesToDelete) {
      log('Deleting: ${file.path}');
      await itineraryProvider.permanentlyDeletePhoto(
        activity: activity,
        pathImage: file.path,
      );
    }
    exitTrashSelection();
    loadRemovedImages();
  }

  void loadRemovedImages() {
    final removedPaths = activity.removedImages ?? [];
    final files = removedPaths
        .where((path) => path.isNotEmpty)
        .map((path) => File(path))
        .where((file) => file.existsSync())
        .toList();
    image.value = files;
  }

  int getRemainingDays(String path) {
    final timestamp = activity.removedImagesTimestamp?[path];
    if (timestamp == null) return 30;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - timestamp;
    const thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;
    final remaining = thirtyDaysMs - elapsed;
    if (remaining <= 0) return 0;
    return (remaining / (24 * 60 * 60 * 1000)).ceil();
  }

  bool isExpired(String path) {
    return getRemainingDays(path) <= 0;
  }

  // Trash selection state
  RxBool isTrashSelectionMode = false.obs;
  RxList<File> selectedTrashPhotos = <File>[].obs;

  bool isTrashSelected(File file) =>
      selectedTrashPhotos.any((selected) => selected.path == file.path);

  void enterTrashSelection(File file) {
    selectedTrashPhotos.assignAll([file]);
    isTrashSelectionMode.value = true;
  }

  void toggleTrashSelection(File file) {
    if (isTrashSelected(file)) {
      selectedTrashPhotos.removeWhere((selected) => selected.path == file.path);
      if (selectedTrashPhotos.isEmpty) {
        exitTrashSelection();
      }
    } else {
      selectedTrashPhotos.add(file);
    }
  }

  void selectAllTrash(List<File> trashImages) {
    selectedTrashPhotos.assignAll(trashImages);
  }

  void exitTrashSelection() {
    selectedTrashPhotos.clear();
    isTrashSelectionMode.value = false;
  }

  Future<void> deleteExpiredPhotos() async {
    await itineraryProvider.permanentlyDeleteExpiredPhotos();
    loadRemovedImages();
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, File image) async {
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Hapus foto?',
        message:
            'Foto ini akan dipindahkan ke sampah. Kamu masih bisa memulihkannya nanti.',
        confirmLabel: 'Hapus',
        onConfirm: () => deletePhoto(image),
      ),
    );
  }

  Future<void> showReturnConfirmationDialog(
      BuildContext context, File image) async {
    showDialog(
      context: context,
      builder: (_) => IterasiConfirmDialog(
        title: 'Pulihkan foto?',
        message: 'Foto ini akan dikembalikan ke jurnal aktivitas.',
        confirmLabel: 'Pulihkan',
        onConfirm: () => returnPhoto(image),
      ),
    );
  }
}
