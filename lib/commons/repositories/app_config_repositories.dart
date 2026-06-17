import 'package:omkar_sale/commons/models/app_config.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class AppSettingConfigRepositories {
  Future<AppConfig> gettingConfig() async {
    try {
      final response = await Api.instance.get(url: settingConfigUrl);

      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }

      return AppConfig.fromJson(
        response['data'] as Map<String, dynamic>? ?? {},
      );
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
