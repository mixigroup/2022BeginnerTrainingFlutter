import 'package:beginner_training_flutter/my_home_page.dart'; // 移動させたので import してね！
import 'package:beginner_training_flutter/text_field_page.dart';
import 'package:flutter/material.dart';

// 中枢！main.dart の main() が最初に呼ばれる
void main() {
  // 下の MyApp() を run するよ〜
  runApp(MyApp());
}

// こちらが MyApp
// Widget を使うよってことで Widget を extend したクラスを作る
// StatelessWidget に関しては後で説明
class MyApp extends StatelessWidget {
  // コンストラクタ
  // クラスが作られたときにクラス内で使う変数を初期化するためのもの
  // 今回は変数がないのでデフォルトの Key のみ突っ込まれてる
  // Key, super の説明は今回は省略
  MyApp({Key? key}) : super(key: key);
  // もしクラスに変数があったらこんな感じで書く
  // 上の main() で `MyApp(hoge: "ほげりんちょ")` みたいに渡してあげると hoge には『ほげりんちょ』が代入される
  // const MyApp({Key? key, required this.hoge}) : super(key: key);
  // final String hoge;

  // MaterialApp を作って返して表示させるよ！
  // MaterialApp は Flutter アプリケーションの全体を管理するもので，全体のデザイン（theme: ）や
  // 画面遷移をする場合の状態監視，最初に表示させるページ（home: ）を指定しているよ
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // OS のテーマ設定に合わせて変更できる
      theme: lightTheme,
      darkTheme: darkTheme,
      // 最初に表示させるページをは下の MyHomePage だね
      // 引数として title 渡してる（無くてもいいよ）
      home: const TextFieldPage(),
    );
  }

  // 標準で ThemeData.light() とか用意してくれてる
  // 色変えたかったら下記みたいに変える！
  final lightTheme = ThemeData.from(
    colorScheme: const ColorScheme.light(
      primary: Colors.amber,
      onPrimary: Colors.white,
      secondary: Colors.green,
    ),
  );
  final darkTheme = ThemeData.from(
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.blueAccent,
    ),
  );
}
