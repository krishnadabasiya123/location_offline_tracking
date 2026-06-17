// enum AchievementStatus { await, approved, reject }

// class Achievement {
//   Achievement({
//     required this.id,
//     required this.name,
//     required this.status,
//     required this.data,
//   });

//   factory Achievement.fromJson(Map<String, dynamic> json) {
//     return Achievement(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       status: AchievementStatus.values.firstWhere(
//         (e) => e.name == json['status'],
//         orElse: () => AchievementStatus.await,
//       ),
//       data: json['data'] as String,
//     );
//   }
//   final String id;
//   final String name;
//   final AchievementStatus status;
//   final String data;

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'status': status.name,
//       'data': data,
//     };
//   }
// }
