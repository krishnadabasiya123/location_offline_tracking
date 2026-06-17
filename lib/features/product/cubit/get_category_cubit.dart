import 'package:omkar_sale/core/app/all_import_file.dart';

@immutable
abstract class GetCategoryState extends Equatable {}

class GetCategoryInitial extends GetCategoryState {
  @override
  List<Object?> get props => [];
}

class GetCategoryInProgress extends GetCategoryState {
  @override
  List<Object?> get props => [];
}

class GetCategoryFetchSuccess extends GetCategoryState {
  GetCategoryFetchSuccess({required this.categories});

  final List<ProductCategory> categories;

  GetCategoryFetchSuccess copyWith({List<ProductCategory>? newGetCategory}) {
    return GetCategoryFetchSuccess(categories: newGetCategory ?? categories);
  }

  @override
  List<Object?> get props => [categories];
}

class GetCategoryFetchFailure extends GetCategoryState {
  GetCategoryFetchFailure({required this.exception});

  final ApiException exception;
  @override
  List<Object?> get props => [exception];
}

class GetCategoryCubit extends Cubit<GetCategoryState> {
  GetCategoryCubit() : super(GetCategoryInitial());
  final ProductRepository _productRepository = ProductRepository();

  Future<void> fetchGetCategory() async {
    emit(GetCategoryInProgress());

    await Future.delayed(const Duration(seconds: 1));

    await _productRepository
        .getCategories()
        .then((value) {
          if (value.isEmpty) {
            emit(GetCategoryFetchSuccess(categories: const []));
          } else {
            const allCategories = ProductCategory(id: -1, name: 'All', description: 'description');

            emit(GetCategoryFetchSuccess(categories: [allCategories, ...value]));
          }
        })
        .catchError((Object e) {
          if (e is ApiException) {
            emit(GetCategoryFetchFailure(exception: e));
          } else {
            emit(GetCategoryFetchFailure(exception: ApiException(errorMessageKey: e.toString())));
          }
        });
  }
}
