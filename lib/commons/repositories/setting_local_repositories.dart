import 'package:omkar_sale/core/app/all_import_file.dart';

class SettingLocalRepository {
  SettingLocalRepository._();
  static const String _boxName = 'app_preferences';

  static const String _localeKey = 'locale';
  static const String _themeKey = 'theme';
  static const String isOpenFirstTimeKey = 'isOpenFirstTime';
  static const String _locationUpdateIntervalKey = 'locationUpdateInterval';
  static const String _locationDisclosureKey = 'locationDisclosureAccepted';
  // Stores show count. 99 = permanently done (user completed the setup).
  static const String _batteryOptDialogShownKey = 'batteryOptDialogShownCount';
  static const String _autoStartDialogShownKey = 'autoStartDialogShown';
  static const String _clockStateKey = 'is_clocked_in';
  // Theme values
  static const String lightThemeKey = 'light';
  static const String darkThemeKey = 'dark';

  static Box<dynamic> get _box => Hive.box<dynamic>(_boxName);
  static final SettingLocalRepository instance = SettingLocalRepository._();

  /// Call this in main()
  Future<void> init() async {
    await Hive.openBox<dynamic>(_boxName);
  }

  /* -------------------- Location Update Interval -------------------- */
  Future<void> setLocationUpdateInterval(int interval) async {
    await _box.put(_locationUpdateIntervalKey, interval);
  }

  int getLocationUpdateInterval() {
    return _box.get(_locationUpdateIntervalKey, defaultValue: 15) as int;
  }

  /* -------------------- Locale -------------------- */

  Future<void> setLocale(String locale) async {
    await _box.put(_localeKey, locale);
  }

  String getLocale() {
    return _box.get(_localeKey, defaultValue: UiUtils.defaultLanguageCode)
        as String;
  }

  /* -------------------- Theme -------------------- */

  Future<void> setTheme(String theme) async {
    await _box.put(_themeKey, theme);
  }

  String getTheme() {
    return _box.get(_themeKey, defaultValue: UiUtils.defaultThemeKey) as String;
  }

  /* -------------------- Is Open First Time -------------------- */
  Future<void> setIsOpenFirstTime() async {
    return _box.put(isOpenFirstTimeKey, true);
  }

  bool getIsOpenFirstTime() {
    return _box.get(isOpenFirstTimeKey, defaultValue: false) as bool;
  }

  /* -------------------- Location Disclosure -------------------- */
  Future<void> setLocationDisclosureAccepted() async {
    await _box.put(_locationDisclosureKey, true);
  }

  bool isLocationDisclosureAccepted() {
    return _box.get(_locationDisclosureKey, defaultValue: false) as bool;
  }

  /* -------------------- Battery Optimization Dialog -------------------- */

  /// Returns how many times the dialog has been shown.
  /// 99 = user completed setup, permanently skip.
  int getBatteryOptDialogCount() {
    return _box.get(_batteryOptDialogShownKey, defaultValue: 0) as int;
  }

  Future<void> setBatteryOptDialogCount(int count) async {
    await _box.put(_batteryOptDialogShownKey, count);
  }

  Future<void> markBatteryOptDone() async {
    await _box.put(_batteryOptDialogShownKey, 99);
  }

  /* -------------------- Auto-Start Dialog -------------------- */

  bool isAutoStartDialogShown() {
    return _box.get(_autoStartDialogShownKey, defaultValue: false) as bool;
  }

  Future<void> markAutoStartDialogShown() async {
    await _box.put(_autoStartDialogShownKey, true);
  }

  /* -------------------- Shift Config -------------------- */
  static const String _shiftConfigBoxName = 'shift_config';
  static const String _shiftTokenKey = 'token';
  static const String _shiftIntervalKey = 'interval';
  static const String _shiftIsActiveKey = 'isActive';

  Future<void> saveShiftConfig({
    required String token,
    required int interval,
    required bool isActive,
  }) async {
    final box = await Hive.openBox<dynamic>(_shiftConfigBoxName);
    await box.put(_shiftTokenKey, token);
    await box.put(_shiftIntervalKey, interval);
    await box.put(_shiftIsActiveKey, isActive);
  }

  Future<void> setShiftActive(bool isActive) async {
    final box = await Hive.openBox<dynamic>(_shiftConfigBoxName);
    await box.put(_shiftIsActiveKey, isActive);
  }

  /* -------------------- Last Location Fix Timestamp -------------------- */
  // Used to detect process death: on tracker start, compare now() vs last fix
  // while shift was active. Large gap = OS killed app mid-shift.
  static const String _lastFixMsKey = 'lastFixEpochMs';

  Future<void> setLastFixEpochMs(int epochMs) async {
    await _box.put(_lastFixMsKey, epochMs);
  }

  int? getLastFixEpochMs() {
    final v = _box.get(_lastFixMsKey);
    return v is int ? v : null;
  }

  /* -------------------- Clock State -------------------- */
  Future<void> setClockedIn(bool isClockedIn) async {
    await _box.put(_clockStateKey, isClockedIn);
  }

  bool getClockedIn() {
    return _box.get(_clockStateKey, defaultValue: false) as bool;
  }
}
