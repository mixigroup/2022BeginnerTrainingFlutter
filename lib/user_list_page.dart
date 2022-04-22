import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({Key? key}) : super(key: key);

  // クエリ呼ぶメソッド生やすよ！
  Future<QueryResult<Object?>> callQuery() async {
    // 接続先
    final _httpLink =
        HttpLink("https://serene-garden-89220.herokuapp.com/query");
    // Graphql のクライアントを準備
    final GraphQLClient client =
        GraphQLClient(link: _httpLink, cache: GraphQLCache());

    // これがユーザ一覧を取得するための Query を呼ぶやつ
    // query <<名付けたクエリ名>> { <<呼びたい Query>> } って感じで書く
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
        child: FutureBuilder(
          // callQuery() を呼ぶと result が Future で返ってくる
          future: callQuery(),
          // それを snapshot が受け止める！
          builder: (_, AsyncSnapshot<QueryResult<Object?>> snapshot) {
            // snapshot は受け止めたデータもしくはエラーだったらエラーを持つ
            if (snapshot.hasError) {
              return const Text("受け止められんかった😭");
            }
            // データを持てたら表示してあげる！
            if (snapshot.hasData) {
              return Text(snapshot.data.toString());
            }
            // データもないしエラーもきてない => まだ届いてきてない ってことなのでローディングを表示してあげよう！
            return const Text("Loading...");
          },
        ),
      ),
    );
  }
}
