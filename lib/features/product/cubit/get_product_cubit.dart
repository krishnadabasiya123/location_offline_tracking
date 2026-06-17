import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class GetProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetProductInitial extends GetProductState {}

class GetProductInProgress extends GetProductState {}

class GetProductFetchSuccess extends GetProductState {
  GetProductFetchSuccess({
    required this.products,
    required this.total,
    required this.searchQuery,
    required this.categoryId,
    this.isError = false,
    this.isLoading = false,
    this.isUpdatingProducts = false,
    this.exception,
  });
  final List<Product> products;
  final int total;
  final String searchQuery;
  final int categoryId;
  final bool isLoading;
  final bool isError;
  final ApiException? exception;
  final bool isUpdatingProducts;

  GetProductFetchSuccess copyWith({
    List<Product>? products,
    int? total,
    String? searchQuery,
    int? categoryId,
    bool? isLoading,
    bool? isError,
    // Use a Function that returns an ApiException? to allow passing null
    ApiException? Function()? exception,
    bool? isUpdatingProducts,
  }) {
    return GetProductFetchSuccess(
      products: products ?? this.products,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isUpdatingProducts: isUpdatingProducts ?? this.isUpdatingProducts,
      // Logic: If the function is provided, use it (even if it returns null)
      exception: exception != null ? exception() : this.exception,
    );
  }

  @override
  List<Object?> get props => [products, total, searchQuery, categoryId, isLoading, isError, exception, isUpdatingProducts];
}

