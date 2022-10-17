import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:russian_wordle/strings.dart';

import 'letter.dart';
import 'letter_state.dart';
import 'theme.dart';

class Keyboard extends StatefulWidget {

  final Function(String) onLetterPressed;
  final Function() onEnterPressed;
  final Function() onBackspacePressed;

  const Keyboard({Key? key,
    required this.onLetterPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardState();
}

class KeyboardState extends State<Keyboard> {
  final Map<String, Letter> _letters = {
    for (var e in Strings.kbRow1.split('')) e : Letter(e, state:LetterState.untouched),
    for (var e in Strings.kbRow2.split('')) e : Letter(e, state:LetterState.untouched),
    for (var e in Strings.kbRow3.split('')) e : Letter(e, state:LetterState.untouched),
  };

  void upgradeLetters(List<Letter> letters) {
    setState(() {
      for (var l in letters) {
        if (_letters[l.value] != null) {
          _letters[l.value] = _letters[l.value]!.upgrade(l.state);
        }
      }
    });
  }

  void setLetters(List<Letter> letters) {
    setState(() {
      for (var l in letters) {
        if (_letters[l.value] != null) {
          _letters[l.value] = l;
        }
      }
    });
  }

  void resetLetters() {
    setState(() {
      for (var l in _letters.keys) {
        _letters[l] = Letter(l, state:LetterState.untouched);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(6), child:
    Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < Strings.kbRow1.length; i++)
                KeyboardButton(
                  text: Strings.kbRow1[i],
                  letterState: _letters[Strings.kbRow1[i]]?.state ?? LetterState.untouched,
                  onPressed: () => widget.onLetterPressed(Strings.kbRow1[i]),
                )
            ]
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              for (int i = 0; i < Strings.kbRow2.length; i++)
                KeyboardButton(
                  flex: 2,
                  text: Strings.kbRow2[i],
                  letterState: _letters[Strings.kbRow2[i]]?.state ?? LetterState.untouched,
                  onPressed: () => widget.onLetterPressed(Strings.kbRow2[i]),
                ),
              const Spacer(flex: 1),
            ]
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KeyboardButton( // BACKSPACE
                text: '',
                child: Icon(Icons.keyboard_backspace_rounded, color: AppTheme.colors.textLetterUntouched),
                flex: 2,
                onPressed: widget.onBackspacePressed,
              ),
              for (int i = 0; i < Strings.kbRow3.length; i++)
                KeyboardButton(
                  text: Strings.kbRow3[i],
                  letterState: _letters[Strings.kbRow3[i]]?.state ?? LetterState.untouched,
                  onPressed: () => widget.onLetterPressed(Strings.kbRow3[i]),
                ),
              KeyboardButton( // ENTER
                text: 'ENTER',
                flex: 2,
                onPressed: widget.onEnterPressed,
              ),
            ]
        )
      ],
    ),
    );
  }
}

class KeyboardButton extends StatefulWidget {
  final String text;
  final Widget? child;
  final int flex;
  final LetterState letterState;
  final void Function() onPressed;

  const KeyboardButton({
    Key? key,
    required this.text,
    this.child,
    this.letterState = LetterState.untouched,
    this.flex = 1, this.onPressed = _doNothing,
  }) : super(key: key);

  static void _doNothing(){}

  @override
  State<StatefulWidget> createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<KeyboardButton> with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        );
  }

  animateColor(Color begin, Color end) {
    _colorAnimation?.removeListener(() { setState(() {}); });
    _colorAnimation =
    ColorTween(begin: begin, end: end).animate(_colorController)
      ..addListener(() {
        setState(() {});
      });
    _colorController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant KeyboardButton oldWidget) {
    animateColor(
        AppTheme.colorFromState(oldWidget.letterState),
        AppTheme.colorFromState(widget.letterState));
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var textColor = widget.letterState == LetterState.untouched
        ? AppTheme.colors.textLetterUntouched
        : AppTheme.colors.textLetter;
    return
      Expanded(flex: widget.flex, child:
      Container(
        padding: const EdgeInsets.all(2),
        height: 72,
        child:
        CupertinoButton(
          child: widget.child != null ? widget.child! : Text(
              widget.text.toUpperCase(),
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 18
              )
          ),
          onPressed: widget.onPressed,
          color: _colorController.isAnimating
              ? _colorAnimation?.value
              : AppTheme.colorFromState(widget.letterState),
          minSize: 0,
          borderRadius: BorderRadius.circular(6),
          padding: EdgeInsets.zero,
        ),
      ),
      );
  }
}

