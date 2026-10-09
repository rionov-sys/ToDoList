class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String timezone;
  final String plan;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.timezone = 'Asia/Jakarta (WIB • UTC+7)',
    this.plan = 'Pro Plan',
    required this.createdAt,
  });

  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta (WIB • UTC+7)',
      plan: json['plan'] as String? ?? 'Pro Plan',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'plan': plan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? timezone,
    String? plan,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
