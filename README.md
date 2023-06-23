# flutter_mvc_counter

このリポジトリは近日公開予定の記事のサンプルアプリです。。

以下に、記事と同様の内容を記載します。

---

この章では、様々なアーキテクチャの最も基礎ともいえる MVC で作る方法を説明します。

## MVC とは

MVC アーキテクチャの詳しい説明は、たとえば次のような文書：

<https://www.artima.com/articles/the-dci-architecture-a-new-vision-of-object-oriented-programming>

に任せることにして本書では省略しますが、MVC アーキテクチャは、プログラムを M (Model), V (View), C (Controller) の役割に分担して記述するアーキテクチャです。

それぞれの役割を簡単に説明すると、以下の通りです。

- Model: アプリケーションの振る舞いを表現するもの。View と Controller 以外のすべてのモジュールが該当する
- View: ディスプレイに表示される見た目
- Controller: ユーザーによる操作を解釈して Model を操作したり、モデルを UI に反映させたりするもの

大まかに格闘ゲームに例えるならば、

- Model: 格闘ゲームの振る舞いを表現するもの（キャラクターの能力、キャラクターの各種操作内容、ダメージや吹っ飛び率の計算、残機数の計算...などすべて）
- View: ゲームの画面に表示されるキャラクターやステージなどの見た目
- Controller: ユーザーが手に持って操作するコントローラ

といえるでしょう。

View と Controller をあわせて UI（ユーザーインターフェース）といいます。その名の通り、ユーザーとアプリケーションの境界、両者をつなぐものです。

設計を考える際の最も大切な原則のひとつに、プレゼンテーションロジックとドメインロジックを分離する考え方 (PDS: Presentation Domain Separation) があります。これについても詳細は世の中の他の文書に任せますが、かんたんに言うと、ユーザーインターフェイスに関する実装と、アプリケーションの振る舞いを表現する実装とを分離することです。

たとえば以下の文書：

<https://bliki-ja.github.io/PresentationDomainSeparation/>

が説明するように、プレゼンテーションロジックとドメインロジックが分かれていると、

- 同じプログラムを、重複コードなしに、複数の見た目に対応させすい
- 一般にテストがやや難しいプレゼンテーションロジックを、ドメインロジックと分離することで、ドメインロジックをテスト可能に書きやすい

などのメリットがあります。

MVC アーキテクチャと対応させるならば、MVC アーキテクチャは UI (View + Controller) と アプリケーションの振る舞い・ロジック (Model) を分離して記述していく方針といえます。

また、MVVM や本書で説明される他のいろいろなアーキテクチャパターンも、最も抽象的と言える MVC アーキテクチャを、それぞれの観点で切り口を変えたりレイヤー分けをしたりしたものと解釈することができます。

## MVC を Flutter に適用する

この章で説明する MVC アーキテクチャによるカウンターアプリを以下のように解釈して Flutter フレームワークに適用し、その実装方針とします。

なお、以下の解釈や実装方針は一定の一貫性や納得感を伴うものではありますが、唯一の最善の正解というわけではないことには注意してください。また、以下では説明のしやすさの観点から、M, V, C の順番を入れ替えています。

### View

Flutter における View（ディスプレイに表示される見た目）は、ウィジェットが提供します。スマートフォン・タブレット、PC などの端末の画面上、または Web アプリならばそれらのブラウザ上に表示される見た目が View です。

### Controller

Flutter で開発したアプリケーションは、スマートフォンやタブレットの画面を手で（またはマウス等のデバイスを通じて）操作します。

Flutter アプリにおいて、格闘ゲームのコントローラに相当する、ユーザーが触って操作する対象は、たとえば `ElevatedButton` などのボタンや `SelectableText` などのウィジェット (`StatefulWidget`) が代表的です。

`ElevatedButton` の `onPressed` のように「押したら（操作したら）どうなるか」という機能が記述されます。

