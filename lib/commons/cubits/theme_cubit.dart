import 'package:omkar_sale/core/app/all_import_file.dart';

class ThemeState {
  const ThemeState(this.appTheme);
  final AppThemeType appTheme;
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(SettingLocalRepository.instance.getTheme() == SettingLocalRepository.darkThemeKey ? AppThemeType.dark : AppThemeType.light));

  final SettingLocalRepository _preferences = SettingLocalRepository.instance;

  void changeTheme(AppThemeType appTheme) {
    _preferences.setTheme(appTheme == AppThemeType.dark ? SettingLocalRepository.darkThemeKey : SettingLocalRepository.lightThemeKey);
    emit(ThemeState(appTheme));
  }
}
