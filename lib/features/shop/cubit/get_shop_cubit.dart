import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/repository/shop_repository.dart';

@immutable
abstract class GetShopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetShopInitial extends GetShopState {}

class GetShopInProgress extends GetShopState {}

class GetShopFetchSuccess extends GetShopState {
  GetShopFetchSuccess({
    required this.shops,
    required this.total,
    required this.searchQuery,
    this.isError = false,
    this.isLoading = false,
    this.exception,
  });
  final List<Shop> shops;
  final int total;
  final String searchQuery;
  final bool isLoading;
  final bool isError;
  final ApiException? exception;

  GetShopFetchSuccess copyWith({
    List<Shop>? newShops,
    int? total,
    String? searchQuery,

    bool? isLoading,
    bool? isError,
    ApiException? exception,
  }) {
    return GetShopFetchSuccess(
      shops: newShops ?? shops,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      exception: exception ?? this.exception,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [shops, total, searchQuery, isLoading, isError, exception];
}

class GetShopFetchFailure extends GetShopState {
  GetShopFetchFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class GetShopCubit extends Cubit<GetShopState> {
  GetShopCubit() : super(GetShopInitial());
  final ShopRepository _shopRepository = ShopRepository();

  Future<void> fetchGetShop({String searchQuery = '', bool forceRefresh = false}) async {
    if (state is GetShopInProgress) return;

    if (!forceRefresh && state is GetShopFetchSuccess && (state as GetShopFetchSuccess).searchQuery == searchQuery) {
      return;
    }
    emit(GetShopInProgress());

    try {
      final value = await _shopRepository.getShops(limit: apiCallLimit, searchQuery: searchQuery);
      emit(
        GetShopFetchSuccess(
          shops: value['shops'] as List<Shop>,
          total: value['total'] as int,
          searchQuery: searchQuery,
        ),
      );
    } catch (e) {
      if (e is ApiException) {
        emit(GetShopFetchFailure(exception: e));
      } else {
        emit(GetShopFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }

  Future<void> fetchMoreShops() async {
    if (state is GetShopFetchSuccess) {
      final currentState = state as GetShopFetchSuccess;
      if (currentState.isLoading) return;
      emit(currentState.copyWith(isLoading: true, isError: false));
      try {
        final value = await _shopRepository.getShops(
          searchQuery: currentState.searchQuery,
          limit: apiCallLimit,
          offset: currentState.shops.length,
        );
        final newShops = value['shops'] as List<Shop>;
        emit(currentState.copyWith(newShops: [...currentState.shops, ...newShops], total: value['total'] as int, isLoading: false));
      } catch (e) {
        if (e is ApiException) {
          emit(currentState.copyWith(isError: true, exception: e));
        } else {
          emit(currentState.copyWith(isError: true, exception: ApiException(errorMessageKey: e.toString())));
        }
      }
    }
  }

  bool hasMoreShops() {
    if (state is GetShopFetchSuccess) {
      final s = state as GetShopFetchSuccess;
      return s.total > s.shops.length;
    }
    return false;
  }

  void addShop(Shop shop) {
    if (state is GetShopFetchSuccess) {
      final currentState = state as GetShopFetchSuccess;
      emit(currentState.copyWith(newShops: [shop, ...currentState.shops]));
    }
  }
}
