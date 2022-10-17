import 'package:flutter/cupertino.dart';

import 'letter_state.dart';

class AppTheme {
  // Singleton pattern
  AppTheme._privateConstructor(); // that's a constructor actually
  static final AppTheme _appTheme = AppTheme._privateConstructor();
  factory AppTheme() {
    return _appTheme;
  }

  static AppColors colors = AppColors();
  static Brightness brightness = Brightness.light;

  static Color colorFromState(LetterState letterState) {
    switch (letterState) {
      case LetterState.absent   : return colors.letterAbsent;
      case LetterState.present  : return colors.letterPresent;
      case LetterState.onSpot   : return colors.letterOnSpot;
      default                   : return colors.letterUntouched;
    }
  }
}

class AppColors {
  Color background          = const Color(0xffffffff);
  Color barBackground       = const Color(0xffffffff);
  Color guessBorderEmpty    = const Color(0xFFc0c0c0);
  Color guessBorderLetter   = const Color(0xFF5C5C5C);
  Color keyboardBackground  = const Color(0xfff0f0f0);
  Color letterUntouched     = const Color(0xffffffff);
  Color letterAbsent        = const Color(0xff311847);
  Color letterPresent       = const Color(0xffec9f05);
  Color letterOnSpot        = const Color(0xff8ea604);
  Color textOnBackground    = const Color(0xFF404040);
  Color textLetter          = const Color(0xffffffff);
  Color textLetterUntouched = const Color(0xFF1A1A1A);
}

Map<LetterState, Color> gbTextColor = {
  LetterState.untouched:  AppTheme.colors.textLetterUntouched,
  LetterState.absent:     AppTheme.colors.textLetter,
  LetterState.present:    AppTheme.colors.textLetter,
  LetterState.onSpot:     AppTheme.colors.textLetter,
};

Map<LetterState, Color> gbTileColor = {
  LetterState.untouched:  AppTheme.colors.letterUntouched,
  LetterState.absent:     AppTheme.colors.letterAbsent,
  LetterState.present:    AppTheme.colors.letterPresent,
  LetterState.onSpot:     AppTheme.colors.letterOnSpot,
};

Map<LetterState, Color> kbTextColor = {
  LetterState.untouched:  AppTheme.colors.textLetterUntouched,
  LetterState.absent:     AppTheme.colors.textLetter,
  LetterState.present:    AppTheme.colors.textLetter,
  LetterState.onSpot:     AppTheme.colors.textLetter,
};

Map<LetterState, Color> kbKeyColor = {
  LetterState.untouched:  AppTheme.colors.letterUntouched,
  LetterState.absent:     AppTheme.colors.letterAbsent,
  LetterState.present:    AppTheme.colors.letterPresent,
  LetterState.onSpot:     AppTheme.colors.letterOnSpot,
};