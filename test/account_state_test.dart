import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses guest account_state from API payload', () {
    final user = UserModel.fromJson({
      'id': 1,
      'first_name': 'Guest',
      'last_name': 'User',
      'phone_verified': false,
      'email_verified': false,
      'avatar': null,
      'email': null,
      'phone': null,
      'address': null,
      'language': 'ar',
      'status': 'active',
      'is_guest': true,
      'account_state': 'guest',
      'approved': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    expect(user.isGuest, true);
    expect(user.accountState, 'guest');
  });

  test('falls back to computed account_state when API omits it', () {
    final user = UserModel.fromJson({
      'id': 2,
      'first_name': 'Ali',
      'last_name': 'Masry',
      'phone_verified': false,
      'email_verified': true,
      'avatar': null,
      'email': 'ali@example.com',
      'phone': null,
      'address': null,
      'language': 'ar',
      'status': 'active',
      'is_guest': false,
      'approved': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    expect(user.isGuest, false);
    expect(user.accountState, 'registered_verified');
  });
}
