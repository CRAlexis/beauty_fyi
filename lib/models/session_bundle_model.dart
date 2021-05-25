import 'package:beauty_fyi/models/service_media.dart';
import 'package:beauty_fyi/models/service_model.dart';
import 'package:beauty_fyi/models/session_model.dart';

class SessionBundleModel {
  final List<SessionModel> sessionModel;
  final List<ServiceModel> serviceModel;
  final List<List<ServiceMedia>> serviceMedia;
  SessionBundleModel(
      {required this.sessionModel,
      required this.serviceMedia,
      required this.serviceModel});
}
