import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/app_me_response_sidecar.dart';
import 'package:diplomasi_app/data/model/users/user_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/user_data.dart';

/// Runs GET /user/me (with bootstrap query params) once per access token so cold
/// start and splash can share the same work without blocking the app shell.
class AppShellBootstrap {
  AppShellBootstrap._();

  static String? _preparedToken;
  static AppMeSidecarOutcome? lastOutcome;

  static void reset() {
    _preparedToken = null;
    lastOutcome = null;
  }

  static Future<void> ensurePreparedForCurrentToken() async {
    final tokenVal = Shared.getValue(StorageKeys.accessToken);
    final token = tokenVal?.toString() ?? '';
    if (token.isEmpty) return;
    if (_preparedToken == token) return;

    final userData = UserData();
    final response = await userData.getMyInfo(mergeBootstrapPayload: true);
    if (!response.isSuccess) return;

    final rawUser = response.data;
    if (rawUser is! Map) return;
    final userMap = Map<String, dynamic>.from(rawUser);

    Shared.setValue('user-data', userMap);
    final user = UserModel.fromJson(userMap);
    Shared.setValue(StorageKeys.accountState, user.accountState);

    final rawBody = response.body;
    if (rawBody is Map) {
      lastOutcome = await AppMeResponseSidecar.applyFromMeBody(
        Map<String, dynamic>.from(rawBody),
        mergeBootstrapPayload: true,
      );
    } else {
      lastOutcome = AppMeSidecarOutcome();
    }
    _preparedToken = token;
  }

  /// Call after a successful explicit GET /user/me with merge so [ensurePreparedForCurrentToken] stays in sync.
  static void recordSuccessfulBootstrap(AppMeSidecarOutcome outcome) {
    final tokenVal = Shared.getValue(StorageKeys.accessToken);
    final token = tokenVal?.toString() ?? '';
    if (token.isNotEmpty) {
      _preparedToken = token;
    }
    lastOutcome = outcome;
  }
}
