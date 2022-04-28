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

  // State として word と mean を持っておく
  String word = "";
  String mean = "";
  // 余力があれば loading も持っておこう
  bool loading = false;

  // 回答にも wordId を使いたいので持っておく
  String wordId = "";
  // テキストフィールドで受け取る回答
  String answerWord = "";
  // 結果（結果を受け取ったら再レンダリングさせて表示させるために State で持っておく）
  List answerResult = [];

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
      final answerWord = data["answerWord"];
      // chars はリストで返ってくるので List として answer に格納
      final answer = answerWord["chars"] as List;
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

    debugPrint(wordId);
    debugPrint(answerWord);
    debugPrint(result.toString());
  }

  // わかりにくいのでメソッド名変更
  void getWord() async {
    // UUID 生成
    const uuid = Uuid();
    // wordId を State として持っておく
    setState(() {
      wordId = uuid.v4();
    });
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
        // 引数に wordId 渡す
        'wordId': wordId,
      },
    );

    // クエリ実行！
    final QueryResult result = await client.query(options);

    if (result.hasException) {
      debugPrint("エラーだった：" + result.exception.toString());
    }

    final data = result.data;
    // もしデータがあったら
    if (data != null) {
      // correctWord に返ってきた data["correctWord"] を代入！
      final correctWord = data["correctWord"];
      // State に返ってきた値代入！
      setState(() {
        word = correctWord["word"];
        mean = correctWord["mean"];
      });
    }

    debugPrint(result.toString());

    // データ取得されたらローディングは終わりなので false を代入
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // もしローディングフラグが立ってたら『ローディング中…』のテキスト表示してあげる
          if (loading) ...[
            const Text(
              "loading...",
              style: TextStyle(color: Colors.blue),
            ),
          ],
          TextButton(
            onPressed: () {
              // ボタン押したらクエリ呼ぶ
              // クエリ呼んでる間はローディング中なのでローディングフラグを true へ
              setState(() {
                loading = true;
              });
              getWord();
            },
            child: const Text(
              "4文字の英単語",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
            ),
          ),
          // 最初は空文字が表示されてる
          // callQuery(); で値が setState されたら再描画されて word と mean が表示される！
          Text(word),
          Text(mean),
          // こっから新規追加 ------------------------
          // テキストフィールドで回答受けとって answerWord に代入
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
          // もし結果が返ってきてたらそれを表示
          if (answerResult.isNotEmpty) ...[
            // for で回してもいいけど4文字だし row で…
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: ColoredBox(
                      // judge の結果によって色を変えてあげる
                      // ? : の記法は３項演算子といいます
                      // (条件) ? （true だった場合） : （false だった場合）って感じで書きます！
                      color: (answerResult[0].judge == "CORRECT")
                          ? Colors.green
                          : (answerResult[0].judge == "EXISTING")
                              ? Colors.amber
                              : Colors.grey,
                      child: Center(
                        child: Text(
                          // answerResult に追加してった一つ目の結果を表示
                          answerResult[0].char,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: ColoredBox(
                      color: (answerResult[1].judge == "CORRECT")
                          ? Colors.green
                          : (answerResult[1].judge == "EXISTING")
                              ? Colors.amber
                              : Colors.grey,
                      child: Center(
                        child: Text(
                          answerResult[1].char,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: ColoredBox(
                      color: (answerResult[2].judge == "CORRECT")
                          ? Colors.green
                          : (answerResult[2].judge == "EXISTING")
                              ? Colors.amber
                              : Colors.grey,
                      child: Center(
                        child: Text(
                          answerResult[2].char,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70,
                    width: 70,
                    child: ColoredBox(
                      color: (answerResult[3].judge == "CORRECT")
                          ? Colors.green
                          : (answerResult[3].judge == "EXISTING")
                              ? Colors.amber
                              : Colors.grey,
                      child: Center(
                        child: Text(
                          answerResult[3].char,
                          style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
