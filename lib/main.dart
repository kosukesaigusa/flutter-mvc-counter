import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'counter.dart';
import 'counter_controller.dart';
import 'counter_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Counter>(create: (_) => Counter()),
        ProxyProvider<Counter, CounterController>(
          update: (_, counter, __) => CounterController(counter),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter MVC Counter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const CounterPage(),
      ),
    );
  }
}
