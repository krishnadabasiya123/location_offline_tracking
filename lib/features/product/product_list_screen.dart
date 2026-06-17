// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';

// class ProductListScreen extends StatefulWidget {
//   const ProductListScreen({super.key});

//   @override
//   State<ProductListScreen> createState() => _ProductListScreenState();
// }

// class _ProductListScreenState extends State<ProductListScreen> {
//   static const int allCategoryId = -1;

//   // Controllers & Utilities
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   final Debouncer _debouncer = Debouncer(milliseconds: 500);
//   final ValueNotifier<int> _selectedCategoryId = ValueNotifier<int>(allCategoryId);

//   String _previousQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _setupListeners();
//   }

//   void _initializeData() {
//     Future.microtask(() {
//       fetchCategories();
//       fetchCartProducts();
//     });
//   }

//   void _setupListeners() {
//     _searchController.addListener(_onSearchChanged);
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//         context.read<GetProductCubit>().fetchMoreProducts();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _scrollController.dispose();
//     _selectedCategoryId.dispose();
//     _debouncer.dispose();
//     super.dispose();
//   }

//   // --- Logic Methods ---

//   void _onSearchChanged() {
//     final currentQuery = _searchController.text;
//     if (currentQuery != _previousQuery) {
//       _previousQuery = currentQuery;
//       _debouncer.run(() {
//         fetchProducts(
//           categoryId: _selectedCategoryId.value,
//           searchQuery: currentQuery,
//         );
//       });
//     }
//   }

//   Future<void> fetchProducts({String searchQuery = '', int categoryId = allCategoryId}) async {
//     context.read<GetProductCubit>().fetchGetProduct(
//       categoryId: categoryId,
//       searchQuery: searchQuery,
//     );
//   }

//   Future<void> fetchCategories() async {
//     await context.read<GetCategoryCubit>().fetchGetCategory();
//   }

//   Future<void> fetchCartProducts() async {
//     context.read<GetCartItemCubit>().featchCartProducts();
//   }

//   Widget _buildHeader() {
//     return CustomAppBar(
//       backgroundColor: context.colorScheme.secondary,
//       elevation: 0,
//       title: 'productsLbl'.tr(context),
//       automaticallyImplyLeading: false,
//     );
//   }

//   Widget _buildSearchbarContainer() {
//     return CustomTextField(
//       controller: _searchController, // CRITICAL: Added the controller here
//       contentPadding: EdgeInsets.zero,
//       borderRadius: 15.sp(context),
//       fillColor: context.colorScheme.secondary,
//       prefixIcon: Icon(
//         Icons.search,
//         size: 25.sp(context),
//         color: context.colorScheme.onSurface.withValues(alpha: 0.4),
//       ),
//       hintText: 'searchProductLbl'.tr(context),
//       hintFontSize: 15.sp(context),
//       fontSize: 17.sp(context),
//     );
//   }

//   Widget _buildCategorySection() {
//     return BlocConsumer<GetCategoryCubit, GetCategoryState>(
//       listener: (context, state) {
//         if (state is GetCategoryFetchSuccess) {
//           fetchProducts(categoryId: _selectedCategoryId.value);
//         }
//       },
//       builder: (context, state) {
//         if (state is GetCategoryFetchSuccess && state.categories.isNotEmpty) {
//           return _buildCategoryListWidget(categories: state.categories);
//         }
//         if (state is GetCategoryInProgress) {
//           return const Padding(
//             padding: EdgeInsets.all(20),
//             child: CustomCircularProgressIndicator(),
//           );
//         }
//         return const SizedBox();
//       },
//     );
//   }

//   Widget _buildCategoryListWidget({required List<ProductCategory> categories}) {
//     return Container(
//       height: 45.sp(context),
//       margin: EdgeInsets.symmetric(vertical: 10.sp(context)),
//       child: ValueListenableBuilder<int>(
//         valueListenable: _selectedCategoryId,
//         builder: (context, currentSelectedId, _) {
//           return ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               final isSelected = currentSelectedId == category.id;

