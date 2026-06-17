import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:path_provider/path_provider.dart';

abstract class OrderPdfState {}

class OrderPdfInitial extends OrderPdfState {}

class OrderPdfDownloadInProgress extends OrderPdfState {
  OrderPdfDownloadInProgress({this.percentage = 0.0});
  final double percentage;
}

class OrderPdfDownloadSuccess extends OrderPdfState {
  OrderPdfDownloadSuccess({required this.savePath, required this.share});
  final String savePath;
  final bool share;
}

class OrderPdfDownloadFailure extends OrderPdfState {
  OrderPdfDownloadFailure(this.errorMessage);
  final String errorMessage;
}

class OrderPdfCubit extends Cubit<OrderPdfState> {
  OrderPdfCubit() : super(OrderPdfInitial());

  Future<void> fetchAndHandlePdf({
    required int orderId,
    required bool share,
  }) async {
    try {
      emit(OrderPdfDownloadInProgress());

      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/order_$orderId.pdf';
      final url = '$orderPdfUrl?id=$orderId';

      await Api.instance.download(
        url: url,
        cancelToken: CancelToken(),
        savePath: savePath,
        useAuthToken: true,
        updateDownloadedPercentage: (p) {
          emit(OrderPdfDownloadInProgress(percentage: p));
        },
      );

      emit(OrderPdfDownloadSuccess(savePath: savePath, share: share));
    } catch (e, st) {
      if (e is ApiException) {
        emit(OrderPdfDownloadFailure(e.errorMessageKey));
      } else {
        emit(OrderPdfDownloadFailure(e.toString()));
      }
    }
  }
}
