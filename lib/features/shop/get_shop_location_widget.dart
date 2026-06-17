import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class StreetMapPicker extends StatefulWidget {
  const StreetMapPicker({super.key});

  @override
  State<StreetMapPicker> createState() => _StreetMapPickerState();
}

class _StreetMapPickerState extends State<StreetMapPicker> with TickerProviderStateMixin {
  late MapController _mapController;

  final ValueNotifier<bool> _isMapLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String> _addressNotifier = ValueNotifier<String>('fetchingAddressLbl');

  LatLng _currentCenter = const LatLng(0, 0);

  String _city = '';
  // String _zip = '';
  String _state = '';
  String _country = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Start fetching location immediately after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationLogic(isInitialLoad: true);
    });
  }

  @override
  void dispose() {
    _isMapLoading.dispose();
    _addressNotifier.dispose();
    super.dispose();
  }

  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,}$').hasMatch(value);
  }

  String _buildFullAddress(Placemark p) {
    final parts = <String>[];
    void add(String? value) {
      if (value == null) return;
      final v = value.trim();
      if (v.isEmpty || _isPlusCode(v) || parts.contains(v)) return;
      parts.add(v);
    }

    add(p.name);
    add(p.subThoroughfare);
    add(p.thoroughfare);
    add(p.street);
    add(p.subLocality);
    add(p.locality);
    add(p.administrativeArea);
    add(p.postalCode);
    add(p.country);

    return parts.join(', ');
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    try {
      final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
      final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
      final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

      final controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
      final animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

      controller.addListener(() {
        _mapController.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
      });

      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) controller.dispose();
      });

      controller.forward();
    } catch (_) {
      _mapController.move(destLocation, destZoom);
    }
  }

  Future<void> _getAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _city = place.locality ?? '';
        //    _zip = place.postalCode ?? '';
        _state = place.administrativeArea ?? '';
        _country = place.country ?? '';

        // Update notifier without triggering full widget rebuild
        _addressNotifier.value = _buildFullAddress(place);
      }
    } catch (e) {
      _addressNotifier.value = 'addressNotFoundLbl'.tr(context);
    }
  }

  void _showEnableLocationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('enableLocation'.tr(context)),
        content: Text('locationPermissionLbl'.tr(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancelLbl'.tr(context))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: Text('enableLbl'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _initLocationLogic({bool isInitialLoad = false}) async {
    _isMapLoading.value = true;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isMapLoading.value = false;
      _showEnableLocationDialog();
      return;
    }

    try {
      // Fetch dynamic user location
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final userLoc = LatLng(position.latitude, position.longitude);
      _currentCenter = userLoc;

      _isMapLoading.value = false;

      // Move map and get address
      if (isInitialLoad) {
        _mapController.move(userLoc, 15);
      } else {
        _animatedMapMove(userLoc, 15);
      }

      await _getAddress(userLoc);
    } catch (e) {
      _isMapLoading.value = false;
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('pickShopLocationLbl'.tr(context)),
      ),
      body: Stack(
        children: [
          // THE MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15,
              onPositionChanged: (position, _) {
                _currentCenter = position.center;
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddress(_currentCenter);
                }
              },
            ),
            children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.omkar_sale.app')],
          ),

          // LOADING SPINNER (ValueNotifier)
          ValueListenableBuilder<bool>(
            valueListenable: _isMapLoading,
            builder: (context, loading, _) {
              return loading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
            },
          ),

          // CENTER PIN
          ValueListenableBuilder<bool>(
            valueListenable: _isMapLoading,
            builder: (context, loading, _) {
              if (loading) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on_rounded, size: 50, color: context.primaryColor),
                ),
              );
            },
          ),

          // BOTTOM ADDRESS BOX
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20.sp(context)),
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_outlined, color: context.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: _addressNotifier,
                          builder: (context, address, _) {
                            return Text(address.tr(context), maxLines: 3, overflow: TextOverflow.ellipsis);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: _isMapLoading,
                    builder: (context, value, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!value) {
                              Navigator.pop(context, {'latlng': _currentCenter, 'address': _addressNotifier.value, 'city': _city, 'state': _state, 'country': _country});
                            }
                            // 'zip': _zip,
                          },
                          child: Text('confirmLocationLbl'.tr(context)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // MY LOCATION BUTTON
          Positioned(
            bottom: 160.sp(context),
            right: 20,
            child: FloatingActionButton(mini: true, onPressed: _initLocationLogic, child: const Icon(Icons.my_location)),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';

// class StreetMapPicker extends StatefulWidget {
//   const StreetMapPicker({super.key});

//   @override
//   State<StreetMapPicker> createState() => _StreetMapPickerState();
// }

// class _StreetMapPickerState extends State<StreetMapPicker> with TickerProviderStateMixin, WidgetsBindingObserver {
//   late MapController _mapController;

//   // Default: India
//   LatLng _currentCenter = const LatLng(20.5937, 78.9629);
//   String _address = 'fetchingAddressLbl';
//   bool _isMapLoading = true;
//   String _city = '';
//   String _zip = '';
//   String _state = '';
//   String _country = '';

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     WidgetsBinding.instance.addObserver(this);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initLocationLogic(isInitialLoad: true);
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // -------------------- ADDRESS HELPERS --------------------

//   bool _isPlusCode(String value) {
//     return RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,}$').hasMatch(value);
//   }

//   String _buildFullAddress(Placemark p) {
//     final parts = <String>[];

//     void add(String? value) {
//       if (value == null) return;
//       final v = value.trim();
//       if (v.isEmpty) return;
//       if (_isPlusCode(v)) return;
//       if (parts.contains(v)) return;
//       parts.add(v);
//     }

//     // Order matters
//     add(p.name);
//     add(p.subThoroughfare); // house number
//     add(p.thoroughfare); // road
//     add(p.street);
//     add(p.subLocality); // area
//     add(p.locality); // city / village
//     add(p.administrativeArea); // state
//     add(p.postalCode); // pincode
//     add(p.country); // country

//     return parts.join(', ');
//   }

//   // -------------------- MAP ANIMATION --------------------

//   void _animatedMapMove(LatLng destLocation, double destZoom) {
//     try {
//       final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
//       final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
//       final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

//       final controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

//       final animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

//       controller.addListener(() {
//         _mapController.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
//       });

//       animation.addStatusListener((status) {
//         if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
//           controller.dispose();
//         }
//       });

//       controller.forward();
//     } catch (_) {
//       _mapController.move(destLocation, destZoom);
//     }
//   }

//   // -------------------- ADDRESS FETCH --------------------

//   Future<void> _getAddress(LatLng position) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

//       if (placemarks.isNotEmpty && mounted) {
//         final place = placemarks.first;

//         log(place.toJson().toString());

//         final fullAddress = _buildFullAddress(place);

//         setState(() {
//           _address = fullAddress;
//           _city = place.locality ?? '';
//           _zip = place.postalCode ?? '';
//           _state = place.administrativeArea ?? '';
//           _country = place.country ?? '';
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _address = 'addressNotFoundLbl');
//     }
//   }

//   // -------------------- PERMISSION DIALOGS --------------------

//   void _showEnableLocationDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('enableLocation'.tr(context)),
//         content: Text('locationPermissionLbl'.tr(context)),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: Text('cancelLbl'.tr(context)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Geolocator.openLocationSettings();
//             },
//             child: Text('enableLbl'.tr(context)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('permissionRequestLbl'.tr(context)),
//         content: Text('locationPermissionDeniedLbl'.tr(context)),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text('cancelLbl'.tr(context))),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Geolocator.openAppSettings();
//             },
//             child: Text('openSettingLbl'.tr(context)),
//           ),
//         ],
//       ),
//     );
//   }

//   // -------------------- LOCATION LOGIC --------------------

//   Future<void> _initLocationLogic({bool isInitialLoad = false}) async {
//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();

//     if (!serviceEnabled) {
//       if (mounted) setState(() => _isMapLoading = false);
//       _showEnableLocationDialog();
//       return;
//     }

//     var permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (mounted) setState(() => _isMapLoading = false);
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showPermissionDeniedDialog();
//       return;
//     }

//     try {
//       final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//       final userLoc = LatLng(position.latitude, position.longitude);

//       if (!mounted) return;

//       setState(() {
//         _currentCenter = userLoc;
//         _isMapLoading = false;
//       });

//       await _getAddress(userLoc);

//       if (isInitialLoad) {
//         _mapController.move(userLoc, 15);
//       } else {
//         _animatedMapMove(userLoc, 15);
//       }
//     } catch (_) {
//       if (mounted) setState(() => _isMapLoading = false);
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _initLocationLogic();
//     }
//   }

//   // -------------------- UI --------------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('pickShopLocationLbl'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentCenter,
//               initialZoom: 15,
//               onPositionChanged: (position, _) {
//                 _currentCenter = position.center;
//               },
//               onMapEvent: (event) {
//                 if (event is MapEventMoveEnd) {
//                   _getAddress(_currentCenter);
//                 }
//               },
//             ),
//             children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.omkar_sale.app')],
//           ),

//           if (_isMapLoading) const Center(child: CircularProgressIndicator()),

//           if (!_isMapLoading)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 40),
//                 child: Icon(Icons.location_on_rounded, size: 50, color: context.primaryColor),
//               ),
//             ),

//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: EdgeInsets.all(20.sp(context)),
//               decoration: BoxDecoration(
//                 color: context.colorScheme.secondary,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.map_outlined, color: context.primaryColor),
//                       const SizedBox(width: 10),
//                       Expanded(child: Text(_address.tr(context), maxLines: 3, overflow: TextOverflow.ellipsis)),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context, {'latlng': _currentCenter, 'address': _address, 'city': _city, 'zip': _zip, 'state': _state, 'country': _country});
//                       },

//                       child: Text('confirmLocationLbl'.tr(context)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           Positioned(
//             bottom: 160.sp(context),
//             right: 20,
//             child: FloatingActionButton(mini: true, onPressed: _initLocationLogic, child: const Icon(Icons.my_location)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// class StreetMapPicker extends StatefulWidget {
//   const StreetMapPicker({super.key});

//   @override
//   State<StreetMapPicker> createState() => _StreetMapPickerState();
// }

// class _StreetMapPickerState extends State<StreetMapPicker> {
//   late MapController _mapController;

//   // Default fallback (India)
//   LatLng _currentCenter = const LatLng(20.5937, 78.9629);
//   bool _isMapLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     // Start permission and location logic immediately
//     _initLocationLogic();
//   }

//   Future<void> _initLocationLogic() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     try {
//       // 1. Check if location services are enabled
//       serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         // Services are disabled, use default
//         _finishSetup();
//         return;
//       }

//       // 2. Check Permission Status
//       permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         // Request Permission
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           // Denied again, use default
//           _finishSetup();
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         // Permissions are permanently denied, use default
//         _finishSetup();
//         return;
//       }

//       // 3. If we reached here, permission is GRANTED
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         _currentCenter = LatLng(position.latitude, position.longitude);
//         _isMapLoading = false;
//       });
//     } catch (e) {
//       // Any error (timeout, etc), fallback to default
//       Print("Location Error: $e");
//       _finishSetup();
//     }
//   }

//   void _finishSetup() {
//     setState(() {
//       _isMapLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pick Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
//       ),
//       body: _isMapLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 // THE MAP
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _currentCenter,
//                     initialZoom: 15.0,
//                     onPositionChanged: (position, hasGesture) {
//                       // Update center variable as user drags the map
//                       _currentCenter = position.center;
//                     },
//                   ),
//                   children: [
//                     TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.omkar_sale.app'),
//                     RichAttributionWidget(
//                       attributions: [
//                         TextSourceAttribution(
//                           '© OpenStreetMap contributors',
//                           onTap: () {}, // You can link to https://www.openstreetmap.org/copyright
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 // FIXED CENTER PIN (Modern UI)
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 40), // Offset for pin point
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(8)),
//                           child: const Text(
//                             "Deliver here",
//                             style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         Icon(Icons.location_on_rounded, size: 45, color: context.primaryColor),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ACTION BUTTONS
//                 Positioned(
//                   bottom: 50.sp(context),
//                   left: 20.sp(context),
//                   right: 20.sp(context),
//                   child: Column(
//                     children: [
//                       // My Location Button
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: FloatingActionButton(
//                           mini: true,
//                           backgroundColor: context.colorScheme.secondary,
//                           onPressed: () => _initLocationLogic().then((_) {
//                             _mapController.move(_currentCenter, 15.0);
//                           }),
//                           child: Icon(Icons.my_location, color: context.primaryColor),
//                         ),
//                       ),
//                       SizedBox(height: 16.sp(context)),

//                       // CONFIRM BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         height: 55,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: context.primaryColor,
//                             foregroundColor: Colors.white,
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           onPressed: () {
//                             // POP WITH COORDINATES
//                             Navigator.pop(context, _currentCenter);
//                           },
//                           child: const Text("Confirm Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
