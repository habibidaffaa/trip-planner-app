import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class CustomColor {
  // Ocean scale
  static const ocean950 = Color(0xFF06192F);
  static const ocean900 = Color(0xFF0A2540);
  static const ocean800 = Color(0xFF143155);
  static const ocean700 = Color(0xFF1B3A5F);
  static const ocean600 = Color(0xFF284F77);
  static const ocean500 = Color(0xFF3A5878);
  static const ocean400 = Color(0xFF5B7A9C);
  static const ocean300 = Color(0xFF7A93AC);
  static const ocean200 = Color(0xFFC7D5E0);
  static const ocean100 = Color(0xFFDEE6EF);
  static const ocean50 = Color(0xFFEFF4F8);

  // Coral scale
  static const coral800 = Color(0xFF8E3F2A);
  static const coral700 = Color(0xFFB2533A);
  static const coral600 = Color(0xFFC25E42);
  static const coral500 = Color(0xFFD4684A);
  static const coral400 = Color(0xFFE08366);
  static const coral300 = Color(0xFFE89878);
  static const coral200 = Color(0xFFF2BFA8);

  // Sand scale
  static const sand700 = Color(0xFFA78854);
  static const sand500 = Color(0xFFC9A875);
  static const sand400 = Color(0xFFD8BC92);
  static const sand300 = Color(0xFFE8DAC2);
  static const sand200 = Color(0xFFEFE3CD);
  static const sand100 = Color(0xFFF5EDDD);

  // Paper / Ink / Muted
  static const paper = Color(0xFFFAF6EF);
  static const paper2 = Color(0xFFF2EEE6);
  static const ink = Color(0xFF0A2540);
  static const muted = Color(0xFF6B7A8F);

  // Semantic
  static const success = Color(0xFF047857);
  static const warnAmber = Color(0xFFD97706);
  static const danger = Color(0xFFB2533A);

  // Shadow tokens
  static const shadowSoft = Color(0x140A2540);
  static const shadowCard = Color(0x1F0A2540);

  // Core brand palette — aliased to new tokens
  static const boardroomNavy = ocean900;
  static const brandElectric = coral500;
  static const lilacAccent = sand300;
  static const feedbackYellow = warnAmber;
  static const softOffWhite = paper;
  static const pitchBlack = ocean900;
  static const mediumGray = muted;
  static const lightCoolGray = ocean100;
  static const inputBorderGray = muted;
  static const accentOrange = coral500;

  // Semantic aliases
  static const primary = brandElectric;
  static const surface = softOffWhite;
  static const buttonColor = brandElectric;
  static const dateBackground = lilacAccent;
  static const borderColor = inputBorderGray;
  static const backgroundColor = paper;

  // Primary color scale → ocean/coral scale
  static const primaryColor50 = ocean50;
  static const primaryColor100 = sand300;
  static const primaryColor200 = ocean200;
  static const primaryColor300 = ocean300;
  static const primaryColor400 = ocean400;
  static const primaryColor500 = coral500;
  static const primaryColor600 = ocean600;
  static const primaryColor700 = ocean700;
  static const primaryColor800 = ocean800;
  static const primaryColor900 = ocean900;

  // Neutral
  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = pitchBlack;

  static const subtitleTextColor = muted;
  static const hintTextColor = muted;
  static const warningColor = danger;

  static const greyBackgroundColor = paper;
  static const disabledColor = ocean200;
  static const transparentColor = Colors.transparent;

  static const scaffoldBackground = paper;
  static const cardBackground = paper;
  static const cardBorder = ocean100;
  static const dividerColor = ocean100;
  static const inputFillColor = paper;
  static const inputBorderColor = muted;
  static const successColor = success;
  static const shadowColor = shadowSoft;
  static const actionPanelShadowColor = shadowCard;
}

class AppTheme {
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999));

  static OutlineInputBorder inputBorder([Color color = CustomColor.ocean100]) {
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: CustomColor.coral500,
        primary: CustomColor.coral500,
        secondary: CustomColor.ocean700,
        surface: CustomColor.paper,
        error: CustomColor.danger,
        brightness: Brightness.light,
      ).copyWith(
        onPrimary: CustomColor.whiteColor,
        onSecondary: CustomColor.whiteColor,
        onSurface: CustomColor.ink,
        onError: CustomColor.whiteColor,
      ),
      primaryColor: CustomColor.ocean900,
      scaffoldBackgroundColor: CustomColor.paper,
      canvasColor: CustomColor.paper,
      dividerColor: CustomColor.ocean100,
      shadowColor: CustomColor.shadowSoft,
      splashColor: CustomColor.sand100,
      highlightColor: CustomColor.ocean50,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CustomColor.coral500,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CustomColor.paper,
        foregroundColor: CustomColor.ocean900,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: CustomColor.transparentColor,
        titleTextStyle: displayStyle.copyWith(
          fontWeight: semibold,
          fontSize: 18,
          color: CustomColor.ocean900,
          letterSpacing: -0.36,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: CustomColor.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: bodyStyle.copyWith(
          color: CustomColor.muted,
          fontSize: 14,
          fontWeight: medium,
        ),
        errorStyle: bodyStyle.copyWith(
          color: CustomColor.danger,
          fontSize: 10,
          fontWeight: medium,
        ),
        border: inputBorder(),
        enabledBorder: inputBorder(),
        focusedBorder: inputBorder(CustomColor.ocean900),
        errorBorder: inputBorder(CustomColor.danger),
        focusedErrorBorder: inputBorder(CustomColor.danger),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.ocean900,
          foregroundColor: CustomColor.paper,
          disabledBackgroundColor: CustomColor.ocean200,
          disabledForegroundColor: CustomColor.whiteColor,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: const RoundedRectangleBorder(borderRadius: pillRadius),
          textStyle: bodyStyle.copyWith(
            fontWeight: semibold,
            fontSize: 16,
            color: CustomColor.paper,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: CustomColor.ocean900,
        foregroundColor: CustomColor.paper,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: pillRadius),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CustomColor.ocean900,
        contentTextStyle: bodyStyle.copyWith(
          color: CustomColor.whiteColor,
          fontWeight: medium,
        ),
        actionTextColor: CustomColor.sand300,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CustomColor.paper,
        surfaceTintColor: CustomColor.transparentColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CustomColor.paper,
        selectedItemColor: CustomColor.coral500,
        unselectedItemColor: CustomColor.muted,
        selectedLabelStyle: bodyStyle.copyWith(
          fontSize: 12,
          fontWeight: semibold,
        ),
        unselectedLabelStyle: bodyStyle.copyWith(
          fontSize: 12,
          fontWeight: medium,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: CustomColor.ink,
        displayColor: CustomColor.ocean900,
      ),
    );
  }
}

final TextStyle primaryTextStyle = GoogleFonts.dmSans(color: CustomColor.ink);
final TextStyle headingTextStyle = GoogleFonts.instrumentSerif(
  color: CustomColor.ink,
  letterSpacing: -0.64,
);

final TextStyle bodyStyle = GoogleFonts.dmSans(color: CustomColor.ink);
final TextStyle displayStyle =
    GoogleFonts.instrumentSerif(color: CustomColor.ink);
final TextStyle monoStyle = GoogleFonts.dmMono(color: CustomColor.muted);

const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
const FontWeight semibold = FontWeight.w600;
const FontWeight bold = FontWeight.w700;
