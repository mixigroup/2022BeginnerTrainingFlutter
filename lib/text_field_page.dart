import 'package:flutter/material.dart';

class TextFieldPage extends StatelessWidget {
  const TextFieldPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String showText = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("テキストフィールドを使ってみよう！"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: ((value) {
                showText = value;
              }),
            ),
          ),
          Text(showText),
        ],
      ),
    );
  }
}
