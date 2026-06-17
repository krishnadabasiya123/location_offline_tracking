import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

enum AchievementStatus {
  awaiting('awaitLbl', Colors.orange, 0),
  approved('approvedLbl', Colors.green, 1),
  rejected('rejectedLbl', Colors.red, 2)
  ;

  final String text;
  final Color color;
  final int status; // backend value

  const AchievementStatus(this.text, this.color, this.status);

  /// Convert API value (int or string) → enum
  static AchievementStatus fromValue(dynamic value) {
    if (value == null) return AchievementStatus.awaiting;

    // API sends int
    if (value is int) {
      return AchievementStatus.values.firstWhere(
        (e) => e.status == value,
        orElse: () => AchievementStatus.awaiting,
      );
    }

    // API sends string
    return AchievementStatus.values.firstWhere(
      (e) => e.status.toString().toLowerCase() == value.toString().toLowerCase(),
      orElse: () => AchievementStatus.awaiting,
    );
  }
}

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.achievement,
    required this.status,
    required this.createdAt,
    required this.rejectedReason,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      achievement: json['achievement']?.toString() ?? '',
      rejectedReason: json['comment']?.toString() ?? '',
      status: AchievementStatus.fromValue(json['status']?.toString() ?? '0'),
      createdAt: json['created_at'] != null ? DateFormat('dd-MM-yyyy').parse(json['created_at'].toString()) : DateTime.now(), // fallback
    );
  }

  final int id;
  final String achievement;
  final String rejectedReason;
  final AchievementStatus status;
  final DateTime createdAt;

  Achievement copyWith({
    int? id,
    String? achievement,
    AchievementStatus? status,
    DateTime? createdAt,
    String? rejectedReason,
  }) {
    return Achievement(
      id: id ?? this.id,
      rejectedReason: rejectedReason ?? this.rejectedReason,
      achievement: achievement ?? this.achievement,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'achievement': achievement,
    'comment': rejectedReason,
    'status': status.index, // 0,1,2
    'created_at': DateFormat('dd-MM-yyyy hh:mm a').format(createdAt),
  };

  @override
  List<Object?> get props => [id, achievement, status, createdAt, rejectedReason];

  @override
  String toString() => '$id, $achievement, $status, $createdAt , $rejectedReason';
}

extension AchievementDateX on Achievement {
  String get dateOnly => DateFormat('dd-MM-yyyy').format(createdAt);
}
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:omkar_sale/core/app/all_import_file.dart';

// /// --- Achievement Status Enum with helpers ---
// enum AchievementStatus {
//   awaiting('awaitLbl', Colors.orange), // 0
//   approved('approvedLbl', Colors.green), // 1
//   rejected('rejectedLbl', Colors.red)
//   ; // 2

//   final String text;
//   final Color color;

//   const AchievementStatus(this.text, this.color);

//   static AchievementStatus fromValue(String value) {
//     return AchievementStatus.values.firstWhere(
//       (e) => e.name.toLowerCase() == value.toLowerCase(),
//       orElse: () => AchievementStatus.awaiting,
//     );
//   }
// }

// class Achievement extends Equatable {
//   const Achievement({
//     required this.id,
//     required this.achievement,
//     required this.status,
//     required this.createdAt,
//   });

//   factory Achievement.fromJson(Map<String, dynamic> json) {
//     return Achievement(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       achievement: json['achievement']?.toString() ?? '',
//       status: AchievementStatus.fromValue(json['status']?.toString() ?? '0'),
//       createdAt: json['created_at'] != null ? DateFormat('dd-MM-yyyy hh:mm a').parse(json['created_at'] as String) : null,
//     );
//   }

//   final int id;
//   final String achievement;
//   final AchievementStatus status;
//   final DateTime createdAt;

//   Achievement copyWith({int? id, String? achievement, AchievementStatus? status}) {
//     return Achievement(
//       id: id ?? this.id,
//       achievement: achievement ?? this.achievement,
//       status: status ?? this.status,
//       createdAt: createdAt ?? createdAt,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'achievement': achievement,
//     'status': status.index,
//     'created_at': createdAt.toIso8601String(),
//   };

//   @override
//   List<Object?> get props => [id, achievement, status, createdAt];

//   @override
//   String toString() => '$id, $achievement, $status , $createdAt';
// }

// import 'package:equatable/equatable.dart';

// enum AchievementStatus { await, approved, reject }

// class Achievement extends Equatable {
//   const Achievement({
//     required this.id,
//     required this.achievement,
//     required this.status,
//   });

//   factory Achievement.fromJson(Map<String, dynamic> json) {
//     return Achievement(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       achievement: json['achievement']?.toString() ?? '',
//       status: AchievementStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => AchievementStatus.await),
//     );
//   }

//   final int id;
//   final String achievement;
//   final AchievementStatus status;

//   Achievement copyWith({int? id, String? achievement, AchievementStatus? status, dynamic comment}) {
//     return Achievement(id: id ?? this.id, achievement: achievement ?? this.achievement, status: status ?? this.status);
//   }

//   Map<String, dynamic> toJson() => {'id': id, 'achievement': achievement, 'status': status};

//   @override
//   String toString() {
//     return '$id, $achievement, $status ';
//   }

//   @override
//   List<Object?> get props => [id, achievement, status];
// }
