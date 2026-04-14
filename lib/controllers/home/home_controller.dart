import 'package:diplomasi_app/controllers/app_controller.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/shared_preferences.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/constants/storage_keys.dart';
import 'package:diplomasi_app/core/services/app_shell_bootstrap.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/data/model/learning/level_model.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:diplomasi_app/data/resource/remote/learning/levels_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';
import 'package:diplomasi_app/data/resource/remote/user/certificates_data.dart';
import 'package:get/get.dart';

abstract class HomeController extends GetxController {
  bool isLoading = false;
  bool isLoadingTracks = false;
  bool isLoadingLevels = false;

  LevelsData levelsData = LevelsData();
  CertificatesData certificatesData = CertificatesData();

  LevelModel? level;
  List levels = [];
  List levelTracks = [];
  int completedTracks = 0;
  double progressPercentage = 0.0;
  int userPoints = 10; // Default points
  bool shouldShowPremiumBanner = true;

  Future<void> getLevelDetails();
  Future<void> getLevelTracks();
  Future<void> getLevels();
  void selectLevel(LevelModel level);
  void calculateProgress();
  LevelModel? getNextLevel();
  Future<void> goToNextLevel();
  Future<void> viewCertificate();
}

class HomeControllerImp extends HomeController {
  final BillingData _billingData = BillingData();
  bool _didBootstrapSubscriptionState = false;
  bool _isBootstrappingSubscriptionState = false;

  @override
  void onInit() {
    _applyBannerStateFromCache();
    _bootstrapSubscriptionState();
    Future.microtask(() async {
      await getLevels();
      await getLevelTracks();
    });
    super.onInit();
  }

  Map<String, dynamic>? get _cachedSubscriptionSnapshot =>
      Shared.getMapValueOrNull(StorageKeys.subscriptionState);

  bool get _isCachedActiveSubscription {
    final cached = _cachedSubscriptionSnapshot;
    if (cached == null) return false;
    final status = (cached['status'] ?? '').toString().toLowerCase();
    return status == 'active' || status == 'past_due';
  }

  bool get _shouldFetchSubscriptionOnAppOpen {
    final cached = _cachedSubscriptionSnapshot;
    if (cached == null) return true;
    final status = (cached['status'] ?? '').toString().toLowerCase();
    return status != 'active';
  }

  void _applyBannerStateFromCache() {
    shouldShowPremiumBanner = !_isCachedActiveSubscription;
  }

