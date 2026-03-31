class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final bool phoneVerified;
  final bool emailVerified;
  final String? avatar;
  final String? email;
  final String? phone;
  final String address;
  final String language;
  final String status;
  final bool isGuest;
  final String accountState;
  //approved
  final bool approved;
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
    required this.isGuest,
    required this.accountState,
    required this.approved,
    required this.createdAt,
    required this.updatedAt,
    this.roles,
    this.userRoles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final parsedIsGuest = json['is_guest'] == true || json['is_guest'] == 1;
    final parsedEmailVerified =
        json['email_verified'] == true || json['email_verified'] == 1;
    final parsedAccountState = (json['account_state'] ?? '').toString();

    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneVerified: json['phone_verified'] == true || json['phone_verified'] == 1,
      emailVerified: parsedEmailVerified,
      avatar: json['avatar'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'] ?? '',
      language: json['language'] ?? 'ar',
      status: json['status'] ?? "",
      isGuest: parsedIsGuest,
      accountState: parsedAccountState.isNotEmpty
          ? parsedAccountState
          : (parsedIsGuest
                ? 'guest'
                : (parsedEmailVerified
                      ? 'registered_verified'
                      : 'registered_unverified')),
      approved: json['approved'] ?? false,
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
