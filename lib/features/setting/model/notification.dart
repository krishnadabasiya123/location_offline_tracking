import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Matches: 22 Jan, 2026 10:52
    final inputFormat = DateFormat('dd MMM, yyyy HH:mm');

    return AppNotification(
      id: int.parse(json['id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',

      createdAt: json['created_at'] != null ? inputFormat.parse(json['created_at']?.toString() ?? DateTime.now().toString()) : DateTime.now(),
    );
  }
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;

  /// This getter returns the "2 MINS AGO" style string
  String get timeAgoDisplay => timeago.format(createdAt).toUpperCase();

  @override
  List<Object?> get props => [id, title, message, createdAt];
}
