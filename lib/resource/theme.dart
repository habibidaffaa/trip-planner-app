import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class CustomColor {
  static const primary = Color(0xFFF4B666);
  static const surface = Color(0xFFFAF8F1);
  static const buttonColor = Color(0xFFC58940);
  static const dateBackground = Color(0xFFED9D3B);
  static const borderColor = Color(0xFF979797);
  static const backgroundColor = Color(0xFFFAF8F1);

  static const primaryColor50 = Color(0xfffef8f0);
  static const primaryColor100 = Color(0xFFfce8d0);
  static const primaryColor200 = Color(0xFFfaddb9);
  static const primaryColor300 = Color(0xFFf8ce98);
  static const primaryColor400 = Color(0xFFf4b666);
  static const primaryColor500 = Color(0xFFF4B666);
  static const primaryColor600 = Color(0xFFdea65d);
  static const primaryColor700 = Color(0xFFad8148);
  static const primaryColor800 = Color(0xFF866438);
  static const primaryColor900 = Color(0xFF664c2b);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF343434);

  static const subtitleTextColor = Color(0xFF808080);
  static const hintTextColor = Color(0xFFBAC2C7);
  static const warningColor = Color(0xFFff3f56);

  static const greyBackgroundColor = Color(0xFFF9F9F9);

  static const disabledColor = Color(0xFFC4C4C4);
  static const transparentColor = Colors.transparent;

  static const scaffoldBackground = whiteColor;
  static const cardBackground = primaryColor50;
  static const cardBorder = Color(0xFFDADADA);
  static const dividerColor = Color(0xFFDADADA);
  static const inputFillColor = greyBackgroundColor;
  static const inputBorderColor = borderColor;
  static const successColor = Color(0xFF4FD968);
  static const shadowColor = Color(0x14000000);
  static const actionPanelShadowColor = Color(0x26000000);
}

class AppTheme {
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(5));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(100));

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: CustomColor.primary,
    primary: CustomColor.primary,
    secondary: CustomColor.buttonColor,
    surface: CustomColor.whiteColor,
    error: CustomColor.warningColor,
    brightness: Brightness.light,
  ).copyWith(
    onPrimary: CustomColor.whiteColor,
    onSecondary: CustomColor.whiteColor,
    onSurface: CustomColor.blackColor,
    onError: CustomColor.whiteColor,
  );

  static OutlineInputBorder inputBorder(
      [Color color = CustomColor.inputBorderColor]) {
    return OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  static BoxDecoration softCardDecoration({
    Color backgroundColor = CustomColor.cardBackground,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: Border.all(color: CustomColor.cardBorder),
      boxShadow: const [
        BoxShadow(
          color: CustomColor.shadowColor,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration actionPanelDecoration() {
    return const BoxDecoration(
      color: CustomColor.whiteColor,
      boxShadow: [
        BoxShadow(
          color: CustomColor.actionPanelShadowColor,
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData(
      colorScheme: colorScheme,
      primaryColor: CustomColor.primary,
      scaffoldBackgroundColor: CustomColor.scaffoldBackground,
      canvasColor: CustomColor.whiteColor,
      dividerColor: CustomColor.dividerColor,
      shadowColor: CustomColor.shadowColor,
      splashColor: CustomColor.primaryColor100,
      highlightColor: CustomColor.primaryColor50,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CustomColor.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CustomColor.primary,
        foregroundColor: CustomColor.whiteColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: CustomColor.transparentColor,
        titleTextStyle: primaryTextStyle.copyWith(
          fontWeight: semibold,
          fontSize: 18,
          color: CustomColor.whiteColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: CustomColor.inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: primaryTextStyle.copyWith(
          color: CustomColor.hintTextColor,
          fontSize: 14,
          fontWeight: medium,
        ),
        errorStyle: primaryTextStyle.copyWith(
          color: colorScheme.error,
          fontSize: 10,
          fontWeight: medium,
        ),
        border: inputBorder(),
        enabledBorder: inputBorder(),
        focusedBorder: inputBorder(CustomColor.primary),
        errorBorder: inputBorder(colorScheme.error),
        focusedErrorBorder: inputBorder(colorScheme.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.primary,
          foregroundColor: CustomColor.whiteColor,
          disabledBackgroundColor: CustomColor.disabledColor,
          disabledForegroundColor: CustomColor.whiteColor,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: const RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: primaryTextStyle.copyWith(
            fontWeight: semibold,
            fontSize: 16,
            color: CustomColor.whiteColor,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CustomColor.primary,
        foregroundColor: CustomColor.whiteColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: pillRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CustomColor.blackColor,
        contentTextStyle: primaryTextStyle.copyWith(
          color: CustomColor.whiteColor,
          fontWeight: medium,
        ),
        actionTextColor: CustomColor.primaryColor100,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CustomColor.whiteColor,
        surfaceTintColor: CustomColor.transparentColor,
        shape: RoundedRectangleBorder(borderRadius: largeRadius),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CustomColor.primary,
        selectedItemColor: CustomColor.blackColor,
        unselectedItemColor: CustomColor.primaryColor900,
        selectedLabelStyle: primaryTextStyle.copyWith(
          fontSize: 12,
          fontWeight: semibold,
        ),
        unselectedLabelStyle: primaryTextStyle.copyWith(
          fontSize: 12,
          fontWeight: medium,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: CustomColor.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: CustomColor.blackColor,
        displayColor: CustomColor.blackColor,
      ),
    );
  }
}

TextStyle primaryTextStyle = GoogleFonts.poppins(
  color: CustomColor.blackColor,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
