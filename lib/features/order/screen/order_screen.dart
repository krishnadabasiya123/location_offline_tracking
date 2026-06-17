import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/cubits/app_config_cubit.dart';
import 'package:omkar_sale/commons/widgets/customWidget/Custom_marquee_text.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/cubit/set_place_order_cubit.dart';

class CartProductItem {
  CartProductItem({required this.name, required this.photo, required this.price, required this.quantity});
  final String name;
  final String photo;
  final double price;
  int quantity;
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({required this.shopDetails, super.key});

  final Shop shopDetails;

  @override
  State<OrderScreen> createState() => _OrderDetailsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<SetOrderPlaceCubit>(
        create: (context) => SetOrderPlaceCubit(),
        child: OrderScreen(shopDetails: args?['shopDetails'] as Shop? ?? Shop.fromJson(const {})),
      ),
    );
  }
}

class _OrderDetailsScreenState extends State<OrderScreen> {
  final TextEditingController notesController = TextEditingController();
  late final ValueNotifier<int> currentStepNotifier;
  ValueNotifier<bool> hasTinNumber = ValueNotifier<bool>(false);
  final TextEditingController expectedDeliveryDateController = TextEditingController();
  final TextEditingController _paymentTypeController = TextEditingController();
  ValueNotifier<int> shopId = ValueNotifier<int>(-1);
  ValueNotifier<String> paymentMethodId = ValueNotifier<String>('-1');
  final TextEditingController _shopController = TextEditingController();
  @override
  void initState() {
    super.initState();
    currentStepNotifier = ValueNotifier(1);
    if (widget.shopDetails.id != -1) {
      shopId.value = widget.shopDetails.id;
    }
    if (widget.shopDetails.name.isNotEmpty) {
      _shopController.text = widget.shopDetails.name;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    _shopController.dispose();
    hasTinNumber.dispose();
    _paymentTypeController.dispose();
    expectedDeliveryDateController.dispose();
    shopId.dispose();
    currentStepNotifier.dispose();
    super.dispose();
  }

  // double get subTotal => cartItems.fold(0, (sum, e) => sum + (e.price * e.quantity));
  // double get tax => subTotal * 0.10;
  // double get total => subTotal + tax;

  Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
    );

