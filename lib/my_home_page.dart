import 'package:flutter/material.dart';

// こちらが　MyHomePage
// StatefulWidget を継承すると State を扱えるようになる
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  // MyHomePage で使う State を作るよ宣言
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// State を継承して使う
class _MyHomePageState extends State<MyHomePage> {
  // この子が状態を持つデータ（今後 state と呼びます）
  // Tips: _ はプライベート変数を表してるよ
  int _counter = 0;

  void _incrementCounter() {
    // state は setState() 内で更新させなくてはいけない
    setState(() {
      // 右下のボタンが押されたら _counter が0からプラスされた状態になる
      _counter++;
    });
  }

  void _decrementCounter() {
    // setState 無しだと値は書き換わるが再レンダリングされない
    // _counter--;
    setState(() {
      _counter--;
    });
  }

  // state が変わると　build 内が再レンダリングされる
  // print 文を入れてログを見てみよう
  @override
  Widget build(BuildContext context) {
    // setState は state を変更したあとに build を行わせる（dirtyフラグを立てる）メソッドなので build をしている最中には使いません🙅‍♀️
    // ▼ NG 例
    // setState(() {
    //   _counter++;
    // });

    debugPrint("build の中");

    // Scaffold は土台みたいな感じ（白紙みたいな）
    return Scaffold(
      // AppBar は上のヘッダー
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // Center で真ん中に Text を表示している
      body: Center(
        // Column は [] の中身を縦に並べてくれる widget
        // Row で横になるよ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 高さとか幅を指定できる widget
            SizedBox(
              height: 150,
              width: 100,
              // 与えられた範囲に色を付ける widget
              child: ColoredBox(
                color: Colors.amber,
                child: ListView.builder(
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    debugPrint("ListView の中");
                    return Text(index.toString());
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                _decrementCounter();
              },
              icon: const Icon(Icons.star_border),
            ),
            // マス目は GridView で書ける！
            SizedBox(
              height: 300,
              width: 300,
              child: GridView.count(
                crossAxisCount: 3,
                children: [
                  for (var i = 0; i < 9; i++)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ColoredBox(
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
            // 愚直に書いてもOK
            // Column(
            //   children: [
            //     for (var i = 0; i < 3; i++)
            //       Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           for (var i = 0; i < 3; i++)
            //             const Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: SizedBox(
            //                 width: 40,
            //                 height: 40,
            //                 child: ColoredBox(color: Colors.amber),
            //               ),
            //             ),
            //         ],
            //       ),
            //   ],
            // ),
          ],
        ),
      ),
      // 右下のプラスボタン
      floatingActionButton: FloatingActionButton(
        // _incrementCounter メソッドを呼んでる
        // ▼これと一緒
        // onPressed: () {
        //   _incrementCounter();
        // },
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
