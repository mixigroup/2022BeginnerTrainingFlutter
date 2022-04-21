import 'package:beginner_training_flutter/my_home_page.dart'; // 移動させたので import してね！
import 'package:flutter/material.dart';

// 中枢！main.dart の main() が最初に呼ばれる
void main() {
  // 下の MyApp() を run するよ〜
  runApp(const MyApp());
}

// こちらが MyApp
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // MaterialApp を作って返して表示させるよ！
  // MaterialApp は Flutter アプリケーションの全体を管理するもので，全体のデザイン（theme: ）や
  // 画面遷移をする場合の状態監視，最初に表示させるページ（home: ）を指定しているよ
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // メインカラーは青色指定がされてる
        // ここを変えると AppBar とかの色が変わる
        // Colors は用意してくれてる！
        // Hotreload をすると色が変わるよ
        primarySwatch: Colors.pink,
      ),
      // 最初に表示させるページをは下の MyHomePage だね
      // 引数として title 渡してる（無くてもいいよ）
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
