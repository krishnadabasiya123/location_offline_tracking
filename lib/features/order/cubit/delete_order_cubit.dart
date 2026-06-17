import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/repository/order_repository.dart';

@immutable
abstract class DeleteOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteOrderInitial extends DeleteOrderState {}

class DeleteOrderInProgress extends DeleteOrderState {}

class DeleteOrderSuccess extends DeleteOrderState {
  DeleteOrderSuccess({required this.orderId});
  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class DeleteOrderFailure extends DeleteOrderState {
  DeleteOrderFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class DeleteOrderCubit extends Cubit<DeleteOrderState> {
  DeleteOrderCubit() : super(DeleteOrderInitial());
  final OrderRepository _orderRepository = OrderRepository();

  Future<void> deleteOrder({required String orderId}) async {

    emit(DeleteOrderInProgress());
    await Future.delayed(const Duration(seconds: 2));
    try {
      await _orderRepository.deleteOrder(orderId: orderId);
      emit(DeleteOrderSuccess(orderId: orderId));
    } catch (e) {
      if (e is ApiException) {
        emit(DeleteOrderFailure(exception: e));
      } else {
        emit(DeleteOrderFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
