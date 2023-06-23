import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'counter.dart';
import 'counter_controller.dart';

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
