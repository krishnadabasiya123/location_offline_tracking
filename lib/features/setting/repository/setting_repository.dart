import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/model/notification.dart';

class SettingRepository {
  Future<String> appSettings({required String type}) async {
    try {
      final body = {'type': type};
      final response = await Api.instance.get(url: settingsUrl, useAuthToken: true, queryParameters: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }

      final data = response['data'] as List? ?? [];

      if (data.isEmpty) return '';

      final firstItem = data.first as Map<String, dynamic>;

      return firstItem['value']?.toString() ?? '';
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<Map<String, dynamic>> getNotificationsList({
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final response = await Api.instance.get(url: notificationsUrl, useAuthToken: true);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }

      return {
        'notifications': (response['data'] as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
