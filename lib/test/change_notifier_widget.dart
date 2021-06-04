import 'package:beauty_fyi/test/misc/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = ChangeNotifierProvider<Counter>((ref) => Counter());

class ChangeNotifierWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final count = watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("change notifier"),
        backgroundColor: Colors.yellow,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(child: Text(count.count.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read(counterProvider).increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