    return picked;
  }

  Widget _buildStepIndicator(int currentStep) {
    return Padding(
      padding: EdgeInsets.all(16.sp(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: List.generate(2, (index) {
              final isActive = index < currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4.sp(context),
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 8.sp(context)),
                  decoration: BoxDecoration(color: isActive ? context.colorScheme.primary : context.colorScheme.surfaceDim.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                ),
              );
            }),
          ),
          SizedBox(height: 8.sp(context)),
          Text(
            'Step $currentStep of 2',
            style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.surfaceDim, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Product item) {
    final price = double.tryParse(item.price) ?? 0;
    final total = price * item.quantity;

    return Container(
      padding: EdgeInsets.all(12.sp(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.sp(context)),
        border: Border.all(color: context.colorScheme.surfaceDim.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            height: 56.sp(context),
            width: 56.sp(context),
            decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8.sp(context))),
            child: CustomImageWidget(imagePath: item.image, borderRadius: 8.sp(context)),
          ),
          SizedBox(width: 12.sp(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSecondary),
                ),
                SizedBox(height: 6.sp(context)),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// ==========================================
                        /// ACTIVE UI: STATIC BADGE (AS PER HTML)
                        /// ==========================================
                        CustomMarqueeText(
                          width: constraints.maxWidth * 0.48,
                          text: '${"qtyLbl".tr(context)}: ${item.quantity}',
                          textStyle: TextStyle(
                            fontSize: 13.sp(context),
                            fontWeight: FontWeight.w500,
                            color: context.colorScheme.onSecondary.withValues(alpha: 0.8),
                          ),
                        ),

                        /* 
                        /// ==========================================
                        /// COMMENTED CODE: INTERACTIVE QUANTITY COUNTER
                        /// ==========================================
                        Container(
                          decoration: BoxDecoration(
                            color: context.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(8.sp(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.remove, size: 18.sp(context), color: context.colorScheme.primary),
                                onPressed: () { if (item.quantity > 1) setState(() => item.quantity--); },
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.sp(context)),
                                child: Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.add, size: 18.sp(context), color: context.colorScheme.primary),
                                onPressed: () => setState(() => item.quantity++),
                              ),
                            ],
                          ),
                        ),
                        */
                        Expanded(
                          child: CustomMarqueeText(
                            textAlign: TextAlign.end,
                            width: constraints.maxWidth * 0.48,
                            text: '$currencySymbol ${item.price}',
                            textStyle: TextStyle(fontSize: 14.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.6)),
                          ),
                        ),
                        // Text(
                        //   '$currencySymbol ${item.price}',
                        //   style: TextStyle(fontSize: 14.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.6)),
                        // ),
                      ],
                    );
                  },
                ),
                const Divider(),
                Text(
                  '$currencySymbol ${total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final total = context.read<GetCartItemCubit>().getCartTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'orderSummaryLbl'.tr(context),
          style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface),
        ),
        SizedBox(height: 12.sp(context)),
        Container(
          margin: EdgeInsets.only(bottom: 8.sp(context)),
          padding: EdgeInsets.all(15.sp(context)),
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(16.sp(context)),
            border: Border.all(color: context.colorScheme.surfaceDim.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              // _summaryRow("${"subtotalLbl".tr(context)} (${cartItems.length} ${"itemsLbl".tr(context)})", '$currencySymbol ${subTotal.toStringAsFixed(2)}'),
              // _summaryRow('shippingLbl'.tr(context), 'Free', valueColor: AppThemeColors.greenColor),
              // _summaryRow('taxLbl'.tr(context), '$currencySymbol ${tax.toStringAsFixed(2)}'),
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 8.sp(context)),
              //   child: Divider(color: context.colorScheme.onSecondary.withValues(alpha:0.5), height: 1),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'totalAmountLbl'.tr(context).toUpperCase(),
                    style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSecondary.withValues(alpha: 0.5), letterSpacing: 0.5),
                  ),

                  Expanded(
                    child: CustomMarqueeText(
                      text: '$currencySymbol ${total.toStringAsFixed(2)}',
                      textStyle: TextStyle(fontSize: 19.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.primary),
                      textAlign: TextAlign.end,
                    ),
                    // child: Text(
                    //   '$currencySymbol ${total.toStringAsFixed(2)}',
                    //   style: TextStyle(fontSize: 19.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.primary),
                    // ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: context.colorScheme.onSecondary.withValues(alpha: 0.5), fontSize: 13.5.sp(context)),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor ?? context.colorScheme.onSecondary, fontSize: 14.sp(context), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- STEPS ---

  Widget _buildStep1() {
    final productCart = context.read<GetCartItemCubit>().getCartProducts();

    return Column(
      key: const ValueKey(1),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${"selectedItemsLbl".tr(context)} (${productCart.length})",
              style: TextStyle(fontSize: 16.sp(context)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'editListLbl'.tr(context).toUpperCase(),
                style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp(context)),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: productCart.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.sp(context)),
            itemBuilder: (context, index) => _buildItemCard(productCart[index]),
          ),
        ),
        // SizedBox(height: 8.sp(context)),
        // Text(
        //   "Scroll to see more items",
        //   style: TextStyle(fontSize: 11.sp(context), fontStyle: FontStyle.italic, color: context.colorScheme.surfaceDim),
        // ),
        // SizedBox(height: 12.sp(context)),
        // _buildOrderSummaryCard(),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, Widget? action}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.sp(context), vertical: 12.sp(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface),
          ),
          ?action,
        ],
      ),
    );
  }

  Widget _modernTabButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.sp(context)),
          decoration: BoxDecoration(
            color: isSelected ? context.colorScheme.primary : context.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12.sp(context)),
            // border: Border.all(color: isSelected ? context.colorScheme.primary : context.colorScheme.onSecondary),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSecondary, fontWeight: FontWeight.w500, fontSize: 13.sp(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final paymentMethods = context.read<AppConfigCubit>().getCurrentPaymentMethods();

    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'customerOrShopLbl'.tr(context),
              style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500),
            ),

            // Row(
            //   children: [
            //     Icon(Icons.add, size: 18.sp(context), color: context.colorScheme.primary),
            //     SizedBox(width: 5.sp(context)),
            //     Text(
            //       'registerShopLbl'.tr(context),
            //       style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.primary),
            //     ),
            //   ],
            // ),
          ],
        ),
        SizedBox(height: 8.sp(context)),
        CustomTextField(
          controller: _shopController,
          hintText: 'selectShopLbl'.tr(context),
          prefixIcon: Icon(Icons.storefront, color: context.colorScheme.primary, size: 19.sp(context)),
          fillColor: context.colorScheme.secondary,
          borderRadius: 12.sp(context),
          readOnly: true,
          onTap: () async {
            await Navigator.of(context).pushNamed(Routes.customerListScreen, arguments: {'isComeFromOrderScreen': true}).then(
              (value) {
                if (value != null && value is Shop) {
                  shopId.value = value.id;
                  _shopController.text = value.name;
                }
              },
            );
          },
        ),
        SizedBox(height: 5.sp(context)),
        _buildSectionHeader(title: 'paymentDetailsLbl'.tr(context)),

        Container(
          padding: EdgeInsets.all(16.sp(context)),
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(20.sp(context)),
            border: Border.all(color: context.colorScheme.surfaceDim.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIN Number Toggle
              Text(
                'TINNumberAvailableLbl'.tr(context),
                style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSecondary.withValues(alpha: 0.7)),
              ),
              SizedBox(height: 8.sp(context)),
              ValueListenableBuilder(
                valueListenable: hasTinNumber,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      _modernTabButton('Yes', value, () => hasTinNumber.value = true),
                      SizedBox(width: 12.sp(context)),
                      _modernTabButton('No', !value, () => hasTinNumber.value = false),
                    ],
                  );
                },
              ),

              SizedBox(height: 14.sp(context)),

              // Payment Type Dropdown
              // Text(
              //   'paymentTypeLbl'.tr(context),
              //   style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w600, color: context.colorScheme.onSecondary.withValues(alpha:0.7)),
              // ),
              // SizedBox(height: 8.sp(context)),
              CustomDropdown(
                height: 52.sp(context),
                items: DropdownConfig.fromStringList(paymentMethods.map((e) => e.value).toList()),
                controller: _paymentTypeController,
                hintText: 'paymentMethodLbl'.tr(context),
                isEnabled: true,
                onSelected: (value, label) {
                  paymentMethodId.value = value;
                },
                width: double.infinity,
                backgroundColor: context.scaffoldBackgroundColor,
                menuBackgroundColor: context.colorScheme.secondary,
                borderRadius: 12.sp(context),
                borderType: DropdownBorderType.outline,
                borderColor: Colors.transparent,
                focusedBorderColor: context.colorScheme.primary,
                iconSize: 20.sp(context),
                textStyle: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 14.sp(context)),
              // Text(
              //   'preferredDeliveryLbl'.tr(context),
              //   style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w600, color: context.colorScheme.onSecondary.withValues(alpha:0.7)),
              // ),
              // SizedBox(height: 8.sp(context)),
              ValueListenableBuilder(
                valueListenable: expectedDeliveryDateController,
                builder: (context, value, child) {
                  return CustomTextField(
                    controller: expectedDeliveryDateController,
                    hintText: 'ExpectedDeliveryDateLbl'.tr(context),
                    hintStyle: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500),
                    fillColor: context.scaffoldBackgroundColor,
                    borderRadius: 12.sp(context),
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    //contentPadding: EdgeInsets.zero,
                    onTap: () {
                      pickDate(context: context).then((value) {
                        if (value != null) {
                          return expectedDeliveryDateController.text = value.toLocal().toString().split(' ').first;
                        }
                      });
                    },
                    suffixIcon: Icon(Icons.calendar_today, color: context.colorScheme.primary, size: 19.sp(context)),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 14.sp(context)),
        _buildCommentContainer(),
        //   SizedBox(height: 24.sp(context)),
      ],
    );
  }

  Widget _buildCommentContainer() {
    return CustomTextField(
      controller: notesController,
      maxLines: context.isMobile ? 3 : 7,
      keyboardType: TextInputType.multiline,
      minLines: context.isMobile ? 3 : 7,
      hintText: 'enterCommentLbl'.tr(context),
      hintColor: context.colorScheme.onSecondary.withValues(alpha: 0.5),
      fillColor: context.colorScheme.secondary,
      hintFontSize: 15.sp(context),
      fontSize: 17.sp(context),
      contentPadding: EdgeInsets.symmetric(horizontal: 15.sp(context), vertical: 10.sp(context)),
      borderRadius: 15.sp(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentStepNotifier,
      builder: (context, currentStep, child) {
        return PopScope(
          canPop: false,
          //currentStep == 1 || context.read<SetOrderPlaceCubit>().state is SetOrderPlaceInProgress,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (context.read<SetOrderPlaceCubit>().state is SetOrderPlaceInProgress) {
              return;
            } else if (currentStep > 1) {
              currentStepNotifier.value--;
            } else {
              Navigator.of(context).pop();
            }
          },
          child: BlocBuilder<GetCartItemCubit, GetCartItemState>(
            builder: (context, state) {
              return Scaffold(
                // floatingActionButton: FloatingActionButton(
                //   onPressed: () {
                //     showThemeSelectorSheet(context);
                //   },
                // ),
                appBar: CustomAppBar(
                  title: (currentStep == 1 ? 'orderConfirmationLbl'.tr(context) : 'reviewPlaceOrderLbl'.tr(context)),
                  onTapBackButton: () {
                    if (currentStep > 1) {
                      currentStepNotifier.value--;
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                bottomNavigationBar: Container(
                  padding: EdgeInsets.all(16.sp(context)),
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondary,
                    border: Border(top: BorderSide(color: context.colorScheme.surfaceDim.withValues(alpha: 0.1))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutBack, // Gives it a slight "pop" effect
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Combined Slide and Fade animation
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2), // Starts slightly below
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        // Only show if currentStep is 2
                        child: currentStep == 2
                            ? KeyedSubtree(
                                key: const ValueKey('orderSummary'),
                                child: _buildOrderSummaryCard(),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // The Spacing should also animate to prevent a jumpy UI
                      if (currentStep == 2) SizedBox(height: 12.sp(context)),
                      BlocConsumer<SetOrderPlaceCubit, SetOrderPlaceState>(
                        listener: (context, state) {
                          'DEBUG: state listener: $state'.log();
                          if (state is SetOrderPlaceSuccess) {
                            context.read<GetCartItemCubit>().clearCart();
                            context.read<GetProductCubit>().resetProductsQuantity();
                            context.showSnackBar(message: 'orderPlacedSuccessfully'.tr(context), backgroundColor: AppThemeColors.greenColor);
                            Navigator.of(context).pop();
                          }
                          if (state is SetOrderPlaceFetchFailure) {
                            context.showSnackBar(message: state.exception.errorMessageKey, backgroundColor: context.colorScheme.error);
                          }
                        },
                        builder: (context, state) {
                          'DEBUG: state: $state'.log();
                          return CustomRoundedButtonWidget(
                            isLoading: state is SetOrderPlaceInProgress,
                            onPressed: () async {
                              if (currentStep < 2) {
                                currentStepNotifier.value++;
                              } else {
                                shopId.value.log('shopId');
                                paymentMethodId.value.log('paymentMethodId');
                                _shopController.text.log('_shopController');

                                if (shopId.value == -1) {
                                  context.showSnackBar(message: 'selectedShopsLbl'.tr(context).tr(context), backgroundColor: context.colorScheme.error);
                                  return;
                                }
                                if (paymentMethodId.value == '-1') {
                                  context.showSnackBar(message: 'selectPaymentMethodLbl'.tr(context).tr(context), backgroundColor: context.colorScheme.error);
                                  return;
                                }

                                final cartProducts = context.read<GetCartItemCubit>().getCartProducts();
                                final productCartAndQuantity = cartProducts.map((p) => {'product_id': p.id.toString(), 'quantity': p.quantity.toString()}).toList();

                                await context.read<SetOrderPlaceCubit>().placeOrder(
                                  customerId: shopId.value.toString(),
                                  productIdAndQuantity: productCartAndQuantity,
                                  tinNumber: hasTinNumber.value,
                                  paymentTypeId: paymentMethodId.value,
                                  deliveryDate: expectedDeliveryDateController.text.trim(),
                                  notes: notesController.text.trim(),
                                );
                              }
                            },
                            text: currentStep == 1 ? 'orderConfirmationLbl'.tr(context) : 'placeOrderLbl'.tr(context),
                            height: 54.sp(context),
                            textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500),
                            gradient: const LinearGradient(colors: [AppThemeColors.linearGradientPrimary, AppThemeColors.linearGradientSecondary]),
                            borderRadius: BorderRadius.circular(12.sp(context)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    _buildStepIndicator(currentStep),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp(context)),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: currentStep == 1 ? _buildStep1() : _buildStep2(),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.sp(context)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_appbar_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_rounded_button_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_textformfiled_widget.dart';
// import 'package:omkar_sale/utils/extensions/context_size_extensions.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/string_extensopns.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// class CartProductItem {
//   final String name;
//   final String photo;
//   final double price;
//   int quantity;

//   CartProductItem({required this.name, required this.photo, required this.price, required this.quantity});
// }

// class OrderScreen extends StatefulWidget {
//   const OrderScreen({super.key});

//   @override
//   State<OrderScreen> createState() => _OrderDetailsScreenState();

//   static Route<dynamic> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute(builder: (_) => OrderScreen());
//   }
// }

// class _OrderDetailsScreenState extends State<OrderScreen> {
//   final TextEditingController notesController = TextEditingController();

//   DateTime dateTime = DateTime.now().add(const Duration(days: 1));

//   /// 🔹 Fixed cart list (UI only)
//   final List<CartProductItem> cartItems = [
//     CartProductItem(name: 'Pizza Margherita', photo: '', price: 250, quantity: 1),
//     CartProductItem(name: 'Veg Burger', photo: '', price: 120, quantity: 2),
//     CartProductItem(name: 'Pizza Margherita', photo: '', price: 250, quantity: 1),
//     CartProductItem(name: 'Veg Burger', photo: '', price: 120, quantity: 2),
//     CartProductItem(name: 'Pizza Margherita', photo: '', price: 250, quantity: 1),
//     CartProductItem(name: 'Veg Burger', photo: '', price: 120, quantity: 2),
//     CartProductItem(name: 'Pizza Margherita', photo: '', price: 250, quantity: 1),
//     CartProductItem(name: 'Veg Burger', photo: '', price: 120, quantity: 2),
//   ];

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     notesController.dispose();
//     super.dispose();
//   }

//   double get subTotal => cartItems.fold(0, (sum, e) => sum + (e.price * e.quantity));

//   Widget _buildOrderTotalAndTaxDetailsContainer() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: 10.sp(context)),
//           child: Text(
//             "orderSummaryLbl".tr(context),
//             style: TextStyle(fontSize: 17.sp(context), color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.sp(context)),
//             color: context.colorScheme.secondary,
//             border: Border.all(color: context.colorScheme.primary.withValues(alpha:0.4)),
//           ),
//           padding: EdgeInsets.symmetric(horizontal: 15.sp(context), vertical: 15.sp(context)),
//           child: Column(children: [_buildSubtotalTaxTotalWidget(context), _buildSubtotalTaxTotalWidget(context), _buildSubtotalTaxTotalWidget(context)]),
//         ),
//       ],
//     );
//   }

//   Widget _buildCommentContainer() {
//     return CustomTextField(
//       controller: notesController,
//       maxLines: context.isMobile ? 2 : 7,
//       keyboardType: TextInputType.multiline,
//       minLines: context.isMobile ? 2 : 7,
//       hintText: 'enterCommentLbl'.tr(context),
//       fillColor: context.colorScheme.secondary,
//       hintFontSize: 15.sp(context),
//       fontSize: 17.sp(context),
//       contentPadding: EdgeInsets.symmetric(horizontal: 15.sp(context), vertical: 10.sp(context)),
//       borderRadius: 15.sp(context),
//       borderType: CustomTextFormFieldBorder.none,
//     );
//   }

//   Widget _buildOrderItemsListContainer() {
//     return Expanded(
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.sp(context)),
//         child: ListView.separated(
//           padding: EdgeInsets.zero,
//           itemCount: cartItems.length,
//           separatorBuilder: (_, __) => SizedBox(height: 12.sp(context)),
//           itemBuilder: (context, index) {
//             final item = cartItems[index];
//             return Container(
//               padding: EdgeInsets.all(10.sp(context)),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.sp(context)),
//                 color: context.colorScheme.secondary,
//                 border: Border.all(color: context.colorScheme.primary.withValues(alpha:0.4)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     height: 50.sp(context),
//                     width: 50.sp(context),
//                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.sp(context))),
//                     child: const Icon(Icons.fastfood),
//                   ),
//                   SizedBox(width: 12.sp(context)),
//                   Expanded(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.name,
//                           style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w600, color: context.colorScheme.onSecondary.withValues(alpha: 0.9)),
//                         ),
//                         SizedBox(height: 4.sp(context)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween, // Separates price and counter
//                           children: [
//                             Text(
//                               '$currencySymbol ${item.price.toStringAsFixed(2)}',
//                               style: TextStyle(fontWeight: FontWeight.bold, color: context.colorScheme.onSecondary.withValues(alpha: 0.7)),
//                             ),

//                             // Compact Counter
//                             Container(
//                               decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8.sp(context))),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     padding: EdgeInsets.all(3.sp(context)), // Small padding
//                                     constraints: const BoxConstraints(),
//                                     visualDensity: VisualDensity.compact,
//                                     icon: Icon(Icons.remove, size: 18.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.9)),
//                                     onPressed: () {
//                                       if (item.quantity > 1) setState(() => item.quantity--);
//                                     },
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 4.sp(context)),
//                                     child: Text(item.quantity.toString(), style: TextStyle(color: context.colorScheme.onSecondary.withValues(alpha: 0.9))),
//                                   ),
//                                   IconButton(
//                                     padding: EdgeInsets.all(3.sp(context)),
//                                     constraints: const BoxConstraints(),
//                                     visualDensity: VisualDensity.compact,
//                                     icon: Icon(Icons.add, size: 18.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.9)),
//                                     onPressed: () => setState(() => item.quantity++),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceOrderButtonContainer() {
//     return Container(
//       color: context.colorScheme.secondary,
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 12.sp(context), horizontal: 14.sp(context)),
//       child: CustomRoundedButtonWidget(
//         onPressed: () {},
//         text: 'Place Order'.tr(context),
//         height: 56.sp(context),
//         gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
//         shadowColor: const Color(0xFF4A00E0),
//         elevation: 8,
//         borderRadius: BorderRadius.circular(16),
//         textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildSubtotalTaxTotalWidget(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.sp(context), vertical: 3.sp(context)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Grand Total',
//             style: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.onSecondary.withValues(alpha: 0.6)),
//           ),
//           Text(
//             '$currencySymbol ${subTotal.toStringAsFixed(2)}',
//             style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.onSecondary.withValues(alpha: 0.8)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBodyContainer() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.sp(context), vertical: 5.sp(context)),
//       child: Column(
//         children: [
//           SizedBox(height: 10.sp(context)),
//           // Padding(
//           //   padding: EdgeInsets.symmetric(vertical: 8.sp(context)),
//           //   child: CustomTextField(
//           //     contentPadding: EdgeInsets.zero,
//           //     borderRadius: 15.sp(context),
//           //     borderType: CustomTextFormFieldBorder.none,
//           //     fillColor: context.colorScheme.secondary,
//           //     prefixIcon: Icon(Icons.shopping_bag, size: 25.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.4)),
//           //     hintText: "selectShop".tr(context),
//           //     hintFontSize: 15.sp(context),
//           //     fontSize: 17.sp(context),
//           //   ),
//           // ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "${"Selected Items".tr(context)} (8)",
//                 style: TextStyle(fontSize: 16.sp(context), color: context.colorScheme.onSurface, fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 "EditListLbl".tr(context),
//                 style: TextStyle(fontSize: 13.sp(context), color: context.colorScheme.primary),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.sp(context)),

//           /// 🛒 Cart Items
//           _buildOrderItemsListContainer(),
//           SizedBox(height: 10.sp(context)),

//           // /// 📝 Notes
//           // _buildCommentContainer(),
//           // SizedBox(height: 10.sp(context)),

//           /// 💰 Total
//           _buildOrderTotalAndTaxDetailsContainer(),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Order Details".tr(context)),
//       bottomNavigationBar: _buildPlaceOrderButtonContainer(),
//       body: _buildBodyContainer(),
//     );
//   }
// }
