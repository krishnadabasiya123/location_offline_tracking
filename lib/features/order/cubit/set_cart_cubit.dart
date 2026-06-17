import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omkar_sale/core/api/api_config.dart';
import 'package:omkar_sale/features/order/model/product.dart';
import 'package:omkar_sale/utils/extensions/logger_extensions.dart';

@immutable
abstract class SetCartState extends Equatable {}

class SetCartInitial extends SetCartState {
  @override
  List<Object?> get props => [];
}

class SetCartInProgress extends SetCartState {
  @override
  List<Object?> get props => [];
}

class SetCartSuccess extends SetCartState {
  SetCartSuccess({required this.product, required this.quantity});
  final Product product;
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class SetCartFetchFailure extends SetCartState {
  SetCartFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class SetCartCubit extends Cubit<SetCartState> {
  SetCartCubit() : super(SetCartInitial());

  Future<void> updateItemInCart({required Product product, required int quantity}) async {
    // We emit Success immediately to update the UI smoothly
    quantity.log('SetCartCubit');
    product.log('SetCartCubit');
    emit(SetCartSuccess(product: product, quantity: quantity));
  }

  void reset() {
    emit(SetCartInitial());
  }


  
}
