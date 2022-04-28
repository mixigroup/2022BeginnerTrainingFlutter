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

  // テキストフィールドで受け取る回答
  String answerWord = "";
  // 結果（結果を受け取ったら再レンダリングさせて表示させるために State で持っておく）
  List<Answer> answerResult = [];
  int times = 0;

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
    // 2回目以降，次回答するときにどんどん add されてしまうので空にしてあげる
    setState(() {
      answerResult = [];
    });

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
        'word': answerWord,
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
        tiles[answer.position + (times * 4)].state = CharState.CORRECT;
        tiles[answer.position + (times * 4)].char = answer.char;
      } else if (answer.judge == "EXISTING") {
        tiles[answer.position + (times * 4)].state = CharState.EXISTING;
        tiles[answer.position + (times * 4)].char = answer.char;
      } else if (answer.judge == "NOTHING") {
        tiles[answer.position + (times * 4)].state = CharState.NOTHING;
        tiles[answer.position + (times * 4)].char = answer.char;
      }
    }

    // 回数を増やす
    setState(() {
      times++;
    });

    debugPrint(times.toString());
    debugPrint(wordId);
    debugPrint(answerWord);
    debugPrint(result.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                answerWord = value;
              });
            },
          ),
          TextButton(
            onPressed: () {
              // 回答ミューテーションを実行！
              answer();
            },
            child: const Text(
              "回答する",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
            ),
          ),
          SizedBox(
            height: 600,
            child: GridView.count(
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
        ],
      ),
    );
  }
}

Widget _tile(TileState tileState) {
  // 四角の状態によって背景色を変える
  Color boxBackgroundColor = Colors.white;
  if (tileState.state == CharState.CORRECT) {
    boxBackgroundColor = Colors.green;
  } else if (tileState.state == CharState.EXISTING) {
    boxBackgroundColor = Colors.amber;
  } else if (tileState.state == CharState.NOTHING) {
    boxBackgroundColor = Colors.grey;
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
          style: const TextStyle(
            fontSize: 60,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
