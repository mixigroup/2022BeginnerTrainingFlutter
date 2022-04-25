import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  // State 宣言！
  List users = [];
  bool loading = false;

  // クエリ呼ぶメソッド生やすよ！
  void callQuery() async {
    // 接続先
    final _httpLink =
        HttpLink("https://serene-garden-89220.herokuapp.com/query");
    // Graphql のクライアントを準備
    final GraphQLClient client =
        GraphQLClient(link: _httpLink, cache: GraphQLCache());

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

    // 返ってきた result のデータがあったら users にぶちこむ
    final data = result.data;
    if (data != null) {
      setState(() {
        users = data["userList"];
      });
    }

    // data が取れてもエラーでも loading は false に戻す
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ボタンが押されたらクエリを呼ぶ！
            IconButton(
                onPressed: () {
                  // ボタン押したら loading を true に
                  setState(() {
                    loading = true;
                  });
                  callQuery();
                },
                icon: const Icon(Icons.refresh)),
            // loading フラグが true の時は Loading... と表示
            if (loading) ...[
              const Text("Loading…"),
            ],
            // users が null じゃないとき（クエリでデータが返ってきたとき）はそれを表示！
            if (users.isNotEmpty) ...[
              SizedBox(
                height: 350,
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    return Column(
                      children: [
                        Text(users[index]["name"]),
                        Text(users[index]["id"]),
                        const Text("----"),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
