import 'package:flutter/material.dart';

class TextFieldPage extends StatelessWidget {
  const TextFieldPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("テキストフィールドを使ってみよう！"),
      ),
      body: const MyTextFiled(),
    );
  }
}

class MyTextFiled extends StatefulWidget {
  const MyTextFiled({Key? key}) : super(key: key);

  @override
  State<MyTextFiled> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextFiled> {
  String showText = "";

  @override
  Widget build(BuildContext context) {
    String tmpText = "";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: ((value) {
              tmpText = value;
            }),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              showText = tmpText;
            });
          },
          icon: const Icon(Icons.arrow_downward),
        ),
        Text(showText),
      ],
    );
  }
}
