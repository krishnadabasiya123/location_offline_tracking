import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/widgets/customWidget/Custom_marquee_text.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ProductDetailsCard extends StatelessWidget {
  const ProductDetailsCard({
    required this.onTapQuantity,
    required this.product,
    super.key,
  });

  final Product product;
  final VoidCallback onTapQuantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.sp(context)),
      height: context.screenHeight * 0.12,
      constraints: const BoxConstraints(minHeight: 110),
      padding: EdgeInsets.all(8.sp(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.sp(context)),
        color: context.colorScheme.secondary,
      ),
      child: Row(
        children: [
          CustomImageWidget(
            imagePath: product.image,
            height: 90.sp(context),
            width: 90.sp(context),
            border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
            borderRadius: 10.sp(context),
          ),
          SizedBox(width: 12.sp(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.category.name,
                      style: TextStyle(fontSize: 13.sp(context), color: context.colorScheme.primary),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomMarqueeText(
                        text: '$currencySymbol ${product.price}',
                        textStyle: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500),

                        width: 100.sp(context),
                      ),
                      // child: Text(
                      //   '$currencySymbol ${product.price}',
                      //   style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500),
                      // ),
                    ),

                    // --- QUANTITY BADGE BUTTON ---
                    Expanded(
                      child: GestureDetector(
                        onTap: onTapQuantity,
                        child: Container(
                          height: 30.sp(context),
                          padding: EdgeInsets.symmetric(horizontal: 12.sp(context)),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.sp(context)),
                            border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.2)),
                          ),

                          child: CustomMarqueeTextWithIcon(
                            text: product.quantity == 0 ? 'addItemLbl'.tr(context) : '${'qtyLbl'.tr(context)}: ${product.quantity}',
                            textStyle: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                            width: 100.sp(context),
                            iconData: product.quantity == 0 ? Icons.add : Icons.edit_note,
                            iconSize: 16.sp(context),
                          ), // child: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Icon(product.quantity == 0 ? Icons.add : Icons.edit_note, size: 16.sp(context), color: context.colorScheme.primary),
                          //     SizedBox(width: 4.sp(context)),

                          //     Text(
                          //       product.quantity == 0 ? 'addItemLbl'.tr(context) : '${'qtyLbl'.tr(context)}: ${product.quantity}',
                          //       style: TextStyle(
                          //         color: context.colorScheme.primary,
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 13.sp(context),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showQuantityBottomSheet(
  BuildContext context, {
  required Product product,
  required void Function(int) onUpdate,
}) {
  // Local controller for the sheet
  final qtyController = TextEditingController(text: product.quantity <= 0 ? '' : product.quantity.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Critical for keyboard handling
    backgroundColor: context.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        // Allows the +/- buttons to update the sheet UI
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Moves up with keyboard
              left: 20,
              right: 20,
              top: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20.sp(context)),

                // Product Preview Header
                Row(
                  children: [
                    CustomImageWidget(
                      imagePath: product.image,
                      height: 50.sp(context),
                      width: 50.sp(context),
                      borderRadius: 8.sp(context),
                    ),
                    SizedBox(width: 12.sp(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'updateQuantityLbl'.tr(context),
                            style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500),
                          ),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.sp(context)),

                // Main Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // MINUS BUTTON
                    _buildCircleBtn(context, Icons.remove, () {
                      final current = int.tryParse(qtyController.text) ?? 0;
                      if (current > 0) {
                        setSheetState(() => qtyController.text = (current - 1).toString());
                      }
                    }),

                    SizedBox(width: 25.sp(context)),

                    // QUANTITY INPUT
                    SizedBox(
                      width: 150.sp(context),
                      child: CustomTextField(
                        controller: qtyController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        fontSize: 22.sp(context),
                        hintText: '',
                        borderType: CustomTextFormFieldBorder.outline,
                        borderRadius: 8.sp(context),
                        fillColor: context.colorScheme.secondary,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.sp(context)),
                        autofocus: true,
                        onChanged: (val) => setSheetState(() {}), // Refresh UI on type
                      ),
                    ),

                    SizedBox(width: 25.sp(context)),

                    // PLUS BUTTON
                    _buildCircleBtn(context, Icons.add, () {
                      final current = int.tryParse(qtyController.text) ?? 0;
                      setSheetState(() => qtyController.text = (current + 1).toString());
                    }),
                  ],
                ),

                SizedBox(height: 35.sp(context)),

                // UPDATE BUTTON
                CustomRoundedButtonWidget(
                  onPressed: () {
                    final val = int.tryParse(qtyController.text) ?? 0;
                    onUpdate(val);
                    Navigator.pop(context);
                  },
                  text: 'updateLbl'.tr(context).toUpperCase(),
                  height: 52.sp(context),
                  textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.sp(context)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Small helper for the circular +/- buttons
Widget _buildCircleBtn(BuildContext context, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(50),
    child: Container(
      padding: EdgeInsets.all(12.sp(context)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Icon(icon, color: context.colorScheme.primary, size: 24.sp(context)),
    ),
  );
}
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';

// class ProductDetailsCard extends StatefulWidget {
//   const ProductDetailsCard({
//     required this.decreaseQuantityCallback,
//     required this.increaseQuantityCallback,
//     required this.product,
//     super.key,
//   });

//   final Product product;
//   final VoidCallback increaseQuantityCallback;
//   final VoidCallback decreaseQuantityCallback;

//   @override
//   State<ProductDetailsCard> createState() => _ProductDetailsCardState();
// }

// class _ProductDetailsCardState extends State<ProductDetailsCard> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.product.quantity.toString());
//   }

//   @override
//   void didUpdateWidget(covariant ProductDetailsCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.product.quantity.toString() != _controller.text) {
//       _controller.text = widget.product.quantity.toString();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10.sp(context)),
//       height: context.screenHeight * 0.12,
//       constraints: const BoxConstraints(minHeight: 110),
//       padding: EdgeInsets.all(8.sp(context)),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.sp(context)),
//         color: context.colorScheme.secondary,
//       ),
//       width: double.infinity,
//       child: Row(
//         children: [
//           // Image
//           CustomImageWidget(
//             imagePath: widget.product.image,
//             height: 90.sp(context),
//             width: 90.sp(context),
//             border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
//             borderRadius: 10.sp(context),
//           ),
//           SizedBox(width: 8.sp(context)),
//           // Product Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.product.name,
//                       style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.w300),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       widget.product.category.name,
//                       style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.primary),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '$currencySymbol ${widget.product.price}',
//                       style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w400),
//                     ),

//                     // Quantity Control Box
//                     Container(
//                       height: 32.sp(context),
//                       width: 110.sp(context),
//                       decoration: BoxDecoration(
//                         color: context.primaryColor.withValues(alpha: 0.15),
//                         borderRadius: BorderRadius.circular(8.sp(context)),
//                       ),
//                       child: (widget.product.quantity == 0)
//                           ? GestureDetector(
//                               onTap: widget.increaseQuantityCallback,
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 12.sp(context)),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.add, size: 16.sp(context), color: context.colorScheme.primary),
//                                     Text('addItemLbl'.tr(context), style: TextStyle(color: context.colorScheme.primary)),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           : Row(
//                               children: [
//                                 // DECREASE
//                                 GestureDetector(
//                                   onTap: widget.decreaseQuantityCallback,
//                                   child: Container(
//                                     width: 35.sp(context),
//                                     color: Colors.transparent,
//                                     child: Icon(Icons.remove, color: context.colorScheme.primary, size: 20.sp(context)),
//                                   ),
//                                 ),

