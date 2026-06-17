// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_appbar_widget.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_padding_widget.dart';
// import 'package:omkar_sale/utils/extensions/num_extensions.dart';
// import 'package:omkar_sale/utils/extensions/string_extensopns.dart';
// import 'package:omkar_sale/utils/extensions/theme_extensions.dart';

// class SettingScreen extends StatefulWidget {
//   const SettingScreen({super.key});

//   @override
//   State<SettingScreen> createState() => _SettingScreenState();
// }

// class _SettingScreenState extends State<SettingScreen> {
//   bool isNotificationEnabled = true;

//   @override
//   Widget build(BuildContext context) {
//     final surfaceColor = context.colorScheme.secondary;
//     final primaryColor = Theme.of(context).primaryColor;

//     return Scaffold(
//       backgroundColor: context.colorScheme.surface,
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: CustomPaddingWidget.symmetric(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 20.sp(context)),

//                     // Improved Profile Section
//                     _buildCurrentUserDetailsContainer(),

//                     SizedBox(height: 32.sp(context)),

//                     // Management Section
//                     _buildSectionHeader("MANAGEMENT"),
//                     _buildManagementTile(
//                       icon: Icons.receipt_long,
//                       title: "Order History",
//                       subtitle: "View past transactions",
//                       iconBg: Colors.blue.withValues(alpha: 0.1),
//                       iconColor: Colors.blue,
//                       surfaceColor: surfaceColor,
//                     ),
//                     SizedBox(height: 12.sp(context)),
//                     _buildManagementTile(
//                       icon: Icons.groups,
//                       title: "Clients",
//                       subtitle: "Manage customer list",
//                       iconBg: Colors.purple.withValues(alpha: 0.1),
//                       iconColor: Colors.purple,
//                       surfaceColor: surfaceColor,
//                     ),

//                     SizedBox(height: 32.sp(context)),

//                     // General Section (Grouped)
//                     _buildSectionHeader("GENERAL"),
//                     _buildGroupedSection(surfaceColor, [
//                       _buildGeneralTile(
//                         icon: Icons.notifications,
//                         title: "Notifications",
//                         iconBg: Colors.amber.withValues(alpha: 0.1),
//                         iconColor: Colors.amber,
//                         trailing: Switch(value: isNotificationEnabled, onChanged: (v) => setState(() => isNotificationEnabled = v), activeTrackColor: primaryColor, activeThumbColor: Colors.white),
//                       ),
//                       _buildGeneralTile(icon: Icons.dark_mode, title: "Appearance", iconBg: Colors.blueGrey.withValues(alpha: 0.1), iconColor: Colors.blueGrey, trailingText: "System"),
//                       _buildGeneralTile(icon: Icons.lock, title: "Privacy & Security", iconBg: Colors.teal.withValues(alpha: 0.1), iconColor: Colors.teal, isLast: true),
//                     ]),

//                     SizedBox(height: 32.sp(context)),
//                     _buildLogoutButton(surfaceColor),

//                     SizedBox(height: 24.sp(context)),
//                     Center(
//                       child: Text(
//                         "APP VERSION 2.4.0",
//                         style: TextStyle(fontSize: 10.sp(context), fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
//                       ),
//                     ),
//                     SizedBox(height: 40.sp(context)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return CustomAppBar(
//       backgroundColor: context.colorScheme.secondary,
//       elevation: 0,
//       title: "Settings", // "settingLbl".tr(context)
//       centerTitle: true,
//       roundedAppBar: true,
//       automaticallyImplyLeading: false,
//     );
//   }

