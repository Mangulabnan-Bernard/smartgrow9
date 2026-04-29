class UserStats {
  final int xp;
  final int level;
  final int scansCount;
  final int sessionsCount;
  final String username;
  final String? fullName;
  final String profileIcon;
  final String? lastAction;
  final String themeColor;

  const UserStats({
    required this.xp,
    required this.level,
    required this.scansCount,
    required this.sessionsCount,
    required this.username,
    this.fullName,
    required this.profileIcon,
    this.lastAction,
    this.themeColor = 'green',
  });

  UserStats copyWith({
    int? xp,
    int? level,
    int? scansCount,
    int? sessionsCount,
    String? username,
    String? fullName,
    String? profileIcon,
    String? lastAction,
    String? themeColor,
  }) {
    return UserStats(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      scansCount: scansCount ?? this.scansCount,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileIcon: profileIcon ?? this.profileIcon,
      lastAction: lastAction ?? this.lastAction,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'level': level,
      'scansCount': scansCount,
      'sessionsCount': sessionsCount,
      'username': username,
      'fullName': fullName,
      'profileIcon': profileIcon,
      'lastAction': lastAction,
      'themeColor': themeColor,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      scansCount: json['scansCount'] ?? 0,
      sessionsCount: json['sessionsCount'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'],
      profileIcon: json['profileIcon'] ?? 'Persona1',
      lastAction: json['lastAction'],
      themeColor: json['themeColor'] ?? 'green',
    );
  }

  int get nextLevelXp => level * 1000;

  double get xpProgress => (xp / nextLevelXp).clamp(0.0, 1.0);
}