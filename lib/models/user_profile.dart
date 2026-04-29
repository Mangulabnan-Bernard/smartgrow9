class UserProfile {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
