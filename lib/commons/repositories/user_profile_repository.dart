import 'package:omkar_sale/commons/models/agenda_details.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class UserProfileRepository {
  Future<UserDetails> getUserProfile() async {
    try {
      final response = await Api.instance.get(url: userProfileUrl, useAuthToken: true);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return UserDetails.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  //agendas
  Future<Map<String, dynamic>> getAgendas({
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final body = {'limit': limit, 'offset': offset};
      final response = await Api.instance.get(url: agendasUrl, useAuthToken: true, queryParameters: body);

      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return {
        'agendas': (response['data'] as List).map((e) => AgendaDetails.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<AgendaDetails> setAgendas({required int agendaId, required String agendaTitle}) async {
    try {
      final body = {'completion_notes': agendaTitle, 'id': agendaId};
      final response = await Api.instance.patch(url: agendaCompletionNotesUrl, useAuthToken: true, parameter: body);

      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return AgendaDetails.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
