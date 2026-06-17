import 'package:flutter/cupertino.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class AppLocalizationState {
  const AppLocalizationState(this.language);

  final Locale language;
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  AppLocalizationCubit(this._preferences) : super(AppLocalizationState(UiUtils.getLocaleFromLanguageCode(_preferences.getLocale())));

  final SettingLocalRepository _preferences;

  Future<void> changeLanguage(String languageCode) async {
    await _preferences.setLocale(languageCode);

    emit(AppLocalizationState(UiUtils.getLocaleFromLanguageCode(languageCode)));
  }
}
