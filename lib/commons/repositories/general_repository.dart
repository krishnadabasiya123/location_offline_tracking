import 'package:omkar_sale/core/app/all_import_file.dart';

class GeneralRepository {
  Future<UserDetails> updateProfile({required String name, required String number, required String imageUrl}) async {
    try {
      final body = <String, dynamic>{'name': name, 'phone': number};

      if (imageUrl.isNotEmpty) {
        body['profile'] = await MultipartFile.fromFile(imageUrl);
      }

      final response = await Api.instance.post(url: updateUserProfileUrl, parameter: body, useAuthToken: true);

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
}
