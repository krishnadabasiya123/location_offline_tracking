import 'package:omkar_sale/core/app/all_import_file.dart';

class AgendaDetails extends Equatable {
  const AgendaDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.meetingDate,
    required this.completionNotes,
  });

  factory AgendaDetails.fromJson(Map<String, dynamic> json) {
    final apiFormat = DateFormat('dd-MM-yyyy hh:mm a');

    DateTime parsedDate;
    try {
      parsedDate = apiFormat.parse(json['meeting_date']?.toString() ?? '');
    } catch (e) {
      parsedDate = DateTime.now();
    }
    return AgendaDetails(
      id: int.parse(json['id']?.toString() ?? '0'),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      meetingDate: parsedDate,
      completionNotes: List<CompletionNote>.from((json['completion_notes'] as List? ?? []).map((x) => CompletionNote.fromJson(x as Map<String, dynamic>))),
    );
  }
  String get formattedFullDate {
    return DateFormat('dd-MMM-yyyy hh:mm a').format(meetingDate).toUpperCase();
  }

  // Helpers for your AgendaItemWidget
  String get monthName => DateFormat('MMM').format(meetingDate).toUpperCase(); // "JAN"
  String get dayNumber => DateFormat('dd').format(meetingDate); // "22"
  String get timeString => DateFormat('hh:mm a').format(meetingDate); // "12:44 PM"

  final int id;
  final String title;
  final String description;
  final DateTime meetingDate;
  final List<CompletionNote> completionNotes;

  AgendaDetails copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? meetingDate,
    List<CompletionNote>? completionNotes,
  }) {
    return AgendaDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      meetingDate: meetingDate ?? this.meetingDate,
      completionNotes: completionNotes ?? this.completionNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'meeting_date': meetingDate,
    'completion_notes': completionNotes.map((e) => e.toJson()).toList(),
  };

  @override
  String toString() {
    return '$id, $title, $description, $meetingDate,$completionNotes ';
  }

  @override
  List<Object?> get props => [id, title, description, meetingDate, completionNotes];
}

class CompletionNote extends Equatable {
  const CompletionNote({
    required this.userId,
    required this.userName,
    required this.completionNotes,
  });

  factory CompletionNote.fromJson(Map<String, dynamic> json) {
    return CompletionNote(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      userName: json['user_name']?.toString() ?? '',
      completionNotes: json['completion_notes']?.toString() ?? '',
    );
  }

  final int userId;
  final String userName;
  final String completionNotes;

  CompletionNote copyWith({
    int? userId,
    String? userName,
    String? completionNotes,
    DateTime? completedAt,
  }) {
    return CompletionNote(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      completionNotes: completionNotes ?? this.completionNotes,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_name': userName,
    'completion_notes': completionNotes,
  };

  @override
  String toString() {
    return '$userId, $userName, $completionNotes';
  }

  @override
  List<Object?> get props => [userId, userName, completionNotes];
}
