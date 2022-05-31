import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("context サンプル"),
        ),
        body: Column(
          children: [
            Theme(
              data: ThemeData(primaryColor: Colors.orange),
              child: const Sample(title: 'Widget A'),
            ),
            Column(
              children: [
                const Sample(title: 'Widget B'),
                Theme(
                  data: ThemeData(
                    primaryColor: Colors.pink,
                  ),
                  child: const Sample(title: 'Widget C'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Sample extends StatelessWidget {
  const Sample({Key? key, required this.title}) : super(key: key);
  final String title;

  // context を辿っていった先にある Theme の色をした四角を表示
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: ColoredBox(
        color: Theme.of(context).primaryColor,
        child: Text(title),
      ),
    );
  }
}
