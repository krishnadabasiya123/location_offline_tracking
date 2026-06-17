import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/cubit/order_pdf_cubit.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({required this.orderId, super.key});

  final int orderId;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final orderId = routeSettings.arguments! as int;
    return CupertinoPageRoute<dynamic>(
      builder: (_) => PdfViewerScreen(orderId: orderId),
      settings: routeSettings,
    );
  }
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final OrderPdfCubit _pdfCubit = OrderPdfCubit();
  String? _localPdfPath;

  @override
  void initState() {
    super.initState();
    // Kick off the download immediately so it can be viewed
    _pdfCubit.fetchAndHandlePdf(orderId: widget.orderId, share: false);
  }

  @override
  void dispose() {
    _pdfCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _pdfCubit,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'orderReceiptLbl'.tr(context),
          actions: [
            SizedBox(width: 8.sp(context)),
          ],
        ),
        body: BlocConsumer<OrderPdfCubit, OrderPdfState>(
          listener: (context, state) {
            if (state is OrderPdfDownloadSuccess) {
              setState(() {
                _localPdfPath = state.savePath; // Save the path for the sharing action or viewing
              });
            } else if (state is OrderPdfDownloadFailure) {
              context.showSnackBar(message: 'Failed: ${state.errorMessage}', backgroundColor: context.colorScheme.error);
            }
          },
          builder: (context, state) {
            if (state is OrderPdfDownloadInProgress || state is OrderPdfInitial) {
              var progress = 0.0;
              if (state is OrderPdfDownloadInProgress) {
                progress = state.percentage / 100.0;
              }
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(40.sp(context)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Preparing File...',
                        style: TextStyle(color: context.colorScheme.onSurface, fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.sp(context)),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.2),
                        color: context.colorScheme.primary,
                      ),
                      SizedBox(height: 10.sp(context)),
                      Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: context.colorScheme.onSurface)),
                    ],
                  ),
                ),
              );
            }

            if (_localPdfPath != null) {
              // PDF successfully downloaded and can be presented!
              return PDFView(
                filePath: _localPdfPath,
                onError: print,
                onPageError: (page, error) {
                  print(r'$page: ${error.toString()}');
                },
              );
            }

            // Failure or Fallback State
            return Center(
              child: CustomRoundedButtonWidget(
                text: 'Retry',
                onPressed: () => _pdfCubit.fetchAndHandlePdf(orderId: widget.orderId, share: false),
                width: 150.sp(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
