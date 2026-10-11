/// UserModel represents an authenticated or guest farmer account
/// reflecting the Chapter 5 `users` schema.
class UserModel {
  final String id;
  final String? displayName;
  final String? email;
  final String? phone;
  final String role; // 'farmer' | 'admin'
  final String locale; // 'en' | 'ur'
  final bool consentToRetainImages;
  final DateTime createdAt;
  final DateTime? lastSeenAt;

  const UserModel({
    required this.id,
    this.displayName,
    this.email,
    this.phone,
    this.role = 'farmer',
    this.locale = 'en',
    this.consentToRetainImages = false,
    required this.createdAt,
    this.lastSeenAt,
  });

  bool get isGuest => email == null && phone == null;
  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? phone,
    String? role,
    String? locale,
    bool? consentToRetainImages,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      consentToRetainImages: consentToRetainImages ?? this.consentToRetainImages,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'role': role,
    'locale': locale,
    'consentToRetainImages': consentToRetainImages,
    'createdAt': createdAt.toIso8601String(),
    'lastSeenAt': lastSeenAt?.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    displayName: json['displayName'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    role: json['role'] as String? ?? 'farmer',
    locale: json['locale'] as String? ?? 'en',
    consentToRetainImages: json['consentToRetainImages'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastSeenAt: json['lastSeenAt'] != null
        ? DateTime.parse(json['lastSeenAt'] as String)
        : null,
  );
}
