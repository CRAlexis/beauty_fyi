import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:riverpod/riverpod.dart';

enum ServicesProviderEnum { READALL, READONE, NULL }

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

class ServiceLoaded extends ServicesState {
  final List<ServiceMedia> serviceMedia;
  final ServiceModel service;
  const ServiceLoaded(this.service, this.serviceMedia);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ServiceLoaded && o.service == service;
  }

  @override
  int get hashCode => service.hashCode;
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
  ServicesNotifier(ServicesProviderEnum servicesProviderEnum, int? serviceId,
      [ServicesNotifier? state])
      : super(ServicesInitial()) {
    switch (servicesProviderEnum) {
      case ServicesProviderEnum.READALL:
        getServices();
        break;
      case ServicesProviderEnum.READONE:
        getService(serviceId);
        break;
      default:
        getServices();
        break;
    }
  }

  Future<void> getServices() async {
    try {
      state = ServicesLoading();
      final List<ServiceModel> services = await ServiceModel().readServices();
      state = ServicesLoaded(services);
      return;
    } catch (e) {
      state = ServicesError("Unable to load services.");
      return;
    }
  }

  Future<void> getService(serviceId) async {
    try {
      state = ServicesLoading();
      final service = await ServiceModel(id: serviceId).readService();
      final serviceImages = await fetchServiceImages(serviceId);
      state = ServiceLoaded(service, serviceImages);
    } catch (e) {
      state = ServicesError("Unable to load service.");
    }
  }

  Future<List<ServiceMedia>> fetchServiceImages(int serviceId) async {
    return await ServiceMedia()
        .readServiceMedia(sql: "service_id = ?", args: [serviceId]);
  }
}
