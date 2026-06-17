import 'package:omkar_sale/core/app/all_import_file.dart';

class AuthRepository {
  factory AuthRepository() => instance;
  AuthRepository._internal();
  static final AuthRepository instance = AuthRepository._internal();

  final AuthLocalRepository _localRepo = AuthLocalRepository.instance;

  Map<String, dynamic> getLocalAuthDetails() {
    return {'isLogin': _localRepo.checkIsAuth(), 'jwtToken': _localRepo.getJwtToken(), 'userData': _localRepo.getUserDetails()};
  }

  Future<void> setLocalAuthDetails({required String jwtToken, required bool authStatus, required Map<String, dynamic> userData}) async {
    await _localRepo.changeAuthStatus(authStatus: authStatus);
    await _localRepo.setJwtToken(jwtToken);
    await _localRepo.setUserDetails(userData);
  }

  Future<({Map<String, dynamic> userData, String jwtToken})> signUser({required String email, required String password}) async {
    try {
      final fcmToken = await getFCMToken();
      final body = {'email': email, 'password': password.trim(), 'deviceType': Platform.isAndroid ? 'android' : 'ios', 'fcmToken': fcmToken};

      body.log();
      final response = await Api.instance.post(url: loginUrl, parameter: body, useAuthToken: false);

      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }

      return (jwtToken: response['token'] as String, userData: response['data'] as Map<String, dynamic>);
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  // Future<void> signOut() async {
  //   await _localRepo.clearStorage();
  // }

  static Future<String> getFCMToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<void> clearSessionData() async {
    try {
      await _localRepo.clearSessionData();
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      final response = await Api.instance.get(url: logoutUrl, useAuthToken: true);

      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
