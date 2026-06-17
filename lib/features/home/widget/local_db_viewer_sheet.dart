import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

void showLocalDbViewerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent, // Let container handle it
    isScrollControlled: true,
    builder: (_) => const LocalDbViewerSheet(),
  );
}

class LocalDbViewerSheet extends StatefulWidget {
  const LocalDbViewerSheet({super.key});

  @override
  State<LocalDbViewerSheet> createState() => _LocalDbViewerSheetState();
}

class _LocalDbViewerSheetState extends State<LocalDbViewerSheet> {
  bool _isLoading = true;
  String _locationJson = '';
  String _clockInOutJson = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (!Hive.isBoxOpen(LocationRepository.kHiveBoxName)) {
        await Hive.openBox(LocationRepository.kHiveBoxName);
      }
      if (!Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)) {
        await Hive.openBox(ClockInOutRepository.kClockInOutBoxName);
      }

      final locBox = Hive.box(LocationRepository.kHiveBoxName);
      final locationMap = <String, dynamic>{};
      for (final key in locBox.keys) {
        locationMap[key.toString()] = locBox.get(key);
      }

      final clockBox = Hive.box(ClockInOutRepository.kClockInOutBoxName);
      final clockMap = <String, dynamic>{};
      for (final key in clockBox.keys) {
        clockMap[key.toString()] = clockBox.get(key);
      }

      final encoder = const JsonEncoder.withIndent('  ');
      _locationJson = encoder.convert(_makeJsonCompatible(locationMap));
      _clockInOutJson = encoder.convert(_makeJsonCompatible(clockMap));
    } catch (e) {
      log('Error reading Hive data: $e');
      _locationJson = 'Error reading box: $e';
      _clockInOutJson = 'Error reading box: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  dynamic _makeJsonCompatible(dynamic item) {
    if (item is Map) {
      return item.map((k, v) {
        if (k.toString() == 'time' && v is int) {
          final dt = DateTime.fromMillisecondsSinceEpoch(v);
          final formatted = DateFormat('dd-MM-yyyy HH:mm:ss').format(dt);
          return MapEntry(k.toString(), formatted);
        }
        return MapEntry(k.toString(), _makeJsonCompatible(v));
      });
    } else if (item is List) {
      return item.map(_makeJsonCompatible).toList();
    } else if (item is DateTime) {
      return DateFormat('dd-MM-yyyy HH:mm:ss').format(item);
    } else if (item is num || item is bool || item == null || item is String) {
      return item;
    } else {
      return item.toString();
    }
  }

  void _copyToClipboard(String text, String title) {
    Clipboard.setData(ClipboardData(text: text));
    context.showSnackBar(
      message: '$title copied to clipboard!',
      backgroundColor: Colors.green,
    );
  }

  Future<void> _clearHiveData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final locBox = Hive.isBoxOpen(LocationRepository.kHiveBoxName)
          ? Hive.box(LocationRepository.kHiveBoxName)
          : await Hive.openBox(LocationRepository.kHiveBoxName);
      await locBox.clear();

      final clockBox = Hive.isBoxOpen(ClockInOutRepository.kClockInOutBoxName)
          ? Hive.box(ClockInOutRepository.kClockInOutBoxName)
          : await Hive.openBox(ClockInOutRepository.kClockInOutBoxName);
      await clockBox.clear();

      if (mounted) {
        context.showSnackBar(
          message: 'All Hive boxes cleared successfully!',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          message: 'Failed to clear data: $e',
          backgroundColor: Colors.red,
        );
      }
    }
    await _loadData();
  }

  void _showClearConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                'Clear Local Data',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete all entries from locationDataBox and clockInOutBox? This action cannot be undone.',
            style: GoogleFonts.manrope(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _clearHiveData();
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.8,
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceDim.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Local DB Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp(context),
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: _showClearConfirmationDialog,
                        tooltip: 'Clear All Data',
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: context.primaryColor),
                        onPressed: _loadData,
                        tooltip: 'Refresh Data',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              labelColor: context.primaryColor,
              unselectedLabelColor: context.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              indicatorColor: context.primaryColor,
              tabs: const [
                Tab(
                  icon: Icon(Icons.location_on),
                  text: 'locationDataBox',
                ),
                Tab(
                  icon: Icon(Icons.alarm),
                  text: 'clockInOutBox',
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CustomCircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildJsonViewerTab(
                          context,
                          title: 'locationDataBox',
                          jsonText: _locationJson,
                        ),
                        _buildJsonViewerTab(
                          context,
                          title: 'clockInOutBox',
                          jsonText: _clockInOutJson,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonViewerTab(
    BuildContext context, {
    required String title,
    required String jsonText,
  }) {
    final hasData =
        jsonText.trim() != '{}' &&
        jsonText.trim().isNotEmpty &&
        !jsonText.startsWith('Error');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasData ? 'JSON Contents:' : 'No data stored',
                style: GoogleFonts.manrope(
                  fontSize: 14.sp(context),
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (hasData)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _copyToClipboard(jsonText, title),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text(
                    'Copy JSON',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.9,
                ), // Terminal style code view
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colorScheme.surfaceDim.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: hasData
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          jsonText,
                          style: GoogleFonts.firaCode(
                            color: const Color(0xFF4AF626), // terminal green
                            fontSize: 12.sp(context),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storage_rounded,
                            size: 48.sp(context),
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Box is empty',
                            style: GoogleFonts.manrope(
                              color: Colors.grey,
                              fontSize: 14.sp(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
