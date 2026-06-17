import 'package:omkar_sale/core/constants/constant.dart';

const _api = '$databaseUrl/v1';
const String loginUrl = '$_api/user/login';
//user/logout
const String logoutUrl = '$_api/user/logout';
//user/profile
const String userProfileUrl = '$_api/user/profile';
//user/update
const String updateUserProfileUrl = '$_api/user/update';
//attendances/clock-in-out
// const String clockInOutUrl = '$_api/attendances/clock-in-out';
const String clockInOutUrl = '$_api/set_attendance';
//categories
const String categoriesUrl = '$_api/categories';
//products
const String productsUrl = '$_api/products';
//customers
const String shopsUrl = '$_api/customers';
//orders
const String ordersUrl = '$_api/orders';
const String orderPdfUrl = '$_api/orders/pdf';
//delete order
const String deleteOrderUrl = '$_api/orders/destroy';
//update user location
// const String updateUserLocationUrl = '$_api/current/location/store';
const String updateUserLocationUrl = '$_api/set_location';
//store-visits/bulk
const String storeVisitsBulkUrl = '$_api/store-visits/bulk';
//agendas
const String agendasUrl = '$_api/agendas';
//agendas/completion-notes
const String agendaCompletionNotesUrl = '$_api/agendas/completion-notes';
//achievements
const String achievementsUrl = '$_api/achievements';
//settings/public-config
const String settingConfigUrl = '$_api/settings/public-config';
//settings
const String settingsUrl = '$_api/settings';
//notifications
const String notificationsUrl = '$_api/notifications';
