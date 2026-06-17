import 'dart:math';

import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/repository/setting_repository.dart';

@immutable
abstract class AppSettingState extends Equatable {}

class AppSettingInitial extends AppSettingState {
  @override
  List<Object?> get props => [];
}

class AppSettingInProgress extends AppSettingState {
  @override
  List<Object?> get props => [];
}

class AppSettingSuccess extends AppSettingState {
  AppSettingSuccess({required this.appSettingsText});
  final String appSettingsText;

  @override
  List<Object?> get props => [appSettingsText];
}

class AppSettingFetchFailure extends AppSettingState {
  AppSettingFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class AppSettingCubit extends Cubit<AppSettingState> {
  AppSettingCubit() : super(AppSettingInitial());

  final SettingRepository _settingRepository = SettingRepository();

  Future<void> fetchAppSetting({required String type}) async {
    emit(AppSettingInProgress());
    try {
      final result = await _settingRepository.appSettings(type: type);
      emit(AppSettingSuccess(appSettingsText: result));
    } catch (e) {
      if (e is ApiException) {
        emit(AppSettingFetchFailure(exception: e));
      } else {
        emit(AppSettingFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
