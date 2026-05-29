import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> persistThumbnail(File sourceFile, String itineraryId) async {
  final dir = await getApplicationDocumentsDirectory();
  final thumbnailDir = Directory('${dir.path}/thumbnails');
  if (!thumbnailDir.existsSync()) {
    thumbnailDir.createSync(recursive: true);
  }
  final dest = File('${thumbnailDir.path}/$itineraryId.jpg');
  await sourceFile.copy(dest.path);
  return dest.path;
}