  void _persistSubscriptionSnapshot(Map<String, dynamic>? subscription) {
    final status = (subscription?['status'] ?? 'none').toString().toLowerCase();
    final normalizedStatus = status.isEmpty ? 'none' : status;
    Shared.setValue(StorageKeys.subscriptionState, {
      'has_subscription': subscription != null,
      'status': normalizedStatus,
      'plan_id': subscription?['plan_id'],
      'end_date': subscription?['end_date'],
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _bootstrapSubscriptionState() async {
    if (_didBootstrapSubscriptionState || _isBootstrappingSubscriptionState) {
      return;
    }
    _didBootstrapSubscriptionState = true;

    if (Get.isRegistered<AppControllerImp>()) {
      final app = Get.find<AppControllerImp>();
      if (app.shellBootstrapSidecarOutcome?.mergedSubscriptionPayload == true) {
        _applyBannerStateFromCache();
        update();
        return;
      }
    }

    if (currentAccountState != 'registered_verified') {
      _persistSubscriptionSnapshot(null);
      shouldShowPremiumBanner = true;
      update();
      return;
    }

    if (!_shouldFetchSubscriptionOnAppOpen) {
      update();
      return;
    }

    _isBootstrappingSubscriptionState = true;
    try {
      final response = await _billingData.getCurrentSubscription();
      if (response.isSuccess) {
        final subscription = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;
        _persistSubscriptionSnapshot(subscription);
      } else if (response.statusCode == 404) {
        _persistSubscriptionSnapshot(null);
      }
      _applyBannerStateFromCache();
      update();
    } finally {
      _isBootstrappingSubscriptionState = false;
    }
  }

  @override
  Future<void> getLevelDetails() async {
    // This method is kept for backward compatibility but should not be used
    // Use updateLevelFromLevels() instead
    updateLevelFromLevels();
  }

  /// Updates the current level data from the levels list
  void updateLevelFromLevels() {
    if (levels.isEmpty || level == null) return;

    try {
      final currentLevelId = level!.id;
      dynamic levelData;
      try {
        levelData = levels.firstWhere(
          (l) => (l as Map<String, dynamic>)['id'] == currentLevelId,
        );
      } catch (e) {
        // Level not found in list
        return;
      }

      if (levelData != null) {
        level = LevelModel.fromJson(levelData as Map<String, dynamic>);
        update();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> getLevelTracks() async {
    if (isLoadingTracks) return;

    isLoadingTracks = true;
    update();

    int levelId = Shared.getValue(StorageKeys.levelId, initialValue: 0);

    if (levelId == 0) {
      isLoadingTracks = false;
      update();
      return;
    }

    // Store previous level status to check if it changed
    final previousAccessStatus = level?.accessStatus;
    final previousIsCompleted = level?.isCompleted;

    var response = await levelsData.track(levelId);

    if (response.isSuccess) {
      levelTracks = await response.data;

      calculateProgress();

      // Check if level status changed by examining levelTracks data
      // The level data might be included in the tracks response
      bool levelStatusChanged = false;

      if (levelTracks.isNotEmpty) {
        // Check if level data is in any track response
        Map<String, dynamic>? levelDataFromTrack;
        for (var track in levelTracks) {
          if (track['level'] != null) {
            levelDataFromTrack = track['level'] as Map<String, dynamic>;
            break; // Use first track that has level data
          }
        }

        if (levelDataFromTrack != null) {
          final newAccessStatus =
              levelDataFromTrack['access_status'] as String?;
          final newIsCompleted = levelDataFromTrack['is_completed'] as bool?;

          // Check if status actually changed
          if (newAccessStatus != previousAccessStatus ||
              newIsCompleted != previousIsCompleted) {
            levelStatusChanged = true;
          }
        } else {
          // If level data not in tracks, check if all tracks are completed
          // This indicates the level might have been completed
          final allTracksCompleted = levelTracks.every((track) {
            final trackable = track['trackable'];
            return trackable != null && trackable['status'] == 'completed';
          });

          // If all tracks completed and level wasn't completed before, status changed
          if (allTracksCompleted &&
              (previousAccessStatus != 'completed' ||
                  previousIsCompleted != true)) {
            levelStatusChanged = true;
          }
        }
      }

      // If level status changed, update levels list
      if (levelStatusChanged) {
        await getLevels();
        // Update current level from the updated levels list
        updateLevelFromLevels();
      }
    }

    isLoadingTracks = false;
    update();
  }

  @override
  Future<void> getLevels() async {
    if (isLoadingLevels) return;

    isLoadingLevels = true;
    update();

    var courseId = Shared.getValue(StorageKeys.courseId, initialValue: 0) as int;
    if (courseId == 0) {
      await AppShellBootstrap.ensurePreparedForCurrentToken();
      courseId = Shared.getValue(StorageKeys.courseId, initialValue: 0) as int;
    }
    if (courseId == 0) {
      isLoadingLevels = false;
      update();
      return;
    }

    ApiResponse response = await levelsData.get(courseId: courseId);

    if (response.isSuccess) {
      levels = response.data;

      // Update current level from levels list
      if (levels.isNotEmpty) {
        final currentLevelId = Shared.getValue(
          StorageKeys.levelId,
          initialValue: 0,
        );
        if (currentLevelId > 0) {
          try {
            final levelData = levels.firstWhere(
              (l) => (l as Map<String, dynamic>)['id'] == currentLevelId,
            );
            level = LevelModel.fromJson(levelData as Map<String, dynamic>);
          } catch (e) {
            // Level not found, if level is null, select first level
            if (level == null && levels.isNotEmpty) {
              level = LevelModel.fromJson(levels.first as Map<String, dynamic>);
              Shared.setValue(StorageKeys.levelId, level!.id);
            }
          }
        } else if (level == null) {
          level = LevelModel.fromJson(levels.first as Map<String, dynamic>);
          Shared.setValue(StorageKeys.levelId, level!.id);
        } else {
          // Update existing level from levels list
          updateLevelFromLevels();
        }
      }
    }
    isLoadingLevels = false;
    update();
  }

  @override
  void selectLevel(LevelModel selectedLevel) {
    level = selectedLevel;
    Shared.setValue(StorageKeys.levelId, selectedLevel.id);
    // Only reload tracks for the new level, level data comes from levels list
    getLevelTracks();
    update();
  }

  @override
  void calculateProgress() {
    completedTracks = 0;
    if (levelTracks.isEmpty) {
      progressPercentage = 0;
      return;
    }

    for (int i = 0; i < levelTracks.length; i++) {
      if (levelTracks[i]['status'] == 'completed') {
        completedTracks++;
      }
    }

    progressPercentage = (completedTracks / levelTracks.length) * 100;
  }

  @override
  LevelModel? getNextLevel() {
    if (level == null || levels.isEmpty) return null;

    try {
      // Convert levels to LevelModel list
      final levelModels = levels
          .map((l) => LevelModel.fromJson(l as Map<String, dynamic>))
          .toList();

      // Find current level index
      final currentIndex = levelModels.indexWhere((l) => l.id == level!.id);

      // If current level found and there's a next level
      if (currentIndex >= 0 && currentIndex < levelModels.length - 1) {
        return levelModels[currentIndex + 1];
      }
    } catch (e) {
      // Handle error silently
    }

    return null;
  }

  @override
  Future<void> goToNextLevel() async {
    final nextLevel = getNextLevel();
    if (nextLevel != null) {
      selectLevel(nextLevel);
    }
  }

  @override
  Future<void> viewCertificate() async {
    if (level == null) return;

    try {
      // Get certificate for current level
      ApiResponse response = await certificatesData.getCertificates(
        levelId: level!.id,
        perPage: 1,
      );

      if (response.isSuccess && response.data.isNotEmpty) {
        final certificate = CertificateModel.fromJson(
          response.data[0] as Map<String, dynamic>,
        );
        Get.toNamed(
          AppRoutes.certificateDetail.replaceAll(
            ':id',
            certificate.id.toString(),
          ),
        );
      } else {
        // If no certificate found, show message or navigate to certificates page
        Get.toNamed(AppRoutes.certificates);
      }
    } catch (e) {
      // Handle error - navigate to certificates page
      Get.toNamed(AppRoutes.certificates);
    }
  }
}
