import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/cubit/notification_cubit.dart';
import 'package:omkar_sale/features/setting/model/notification.dart';
import 'package:omkar_sale/features/setting/widget/notification_card_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
  static Route<dynamic> route(RouteSettings settings) => CupertinoPageRoute(
    builder: (_) => BlocProvider(
      create: (context) => GetNotificationCubit(),
      child: const NotificationScreen(),
    ),
  );
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(fetchNotifications);
  }

  void fetchNotifications() {
    context.read<GetNotificationCubit>().fetchGetNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notification'),
      body: CustomPaddingWidget.symmetric(
        fixedVerticalPadding: 10.sp(context),
        child: BlocBuilder<GetNotificationCubit, GetNotificationState>(
          builder: (context, state) {
            if (state is GetNotificationFetchFailure) {
              return CustomErrorWidget(title: state.exception.errorMessageKey, errorType: state.exception.type, onRetry: () => context.read<GetNotificationCubit>().fetchGetNotification());
            }

            if (state is GetNotificationFetchSuccess) {
              if (state.notifications.isEmpty) {
                return CustomErrorWidget(title: 'noNotificationFoundLbl'.tr(context), errorType: CustomErrorType.noDataFound);
              }

              return PaginatedBlocListView<AppNotification>(
                items: state.notifications,
                isLoading: state.isLoading,
                isInitialLoad: false,
                hasMore: context.read<GetNotificationCubit>().hasMoreNotifications(),
                onLoadMore: context.read<GetNotificationCubit>().fetchMoreNotifications,
                itemBuilder: (context, item) {
                  return NotificationCard(notification: item);
                },
              );

              // NotificationCard();
            }
            return const Center(child: CustomCircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
