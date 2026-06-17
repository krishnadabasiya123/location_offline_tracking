import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class GetCartItemState extends Equatable {}

class GetCartItemInitial extends GetCartItemState {
  @override
  List<Object?> get props => [];
}

class GetCartItemInProgress extends GetCartItemState {
  @override
  List<Object?> get props => [];
}

class GetCartItemSuccess extends GetCartItemState {
  GetCartItemSuccess({required this.products});
  final List<Product> products;

  GetCartItemSuccess copyWith({List<Product>? products}) {
    return GetCartItemSuccess(products: products ?? this.products);
  }

  @override
  List<Object?> get props => [products];
}

class GetCartItemFetchFailure extends GetCartItemState {
  GetCartItemFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class GetCartItemCubit extends Cubit<GetCartItemState> {
  GetCartItemCubit() : super(GetCartItemInitial());

  void featchCartProducts() {
    emit(GetCartItemSuccess(products: const []));
  }

  void clearCart() {
    emit(GetCartItemSuccess(products: const []));
  }

  void updateItemInCart({required Product product, required int quantity}) {
    if (state is! GetCartItemSuccess) {
      emit(GetCartItemSuccess(products: [product.copyWith(quantity: quantity)]));
      return;
    }

    final currentState = state as GetCartItemSuccess;
    final updatedProducts = List<Product>.from(currentState.products);
    final index = updatedProducts.indexWhere((element) => element.id == product.id);

    if (quantity <= 0) {
      if (index != -1) {
        updatedProducts.removeAt(index);
      }
    } else {
      if (index != -1) {
        updatedProducts[index] = updatedProducts[index].copyWith(quantity: quantity);
      } else {
        updatedProducts.add(product.copyWith(quantity: quantity));
      }
    }

    emit(GetCartItemSuccess(products: updatedProducts));
  }

  int getTotalQuantity() {
    final s = state;
    if (s is GetCartItemSuccess) {
      return s.products.fold(0, (prev, element) => prev + element.quantity);
    }
    return 0;
  }

  //give me total product lenth not product with quantity
  int getTotalProductLength() {
    final s = state;
    if (s is GetCartItemSuccess) {
      return s.products.length;
    }
    return 0;
  }

  double getCartTotal() {
    final s = state;
    if (s is GetCartItemSuccess) {
      // Start fold with 0.0 (double)
      return s.products.fold(0, (double prev, element) {
        final price = double.tryParse(element.price) ?? 0.0;
        return prev + (price * element.quantity);
      });
    }
    return 0;
  }

  List<Product> getCartProducts() {
    if (state is GetCartItemSuccess) {
      return (state as GetCartItemSuccess).products;
    }
    return [];
  }
}
