import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

/// App theme configuration
///
/// Uses Material 3 with Flex Color Scheme for beautiful theming
class AppTheme {
  /// Light theme
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      useMaterial3: true,
      appBarOpacity: 0.95,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3ErrorColors: true,
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepBlue,
      useMaterial3: true,
      appBarOpacity: 0.95,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3ErrorColors: true,
    );
  }

  /// AMOLED black theme
  static ThemeData get amoledTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepBlue,
      useMaterial3: true,
      appBarOpacity: 1.0,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 0,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3ErrorColors: true,
    );
  }

  /// Color tokens
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFCF6679);

  /// Background colors
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundAmoled = Color(0xFF000000);

  /// Typography
  static const String fontFamily = 'Inter';
  static const String monoFontFamily = 'JetBrainsMono';
}

