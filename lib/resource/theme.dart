import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class CustomColor {
  // Core brand palette — Officevibe Design System
  static const boardroomNavy = Color(0xFF0C1754);
  static const brandElectric = Color(0xFF2545FF);
  static const lilacAccent = Color(0xFFD9D4FF);
  static const feedbackYellow = Color(0xFFFFC13A);
  static const softOffWhite = Color(0xFFF9F8F6);
  static const pitchBlack = Color(0xFF171417);
  static const mediumGray = Color(0xFF222222);
  static const lightCoolGray = Color(0xFFEAEBF8);
  static const inputBorderGray = Color(0xFFCCCCCC);
  static const accentOrange = Color(0xFFFF5B22);

  // Semantic aliases — kept for backward compatibility
  static const primary = brandElectric;
  static const surface = softOffWhite;
  static const buttonColor = brandElectric;
  static const dateBackground = lilacAccent;
  static const borderColor = inputBorderGray;
  static const backgroundColor = softOffWhite;

  // Brand Electric scale (replaces amber scale)
  static const primaryColor50 = Color(0xFFEEF0FF);
  static const primaryColor100 = Color(0xFFD9D4FF); // lilacAccent
  static const primaryColor200 = Color(0xFFB3AEFF);
  static const primaryColor300 = Color(0xFF8F87FF);
  static const primaryColor400 = Color(0xFF5C62FF);
  static const primaryColor500 = brandElectric;
  static const primaryColor600 = Color(0xFF1D3BDD);
  static const primaryColor700 = Color(0xFF162EB8);
  static const primaryColor800 = Color(0xFF0E2190);
  static const primaryColor900 = boardroomNavy;

  // Neutral
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = pitchBlack;

  static const subtitleTextColor = Color(0xFF6B7280);
  static const hintTextColor = inputBorderGray;
  static const warningColor = Color(0xFFFF3F56);

  static const greyBackgroundColor = softOffWhite;
  static const disabledColor = inputBorderGray;
  static const transparentColor = Colors.transparent;

  static const scaffoldBackground = softOffWhite;
  static const cardBackground = whiteColor;
  static const cardBorder = lightCoolGray;
  static const dividerColor = lightCoolGray;
  static const inputFillColor = whiteColor;
  static const inputBorderColor = inputBorderGray;
  static const successColor = Color(0xFF4FD968);
  static const shadowColor = Color(0x0A0C1754);
  static const actionPanelShadowColor = Color(0x1A0C1754);
}

class AppTheme {
  // DESIGN.md: inputs 0px, cards 16px, buttons 100px
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(0));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(100));

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: CustomColor.brandElectric,
    primary: CustomColor.brandElectric,
    secondary: CustomColor.boardroomNavy,
    surface: CustomColor.whiteColor,
    error: CustomColor.warningColor,
    brightness: Brightness.light,
  ).copyWith(
    onPrimary: CustomColor.whiteColor,
    onSecondary: CustomColor.whiteColor,
    onSurface: CustomColor.pitchBlack,
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
          blurRadius: 12,
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
          blurRadius: 16,
          offset: Offset(0, -2),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData(
      colorScheme: colorScheme,
      primaryColor: CustomColor.brandElectric,
      scaffoldBackgroundColor: CustomColor.scaffoldBackground,
      canvasColor: CustomColor.whiteColor,
      dividerColor: CustomColor.dividerColor,
      shadowColor: CustomColor.shadowColor,
      splashColor: CustomColor.primaryColor100,
      highlightColor: CustomColor.primaryColor50,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CustomColor.brandElectric,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CustomColor.whiteColor,
        foregroundColor: CustomColor.boardroomNavy,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: CustomColor.transparentColor,
        titleTextStyle: headingTextStyle.copyWith(
          fontWeight: semibold,
          fontSize: 18,
          color: CustomColor.boardroomNavy,
          letterSpacing: -0.36,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: CustomColor.whiteColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
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
        focusedBorder: inputBorder(CustomColor.brandElectric),
        errorBorder: inputBorder(colorScheme.error),
        focusedErrorBorder: inputBorder(colorScheme.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.brandElectric,
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
        backgroundColor: CustomColor.brandElectric,
        foregroundColor: CustomColor.whiteColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: pillRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CustomColor.boardroomNavy,
        contentTextStyle: primaryTextStyle.copyWith(
          color: CustomColor.whiteColor,
          fontWeight: medium,
        ),
        actionTextColor: CustomColor.lilacAccent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CustomColor.whiteColor,
        surfaceTintColor: CustomColor.transparentColor,
        shape: RoundedRectangleBorder(borderRadius: largeRadius),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CustomColor.whiteColor,
        selectedItemColor: CustomColor.brandElectric,
        unselectedItemColor: CustomColor.mediumGray,
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
      dialogTheme: DialogThemeData(
        backgroundColor: CustomColor.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: CustomColor.pitchBlack,
        displayColor: CustomColor.boardroomNavy,
      ),
    );
  }
}

// Body / UI text — Inter 400/500/700
TextStyle primaryTextStyle = GoogleFonts.inter(
  color: CustomColor.pitchBlack,
);

// Heading text — Inter with tight letter-spacing (simulates geometric display font)
TextStyle headingTextStyle = GoogleFonts.inter(
  color: CustomColor.boardroomNavy,
  letterSpacing: -0.64,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
