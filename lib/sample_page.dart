import 'package:flutter/material.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("サンプル"),
        ),
        // Column や Row, GridView は親の幅までその方向に（Column なら縦，Row なら横）いっぱい広がろうとする
        body: Column(
          // MainAxisSize.min をつけることで要素の大きさに留まる
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("hoge"),
            const Text("fuga"),
            const Text("piyo"),
            // Column の中に GridView を入れると GridView は縦に広がろうとするためエラーになる
            // 解決策① GridView の高さを制限してあげる
            // SizedBox(
            //   height: 300,
            //   child: GridView.count(
            //     crossAxisCount: 3,
            //     children: [
            //       for (var i = 0; i < 9; i++)
            //         const Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: ColoredBox(color: Colors.pink),
            //         )
            //     ],
            //   ),
            // ),
            // 解決策② Expanded を使用する
            // Expanded は親のサイズの隙間を埋めるもの
            // Expanded(
            //   child: GridView.count(
            //     // shrinkWrap: true,
            //     crossAxisCount: 3,
            //     children: [
            //       for (var i = 0; i < 9; i++)
            //         const Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: ColoredBox(color: Colors.pink),
            //         )
            //     ],
            //   ),
            // ),
            // 解決策③ shrinkWrap を true にする
            // 要素の大きさに留まる
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                for (var i = 0; i < 9; i++)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ColoredBox(color: Colors.pink),
                  )
              ],
            ),
          ],
        ));
  }
}