class GetProductFetchFailure extends GetProductState {
  GetProductFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetProductCubit extends Cubit<GetProductState> {
  GetProductCubit() : super(GetProductInitial());
  final ProductRepository _productRepository = ProductRepository();

  Future<void> fetchGetProduct({required int categoryId, String searchQuery = ''}) async {
    emit(GetProductInProgress());

    try {
      final value = await _productRepository.getProducts(categoryId: categoryId, limit: apiCallLimit, searchQuery: searchQuery);

      emit(GetProductFetchSuccess(products: value['products'] as List<Product>, total: value['total'] as int, searchQuery: searchQuery, categoryId: categoryId));
    } catch (e) {
      if (e is ApiException) {
        emit(GetProductFetchFailure(exception: e));
      } else {
        emit(GetProductFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }

  bool isLoading() {
    if (state is GetProductFetchSuccess) {
      final currentState = state as GetProductFetchSuccess;
      return currentState.isLoading || currentState.isUpdatingProducts;
    }
    return false;
  }

  Future<void> fetchMoreProducts() async {
    if (state is GetProductFetchSuccess) {
      final currentState = state as GetProductFetchSuccess;
      if (currentState.isLoading) return;

      if (currentState.isUpdatingProducts) {
        emit(currentState.copyWith(isLoading: false, isError: true, exception: () => const ApiException(errorMessageKey: 'oneProcessAreRunning')));
        return;
      }

      emit(currentState.copyWith(isLoading: true));

      try {
        final value = await _productRepository.getProducts(searchQuery: currentState.searchQuery, limit: apiCallLimit, offset: currentState.products.length, categoryId: currentState.categoryId);
        final newProducts = value['products'] as List<Product>;
        emit(currentState.copyWith(products: [...currentState.products, ...newProducts], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(
            currentState.copyWith(
              isError: true,
              exception: () => e,
            ),
          );
        } else {
          emit(currentState.copyWith(isError: true, exception: () => ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreProducts() {
    if (state is GetProductFetchSuccess) {
      final s = state as GetProductFetchSuccess;
      return s.total > s.products.length;
    }
    return false;
  }

  Future<void> updateProductQuantity({required String productId, required int quantity}) async {
    '$productId, $quantity'.log('updateProductQuantity');
    if (state is GetProductFetchSuccess) {
      final currentState = state as GetProductFetchSuccess;

      if (currentState.isUpdatingProducts) {
        return;
      }
      if (currentState.isLoading) {
        emit(currentState.copyWith(isUpdatingProducts: false, isError: true, exception: () => const ApiException(errorMessageKey: 'oneProcessAreRunning')));
        return;
      }

      emit(currentState.copyWith(isUpdatingProducts: true));

      final index = currentState.products.indexWhere((element) => element.id.toString() == productId);

      final updatedProducts = List<Product>.from(currentState.products);
      if (index != -1) {
        updatedProducts[index] = updatedProducts[index].copyWith(quantity: quantity);
      }
      emit(currentState.copyWith(products: updatedProducts, isUpdatingProducts: false));
    }
  }

  void updateProductQuantityForCart(List<Product> cartProducts) {
    if (state is! GetProductFetchSuccess) return;

    final currentState = state as GetProductFetchSuccess;
    var hasChanged = false;

    final updatedProducts = currentState.products.map((product) {
      final cartProduct = cartProducts.firstWhere((cp) => cp.id == product.id, orElse: () => product);

      final quantity = cartProduct.quantity;

      if (product.quantity != quantity) {
        hasChanged = true;
        return product.copyWith(quantity: quantity);
      }
      return product;
    }).toList();

    if (hasChanged) {
      emit(currentState.copyWith(products: updatedProducts));
    }
  }

  void resetProductsQuantity() {
    final currentState = state;
    if (currentState is GetProductFetchSuccess) {
      // 1. Create a brand new list with quantity 0
      final resetList = currentState.products.map((product) {
        return product.copyWith(quantity: 0);
      }).toList();

      // 2. Emit state with ALL flags reset to false
      emit(
        currentState.copyWith(
          products: resetList,
          isLoading: false, // Reset loading
          isUpdatingProducts: false, // Reset updating flag (CRITICAL)
          isError: false, // Clear previous errors
          exception: () => null, // Clear exception
        ),
      );
    }
  }
}
// import 'package:equatable/equatable.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:omkar_sale/core/api/api_config.dart';
// import 'package:omkar_sale/core/constants/constant.dart';
// import 'package:omkar_sale/features/order/model/category.dart';
// import 'package:omkar_sale/features/order/model/product.dart';
// import 'package:omkar_sale/features/product/repository/product_repository.dart';

// @immutable
// abstract class GetProductState extends Equatable {}

// class GetProductInitial extends GetProductState {
//   @override
//   List<Object?> get props => [];
// }

// class GetProductInProgress extends GetProductState {
//   @override
//   List<Object?> get props => [];
// }

// class GetProductFetchSuccess extends GetProductState {
//   GetProductFetchSuccess({required this.categoryId, required this.searchQuery, required this.total, required this.products, this.isError = false, this.isLoading = false});

//   final List<Product> products;
//   final int total;
//   final String searchQuery;
//   final int categoryId;
//   final bool isLoading;
//   final bool isError;

//   GetProductFetchSuccess copyWith({List<Product>? newProduct, int? newTotal, String? newSearchQuery, bool? newIsLoading, bool? newIsError, int? categoryId}) {
//     return GetProductFetchSuccess(
//       products: newProduct ?? products,
//       total: newTotal ?? total,
//       searchQuery: newSearchQuery ?? searchQuery,
//       isError: newIsError ?? isError,
//       isLoading: newIsLoading ?? isLoading,
//       categoryId: categoryId ?? this.categoryId,
//     );
//   }

//   @override
//   List<Object?> get props => [products, total, searchQuery];
// }

// class GetProductFetchFailure extends GetProductState {
//   GetProductFetchFailure({required this.exception});

//   final ApiException exception;
//   @override
//   List<Object?> get props => [exception];
// }

// class GetProductCubit extends Cubit<GetProductState> {
//   GetProductCubit() : super(GetProductInitial());
//   final ProductRepository _productRepository = ProductRepository();

//   Future<void> fetchGetProduct({required int categoryId, String searchQuery = ''}) async {
//     emit(GetProductInProgress());

//     await Future.delayed(const Duration(seconds: 10));

//     await _productRepository
//         .getProducts(categoryId: categoryId, limit: apiCallLimit, searchQuery: searchQuery)
//         .then((value) {
//           emit(
//             GetProductFetchSuccess(
//               products: value['products'] as List<Product>,
//               total: value['total'] as int,
//               searchQuery: searchQuery,
//               categoryId: categoryId,
//             ),
//           );
//         })
//         .catchError((Object e) {
//           if (e is ApiException) {
//             emit(GetProductFetchFailure(exception: e));
//           } else {
//             emit(GetProductFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
//           }
//         });
//   }

//   bool hasMoreProducts() {
//     if (state is GetProductFetchSuccess) {
//       final currentState = state as GetProductFetchSuccess;
//       return currentState.total > currentState.products.length;
//     }
//     return false;
//   }

//   Future<void> fetchProducts() async {
//     if (state is GetProductFetchSuccess) {
//       final currentState = state as GetProductFetchSuccess;
//       if (currentState.isLoading) {
//         return;
//       }
//       emit(currentState.copyWith(newIsLoading: true));
//       final oldData = currentState.products;
//       await _productRepository
//           .getProducts(searchQuery: currentState.searchQuery, limit: apiCallLimit, offset: oldData.length, categoryId: currentState.categoryId)
//           .then((value) {
//             final newData = oldData..addAll(value['products'] as List<Product>);
//             emit(currentState.copyWith(newProduct: newData, newTotal: value['total'] as int, newIsLoading: false));
//           })
//           .catchError((Object e) {
//             if (e is ApiException) {
//               emit(currentState.copyWith(newIsError: true, newIsLoading: false));
//             } else {
//               emit(currentState.copyWith(newIsError: true, newIsLoading: false));
//             }
//           });
//     }
//   }
// }
