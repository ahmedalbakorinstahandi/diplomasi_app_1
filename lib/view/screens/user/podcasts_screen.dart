import 'package:diplomasi_app/controllers/user/podcast_player_controller.dart';
import 'package:diplomasi_app/controllers/user/podcasts_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/podcasts_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/podcast_card.dart';
import 'package:diplomasi_app/view/widgets/user/podcast_mini_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PodcastsControllerImp());
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return GetBuilder<PodcastsControllerImp>(
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              _PodcastsHeader(controller: controller),
              _FilterChips(controller: controller),
              Expanded(
                child: _PodcastsList(controller: controller, colors: colors, scheme: scheme),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _PodcastsHeader extends StatelessWidget {
  const _PodcastsHeader({required this.controller});
  final PodcastsControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(width(16), height(12), width(16), height(4)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'البودكاست',
                style: TextStyle(
                  fontSize: emp(22),
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.download_rounded, color: colors.textSecondary),
                tooltip: 'التحميلات',
                onPressed: () => Get.toNamed(AppRoutes.podcastDownloads),
              ),
            ],
          ),
          SizedBox(height: height(8)),
          // Search bar
          TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'ابحث في الحلقات...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width(12),
                vertical: height(10),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});
  final PodcastsControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final filters = [
      ('all', 'الكل'),
      ('continue_listening', 'أكمل الاستماع'),
      ('favorites', 'المفضلة'),
    ];

    return SizedBox(
      height: height(40),
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: width(16)),
            children: [
              ...filters.map((f) {
                final isSelected = controller.status.value == f.$1;
                return Padding(
                  padding: EdgeInsets.only(left: width(8)),
                  child: FilterChip(
                    label: Text(f.$2),
                    selected: isSelected,
                    onSelected: (_) => controller.setStatus(f.$1),
                    selectedColor: scheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? scheme.onPrimary : scheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: emp(12),
                    ),
                    checkmarkColor: scheme.onPrimary,
                    backgroundColor: scheme.surface,
                    side: BorderSide(
                      color: isSelected ? scheme.primary : scheme.outline.withOpacity(0.4),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
              Padding(
                padding: EdgeInsets.only(left: width(8)),
                child: Obx(() {
                  final isSelected = controller.filterFree.value == true;
                  return FilterChip(
                    label: const Text('مجاني فقط'),
                    selected: isSelected,
                    onSelected: (v) => controller.setFreeFilter(v ? true : null),
                    selectedColor: scheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? scheme.onPrimary : scheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: emp(12),
                    ),
                    checkmarkColor: scheme.onPrimary,
                    backgroundColor: scheme.surface,
                    side: BorderSide(
                      color: isSelected ? scheme.primary : scheme.outline.withOpacity(0.4),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }),
              ),
            ],
          )),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _PodcastsList extends StatelessWidget {
  const _PodcastsList({required this.controller, required this.colors, required this.scheme});
  final PodcastsControllerImp controller;
  final AppColors colors;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PodcastPlayerControllerImp>();

    return Obx(() {
      if (controller.isLoading.value && controller.podcasts.isEmpty) {
        return const PodcastsScreenShimmer();
      }

      if (controller.hasError.value && controller.podcasts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: colors.textMuted),
              SizedBox(height: height(12)),
              Text('تعذّر تحميل الحلقات', style: TextStyle(color: colors.textSecondary)),
              SizedBox(height: height(16)),
              ElevatedButton(
                onPressed: controller.refresh,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      if (controller.podcasts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.headphones_rounded, size: 64, color: colors.textMuted),
              SizedBox(height: height(16)),
              Text(
                'لا توجد حلقات',
                style: TextStyle(
                  fontSize: emp(16),
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: Obx(() {
          final miniVisible = player.currentPodcast.value != null;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              width(16),
              height(12),
              width(16),
              miniVisible ? kMiniPlayerHeight + height(16) : height(16),
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.podcasts.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i >= controller.podcasts.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(height(16)),
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                );
              }
              final podcast = controller.podcasts[i];
              return PodcastCard(
                key: ValueKey('podcast_${podcast.id}'),
                podcast: podcast,
              );
            },
          );
        }),
      );
    });
  }
}
