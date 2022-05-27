import 'package:beginner_training_flutter/wordle_page.dart';
import 'package:flutter/material.dart';

// キーボードの文字を表す状態を表すクラスs
class AlphabetState {
  AlphabetState({
    required this.char,
    required this.state,
  });
  String char;
  CharState state;
}

class KeyBoard extends StatefulWidget {
  const KeyBoard({
    Key? key,
    required this.tiles,
    required this.count,
    this.onTapEnter,
    this.onTapDelete,
    this.onTapAlphabet,
  }) : super(key: key);

  final List<TileState> tiles;
  final int count;
  final VoidCallback? onTapEnter;
  final VoidCallback? onTapDelete;
  final Function(String)? onTapAlphabet;

  @override
  State<KeyBoard> createState() => _KeyBoardState();
}

class _KeyBoardState extends State<KeyBoard> {
  // アルファベットたちを定義
  // 最初は回答無しの状態
  List<AlphabetState> alphabets = [
    AlphabetState(char: "Q", state: CharState.NO_ANSWER),
    AlphabetState(char: "W", state: CharState.NO_ANSWER),
    AlphabetState(char: "E", state: CharState.NO_ANSWER),
    AlphabetState(char: "R", state: CharState.NO_ANSWER),
    AlphabetState(char: "T", state: CharState.NO_ANSWER),
    AlphabetState(char: "Y", state: CharState.NO_ANSWER),
    AlphabetState(char: "U", state: CharState.NO_ANSWER),
    AlphabetState(char: "I", state: CharState.NO_ANSWER),
    AlphabetState(char: "O", state: CharState.NO_ANSWER),
    AlphabetState(char: "P", state: CharState.NO_ANSWER),
    AlphabetState(char: "A", state: CharState.NO_ANSWER),
    AlphabetState(char: "S", state: CharState.NO_ANSWER),
    AlphabetState(char: "D", state: CharState.NO_ANSWER),
    AlphabetState(char: "F", state: CharState.NO_ANSWER),
    AlphabetState(char: "G", state: CharState.NO_ANSWER),
    AlphabetState(char: "H", state: CharState.NO_ANSWER),
    AlphabetState(char: "J", state: CharState.NO_ANSWER),
    AlphabetState(char: "K", state: CharState.NO_ANSWER),
    AlphabetState(char: "L", state: CharState.NO_ANSWER),
    AlphabetState(char: "Z", state: CharState.NO_ANSWER),
    AlphabetState(char: "X", state: CharState.NO_ANSWER),
    AlphabetState(char: "C", state: CharState.NO_ANSWER),
    AlphabetState(char: "V", state: CharState.NO_ANSWER),
    AlphabetState(char: "B", state: CharState.NO_ANSWER),
    AlphabetState(char: "N", state: CharState.NO_ANSWER),
    AlphabetState(char: "M", state: CharState.NO_ANSWER),
  ];

  @override
  Widget build(BuildContext context) {
    return keyboard(
      widget.tiles,
      widget.count,
      widget.onTapEnter,
      widget.onTapDelete,
      widget.onTapAlphabet,
    );
  }

  Widget keyboard(
    List<TileState> tiles,
    int count,
    VoidCallback? onTapEnter,
    VoidCallback? onTapDelete,
    Function(String)? onTapAlphabet,
  ) {
    //  MediaQuery.of(context).size は親のサイズを取ってくる
    final width = MediaQuery.of(context).size.width;

    for (var tileState in tiles) {
      // 四角の状態が正解だった場合
      if (tileState.state == CharState.CORRECT) {
        // 四角の正解の文字とアルファベットを比較していく
        for (var alphabet in alphabets) {
          // 一致したら
          if (tileState.char == alphabet.char) {
            setState(() {
              debugPrint("せいかい：${alphabet.char}");
              // アルファベットの状態を正解に！
              alphabet.state = CharState.CORRECT;
            });
          }
        }
      } else if (tileState.state == CharState.EXISTING) {
        for (var alphabet in alphabets) {
          if (tileState.char == alphabet.char) {
            setState(() {
              debugPrint("おしい：${alphabet.char}");
              // CORRECT があった場合，緑にしておきたいので色が上書きされないように return しちゃう
              if (alphabet.state == CharState.CORRECT) {
                return;
              }
              alphabet.state = CharState.EXISTING;
            });
          }
        }
      } else if (tileState.state == CharState.NOTHING) {
        for (var alphabet in alphabets) {
          if (tileState.char == alphabet.char) {
            setState(() {
              debugPrint("まちがい：${alphabet.char}");
              alphabet.state = CharState.NOTHING;
            });
          }
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 10; i++)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _alphabet(
                  alphabets[i].char,
                  width,
                  onTapAlphabet,
                  alphabets[i].state,
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 10; i < 19; i++)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _alphabet(
                  alphabets[i].char,
                  width,
                  onTapAlphabet,
                  alphabets[i].state,
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _button(
              "Enter",
              onTapEnter,
              width,
            ),
            for (var i = 19; i < 26; i++)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: _alphabet(
                  alphabets[i].char,
                  width,
                  onTapAlphabet,
                  alphabets[i].state,
                ),
              ),
            _button(
              "Delete",
              onTapDelete,
              width,
            ),
          ],
        ),
      ],
    );
  }

  // キーボードのアルファベットボタンひとつひとつ
  Widget _alphabet(
    String char,
    double width,
    Function(String)? onTapAlphabet,
    CharState charState,
  ) {
    // 最初の色は薄グレー色
    Color backgroundColor = Colors.grey;
    // アルファベットの状態によって色を変える！
    if (charState == CharState.CORRECT) {
      backgroundColor = Colors.green;
    } else if (charState == CharState.EXISTING) {
      backgroundColor = Colors.amber;
    } else if (charState == CharState.NOTHING) {
      backgroundColor = Colors.blueGrey;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: width / 13,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
          ),
          child: Text(
            char,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: (onTapAlphabet != null) ? () => onTapAlphabet(char) : null,
        ),
      ),
    );
  }

  // キーボードのEnterとDeleteのボタン
  Widget _button(
    String text,
    VoidCallback? onTap,
    double width,
  ) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: width / 7,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
