//AppConfigurationCubit

import 'package:omkar_sale/commons/models/app_config.dart';
import 'package:omkar_sale/commons/repositories/app_config_repositories.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/location_service.dart';

@immutable
abstract class AppConfigState extends Equatable {}

class AppConfigInitial extends AppConfigState {
  @override
  List<Object?> get props => [];
}

class AppConfigFetchProgress extends AppConfigState {
  @override
  List<Object?> get props => [];
}

class AppConfigFetchSuccess extends AppConfigState {
  AppConfigFetchSuccess({required this.appConfig});

  final AppConfig appConfig;

  AppConfigFetchSuccess copyWith({AppConfig? newAppConfig}) {
    return AppConfigFetchSuccess(appConfig: newAppConfig ?? appConfig);
  }

  @override
  List<Object?> get props => [appConfig];
}

class AppConfigFetchFailure extends AppConfigState {
  AppConfigFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class AppConfigCubit extends Cubit<AppConfigState> {
  AppConfigCubit() : super(AppConfigInitial());
  final AppSettingConfigRepositories _appSettingConfigRepositories = AppSettingConfigRepositories();

  Future<void> fetchAppConfig() async {
    emit(AppConfigFetchProgress());

    await _appSettingConfigRepositories
        .gettingConfig()
        .then((value) async {
          await SettingLocalRepository.instance.setLocationUpdateInterval(value.trackingConfig.gpsUpdateInterval);
          LocationTracker.instance.updateInterval(value.trackingConfig.gpsUpdateInterval);
          emit(AppConfigFetchSuccess(appConfig: value));
        })
        .catchError((Object e) {
          if (e is ApiException) {
            emit(AppConfigFetchFailure(exception: e));
          } else {
            emit(AppConfigFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
          }
        });
  }

  MaintenanceMode getCurrentMaintenanceMode() {
    if (state is AppConfigFetchSuccess) {
      return (state as AppConfigFetchSuccess).appConfig.maintenanceMode;
    }
    return MaintenanceMode.fromJson(const {});
  }

  ForceUpdate getCurrentForceUpdate() {
    if (state is AppConfigFetchSuccess) {
      return (state as AppConfigFetchSuccess).appConfig.forceUpdate;
    }
    return ForceUpdate.fromJson(const {});
  }

  TrackingConfig getCurrentTrackingConfig() {
    if (state is AppConfigFetchSuccess) {
      return (state as AppConfigFetchSuccess).appConfig.trackingConfig;
    }
    return TrackingConfig.fromJson(const {});
  }

  List<PaymentMethod> getCurrentPaymentMethods() {
    if (state is AppConfigFetchSuccess) {
      return (state as AppConfigFetchSuccess).appConfig.paymentMethods;
    }
    return [];
  }
}
