import 'package:beginner_training_flutter/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';

// 回答の結果は char と position と judge が返ってくるのでそれを格納するためのクラスを用意
class Answer {
  const Answer({
    required this.char,
    required this.position,
    required this.judge,
  });
  final String char;
  final int position;
  final String judge;
}

// 四角たち状態を格納するためのクラスを用意
class TileState {
  TileState({
    required this.times, // 何回目か
    required this.position, // 何文字目か
    required this.char, // 文字
    required this.state, // 合ってるのか間違ってるのか存在はしてるのかなどの結果
  });
  int times;
  int position;
  String char;
  CharState state;
}

// 合ってるか間違ってるのか存在はしてるのかなど，返ってくる結果を表したもの
enum CharState {
  CORRECT,
  EXISTING,
  NOTHING,
  NO_ANSWER,
}

// 今何回目で何文字目なのかを表すためのクラスを用意
class Cursor {
  Cursor({
    required this.currentTimes,
    required this.currentPosition,
  });
  int currentTimes;
  int currentPosition;
}

class WordlePage extends StatelessWidget {
  const WordlePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wordle"),
      ),
      body: const CorrectWord(),
    );
  }
}

// 接続先
final _httpLink = HttpLink("https://serene-garden-89220.herokuapp.com/query");
// Graphql のクライアントを準備
final GraphQLClient client =
    GraphQLClient(link: _httpLink, cache: GraphQLCache());

