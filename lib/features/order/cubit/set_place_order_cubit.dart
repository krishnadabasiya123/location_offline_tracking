import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omkar_sale/core/api/api_config.dart';
import 'package:omkar_sale/features/order/repository/order_repository.dart';

@immutable
abstract class SetOrderPlaceState extends Equatable {}

class SetOrderPlaceInitial extends SetOrderPlaceState {
  @override
  List<Object?> get props => [];
}

class SetOrderPlaceInProgress extends SetOrderPlaceState {
  @override
  List<Object?> get props => [];
}

class SetOrderPlaceSuccess extends SetOrderPlaceState {
  @override
  List<Object?> get props => [];
}

class SetOrderPlaceFetchFailure extends SetOrderPlaceState {
  SetOrderPlaceFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class SetOrderPlaceCubit extends Cubit<SetOrderPlaceState> {
  SetOrderPlaceCubit() : super(SetOrderPlaceInitial());
  final OrderRepository _orderRepository = OrderRepository();

  Future<void> placeOrder({
    required String customerId,
    required List<Map<String, String>> productIdAndQuantity,
    required bool tinNumber,
    required String paymentTypeId,
    String notes = '',
    String deliveryDate = '',
  }) async {
    emit(SetOrderPlaceInProgress());
    try {
      await _orderRepository.setOrder(
        customerId: customerId,
        notes: notes,
        productIdAndQuantity: productIdAndQuantity,
        tinNumber: tinNumber,
        paymentTypeId: paymentTypeId,
        deliveryDate: deliveryDate,
      );

      emit(SetOrderPlaceSuccess());
    } catch (e) {
      if (e is ApiException) {
        emit(SetOrderPlaceFetchFailure(exception: e));
      } else {
        emit(SetOrderPlaceFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
