class ServiceProcess {
  final String? processName;
  final int? processDuration;
  ServiceProcess({this.processName, this.processDuration});

  Map<String, dynamic> get toMap {
    return {
      'processName': this.processName,
      'processDuration': this.processDuration
    };
  }

  ServiceProcess toModel(Map<String, dynamic> map) {
    return ServiceProcess(
        processName: map['processName'],
        processDuration: map['processDuration']);
  }
}
