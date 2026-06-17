import 'package:flutter/widgets.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/model/notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({required this.notification, super.key});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.sp(context)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.sp(context)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSecondary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.sp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.title,
            style: TextStyle(fontSize: 16.5.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.onSecondary, fontStyle: GoogleFonts.robotoMono().fontStyle),
          ),
          Text(
            notification.message,
            style: TextStyle(fontSize: 14.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.8)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.sp(context)),
            child: Text(
              notification.timeAgoDisplay,
              style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
