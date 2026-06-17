import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/model/place_order.dart';

class OrderRepository {
  Future<void> setOrder({
    required String customerId,
    required String notes,
    required List<Map<String, String>> productIdAndQuantity,
    required bool tinNumber,
    required String paymentTypeId,
    required String deliveryDate,
  }) async {
    try {
      final body = {
        'customer_id': customerId,
        'notes': notes,
        'tin_number': tinNumber ? '1' : '0',
        'delivery_date': deliveryDate,
        'payment_mode': paymentTypeId,
      };

      for (var i = 0; i < productIdAndQuantity.length; i++) {
        body['order_items[$i][product_id]'] = productIdAndQuantity[i]['product_id'] ?? '';
        body['order_items[$i][quantity]'] = productIdAndQuantity[i]['quantity'] ?? '';
      }
      body.log();
      final response = await Api.instance.post(url: ordersUrl, useAuthToken: true, parameter: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<Map<String, dynamic>> getOrders({
    required String searchQuery,
    required int limit,
    int? offset = 0,
  }) async {
    try {
      final body = {
        'search': searchQuery,
        'limit': limit,
        'offset': offset,
      };
      final response = await Api.instance.get(url: ordersUrl, useAuthToken: true, queryParameters: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
      return {
        'products': (response['data'] as List).map((e) => PlaceOrderDetails.fromJson(e as Map<String, dynamic>)).toList(),
        'total': response['total'] as int,
      };
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }

  Future<void> deleteOrder({required String orderId}) async {
    try {
      final body = {'id': orderId};
      final response = await Api.instance.post(url: deleteOrderUrl, useAuthToken: true, parameter: body);
      if (response['error'] as bool) {
        throw ApiException(errorMessageKey: response['message'] as String);
      }
    } on ApiException catch (_) {
      rethrow;
    } catch (e) {
      throw ApiException(errorMessageKey: e.toString());
    }
  }
}
