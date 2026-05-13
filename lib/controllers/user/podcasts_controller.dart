import 'dart:async';

import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/services/podcast_listen_progress_store.dart';
import 'package:diplomasi_app/controllers/user/podcast_download_controller.dart';
import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/data/model/user/podcast_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/podcasts_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastsControllerImp extends GetxController {
  final PodcastsData _data = PodcastsData();

  // ── list state ──────────────────────────────────────────────────────────────
  final RxList<PodcastModel> podcasts = <PodcastModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;

  int _page = 1;
  bool _hasMore = true;
  CancelToken? _cancelToken;

  // ── filters ─────────────────────────────────────────────────────────────────
  /// 'all' | 'continue_listening' | 'favorites'
  final RxString status = 'all'.obs;
  final RxnBool filterFree = RxnBool(null);

  final RxString searchQuery = ''.obs;
  Timer? _searchDebounce;
  CancelToken? _searchCancelToken;

  PodcastPlayerControllerImp get _player => Get.find<PodcastPlayerControllerImp>();
  PodcastDownloadControllerImp get _downloads => Get.find<PodcastDownloadControllerImp>();

  // ── lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _downloads.hydrateFromStorage();
    fetchPodcasts(reload: true);

    // Keep the list in sync when the user toggles a favourite from the player screen.
    ever(_player.lastFavouriteToggle, ((int, bool)? event) {
      if (event == null) return;
      final idx = podcasts.indexWhere((p) => p.id == event.$1);
      if (idx >= 0) {
        podcasts[idx] = podcasts[idx].copyWith(isFavorite: event.$2);
        podcasts.refresh();
      }
    });
  }

  @override
  void onClose() {
    _cancelToken?.cancel();
    _searchCancelToken?.cancel();
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ── data loading ─────────────────────────────────────────────────────────────
  Future<void> fetchPodcasts({bool reload = false}) async {
    if (isLoading.value && !reload) return;

    if (reload) {
      _page = 1;
      _hasMore = true;
      _cancelToken?.cancel();
      _cancelToken = CancelToken();
      hasError.value = false;
    } else {
      if (!_hasMore) return;
    }

    if (_page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      // Without a session the API falls back to `all` for this filter; we then
      // narrow client-side using merged local progress.
      final apiStatus =
          (!isUserLoggedIn && status.value == 'continue_listening')
              ? 'all'
              : status.value;

      final res = await _data.getPodcasts(
        page: _page,
        status: apiStatus,
        isFree: filterFree.value,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        cancelToken: _cancelToken,
      );

      if (res.isSuccess && res.data != null) {
        final raw = res.data;
        if (raw is! List) {
          hasError.value = true;
        } else {
          var items = raw
              .map((e) => PodcastModel.fromJson(e as Map<String, dynamic>))
              .map(PodcastListenProgressStore.mergeIntoPodcast)
              .toList();

          if (!isUserLoggedIn && status.value == 'continue_listening') {
            items = items
                .where(PodcastListenProgressStore.looksLikeContinueListening)
                .toList();
          }

          if (reload) {
            podcasts.assignAll(items);
          } else {
            podcasts.addAll(items);
          }

          final meta = res.meta;
          if (meta != null) {
            _hasMore = meta.currentPage < meta.lastPage;
            _page = meta.currentPage + 1;
          } else {
            // Still show [data]; disable endless scroll if pagination meta is missing.
            _hasMore = false;
            _page = 1;
          }
        }
      } else if (!res.isSuccess) {
        hasError.value = true;
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  @override
  Future<void> refresh() => fetchPodcasts(reload: true);

  void setStatus(String s) {
    if (status.value == s) return;

    // Favorites need an account; «أكمل الاستماع» uses local progress when unauthenticated.
    if (s == 'favorites' && !isUserLoggedIn) {
      customSnackBar(
        text: 'سجّل الدخول لعرض المفضلة',
        snackType: SnackBarType.info,
      );
      return;
    }

    status.value = s;
    fetchPodcasts(reload: true);
  }

  void setFreeFilter(bool? v) {
    filterFree.value = v;
    fetchPodcasts(reload: true);
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchCancelToken?.cancel();
    _searchCancelToken = CancelToken();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchPodcasts(reload: true);
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    fetchPodcasts(reload: true);
  }

  // ── favorite toggle (optimistic) ─────────────────────────────────────────────
  Future<void> toggleFavorite(PodcastModel podcast) async {
    if (!isUserLoggedIn) {
      customSnackBar(
        text: 'سجّل الدخول لإضافة الحلقات إلى المفضلة',
        snackType: SnackBarType.info,
      );
      return;
    }

    final idx = podcasts.indexWhere((p) => p.id == podcast.id);
    final wasFav = idx >= 0 ? podcasts[idx].isFavorite : podcast.isFavorite;

    if (idx >= 0) {
      podcasts[idx] = podcasts[idx].copyWith(isFavorite: !wasFav);
      podcasts.refresh();
    }

    final ApiResponse res = wasFav
        ? await _data.removeFavorite(podcast.id)
        : await _data.addFavorite(podcast.id);

    if (!res.isSuccess) {
      if (idx >= 0) {
        podcasts[idx] = podcasts[idx].copyWith(isFavorite: wasFav);
        podcasts.refresh();
      }
      customSnackBar(
        text: 'تعذّر تحديث المفضلة. تحقق من الاتصال وحاول مرة أخرى.',
        snackType: SnackBarType.error,
      );
    }
  }

  // ── play ─────────────────────────────────────────────────────────────────────
  Future<void> play(PodcastModel podcast) async {
    if (podcast.isLocked) {
      _showLockedSheet(podcast);
      return;
    }
    // Pass the full visible list as the queue so prev/next navigation works
    // in the player screen, notification, and car controls.
    final idx = podcasts.indexWhere((p) => p.id == podcast.id);
    _player.setQueue(podcasts.toList(), idx >= 0 ? idx : 0);
    await _player.playFromModel(podcast);
  }

  void _showLockedSheet(PodcastModel podcast) {
    Get.bottomSheet(
      _LockedPodcastSheet(podcast: podcast),
      isScrollControlled: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Simple locked-podcast bottom sheet (reuses theme; no external dependency).
// ---------------------------------------------------------------------------
class _LockedPodcastSheet extends StatelessWidget {
  const _LockedPodcastSheet({required this.podcast});
  final PodcastModel podcast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.lock_rounded, size: 48, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'هذه الحلقة متاحة للمشتركين فقط',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'اشترك للوصول إلى جميع الحلقات الصوتية',
              style: TextStyle(fontSize: 14, color: scheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/plans');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'اشترك الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
