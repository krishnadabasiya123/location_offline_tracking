import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:omkar_sale/commons/cubits/agenda_cubit.dart';
import 'package:omkar_sale/commons/cubits/set_agenda_cubit.dart';
import 'package:omkar_sale/commons/models/agenda_details.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class AgendaItemWidget extends StatelessWidget {
  const AgendaItemWidget({required this.agendaDetails, super.key});

  final AgendaDetails agendaDetails;

  // --- Logic: Show Details in BottomSheet ---
  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.sp(context))),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(24.sp(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.sp(context),
                    height: 4.sp(context),
                    margin: EdgeInsets.only(bottom: 20.sp(context)),
                    decoration: BoxDecoration(color: context.colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                // Title and Date/Time Row
                Text(
                  agendaDetails.title,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.sp(context)),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp(context), color: context.primaryColor),
                    SizedBox(width: 8.sp(context)),
                    Text('${agendaDetails.dayNumber} ${agendaDetails.monthName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(width: 20.sp(context)),
                    Icon(Icons.access_time, size: 16.sp(context), color: context.primaryColor),
                    SizedBox(width: 8.sp(context)),
                    Text(agendaDetails.timeString, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),

                Divider(height: 40.sp(context), thickness: 1),

                // Full Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14.sp(context),
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12.sp(context)),

                // Using HtmlWidget if the description has HTML, otherwise use Text
                HtmlWidget(
                  agendaDetails.description,
                  textStyle: TextStyle(
                    fontSize: 15.sp(context),
                    height: 1.6,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 40.sp(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCompletionNotes({required BuildContext context, required int agendaId}) {
    final cubit = context.read<SetAgendaNotesCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Handle rounding in the container
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: CompletionNotesSheet(agendaId: agendaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () => _showDetails(context), // Trigger the BottomSheet
      child: Container(
        padding: EdgeInsets.all(12.sp(context)),
        margin: EdgeInsets.only(bottom: 12.sp(context)),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(24.sp(context)),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Date Box
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.sp(context), horizontal: 15.sp(context)),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.sp(context)),
                    border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        agendaDetails.monthName.toUpperCase(),
                        style: TextStyle(fontSize: 10.sp(context), fontWeight: FontWeight.bold, color: context.primaryColor),
                      ),
                      Text(
                        agendaDetails.meetingDate.day.toString(),
                        style: TextStyle(
                          fontSize: 18.sp(context),
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.sp(context)),

                // Text Content (Short version)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              agendaDetails.title,
                              style: TextStyle(fontSize: 14.sp(context), fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                            ),
                          ),
                          Text(
                            agendaDetails.timeString,
                            style: TextStyle(fontSize: 10.sp(context), fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.sp(context)),
                      Text(
                        'tapToViewDetailsLbl'.tr(context),
                        style: TextStyle(
                          fontSize: 12.sp(context),
                          color: context.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 30.sp(context), thickness: 0.5, color: colorScheme.onSurface.withValues(alpha: 0.2)),

            Align(
              alignment: AlignmentGeometry.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.sp(context), vertical: 6.sp(context)),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(20.sp(context)),
                ),

                child: agendaDetails.completionNotes.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 18.sp(context), color: context.primaryColor),
                          SizedBox(width: 3.sp(context)),
                          Text(
                            'completeLbl'.tr(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13.sp(context), color: colorScheme.onSurface.withValues(alpha: 0.6), height: 1.4),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () => _showCompletionNotes(context: context, agendaId: agendaDetails.id),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_note, size: 18.sp(context), color: context.primaryColor),
                            SizedBox(width: 3.sp(context)),
                            Text(
                              'notesLbl'.tr(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp(context),
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                height: 1.4,
                              ),
                            ),
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
}

class CompletionNotesSheet extends StatefulWidget {
  const CompletionNotesSheet({required this.agendaId, super.key});
  final int agendaId;

  @override
  State<CompletionNotesSheet> createState() => _CompletionNotesSheetState();
}

class _CompletionNotesSheetState extends State<CompletionNotesSheet> {
  TextEditingController noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (context.read<SetAgendaNotesCubit>().state is! SetAgendaNotesInProgress) {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Handle Keyboard
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp(context))),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.sp(context)),
                  width: 50.sp(context),
                  height: 5.sp(context),
                  decoration: BoxDecoration(color: context.colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                ),

                Padding(
                  padding: EdgeInsets.all(24.sp(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row
                      Text(
                        'addCompletionNotesLbl'.tr(context),
                        style: TextStyle(fontSize: 20.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface),
                      ),
                      SizedBox(height: 24.sp(context)),

                      // Note Label
                      Text(
                        'notesLbl'.tr(context),
                        style: TextStyle(fontSize: 12.sp(context), fontWeight: FontWeight.w500, color: context.colorScheme.onSurface.withValues(alpha: 0.6), letterSpacing: 1.5),
                      ),
                      SizedBox(height: 8.sp(context)),

                      // Note TextArea
                      CustomTextField(
                        controller: noteController,
                        maxLines: 6,
                        hintMaxLines: 6,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        hintText: 'enterCompletionNotesOfAgendaLbl'.tr(context),
                        hintStyle: TextStyle(fontSize: 14.sp(context)),
                        fillColor: context.scaffoldBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.sp(context)), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.all(16.sp(context)),
                      ),

                      SizedBox(height: 24.sp(context)),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomRoundedButtonWidget(
                              onPressed: () {
                                if (context.read<SetAgendaNotesCubit>().state is! SetAgendaNotesInProgress) {
                                  Navigator.pop(context);
                                }
                              },
                              text: 'Cancel'.tr(context),
                              stretch: true,
                              height: 45.sp(context),
                              borderRadius: BorderRadius.circular(12.sp(context)),
                              backgroundColor: context.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(width: 16.sp(context)),
                          Expanded(
                            flex: 2,

                            child: BlocConsumer<SetAgendaNotesCubit, SetAgendaNotesState>(
                              listener: (context, state) {
                                if (state is SetAgendaNotesFetchSuccess) {
                                  context.read<GetAgendaCubit>().updateCompletionNotes(updateAgendaDetails: state.agenda);
                                  Navigator.pop(context);
                                }
                                if (state is SetAgendaNotesFetchFailure) {
                                  context.showSnackBar(message: state.exception.errorMessageKey.tr(context), backgroundColor: context.colorScheme.error);
                                }
                              },
                              builder: (context, state) {
                                return CustomRoundedButtonWidget(
                                  isLoading: state is SetAgendaNotesInProgress,
                                  onPressed: () {
                                    if (noteController.text.trim().isEmpty) {
                                      context.showSnackBar(message: 'pleaseEnterNotesLbl'.tr(context), backgroundColor: context.colorScheme.error);
                                      return;
                                    }

                                    context.read<SetAgendaNotesCubit>().setAgendaNotes(agendaId: widget.agendaId, agendaTitle: noteController.text.trim());
                                  },
                                  text: 'Save Notes'.tr(context),
                                  stretch: true,
                                  height: 45.sp(context),
                                  borderRadius: BorderRadius.circular(12.sp(context)),
                                  backgroundColor: context.primaryColor,
                                  icon: Icon(Icons.check_circle, color: Colors.white, size: 18.sp(context)),
                                );
                              },
                            ),
                            // child: ElevatedButton(
                            //   onPressed: () {
                            //     // Handle Save Logic
                            //     Navigator.pop(context);
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     padding: EdgeInsets.symmetric(vertical: 16.sp(context)),
                            //     backgroundColor: context.primaryColor,
                            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp(context))),
                            //     elevation: 0,
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       const Text(
                            //         'Save Notes',
                            //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //       ),
                            //       SizedBox(width: 8.sp(context)),
                            //       const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            //     ],
                            //   ),
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';

// class AgendaItemWidget extends StatelessWidget {
//   const AgendaItemWidget({
//     required this.month,
//     required this.day,
//     required this.title,
//     required this.time,
//     required this.description,
//     super.key,
//   });
//   final String month;
//   final String day;
//   final String title;
//   final String time;
//   final String description;

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = context.colorScheme;

//     return Container(
//       padding: EdgeInsets.all(12.sp(context)),
//       margin: EdgeInsets.only(bottom: 12.sp(context)),
//       decoration: BoxDecoration(
//         color: colorScheme.secondary, // surface-light / surface-dark
//         borderRadius: BorderRadius.circular(24.sp(context)),
//         border: Border.all(color: colorScheme.onSurface.withValues(alpha:0.05)),

//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Date Box (Left Side)
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 12.sp(context), horizontal: 15.sp(context)),
//             decoration: BoxDecoration(
//               color: context.primaryColor.withValues(alpha:0.1),
//               borderRadius: BorderRadius.circular(16.sp(context)),
//               border: Border.all(
//                 color: context.primaryColor.withValues(alpha:0.2),
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   month.toUpperCase(),
//                   style: TextStyle(fontSize: 10.sp(context), fontWeight: FontWeight.bold, color: context.primaryColor),
//                 ),
//                 Text(
//                   day,
//                   style: TextStyle(
//                     fontSize: 18.sp(context),
//                     fontWeight: FontWeight.bold,
//                     color: context.primaryColor,
//                     height: 1.1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: 16.sp(context)),

//           // Content (Right Side)
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 14.sp(context),
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 10.sp(context),
//                         fontWeight: FontWeight.bold,
//                         color: colorScheme.onSurface.withValues(alpha:0.4),
//                       ),
//                     ),
//                   ],
//                 ),
//                 // SizedBox(height: 4.sp(context)),
//                 // HtmlWidget(
//                 //   description,
//                 //   onErrorBuilder: (_, e, err) => Text('$e error: $err'),
//                 //   onLoadingBuilder: (_, e, l) => const Center(child: CircularProgressIndicator()),
//                 //   textStyle: TextStyle(
//                 //     color: Theme.of(context).colorScheme.onTertiary,
//                 //     fontWeight: FontWeight.w400,
//                 //     fontSize: 12.sp(context),
//                 //   ),
//                 // ),

//                 // Text(
//                 //   description,
//                 //   maxLines: 2,
//                 //   overflow: TextOverflow.ellipsis,
//                 //   style: TextStyle(
//                 //     fontSize: 12.sp(context),
//                 //     color: colorScheme.onSurface.withValues(alpha:0.6),
//                 //     height: 1.4,
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
