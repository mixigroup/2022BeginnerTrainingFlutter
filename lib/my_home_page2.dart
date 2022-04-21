import 'package:flutter/material.dart';

class MyHomePage2 extends StatelessWidget {
  const MyHomePage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("タイトル"),
      ),
      body: Center(
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
            const Count(),
          ],
        ),
      ),
    );
  }
}

class Count extends StatefulWidget {
  const Count({Key? key}) : super(key: key);

  @override
  State<Count> createState() => _CountState();
}

class _CountState extends State<Count> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _discrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            _discrementCounter();
          },
          icon: const Icon(Icons.star_border),
        ),
        FloatingActionButton(
          onPressed: _incrementCounter,
          child: const Icon(Icons.add),
        )
      ],
    );
  }
}