その `onPressed` の処理の中に、Controller の役割である「ユーザーによる操作を解釈して Model を操作」するプログラムを記述したり、同様の内容を `FooController` のようなコントローラクラスを定義して、そのメソッドとして記述し、たとえば [provider](https://pub.dev/packages/provider) パッケージの `Provider` を組み合わせて提供したりすると良いでしょう。

コントローラは「ユーザーによる操作を解釈して Model を操作」するので、カウンターアプリならば、`CounterController` が `Counter` モデルのインスタンスを保持して、ユーザーからの操作を受けつつ、その操作に応じた指示を `Counter` モデルに対して行います。

### Model

Model は View と Controller (UI) 以外のアプリケーションの振る舞いです。上述の通り、View と Controller は Flutter フレームワークに大きく依存しますが、Model は Flutter フレームワークや環境にできるだけ依存しないように記述して、ユニットテストを可能にする方針が望ましいです。

Flutter フレームワークや外部の環境に依存せず、ピュアな Dart で記述できることが理想でしょう。そうすることでユニットテストもピュアな Dart で記述することができます。他のクラスのインスタンスに依存する場合には、コンストラクタインジェクションで依存性を注入するのが通例です。

と言いつつ、本章で取り上げるカウンターアプリでは、モデルは Flutter の `ChangeNotifier` には依存することを認めることとします。しばしば「UI = f(state)」で説明される Model → View の関係と View の更新をかんたんに実装できる上、モデルのユニットテスト可能性には影響を及ぼさないからです（影響を及ぼさないように実装します）。

## 今回取り上げるカウンターアプリの要件

ただ数字をカウントアップするよりは少し複雑な下記のようなカウンターアプリを取り上げます。

- 「カウント」に数字が表示されている
- 「カウントアップ」ボタンを押すと、「カウント」の数字に 1 が加算される
- 「リストに追加」ボタンを押すと、現在のカウントの数字がリストに追加される
- 「合計値」には、現在のリストの合計値が表示されている
- リストに追加時に合計値が 5 の倍数になった場合には、「合計値が 5 の倍数です！」という `SnackBar` が表示される
- 「クリア」ボタンを押すと、「カウント」が 0 に、「リスト」が空にリセットされる

![カウンターアプリ](https://github-production-user-asset-6210df.s3.amazonaws.com/13669049/248271618-19607def-ddad-4160-823a-c27e30b677d3.gif?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230623%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230623T131117Z&X-Amz-Expires=300&X-Amz-Signature=8828d061918d63785827835546df7461f2016124d613db20631653d73c480551&X-Amz-SignedHeaders=host&actor_id=13669049&key_id=0&repo_id=476170184)

また、[provider](https://pub.dev/packages/provider) パッケージと、`ChangeNotifier`, `ChangeNotifierProvider` を使用し、Model に対するユニットテストを記述します。Flutter のウィジェットテストによる UI (View + Controller) に対するテストは省略します。

## カウンターアプリの実装

### Model の実装

まずは、カウンターアプリの振る舞いを記述する `Counter` モデルを実装します。最終的には `ChangeNotifier` を継承し、Flutter フレームワークに依存しますが、途中までピュアな Dart のクラスとして書いてみましょう。

`Counter` モデルが保持するのは、現在のカウント値と、カウント値のリストです。

```dart
/// カウンターの振る舞いを表現するモデル。
class Counter {
  /// カウント値。
  int _count = 0;

  /// カウント値のリスト。
  final List<int> _counts = [];
}
```

カウント値に 1 を加算する処理（振る舞い）を、次の `increment` メソッドとして定義します。

```dart
/// カウント値に 1 を加算する。
void increment() {
  _count++;
}
```

同様に、

- カウント値をリストに追加する処理
- カウント値とカウント値のリストをクリアする処理
- カウント値のリストの合計を計算する処理を
- カウント値の合計が 5 の倍数であるかを判定する処理

をそれぞれのメソッドとして定義すれば `Counter` モデルがほぼ完成です。ここまではピュアな Dart で何にも依存せずにカウンターの振る舞いを記述できています。

```dart
/// カウンターの振る舞いを表現するモデル。
class Counter {
  /// カウント値。
  int _count = 0;

  /// カウント値のリスト。
  final List<int> _counts = [];

  /// カウント値に 1 を加算する。
  void increment() {
    _count++;
  }

  /// カウント値をリストに追加する。
  void append() {
    _counts.add(_count);
  }

  /// カウント値とカウント値のリストをクリアする。
  void clear() {
    _count = 0;
    _counts.clear();
  }

  /// カウント値のリストの合計を計算する。
  int calculateTotal() {
    return _counts.fold(0, (a, b) => a + b);
  }

  /// カウント値の合計が 5 の倍数であるかを判定する。
  bool isTotalMultipleOfFive() => calculateTotal() % 5 == 0;
}
```

最後に `ChangeNotifier` を継承して、必要な箇所で `notifyListeners` メソッドをコールするよう書き換えて完成です。

```dart
/// カウンターの振る舞いを表現するモデル。
class Counter extends ChangeNotifier {
  int get count => _count;

  List<int> get counts => _counts;

  /// カウント値。
  int _count = 0;

  /// カウント値のリスト。
  final List<int> _counts = [];

  /// カウント値に 1 を加算する。
  void increment() {
    _count++;
    notifyListeners();
  }

  /// カウント値をリストに追加する。
  void append() {
    _counts.add(_count);
    notifyListeners();
  }

  /// カウント値とカウント値のリストをクリアする。
  void clear() {
    _count = 0;
    _counts.clear();
    notifyListeners();
  }

  /// カウント値のリストの合計を計算する。
  int calculateTotal() {
    return _counts.fold(0, (a, b) => a + b);
  }

  /// カウント値の合計が 5 の倍数であるかを判定する。
  bool isTotalMultipleOfFive() => calculateTotal() % 5 == 0;
}
```

### Model のユニットテストの実装

Model が完成したので、View や Controller の実装に移る前に、Model のユニットテストを完成させてみます。

Dart (Flutter) におけるユニットテストの書き方の詳細はここでは説明しませんが、`ChangeNotifier` にしか依存していない `Counter` モデルは、次のように簡単にユニットテストを書くことができ、その振る舞いを説明したり振る舞いの正しさを検査したりすることができます。

```dart
void main() {
  late Counter counter;

  setUp(() {
    counter = Counter();
  });

  group('Counter', () {
    test('初期値は0である', () {
      expect(counter.count, 0);
    });

    test('値が正しくインクリメントされる', () {
      counter.increment();
      expect(counter.count, 1);
    });

    test('値がリストに正しく追加される', () {
      counter.append();
      expect(counter.counts.length, 1);
      expect(counter.counts[0], 0);

      counter.increment();
      counter.append();
      expect(counter.counts.length, 2);
      expect(counter.counts[1], 1);
    });

    test('値とリストが正しくクリアされる', () {
      counter.increment();
      counter.append();
      counter.clear();
      expect(counter.count, 0);
      expect(counter.counts.isEmpty, true);
    });

    test('リストの値の合計が正しく計算される', () {
      counter.increment();
      counter.append();
      counter.increment();
      counter.append();
      expect(counter.calculateTotal(), 3);
    });

    test('リストの値の合計が 5 の倍数である判定が正しくされる', () {
      counter.increment();
      counter.increment();
      counter.append();
      expect(counter.isTotalMultipleOfFive(), false);
      counter.increment();
      counter.append();
      expect(counter.isTotalMultipleOfFive(), true);
    });
  });
}
```

また、例えばカウントの値を何かしらの API と通信して送信し永続化するようなこともあるでしょう。そのような場合には、`Counter` クラスのコンストラクタで、リポジトリクラスや API クライアントのクラスをインジェクトします。

```dart
class Counter extends ChangeNotifier {
  Counter(Repository repository): _repository = repository;

  /// リポジトリクラスのインスタンス。
  final Repository _repository;

  // ... 省略
}
```

そうすることで、ユニットテストではそれをモックに置き換えることが容易にできます。

### Controller の実装

コントローラは、`Counter` モデルを保持して、ユーザーによる操作を解釈してモデルを操作したり、UI に反映したりする役割を担います。

コンストラクタで `Counter` モデルのインスタンスを渡す方法はシンプルで、コントローラのテストを書きたくなった場合にもモデルを容易にモックに置き換えることができるので良いでしょう。

ユーザー操作に相当するコントローラの各メソッドが、ユーザーの操作を解釈しながら、対応するモデルのメソッドを呼ぶようなつくりになっています。

`addToList` メソッドでは、合計値が 5 の倍数であるかどうかを判定して、そうである場合には、`SnackBar` を表示しています。これも Model を反映した View に反映するという意味で、コントローラの役割と捉えることができます。

他にも、例えばモデルで発生した例外を捕捉して、同様に `SnackBar` や `AlertDialog` を表示するような実装もコントローラに記述すると良いでしょう。

Model と違って Flutter に依存することを認めており、例えば `ElevatedButton` の `onPressed` に直接記述しても差し支えないような処理なので、`BuildContext` をメソッドの引数として渡すことも、ここでは許容しています。

```dart
/// ユーザーによる操作を解釈して [Counter] モデルを操作したり、モデルを UI に反映
/// させたりするコントローラ。
class CounterController {
  const CounterController(Counter counter) : _counter = counter;

  /// [CounterController] が保持・操作すべき [Counter] モデル。
  final Counter _counter;

  /// 「カウントアップボタンを押す。
  void countUp() => _counter.increment();

  /// 「リストに追加」ボタンを押す。
  /// 合計値が 5 の倍数であった場合には [SnackBar] を表示する。
  void addToList(BuildContext context) {
    _counter.append();
    final total = _counter.calculateTotal();
    if (_counter.isTotalMultipleOfFive()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('合計値 ($total) は 5 の倍数です！'),
        ),
      );
    }
  }

  /// 「クリア」ボタンを押す。
  void clear() => _counter.clear();
}
```

### View の実装

さいごに View の実装を行います。ユーザーが見るべき画面を構成します。

`context.watch<Counter>()` によってモデルのインスタンスを監視し、モデルの変更が通知された際に画面が再描画されるようになっています。`ElevatedButton` の `onPressed` の処理では `context.read<Counter>()` で参照した `CounterController` のインスタンスの各メソッドをコールしています。

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('カウント'),
            Text(counter.count.toString()),
            const SizedBox(height: 16),
            const Text('リスト'),
            Text(counter.counts.toString()),
            const SizedBox(height: 16),
            const Text('合計値'),
            Text(counter.calculateTotal().toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CounterController>().countUp(),
              child: const Text('カウントアップ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<CounterController>().addToList(context),
              child: const Text('リストに追加'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<CounterController>().clear(),
              child: const Text('クリア'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## さいごに

この章では、MVC アーキテクチャの概要を述べて、それをどのように解釈して Flutter に適用することができるか説明しました。

サンプルアプリでは、その具体例を示しながら、モデルのユニットテストも記述しました。

どのモジュールが他のどのモジュールに依存することは許して、反対にどのモジュールへの依存は許さないかを明確化し、依存させる場合にはどのように依存すると良いかの具体例を示すことで、テスト容易性、依存性の注入、PDS (Presentation Domain Separation) などの概念に関しても、意識したり学んだりするきっかけになるとも思います。

MVC アーキテクチャは最も抽象的なアーキテクチャとして、その思想を学ぶことは、今後他の様々なアーキテクチャを学ぶ上でも重要です。それぞれのアーキテクチャのそれぞれのレイヤーや役割が MVC のどれに相当するのかを考えることで理解が深まるでしょう。

また、ある程度大きい規模のアプリケーションであっても、MVC アーキテクチャによって十分に高い開発体験やテスト容易性を担保した開発を行うことができるはずです。

今後の Flutter の実装方針を考える参考にしてみてください。
