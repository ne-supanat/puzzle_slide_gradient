import 'package:flutter/material.dart';

class PuzzleTextStyle {
  static const _baseTextStyle = TextStyle(
    fontFamily: 'GoogleSans',
    color: PuzzleColor.text,
    fontWeight: FontWeight.normal,
  );

  /// Headline 1 text style
  static TextStyle get headline1 {
    return _baseTextStyle.copyWith(
      fontSize: 74,
      fontWeight: FontWeight.bold,
    );
  }

  /// Headline 2 text style
  static TextStyle get headline2 {
    return _baseTextStyle.copyWith(
      fontSize: 54,
      fontWeight: FontWeight.bold,
    );
  }

  /// Headline 3 text style
  static TextStyle get headline3 {
    return _baseTextStyle.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  /// Body 1 text style
  static TextStyle get body1 {
    return _baseTextStyle.copyWith(
      fontSize: 46,
    );
  }

  /// Body 2 text style
  static TextStyle get body2 {
    return _baseTextStyle.copyWith(
      fontSize: 24,
    );
  }

  /// Body 3 text style
  static TextStyle get body3 {
    return _baseTextStyle.copyWith(
      fontSize: 18,
    );
  }
}

class PuzzleColor {
  static const Color bg = Color(0xFF2C2F4D);
  static const Color text = Color(0xFF313131);

  static const Color white = Color(0xFFEEEEEE);
}

class PuzzleSize {
  static const double smallScreenWidth = 610;
  static const double mediumScreenWidth = 1200;
  static const double largeScreenWidth = 1440;

  static const double smallBoardWidth = 400;
  static const double mediumBoardWidth = 400;
  static const double largeBoardWidth = 500;

  static const double smallTileWidth = 100;
  static const double mediumTileWidth = 100;
  static const double largeTileWidth = 125;

  static const double smallGapSize = 24;
  static const double mediumGapSize = 24;
  static const double largeGapSize = 48;
  
}
