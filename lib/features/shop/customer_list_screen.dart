import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/cubit/get_shop_cubit.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({this.isComeFromOrderScreen = false, super.key, this.isShowShopInventory = false});
  final bool isComeFromOrderScreen;
  final bool isShowShopInventory;

  @override
  State<CustomerListScreen> createState() => _ShopListScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
      builder: (_) => CustomerListScreen(isComeFromOrderScreen: args?['isComeFromOrderScreen'] as bool? ?? false, isShowShopInventory: args?['isShowShopInventory'] as bool? ?? false),
    );
  }
}

class _ShopListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  String _previousQuery = '';
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.microtask(fetchShops);
  }

  void fetchShops({String searchQuery = '', bool forceRefresh = false}) {
    context.read<GetShopCubit>().fetchGetShop(searchQuery: searchQuery, forceRefresh: forceRefresh);
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text;
    if (currentQuery != _previousQuery) {
      _previousQuery = currentQuery;
      _debouncer.run(() {
        fetchShops(searchQuery: currentQuery);
      });
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: context.read<UserDetailsCubit>().isUserSalesman() && !widget.isShowShopInventory,
        child: CustomRoundedButtonWidget(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.createShopScreen);
          },
          width: context.screenWidth * 0.3,
          text: 'AddShopLbl'.tr(context),
        ),
      ),
      appBar: CustomAppBar(
        title: 'OtherShopsLbl'.translate(context),
        automaticallyImplyLeading: widget.isComeFromOrderScreen,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchShops(forceRefresh: true);
        },
        child: CustomPaddingWidget.only(
          child: Column(
            children: [
              SizedBox(height: 10.sp(context)),
              _buildSearchShopContainer(context),

              SizedBox(height: 10.sp(context)),
              Expanded(
                child: BlocConsumer<GetShopCubit, GetShopState>(
                  listener: (context, state) {
                    if (state is GetShopFetchSuccess) {
                      if (state.isError) {
                        'state'.log('GetShopCubit');
                        context.showSnackBar(message: state.exception!.errorMessageKey, backgroundColor: context.colorScheme.error);
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is GetShopFetchFailure) {
                      return CustomErrorWidget(
                        errorType: state.exception.type,
                        subtitle: state.exception.errorMessageKey.tr(context),
                        onRetry: fetchShops,
                      );
                    }

                    if (state is GetShopFetchSuccess) {
                      if (state.shops.isEmpty) {
                        return CustomErrorWidget(
                          errorType: CustomErrorType.noDataFound,
                          onRetry: fetchShops,
                        );
                      }
                      return PaginatedBlocListView<Shop>(
                        padding: EdgeInsets.only(bottom: 60.sp(context)),
                        items: state.shops,
                        hasMore: context.read<GetShopCubit>().hasMoreShops(),
                        isLoading: state.isLoading,
                        isInitialLoad: false,
                        onLoadMore: () => context.read<GetShopCubit>().fetchMoreShops(),
                        itemBuilder: (context, item) => ShopCard(
                          shop: item,
                          onTap: () {
                            if (widget.isComeFromOrderScreen) {
                              Navigator.pop(context, item);
                            } else if (context.read<UserDetailsCubit>().getCurrentUserRole() == UserRole.merchant || widget.isShowShopInventory) {
                              Navigator.of(context).pushNamed(Routes.shopWiseProductListingScreen, arguments: {'shopDetails': item});
                            } else {
                              Navigator.of(context).pushNamed(Routes.productListingScreen, arguments: {'shopDetails': item});
                            }

                            // if (context.read<UserDetailsCubit>().getCurrentUserRole() == UserRole.merchant) {
                            //   Navigator.of(context).pushNamed(Routes.productListingScreen, arguments: {'shopDetails': item});
                            // }
                          },
                        ),
                      );

                      // return ListView.builder(
                      //   padding: EdgeInsets.only(bottom: 15.sp(context)),
                      //   physics: const AlwaysScrollableScrollPhysics(),
                      //   itemCount: 10,
                      //   itemBuilder: (context, index) => ShopCard(shop: state.shops[index]),
                      // );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchShopContainer(BuildContext context) {
    return CustomTextField(
      controller: _searchController,
      hintText: 'searchStoreHintLbl'.tr(context),
      prefixIcon: Icon(Icons.search_rounded, size: 20.sp(context)),
      //   suffixIcon: Icon(Icons.tune_rounded, color: context.primaryColor, size: 20.sp(context)),
      fillColor: context.colorScheme.secondary,
      borderRadius: 12,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_appbar_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_textformfiled_widget.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/string_extensopns.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// enum ApprovalStatus { approved, pending }

// class Shop {
//   final String name;
//   final String address;
//   final String owner;

//   Shop({required this.name, required this.address, required this.owner});
// }

// class ShopCard extends StatelessWidget {
//   final Shop shop;
//   const ShopCard({super.key, required this.shop});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.sp(context)),
//       padding: EdgeInsets.all(16.sp(context)),
//       decoration: BoxDecoration(
//         color: context.colorScheme.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha:0.5)),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       shop.name,
//                       style: TextStyle(fontSize: 18.sp(context), fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 4.sp(context)),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on_rounded, size: 14.sp(context), color: Colors.grey),
//                         SizedBox(width: 4.sp(context)),
//                         Expanded(
//                           child: Text(
//                             shop.address,
//                             style: TextStyle(fontSize: 13.sp(context), color: Colors.grey),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 12.sp(context)),
//             child: Divider(height: 1, color: context.colorScheme.outlineVariant.withValues(alpha:0.5)),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.person_rounded, size: 16.sp(context), color: Colors.grey),
//                   SizedBox(width: 6.sp(context)),
//                   Text(
//                     shop.owner,
//                     style: TextStyle(fontSize: 14.sp(context), color: Colors.grey),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Text(
//                     "Details",
//                     style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp(context)),
//                   ),
//                   Icon(Icons.chevron_right_rounded, color: context.primaryColor, size: 20.sp(context)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusChip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(color: color.withValues(alpha:0.1), borderRadius: BorderRadius.circular(4)),
//       child: Text(
//         label.toUpperCase(),
//         style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

// class CustomerListScreen extends StatefulWidget {
//   const CustomerListScreen({super.key});

//   @override
//   State<CustomerListScreen> createState() => _ShopListScreenState();
//   static Route<CustomerListScreen> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute(builder: (_) => CustomerListScreen());
//   }
// }

// class _ShopListScreenState extends State<CustomerListScreen> {
//   final List<Shop> shops = [
//     Shop(name: "Sunrise Market", address: "123 Market St, San Francisco", owner: "John Doe"),
//     Shop(name: "Tech Haven Electronics", address: "450 10th Ave, New York", owner: "Sarah Smith"),
//     Shop(name: "Quick Stop Grocers", address: "89 Willow Creek, Austin", owner: "Mike Johnson"),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "OtherShops".translate(context)),
//       body: Column(
//         children: [
//           _buildSearchShopContainer(context),
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.all(16.sp(context)),
//               physics: const BouncingScrollPhysics(),
//               itemCount: shops.length,
//               itemBuilder: (context, index) => ShopCard(shop: shops[index]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchShopContainer(BuildContext context) {
//     return Column(
//       children: [
//         CustomTextField(
//           hintText: "Search store name, city...",
//           prefixIcon: const Icon(Icons.search_rounded),
//           suffixIcon: Icon(Icons.tune_rounded, color: context.primaryColor),
//           fillColor: context.colorScheme.secondary,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//           contentPadding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//       ],
//     );
//   }
// }
