import 'package:flutter/material.dart';

class TextFieldPage extends StatelessWidget {
  const TextFieldPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("テキストフィールドを使ってみよう！"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(),
      ),
    );
  }
}
