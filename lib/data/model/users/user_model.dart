class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final int phoneVerified;
  final int emailVerified;
  final String? avatar;
  final String email;
  final String phone;
  final String address;
  final String language;
  final String status;
  //approved
  final int approved;
  final String createdAt;
  final String updatedAt;
  final List<Role>? roles;
  final List<UserRole>? userRoles;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneVerified,
    required this.emailVerified,
    this.avatar,
    required this.email,
    required this.phone,
    required this.address,
    required this.language,
    required this.status,
    required this.approved,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
    this.userRoles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneVerified: json['phone_verified'],
      emailVerified: json['email_verified'],
      avatar: json['avatar'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'] ?? '',
      language: json['language'],
      status: json['status'] ?? "",
      approved: json['approved'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      roles: json['roles'] != null
          ? (json['roles'] as List).map((role) => Role.fromJson(role)).toList()
          : null,
      userRoles: json['user_roles'] != null
          ? (json['user_roles'] as List)
                .map((userRole) => UserRole.fromJson(userRole))
                .toList()
          : null,
    );
  }
}

class Role {
  final int id;
  final String name;
  final String description;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isDefault: json['is_default'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class UserRole {
  final int id;
  final int userId;
  final int roleId;
  final String createdAt;

  UserRole({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.createdAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      userId: json['user_id'],
      roleId: json['role_id'],
      createdAt: json['created_at'],
    );
  }
}
