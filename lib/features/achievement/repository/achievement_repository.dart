import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/achievement/model/achievement.dart';

class AchievementRepository {
  Future<Achievement> requestAchievement({required String achievementTitle}) async {
    try {
      final body = {'achievement': achievementTitle};
      final response = await Api.instance.post(url: achievementsUrl, useAuthToken: true, parameter: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }

      return Achievement.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<Map<String, dynamic>> getAchievements({
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final response = await Api.instance.get(url: achievementsUrl, useAuthToken: true);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return {
        'achievements': (response['data'] as List).map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e, st) {
      log(e.toString(), name: 'AchievementRepository.getAchievements', error: e, stackTrace: st);
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
