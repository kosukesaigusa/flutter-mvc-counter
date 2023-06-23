import 'package:flutter/material.dart';

import 'counter.dart';

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
