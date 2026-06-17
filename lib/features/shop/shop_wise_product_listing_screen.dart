import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ShopWiseProductListingScreen extends StatefulWidget {
  const ShopWiseProductListingScreen({required this.shop, super.key});
  final Shop shop;

  @override
  State<ShopWiseProductListingScreen> createState() => _ShopWiseProductListingScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    if (routeSettings.arguments == null) {
      return CupertinoPageRoute(builder: (_) => const Scaffold());
    }
    final args = routeSettings.arguments! as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => ShopWiseProductListingScreen(shop: args['shopDetails'] as Shop),
    );
  }
}

class _ShopWiseProductListingScreenState extends State<ShopWiseProductListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.shop.name,
        backgroundColor: context.colorScheme.secondary,
      ),
      body: CustomPaddingWidget.symmetric(
        child: Column(
          children: [
            SizedBox(height: 10.sp(context)),
            // We can add search functionality later if needed, filtering the local list
            // _buildSearchContainer(),
            if (widget.shop.products.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.3)),
                      SizedBox(height: 16.sp(context)),
                      Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18.sp(context),
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 16.sp(context)),
                  itemCount: widget.shop.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.shop.products[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.sp(context)),
                      padding: EdgeInsets.all(12.sp(context)),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12.sp(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.sp(context)),
                            child: CustomImageWidget(
                              imagePath: product.image,
                              height: 60.sp(context),
                              width: 60.sp(context),
                            ),
                          ),
                          SizedBox(width: 12.sp(context)),
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 16.sp(context),
                                    fontWeight: FontWeight.w600,
                                    color: context.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4.sp(context)),
                                Text(
                                  product.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp(context),
                                    fontWeight: FontWeight.w500,
                                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                // SizedBox(height: 5.sp(context)),
                                // Text(
                                //   '$currencySymbol ${product.price}',
                                //   style: TextStyle(
                                //     fontSize: 14.sp(context),
                                //     fontWeight: FontWeight.bold,
                                //     color: context.primaryColor,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
