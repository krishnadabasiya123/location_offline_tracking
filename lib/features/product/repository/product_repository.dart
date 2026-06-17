import 'package:omkar_sale/core/app/all_import_file.dart';

class ProductRepository {
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await Api.instance.get(url: categoriesUrl, useAuthToken: true);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return (response['data'] as List).map((e) => ProductCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<Map<String, dynamic>> getProducts({
    required int categoryId,
    required String searchQuery,
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final body = {'category_id': categoryId, 'search': searchQuery, 'limit': apiCallLimit, 'offset': offset};
      if (searchQuery.isNotEmpty) {
        body.remove('category_id');
      }
      if (categoryId == -1) {
        body.remove('category_id');
      }
      if (searchQuery.isEmpty) {
        body.remove('search');
      }
      final response = await Api.instance.get(url: productsUrl, useAuthToken: true, queryParameters: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return {
        'products': (response['data'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
