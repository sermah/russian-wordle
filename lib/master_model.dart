import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'letter_state.dart';
import 'vibration.dart';

import 'dictionary.dart';
import 'guess_board.dart';
import 'keyboard.dart';
import 'letter.dart';

class GameModel {
  late GlobalKey<GuessBoardState> gbStateKey;
  late GlobalKey<KeyboardState> kbStateKey;

  int boardWidth = 5;
  int boardHeight = 6;
  bool ended = false;
  bool won = false;

  String solution = "";
  late Dictionary dict;

  late Function(bool, bool) onChangeEnded;

  GameModel({
    required this.gbStateKey, required this.kbStateKey,
    required Function() onSolutionLoaded, required this.onChangeEnded
  }) {
    dict = Dictionary((solution) {
      this.solution = solution;
      onSolutionLoaded();
    });
  }

  List<List<Letter>> guessBoard = [];
  String currentGuess = "";

  KeyboardState kbState() => kbStateKey.currentState!;
  GuessBoardState gbState() => gbStateKey.currentState!;

  void updateKeyboardLetters(List<Letter> letters){
    kbState().upgradeLetters(letters);
  }

  void updateGuessBoard() => gbState()
      .update(guessBoard + [[ for (var i = 0; i < currentGuess.length; i++)
    Letter(currentGuess[i], state: LetterState.untouched)
  ]]);

  void restartGame() {
    //kbState().resetLetters();
    currentGuess = "";
    guessBoard = [];
    ended = false;
    won = false;
    solution = dict.pickSolution();
    onChangeEnded(ended, won);
    updateGuessBoard();
  }

  void typeLetter(String letter) {
    if (letter.length == 1 &&
        currentGuess.length < boardWidth && guessBoard.length < boardHeight &&
        !ended
    ) {
      currentGuess += letter;
      updateGuessBoard();
      Vibration.tap();
    }
  }

  void eraseLetter() {
    if (currentGuess.isNotEmpty && !ended) {
      currentGuess = currentGuess.substring(0, currentGuess.length - 1);
      updateGuessBoard();
      Vibration.tap();
    }
  }

  void animateWin() {
    //gbState().animate
  }

  void submitGuess() {
    if (ended) {
      restartGame();
      return;
    }
    if (currentGuess.length != boardWidth || !checkDictionary(currentGuess)) {
      Vibration.fail();
      return;
    }

    var checkedLetters = checkLetters(currentGuess);
    guessBoard.add(checkedLetters);
    kbState().upgradeLetters(checkedLetters);
    currentGuess = "";
    updateGuessBoard();
    if (!ended) Vibration.tap();
  }

  bool checkDictionary(String word) {
    return dict.wordIsInDict(word);
  }

  List<Letter> checkLetters(String word) {
    if (word.length != boardWidth) return [];
    word = word.toLowerCase();

    List<Letter> result = [for (var i = 0; i < word.length; i++)
      Letter(word[i], state: LetterState.untouched)];

    var ansMatched = List<bool>.filled(boardWidth, false);

    var count = 0;
    for (var i = 0; i < boardWidth; i++) {
      if (word[i] == solution[i]) {
        result[i] = result[i].upgrade(LetterState.onSpot);
        ansMatched[i] = true;
        count++;
      }
    }

    if (count == 5) {
      winGame();
      return result;
    }

    for (var ia = 0; ia < boardWidth; ia++) {
      if (ansMatched[ia]) continue;
      for (var ig = 0; ig < boardWidth; ig++) {
        if (result[ig].state != LetterState.untouched || word[ig] != solution[ia]) continue;
        ansMatched[ia] = true;
        result[ig] = result[ig].upgrade(LetterState.present);
        break;
      }
    }

    for (var i = 0; i < boardWidth; i++) {
      // Only untouched will be affected
      result[i] = result[i].upgrade(LetterState.absent);
    }

    if (guessBoard.length + 1 == boardHeight) loseGame();
    return result;
  }

  void winGame() {
    won = true;
    ended = true;
    onChangeEnded(ended, won);
    Vibration.tap();
  }

  void loseGame() {
    won = false;
    ended = true;
    onChangeEnded(ended, won);
    Vibration.fail();
  }
}