import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

// 接続先
final _httpLink = HttpLink("https://serene-garden-89220.herokuapp.com/query");
// Graphql のクライアントを準備
final GraphQLClient client =
    GraphQLClient(link: _httpLink, cache: GraphQLCache());

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  // クエリ呼ぶメソッド生やすよ！
  Future<QueryResult<Object?>> callQuery() async {
    // これがユーザ一覧を取得するための Query を呼ぶやつ
    // query <<名付けたクエリ名>> { <<呼びたい Query>> } って感じで書く
    // ''' で生のテキストとして認識される（改行やタブも認識）<= row string っていう
    const String getUserListQuery = r'''
query userListPage {
  userList {
    name
    id
  }
}
''';
    // 例えば『リストページではユーザリストと会社リストの情報が欲しい！』ってときに
    // ▼こんな感じで名付けたクエリの中で複数の Query を呼ぶことができる！
    // （実際カンパニーリストクエリはAPIにないからこのコードは動かないです🙇🏻‍♀️）
    // const String getUserListQuery = r'''
    //   query ListPageDeYobuQuery {
    //     userList {
    //       name
    //       id
    //     }
    //     companyList {
    //       name
    //       id
    //     }
    //   }
    // ''';

    // ここで上で書いたクエリを graphql で読み込めるものに変換！
    final QueryOptions options = QueryOptions(
      document: gql(getUserListQuery),
      // 今回はまだ使わないのでコメントアウト
      // variables: <String, dynamic>{
      //   'nRepositories': nRepositories,
      // },
    );

    // 上で options に変換したクエリを最初に作ったクライアントに乗せて叩く！
    // レスポンスが届くまで時間がかかるので await してちょっと待ってあげる
    // 💡 await を使うためにはメソッドに async をつけてあげる必要ある
    final QueryResult result = await client.query(options);

    // 返ってきた result がエラーだったらログに書く
    if (result.hasException) {
      debugPrint("エラーだった：" + result.exception.toString());
    }

    // 返ってきた result をログに書く！
    // でも多分見にくいのでターミナルで v 押して devtool の network で見てみよう
    debugPrint(result.toString());

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Future で返ってくるものは FutureBuilder で受け止める！
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: FutureBuilder(
                // callQuery() を呼ぶと result が Future で返ってくる
                future: callQuery(),
                // それを snapshot が受け止める！
                builder: (_, AsyncSnapshot<QueryResult<Object?>> snapshot) {
                  // snapshot は受け止めたデータもしくはエラーだったらエラーを持つ
                  if (snapshot.hasError) {
                    return const Text("受け止められんかった😭");
                  }
                  final result = snapshot.data;
                  // データを持ってたら表示してあげる！
                  if (result != null) {
                    var users = [];
                    // 見やすいように，受け取った result の data を users に格納
                    final data = result.data;
                    if (data != null) {
                      users = data["userList"];
                    }

                    return ListView.builder(
                      // users の userList に入ってる数を length で取得
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        // userList の1番目〜2番目〜などを user に渡してそれらの name や id を表示
                        final user = users[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "名前は" + user["name"].toString(),
                            ),
                            Text("IDは" + user["id"].toString()),
                            const Text("----"),
                          ],
                        );
                      },
                    );
                  }
                  // データもないしエラーもきてない => まだ届いてきてない ってことなのでローディングを表示してあげよう！
                  return const Text("Loading...");
                },
              ),
            ),
            // ここにIDを受け取るテキストフィールドと表示するウィジェットを増やす！
            // テキストフィールドは Stateful なので分けよう
            const FindUserAndShow(),
          ],
        ),
      ),
    );
  }
}

class FindUserAndShow extends StatefulWidget {
  const FindUserAndShow({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FindUserAndShowState();
}

class FindUserAndShowState extends State<FindUserAndShow> {
  String userId = '';
  String id = '';
  String name = '';
  String error = '';

  void callQuery() async {
    debugPrint(userId);
    setState(() {
      error = '';
      id = '';
      name = '';
    });

    // 引数の受け取り方
    // 名付けたクエリ名（FindUserAndShow）のところで引数を宣言（今回は String! 型の hikisuu を使うで〜って宣言）
    // ▲ここの型は graphql のスキーマに合わせてあげてください
    // 呼び出すクエリ（user）のところで引数を渡してあげる（今回は userId に hikisuu を渡してあげてる）
    // $ がついてると生のテキストから変数になれる！
    const String getUserQuery = r'''
query FindUserAndShow($hikisuu: String!) {
  user(userId: $hikisuu) {
    name
    id
  }
}
''';

    final QueryOptions options = QueryOptions(
      document: gql(getUserQuery),
      // ここで引数を渡してあげる！
      // 上のクエリ文で定義した　hikisuu 君に State の userId を渡してあげよう！
      variables: <String, dynamic>{
        'hikisuu': userId,
      },
    );
    // クエリ実行
    final QueryResult result = await client.query(options);

    // もしエラーを取得したらログに出す
    final exception = result.exception;
    if (exception != null) {
      debugPrint("エラーだった：" + result.exception.toString());
      // error に受け取ったエラーをぶっ込んであげる
      setState(() {
        // error = result.exception.toString();
        // ▼具体的なエラーだけ表示したい場合は graphqlErrors 配列の一番最初の message に入ってるのでそれを入れてあげてください
        error = exception.graphqlErrors.first.message;
      });
    }

    // もしデータ取得できてたら id と name につっこんであげる
    final data = result.data;
    if (data != null) {
      final user = data["user"];
      setState(() {
        id = user["id"];
        name = user["name"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(hintText: "IDを入力！"),
            onChanged: (value) {
              setState(() {
                userId = value;
              });
            },
          ),
        ),
        IconButton(
          onPressed: callQuery,
          icon: const Icon(Icons.get_app),
        ),
        // もし id と name が空文字じゃなかったら（データをクエリで受け取れていたら）表示！
        if (id != '' && name != '') ...[
          Text(id),
          Text(name),
        ],
        // もしクエリでエラーを受け取っていたらそれを表示
        if (error != '') ...[
          Text(error),
        ],
      ],
    );
  }
}
