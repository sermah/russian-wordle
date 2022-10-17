import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:russian_wordle/dictionary.dart';
import 'package:russian_wordle/strings.dart';
import 'package:russian_wordle/theme.dart';
import 'guess_board.dart';
import 'master_model.dart';

import 'keyboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Словечки',
      theme: CupertinoThemeData(
        brightness: AppTheme.brightness,
        scaffoldBackgroundColor: AppTheme.colors.background,
        barBackgroundColor: AppTheme.colors.barBackground,
      ),
      debugShowCheckedModeBanner: false,
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GlobalKey<GuessBoardState> gbStateKey = GlobalKey();
  final GlobalKey<KeyboardState> kbStateKey = GlobalKey();
  late final GameModel master;
  bool loaded = false;
  bool gameEnded = false;
  bool gameWon = false;

  _GamePageState() {
    master = GameModel(
        gbStateKey: gbStateKey,
        kbStateKey: kbStateKey,
        onSolutionLoaded: () {
          notifyLoaded();
        },
        onChangeEnded: changeEnded);
  }

  notifyLoaded() {
    setState(() {
      loaded = true;
    });
  }

  changeEnded(bool ended, bool won) {
    setState(() {
      gameEnded = ended;
      gameWon = won;
    });
  }

  gbLastAnimationEnded(GBAnimationType type) {
    if (type == GBAnimationType.flip && gameWon) {
      master.animateWin();
    }
  }

  onKeyHandler(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (event.physicalKey == PhysicalKeyboardKey.enter) {
      master.submitGuess();
    } else if (event.physicalKey == PhysicalKeyboardKey.backspace) {
      master.eraseLetter();
    } else if (alphabet.contains(event.data.keyLabel[0].toLowerCase())) {
      master.typeLetter(event.character![0].toLowerCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(Strings.barTitle),
          trailing: CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: const Text(Strings.btnSettings),
              onPressed: () {
                print("Settings");
              }),
        ),
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: onKeyHandler,
          child: Center(
            child: !loaded
                ? CupertinoActivityIndicator(
                    color: AppTheme.colors.textOnBackground)
                : Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        GuessBoard(
                            key: gbStateKey,
                            lastAnimationCompleted: gbLastAnimationEnded),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 240),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.keyboardBackground,
                              border: Border.all(
                                  color: AppTheme.colors.guessBorderEmpty),
                            ),
                            child: Row(children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: !gameEnded
                                      ? Keyboard(
                                          key: kbStateKey,
                                          onLetterPressed: (l) =>
                                              master.typeLetter(l),
                                          onBackspacePressed: () =>
                                              master.eraseLetter(),
                                          onEnterPressed: () =>
                                              master.submitGuess(),
                                        )
                                      : Center(
                                          child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                gameWon
                                                    ? Strings.msgYouWon
                                                    : Strings.msgYouLost,
                                                style: TextStyle(
                                                  color: AppTheme.colors
                                                      .textLetterUntouched,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                            ),
                                            const SizedBox(height: 24),
                                            CupertinoButton(
                                                color: AppTheme
                                                    .colors.letterOnSpot,
                                                child: Text(
                                                  Strings.btnPlayAgain,
                                                  style: TextStyle(
                                                    color: AppTheme.colors
                                                        .textLetter,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    master.submitGuess()),
                                            const SizedBox(height: 16),
                                            gameWon
                                            ? CupertinoButton(
                                                color: AppTheme
                                                    .colors.letterUntouched,
                                                child: Text(
                                                  Strings.btnShare,
                                                  style: TextStyle(
                                                    color: AppTheme.colors
                                                        .textLetterUntouched,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    master.submitGuess())
                                            : Text(
                                              Strings.msgSolutionWas + master.solution,
                                              style: TextStyle(
                                                color: AppTheme.colors
                                                    .textLetterUntouched,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        )),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }
}
