import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/utils/connectivity.dart';

class ClockInOutRepository {
  static const String kClockInOutBoxName = 'clockInOutDataBox';

  Future<void> setClockInOut({
    required String date,
    required Map<String, dynamic> entry,
  }) async {
    try {
      if (!Hive.isBoxOpen(kClockInOutBoxName)) {
        await Hive.openBox(kClockInOutBoxName);
      }
      final box = Hive.box(kClockInOutBoxName);

      final updatedEntry = Map<String, dynamic>.from(entry);
      final type = updatedEntry['type'] as String?;

      var isSync = false;

      if (await InternetConnectivity.checkInternet()) {
        switch (type) {
          case 'in':
            isSync = await clockInApiDirectly(updatedEntry);
          case 'out':
            isSync = await clockOutApiDirectly(updatedEntry);
        }
      }

      updatedEntry['isSync'] = isSync;

      final activeBox = Hive.isBoxOpen(kClockInOutBoxName)
          ? Hive.box(kClockInOutBoxName)
          : await Hive.openBox(kClockInOutBoxName);

      final existingEntries = List<dynamic>.from(
        activeBox.get(date) as Iterable? ?? [],
      )..add(updatedEntry);

      await activeBox.put(date, existingEntries);
    } catch (e) {
      throw Exception('Error in ClockInOutRepository.setClockInOut: $e');
    }
  }

  Future<bool> clockInApiDirectly(Map<String, dynamic> entry) async {
    try {
      final body = <String, dynamic>{'type': 'in'};
      final lat = entry['lat']?.toString() ?? '';
      final lon = entry['long']?.toString() ?? '';

      if (lat.isNotEmpty && lon.isNotEmpty) {
        body['location[0][latitude]'] = lat;
        body['location[0][longitude]'] = lon;
      }

      final timeInt = entry['time'] as int?;
      final dateTime = timeInt != null
          ? DateTime.fromMillisecondsSinceEpoch(timeInt)
          : DateTime.now();

      body['date'] = DateFormat('dd-MM-yyyy').format(dateTime);
      body['date_time'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

      log('📤 API: Clock In request: $body');
      final response = await Api.instance.post(
        url: clockInOutUrl,
        parameter: body,
        useAuthToken: true,
      );

      return !(response['error'] as bool);
    } catch (e) {
      log('❌ API: Clock In failed: $e');
      return false;
    }
  }

  Future<bool> clockOutApiDirectly(Map<String, dynamic> entry) async {
    try {
      final body = <String, dynamic>{'type': 'out'};
      final lat = entry['lat']?.toString() ?? '';
      final lon = entry['long']?.toString() ?? '';

      if (lat.isNotEmpty && lon.isNotEmpty) {
        body['location[0][latitude]'] = lat;
        body['location[0][longitude]'] = lon;
      }

      final timeInt = entry['time'] as int?;
      final dateTime = timeInt != null
          ? DateTime.fromMillisecondsSinceEpoch(timeInt)
          : DateTime.now();

      body['date'] = DateFormat('dd-MM-yyyy').format(dateTime);
      body['date_time'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

      log('📤 API: Clock Out request: $body');
      final response = await Api.instance.post(
        url: clockInOutUrl,
        parameter: body,
        useAuthToken: true,
      );

      return !(response['error'] as bool);
    } catch (e) {
      log('❌ API: Clock Out failed: $e');
      return false;
    }
  }
}