//                                 // QTY
//                                 Expanded(
//                                   child: CustomTextField(
//                                     textAlign: TextAlign.center,
//                                     controller: _controller,
//                                     keyboardType: TextInputType.number,
//                                     // textAlign: TextAlign.center, // Note: You might need to add this to your CustomTextField class
//                                     readOnly: true,
//                                     contentPadding: EdgeInsets.zero, // 2. Critical: Remove the default padding
//                                     fillColor: Colors.transparent, // 3. Remove white background
//                                     boxShadow: const [], // 4. Remove default shadows
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.bold,
//                                     textColor: context.colorScheme.primary,
//                                   ),
//                                 ),

//                                 // Text(
//                                 //   '${widget.product.quantity}',
//                                 //   style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.primary),
//                                 // ),

//                                 // INCREASE
//                                 GestureDetector(
//                                   onTap: widget.increaseQuantityCallback,

//                                   child: Container(
//                                     width: 35.sp(context),
//                                     color: Colors.transparent,
//                                     child: Icon(Icons.add, color: context.colorScheme.primary, size: 20.sp(context)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                     ),

//                     //   Container(
//                     //   height: 32.sp(context),
//                     //   decoration: BoxDecoration(
//                     //     color: context.primaryColor.withValues(alpha: 0.15),
//                     //     borderRadius: BorderRadius.circular(8.sp(context)),
//                     //   ),
//                     //   child: (widget.product.quantity == 0)
//                     //       ? GestureDetector(
//                     //           onTap: widget.increaseQuantityCallback,
//                     //           child: Padding(
//                     //             padding: EdgeInsets.symmetric(horizontal: 12.sp(context)),
//                     //             child: Row(
//                     //               children: [
//                     //                 Icon(Icons.add, size: 16.sp(context), color: context.colorScheme.primary),
//                     //                 Text('addItemLbl'.tr(context), style: TextStyle(color: context.colorScheme.primary)),
//                     //               ],
//                     //             ),
//                     //           ),
//                     //         )
//                     //       : Row(
//                     //           children: [
//                     //             // DECREASE
//                     //             GestureDetector(
//                     //               onTap: widget.decreaseQuantityCallback,

//                     //               child: Container(
//                     //                 width: 35.sp(context),
//                     //                 color: Colors.transparent,
//                     //                 child: Icon(Icons.remove, color: context.colorScheme.primary, size: 20.sp(context)),
//                     //               ),
//                     //             ),

