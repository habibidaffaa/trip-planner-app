import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/widget/text_dialog.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PhotoController extends GetxController {
  RxList<File> image = <File>[].obs;
  RxBool isLoading = true.obs;
  late Activity activity;
  late String activityDate;
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
    await syncGalleryIncremental();

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

  DateTime? _parseActivityDate() {
    final parts = activityDate.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  bool _isWithinActivityWindow(DateTime photoDateTime) {
    final selectedDate = _parseActivityDate();
    if (selectedDate == null) {
      return false;
    }

    if (photoDateTime.year != selectedDate.year ||
        photoDateTime.month != selectedDate.month ||
        photoDateTime.day != selectedDate.day) {
      return false;
    }

    final start = activity.startTimeOfDay;
    final end = activity.endTimeOfDay;

    final startMinute = (start.hour * 60) + start.minute;
    final endMinute = (end.hour * 60) + end.minute;
    final photoMinute = (photoDateTime.hour * 60) + photoDateTime.minute;

    if (endMinute < startMinute) {
      return false;
    }

    return photoMinute >= startMinute && photoMinute <= endMinute;
  }

  String _sanitizeHash(String rawHash) {
    return rawHash.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  String _buildAssetHash(AssetEntity asset) {
    return _sanitizeHash(
      '${asset.id}_${asset.createDateTime.millisecondsSinceEpoch}',
    );
  }

  Future<void> syncGalleryIncremental({bool force = false}) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isEmpty) {
        return;
      }

      // Skip the app's own album: photos captured via the in-app camera are
      // already added manually, and saved to "Pictures/Trip Planner". Scanning
      // that bucket would re-import them as AUTO_ copies → duplicate photos.
      final scanAlbums = albums
          .where((album) => album.name.toLowerCase().trim() != 'trip planner')
          .toList();
      if (scanAlbums.isEmpty) {
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();

      final existing = Set<String>.from(activity.images ?? const <String>[]);
      final removed =
          Set<String>.from(activity.removedImages ?? const <String>[]);
      final hiddenHashes =
          Set<String>.from(activity.hiddenPhotoHashes ?? const <String>[]);
      final lastScanEpochMs = activity.lastGalleryScanEpochMs ?? 0;
      int newestScanEpochMs = lastScanEpochMs;

      for (final album in scanAlbums) {
        final assets = await album.getAssetListPaged(page: 0, size: 1200);

        for (final asset in assets) {
          final createdAt = asset.createDateTime;
          final createdAtEpochMs = createdAt.millisecondsSinceEpoch;

          if (!force && createdAtEpochMs <= lastScanEpochMs) {
            continue;
          }

          if (createdAtEpochMs > newestScanEpochMs) {
            newestScanEpochMs = createdAtEpochMs;
          }

          if (!_isWithinActivityWindow(createdAt)) {
            continue;
          }

          final assetHash = _buildAssetHash(asset);
          if (hiddenHashes.contains(assetHash)) {
            continue;
          }

          final originalFile = await asset.originFile;
          if (originalFile == null) {
            continue;
          }

          final extension = path_lib.extension(originalFile.path).toLowerCase();
          final safeExtension = extension.isEmpty ? '.jpg' : extension;
          final internalName = 'AUTO_$assetHash$safeExtension';
          final internalPath = '${appDir.path}/$internalName';

          final internalFile = File(internalPath);
          if (!await internalFile.exists()) {
            await originalFile.copy(internalPath);
          }

          if (removed.contains(internalPath) ||
              existing.contains(internalPath)) {
            continue;
          }

          itineraryProvider.addPhotoActivity(
            activity: activity,
            pathImage: internalPath,
          );
          existing.add(internalPath);
        }
      }

      final nowEpochMs = DateTime.now().millisecondsSinceEpoch;
      final targetEpochMs =
          newestScanEpochMs > nowEpochMs ? newestScanEpochMs : nowEpochMs;
      itineraryProvider.updateLastGalleryScan(
        activity,
        targetEpochMs,
        shouldNotify: false,
      );
      loadCachedImagesOnly();
    } catch (e) {
      log('Auto import photos failed: $e');
    }
  }

  // Future<List<File>> loadNewPhotos() async {
  //   var result = await PhotoManager.requestPermissionExtend();
  //   var status = await Permission.manageExternalStorage.request();
  //   print(result);
  //   if (result.isAuth) {
  //     List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
  //     List<AssetEntity> assets =
  //         await albums.first.getAssetListPaged(page: 0, size: 100);
  //     List<File> files = [];
  //     for (var asset in assets) {
  //       bool isInDate = false;
  //       var file = await asset.originFile;
  //       if (file != null) {
  //         isInDate = await matchesActivityTime(file);
  //         if (isInDate == true) {
  //           files.add(file);
  //         }
  //       }
  //     }
  //     return files;
  //   } else {
  //     print('tidak masuk');
  //     PhotoManager.openSetting();
  //     return [];
  //   }
  // }

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
    _addHiddenHashIfAuto(image.path);
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
      _addHiddenHashIfAuto(file.path);
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

  void _addHiddenHashIfAuto(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    if (!fileName.startsWith('AUTO_')) return;
    final extensionIndex = fileName.lastIndexOf('.');
    final rawHash = extensionIndex > 5
        ? fileName.substring(5, extensionIndex)
        : fileName.substring(5);
    if (rawHash.isNotEmpty) {
      itineraryProvider.addHiddenPhotoHashForActivity(
        activity: activity,
        hash: itineraryProvider.normalizeHiddenPhotoHash(rawHash),
      );
    }
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
