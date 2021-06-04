import 'package:beauty_fyi/models/service_model.dart';
import 'package:riverpod/riverpod.dart';

abstract class ServicesState {
  const ServicesState();
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  const ServicesLoaded(this.services);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ServicesLoaded && o.services == services;
  }

  @override
  int get hashCode => services.hashCode;
}

class ServicesError extends ServicesState {
  final String message;
  const ServicesError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ServicesError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  ServicesNotifier([ServicesNotifier? state]) : super(ServicesInitial()) {
    getServices();
  }

  Future<void> getServices() async {
    try {
      state = ServicesLoading();
      final List<ServiceModel> services = await ServiceModel().readServices();
      state = ServicesLoaded(services);
      return;
    } catch (e) {
      state = ServicesError("Unable to load your services");
      return;
    }
  }
}

class _Extender {
  void testing() {}
}

class _Testing extends _Extender {
  _Testing() : super() {
    print("hey");
  }
}