class CorrectWord extends StatefulWidget {
  const CorrectWord({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CorrectWordState();
}

class CorrectWordState extends State<CorrectWord> {
  final String userId = "kunokuno"; // ここはさっき覚えておいて欲しいと言ったユーザID…！
  final wordId = const Uuid().v4();

  // キーボードが押されて受け取る文字を配列に格納していく
  // [m, i, x, i] みたいな感じ
  List<String> answerWord = [];
  // 結果（結果を受け取ったら再レンダリングさせて表示させるために State で持っておく）
  List<Answer> answerResult = [];
  // 最初は試行0回，位置も0文字目
  Cursor cursor = Cursor(currentTimes: 0, currentPosition: 0);

  // 四角たちを初期化
  // 4文字の英単語で5回チャレンジできるので20こ用意
  List<TileState> tiles = List.generate(
    20,
    (i) => TileState(
      times: 0,
      position: 0,
      char: "",
      state: CharState.NO_ANSWER,
    ),
  );

  void answer() async {
    // 配列で受け取った文字を word に合算してく
    String word = "";
    for (var element in answerWord) {
      word += element;
    }

    const String answerWordQuery = r'''
mutation answerWordMutation($wordId: String!, $word: String!, $userId: String!) {
  answerWord(wordId: $wordId, word: $word, userId: $userId) {
    chars {
      position
      char
      judge
  	}
  }
}
''';

    final MutationOptions options = MutationOptions(
      document: gql(answerWordQuery),
      variables: <String, dynamic>{
        'wordId': wordId,
        'word': word,
        'userId': userId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      debugPrint("エラーだった：" + result.exception.toString());
    }

    final data = result.data;
    if (data != null) {
      // chars はリストで返ってくるので List として answer に格納
      final answer = data["answerWord"]["chars"] as List;
      // answer の中身をひとつづつ見ていく
      setState(() {
        for (var a in answer) {
          // 上で作った Answer クラスに合わせて代入していく
          // answerResult 配列に追加してく！
          answerResult.add(
            Answer(
              char: a["char"],
              position: a["position"],
              judge: a["judge"],
            ),
          );
        }
      });
    }

    // 四角たちの状態を代入
    for (var answer in answerResult) {
      if (answer.judge == "CORRECT") {
        tiles[answer.position + (cursor.currentTimes * 4)].state = CharState.CORRECT;
        tiles[answer.position + (cursor.currentTimes * 4)].char = answer.char;
      } else if (answer.judge == "EXISTING") {
        tiles[answer.position + (cursor.currentTimes * 4)].state = CharState.EXISTING;
        tiles[answer.position + (cursor.currentTimes * 4)].char = answer.char;
      } else if (answer.judge == "NOTHING") {
        tiles[answer.position + (cursor.currentTimes * 4)].state = CharState.NOTHING;
        tiles[answer.position + (cursor.currentTimes * 4)].char = answer.char;
      }
    }

    // 回数を増やす
    // 四角の状態も setState
    setState(() {
      cursor.currentPosition = 0;
      (cursor.currentTimes < 5) ? cursor.currentTimes++ : null;
      tiles = tiles;
      // 2回目以降，次回答するときにどんどん add されてしまうので空にしてあげる
      // 四角の状態をセットしたのでもう空にして大丈夫！
      answerWord = [];
      answerResult = [];
    });

    // 5回だったら回答クエリを読んでダイアログを表示！！！
    if (cursor.currentTimes == 5) {
      getWord();
    }

    debugPrint(cursor.currentTimes.toString());
    debugPrint(wordId);
    debugPrint(result.toString());
  }

  // 答えを取得するクエリを呼ぶメソッド追加！
  void getWord() async {
    debugPrint(wordId);

    const String getCorrectWordQuery = r'''
query correctWordQuery($wordId: String!) {
  correctWord(wordId: $wordId) {
    word
    mean
  }
}
''';

    final QueryOptions options = QueryOptions(
      document: gql(getCorrectWordQuery),
      variables: <String, dynamic>{
        'wordId': wordId,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      debugPrint("エラーだった：" + result.exception.toString());
    }

    final data = result.data;
    if (data != null) {
      final correctWord = data["correctWord"];
      // ダイアログは標準で用意されている showDialog メソッドを呼ぶと表示される！
      showDialog(
        context: context,
        builder: (_) {
          // よく見るタイトルと本文とOK/キャンセルなどのボタンを表示するダイアログが標準で AlertDialog として用意されている
          return AlertDialog(
            title: const Text("答え"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("単語：" + correctWord["word"]),
                Text("意味：" + correctWord["mean"]),
              ],
            ),
            actions: [
              TextButton(
                // ダイアログは画面が上に乗っかるのでそれを取り除くために pop をすると閉じる
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    debugPrint(result.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 500,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                for (var tile in tiles)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: _tile(tile),
                  ),
              ],
            ),
          ),
          const Spacer(),
          KeyBoard(
            tiles: tiles,
            count: cursor.currentTimes,
            onTapEnter: () {
              // 4文字に足りてないときはエンター押せないように（誤爆阻止）
              (answerWord.length == 4) ? answer() : null;
            },
            onTapDelete: () {
              setState(() {
                // 回答配列の最後を削除してく
                answerWord.removeAt(answerWord.length - 1);
                // 四角は空文字にする
                tiles[cursor.currentPosition + (cursor.currentTimes * 4) - 1]
                    .char = "";
                // カーソル位置を戻す
                cursor.currentPosition--;
              });
            },
            // 4文字よりたくさん打てないように
            onTapAlphabet: (answerWord.length < 4)
                ? (char) {
                    setState(
                      () {
                        // 回答配列に追加してく
                        answerWord.add(char);
                        // キーボードで押された文字を char で受け取って四角の文字に表示
                        tiles[cursor.currentPosition +
                                (cursor.currentTimes * 4)]
                            .char = char;
                        // カーソル位置を増やす
                        cursor.currentPosition++;
                      },
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

Widget _tile(TileState tileState) {
  // 四角の状態によって背景色を変える
  Color boxBackgroundColor = Colors.white;
  // 四角の状態によって文字色を変える
  // 回答ないときはグレー，あるとき（背景色がある場合）は白色へ
  Color textColor = Colors.blueGrey;
  if (tileState.state == CharState.CORRECT) {
    boxBackgroundColor = Colors.green;
    textColor = Colors.white;
  } else if (tileState.state == CharState.EXISTING) {
    boxBackgroundColor = Colors.amber;
    textColor = Colors.white;
  } else if (tileState.state == CharState.NOTHING) {
    boxBackgroundColor = Colors.grey;
    textColor = Colors.white;
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    // DecoratedBox は四角に枠線つけたりデコれる widget💓
    child: DecoratedBox(
      decoration: BoxDecoration(
        // 枠線の色
        border: Border.all(color: Colors.blueGrey),
        color: boxBackgroundColor,
        // 枠線の角丸
        borderRadius: BorderRadius.circular(10),
      ),
      // 真ん中に文字表示
      child: Center(
        child: Text(
          tileState.char,
          style: TextStyle(
            fontSize: 60,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
