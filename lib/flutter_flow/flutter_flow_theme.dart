// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color primaryTextInverse;
  late Color disableText;
  late Color primaryBackgroundInverse;
  late Color disableBackground;

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFFFBA808);
  late Color secondary = const Color(0xFFFFF6E6);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFF1F1FB);
  late Color primaryText = const Color(0xFF000014);
  late Color secondaryText = const Color(0xFFB9B9C8);
  late Color primaryBackground = const Color(0xFFF8F9FC);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0x4CFBA808);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0x4DEE8B60);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF328048);
  late Color warning = const Color(0xFFF6B326);
  late Color error = const Color(0xFFD02B20);
  late Color info = const Color(0xFF0F96F4);

  late Color primaryTextInverse = const Color(0xFFFFFFFF);
  late Color disableText = const Color(0xFFCDCDDC);
  late Color primaryBackgroundInverse = const Color(0xFF000014);
  late Color disableBackground = const Color(0xFFF1F1FB);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Manrope';
  TextStyle get displayLarge => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 61.0,
        fontStyle: FontStyle.normal,
      );
  String get displayMediumFamily => 'Manrope';
  TextStyle get displayMedium => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 49.0,
        fontStyle: FontStyle.normal,
      );
  String get displaySmallFamily => 'Manrope';
  TextStyle get displaySmall => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 39.0,
        fontStyle: FontStyle.normal,
      );
  String get headlineLargeFamily => 'Manrope';
  TextStyle get headlineLarge => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 32.0,
        fontStyle: FontStyle.normal,
      );
  String get headlineMediumFamily => 'Manrope';
  TextStyle get headlineMedium => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 25.0,
        fontStyle: FontStyle.normal,
      );
  String get headlineSmallFamily => 'Manrope';
  TextStyle get headlineSmall => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 25.0,
        fontStyle: FontStyle.normal,
      );
  String get titleLargeFamily => 'Manrope';
  TextStyle get titleLarge => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        fontStyle: FontStyle.normal,
      );
  String get titleMediumFamily => 'Manrope';
  TextStyle get titleMedium => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        fontStyle: FontStyle.normal,
      );
  String get titleSmallFamily => 'Manrope';
  TextStyle get titleSmall => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        fontStyle: FontStyle.normal,
      );
  String get labelLargeFamily => 'Manrope';
  TextStyle get labelLarge => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16.0,
        fontStyle: FontStyle.normal,
      );
  String get labelMediumFamily => 'Manrope';
  TextStyle get labelMedium => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        fontStyle: FontStyle.normal,
      );
  String get labelSmallFamily => 'Manrope';
  TextStyle get labelSmall => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
        fontStyle: FontStyle.normal,
      );
  String get bodyLargeFamily => 'Manrope';
  TextStyle get bodyLarge => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        fontStyle: FontStyle.normal,
      );
  String get bodyMediumFamily => 'Manrope';
  TextStyle get bodyMedium => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
        fontStyle: FontStyle.normal,
      );
  String get bodySmallFamily => 'Manrope';
  TextStyle get bodySmall => GoogleFonts.getFont(
        'Manrope',
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
        fontStyle: FontStyle.normal,
      );
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily!,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration,
              height: lineHeight,
              shadows: shadows,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
              shadows: shadows,
            );
}
