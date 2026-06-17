import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/model/place_order.dart';
import 'package:omkar_sale/features/order/repository/order_repository.dart';

@immutable
abstract class GetOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetOrdersInitial extends GetOrdersState {}

class GetOrdersInProgress extends GetOrdersState {}

class GetOrdersFetchSuccess extends GetOrdersState {
  GetOrdersFetchSuccess({
    required this.orders,
    required this.total,
    required this.searchQuery,

    this.isError = false,
    this.isLoading = false,
    this.exception,
  });
  final List<PlaceOrderDetails> orders;
  final int total;
  final String searchQuery;
  final bool isLoading;
  final bool isError;
  final ApiException? exception;

  GetOrdersFetchSuccess copyWith({
    List<PlaceOrderDetails>? orders,
    int? total,
    String? searchQuery,
    bool? isLoading,
    bool? isError,
    ApiException? exception,
  }) {
    return GetOrdersFetchSuccess(
      orders: orders ?? this.orders,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      exception: exception ?? this.exception,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [orders, total, searchQuery, isLoading, isError, exception];
}

class GetOrdersFetchFailure extends GetOrdersState {
  GetOrdersFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetOrdersCubit extends Cubit<GetOrdersState> {
    GetOrdersCubit() : super(GetOrdersInitial());
  final OrderRepository _orderRepository = OrderRepository();

  Future<void> fetchGetOrders({String searchQuery = ''}) async {
    emit(GetOrdersInProgress());

    try {
      final value = await _orderRepository.getOrders(limit: apiCallLimit, searchQuery: searchQuery);

      emit(
        GetOrdersFetchSuccess(
          orders: value['products'] as List<PlaceOrderDetails>,
          total: value['total'] as int,
          searchQuery: searchQuery,
        ),
      );
    } catch (e) {
      if (e is ApiException) {
        emit(GetOrdersFetchFailure(exception: e));
      } else {
        emit(GetOrdersFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }




void deleteOrder(String orderId) {
    if (state is! GetOrdersFetchSuccess) return;
    final currentState = state as GetOrdersFetchSuccess;
    final targetId = int.tryParse(orderId);
    if (targetId == null) return;
    final containsOrder = currentState.orders.any((o) => o.id == targetId);
    if (!containsOrder) return;
    final updatedOrders = currentState.orders.where((order) => order.id != targetId).toList();
    
    final updatedTotal = (currentState.total - 1).clamp(0, currentState.total);
    emit(currentState.copyWith(
      orders: updatedOrders,
      total: updatedTotal,
      isError: false,
     
    ));
  }


  Future<void> fetchMoreProducts() async {
    if (state is GetOrdersFetchSuccess) {
      final currentState = state as GetOrdersFetchSuccess;
      if (currentState.isLoading) return;

      emit(currentState.copyWith(isLoading: true));

      try {
        final value = await _orderRepository.getOrders(
          searchQuery: currentState.searchQuery,
          limit: apiCallLimit,
          offset: currentState.orders.length,
        );
        final newProducts = value['products'] as List<PlaceOrderDetails>;
        emit(currentState.copyWith(orders: [...currentState.orders, ...newProducts], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(currentState.copyWith(isError: true, exception: e));
        } else {
          emit(currentState.copyWith(isError: true, exception: ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreProducts() {
    if (state is GetOrdersFetchSuccess) {
      final s = state as GetOrdersFetchSuccess;
      return s.total > s.orders.length;
    }
    return false;
  }
}