//   /// IMPROVED Profile Container matching the HTML Design
//   Widget _buildCurrentUserDetailsContainer() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(24.sp(context)),
//       child: Container(
//         padding: EdgeInsets.all(20.sp(context)),
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: context.colorScheme.secondary,
//           border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
//         ),
//         child: Row(
//           children: [
//             // User Avatar with Ring
//             Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(18.sp(context)),
//                 boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16.sp(context)),
//                 child: Image.network(
//                   'https://lh3.googleusercontent.com/aida-public/AB6AXuCCJ0RRrkff5nGqiJhMknSISs_Y3ueSqBKospeC26EKNBAN8OUje1U4fpMwnjakpyZClAfMxY2sfxxBcEuVlkgATQQyA-ffOT2lApFaIUJeafvAwSiu2xJJmt3wHPmeI6d-w_OCBKitkXP1C7v5T_SvBMLTpwPK8sgILpvPoBKCCUNgYBdzQurK_yw0XnUdtnETvkHIeuByzeiXMTmshyZaj6ayfq7nICg3HIIdYKZFMLLEWdZHJtwaFyrI9W1yOX4SWTw9Y9KAh_4',
//                   width: 65.sp(context),
//                   height: 65.sp(context),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             SizedBox(width: 16.sp(context)),
//             // Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Alex Morgan Alex Morgan Alex Morgan Alex Morgan ",
//                     style: GoogleFonts.manrope(fontSize: 18.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.onSurface),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     "Sales Representative",
//                     style: TextStyle(fontSize: 14.sp(context), color: Colors.grey),
//                   ),
//                   SizedBox(height: 8.sp(context)),
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8.sp(context), vertical: 2.sp(context)),
//                         decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.sp(context))),
//                         child: Text(
//                           "ACTIVE",
//                           style: TextStyle(fontSize: 10.sp(context), color: Colors.green, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       SizedBox(width: 8.sp(context)),
//                       Text(
//                         "ID: #88392",
//                         style: TextStyle(fontSize: 10.sp(context), color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Edit Button
//             // Container(
//             //   padding: EdgeInsets.all(8.sp(context)),
//             //   decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), shape: BoxShape.circle),
//             //   child: Icon(Icons.edit, size: 20.sp(context), color: Colors.grey),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: EdgeInsets.only(left: 8.sp(context), bottom: 16.sp(context)),
//       child: Text(
//         title,
//         style: GoogleFonts.manrope(fontSize: 12.sp(context), fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
//       ),
//     );
//   }

//   Widget _buildManagementTile({required IconData icon, required String title, required String subtitle, required Color iconBg, required Color iconColor, required Color surfaceColor}) {
//     return Container(
//       padding: EdgeInsets.all(16.sp(context)),
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(20.sp(context)),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12.sp(context)),
//             decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12.sp(context))),
//             child: Icon(icon, color: iconColor),
//           ),
//           SizedBox(width: 16.sp(context)),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupedSection(Color surfaceColor, List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(20.sp(context)),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
//       ),
//       child: Column(children: children),
//     );
//   }

//   Widget _buildGeneralTile({required IconData icon, required String title, required Color iconBg, required Color iconColor, Widget? trailing, String? trailingText, bool isLast = false}) {
//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16.0.sp(context)),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.sp(context)),
//                 decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8.sp(context))),
//                 child: Icon(icon, color: iconColor, size: 20.sp(context)),
//               ),
//               SizedBox(width: 12.sp(context)),
//               Expanded(
//                 child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//               ),
//               if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               trailing ?? Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp(context)),
//             ],
//           ),
//         ),
//         if (!isLast) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 16.sp(context), endIndent: 16.sp(context)),
//       ],
//     );
//   }

