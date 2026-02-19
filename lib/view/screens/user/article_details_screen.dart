import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final ArticleModel article = Get.arguments as ArticleModel;
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return MyScaffold(
      body: Column(
        children: [
          // Article Header
          Container(
            width: getWidth(),
            padding: EdgeInsets.only(
              top: statusBarHeight + height(20),
              left: width(20),
              right: width(20),
              bottom: height(20),
            ),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: scheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: width(12)),
                    Expanded(
                      child: Text(
                        article.title,
                        style: TextStyle(
                          fontSize: emp(24),
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimary,
                          height: 1.4,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                if (article.author != null || article.publishedAt != null) ...[
                  SizedBox(height: height(16)),
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
                            backgroundColor: scheme.onPrimary.withOpacity(0.2),
                          )
                        else
                          CircleAvatar(
                            radius: width(16),
                            backgroundColor: scheme.onPrimary.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              size: width(16),
                              color: scheme.onPrimary,
                            ),
                          ),
                        SizedBox(width: width(8)),
                        // Author Name
                        Expanded(
                          child: Text(
                            article.author!.fullName,
                            style: TextStyle(
                              fontSize: emp(14),
                              fontWeight: FontWeight.w500,
                              color: scheme.onPrimary.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (article.publishedAt != null)
                          SizedBox(width: width(16)),
                      ],
                      // Date and Time
                      if (article.publishedAt != null)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: width(16),
                                color: scheme.onPrimary.withOpacity(0.8),
                              ),
                              SizedBox(width: width(6)),
                              Flexible(
                                child: Text(
                                  '${_formatDate(article.publishedAt)} ${_getTime(article.publishedAt)}',
                                  style: TextStyle(
                                    fontSize: emp(13),
                                    fontWeight: FontWeight.w400,
                                    color: scheme.onPrimary.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height(10)),
                  // Content Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        if (article.imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            width: double.infinity,
                            height: height(250),
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                height: height(250),
                                color: colors.border,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: colors.textSecondary,
                                  size: width(40),
                                ),
                              );
                            },
                          ),
                        SizedBox(height: height(24)),

                        // HTML Content
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Html(
                            data: article.content,
                            style: {
                              "body": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontSize: FontSize(emp(16)),
                                color: scheme.onSurface,
                                lineHeight: LineHeight(1.8),
                              ),
                              "p": Style(
                                margin: Margins.only(bottom: 14),
                                fontSize: FontSize(emp(16)),
                                lineHeight: LineHeight(1.8),
                              ),
                              "h1": Style(
                                fontSize: FontSize(emp(28)),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(bottom: 18, top: 24),
                                color: scheme.onSurface,
                              ),
                              "h2": Style(
                                fontSize: FontSize(emp(20)),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(bottom: 14, top: 20),
                                color: scheme.onSurface,
                              ),
                              "h3": Style(
                                fontSize: FontSize(emp(18)),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(bottom: 12, top: 16),
                                color: scheme.onSurface,
                              ),
                              "ul": Style(
                                margin: Margins.only(bottom: 14),
                                padding: HtmlPaddings.only(left: 18),
                              ),
                              "li": Style(
                                margin: Margins.only(bottom: 6),
                                fontSize: FontSize(emp(16)),
                                lineHeight: LineHeight(1.8),
                              ),
                              "strong": Style(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                              "div": Style(margin: Margins.only(bottom: 14)),
                              "article": Style(
                                padding: HtmlPaddings.zero,
                                margin: Margins.zero,
                              ),
                              "header": Style(
                                padding: HtmlPaddings.only(bottom: 16),
                                margin: Margins.only(bottom: 18),
                                border: Border(
                                  bottom: BorderSide(
                                    color: colors.borderStrong,
                                    width: 1,
                                  ),
                                ),
                              ),
                              "section": Style(margin: Margins.only(top: 18)),
                              "footer": Style(
                                margin: Margins.only(top: 26),
                                padding: HtmlPaddings.only(top: 14),
                                border: Border(
                                  top: BorderSide(
                                    color: colors.borderStrong,
                                    width: 1,
                                  ),
                                ),
                                fontSize: FontSize(emp(13)),
                                color: colors.textMuted,
                              ),
                            },
                          ),
                        ),

                        SizedBox(height: height(32)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
