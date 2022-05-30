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
  // State として word と mean を持っておく
  String word = "";
  String mean = "";
  // 余力があれば loading も持っておこう
  bool loading = false;

  // クエリを呼ぶメソッド
  void callQuery() async {
    // UUID 生成
    const uuid = Uuid();
    // その UUID を wordId とする
    String wordId = uuid.v4();

    // クエリ
    const String getCorrectWord = r'''
query correctWordQuery($wordId: String!) {
  correctWord(wordId: $wordId) {
    word
    mean
  }
}
''';

    final QueryOptions options = QueryOptions(
      document: gql(getCorrectWord),
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
              callQuery();
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
        ],
      ),
    );
  }
}
