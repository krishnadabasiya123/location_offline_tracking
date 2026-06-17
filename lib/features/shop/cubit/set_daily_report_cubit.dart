import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/repository/shop_repository.dart';

@immutable
abstract class SetDailyReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetDailyReportInitial extends SetDailyReportState {}

class SetDailyReportInProgress extends SetDailyReportState {}

class SetDailyReportSuccess extends SetDailyReportState {
  SetDailyReportSuccess();

  @override
  List<Object?> get props => [];
}

class SetDailyReportFailure extends SetDailyReportState {
  SetDailyReportFailure({required this.exception});
  final ApiException exception;

  @override
  List<Object?> get props => [exception];
}

class SetDailyReportCubit extends Cubit<SetDailyReportState> {
  SetDailyReportCubit() : super(SetDailyReportInitial());
  final ShopRepository _shopRepository = ShopRepository();

  Future<void> setDailyReport({
    required List<Map<String, dynamic>> visits,
  }) async {
    emit(SetDailyReportInProgress());

    try {
      await _shopRepository.submitDailyReport(visits: visits);
      emit(SetDailyReportSuccess());
    } catch (e) {
      if (e is ApiException) {
        emit(SetDailyReportFailure(exception: e));
      } else {
        emit(SetDailyReportFailure(exception: ApiException(errorMessageKey: e.toString())));
      }
    }
  }
}
