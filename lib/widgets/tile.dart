import 'package:flutter/cupertino.dart';
import 'package:wordle_infinite/theme.dart';

class TileWidget extends StatelessWidget {
  final double offsetX;
  final double offsetY;
  final double scale;
  final String letter;
  final Color bgColor;
  final Color textColor;

  const TileWidget ({
    Key? key,
    required this.letter,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.textColor,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Center(child:
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: letter.isEmpty
                ? AppTheme.colors.guessBorderEmpty
                : AppTheme.colors.guessBorderLetter
            ),
            color: bgColor,
          ),
          child: Center(
            child: Text(letter,
              style: TextStyle(color: textColor, fontSize: 14.0),
            ),
          ),
        ),
      );
  }
}