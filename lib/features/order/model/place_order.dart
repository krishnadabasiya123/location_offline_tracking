import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

/// --- Order Status Enum with UI properties ---
enum OrderStatus {
  approved('approvedLbl', Colors.green),
  rejected('rejectedLbl', Colors.red),
  cancelled('cancelledLbl', Colors.grey),
  pending('pendingLbl', Colors.orange),
  completed('completedLbl', Colors.blue)
  ;

  /// This is the localization key (e.g., 'pendingLbl' which converts to 'Pending')
  final String text;
  final Color color;

  const OrderStatus(this.text, this.color);

  Color get backgroundColor => color.withValues(alpha: 0.8);

  static OrderStatus fromValue(String? value) {
    if (value == null) return OrderStatus.pending;
    return OrderStatus.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase(), orElse: () => OrderStatus.pending);
  }
}

class PlaceOrderDetails extends Equatable {
  const PlaceOrderDetails({
    required this.id,
    required this.customer,
    required this.orderDate,
    required this.deliveryDate,
    required this.paymentMode,
    required this.status,
    required this.totalAmount,
    required this.notes,
    required this.tinNumber,
    required this.items,
  });

  factory PlaceOrderDetails.fromJson(Map<String, dynamic> json) {
    return PlaceOrderDetails(
      id: int.tryParse(json['id']?.toString() ?? '-1') ?? 0,
      customer: json['customer'] == null ? Shop.fromJson(const {}) : Shop.fromJson(json['customer'] as Map<String, dynamic>),
      orderDate: json['order_date']?.toString() ?? '',
      deliveryDate: json['delivery_date']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '-',
      // Correctly parsing String from API to Enum
      status: OrderStatus.fromValue(json['status']?.toString()),
      totalAmount: json['total_amount']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      tinNumber: (json['tin_number']?.toString() ?? '0') == '1',
      // Null-safe list parsing
      items: json['items'] == null
          ? []
          : (json['items'] as List).map((e) {
              final item = e as Map<String, dynamic>;
              final productMap = Map<String, dynamic>.from(item['product'] as Map<String, dynamic>);

              productMap['quantity'] = item['quantity'];
              return Product.fromJson(productMap);
            }).toList(),
    );
  }
  final int id;
  final Shop customer;
  final String orderDate;
  final String deliveryDate;
  final String paymentMode;
  final OrderStatus status;
  final String totalAmount;
  final String notes;
  final bool tinNumber;

  final List<Product> items;

  PlaceOrderDetails copyWith({
    int? id,
    Shop? customer,
    String? orderDate,
    String? deliveryDate,
    String? paymentMode,
    OrderStatus? status,
    bool? tinNumber,
    String? totalAmount,
    String? notes,
    List<Product>? items,
  }) {
    return PlaceOrderDetails(
      id: id ?? this.id,
      tinNumber: tinNumber ?? this.tinNumber,
      customer: customer ?? this.customer,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      paymentMode: paymentMode ?? this.paymentMode,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer.toJson(),
    'order_date': orderDate,
    'delivery_date': deliveryDate,
    'payment_mode': paymentMode,
    // Sending string name (e.g., "approved") to API
    'status': status.name,
    'total_amount': totalAmount,
    'tin_number': tinNumber,
    'notes': notes,
    'items': items.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return 'Order(id: $id, customer: ${customer.name}, status: ${status.name}, total: $totalAmount , items: $items)';
  }

  @override
  List<Object?> get props => [id, customer, orderDate, deliveryDate, paymentMode, status, tinNumber, totalAmount, notes, items];
}
