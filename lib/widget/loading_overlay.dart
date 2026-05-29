import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';

class LoadingOverlay {
  static show(BuildContext context, {bool isDark = false}) {
    return OverlayLoadingProgress.start(
      context,
      barrierDismissible: false,
      widget: CircularProgressIndicator(
        color: isDark ? CustomColor.paper : CustomColor.coral500,
      ),
    );
  }

  static hide() {
    return OverlayLoadingProgress.stop();
  }
}
