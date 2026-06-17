enum UserRole {
  merchant(2),
  salesman(1)
  ;

  final int value;
  const UserRole(this.value);

  // Helper to get enum from integer
  static UserRole fromInt(int val) {
    return val == 1 ? UserRole.salesman : UserRole.merchant;
  }
}

class UserDetails {
  UserDetails({
    required this.uuid,
    required this.name,
    required this.email,
    required this.role,
    required this.hasClockedIn,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.phone,
  });

  // Fixed the empty factory to provide the Enum type, not an int
  factory UserDetails.empty() {
    return UserDetails(
      uuid: '',
      name: '',
      email: '',
      role: UserRole.salesman,
      hasClockedIn: false,
      firstName: '',
      lastName: '',
      imageUrl: '',
      phone: '',
    );
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final roleInt = int.tryParse(json['role']?.toString() ?? '0') ?? 0;

    return UserDetails(
      uuid: json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRole.fromInt(roleInt),
      hasClockedIn: json['has_clocked_in']?.toString() == 'true',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      imageUrl: json['profile_image']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
  final String uuid;
  final String name;
  final String email;
  final UserRole role;
  final bool hasClockedIn;
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String phone;

  UserDetails copyWith({
    String? uuid,
    String? name,
    String? email,
    UserRole? role,
    bool? hasClockedIn,
    String? firstName,
    String? lastName,
    String? imageUrl,
    String? phone,
  }) {
    return UserDetails(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hasClockedIn: hasClockedIn ?? this.hasClockedIn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'email': email,
    'role': role.value, // Save the integer value (0 or 1)
    'has_clocked_in': hasClockedIn,
    'first_name': firstName,
    'last_name': lastName,
    'image_url': imageUrl,
    'phone': phone,
  };

  @override
  String toString() {
    return 'UserDetails(uuid: $uuid, name: $name, email: $email, role: ${role.name}, clockedIn: $hasClockedIn, firstName: $firstName, lastName: $lastName, imageUrl: $imageUrl, phone: $phone)';
  }
}
