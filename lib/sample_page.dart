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
          children: const [
            Text("hoge"),
            Text("fuga"),
            Text("piyo"),
          ],
        ));
  }
}
