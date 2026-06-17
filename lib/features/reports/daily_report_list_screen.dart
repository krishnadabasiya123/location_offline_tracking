import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/cubit/set_daily_report_cubit.dart';

class DailyReportListScreen extends StatefulWidget {
  const DailyReportListScreen({super.key});

  @override
  State<DailyReportListScreen> createState() => _DailyReportListScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => SetDailyReportCubit(),
        child: const DailyReportListScreen(),
      ),
    );
  }
}

class _DailyReportListScreenState extends State<DailyReportListScreen> {
  final ValueNotifier<List<Map<String, dynamic>>> _reportsNotifier = ValueNotifier([]);

  @override
  void dispose() {
    _reportsNotifier.dispose();
    super.dispose();
  }

  Widget _buildReportCard(Map<String, dynamic> report, int index) {
    final images = report['images'] as List<File>;
    final shopName = report['shopName'] as String;
    final purpose = report['purpose'] as String;
    final remarks = report['remarks'] as String;
    final timestamp = report['timestamp'] as DateTime;

    return Container(
      margin: EdgeInsets.only(bottom: 16.sp(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.sp(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.sp(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Delete Option
            Padding(
              padding: EdgeInsets.all(16.sp(context)),
              child: Row(
                children: [
                  Container(
                    height: 40.sp(context),
                    width: 40.sp(context),
                    decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.sp(context))),
                    child: Icon(Icons.storefront_rounded, color: context.primaryColor, size: 24.sp(context)),
                  ),
                  SizedBox(width: 12.sp(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Purpose: $purpose',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13.sp(context)),
                        ),
                        Text(
                          "${timestamp.day}/${timestamp.month}/${timestamp.year} • ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12.sp(context)),
                        ),
                      ],
                    ),
                  ),
                  _buildPopupMenu(index, report),
                ],
              ),
            ),

            if (remarks.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp(context)),
                child: Text(
                  remarks,
                  style: TextStyle(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14.sp(context),
                    height: 1.4,
                  ),
                ),
              ),

            if (images.isNotEmpty) ...[
              SizedBox(height: 16.sp(context)),
              SizedBox(
                height: 100.sp(context),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.sp(context)),
                  itemCount: images.length,
                  itemBuilder: (context, imgIndex) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.sp(context)),
                      child: CustomImageWidget(
                        imagePath: images[imgIndex].path,
                        borderRadius: 12.sp(context),
                        border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.3), width: 1.sp(context)),
                      ),
                    );

                    // return Container(
                    //   width: 100.sp(context),
                    //   margin: EdgeInsets.only(right: 12.sp(context)),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(12.sp(context)),
                    //     image: DecorationImage(
                    //       image: FileImage(images[imgIndex]),
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    // );
                  },
                ),
              ),
            ],
            SizedBox(height: 16.sp(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(int index, Map<String, dynamic> report) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (context.read<SetDailyReportCubit>().state is! SetDailyReportInProgress) {
          if (value == 'edit') {
            final result = await Navigator.of(context).pushNamed(
              Routes.submitReportScreen,
              arguments: report,
            );
            if (result != null && result is Map<String, dynamic>) {
              final updatedList = List<Map<String, dynamic>>.from(_reportsNotifier.value);
              updatedList[index] = result;
              _reportsNotifier.value = updatedList;
            }
          } else if (value == 'delete') {
            final updatedList = List<Map<String, dynamic>>.from(_reportsNotifier.value)..removeAt(index);
            _reportsNotifier.value = updatedList;
          }
        }
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(CupertinoIcons.pencil, size: 18, color: context.primaryColor),
              const SizedBox(width: 8),
              Text('editLbl'.tr(context)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, size: 18, color: context.colorScheme.error),
              const SizedBox(width: 8),
              Text('deleteLbl'.tr(context), style: TextStyle(color: context.colorScheme.error)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(8.sp(context)),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20.sp(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.read<SetDailyReportCubit>().state is! SetDailyReportInProgress) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface, // Mostly black in dark mode
        appBar: CustomAppBar(
          title: 'submitDailyReportLbl'.tr(context),
          backgroundColor: context.colorScheme.secondary,
          actions: [
            IconButton(
              onPressed: () async {
                if (context.read<SetDailyReportCubit>().state is! SetDailyReportInProgress) {
                  final result = await Navigator.of(context).pushNamed(Routes.submitReportScreen);
                  if (result != null && result is Map<String, dynamic>) {
                    _reportsNotifier.value = [..._reportsNotifier.value, result];
                  }
                }
              },
              icon: Icon(Icons.add_circle_outline, color: context.primaryColor, size: 28.sp(context)),
            ),
          ],
        ),
        body: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _reportsNotifier,
          builder: (context, reports, child) {
            return reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(32.sp(context)),
                          decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.assignment_add, size: 64.sp(context), color: context.primaryColor),
                        ),
                        SizedBox(height: 24.sp(context)),
                        Text(
                          'noDataFoundTitleLbl'.tr(context),
                          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 20.sp(context), fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.sp(context)),
                        Text(
                          'addDailyReportLbl'.tr(context),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14.sp(context)),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.sp(context)),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _buildReportCard(report, index);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.sp(context), 0, 16.sp(context), MediaQuery.of(context).padding.bottom + 16.sp(context)),
                        child: BlocConsumer<SetDailyReportCubit, SetDailyReportState>(
                          listener: (context, state) {
                            if (state is SetDailyReportSuccess) {
                              context.showSnackBar(message: 'dailyReportSubmittedSuccessfully'.tr(context), backgroundColor: AppThemeColors.greenColor);
                              Navigator.pop(context);
                            }
                            if (state is SetDailyReportFailure) {
                              context.showSnackBar(message: state.exception.errorMessageKey, backgroundColor: context.colorScheme.error);
                            }
                          },
                          builder: (context, state) {
                            return CustomRoundedButtonWidget(
                              isLoading: state is SetDailyReportInProgress,
                              onPressed: () {
                                context.read<SetDailyReportCubit>().setDailyReport(visits: reports);
                              },
                              text: 'saveLbl'.tr(context),
                              textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
