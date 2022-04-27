import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';

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
    // データがあったら
    if (data != null) {
      // answerWord に data["answerWord"] を代入！
      final answerWord = data["answerWord"];
      // State に返ってきた結果代入！
      setState(() {
        answerResult = answerWord["chars"];
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
            Text(answerResult.toString()),
          ],
        ],
      ),
    );
  }
}
