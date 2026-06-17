import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/order/cubit/delete_order_cubit.dart';
import 'package:omkar_sale/features/order/cubit/get_order_cubit.dart';
import 'package:omkar_sale/features/order/model/place_order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute<dynamic>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<GetOrdersCubit>(create: (context) => GetOrdersCubit()),
          BlocProvider<DeleteOrderCubit>(create: (context) => DeleteOrderCubit()),
        ],
        child: const OrderHistoryScreen(),
      ),
      settings: routeSettings,
    );
  }
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _previousQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);
  @override
  void initState() {
    super.initState();
    Future.microtask(fetchOrders);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text;
    if (currentQuery != _previousQuery) {
      _previousQuery = currentQuery;
      _debouncer.run(() {
        fetchOrders(searchQuery: currentQuery);
      });
    }
  }

  void fetchOrders({String searchQuery = ''}) {
    context.read<GetOrdersCubit>().fetchGetOrders(searchQuery: searchQuery);
  }

  Widget _buildSearchbarContainer() {
    return CustomTextField(
      controller: _searchController,
      contentPadding: EdgeInsets.zero,
      borderRadius: 15.sp(context),
      fillColor: context.colorScheme.secondary,
      prefixIcon: Icon(Icons.search, size: 25.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.4)),
      hintText: 'searchStoreHintLbl'.tr(context),
      hintFontSize: 15.sp(context),
      fontSize: 17.sp(context),
    );
  }

  Widget _buildHeader() {
    return CustomAppBar(
      backgroundColor: context.colorScheme.secondary,
      elevation: 0,
      //appBarHeight: (kToolbarHeight).sp(context),
      title: 'orderHistoryLbl'.tr(context),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildErrorContainer({required String titleText, required String subtitleText, required VoidCallback onRetry}) {
    return CustomErrorWidget(
      retryButtonHeight: 45.sp(context),
      title: titleText,
      subtitle: subtitleText,
      imageWidget: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.rotate(
            angle: 6 * pi / 180,
            child: Container(
              height: 110.sp(context),
              width: 110.sp(context),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                borderRadius: BorderRadius.circular(40.sp(context)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 8))],
                border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Icon(Icons.inventory_2, size: 50.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
          ),
          Positioned(
            top: -10,
            right: -15,
            child: Transform.rotate(
              angle: -12 * pi / 180,
              child: Container(
                height: 40.sp(context),
                width: 40.sp(context),
                decoration: BoxDecoration(
                  color: context.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16.sp(context)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
                  border: Border.all(color: context.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.search_off, size: 20.sp(context), color: context.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteOrderCubit, DeleteOrderState>(
          listener: (context, state) {
            if (state is DeleteOrderInProgress) {
              context.showCustomDialog<void>(isLoading: true, isDismissible: false);
            } else if (state is DeleteOrderSuccess) {
              context.read<GetOrdersCubit>().deleteOrder(state.orderId);
              Navigator.pop(context);
              context.showSnackBar(message: 'orderDeleteSuccessMsg'.tr(context));
            } else if (state is DeleteOrderFailure) {
              Navigator.pop(context);
              context.showSnackBar(message: state.exception.errorMessageKey.tr(context), backgroundColor: context.colorScheme.error);
            }
          },
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomPaddingWidget.symmetric(
                child: Column(
                  children: [
                    SizedBox(height: 10.sp(context)),
                    _buildSearchbarContainer(),
                    SizedBox(height: 10.sp(context)),
                    Expanded(
                      child: BlocBuilder<GetOrdersCubit, GetOrdersState>(
                        builder: (context, state) {
                          if (state is GetOrdersFetchFailure) {
                            return _buildErrorContainer(
                              titleText: '',
                              subtitleText: state.exception.errorMessageKey,
                              onRetry: fetchOrders,
                            );
                          }

                          if (state is GetOrdersFetchSuccess) {
                            if (state.orders.isEmpty) {
                              return _buildErrorContainer(titleText: 'orderNotFoundLbl'.tr(context), subtitleText: 'orderNotFoundDescLbl'.tr(context), onRetry: fetchOrders);
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                fetchOrders();
                              },
                              child: PaginatedBlocListView<PlaceOrderDetails>(
                                physics: const AlwaysScrollableScrollPhysics(),
                                items: state.orders,
                                hasMore: context.read<GetOrdersCubit>().hasMoreProducts(),
                                isLoading: state.isLoading,
                                isInitialLoad: false,
                                onLoadMore: context.read<GetOrdersCubit>().fetchMoreProducts,
                                itemBuilder: (context, order) {
                                  return OrderHistoryCard(
                                    order: order,
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.orderDetailScreen, arguments: order);
                                    },
                                    onDelete: (order) {
                                      _showDeleteConfirmationDialog(context, order);
                                    },
                                  );
                                },
                              ),
                            );
                          }
                          return const Center(child: CustomCircularProgressIndicator());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, PlaceOrderDetails order) {
    context.showCustomDialog(
      title: 'deleteOrderTitle'.tr(context),
      message: 'deleteOrderConfirmDesc'.tr(context),
      onConfirm: () {
        context.read<DeleteOrderCubit>().deleteOrder(orderId: order.id.toString());
      },
      confirmButtonText: 'deleteLbl'.tr(context),
      cancelButtonText: 'cancelLbl'.tr(context),
    );
  }
}
