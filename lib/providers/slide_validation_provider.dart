import 'package:riverpod/riverpod.dart';

abstract class SlideValidationState {
  const SlideValidationState();
}

class SlideValidation extends SlideValidationState {
  final bool isValidated;
  const SlideValidation(this.isValidated);
}

class SlideValidatedNotifier<SlideValidationState> extends StateNotifier {
  SlideValidatedNotifier([SlideValidationState? state])
      : super(SlideValidation(false));

  Future<void> validateSlide(bool isValidated) async {
    state = SlideValidation(isValidated);
    return;
  }
}
