import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/repository/shop_repository.dart';

@immutable
abstract class CreateShopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateShopInitial extends CreateShopState {}

class CreateShopInProgress extends CreateShopState {}

class CreateShopSuccess extends CreateShopState {
  CreateShopSuccess({required this.shop});
  final Shop shop;

  @override
  List<Object?> get props => [shop];
}

class CreateShopFailure extends CreateShopState {
  CreateShopFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class CreateShopCubit extends Cubit<CreateShopState> {
  CreateShopCubit() : super(CreateShopInitial());
  final ShopRepository _shopRepository = ShopRepository();

  Future<void> createShop({
    required String shopName,
    required String shopsAddress,
    required String shopCity,
    required String shopContactPerson,
    required String shopPhone,
    required String email,
    String shopLatitude = '',
    String shopLongitude = '',
    String shopTINnumber = '',
  }) async {
    emit(CreateShopInProgress());

    try {
      final value = await _shopRepository.createShop(
        shopTINnumber: shopTINnumber,
        shopName: shopName,
        shopsAddress: shopsAddress,
        shopCity: shopCity,
        shopContactPerson: shopContactPerson,
        shopPhone: shopPhone,
        email: email,
        shopLatitude: shopLatitude,
        shopLongitude: shopLongitude,
      );

      emit(CreateShopSuccess(shop: value));
    } catch (e) {
      if (e is ApiException) {
        emit(CreateShopFailure(exception: e));
      } else {
        emit(CreateShopFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
