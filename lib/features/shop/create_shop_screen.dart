import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/cubit/create_shop.dart';
import 'package:omkar_sale/features/shop/cubit/get_shop_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<CreateShopCubit>(create: (context) => CreateShopCubit(), child: const CreateShopScreen()),
    );
  }
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  // final _zipController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _personController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _tinController = TextEditingController();

  // Focus Nodes
  final FocusNode _nameFn = FocusNode();
  final FocusNode _addressFn = FocusNode();
  final FocusNode _cityFn = FocusNode();
  //  final FocusNode _zipFn = FocusNode();
  final FocusNode _personFn = FocusNode();
  final FocusNode _phoneFn = FocusNode();
  final FocusNode _emailFn = FocusNode();
  final FocusNode _tinFn = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    //  _zipController.dispose();
    _personController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _lngController.dispose();
    _latController.dispose();
    _tinController.dispose();
    _nameFn.dispose();
    _addressFn.dispose();
    _cityFn.dispose();
    //  _zipFn.dispose();
    _personFn.dispose();
    _phoneFn.dispose();
    _emailFn.dispose();
    _tinFn.dispose();
    super.dispose();
  }

  /// TRIGGERED ONLY ON BUTTON TAP
  Future<void> _handleMapRequest() async {
    // 1. Check if Location Services (GPS Toggle) are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationServiceDialog();
      }
      return;
    }

    // 2. Check current permission status
    final status = await Permission.location.status;

    if (status.isGranted) {
      _navigateToMap();
    } else if (status.isPermanentlyDenied) {
      // User previously clicked "Don't ask again"
      if (mounted) _showPermissionDeniedDialog();
    } else {
      // Request permission for the first time or if previously denied
      final result = await Permission.location.request();
      if (result.isGranted) {
        _navigateToMap();
      } else if (result.isPermanentlyDenied) {
        if (mounted) _showPermissionDeniedDialog();
      }
    }
  }

  /// Dialog to prompt user to turn on GPS
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('locationServiceDisabled'.tr(context)),
        content: Text('pleaseEnableGPS'.tr(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancelLbl'.tr(context))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: Text('settingsLbl'.tr(context)),
          ),
        ],
      ),
    );
  }

  /// Dialog to prompt user to open App Settings if permission is permanently denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('permissionDenied'.tr(context)),
        content: Text('locationPermissionRequired'.tr(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancelLbl'.tr(context))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('openSettings'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToMap() async {
    final result = await Navigator.of(context).pushNamed(Routes.streetMapPicker);
    if (result != null && result is Map) {
      final coords = result['latlng'] as LatLng;
      setState(() {
        _latController.text = coords.latitude.toStringAsFixed(6);
        _lngController.text = coords.longitude.toStringAsFixed(6);
        _addressController.text = result['address']?.toString() ?? '';
        _cityController.text = result['city']?.toString() ?? '';
        // _zipController.text = result['zip']?.toString() ?? '';
      });
    }
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30.sp(context),
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 10.sp(context)),
      color: context.colorScheme.primary.withValues(alpha: 0.5),
    );
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   state.log();
  //   if (state == AppLifecycleState.resumed || state == AppLifecycleState.inactive) {
  //     await _checkCurrentPermissionStatus();
  //   }
  // }

  // Future<void> _checkCurrentPermissionStatus() async {
  //   final isServiceEnabled = await Geolocator.isLocationServiceEnabled();

  //   final status = await Permission.location.status;

  //   if (!isServiceEnabled) {
  //     Print('The GPS Switch in the notification bar is OFF');
  //     context.showSnackBar(message: 'locationPermissionDeniedLbl'.tr(context));
  //     Navigator.of(context).pop();

  //     return;
  //   }

  //   if (status.isDenied) {
  //     Print('The App Permission in Settings is DENIED');
  //     return;
  //   }

  //   Print('Both Service and Permission are OK');
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.read<CreateShopCubit>().state is CreateShopInProgress) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'registerShopLbl'.tr(context)),
        body: CustomPaddingWidget.symmetric(
          child: Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 20.sp(context)),
                    physics: const BouncingScrollPhysics(),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('ShopIdentity'.tr(context)),
                        CustomTextField(
                          controller: _nameController,
                          focusNode: _nameFn,
                          nextFocus: _addressFn,
                          fillColor: context.colorScheme.secondary,
                          hintText: 'EnterShopNameLbl'.tr(context),
                          prefixIcon: Icon(Icons.store_rounded, color: context.primaryColor),
                          validator: (v) => Validator.isTextFieldEmpty(value: v, context: context, errorMessage: 'shopNameAreRequiredLbl'.tr(context)),

                          textInputAction: TextInputAction.next,
                        ),

                        SizedBox(height: 25.sp(context)),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSectionHeader('LocationHub'.tr(context)), _buildMapTrigger()]),
                        CustomTextField(
                          controller: _addressController,
                          focusNode: _addressFn,
                          keyboardType: TextInputType.multiline,
                          nextFocus: _cityFn,
                          hintText: 'StreetAddressLbl'.tr(context),
                          maxLines: 5,
                          fillColor: context.colorScheme.secondary,
                          prefixIcon: Icon(Icons.location_on_rounded, color: context.primaryColor),
                          textInputAction: TextInputAction.newline,
                          validator: (v) => Validator.isTextFieldEmpty(value: v, context: context, errorMessage: 'streetAddressAreRequired'.tr(context)),
                        ),

                        SizedBox(height: 12.sp(context)),

                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _cityController,
                                focusNode: _cityFn,
                                nextFocus: _personFn,
                                hintText: 'cityLbl'.tr(context),
                                fillColor: context.colorScheme.secondary,
                                textInputAction: TextInputAction.next,
                                validator: (v) => Validator.isTextFieldEmpty(value: v, context: context, errorMessage: 'cityRequiredLbl'.tr(context)),
                              ),
                            ),
                            // SizedBox(width: 12.sp(context)),
                            // Expanded(
                            //   child: CustomTextField(
                            //     controller: _zipController,
                            //     focusNode: _zipFn,
                            //     nextFocus: _personFn,
                            //     hintText: 'zip'.tr(context),
                            //     keyboardType: TextInputType.number,
                            //     fillColor: context.colorScheme.secondary,
                            //     textInputAction: TextInputAction.next,
                            //   ),
                            // ),
                          ],
                        ),

                        SizedBox(height: 12.sp(context)),
                        _buildCoordinateDisplay(),

                        SizedBox(height: 25.sp(context)),

                        _buildSectionHeader('contactInfoLbl'.tr(context)),
                        CustomTextField(
                          controller: _personController,
                          focusNode: _personFn,
                          nextFocus: _phoneFn,
                          hintText: 'contactPersonLbl'.tr(context),
                          fillColor: context.colorScheme.secondary,
                          prefixIcon: Icon(Icons.person_outline_rounded, color: context.primaryColor),
                          textInputAction: TextInputAction.next,
                          validator: (v) => Validator.isTextFieldEmpty(value: v, context: context, errorMessage: 'contactRequiredLbl'.tr(context)),
                        ),
                        SizedBox(height: 12.sp(context)),
                        CustomTextField(
                          controller: _phoneController,
                          focusNode: _phoneFn,
                          nextFocus: _emailFn,
                          hintText: 'phoneNumberLbl'.tr(context),
                          keyboardType: TextInputType.phone,
                          fillColor: context.colorScheme.secondary,
                          prefixIcon: Icon(Icons.phone_android_rounded, color: context.primaryColor),
                          textInputAction: TextInputAction.next,
                          validator: (v) => Validator.isTextFieldEmpty(value: v, context: context, errorMessage: 'contactPersonPhoneLbl'.tr(context)),
                        ),
                        SizedBox(height: 12.sp(context)),
                        CustomTextField(
                          controller: _emailController,
                          focusNode: _emailFn,
                          nextFocus: _tinFn,
                          hintText: 'emailAddressLbl'.tr(context),
                          keyboardType: TextInputType.emailAddress,
                          fillColor: context.colorScheme.secondary,
                          textInputAction: TextInputAction.next, // LAST FIELD
                          prefixIcon: Icon(Icons.alternate_email_rounded, color: context.primaryColor),
                        ),
                        SizedBox(height: 12.sp(context)),
                        CustomTextField(
                          controller: _tinController,
                          focusNode: _tinFn,
                          hintText: 'TINNumberLbl'.tr(context),
                          keyboardType: TextInputType.emailAddress,
                          fillColor: context.colorScheme.secondary,
                          textInputAction: TextInputAction.done, // LAST FIELD
                          prefixIcon: Icon(Icons.numbers, color: context.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.sp(context), bottom: 12.sp(context)),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.w900, color: context.colorScheme.onSurface.withValues(alpha: 0.6), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMapTrigger() {
    return TextButton.icon(
      onPressed: _handleMapRequest,
      icon: Icon(Icons.map_rounded, size: 18.sp(context)),
      label: Text(
        'pickOnMapLbl'.tr(context),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp(context)),
      ),
      style: TextButton.styleFrom(
        foregroundColor: context.primaryColor,
        backgroundColor: context.primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCoordinateDisplay() {
    return Container(
      padding: EdgeInsets.all(16.sp(context)),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.sp(context)),
        border: BoxBorder.all(color: context.primaryColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'latitudeLbl'.tr(context),
                style: TextStyle(fontSize: 12.sp(context), color: context.primaryColor),
              ),
              Text(
                _latController.text.isEmpty ? '0.0' : _latController.text,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp(context)),
              ),
            ],
          ),
          _buildVerticalDivider(),
          Column(
            children: [
              Text(
                'longitudeLbl'.tr(context),
                style: TextStyle(fontSize: 12.sp(context), color: context.primaryColor),
              ),
              Text(
                _lngController.text.isEmpty ? '0.0' : _lngController.text,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<CreateShopCubit, CreateShopState>(
      listener: (context, state) {
        if (state is CreateShopFailure) {
          context.showSnackBar(message: state.exception.errorMessageKey.tr(context), backgroundColor: context.colorScheme.error);
        }
        if (state is CreateShopSuccess) {
          context.read<GetShopCubit>().addShop(state.shop);

          context.showSnackBar(message: 'shopCreatedSuccessfullyLbl'.tr(context), backgroundColor: AppThemeColors.greenColor);
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + (Platform.isIOS ? 0 : 15).sp(context)),
          child: CustomRoundedButtonWidget(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<CreateShopCubit>().createShop(
                  shopName: _nameController.text.trim(),
                  shopsAddress: _addressController.text.trim(),
                  shopCity: _cityController.text.trim(),
                  shopContactPerson: _personController.text.trim(),
                  shopPhone: _phoneController.text.trim(),
                  email: _emailController.text.trim(),
                  shopLatitude: _latController.text.trim(),
                  shopLongitude: _lngController.text.trim(),
                  shopTINnumber: _tinController.text.trim(),
                );
              }
            },
            isLoading: state is CreateShopInProgress,
            text: 'registerShopLbl'.tr(context),
            stretch: true, // Full width
            height: 56.sp(context),
            gradient: LinearGradient(colors: [context.primaryColor, context.primaryColor.withBlue(255)]),
            elevation: 8,
            borderRadius: BorderRadius.circular(16.sp(context)),
            textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_appbar_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_textformfiled_widget.dart';
// import 'package:omkar_sale/features/shop/get_shop_location_widget.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/string_extensopns.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';
// import 'package:permission_handler/permission_handler.dart'; // Required

// class CreateShopScreen extends StatefulWidget {
//   const CreateShopScreen({super.key});

//   @override
//   State<CreateShopScreen> createState() => _CreateShopScreenState();
// }

// class _CreateShopScreenState extends State<CreateShopScreen> {
//   // Controllers
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _zipController = TextEditingController();
//   final _latController = TextEditingController();
//   final _lngController = TextEditingController();
//   final _personController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();

//   // Integrated Permission Logic
//   Future<void> _handleMapRequest() async {
//     PermissionStatus status = await Permission.location.status;

//     if (status.isGranted) {
//       _navigateToMap();
//     } else {
//       PermissionStatus result = await Permission.location.request();
//       if (result.isGranted) {
//         // Callback logic here
//         Print("Location Permission Just Granted!");
//         _navigateToMap();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission is required to pick from map.")));
//       }
//     }
//   }

//   Future<void> _navigateToMap() async {
//     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const StreetMapPicker()));

//     if (result != null && result is Map) {
//       final LatLng coords = result['latlng'];
//       setState(() {
//         _latController.text = coords.latitude.toStringAsFixed(6);
//         _lngController.text = coords.longitude.toStringAsFixed(6);
//         _addressController.text = result['address'] ?? '';
//         _cityController.text = result['city'] ?? '';
//         _zipController.text = result['zip'] ?? '';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Order Details".tr(context)),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: EdgeInsets.all(20.sp(context)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionHeader("Shop Identity"),
//             _buildModernField(controller: _nameController, hint: "Shop Name", icon: Icons.store_rounded),

//             SizedBox(height: 25.sp(context)),

//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildSectionHeader("Location Hub"), _buildMapTrigger()]),
//             _buildModernField(controller: _addressController, hint: "Full Address", icon: Icons.location_on_rounded, maxLines: 2),
//             SizedBox(height: 12.sp(context)),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildModernField(controller: _cityController, hint: "City", icon: Icons.location_city),
//                 ),
//                 SizedBox(width: 12.sp(context)),
//                 Expanded(
//                   child: _buildModernField(controller: _zipController, hint: "Zip Code", icon: Icons.map_outlined),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12.sp(context)),
//             _buildCoordinateDisplay(),

//             SizedBox(height: 25.sp(context)),

//             _buildSectionHeader("Contact Info"),
//             _buildModernField(controller: _personController, hint: "Owner/Manager Name", icon: Icons.person_outline_rounded),
//             SizedBox(height: 12.sp(context)),
//             _buildModernField(controller: _phoneController, hint: "Phone Number", icon: Icons.phone_android_rounded, keyboard: TextInputType.phone),
//             SizedBox(height: 12.sp(context)),
//             _buildModernField(controller: _emailController, hint: "Email Address", icon: Icons.alternate_email_rounded, keyboard: TextInputType.emailAddress),

//             SizedBox(height: 40.sp(context)),
//             _buildSubmitButton(),
//             SizedBox(height: 20.sp(context)),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- COOL UI COMPONENTS ---

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.only(left: 4.sp(context), bottom: 12.sp(context)),
//       child: Text(
//         title.toUpperCase(),
//         style: TextStyle(fontSize: 13.sp(context), fontWeight: FontWeight.w900, color: context.colorScheme.onSurface.withValues(alpha:0.7), letterSpacing: 1.2),
//       ),
//     );
//   }

//   Widget _buildModernField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: CustomTextField(
//         controller: controller,
//         maxLines: maxLines,
//         prefixIcon: Icon(icon, color: context.primaryColor.withValues(alpha:0.7), size: 20.sp(context)),
//         hintText: hint,

//         fillColor: Colors.white,
//         hintFontSize: 15.sp(context),
//         fontSize: 17.sp(context),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.sp(context), vertical: 16.sp(context)),
//         borderRadius: 15.sp(context),
//         borderType: CustomTextFormFieldBorder.none,
//         keyboardType: keyboard,
//         errorFontSize: 8.sp(context),
//       ),

//       //  TextField(
//       //   controller: controller,
//       //   maxLines: maxLines,
//       //   keyboardType: keyboard,
//       //   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//       //   decoration: InputDecoration(
//       //     hintText: hint,
//       //     hintStyle: TextStyle(color: Colors.grey.withValues(alpha:0.5), fontWeight: FontWeight.w400),
//       //     prefixIcon: Icon(icon, color: context.primaryColor.withValues(alpha:0.7), size: 20),
//       //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
//       //     filled: true,
//       //     fillColor: Colors.white,
//       //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       //   ),
//       // ),
//     );
//   }

//   Widget _buildCoordinateDisplay() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: context.primaryColor.withValues(alpha:0.05),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: context.primaryColor.withValues(alpha:0.1)),
//       ),
//       child: Row(
//         children: [
//           _coordItem("LATITUDE", _latController),
//           Container(width: 1, height: 30, color: context.primaryColor.withValues(alpha:0.2)),
//           _coordItem("LONGITUDE", _lngController),
//         ],
//       ),
//     );
//   }

//   Widget _coordItem(String label, TextEditingController controller) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: context.primaryColor.withValues(alpha:0.5)),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             controller.text.isEmpty ? "--.------" : controller.text,
//             style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMapTrigger() {
//     return TextButton.icon(
//       onPressed: _handleMapRequest,
//       icon: Icon(Icons.map_rounded, size: 18.sp(context)),
//       label: Text(
//         "OPEN MAP",
//         style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp(context)),
//       ),
//       style: TextButton.styleFrom(
//         foregroundColor: context.primaryColor,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         backgroundColor: context.primaryColor.withValues(alpha:0.1),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(colors: [context.primaryColor, context.primaryColor.withBlue(255)]),
//         boxShadow: [BoxShadow(color: context.primaryColor.withValues(alpha:0.3), blurRadius: 15, offset: const Offset(0, 8))],
//       ),
//       child: ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//         ),
//         child: const Text(
//           "REGISTER SHOP",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:omkar_sale/features/shop/get_shop_location_widget.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// class CreateShopScreen extends StatefulWidget {
//   const CreateShopScreen({super.key});

//   @override
//   State<CreateShopScreen> createState() => _CreateShopScreenState();
// }

// class _CreateShopScreenState extends State<CreateShopScreen> {
//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipController = TextEditingController();
//   final TextEditingController _latController = TextEditingController();
//   final TextEditingController _lngController = TextEditingController();
//   final TextEditingController _personController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();

//   Future<void> _pickLocationFromMap() async {
//     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const StreetMapPicker()));

//     if (result != null && result is Map) {
//       final LatLng coords = result['latlng'];

//       setState(() {
//         _latController.text = coords.latitude.toStringAsFixed(6);
//         _lngController.text = coords.longitude.toStringAsFixed(6);

//         _addressController.text = result['address'] ?? '';
//         _cityController.text = result['city'] ?? '';
//         _zipController.text = result['zip'] ?? '';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.scaffoldBackgroundColor,
//       body: Stack(
//         children: [
//           // 1. Background Header (Now stretches a bit more for depth)
//           _buildTopHeader(),

//           // 2. Main Scroll Content
//           CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // Translucent App Bar
//               SliverAppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 pinned: true,
//                 leading: IconButton(
//                   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 centerTitle: true,
//                 title: const Text(
//                   "Register Shop",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),

//               // Use SliverPadding for the main body to ensure it stays in the sliver world
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.sp(context), vertical: 20.sp(context)),
//                 sliver: SliverList(
//                   delegate: SliverChildListDelegate([
//                     // 3. Floating Main Card
//                     _buildModernCard(
//                       label: "SHOP IDENTITY",
//                       child: _buildTextField(controller: _nameController, hint: "Enter Shop Name", icon: Icons.store_rounded),
//                     ),

//                     SizedBox(height: 24.sp(context)),

//                     // 4. Location Dashboard Widget
//                     _buildModernCard(
//                       label: "LOCATION HUB",
//                       trailing: _buildMapButton(),
//                       child: Column(
//                         children: [
//                           _buildTextField(controller: _addressController, hint: "Street Address", icon: Icons.pin_drop_rounded, maxLines: 2),
//                           const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 0.5)),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildTextField(controller: _cityController, hint: "City", icon: Icons.location_city),
//                               ),
//                               _buildVerticalDivider(),
//                               Expanded(
//                                 child: _buildTextField(controller: _zipController, hint: "Zip", icon: Icons.map_outlined),
//                               ),
//                             ],
//                           ),
//                           const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 0.5)),
//                           Row(
//                             children: [
//                               Expanded(child: _buildCoordinateCell("LAT", _latController)),
//                               _buildVerticalDivider(),
//                               Expanded(child: _buildCoordinateCell("LNG", _lngController)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     SizedBox(height: 24.sp(context)),

//                     // 5. Contact List Widget
//                     _buildModernCard(
//                       label: "CONTACT DETAILS",
//                       child: Column(
//                         children: [
//                           _buildTextField(controller: _personController, hint: "Contact Person", icon: Icons.person_rounded),
//                           const Divider(height: 24),
//                           _buildTextField(controller: _phoneController, hint: "Phone", icon: Icons.phone_android_rounded),
//                           const Divider(height: 24),
//                           _buildTextField(controller: _emailController, hint: "Email", icon: Icons.alternate_email_rounded),
//                         ],
//                       ),
//                     ),
//                   ]),
//                 ),
//               ),

//               // This pushes the button to the bottom if there is space
//               SliverFillRemaining(
//                 hasScrollBody: false,
//                 fillOverscroll: true,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.sp(context), vertical: 30.sp(context)),
//                   child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [_buildGradientButton()]),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // --- UI PIECES ---

//   Widget _buildTopHeader() {
//     return Container(
//       height: 280.sp(context), // Increased height for better coverage
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [context.primaryColor, context.primaryColor.withBlue(255)]),
//         borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
//       ),
//     );
//   }

//   Widget _buildModernCard({required String label, required Widget child, Widget? trailing}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures full width expansion
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8, bottom: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp(context),
//                   fontWeight: FontWeight.w900,
//                   color: Colors.white.withValues(alpha:0.8), // Better visibility on blue
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               if (trailing != null) trailing,
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(24), // Increased padding for "fuller" look
//           decoration: BoxDecoration(
//             color: context.colorScheme.secondary,
//             borderRadius: BorderRadius.circular(28),
//             boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.06), blurRadius: 20, offset: const Offset(0, 10))],
//           ),
//           child: child,
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: context.colorScheme.surfaceDim.withValues(alpha:0.4), fontWeight: FontWeight.normal),
//         prefixIcon: Icon(icon, color: context.primaryColor, size: 22),
//         border: InputBorder.none,
//         isDense: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 8),
//       ),
//     );
//   }

//   Widget _buildCoordinateCell(String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.primaryColor.withValues(alpha:0.6)),
//         ),
//         TextField(
//           controller: controller,
//           readOnly: true,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
//           decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "0.0000"),
//         ),
//       ],
//     );
//   }

//   Widget _buildMapButton() {
//     return GestureDetector(
//       onTap: _pickLocationFromMap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withValues(alpha:0.2), // Glassmorphism style
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withValues(alpha:0.3)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.map_rounded, size: 14, color: Colors.white),
//             const SizedBox(width: 6),
//             const Text(
//               "PICK ON MAP",
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientButton() {
//     return Container(
//       width: double.infinity,
//       height: 60.sp(context),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(colors: [context.primaryColor, context.primaryColor.withBlue(255)]),
//         boxShadow: [BoxShadow(color: context.primaryColor.withValues(alpha:0.4), blurRadius: 20, offset: const Offset(0, 10))],
//       ),
//       child: ElevatedButton(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         ),
//         child: const Text(
//           "FINALIZE & CREATE",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildVerticalDivider() {
//     return Container(height: 30, width: 1, margin: const EdgeInsets.symmetric(horizontal: 10), color: context.colorScheme.surfaceDim.withValues(alpha:0.1));
//   }
// }
