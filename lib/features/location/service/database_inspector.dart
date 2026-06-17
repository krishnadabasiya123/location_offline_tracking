import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/location/service/location_service.dart';

class DatabaseInspector {
  static void show(BuildContext context) {
    try {
      final dateBox = Hive.box<dynamic>(
        ClockInOutRepository.kClockInOutBoxName,
      );
      final locBox = Hive.box<dynamic>(LocationRepository.kHiveBoxName);
      final clockInOutDataBox = ClockInOutRepository.kClockInOutBoxName;
      final locationDataBox = LocationRepository.kHiveBoxName;

      // Helper to recursively convert Map keys to String so JsonEncoder can serialize it safely.
      Map<String, dynamic> stringifyKeys(Map<dynamic, dynamic> map) {
        return map.map((key, value) {
          final stringKey = key.toString();
          var formattedValue = value;

          if ((stringKey == 'time' || stringKey == 'timestamp') &&
              value != null) {
            try {
              DateTime? dt;
              if (value is int) {
                dt = DateTime.fromMillisecondsSinceEpoch(value);
              } else if (value is String) {
                final parsedInt = int.tryParse(value);
                if (parsedInt != null) {
                  dt = DateTime.fromMillisecondsSinceEpoch(parsedInt);
                } else {
                  dt = DateTime.tryParse(value);
                }
              }
              if (dt != null) {
                formattedValue = DateFormat(
                  "d MMMM yyyy 'at' H:mm:ss.SSS",
                ).format(dt);
              }
            } catch (_) {}
          }

          if (formattedValue is Map) {
            return MapEntry(stringKey, stringifyKeys(formattedValue));
          } else if (formattedValue is List) {
            return MapEntry(
              stringKey,
              formattedValue.map((item) {
                if (item is Map) {
                  return stringifyKeys(item);
                }
                return item;
              }).toList(),
            );
          }
          return MapEntry(stringKey, formattedValue);
        });
      }

      final encoder = const JsonEncoder.withIndent('  ');

      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF0F172A),
        isScrollControlled: true, // Allow it to expand nicely
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          String selectedBox = clockInOutDataBox; // Default selected tab
          bool isCopied = false;

          return StatefulBuilder(
            builder: (context, setSheetState) {
              return ValueListenableBuilder<Box<dynamic>>(
                valueListenable: Hive.box<dynamic>(selectedBox).listenable(),
                builder: (context, box, _) {
                  final Map<dynamic, dynamic> currentData =
                      stringifyKeys(box.toMap());
                  final String boxJsonStr = encoder.convert(currentData);

              return FractionallySizedBox(
                heightFactor: 0.75, // Lock it to a beautiful, clean height
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Drag Handle ---
                      Center(
                        child: Container(
                          width: 42,
                          height: 4.5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Database Inspector",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 44,
                            child: InkWell(
                              onTap: () {
                                DatabaseInspector().handleClearData(context);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // --- Interactive Tab Selectors ---
                      Row(
                        children: [
                          _buildTabButton(
                            label: "Sessions (clockInOutData)",
                            isSelected: selectedBox == clockInOutDataBox,
                            onTap: () {
                              setSheetState(() {
                                selectedBox = clockInOutDataBox;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildTabButton(
                            label: "Locations (locationData)",
                            isSelected: selectedBox == locationDataBox,
                            onTap: () {
                              setSheetState(() {
                                selectedBox = locationDataBox;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // --- Coordinate and Session Summary Card ---
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0x0CFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selectedBox == locationDataBox
                                      ? Icons.location_on
                                      : Icons.fingerprint,
                                  color: selectedBox == locationDataBox
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFF10B981),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedBox == locationDataBox
                                      ? "Location Coordinates Count"
                                      : "Shift Session Actions Count",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (currentData.isEmpty)
                              const Text(
                                "No records found.",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              ...currentData.entries
                                  .where(
                                    (entry) =>
                                        entry.key != true &&
                                        entry.key != 'is_clocked_in',
                                  )
                                  .map((entry) {
                                    final dateStr = entry.key;
                                    final dynamic value = entry.value;
                                    int count = 0;

                                    if (selectedBox == locationDataBox) {
                                      if (value is Map &&
                                          value['location'] is List) {
                                        count =
                                            (value['location'] as List).length;
                                      }
                                    } else {
                                      if (value is List) {
                                        count = value.length;
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateStr.toString(),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            selectedBox == locationDataBox
                                                ? "$count points"
                                                : "$count events",
                                            style: TextStyle(
                                              color:
                                                  selectedBox == locationDataBox
                                                  ? (count >= 5000
                                                        ? const Color(
                                                            0xFFEF4444,
                                                          )
                                                        : const Color(
                                                            0xFF38BDF8,
                                                          ))
                                                  : const Color(0xFF10B981),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                          ],
                        ),
                      ),

                      // --- Display Container ---
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  currentData.isEmpty
                                      ? "{} (No records found)"
                                      : boxJsonStr,
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontFamily: 'monospace',
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ),
                            if (currentData.isNotEmpty)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Material(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    child: InkWell(
                                      onTap: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: boxJsonStr),
                                        );
                                        setSheetState(() {
                                          isCopied = true;
                                        });
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
                                            if (context.mounted) {
                                              setSheetState(() {
                                                isCopied = false;
                                              });
                                            }
                                          },
                                        );
                                      },
                                      child: Tooltip(
                                        message: "Copy data to clipboard",
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Icon(
                                              isCopied
                                                  ? Icons.check_circle_outline
                                                  : Icons.copy_rounded,
                                              key: ValueKey<bool>(isCopied),
                                              color: isCopied
                                                  ? const Color(0xFF10B981)
                                                  : Colors.white70,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
        },
      );
    } catch (e) {
      debugPrint("Error reading Hive: $e");
    }
  }

  Future<void> handleClearData(BuildContext context) async {
    await AttendanceDialogs.showClearConfirmation(
      context,
      onConfirm: () async {
        await LocationTracker.instance.stop();

        String clockInOutDataBox = 'clockInOutDataBox';
        String locationDataBox = 'locationDataBox';

        final dateBox = Hive.isBoxOpen(clockInOutDataBox)
            ? Hive.box<dynamic>(clockInOutDataBox)
            : await Hive.openBox<dynamic>(clockInOutDataBox);
        await dateBox.clear();

        final locBox = Hive.isBoxOpen(locationDataBox)
            ? Hive.box<dynamic>(locationDataBox)
            : await Hive.openBox<dynamic>(locationDataBox);
        await locBox.clear();

        if (context.mounted) {
          //context.read<ClockInOutCubit>().loadClockStatus();
          context.read<UserDetailsCubit>().fetchUserDetails();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Hive Database successfully cleared!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
    );
  }

  static Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade600 : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue.shade400 : Colors.white10,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}

class AttendanceDialogs {
  static void showSyncProgress(BuildContext context, String dateStr) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing by tapping outside the dialog
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevents closing via the physical back button
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF0F172A,
                ).withValues(alpha: 0.95), // Deep Slate Glass
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ), // Indigo Accent
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Synchronizing",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Uploading coordinates for $dateStr...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showConnectionError(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 10),
              Text(
                "Connection Error",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            "No internet connection detected. Please connect to the internet to sync your historical shifts.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showClearConfirmation(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Clear Attendance Data?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "This will delete all location points, clock-in/out logs, and user credentials from local Hive databases.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              child: const Text(
                "Clear Data",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
