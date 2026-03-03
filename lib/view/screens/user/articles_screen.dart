import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/user/articles_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/articles_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/articles_header.dart';
import 'package:diplomasi_app/data/model/user/article_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ArticlesControllerImp());
    return GetBuilder<ArticlesControllerImp>(
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              // Header Section
              const ArticlesHeader(),

              if (controller.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    minHeight: height(3),
                  ),
                ),

              SizedBox(height: height(12)),

              // Articles List Section
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.getArticles(reload: true);
                  },
                  child: HandlingListDataView(
                    isLoading: controller.isLoading,
                    dataIsEmpty: controller.articles.isEmpty,
                    emptyMessage: 'لا توجد مقالات',
                    loadingWidget: const ArticlesScreenShimmer(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: controller.articlesScrollController,
                      padding: EdgeInsets.symmetric(horizontal: width(16)),
                      children: [
                        ...controller.articles.map((article) {
                          final a = article as Map<String, dynamic>;
                          return ArticleCard(
                            key: ValueKey('article_${a['id']}'),
                            article: ArticleModel.fromJson(a),
                            searchQuery: controller.searchQuery.isNotEmpty
                                ? controller.searchQuery
                                : null,
                          );
                        }),
                        if (controller.isLoadingMore)
                          Padding(
                            padding: EdgeInsets.all(height(16)),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article, this.searchQuery});
  final ArticleModel article;
  final String? searchQuery;

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly.isAtSameMomentAs(today)) {
        return 'اليوم';
      } else if (dateOnly.isAtSameMomentAs(yesterday)) {
        return 'أمس';
      } else {
        return '${date.day} ${_getMonthName(date.month)} ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    List<String> months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month];
  }

  String _getTime(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime dateTime = DateTime.parse(dateString);
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return '';
    }
  }

  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    // Remove HTML tags
    String text = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '...')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', ''')
        .replaceAll('&rsquo;', ''');

    // Remove extra whitespace and newlines
    text = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();

    return text;
  }

  /// Builds highlighted text with search query matching
  TextSpan _buildHighlightedText({
    required String text,
    required String? searchQuery,
    required TextStyle baseStyle,
    required Color highlightColor,
    required Color highlightTextColor,
  }) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    while (start < text.length) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }

      // Add highlighted match
      final int end = index + searchQuery.length;
      spans.add(
        TextSpan(
          text: text.substring(index, end),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor,
            color: highlightTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      start = end;
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: height(16)),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(width(16)),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (article.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(width(16)),
                topRight: Radius.circular(width(16)),
              ),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl!,
                width: double.infinity,
                height: height(200),
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) {
                  return Container(
                    height: height(200),
                    color: colors.border,
                    child: Icon(
                      Icons.image_not_supported,
                      color: colors.textSecondary,
                      size: width(40),
                    ),
                  );
                },
              ),
            ),
          // Content Section
          Padding(
            padding: EdgeInsets.all(width(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                RichText(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: _buildHighlightedText(
                    text: article.title,
                    searchQuery: searchQuery,
                    baseStyle: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                    highlightColor: colors.warning,
                    highlightTextColor: colors.onWarning,
                  ),
                ),
                SizedBox(height: height(12)),
                // Content Preview
                RichText(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  text: _buildHighlightedText(
                    text: _stripHtmlTags(article.content),
                    searchQuery: searchQuery,
                    baseStyle: TextStyle(
                      fontSize: emp(14),
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    highlightColor: colors.warning,
                    highlightTextColor: colors.onWarning,
                  ),
                ),
                SizedBox(height: height(12)),
                // Read More Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Get.toNamed(AppRoutes.articleDetails, arguments: article);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: height(8),
                        horizontal: width(12),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: width(12),
                      color: scheme.primary,
                      textDirection: TextDirection.rtl,
                    ),
                    label: Text(
                      'عرض المزيد',
                      style: TextStyle(
                        fontSize: emp(13),
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height(12)),
                // Author and Date Row
                Row(
                  children: [
                    // Author Info
                    if (article.author != null) ...[
                      // Author Avatar
                      if (article.author!.avatar != null)
                        CircleAvatar(
                          radius: width(16),
                          backgroundImage: NetworkImage(
                            article.author!.avatar!,
                          ),
                          onBackgroundImageError: (exception, stackTrace) {},
                          backgroundColor: colors.border,
                        )
                      else
                        CircleAvatar(
                          radius: width(16),
                          backgroundColor: scheme.primary.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: width(16),
                            color: scheme.primary,
                          ),
                        ),
                      SizedBox(width: width(8)),
                      // Author Name
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: _buildHighlightedText(
                            text: article.author!.fullName,
                            searchQuery: searchQuery,
                            baseStyle: TextStyle(
                              fontSize: emp(12),
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                            highlightColor: colors.warning,
                            highlightTextColor: colors.onWarning,
                          ),
                        ),
                      ),
                      SizedBox(width: width(12)),
                    ],
                    // Date and Time
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: width(14),
                            color: colors.textMuted,
                          ),
                          SizedBox(width: width(4)),
                          Text(
                            '${_formatDate(article.publishedAt)} ${_getTime(article.publishedAt)}',
                            style: TextStyle(
                              fontSize: emp(12),
                              fontWeight: FontWeight.w400,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
