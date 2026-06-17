import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/commons/screen/maintenance_mode_screen.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/achievement/achievement_screen.dart';
import 'package:omkar_sale/features/order/screen/pdf_viewer_screen.dart';
import 'package:omkar_sale/features/order/screen/widget/order_bottamsheet.dart';
import 'package:omkar_sale/features/reports/daily_report_list_screen.dart';
import 'package:omkar_sale/features/setting/app_setting_screen.dart';
import 'package:omkar_sale/features/setting/notification_screen.dart';
import 'package:omkar_sale/features/shop/shop_wise_product_listing_screen.dart';

class Routes {
  static const homeScreen = '/home';
  static const splashScreen = '/';
  static const signInScreen = '/signIn';
  static const mainScreen = '/main';
  static const orderScreen = '/order';
  static const orderHistoryScreen = '/orderHistory';
  static const customerListScreen = '/customerList';
  static const submitReportScreen = '/submitReport';
  static const dailyReportListScreen = '/dailyReportList';
  static const productListingScreen = '/productListing';
  static const createShopScreen = '/createShop';
  //StreetMapPicker
  static const streetMapPicker = '/streetMapPicker';
  static const maintenanceScreen = '/maintenanceScreen';
  // shopWiseProductListingScreen
  static const shopWiseProductListingScreen = '/shopWiseProductListingScreen';
  static const achievementScreen = '/achievement';
  static const editProfileScreen = '/editProfile';
  static const appSettingsScreen = '/appSettings';
  static const notificationScreen = '/notificationScreen';
  static const orderDetailScreen = '/orderDetail';
  static const pdfViewerScreen = '/pdfViewer';

  static String currentRoute = splashScreen;

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? '';

    log(name: 'Current Route', currentRoute);
    switch (currentRoute) {
      case splashScreen:
        return SplashScreen.route(routeSettings);
      case maintenanceScreen:
        return MaintenanceModeScreen.route(routeSettings);
      case signInScreen:
        return LoginScreen.route(routeSettings);
      case mainScreen:
        return MainScreen.route(routeSettings);
      case orderScreen:
        return OrderScreen.route(routeSettings);
      case orderHistoryScreen:
        return OrderHistoryScreen.route(routeSettings);
      case customerListScreen:
        return CustomerListScreen.route(routeSettings);
      case submitReportScreen:
        return SubmitReportScreen.route(routeSettings);
      case dailyReportListScreen:
        return DailyReportListScreen.route(routeSettings);
      case streetMapPicker:
        return CupertinoPageRoute(builder: (context) => const StreetMapPicker());
      case productListingScreen:
        return ProductListScreen.route(routeSettings);
      case createShopScreen:
        return CreateShopScreen.route(routeSettings);
      case shopWiseProductListingScreen:
        return ShopWiseProductListingScreen.route(routeSettings);
      case achievementScreen:
        return AchievementScreen.route(routeSettings);
      case editProfileScreen:
        return EditProfileScreen.route(routeSettings);
      case appSettingsScreen:
        return AppSettingsScreen.route(routeSettings);
      case notificationScreen:
        return NotificationScreen.route(routeSettings);
      case orderDetailScreen:
        return OrderDetailsScreen.route(routeSettings);
      case pdfViewerScreen:
        return PdfViewerScreen.route(routeSettings);
      default:
        return CupertinoPageRoute(builder: (_) => const Scaffold());
    }
  }
}