//   Widget _buildLogoutButton(Color surfaceColor) {
//     return Container(
//       width: double.infinity,
//       height: 56.sp(context),
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(16.sp(context)),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 2),
//       ),
//       child: TextButton(
//         onPressed: () {
//           // Add Logout Logic
//         },
//         child: const Text(
//           "Log Out",
//           style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class SettingsItem {
  const SettingsItem({required this.key, required this.icon, required this.title, required this.iconBg, required this.iconColor, this.subtitle, this.trailing, this.trailingText});
  final String key;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconBg;
  final Color iconColor;
  final Widget? trailing;
  final String? trailingText;
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late final List<SettingsItem> managementList = [
    SettingsItem(
      key: 'orderHistory',
      icon: Icons.receipt_long,
      title: 'orderHistoryLbl',
      subtitle: 'viewPastTransactionsLbl'.tr(context),
      iconBg: Colors.blue.withValues(alpha: 0.1),
      iconColor: Colors.blue,
    ),
    SettingsItem(
      key: 'clients',
      icon: Icons.groups,
      title: 'addShopLbl',
      subtitle: 'manageShopListLbl'.tr(context),
      iconBg: Colors.purple.withValues(alpha: 0.1),
      iconColor: Colors.purple,
    ),
    SettingsItem(
      key: 'achievement',
      icon: Icons.emoji_events,
      title: 'achievementsLbl',
      subtitle: 'manageAchievementsLbl'.tr(context),
      iconBg: Colors.orange.withValues(alpha: 0.1),
      iconColor: Colors.orange,
    ),
    SettingsItem(
      key: 'shopWiseItems',
      icon: Icons.inventory_2_outlined,
      title: 'shopWiseItemsLbl',
      subtitle: 'manageShopWiseItemsLbl'.tr(context),
      iconBg: Colors.teal.withValues(alpha: 0.1),
      iconColor: Colors.teal,
    ),
  ];
  late final List<SettingsItem> generalList = [
    SettingsItem(
      key: 'notifications',
      icon: Icons.notifications,
      title: 'notificationsLbl',
      iconBg: Colors.amber.withValues(alpha: 0.1),
      iconColor: Colors.amber,
    ),

    SettingsItem(key: 'Theme', icon: Icons.dark_mode, title: 'themeLbl', iconBg: Colors.blueGrey.withValues(alpha: 0.1), iconColor: Colors.blueGrey),
    SettingsItem(key: 'privacyPolicy', icon: Icons.lock, title: 'privacyPolicyLbl', iconBg: Colors.teal.withValues(alpha: 0.1), iconColor: Colors.teal),
  ];

  void _buttonOntap({required String buttonKey}) {
    switch (buttonKey) {
      case 'orderHistory':
        Navigator.of(context).pushNamed(Routes.orderHistoryScreen);
      // case 'clients':
      //   Navigator.of(context).pushNamed(Routes.customerListScreen);
      case 'shopWiseItems':
        Navigator.of(context).pushNamed(Routes.customerListScreen, arguments: {'isShowShopInventory': true});
      case 'clients':
        Navigator.of(context).pushNamed(Routes.createShopScreen);
      case 'achievement':
        Navigator.of(context).pushNamed(Routes.achievementScreen);
      case 'Theme':
        showThemeSelectorSheet(context);
      case 'privacyPolicy':
        Navigator.of(context).pushNamed(Routes.appSettingsScreen);
      case 'notifications':
        Navigator.of(context).pushNamed(Routes.notificationScreen);
    }
  }

  Widget _buildHeader() {
    return CustomAppBar(backgroundColor: context.colorScheme.secondary, elevation: 0, title: 'settingLbl'.tr(context), automaticallyImplyLeading: false);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 5.sp(context), bottom: 10.sp(context)),
      child: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 12.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.onSurface.withValues(alpha: 0.7), letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String buttonKey,
    required IconData icon,
    required String title,
    required Color iconBg,
    required Color iconColor,
    String? subtitle,
    Widget? trailing,
    String? trailingText,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _buttonOntap(buttonKey: buttonKey);
          },
          child: Container(
            padding: EdgeInsets.all(16.sp(context)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.sp(context)),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10.sp(context))),
                  child: Icon(icon, color: iconColor, size: 20.sp(context)),
                ),
                SizedBox(width: 14.sp(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.tr(context),
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp(context), color: context.colorScheme.onSurface),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12.5.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                    ],
                  ),
                ),
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: TextStyle(fontSize: 12.sp(context), color: Colors.grey),
                  ),
                trailing ?? Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp(context)),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: context.colorScheme.onSecondary.withValues(alpha: 0.2), indent: 16.sp(context), endIndent: 16.sp(context)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return CustomRoundedButtonWidget(
      onPressed: () {
        if (context.read<UserDetailsCubit>().getCurrentUser().hasClockedIn) {
          context.showSnackBar(message: 'firstClockOutThenYouCanLogOutLbl'.tr(context), backgroundColor: context.colorScheme.error);
          return;
        }
        showLogoutConfirmationDialog(context);
      },
      text: 'logOutLbl'.tr(context),
      textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold, color: context.colorScheme.primary),
      backgroundColor: context.colorScheme.secondary,
      borderSide: BorderSide(color: context.colorScheme.primary),
    );

    // return Container(
    //   width: double.infinity,
    //   height: 56.sp(context),
    //   decoration: BoxDecoration(
    //     color: context.colorScheme.secondary,
    //     borderRadius: BorderRadius.circular(16.sp(context)),
    //     border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.2)),
    //   ),
    //   child: TextButton(
    //     onPressed: () {
    //       if (context.read<UserDetailsCubit>().getCurrentUser().hasClockedIn) {
    //         context.showSnackBar(message: 'firstClockOutThenYouCanLogOutLbl'.tr(context), backgroundColor: context.colorScheme.error);
    //         return;
    //       }

    //       showLogoutConfirmationDialog(context);
    //     },
    //     child: Text(
    //       'logOutLbl'.tr(context),
    //       style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.sp(context)),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogOutCubit, LogOutState>(
      listener: (context, state) async {
        if (state is LogOutProgress) {
          // Custom method to show loading
          showloadingDialog(context, 'logoutInProgressLbl');
        }
        if (state is LogOutSuccess) {
          Navigator.of(context).pop();
          await LocationRepository().clearAll();
          await context.read<AuthCubit>().signOut();
          await Navigator.of(context).pushReplacementNamed(Routes.signInScreen);
        }
        if (state is LogOutFailure) {
          Navigator.of(context).pop();
          context.showSnackBar(message: state.errorMessage);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: CustomPaddingWidget.symmetric(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.sp(context)),
                      _buildCurrentUserDetailsContainer(),
                      SizedBox(height: 15.sp(context)),

                      if (context.read<UserDetailsCubit>().isUserSalesman()) ...[
                        _buildSectionHeader('managementLbl'.tr(context)),
                        Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20.sp(context)),
                            border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: List.generate(managementList.length, (index) {
                              final item = managementList[index];
                              return _buildSettingsTile(
                                buttonKey: item.key,
                                icon: item.icon,
                                title: item.title,
                                subtitle: item.subtitle,
                                iconBg: item.iconBg,
                                iconColor: item.iconColor,
                                showDivider: index != managementList.length - 1,
                              );
                            }),
                          ),
                        ),

                        SizedBox(height: 15.sp(context)),
                      ],
                      _buildSectionHeader('generalLbl'.tr(context)),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20.sp(context)),
                          border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: List.generate(generalList.length, (index) {
                            final item = generalList[index];
                            return _buildSettingsTile(
                              buttonKey: item.key,
                              icon: item.icon,
                              title: item.title,
                              subtitle: item.subtitle,
                              iconBg: item.iconBg,
                              iconColor: item.iconColor,
                              trailing: item.trailing,
                              trailingText: item.trailingText,
                              showDivider: index != generalList.length - 1,
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 32.sp(context)),
                      _buildLogoutButton(),

                      SizedBox(height: 24.sp(context)),
                      FutureBuilder<({String version, String buildCode})>(
                        future: UiUtils.getInfo(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final (:version, :buildCode) = snapshot.data!;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 20, end: 0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) => Transform.translate(offset: Offset(0, value), child: child),
                            child: Center(
                              child: Text(
                                'App Version $version+$buildCode',
                                style: TextStyle(color: Colors.grey, fontSize: 12.sp(context)),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 40.sp(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildCurrentUserDetailsContainer() {
    return Container(
      padding: EdgeInsets.all(20.sp(context)),
      height: 120.sp(context),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.sp(context)),
        border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final smallerSize = constraints.maxHeight < constraints.maxWidth ? constraints.maxHeight : constraints.maxWidth;
          return BlocBuilder<UserDetailsCubit, UserDetailsState>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                final userDetails = state.userDetail;
                return Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.sp(context)),
                      child: Container(
                        height: smallerSize,
                        width: smallerSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.sp(context)),
                        ),
                        child: userDetails.imageUrl.isNotEmpty
                            ? CustomImageWidget(imagePath: userDetails.imageUrl)
                            : Text(
                                UiUtils.twoCharacterString(userDetails.name),
                                style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold, fontSize: 25.sp(context)),
                              ),
                      ),
                    ),
                    Container(width: 15.sp(context)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userDetails.name,
                            style: GoogleFonts.manrope(
                              textStyle: TextStyle(fontSize: 18.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            userDetails.email,
                            style: TextStyle(fontSize: 15.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                          Text(
                            userDetails.role.name,
                            style: TextStyle(fontSize: 13.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.editProfileScreen);
                      },
                      icon: Icon(Icons.edit, size: 20.sp(context), color: context.primaryColor),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
