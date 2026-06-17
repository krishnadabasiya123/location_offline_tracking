import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/widgets/customWidget/Custom_marquee_text.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/cubit/order_pdf_cubit.dart';
import 'package:omkar_sale/features/order/model/place_order.dart';
import 'package:share_plus/share_plus.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({required this.order, super.key});
  final PlaceOrderDetails order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final order = routeSettings.arguments! as PlaceOrderDetails;
    return MaterialPageRoute<dynamic>(
      builder: (_) => OrderDetailsScreen(order: order),
      settings: routeSettings,
    );
  }
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // Helper: Mapping Status to AppThemeColors
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppThemeColors.deliveredColor;
      case OrderStatus.pending:
        return AppThemeColors.pendingColor;
      case OrderStatus.approved:
        return AppThemeColors.processingColor;
      case OrderStatus.cancelled:
        return AppThemeColors.cancelledColor;
      case OrderStatus.rejected:
        return AppThemeColors.redColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.order.status);

    return BlocProvider(
      create: (context) => OrderPdfCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<OrderPdfCubit, OrderPdfState>(
            listener: (context, state) {
              if (state is OrderPdfDownloadSuccess) {
                Navigator.pop(context); // Close progress bottomsheet
                if (state.share) {
                  final box = context.findRenderObject() as RenderBox?;
                  Share.shareXFiles(
                    [XFile(state.savePath)],
                    text: 'Order Receipt #${widget.order.id}',
                    sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                  );
                }
              } else if (state is OrderPdfDownloadFailure) {
                Navigator.pop(context); // Close progress bottomsheet
                context.showSnackBar(message: 'Failed: ${state.errorMessage}', backgroundColor: context.colorScheme.error);
              }
            },
            child: Scaffold(
              backgroundColor: context.colorScheme.surface,
              appBar: CustomAppBar(title: 'orderSummaryLbl'.tr(context)),
              body: CustomPaddingWidget.symmetric(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.sp(context)),
                      _buildPriceHero(context, statusColor),
                      SizedBox(height: 10.sp(context)),
                      _buildFullWidthDashboard(context),
                      SizedBox(height: 20.sp(context)),
                      if (widget.order.notes.isNotEmpty) ...[_buildNotesContainer(context), SizedBox(height: 32.sp(context))],
                      _buildSectionHeader(context),
                      SizedBox(height: 10.sp(context)),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.order.items.length,
                        itemBuilder: (context, index) {
                          return _buildTieredProductCard(context, widget.order.items[index]);
                        },
                      ),
                      SizedBox(height: 20.sp(context)),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                padding: EdgeInsets.only(
                  left: 16.sp(context),
                  right: 16.sp(context),
                  top: 12.sp(context),
                  bottom: MediaQuery.of(context).padding.bottom + 12.sp(context),
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomRoundedButtonWidget(
                        text: 'viewInvoiceLbl'.tr(context).isEmpty ? 'View Invoice' : 'viewInvoiceLbl'.tr(context),
                        icon: const Icon(Icons.visibility_rounded),
                        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.1),
                        foregroundColor: context.colorScheme.primary,
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.pdfViewerScreen, arguments: widget.order.id);
                        },
                      ),
                    ),
                    SizedBox(width: 12.sp(context)),
                    Expanded(
                      child: CustomRoundedButtonWidget(
                        text: 'shareLbl'.tr(context).isEmpty ? 'Share' : 'shareLbl'.tr(context),
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {
                          context.read<OrderPdfCubit>().fetchAndHandlePdf(orderId: widget.order.id, share: true);
                          _showDownloadProgressBottomSheet(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDownloadProgressBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp(context)))),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.sp(context)),
            child: BlocBuilder<OrderPdfCubit, OrderPdfState>(
              bloc: context.read<OrderPdfCubit>(),
              builder: (context, state) {
                var progress = 0.0;
                if (state is OrderPdfDownloadInProgress) {
                  progress = state.percentage / 100.0;
                }
                final progressText = '${(progress * 100).toStringAsFixed(0)}%';
                return Column(
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
                    Text(progressText, style: TextStyle(color: context.colorScheme.onSurface)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceHero(BuildContext context, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 25.sp(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(25.sp(context)),
        border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          CustomMarqueeText(
            textAlign: TextAlign.center,
            text: '$currencySymbol ${widget.order.totalAmount}',
            textStyle: TextStyle(fontSize: 30.sp(context), fontWeight: FontWeight.w600, letterSpacing: -1),
          ),
          SizedBox(height: 10.sp(context)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.sp(context), vertical: 6.sp(context)),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100.sp(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3.sp(context), backgroundColor: statusColor),
                SizedBox(width: 8.sp(context)),
                Text(
                  widget.order.status.text.tr(context).toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 12.sp(context), fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthDashboard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(24.sp(context)),
        border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.storefront_rounded, 'shopLbl'.tr(context), widget.order.customer.name),
          _buildDivider(context),
          _buildInfoRow(context, Icons.confirmation_number_outlined, 'orderIdLbl'.tr(context), '#ORD-${widget.order.id}'),
          _buildDivider(context),
          _buildInfoRow(context, Icons.calendar_today_rounded, 'orderDateLbl'.tr(context), widget.order.orderDate),
          _buildDivider(context),
          // --- ADDED EXPECTED DELIVERY DATE ---
          _buildInfoRow(context, Icons.local_shipping_outlined, 'ExpectedDeliveryDateLbl'.tr(context), widget.order.deliveryDate),
          _buildDivider(context),
          _buildInfoRow(context, Icons.payments_outlined, 'paymentTypeLbl'.tr(context), widget.order.paymentMode),
          _buildDivider(context),
          _buildInfoRow(context, Icons.tag, 'tinNumberAvailableLbl'.tr(context), widget.order.tinNumber ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp(context), vertical: 14.sp(context)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.sp(context)),
            decoration: BoxDecoration(color: context.colorScheme.surface, borderRadius: BorderRadius.circular(12.sp(context))),
            child: Icon(icon, size: 20.sp(context), color: context.primaryColor),
          ),
          SizedBox(width: 16.sp(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp(context), color: AppThemeColors.darkGreyColor, fontWeight: FontWeight.w600),
                ),
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.primaryColor.withValues(alpha: 0.08), context.primaryColor.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(16.sp(context)),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.sp(context)),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5.sp(context),
                decoration: BoxDecoration(color: context.primaryColor),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.sp(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.sp(context)),
                    decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.auto_awesome_rounded, color: context.primaryColor, size: 18.sp(context)),
                  ),
                  SizedBox(width: 14.sp(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'notesLbl'.tr(context).toUpperCase(),
                          style: TextStyle(fontSize: 11.sp(context), fontWeight: FontWeight.w900, color: context.primaryColor, letterSpacing: 1),
                        ),
                        SizedBox(height: 6.sp(context)),
                        Text(
                          widget.order.notes,
                          style: TextStyle(fontSize: 14.sp(context), height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTieredProductCard(BuildContext context, Product product) {
    final qty = product.quantity;
    final unitPrice = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
    final totalPrice = unitPrice * qty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16.sp(context)),
        border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.sp(context)),
            child: Row(
              children: [
                Container(
                  height: 40.sp(context),
                  width: 40.sp(context),
                  decoration: BoxDecoration(color: context.colorScheme.surface, borderRadius: BorderRadius.circular(10.sp(context))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.sp(context)),
                    child: CustomImageWidget(imagePath: product.image),
                  ),
                ),
                SizedBox(width: 12.sp(context)),
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp(context)),
            child: Divider(height: 1, thickness: 1, color: context.colorScheme.onSurface.withValues(alpha: 0.03)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp(context), vertical: 8.sp(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'unitPriceLbl'.tr(context),
                  style: TextStyle(fontSize: 13.sp(context), color: AppThemeColors.darkGreyColor, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text('$currencySymbol ${unitPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.5.sp(context))),
                    Text(
                      '  ×  ',
                      style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.w500, fontSize: 11.sp(context)),
                    ),
                    Text(
                      '$qty',
                      style: TextStyle(fontSize: 12.5.sp(context), fontWeight: FontWeight.w900, color: context.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp(context), vertical: 10.sp(context)),
            decoration: BoxDecoration(
              color: context.colorScheme.secondary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.sp(context))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'totalLbl'.tr(context).toUpperCase(),
                  style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.w600, color: context.primaryColor, letterSpacing: 0.5),
                ),
                Text(
                  '$currencySymbol ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w600, color: context.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.sp(context),
          height: 18.sp(context),
          decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(10)),
        ),
        SizedBox(width: 10.sp(context)),
        Text(
          'purchasedItemsLbl'.tr(context),
          style: TextStyle(fontSize: 18.sp(context), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
      child: Divider(height: 1, thickness: 1, color: context.colorScheme.onSurface.withValues(alpha: 0.03)),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';
// import 'package:omkar_sale/features/order/model/place_order.dart';

// class OrderDetailsScreen extends StatefulWidget {
//   const OrderDetailsScreen({required this.order, super.key});
//   final PlaceOrderDetails order;

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   // Mapping your Status colors
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.completed:
//         return AppThemeColors.deliveredColor;
//       case OrderStatus.pending:
//         return AppThemeColors.pendingColor;
//       case OrderStatus.approved:
//         return AppThemeColors.processingColor;
//       case OrderStatus.cancelled:
//         return AppThemeColors.cancelledColor;
//       case OrderStatus.rejected:
//         return AppThemeColors.redColor;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(widget.order.status);

//     return Scaffold(
//       backgroundColor: context.colorScheme.surface,

//       appBar: CustomAppBar(
//         title: 'orderSummaryLbl'.tr(context),
//       ),
//       // appBar: AppBar(
//       //   backgroundColor: Colors.transparent,
//       //   elevation: 0,
//       //   leading: IconButton(
//       //     onPressed: () => Navigator.pop(context),
//       //     icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp(context)),
//       //   ),
//       //   centerTitle: true,
//       //   title: Text(
//       //     'orderSummaryLbl'.tr(context).toUpperCase(),
//       //     style: TextStyle(
//       //       fontSize: 12.sp(context),
//       //       fontWeight: FontWeight.w800,
//       //       letterSpacing: 2,
//       //       color: context.colorScheme.onSurface.withValues(alpha: 0.4),
//       //     ),
//       //   ),
//       // ),
//       body: CustomPaddingWidget.symmetric(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           // padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
//           child: Column(
//             children: [
//               SizedBox(height: 10.sp(context)),

//               // --- 1. PRICE & STATUS HERO ---
//               _buildPriceHero(context, statusColor),

//               SizedBox(height: 24.sp(context)),

//               // --- 2. FULL WIDTH DASHBOARD ---
//               _buildFullWidthDashboard(context),

//               SizedBox(height: 24.sp(context)),

//               // --- 3. NOTES (IF APPLICABLE) ---
//               if (widget.order.notes.isNotEmpty) _buildNotesContainer(context),

//               SizedBox(height: 32.sp(context)),

//               // --- 4. ITEM LIST HEADER ---
//               Row(
//                 children: [
//                   Container(
//                     width: 4.sp(context),
//                     height: 18.sp(context),
//                     decoration: BoxDecoration(
//                       color: context.primaryColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   SizedBox(width: 10.sp(context)),
//                   Text(
//                     'purchasedItemsLbl'.tr(context),
//                     style: TextStyle(fontSize: 18.sp(context), fontWeight: FontWeight.w900),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '${widget.order.items.length}',
//                     style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryColor),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20.sp(context)),

//               // --- 5. PRODUCTS ---
//               ...widget.order.items.map((item) => _buildModernProductCard(context, item)),

//               SizedBox(height: 50.sp(context)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceHero(BuildContext context, Color statusColor) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 20.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary,
//         borderRadius: BorderRadius.circular(25.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
//       ),
//       child: Column(
//         children: [
//           Text(
//             '$currencySymbol ${widget.order.totalAmount}',
//             style: TextStyle(fontSize: 35.sp(context), fontWeight: FontWeight.w900, letterSpacing: -1.5),
//           ),
//           SizedBox(height: 8.sp(context)),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 14.sp(context), vertical: 6.sp(context)),
//             decoration: BoxDecoration(
//               color: statusColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(100.sp(context)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(radius: 3.sp(context), backgroundColor: statusColor),
//                 SizedBox(width: 8.sp(context)),
//                 Text(
//                   widget.order.status.text.tr(context).toUpperCase(),
//                   style: TextStyle(color: statusColor, fontSize: 13.sp(context), fontWeight: FontWeight.w900, letterSpacing: 1),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFullWidthDashboard(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary,
//         borderRadius: BorderRadius.circular(24.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
//       ),
//       child: Column(
//         children: [
//           _buildInfoRow(context, Icons.storefront_rounded, 'shopLbl'.tr(context), widget.order.customer.name),
//           _buildDivider(context),
//           _buildInfoRow(context, Icons.confirmation_number_outlined, 'orderIdLbl'.tr(context), '#ORD-${widget.order.id}'),
//           _buildDivider(context),
//           _buildInfoRow(context, Icons.calendar_today_rounded, 'orderDateLbl'.tr(context), widget.order.orderDate),
//           _buildDivider(context),
//           _buildInfoRow(context, Icons.payments_outlined, 'paymentTypeLbl'.tr(context), widget.order.paymentMode),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     BuildContext context,
//     IconData icon,
//     String label,
//     String value,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.sp(context), vertical: 18.sp(context)),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10.sp(context)),
//             decoration: BoxDecoration(
//               color: context.colorScheme.surface, // Background of the icon uses the scaffold color
//               borderRadius: BorderRadius.circular(12.sp(context)),
//             ),
//             child: Icon(icon, size: 20.sp(context), color: context.primaryColor),
//           ),
//           SizedBox(width: 16.sp(context)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 11.sp(context), color: AppThemeColors.darkGreyColor, fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(height: 2.sp(context)),
//                 Text(
//                   value,
//                   style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
//       child: Divider(height: 1, thickness: 1, color: context.colorScheme.onSurface.withValues(alpha: 0.03)),
//     );
//   }

//   Widget _buildNotesContainer(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         // Modern Gradient Background
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             context.primaryColor.withValues(alpha: 0.08), // Slightly stronger at the start
//             context.primaryColor.withValues(alpha: 0.02), // Fades out
//           ],
//         ),
//         borderRadius: BorderRadius.circular(10.sp(context)),
//         // Subtle glow/border
//         border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10.sp(context)),
//         child: Stack(
//           children: [
//             // --- ACCENT STRIP ---
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 width: 5.sp(context),
//                 decoration: BoxDecoration(color: context.primaryColor),
//               ),
//             ),

//             // --- CONTENT ---
//             Padding(
//               padding: EdgeInsets.all(20.sp(context)),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Icon in a circular glass container
//                   Container(
//                     padding: EdgeInsets.all(8.sp(context)),
//                     decoration: BoxDecoration(
//                       color: context.primaryColor.withValues(alpha: 0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.auto_awesome_rounded, color: context.primaryColor, size: 18.sp(context)),
//                   ),
//                   SizedBox(width: 14.sp(context)),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'notesLbl'.tr(context).toUpperCase(),
//                           style: TextStyle(
//                             fontSize: 11.sp(context),
//                             fontWeight: FontWeight.w900,
//                             color: context.primaryColor,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                         SizedBox(height: 6.sp(context)),
//                         Text(
//                           widget.order.notes,
//                           style: TextStyle(
//                             fontSize: 14.sp(context),
//                             height: 1.5,
//                             fontWeight: FontWeight.w500,
//                             // Slightly dynamic text color based on background
//                             color: context.colorScheme.onSurface.withValues(alpha: 0.9),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernProductCard(BuildContext context, Product product) {
//     // Math Logic
//     const qty = 1;
//     final singlePrice = double.tryParse(product.price.replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0;
//     final totalItemPrice = singlePrice * qty;

//     return Container(
//       margin: EdgeInsets.only(bottom: 16.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary,
//         borderRadius: BorderRadius.circular(24.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.06)),
//       ),
//       child: Column(
//         children: [
//           // --- ROW 1: TITLE & IMAGE ---
//           Padding(
//             padding: EdgeInsets.all(14.sp(context)),
//             child: Row(
//               children: [
//                 Container(
//                   height: 50.sp(context),
//                   width: 50.sp(context),
//                   decoration: BoxDecoration(
//                     color: context.colorScheme.surface,
//                     borderRadius: BorderRadius.circular(12.sp(context)),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12.sp(context)),
//                     child: CustomImageWidget(imagePath: product.image),
//                   ),
//                 ),
//                 SizedBox(width: 14.sp(context)),
//                 Expanded(
//                   child: Text(
//                     product.name,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       fontSize: 16.sp(context),
//                       color: context.colorScheme.onSurface,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // --- SUBTLE DIVIDER ---
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 14.sp(context)),
//             child: Divider(height: 1, thickness: 1, color: context.colorScheme.onSurface.withValues(alpha: 0.03)),
//           ),

//           // --- ROW 2: SINGLE ITEM PRICE & QTY ---
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 14.sp(context), vertical: 12.sp(context)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'unitPriceLbl'.tr(context),
//                   style: TextStyle(fontSize: 12.sp(context), color: AppThemeColors.darkGreyColor, fontWeight: FontWeight.w500),
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       '$currencySymbol ${singlePrice.toStringAsFixed(2)}',
//                       style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '  ×  ',
//                       style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '$qty',
//                       style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.w900, color: context.primaryColor),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // --- ROW 3: TOTAL PRICE (ACCENT BAR) ---
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 14.sp(context), vertical: 12.sp(context)),
//             decoration: BoxDecoration(
//               color: context.primaryColor.withValues(alpha: 0.04), // Soft Blue tint
//               borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.sp(context))),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'totalLbl'.tr(context).toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 11.sp(context),
//                     fontWeight: FontWeight.w900,
//                     color: context.primaryColor,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 Text(
//                   '$currencySymbol ${totalItemPrice.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 18.sp(context),
//                     fontWeight: FontWeight.w900,
//                     color: context.primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';
// import 'package:omkar_sale/features/order/model/place_order.dart';

// class OrderDetailsScreen extends StatelessWidget {
//   const OrderDetailsScreen({required this.order, super.key});
//   final PlaceOrderDetails order;

//   // Helper to map OrderStatus to your AppThemeColors
//   Color _getStatusColor(OrderStatus status) {
//     switch (status) {
//       case OrderStatus.completed:
//         return AppThemeColors.deliveredColor;
//       case OrderStatus.pending:
//         return AppThemeColors.pendingColor;
//       case OrderStatus.approved:
//         return AppThemeColors.processingColor;
//       case OrderStatus.cancelled:
//         return AppThemeColors.cancelledColor;
//       case OrderStatus.rejected:
//         return AppThemeColors.redColor;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(order.status);

//     return Scaffold(
//       backgroundColor: context.colorScheme.surface,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp(context)),
//         ),
//         centerTitle: true,
//         title: Text(
//           'orderDetailsLbl'.tr(context).toUpperCase(),
//           style: TextStyle(
//             fontSize: 13.sp(context),
//             fontWeight: FontWeight.w800,
//             letterSpacing: 2,
//             color: context.colorScheme.onSurface.withValues(alpha: 0.5),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10.sp(context)),

//             // --- HERO SECTION: PRICE & STATUS ---
//             _buildPriceHero(context, statusColor),

//             SizedBox(height: 30.sp(context)),

//             // --- DASHBOARD TILES (2x2 Grid) ---
//             _buildInfoDashboard(context),

//             SizedBox(height: 30.sp(context)),

//             // --- NOTES SECTION (COOL ACCENT STYLE) ---
//             if (order.notes.isNotEmpty) _buildNotesContainer(context),

//             SizedBox(height: 35.sp(context)),

//             // --- PRODUCT LIST ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'purchasedItemsLbl'.tr(context),
//                   style: TextStyle(fontSize: 18.sp(context), fontWeight: FontWeight.w900, letterSpacing: -0.5),
//                 ),
//                 Text(
//                   '${order.items.length} Items',
//                   style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.bold, color: context.primaryColor),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20.sp(context)),
//             ...order.items.map((item) => _buildModernProductCard(context, item)),

//             SizedBox(height: 100.sp(context)), // Bottom Padding
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceHero(BuildContext context, Color statusColor) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary, // white or navy-slate
//         borderRadius: BorderRadius.circular(24.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.sp(context), vertical: 6.sp(context)),
//             decoration: BoxDecoration(
//               color: statusColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(radius: 4, backgroundColor: statusColor),
//                 SizedBox(width: 8.sp(context)),
//                 Text(
//                   order.status.text.tr(context).toUpperCase(),
//                   style: TextStyle(color: statusColor, fontSize: 11.sp(context), fontWeight: FontWeight.w900, letterSpacing: 1),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16.sp(context)),
//           Text(
//             order.totalAmount,
//             style: TextStyle(fontSize: 42.sp(context), fontWeight: FontWeight.w900, letterSpacing: -1.5),
//           ),
//           Text(
//             'totalOrderValueLbl'.tr(context),
//             style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoDashboard(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 2.2,
//       mainAxisSpacing: 12.sp(context),
//       crossAxisSpacing: 12.sp(context),
//       children: [
//         _buildInfoTile(context, Icons.storefront_rounded, 'shopLbl'.tr(context), order.customer.name),
//         _buildInfoTile(context, Icons.confirmation_number_outlined, 'idLbl'.tr(context), '#ORD-${order.id}'),
//         _buildInfoTile(context, Icons.calendar_today_rounded, 'dateLbl'.tr(context), order.orderDate),
//         _buildInfoTile(context, Icons.wallet_rounded, 'paymentLbl'.tr(context), order.paymentMode),
//       ],
//     );
//   }

//   Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
//     return Container(
//       padding: EdgeInsets.all(12.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(16.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.sp(context)),
//             decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, size: 16.sp(context), color: context.primaryColor),
//           ),
//           SizedBox(width: 12.sp(context)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 10.sp(context), color: AppThemeColors.darkGreyColor, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.bold),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotesContainer(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(18.sp(context)),
//       decoration: BoxDecoration(
//         color: context.primaryColor.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(20.sp(context)),
//         border: Border.all(color: context.primaryColor.withValues(alpha: 0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.notes_rounded, size: 18.sp(context), color: context.primaryColor),
//               SizedBox(width: 8.sp(context)),
//               Text(
//                 'notesLbl'.tr(context).toUpperCase(),
//                 style: TextStyle(fontSize: 11.sp(context), fontWeight: FontWeight.w900, color: context.primaryColor, letterSpacing: 1),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.sp(context)),
//           Text(
//             order.notes,
//             style: TextStyle(fontSize: 14.sp(context), height: 1.5, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernProductCard(BuildContext context, Product product) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.sp(context)),
//       padding: EdgeInsets.all(12.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.secondary,
//         borderRadius: BorderRadius.circular(20.sp(context)),
//         border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
//       ),
//       child: Row(
//         children: [
//           // REDESIGNED PRODUCT IMAGE BACKGROUND
//           Stack(
//             children: [
//               Container(
//                 height: 75.sp(context),
//                 width: 75.sp(context),
//                 decoration: BoxDecoration(
//                   color: context.colorScheme.surface, // Background of image matches scaffold
//                   borderRadius: BorderRadius.circular(16.sp(context)),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16.sp(context)),
//                   child: CustomImageWidget(imagePath: product.image),
//                 ),
//               ),
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(6)),
//                   child: Text(
//                     'x1',
//                     style: TextStyle(color: Colors.white, fontSize: 10.sp(context), fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 16.sp(context)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp(context)),
//                 ),
//                 SizedBox(height: 4.sp(context)),
//                 Text(
//                   '${'unitPriceLbl'.tr(context)}: ${product.price}',
//                   style: TextStyle(fontSize: 12.sp(context), color: AppThemeColors.darkGreyColor),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             product.price,
//             style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17.sp(context), color: context.primaryColor),
//           ),
//         ],
//       ),
//     );
//   }
// }
