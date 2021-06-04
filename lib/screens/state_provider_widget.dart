import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorToggleProvider = StateProvider<String>((ref) => "");

class StateProviderWidget extends ConsumerWidget {
  @override
  Widget build(
    BuildContext context,
    ScopedReader watch,
  ) {
    final color = watch(colorToggleProvider).state;
    return Scaffold(
      backgroundColor: color == 'Red' ? Colors.red : Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("State provider"),
      ),
      body: Container(
        height: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: Text("Toggle color"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => context.read(colorToggleProvider).state =
              color == 'Red' ? 'Blue' : 'Red',
          child: Icon(Icons.toggle_on)),
    );
  }
}
