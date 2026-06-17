import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  const AppConfig({
    required this.maintenanceMode,
    required this.forceUpdate,
    required this.trackingConfig,
    required this.paymentMethods,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      maintenanceMode: MaintenanceMode.fromJson(
        json['maintenance_mode'] as Map<String, dynamic>? ?? {},
      ),
      forceUpdate: ForceUpdate.fromJson(
        json['force_update'] as Map<String, dynamic>? ?? {},
      ),
      trackingConfig: TrackingConfig.fromJson(
        json['tracking_config'] as Map<String, dynamic>? ?? {},
      ),
      paymentMethods: (json['payment_methods'] as List? ?? [])
          .map((x) => PaymentMethod.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
  final MaintenanceMode maintenanceMode;
  final ForceUpdate forceUpdate;
  final TrackingConfig trackingConfig;
  final List<PaymentMethod> paymentMethods;

  AppConfig copyWith({
    MaintenanceMode? maintenanceMode,
    ForceUpdate? forceUpdate,
    TrackingConfig? trackingConfig,
    List<PaymentMethod>? paymentMethods,
  }) {
    return AppConfig(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      trackingConfig: trackingConfig ?? this.trackingConfig,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  Map<String, dynamic> toJson() => {
    'maintenance_mode': maintenanceMode.toJson(),
    'force_update': forceUpdate.toJson(),
    'tracking_config': trackingConfig.toJson(),
    'payment_methods': paymentMethods.map((x) => x.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    maintenanceMode,
    forceUpdate,
    trackingConfig,
    paymentMethods,
  ];

  @override
  String toString() =>
      'AppConfig(maintenanceMode: $maintenanceMode, forceUpdate: $forceUpdate, trackingConfig: $trackingConfig, paymentMethods: $paymentMethods)';
}

class ForceUpdate extends Equatable {
  const ForceUpdate({
    required this.android,
    required this.ios,
  });

  factory ForceUpdate.fromJson(Map<String, dynamic> json) {
    return ForceUpdate(
      android: PlatformUpdateInfo.fromJson(
        json['android'] as Map<String, dynamic>? ?? {},
      ),
      ios: PlatformUpdateInfo.fromJson(
        json['ios'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
  final PlatformUpdateInfo android;
  final PlatformUpdateInfo ios;

  ForceUpdate copyWith({PlatformUpdateInfo? android, PlatformUpdateInfo? ios}) {
    return ForceUpdate(android: android ?? this.android, ios: ios ?? this.ios);
  }

  Map<String, dynamic> toJson() => {
    'android': android.toJson(),
    'ios': ios.toJson(),
  };

  @override
  List<Object?> get props => [android, ios];

  @override
  String toString() => 'ForceUpdate(android: $android, ios: $ios)';
}

/// Renamed from "Android" to "PlatformUpdateInfo" to be platform-agnostic
class PlatformUpdateInfo extends Equatable {
  const PlatformUpdateInfo({
    required this.enable,
    required this.version,
    required this.url,
  });

  factory PlatformUpdateInfo.fromJson(Map<String, dynamic> json) {
    return PlatformUpdateInfo(
      enable: json['enable'] as bool? ?? false,
      version: json['version'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
  final bool enable;
  final String version;
  final String url;

  PlatformUpdateInfo copyWith({bool? enable, String? version, String? url}) {
    return PlatformUpdateInfo(
      enable: enable ?? this.enable,
      version: version ?? this.version,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toJson() => {
    'enable': enable,
    'version': version,
    'url': url,
  };

  @override
  List<Object?> get props => [enable, version, url];

  @override
  String toString() =>
      'PlatformUpdateInfo(enable: $enable, version: $version, url: $url)';
}

class MaintenanceMode extends Equatable {
  const MaintenanceMode({required this.android, required this.ios});

  factory MaintenanceMode.fromJson(Map<String, dynamic> json) {
    return MaintenanceMode(
      android: false,

      //json['android'] as bool? ?? false,
      ios: json['ios'] as bool? ?? false,
    );
  }
  final bool android;
  final bool ios;

  MaintenanceMode copyWith({bool? android, bool? ios}) {
    return MaintenanceMode(
      android: android ?? this.android,
      ios: ios ?? this.ios,
    );
  }

  Map<String, dynamic> toJson() => {'android': android, 'ios': ios};

  @override
  List<Object?> get props => [android, ios];

  @override
  String toString() => 'MaintenanceMode(android: $android, ios: $ios)';
}

class PaymentMethod extends Equatable {
  const PaymentMethod({
    required this.id,
    required this.key,
    required this.value,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
  final int id;
  final String key;
  final String value;

  PaymentMethod copyWith({
    int? id,
    String? key,
    String? value,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'value': value,
  };

  @override
  List<Object?> get props => [id, key, value];

  @override
  String toString() => 'PaymentMethod(id: $id, key: $key, value: $value)';
}

class TrackingConfig extends Equatable {
  const TrackingConfig({
    required this.gpsUpdateInterval,
    required this.workStartHour,
    required this.workEndHour,
  });

  factory TrackingConfig.fromJson(Map<String, dynamic> json) {
    return TrackingConfig(
      gpsUpdateInterval: json['gps_update_interval'] as int? ?? 0,
      workStartHour: json['work_start_hour'] as String? ?? '',
      workEndHour: json['work_end_hour'] as String? ?? '',
    );
  }
  final int gpsUpdateInterval;
  final String workStartHour;
  final String workEndHour;

  TrackingConfig copyWith({
    int? gpsUpdateInterval,
    String? workStartHour,
    String? workEndHour,
  }) {
    return TrackingConfig(
      gpsUpdateInterval: gpsUpdateInterval ?? this.gpsUpdateInterval,
      workStartHour: workStartHour ?? this.workStartHour,
      workEndHour: workEndHour ?? this.workEndHour,
    );
  }

  Map<String, dynamic> toJson() => {
    'gps_update_interval': gpsUpdateInterval,
    'work_start_hour': workStartHour,
    'work_end_hour': workEndHour,
  };

  @override
  List<Object?> get props => [gpsUpdateInterval, workStartHour, workEndHour];

  @override
  String toString() =>
      'TrackingConfig(gpsUpdateInterval: $gpsUpdateInterval, workStartHour: $workStartHour, workEndHour: $workEndHour)';
}
