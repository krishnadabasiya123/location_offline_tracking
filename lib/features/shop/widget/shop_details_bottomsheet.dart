import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class ShopDetailBottomSheet extends StatefulWidget {
  const ShopDetailBottomSheet({required this.shop, super.key});
  final Shop shop;

  @override
  State<ShopDetailBottomSheet> createState() => _ShopDetailBottomSheetState();
}

class _ShopDetailBottomSheetState extends State<ShopDetailBottomSheet> {
  @override
  Widget build(BuildContext context) {
    // Theme-based dynamic colors

    final colorScheme = context.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32.sp(context)),
          ),
        ),
        child: Column(
          children: [
            // 1. Responsive Drag Handle
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16.sp(context)),
                width: 40.sp(context),
                height: 4.sp(context),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceDim.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10.sp(context)),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.symmetric(horizontal: 24.sp(context)),
                children: [
                  // 2. Header Section
                  _buildHeader(colorScheme.primary),

                  SizedBox(height: 28.sp(context)),

                  // 3. Info Cards Row (Manager & TIN)
                  Row(
                    children: [
                      _buildStatCard(
                        'ManagerLbl'.tr(context),
                        widget.shop.contactPerson,
                        Icons.person_3_outlined,
                        AppThemeColors.linearGradientPrimary,
                      ),
                      SizedBox(width: 12.sp(context)),
                      _buildStatCard(
                        'tinNumberLbl'.tr(context),
                        widget.shop.tin,
                        Icons.verified_user_outlined,
                        AppThemeColors.processingColor,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.sp(context)),

                  // 4. High Contrast Location Card
                  _buildLocationCard(AppThemeColors.linearGradientPrimary.withValues(alpha: 0.15), AppThemeColors.linearGradientPrimary),

                  SizedBox(height: 32.sp(context)),

                  // 5. Inventory Section
                  _buildSectionHeader(
                    'productCatalogLbl'.tr(context),
                    'totalItemsLbl'.tr(context, namedArgs: {'items': widget.shop.products.length.toString()}),
                    colorScheme,
                  ),

                  SizedBox(height: 16.sp(context)),

                  if (widget.shop.products.isEmpty) _buildEmptyState() else ...widget.shop.products.map((product) => _buildProductTile(product, colorScheme)),

                  SizedBox(height: 40.sp(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Row(
      children: [
        Container(
          height: 60.sp(context),
          width: 60.sp(context),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.sp(context)),
          ),
          child: Icon(Icons.storefront_rounded, color: primary, size: 30.sp(context)),
        ),
        SizedBox(width: 16.sp(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.shop.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22.sp(context),
                  fontWeight: FontWeight.w800,
                  color: context.colorScheme.onSecondary,
                ),
              ),
              SizedBox(height: 2.sp(context)),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14.sp(context), color: context.colorScheme.surfaceDim),
                  SizedBox(width: 4.sp(context)),
                  Text(
                    widget.shop.city,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp(context),
                      color: context.colorScheme.surfaceDim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.sp(context)),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24.sp(context)),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.sp(context)),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, size: 18.sp(context), color: accent),
            ),
            SizedBox(height: 12.sp(context)),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp(context),
                color: context.colorScheme.surfaceDim,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.sp(context)),
            Text(
              value.isEmpty ? 'Not Provided' : value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp(context),
                fontWeight: FontWeight.w700,
                color: context.colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Color bg, Color primary) {
    return Container(
      padding: EdgeInsets.all(24.sp(context)),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bg.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(28.sp(context)),
        // boxShadow: [
        //   BoxShadow(
        //     color: bg.withValues(alpha:0.3),
        //     blurRadius: 20,
        //     offset: const Offset(0, 10),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_rounded, color: context.colorScheme.onSurface.withValues(alpha: 0.7), size: 20.sp(context)),
              SizedBox(width: 8.sp(context)),
              Text(
                'officialAddressLbl'.tr(context).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 10.sp(context),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp(context)),
          Text(
            widget.shop.address,
            style: GoogleFonts.plusJakartaSans(
              color: context.colorScheme.onSurface,
              fontSize: 15.sp(context),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          Divider(height: 32.sp(context), color: Colors.white10),
          Row(
            children: [
              Icon(Icons.phone_in_talk_rounded, color: context.colorScheme.onSurface, size: 18.sp(context)),
              SizedBox(width: 12.sp(context)),
              Text(
                widget.shop.contactPhone,
                style: GoogleFonts.plusJakartaSans(
                  color: context.colorScheme.onSurface,
                  fontSize: 14.sp(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp(context),
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.sp(context), vertical: 4.sp(context)),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.sp(context)),
          ),
          child: Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp(context),
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTile(Product product, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp(context)),
      padding: EdgeInsets.all(14.sp(context)),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.sp(context)),
        border: Border.all(color: colorScheme.surfaceDim.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            height: 44.sp(context),
            width: 44.sp(context),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14.sp(context)),
            ),
            child: Icon(Icons.inventory_2_rounded, color: colorScheme.primary, size: 22.sp(context)),
          ),
          SizedBox(width: 16.sp(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp(context),
                    color: colorScheme.onSecondary,
                  ),
                ),
                Text(
                  'In Stock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp(context),
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14.sp(context), color: colorScheme.surfaceDim.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.sp(context)),
        child: Text(
          'noProductAvailableLbl'.tr(context),
          style: GoogleFonts.plusJakartaSans(color: context.colorScheme.surfaceDim, fontSize: 14.sp(context)),
        ),
      ),
    );
  }
}