//                     //             // QTY
//                     //             Text(
//                     //               '${widget.product.quantity}',
//                     //               style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.primary),
//                     //             ),

//                     //             // INCREASE
//                     //             GestureDetector(
//                     //               onTap: widget.increaseQuantityCallback,

//                     //               child: Container(
//                     //                 width: 35.sp(context),
//                     //                 color: Colors.transparent,
//                     //                 child: Icon(Icons.add, color: context.colorScheme.primary, size: 20.sp(context)),
//                     //               ),
//                     //             ),
//                     //           ],
//                     //         ),
//                     // ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ProductDetailsCard extends StatefulWidget {
//   const ProductDetailsCard({required this.decreaseQuantityCallback, required this.increaseQuantityCallback, required this.product, super.key});
//   final Product product;
//   final VoidCallback increaseQuantityCallback;
//   final VoidCallback decreaseQuantityCallback;

//   @override
//   State<ProductDetailsCard> createState() => _ProductDetailsCardState();
// }

// class _ProductDetailsCardState extends State<ProductDetailsCard> {
//   // 1. Initialize the ValueNotifier
//   final ValueNotifier<bool> _isLongPressing = ValueNotifier<bool>(false);

//   @override
//   void dispose() {
//     // 2. Always dispose notifiers to prevent memory leaks
//     _isLongPressing.dispose();
//     super.dispose();
//   }

//   // 3. Updated logic using the notifier value
//   Future<void> _handleLongPress(VoidCallback callback) async {
//     _isLongPressing.value = true;
//     while (_isLongPressing.value) {
//       callback();
//       // Adjust delay for speed (150ms is a good balance)
//       await Future.delayed(const Duration(milliseconds: 150));
//     }
//   }

//   void _stopLongPress() {
//     _isLongPressing.value = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10.sp(context)),
//       height: context.screenHeight * 0.12,
//       constraints: const BoxConstraints(minHeight: 110),
//       padding: EdgeInsets.all(8.sp(context)),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.sp(context)),
//         color: context.colorScheme.secondary,
//       ),
//       width: double.infinity,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final minsize = constraints.maxHeight < constraints.maxWidth ? constraints.maxHeight : constraints.maxWidth;

//           return Row(
//             children: [
//               // Image Section
//               Container(
//                 height: minsize,
//                 width: minsize,
//                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.sp(context))),
//                 child: CustomImageWidget(
//                   imagePath: widget.product.image,
//                   height: minsize,
//                   width: minsize,
//                   border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
//                   borderRadius: 10.sp(context),
//                 ),
//               ),
//               SizedBox(width: 8.sp(context)),
//               // Content Section
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.product.name,
//                           style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.w300),
//                           maxLines: 2,
//                         ),
//                         Text(
//                           widget.product.category.name,
//                           style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.primary),
//                           maxLines: 2,
//                         ),
//                       ],
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '$currencySymbol ${widget.product.price}',
//                           style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSecondary),
//                         ),

//                         // QUANTITY CONTROLS
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10.sp(context)),
//                           height: 30.sp(context),
//                           decoration: BoxDecoration(
//                             color: context.primaryColor.withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(8.sp(context)),
//                           ),
//                           child: widget.product.quantity == 0
//                               ? GestureDetector(
//                                   onTap: widget.increaseQuantityCallback, // Tap "Add" to start
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(Icons.add_shopping_cart_sharp, color: context.colorScheme.primary.withValues(alpha: 0.8), size: 16.sp(context)),
//                                       Padding(
//                                         padding: EdgeInsets.symmetric(horizontal: 10.sp(context)),
//                                         child: Text(
//                                           'addItemLbl'.tr(context),
//                                           style: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.primary),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     // DECREASE BUTTON
//                                     GestureDetector(
//                                       onTap: widget.decreaseQuantityCallback,
//                                       onLongPressStart: (_) => _handleLongPress(widget.decreaseQuantityCallback),
//                                       onLongPressEnd: (_) => _stopLongPress(),
//                                       onLongPressCancel: _stopLongPress,
//                                       child: Container(
//                                         color: Colors.transparent, // Increases hit area
//                                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                                         child: Icon(Icons.remove, color: context.colorScheme.primary, size: 18.sp(context)),
//                                       ),
//                                     ),

//                                     // QUANTITY DISPLAY
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(horizontal: 10.sp(context)),
//                                       child: Text(
//                                         '${widget.product.quantity}',
//                                         style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.primary),
//                                       ),
//                                     ),

//                                     // INCREASE BUTTON
//                                     GestureDetector(
//                                       onTap: widget.increaseQuantityCallback,
//                                       onLongPressStart: (_) => _handleLongPress(widget.increaseQuantityCallback),
//                                       onLongPressEnd: (_) => _stopLongPress(),
//                                       onLongPressCancel: _stopLongPress,
//                                       child: Container(
//                                         color: Colors.transparent, // Increases hit area
//                                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                                         child: Icon(Icons.add, color: context.colorScheme.primary, size: 18.sp(context)),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
