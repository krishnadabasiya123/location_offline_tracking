import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/widget/shop_details_bottomsheet.dart';

class ShopCard extends StatefulWidget {
  const ShopCard({required this.shop, super.key, this.onTap});
  final Shop shop;
  final Function? onTap;

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  // Helper method to get initials (e.g., "Sunrise Market" -> "SM")
  Future<void> _showShopDetailsWithBottomSheet(BuildContext context, Shop shop) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: FractionallySizedBox(
            heightFactor: 0.85, // Opens to 85% of screen height
            child: ShopDetailBottomSheet(shop: shop),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp(context)),
      child: InkWell(
        onTap: () {
          if (widget.onTap != null) widget.onTap?.call();

          //    _showShopDetailsWithBottomSheet(context, widget.shop);
        },
        child: Container(
          // margin: EdgeInsets.only(bottom: 16.sp(context)),
          padding: EdgeInsets.all(16.sp(context)),
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.35)),
            boxShadow: [BoxShadow(color: context.colorScheme.onSecondary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SHOP AVATAR WITH INITIALS ---
                  Container(
                    height: 48.sp(context),
                    width: 48.sp(context),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: context.primaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Text(
                      UiUtils.twoCharacterString(widget.shop.name),
                      style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold, fontSize: 16.sp(context)),
                    ),
                  ),
                  SizedBox(width: 12.sp(context)),
                  // --- SHOP INFO ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shop.name,
                          style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.shop.address.isNotEmpty) ...[
                          SizedBox(height: 4.sp(context)),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                              SizedBox(width: 4.sp(context)),
                              Expanded(
                                child: Text(
                                  widget.shop.address,
                                  style: TextStyle(fontSize: 13.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sp(context)),
                child: Divider(height: 1, color: context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.shop.contactPerson.isNotEmpty) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person_rounded, size: 16.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                          SizedBox(width: 5.sp(context)),
                          Expanded(
                            child: Text(
                              widget.shop.contactPerson,
                              style: TextStyle(fontSize: 14.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.8)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(),
                  ],
                  Row(
                    children: [
                      Text(
                        'detailsLbl'.translate(context), // Using your translate extension
                        style: TextStyle(color: context.primaryColor, fontSize: 14.sp(context)),
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.primaryColor, size: 20.sp(context)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