//               return GestureDetector(
//                 onTap: () {
//                   if (_selectedCategoryId.value != category.id) {
//                     _selectedCategoryId.value = category.id;
//                     fetchProducts(
//                       categoryId: category.id,
//                       searchQuery: _searchController.text,
//                     );
//                   }
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: EdgeInsets.only(right: 10.sp(context)),
//                   padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: isSelected ? context.colorScheme.primary : context.colorScheme.secondary,
//                     borderRadius: BorderRadius.circular(8.sp(context)),
//                     boxShadow: isSelected ? [BoxShadow(color: context.colorScheme.primary.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
//                   ),
//                   child: Text(
//                     category.name,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.sp(context),
//                       color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProductSection() {
//     return Expanded(
//       child: BlocConsumer<GetProductCubit, GetProductState>(
//         listener: (context, state) {
//           if (state is GetProductFetchSuccess && state.isError) {
//             context.showSnackBar(
//               message: state.exception!.errorMessageKey,
//               backgroundColor: context.colorScheme.error,
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is GetProductInProgress) {
//             return const Center(child: CustomCircularProgressIndicator());
//           }

//           if (state is GetProductFetchFailure) {
//             return _buildErrorContainer(
//               titleText: 'productNotFoundTitleLbl'.tr(context),
//               subtitleText: state.exception.errorMessageKey,
//               onRetry: () => fetchProducts(categoryId: _selectedCategoryId.value, searchQuery: _searchController.text),
//             );
//           }

//           if (state is GetProductFetchSuccess) {
//             if (state.products.isEmpty) {
//               return _buildErrorContainer(
//                 titleText: 'productNotFoundTitleLbl'.tr(context),
//                 subtitleText: 'productNotFoundDescLbl'.tr(context),
//                 onRetry: () => fetchProducts(categoryId: _selectedCategoryId.value, searchQuery: _searchController.text),
//               );
//             }

//             return PaginatedBlocListView<Product>(
//               items: state.products,
//               hasMore: context.read<GetProductCubit>().hasMoreProducts(),
//               isLoading: state.isLoading,
//               isInitialLoad: false,
//               onLoadMore: context.read<GetProductCubit>().fetchMoreProducts,
//               itemBuilder: (context, item) => BlocProvider(
//                 create: (context) => SetCartCubit(),
//                 child: Builder(
//                   builder: (_) {
//                     return _buildSingleProductContainer(item);
//                   },
//                 ),
//               ),
//             );
//           }
//           return const SizedBox();
//         },
//       ),
//     );
//   }

//   Widget _buildSingleProductContainer(Product product) {
//     return BlocListener<SetCartCubit, SetCartState>(
//       listener: (context, state) {
//         if (state is SetCartSuccess) {
//           context.read<GetProductCubit>().updateProductQuantity(productId: state.product.id.toString(), quantity: state.quantity);
//           context.read<GetCartItemCubit>().updateItemInCart(product: product, quantity: state.quantity);
//         }
//       },
//       child: ProductDetailsCard(
//         key: ValueKey(product.id),
//         product: product,
//         increaseQuantityCallback: () {
//           if (context.read<GetProductCubit>().isLoading()) return;
//           context.read<SetCartCubit>().updateItemInCart(product: product, quantity: product.quantity + 1);
//         },
//         decreaseQuantityCallback: () {
//           if (context.read<GetProductCubit>().isLoading()) return;
//           context.read<SetCartCubit>().updateItemInCart(product: product, quantity: product.quantity - 1);
//         },
//       ),
//     );
//   }

//   Widget _buildCartContainer(BuildContext context) {
//     return BlocBuilder<GetCartItemCubit, GetCartItemState>(
//       builder: (context, state) {
//         if (state is GetCartItemSuccess && state.products.isNotEmpty) {
//           final totalQty = context.read<GetCartItemCubit>().getTotalProductLength();
//           final totalSum = context.read<GetCartItemCubit>().getCartTotal();
//           final formattedTotal = NumberFormat('#.##').format(totalSum);

//           return Container(
//             height: 70.sp(context),
//             padding: EdgeInsets.symmetric(horizontal: 15.sp(context)),
//             decoration: BoxDecoration(
//               color: context.colorScheme.secondary,
//               boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('totalItemsLbl'.tr(context, namedArgs: {'items': totalQty.toString()})),
//                     Text('\$$formattedTotal', style: GoogleFonts.delaGothicOne(fontSize: 16.sp(context))),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.of(context).pushNamed(Routes.orderScreen),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: context.colorScheme.primary,
//                     foregroundColor: context.colorScheme.onPrimary,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Text('confirmLbl'.tr(context)),
//                 ),
//               ],
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildErrorContainer({required String titleText, required String subtitleText, required VoidCallback onRetry}) {
//     return CustomErrorWidget(
//       retryButtonHeight: 45.sp(context),
//       title: titleText,
//       subtitle: subtitleText,
//       imageWidget: Icon(Icons.inventory_2_outlined, size: 80, color: context.colorScheme.primary.withValues(alpha:0.2)),
//       onRetry: onRetry,
//     );
//   }

//   // --- UI Builders ---

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () async {
//           _searchController.clear();
//           _selectedCategoryId.value = allCategoryId;
//           await fetchCategories();
//           await fetchCartProducts();
//         },
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: CustomPaddingWidget.symmetric(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     _buildSearchbarContainer(),
//                     _buildCategorySection(),
//                     _buildProductSection(),
//                   ],
//                 ),
//               ),
//             ),
//             _buildCartContainer(context),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/widgets/customWidget/Custom_marquee_text.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({required this.shopDetails, super.key});
  final Shop shopDetails;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
  static Route<ProductListScreen> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(builder: (_) => ProductListScreen(shopDetails: args?['shopDetails'] as Shop? ?? Shop.fromJson(const {})));
  }
}

class _ProductListScreenState extends State<ProductListScreen> {
  // --- Variables & Controllers ---
  int productCount = 10;
  String _previousQuery = '';
  static const int allCategoryId = -1;

  final ScrollController scrollerController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);
  final ValueNotifier<int> _selectedCategoryId = ValueNotifier<int>(allCategoryId);

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      fetchCategories();
      fetchCartProducts();
    });
    _searchController.addListener(_onSearchChanged);
    scrollerController.addListener(() {
      if (scrollerController.position.pixels == scrollerController.position.maxScrollExtent) {
        context.read<GetProductCubit>().fetchMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _selectedCategoryId.dispose();
    scrollerController.dispose();
    _debouncer.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Business Logic Methods ---
  void _onSearchChanged() {
    final currentQuery = _searchController.text;
    if (currentQuery != _previousQuery) {
      _previousQuery = currentQuery;
      _debouncer.run(() {
        _selectedCategoryId.value = -1;
        fetchProducts(categoryId: _selectedCategoryId.value, searchQuery: currentQuery);
      });
    }
  }

  Future<void> fetchProducts({String searchQuery = '', int categoryId = allCategoryId}) async {
    context.read<GetProductCubit>().fetchGetProduct(categoryId: categoryId, searchQuery: searchQuery);
  }

  Future<void> fetchCategories() async {
    await context.read<GetCategoryCubit>().fetchGetCategory();
  }

  Future<void> fetchCartProducts() async {
    context.read<GetCartItemCubit>().featchCartProducts();
  }

  // --- Extracted UI Sections ---

  Widget _buildCategorySection() {
    return BlocConsumer<GetCategoryCubit, GetCategoryState>(
      listener: (context, state) {
        if (state is GetCategoryFetchSuccess) {
          fetchProducts(categoryId: _selectedCategoryId.value);
        }
      },
      builder: (context, state) {
        if (state is GetCategoryFetchSuccess && state.categories.isNotEmpty) {
          return _buildCategoryListSection(categories: state.categories);
        }
        if (state is GetCategoryFetchFailure || (state is GetCategoryFetchSuccess && state.categories.isEmpty)) {
          return Expanded(
            child: _buildErrorContainer(
              onRetry: fetchCategories,
              titleText: 'categoryNotFoundTitleLbl'.tr(context),
              subtitleText: 'categoryNotFoundDescLbl'.tr(context),
            ),
          );
        }
        if (state is GetCategoryInitial || state is GetCategoryInProgress) {
          return const Expanded(child: Center(child: CustomCircularProgressIndicator()));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProductSection() {
    return BlocBuilder<GetCategoryCubit, GetCategoryState>(
      builder: (context, state) {
        if (state is GetCategoryFetchSuccess && state.categories.isNotEmpty) {
          return Expanded(
            child: BlocConsumer<GetProductCubit, GetProductState>(
              listener: (context, state) {
                if (state is GetProductFetchSuccess) {
                  if (state.isError) {
                    context.showSnackBar(
                      message: state.exception!.errorMessageKey,
                      backgroundColor: context.colorScheme.error,
                    );
                  }

                  final getCartItemCubit = context.read<GetCartItemCubit>().getCartProducts();

                  if (getCartItemCubit.isNotEmpty) {
                    context.read<GetProductCubit>().updateProductQuantityForCart(getCartItemCubit);
                  }
                }
              },
              builder: (context, state) {
                state.log('GetProductCubit');
                if (state is GetProductInProgress) {
                  return const Center(child: CustomCircularProgressIndicator());
                }
                if (state is GetProductFetchFailure) {
                  return _buildErrorContainer(
                    titleText: 'productNotFoundTitleLbl'.tr(context),
                    subtitleText: state.exception.errorMessageKey,
                    onRetry: () => fetchProducts(categoryId: _selectedCategoryId.value),
                  );
                }
                if (state is GetProductFetchSuccess) {
                  return Container(
                    child: state.products.isEmpty
                        ? _buildErrorContainer(
                            titleText: 'productNotFoundTitleLbl'.tr(context),
                            subtitleText: 'productNotFoundDescLbl'.tr(context),
                            onRetry: () => fetchProducts(categoryId: _selectedCategoryId.value),
                          )
                        : PaginatedBlocListView<Product>(
                            items: state.products,
                            physics: const AlwaysScrollableScrollPhysics(),
                            hasMore: context.read<GetProductCubit>().hasMoreProducts(),
                            isLoading: state.isLoading,
                            isInitialLoad: false,
                            onLoadMore: context.read<GetProductCubit>().fetchMoreProducts,
                            itemBuilder: (context, item) => BlocProvider(
                              create: (context) => SetCartCubit(),
                              child: _buildSingleProductContainer(item),
                            ),
                          ),
                  );
                }
                return const SizedBox();
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  // --- Private UI Helper Widgets ---

  Widget _buildHeader() {
    return CustomAppBar(
      backgroundColor: context.colorScheme.secondary,
      elevation: 0,
      title: 'productsLbl'.tr(context),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildSearchbarContainer() {
    return CustomTextField(
      controller: _searchController,
      contentPadding: EdgeInsets.zero,
      borderRadius: 15.sp(context),
      fillColor: context.colorScheme.secondary,
      prefixIcon: Icon(
        Icons.search,
        size: 25.sp(context),
        color: context.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      hintText: 'searchProductLbl'.tr(context),
      hintFontSize: 15.sp(context),
      fontSize: 17.sp(context),
    );
  }

  Widget _buildCategoryListSection({required List<ProductCategory> categories}) {
    return Container(
      height: 45.sp(context),
      margin: EdgeInsets.symmetric(vertical: 10.sp(context)),
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedCategoryId,
        builder: (context, currentSelectedId, _) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = currentSelectedId == category.id;
              return GestureDetector(
                onTap: () {
                  if (_selectedCategoryId.value == category.id) return;
                  _selectedCategoryId.value = category.id;
                  fetchProducts(categoryId: _selectedCategoryId.value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 10.sp(context)),
                  padding: EdgeInsets.symmetric(horizontal: 20.sp(context)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? context.colorScheme.primary : context.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8.sp(context)),
                    boxShadow: isSelected ? [BoxShadow(color: context.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp(context),
                      color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSingleProductContainer(Product product) {
    return Builder(
      builder: (context) {
        return BlocListener<SetCartCubit, SetCartState>(
          listener: (context, state) {
            if (state is SetCartSuccess) {
              context.read<GetProductCubit>().updateProductQuantity(productId: state.product.id.toString(), quantity: state.quantity);
              context.read<GetCartItemCubit>().updateItemInCart(product: product, quantity: state.quantity);
              context.read<SetCartCubit>().reset();
            }
          },
          child: ProductDetailsCard(
            key: ValueKey(product.id),
            product: product,
            onTapQuantity: () {
              // Check if loading
              if (context.read<GetProductCubit>().isLoading()) {
                context.showSnackBar(message: 'oneProcessAreRunning'.tr(context), backgroundColor: context.colorScheme.error);
                return;
              }

              // OPEN THE NEW BOTTOM SHEET
              showQuantityBottomSheet(
                context,
                product: product,
                onUpdate: (newQty) {
                  // Call Bloc with the final value from sheet
                  context.read<SetCartCubit>().updateItemInCart(product: product, quantity: newQty);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCartContainer(BuildContext context) {
    return BlocBuilder<GetCartItemCubit, GetCartItemState>(
      builder: (context, state) {
        state.log('GetCartItemCubit');
        if (state is GetCartItemSuccess) {
          if (state.products.isEmpty) return const SizedBox();
          final totalQty = context.read<GetCartItemCubit>().getTotalProductLength();
          final totalSum = context.read<GetCartItemCubit>().getCartTotal();
          final formattedTotal = NumberFormat('#.##').format(totalSum);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70.sp(context),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: context.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 5))],
              color: context.colorScheme.secondary,
            ),
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15.sp(context)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          constraints.log('constraints');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'totalItemsLbl'.tr(context, namedArgs: {'items': totalQty.toString()}),
                                style: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                              ),
                              CustomMarqueeTextWithIcon(
                                width: constraints.maxWidth,
                                text: '$currencySymbol $formattedTotal ',
                                textStyle: GoogleFonts.nunito(
                                  textStyle: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                                ),
                              ),

                              // Text(
                              //   '$currencySymbol $formattedTotal',
                              //   style: GoogleFonts.nunito(
                              //     textStyle: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                              //   ),
                              // ),
                            ],
                          );
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(Routes.orderScreen, arguments: {'shopDetails': widget.shopDetails}),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary,
                          borderRadius: BorderRadius.circular(15.sp(context)),
                          boxShadow: [BoxShadow(color: context.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        width: constraints.maxWidth * 0.45,
                        height: constraints.maxHeight * 0.6,
                        child: Center(
                          child: Text(
                            'confirmLbl'.tr(context),
                            style: TextStyle(fontSize: 18.sp(context), color: context.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return Container();
      },
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
  } // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          fetchCategories();
          fetchCartProducts();
          _selectedCategoryId.value = -1;
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomPaddingWidget.symmetric(
                child: Column(
                  children: [
                    SizedBox(height: 10.sp(context)),
                    _buildSearchbarContainer(),
                    _buildCategorySection(),
                    _buildProductSection(),
                  ],
                ),
              ),
            ),
            _buildCartContainer(context),
          ],
        ),
      ),
    );
  }
}
