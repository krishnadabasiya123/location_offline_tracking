import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/achievement/cubit/get_achievement_cubit.dart';
import 'package:omkar_sale/features/achievement/cubit/set_achievement_cubit.dart';
import 'package:omkar_sale/features/achievement/model/achievement.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GetAchievementCubit()..fetchGetAchievement()),
          BlocProvider(create: (_) => SetAchievementCubit()),
        ],
        child: const AchievementScreen(),
      ),
    );
  }

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  void _openAddSheet() {
    final setCubit = context.read<SetAchievementCubit>();
    final getCubit = context.read<GetAchievementCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // Prevents closing by tapping outside
      enableDrag: false, // Prevents closing by dragging down
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getCubit),
          BlocProvider.value(value: setCubit),
        ],
        child: const _AddAchievementSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'achievementsLbl'.tr(context),
        backgroundColor: context.colorScheme.secondary,
        actions: [
          IconButton(
            onPressed: () => context.read<GetAchievementCubit>().fetchGetAchievement(),
            icon: Icon(Icons.refresh_rounded, color: context.colorScheme.onSurface),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: context.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'addNewLbl'.tr(context),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: BlocBuilder<GetAchievementCubit, GetAchievementState>(
        builder: (context, state) {
          if (state is GetAchievementFetchFailure) {
            return CustomErrorWidget(
              title: state.exception.errorMessageKey,
              errorType: state.exception.type,
              onRetry: () => context.read<GetAchievementCubit>().fetchGetAchievement(),
            );
          }

          if (state is GetAchievementFetchSuccess) {
            final achievements = state.achievements;

            return RefreshIndicator(
              onRefresh: () async => context.read<GetAchievementCubit>().fetchGetAchievement(),
              child: Column(
                children: [
                  _buildSummaryHeader(achievements),

                  Expanded(
                    child: achievements.isEmpty
                        ? CustomErrorWidget(
                            title: 'noAchievementsFoundLbl'.tr(context),
                            errorType: CustomErrorType.noDataFound,
                          )
                        : PaginatedBlocListView(
                            padding: EdgeInsets.fromLTRB(16.sp(context), 8.sp(context), 16.sp(context), 80.sp(context)),
                            hasMore: context.read<GetAchievementCubit>().hasMoreAchievements(),
                            onLoadMore: context.read<GetAchievementCubit>().fetchMoreAchievements,
                            isLoading: state.isLoading,
                            isInitialLoad: false,
                            items: state.achievements,
                            itemBuilder: (context, item) {
                              return _AchievementCard(achievement: item);
                            },
                          ),

                    // ListView.builder(
                    //     padding: EdgeInsets.fromLTRB(16.sp(context), 8.sp(context), 16.sp(context), 80.sp(context)),
                    //     itemCount: achievements.length,
                    //     itemBuilder: (context, index) {
                    //       return _AchievementCard(achievement: achievements[index]);
                    //     },
                    //   ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CustomCircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSummaryHeader(List<Achievement> list) {
    final approved = list.where((e) => e.status == AchievementStatus.approved).length;
    return Container(
      margin: EdgeInsets.all(16.sp(context)),
      padding: EdgeInsets.all(20.sp(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.sp(context)),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'yourProgressLbl'.tr(context),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.sp(context)),
              ),
              Text(
                '${list.length} ${"achievementsLbl".tr(context)}',
                style: TextStyle(color: Colors.white, fontSize: 22.sp(context), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp(context), vertical: 8.sp(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.sp(context)),
            ),
            child: Text(
              '$approved ${"approvedLbl".tr(context)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sp(context)),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(10.sp(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.sp(context)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6.sp(context), color: context.colorScheme.primary.withValues(alpha: 0.7)),
              SizedBox(width: 14.sp(context)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.sp(context)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.sp(context)),
                        decoration: BoxDecoration(color: context.colorScheme.surface, shape: BoxShape.circle),
                        child: Icon(Icons.workspace_premium, color: context.colorScheme.primary, size: 24.sp(context)),
                      ),
                      SizedBox(width: 12.sp(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.achievement,
                              style: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface),
                            ),

                            if (achievement.status == AchievementStatus.rejected) ...[
                              SizedBox(height: 4.sp(context)),
                              Text(
                                'Reason: ${achievement.rejectedReason}',
                                style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                            ],

                            SizedBox(height: 4.sp(context)),

                            Text(
                              achievement.dateOnly,
                              style: TextStyle(fontSize: 12.sp(context), color: context.colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.sp(context)),
                child: _StatusChip(status: achievement.status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AchievementStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp(context), vertical: 6.sp(context)),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.sp(context)),
      ),
      child: Text(
        status.text.tr(context).toUpperCase(),
        style: TextStyle(fontSize: 10.sp(context), fontWeight: FontWeight.w800, color: status.color),
      ),
    );
  }
}

class _AddAchievementSheet extends StatefulWidget {
  const _AddAchievementSheet();

  @override
  State<_AddAchievementSheet> createState() => _AddAchievementSheetState();
}

class _AddAchievementSheetState extends State<_AddAchievementSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SetAchievementCubit, SetAchievementState>(
      builder: (context, state) {
        final isLoading = state is SetAchievementInProgress;

        return TapRegion(
          onTapOutside: (event) {
            if (context.read<SetAchievementCubit>().state is! SetAchievementInProgress) {
              Navigator.of(context).pop();
              return;
            }
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (context.read<SetAchievementCubit>().state is! SetAchievementInProgress) {
                Navigator.of(context).pop();
                return;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.sp(context))),
              ),
              padding: EdgeInsets.only(
                left: 20.sp(context),
                right: 20.sp(context),
                top: 20.sp(context),
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.sp(context),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'createAchievementLbl'.tr(context),
                          style: TextStyle(fontSize: 20.sp(context), fontWeight: FontWeight.w500),
                        ),
                        if (!isLoading)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.sp(context)),
                    CustomTextField(
                      controller: _controller,
                      enabled: !isLoading,
                      hintText: 'enterAchievementNameHint'.tr(context),
                      prefixIcon: const Icon(Icons.emoji_events_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enterAchievementNameError'.tr(context);
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.sp(context)),
                    BlocConsumer<SetAchievementCubit, SetAchievementState>(
                      listener: (context, state) {
                        if (state is SetAchievementFetchSuccess) {
                          // Refresh the list after success
                          context.read<GetAchievementCubit>().addAchievement(achievement: state.achievement);
                          Navigator.pop(context);
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50.sp(context),
                          child: CustomRoundedButtonWidget(
                            isLoading: isLoading,
                            text: 'saveLbl'.tr(context),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<SetAchievementCubit>().setAchievement(
                                  achievementTitle: _controller.text.trim(),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';
// import 'package:omkar_sale/features/achievement/cubit/get_achievement_cubit.dart';
// import 'package:omkar_sale/features/achievement/cubit/set_achievement_cubit.dart';
// import 'package:omkar_sale/features/achievement/model/achievement.dart';
// import 'package:omkar_sale/features/achievement/model/achievement_model.dart';
// import 'package:omkar_sale/commons/widgets/customWidget/custom_appbar_widget.dart';

// class AchievementScreen extends StatefulWidget {
//   const AchievementScreen({super.key});

//   static Route<dynamic> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute(
//       builder: (_) => MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (context) => SetAchievementCubit()),
//           BlocProvider(create: (context) => GetAchievementCubit()),
//         ],
//         child: const AchievementScreen(),
//       ),
//     );
//   }

//   @override
//   State<AchievementScreen> createState() => _AchievementScreenState();
// }

// class _AchievementScreenState extends State<AchievementScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     Future.microtask(fetchAchievements);
//     super.initState();
//   }

//   Future<void> fetchAchievements() async {
//     context.read<GetAchievementCubit>().fetchGetAchievement();
//   }

//   void _showAddAchievementSheet() {
//     final setAchievementContext = context.read<SetAchievementCubit>();
//     showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       // Set these to false to prevent closing by clicking outside or dragging down
//       isDismissible: false,
//       enableDrag: false,
//       backgroundColor: context.colorScheme.surface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp(context))),
//       ),
//       builder: (context) {
//         return BlocProvider.value(
//           value: setAchievementContext,
//           child: const AddAchievementBottomSheet(),
//         );
//       },
//     );
//   }

//   Widget _buildStatusChip(AchievementStatus status) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.sp(context), vertical: 4.sp(context)),
//       decoration: BoxDecoration(
//         color: status.color.withValues(alpha: 0.15),
//         borderRadius: BorderRadius.circular(8.sp(context)),
//       ),
//       child: Text(
//         status.name.toUpperCase(),
//         style: TextStyle(
//           color: status.color,
//           fontSize: 12.sp(context),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.colorScheme.surface,
//       appBar: CustomAppBar(
//         title: 'achievementsLbl'.tr(context),
//         backgroundColor: context.colorScheme.secondary,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddAchievementSheet,
//         backgroundColor: context.primaryColor,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: BlocBuilder<GetAchievementCubit, GetAchievementState>(
//         builder: (context, state) {
//           if (state is GetAchievementFetchFailure) {
//             return CustomErrorWidget(
//               title: state.exception.errorMessageKey,
//               errorType: state.exception.type,
//               onRetry: () {
//                 context.read<GetAchievementCubit>().fetchGetAchievement();
//               },
//             );
//           }

//           if (state is GetAchievementFetchSuccess) {
//             if (state.achievements.isEmpty) {
//               return CustomErrorWidget(title: 'noAchievementsFoundLbl'.tr(context), errorType: CustomErrorType.noDataFound);
//             }

//             return ListView.builder(
//               padding: EdgeInsets.all(16.sp(context)),
//               itemCount: state.achievements.length,
//               itemBuilder: (context, index) {
//                 final achievement = state.achievements[index];
//                 return Container(
//                   margin: EdgeInsets.only(bottom: 12.sp(context)),
//                   padding: EdgeInsets.all(16.sp(context)),
//                   decoration: BoxDecoration(
//                     color: context.colorScheme.secondary,
//                     borderRadius: BorderRadius.circular(16.sp(context)),
//                     border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.1)),
//                     boxShadow: [
//                       BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(10.sp(context)),
//                         decoration: BoxDecoration(
//                           color: context.primaryColor.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(10.sp(context)),
//                         ),
//                         child: Icon(Icons.emoji_events, color: context.primaryColor, size: 24.sp(context)),
//                       ),
//                       SizedBox(width: 16.sp(context)),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               achievement.achievement,
//                               style: TextStyle(
//                                 fontSize: 16.sp(context),
//                                 fontWeight: FontWeight.bold,
//                                 color: context.colorScheme.onSurface,
//                               ),
//                             ),
//                             SizedBox(height: 4.sp(context)),
//                             Text(
//                               achievement.dateOnly,
//                               style: TextStyle(
//                                 fontSize: 14.sp(context),
//                                 color: context.colorScheme.onSurface.withValues(alpha: 0.5),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       _buildStatusChip(achievement.status),
//                     ],
//                   ),
//                 );
//               },
//             );
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }

// class AddAchievementBottomSheet extends StatefulWidget {
//   const AddAchievementBottomSheet({super.key});

//   @override
//   State<AddAchievementBottomSheet> createState() => _AddAchievementBottomSheetState();
// }

// class _AddAchievementBottomSheetState extends State<AddAchievementBottomSheet> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController achievementController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return TapRegion(
//       onTapOutside: (event) {
//         if (context.read<SetAchievementCubit>().state is! SetAchievementInProgress) {
//           Navigator.of(context).pop();
//           return;
//         }
//       },
//       child: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (didPop) return;
//           if (context.read<SetAchievementCubit>().state is! SetAchievementInProgress) {
//             Navigator.of(context).pop();
//             return;
//           }
//         },
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16.sp(context),
//             right: 16.sp(context),
//             top: 24.sp(context),
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'createAchievementLbl'.tr(context),
//                   style: TextStyle(
//                     fontSize: 18.sp(context),
//                     fontWeight: FontWeight.bold,
//                     color: context.colorScheme.onSurface,
//                   ),
//                 ),
//                 SizedBox(height: 16.sp(context)),
//                 CustomTextField(
//                   controller: achievementController,
//                   hintText: 'enterAchievementNameHint'.tr(context),
//                   validator: (String? value) {
//                     if (value == null || value.isEmpty) {
//                       return 'enterAchievementNameError'.tr(context);
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 24.sp(context)),
//                 BlocConsumer<SetAchievementCubit, SetAchievementState>(
//                   listener: (context, state) {
//                     if (state is SetAchievementFetchSuccess) {
//                       Navigator.pop(context);
//                     }
//                   },
//                   builder: (context, state) {
//                     return CustomRoundedButtonWidget(
//                       isLoading: state is SetAchievementInProgress,
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           _formKey.currentState!.save();
//                           context.read<SetAchievementCubit>().setAchievement(achievementTitle: achievementController.text);
//                         }
//                       },
//                       text: 'saveLbl'.tr(context),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 24.sp(context)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
