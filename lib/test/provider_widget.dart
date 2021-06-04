import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helloWorldProvider = Provider<String>((ref) => "Hello worlds");

class ProviderWidget extends ConsumerWidget {
  @override
  Widget build(
    BuildContext context,
    ScopedReader watch,
  ) {
    final text = watch(helloWorldProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Provider"),
      ),
      body: Container(
        height: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: Text(text),
        ),
      ),
    );
  }
}
