import 'package:beauty_fyi/test/misc/number_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberProvider = StreamProvider.autoDispose<int>((ref) async* {
  final numberCreator = NumberCreator();

  ref.onDispose(() => numberCreator.controller.sink.close());

  await for (final value in numberCreator.stream) {
    if (value > 10) {}

    if (value == 100) {
      numberCreator.controller.sink.close();
    }
    yield value;
  }
});

class StreamProviderWidget extends ConsumerWidget {
  @override
  Widget build(
    BuildContext context,
    ScopedReader watch,
  ) {
    AsyncValue<int> value = watch(numberProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Stream provider"),
      ),
      body: Container(
        height: double.infinity,
        child: Align(
          alignment: Alignment.center,
          child: Text(value.when(
              data: (_) => _.toString(),
              loading: () => "loading",
              error: (error, stacktrace) => error.toString())),
        ),
      ),
    );
  }
}
