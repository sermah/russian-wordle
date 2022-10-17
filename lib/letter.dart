import 'letter_state.dart';

class Letter {
  final LetterState state;
  final String value;

  const Letter(this.value, {this.state = LetterState.untouched});

  Letter upgrade(LetterState newState) {
    var resultState = newState;
    switch (state) {
      case LetterState.present:
        if (resultState != LetterState.onSpot) {
          resultState = state;
        }
        break;
      case LetterState.onSpot:
        resultState = state;
        break;
      // Commented bc if it goes like absent,onSpot in one line,
      // then absent gets fixed and onSpot can't update it

      // case LetterState.absent:
      //   resultState = state;
      //   break;
      default: break;
    }
    return Letter(value, state: resultState);
  }
}