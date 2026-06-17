import 'package:omkar_sale/core/app/all_import_file.dart';

class ShopRepository {
  Future<Map<String, dynamic>> getShops({
    required String searchQuery,
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final body = {'search': searchQuery, 'limit': apiCallLimit, 'offset': offset};
      if (searchQuery.isEmpty) {
        body.remove('search');
      }
      final response = await Api.instance.get(url: shopsUrl, useAuthToken: true, queryParameters: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return {
        'shops': (response['data'] as List).map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<Shop> createShop({
    required String shopName,
    required String shopsAddress,
    required String shopCity,
    required String shopTINnumber,
    required String shopContactPerson,
    required String shopPhone,
    required String email,
    required String shopLatitude,
    required String shopLongitude,
  }) async {
    try {
      final body = {
        'name': shopName,
        'address': shopsAddress,
        'city': shopCity,
        'contact_phone': shopPhone,
        'contact_person': shopContactPerson,
        'latitude': shopLatitude,
        'longitude': shopLongitude,
        'email': email,
        'tin': shopTINnumber,
      };
      final response = await Api.instance.post(url: shopsUrl, useAuthToken: true, parameter: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return Shop.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  //storeVisitsBulkUrl

  Future<void> submitDailyReport({
    required List<Map<String, dynamic>> visits,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};

      for (var i = 0; i < visits.length; i++) {
        final visit = visits[i];

        formDataMap['visits[$i][customer_id]'] = visit['shopId'];
        formDataMap['visits[$i][purposes]'] = visit['purpose'];
        formDataMap['visits[$i][remarks]'] = visit['remarks'];

        final visitedAt = visit['timestamp']?.toString() ?? '';
        if (visitedAt.trim().isNotEmpty) {
          final parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(visitedAt);

          final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

          formDataMap['visits[$i][visited_at]'] = formattedDate;
        }

        final photoPaths = visit['images'] as List<File>? ?? [];
        if (photoPaths.isNotEmpty) {
          for (var j = 0; j < photoPaths.length; j++) {
            final path = photoPaths[j].path;
            print("Checking path: '$path'"); // Look at the output in your console!

            final file = File(path);
            final isExists = await file.exists();
            print('Exists: $isExists');
            if (isExists) {
              formDataMap['visits[$i][photos][$j]'] = await MultipartFile.fromFile(path, filename: path.split('/').last);
            }
          }
        }
      }
      formDataMap.log('submitDailyReport formDataMap');
      final response = await Api.instance.post(url: storeVisitsBulkUrl, parameter: formDataMap, useAuthToken: true);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
