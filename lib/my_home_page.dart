import 'package:flutter/material.dart';

// こちらが　MyHomePage
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
