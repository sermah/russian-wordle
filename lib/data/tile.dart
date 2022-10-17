import 'package:flutter/cupertino.dart';
import 'package:russian_wordle/letter_state.dart';
import 'package:russian_wordle/theme.dart';

const _jumpOffset = 8.0;
const _shakeOffset = 8.0;
const _bounceScale = 1.3;

class Tile {
  final int x;
  final int y;
  String letter;
  late LetterState letterState;

  late Animation<double> offsetX;
  late Animation<double> offsetY;
  late Animation<double> scale;
  late Animation<double> rotation;
  late Animation<Color> bgColor;
  late Animation<Color> textColor;

  Tile(this.x, this.y, this.letter) {
    letterState = LetterState.untouched;
    resetAnimations();
  }

  void resetAnimations() {
    offsetX = const AlwaysStoppedAnimation(0.0);
    offsetY = const AlwaysStoppedAnimation(0.0);
    scale = const AlwaysStoppedAnimation(1.0);
    bgColor = AlwaysStoppedAnimation(gbTileColor[letterState]!);
    textColor = AlwaysStoppedAnimation(gbTextColor[letterState]!);
  }

  void jump(Animation<double> parent, double intervalStart, double intervalEnd){
    offsetY = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: _jumpOffset), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: _jumpOffset, end: 0.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent,
        curve: Interval(intervalStart, intervalEnd,
            curve: Curves.easeInOutCubic)));
  }

  // Should be provided with a dedicated animation controller to avoid conflicts with neighbors
  void bounce(Animation<double> parent){
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: _bounceScale), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: _bounceScale, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Curves.easeInOutCubic));
  }

  void shake(Animation<double> parent){
    offsetX = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: _shakeOffset), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: _shakeOffset, end: 0.0), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -_shakeOffset), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: -_shakeOffset, end: 0.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Curves.linear));
  }

  void revealColor(Animation<double> parent, LetterState state) {
    bgColor = Tween(begin: bgColor.value, end: gbTileColor[state]!)
        .animate(CurvedAnimation(parent: parent, curve: Curves.linear));
    textColor = Tween(begin: textColor.value, end: gbTextColor[state]!)
        .animate(CurvedAnimation(parent: parent, curve: Curves.linear));
  }
}