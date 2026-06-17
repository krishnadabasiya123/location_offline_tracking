import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/widgets/customWidget/Custom_marquee_text.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/model/place_order.dart';

// enum OrderHistoryStatus { delivered, pending, cancelled }

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    required this.order,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final VoidCallback onTap;
  final void Function(PlaceOrderDetails)? onDelete;
  final PlaceOrderDetails order;

  @override
  Widget build(BuildContext context) {
    final itemImages = order.items.map((e) => e.image).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.sp(context)),
        padding: EdgeInsets.all(16.sp(context)),
        decoration: BoxDecoration(
          color: context.colorScheme.secondary, // Uses #FFFFFF or #192633
          borderRadius: BorderRadius.circular(12.sp(context)),
          border: Border.all(color: context.colorScheme.surfaceDim.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Status & Time ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(context: context),
                Row(
                  children: [
                    Text(
                      order.orderDate,
                      style: TextStyle(color: context.colorScheme.onSecondary.withValues(alpha: 0.7), fontSize: 12.sp(context), fontWeight: FontWeight.w500),
                    ),
                    if (onDelete != null) ...[
                      SizedBox(width: 5.sp(context)),
                      _buildPopupMenu(context),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.sp(context)),

            // --- BODY: Shop Info & Price ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomMarqueeText(
                        text: order.customer.name,
                        textStyle: TextStyle(color: context.colorScheme.onSurface, fontSize: 16.sp(context), fontWeight: FontWeight.w500, letterSpacing: -0.5),
                      ),
                      SizedBox(height: 2.sp(context)),
                      Text(
                        '#ORD-${order.id}',
                        style: TextStyle(color: context.colorScheme.onSecondary.withValues(alpha: 0.5), fontSize: 13.sp(context), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CustomMarqueeText(
                    text: '$currencySymbol ${order.totalAmount}',
                    textStyle: TextStyle(
                      color: order.status == OrderStatus.cancelled ? context.colorScheme.surfaceDim : context.primaryColor,
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.w500,
                      decoration: order.status == OrderStatus.cancelled ? TextDecoration.lineThrough : null,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            // --- DIVIDER (Only if images exist) ---
            if (itemImages.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sp(context)),
                child: Divider(height: 1, thickness: 1, color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
              ),

              // --- FOOTER: Avatars & Details Link ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAvatarStack(context, itemImages),
                  Row(
                    children: [
                      Text(
                        'viewDetailsLbl'.tr(context),
                        style: TextStyle(color: context.colorScheme.primary, fontSize: 14.sp(context), fontWeight: FontWeight.w500),
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.colorScheme.primary, size: 20.sp(context)),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp(context))),
      color: context.colorScheme.secondary,
      surfaceTintColor: context.colorScheme.secondary,
      icon: Container(
        padding: EdgeInsets.all(6.sp(context)),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_vert_rounded,
          size: 20.sp(context),
          color: context.colorScheme.onSecondary.withValues(alpha: 0.7),
        ),
      ),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete?.call(order);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'delete',
          height: 48.sp(context),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.sp(context)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.sp(context)),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  size: 18.sp(context),
                  color: AppThemeColors.redColor,
                ),
              ),
              SizedBox(width: 12.sp(context)),
              Text(
                'deleteLbl'.tr(context),
                style: TextStyle(
                  color: AppThemeColors.redColor,
                  fontSize: 14.sp(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp(context), vertical: 4.sp(context)),
      decoration: BoxDecoration(color: order.status.color, borderRadius: BorderRadius.circular(4.sp(context))),
      child: Text(
        order.status.text.tr(context).toUpperCase(),
        style: TextStyle(color: context.colorScheme.onPrimary, fontSize: 10.sp(context), fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildAvatarStack(BuildContext context, List<String> images) {
    const maxVisible = 5;
    final displayCount = images.length > maxVisible ? maxVisible : images.length;

    if (displayCount == 0) return const SizedBox.shrink();

    // Define dimensions
    final radius = 12.sp(context);
    final diameter = radius * 2;
    final overlap = 15.sp(context);

    final dynamicWidth = (displayCount - 1) * overlap + diameter;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dynamicWidth + 4.sp(context),
          height: diameter + 4.sp(context),
          child: Stack(
            children: List.generate(
              displayCount,
              (index) => Positioned(
                left: index * overlap,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Dynamic border color based on theme (secondary is the card color)
                    border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.25), width: 0.5.sp(context)),
                  ),
                  child: CustomImageWidget.circular(
                    size: diameter,
                    imagePath: images[index],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (images.length > maxVisible) ...[
          SizedBox(width: 3.sp(context)),
          Text(
            '+${images.length - maxVisible}',
            style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.bold, color: AppThemeColors.darkGreyColor),
          ),
        ],
      ],
    );
  }
}
