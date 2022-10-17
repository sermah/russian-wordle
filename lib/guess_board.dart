import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'intvec2.dart';
import 'letter_state.dart';
import 'theme.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'letter.dart';

enum GBAnimationType {
  flip, scale, jump
}

class GuessBoard extends StatefulWidget {
  final Function(GBAnimationType) lastAnimationCompleted;

  const GuessBoard({Key? key, required this.lastAnimationCompleted}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GuessBoardState();
}

class GuessBoardState extends State<GuessBoard> {
  List<List<Letter>> guessBoard = [[]];
  List<List<GlobalKey<_GuessLetterState>>> boardKeys = [[]];
  List<Letter> letters(int i) => guessBoard.length <= i ? [] : guessBoard[i];

  update(List<List<Letter>> guessBoard) {
    setState(() {
      this.guessBoard = guessBoard;
    });
  }

  animateWin() {
    // var row = guessBoard.length - 1;
    // for (int icell = 0; icell < 5; icell++) {
    //   boardKeys[row][icell].currentState?.animateJump();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(child:
    Padding(padding: const EdgeInsets.all(16), child:
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int irow = 0; irow < 6; irow++)
          Flexible(child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int icell = 0; icell < 5; icell++)
                Flexible(child:
                GuessLetter(
                  //key: boardKeys[irow][icell] ?? (boardKeys[irow][icell] = GlobalObjectKey(IntVec2(irow, icell))),
                  text: letters(irow).length > icell ? letters(irow)[icell].value : "",
                  letterState: letters(irow).length > icell ? letters(irow)[icell].state : LetterState.untouched,
                  order: icell,
                  onAnimationCompleted: icell != 4
                      ? (_){}
                      : widget.lastAnimationCompleted,
                ),
                ),
            ],
          ),
          ),
      ],
    ),
    ),
    );
  }
}

class GuessLetter extends StatefulWidget {
  final String text;
  final LetterState letterState;
  final int order;
  final Function(GBAnimationType) onAnimationCompleted;

  const GuessLetter({
    Key? key,
    required this.text,
    this.letterState = LetterState.untouched,
    required this.order,
    required this.onAnimationCompleted
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GuessLetterState();
}

class _GuessLetterState extends State<GuessLetter> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _flipController;
  late AnimationController _jumpController;
  late GuessLetter _oldWidget = widget;

  void animateJump() {
    _jumpController.forward(from: _jumpController.lowerBound);
  }

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.15,
    )..addListener(() {
      setState(() {});
      if (_scaleController.isCompleted) widget.onAnimationCompleted(GBAnimationType.scale);
    });

    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + 250 * widget.order),
      lowerBound: -0.5 * widget.order,
      upperBound: 1.0,
    )..addListener(() {
      setState(() {});
      if (_flipController.isCompleted) widget.onAnimationCompleted(GBAnimationType.flip);
    });

    _jumpController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + 250 * widget.order),
      lowerBound: -0.5 * widget.order,
      upperBound: 1.0,
    )..addListener(() {
      setState(() {});
      if (_jumpController.isCompleted) widget.onAnimationCompleted(GBAnimationType.jump);
    });
  }

  @override
  void didUpdateWidget(covariant GuessLetter oldWidget) {
    if (oldWidget.text != widget.text) {
      _scaleController.reverse(from: _scaleController.upperBound);
    } else if (oldWidget.letterState != widget.letterState) {
      _flipController.forward(from: _flipController.lowerBound);
      _oldWidget = oldWidget;
    }
    // if (_flipController.isCompleted && _animateJump) {
    //   _jumpController.forward(from: _jumpController.lowerBound);
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return (_flipController.isAnimating && _flipController.value < 0.5 && _oldWidget != widget) ? _oldWidget :
    Transform(
      transform: Matrix4.identity()
        ..rotateX((0.5 - (max(_flipController.value, 0) - 0.5).abs()) * pi)
        ..scale(Vector3.all(_scaleController.value))
        ..translate(Vector3(0, 0.5 - pow(max(_flipController.value, 0) - 0.5, 2).toDouble(), 0)),
      alignment: FractionalOffset.center, child:
    AspectRatio(aspectRatio: 1, child:
    Padding(padding: const EdgeInsets.all(2), child:
    Container(
      decoration:
      BoxDecoration(
          border: Border.all(width: 1.5,
            color: widget.letterState == LetterState.untouched
                ? ( widget.text == ""
                    ? AppTheme.colors.guessBorderEmpty
                    : AppTheme.colors.guessBorderLetter
            ) : AppTheme.colorFromState(widget.letterState),
          ),
          borderRadius: BorderRadius.circular(6),
          color: widget.text != ""
              ? AppTheme.colorFromState(widget.letterState)
              : Colors.transparent
      ),
      alignment: Alignment.center,
      child: Text(
        widget.text.toUpperCase(),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: widget.letterState != LetterState.untouched
              ? AppTheme.colors.textLetter
              : AppTheme.colors.textLetterUntouched,
        ),
      ),
    ),
    ),
    ),
    );
  }
}