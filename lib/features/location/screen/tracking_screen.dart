// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';
// import 'package:omkar_sale/features/location/cubit/location_cubit.dart';
// import 'package:omkar_sale/features/location/screen/start_shift_screen.dart';

// class TrackingScreen extends StatelessWidget {
//   const TrackingScreen({super.key});

//   static Route<TrackingScreen> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute<TrackingScreen>(
//       settings: routeSettings,
//       builder: (_) => const TrackingScreen(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<LocationCubit, LocationState>(
//       listener: (context, state) {
//         if (!state.isClockedIn && !state.isLoading) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute<void>(builder: (_) => const StartShiftScreen()),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'trackingActiveLbl'.tr(context),
//             style: GoogleFonts.manrope(
//               fontWeight: FontWeight.bold,
//               fontSize: 18.sp(context),
//             ),
//           ),
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           actions: [
//             BlocBuilder<LocationCubit, LocationState>(
//               builder: (context, state) {  
//                 if (state.isSyncing) {
//                   return Padding(
//                     padding: EdgeInsets.only(right: 16.sp(context)),
//                     child: SizedBox(
//                       width: 20.sp(context),
//                       height: 20.sp(context),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: context.primaryColor,
//                       ),
//                     ),
//                   );
//                 }
//                 return IconButton(
//                   tooltip: 'syncDataLbl'.tr(context),
//                   icon: const Icon(Icons.sync),
//                   onPressed: () => context.read<LocationCubit>().syncData(),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             // Service Status Banner
//             Container(
//               padding: EdgeInsets.all(12.sp(context)),
//               color: context.primaryColor.withValues(alpha: 0.1),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.circle,
//                     color: Colors.green,
//                     size: 12.sp(context),
//                   ),
//                   SizedBox(width: 8.sp(context)),
//                   Text(
//                     'serviceRunningLbl'.tr(context),
//                     style: GoogleFonts.manrope(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.sp(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Location Points List
//             Expanded(
//               child: BlocBuilder<LocationCubit, LocationState>(
//                 builder: (context, state) {
//                   if (state.points.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.location_searching,
//                             size: 64.sp(context),
//                             color: context.colorScheme.onSurface.withValues(alpha: 0.3),
//                           ),
//                           SizedBox(height: 16.sp(context)),
//                           Text(
//                             'waitingForLocationLbl'.tr(context),
//                             style: GoogleFonts.manrope(
//                               fontSize: 16.sp(context),
//                               color: context.colorScheme.onSurface.withValues(alpha: 0.6),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: EdgeInsets.all(10.sp(context)),
//                     itemCount: state.points.length,
//                     itemBuilder: (context, index) {
//                       final point = state.points[index];
//                       final timeStr = point.timestamp.toIso8601String().split('T')[1].split('.')[0];

//                       return Card(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: 10.sp(context),
//                           vertical: 4.sp(context),
//                         ),
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: ListTile(
//                           leading: Container(
//                             padding: EdgeInsets.all(8.sp(context)),
//                             decoration: BoxDecoration(
//                               color: context.primaryColor.withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.place,
//                               color: context.primaryColor,
//                               size: 24.sp(context),
//                             ),
//                           ),
//                           title: Text(
//                             '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
//                             style: GoogleFonts.manrope(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14.sp(context),
//                             ),
//                           ),
//                           subtitle: Text(
//                             timeStr,
//                             style: GoogleFonts.manrope(
//                               fontSize: 12.sp(context),
//                               color: context.colorScheme.onSurface.withValues(alpha: 0.6),
//                             ),
//                           ),
//                           trailing: Text(
//                             '${point.speed.toStringAsFixed(1)} m/s',
//                             style: GoogleFonts.manrope(
//                               fontSize: 12.sp(context),
//                               fontWeight: FontWeight.w500,
//                               color: context.primaryColor,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),

//             // Stop Shift Button
//             Padding(
//               padding: EdgeInsets.all(20.sp(context)),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: BlocBuilder<LocationCubit, LocationState>(
//                   builder: (context, state) {
//                     return CustomRoundedButtonWidget(
//                       isLoading: state.isLoading,
//                       text: 'stopShiftLbl'.tr(context),
//                       stretch: true,
//                       height: 56.sp(context),
//                       textStyle: TextStyle(
//                         fontSize: 16.sp(context),
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       gradient: const LinearGradient(
//                         colors: [Colors.red, Color(0xFFD32F2F)],
//                       ),
//                       elevation: 4,
//                       borderRadius: BorderRadius.circular(16),
//                       onPressed: state.isLoading ? null : () => context.read<LocationCubit>().stopShift(),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
