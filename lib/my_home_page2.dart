import 'package:flutter/material.dart';

class MyHomePage2 extends StatelessWidget {
  const MyHomePage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("タイトル"),
      ),
      body: const Center(
        child: Count(),
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
  int _counter2 = 1;

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

  void _twice() {
    setState(() {
      _counter2 = _counter2 * 2;
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
              '足し算されてく:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                _discrementCounter();
              },
              child: const Text(
                "マイナス",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                _incrementCounter();
              },
              child: const Text(
                "プラス",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '2倍されてく:',
            ),
            Text(
              '$_counter2',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            _twice();
          },
          child: const Text(
            "2倍",
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.pink),
          ),
        ),
      ],
    );
  }
}
