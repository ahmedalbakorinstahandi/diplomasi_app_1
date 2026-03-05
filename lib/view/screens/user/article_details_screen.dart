import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/controllers/user/article_details_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/format_date.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticleModel article = Get.arguments as ArticleModel;
    final controller = Get.put(ArticleDetailsController());
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final statusBarHeight = MediaQuery.of(context).padding.top;

    const double contentPadding = 20;
    final imageHeight = height(240);
    final imageRadius = 12.0;

    return MyScaffold(
      body: Column(
        children: [
          // —— الهيدر ——
          Container(
            width: getWidth(),
            padding: EdgeInsets.only(
              top: statusBarHeight + height(16),
              left: width(contentPadding),
              right: width(contentPadding),
              bottom: height(16),
            ),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(width(24)),
                      child: Padding(
                        padding: EdgeInsets.all(width(4)),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: emp(22),
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: width(8)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: height(2)),
                        child: Text(
                          article.title,
                          style: TextStyle(
                            fontSize: emp(22),
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimary,
                            height: 1.35,
                          ),
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
                if (article.author != null || article.publishedAt != null) ...[
                  SizedBox(height: height(14)),
                  Row(
                    children: [
                      if (article.author != null) ...[
                        CircleAvatar(
                          radius: width(14),
                          backgroundImage: article.author!.avatar != null
                              ? NetworkImage(article.author!.avatar!)
                              : null,
                          onBackgroundImageError: (_, __) {},
                          backgroundColor: scheme.onPrimary.withOpacity(0.22),
                          child: article.author!.avatar == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: width(16),
                                  color: scheme.onPrimary,
                                )
                              : null,
                        ),
                        SizedBox(width: width(8)),
                        Expanded(
                          child: Text(
                            article.author!.fullName,
                            style: TextStyle(
                              fontSize: emp(13),
                              fontWeight: FontWeight.w500,
                              color: scheme.onPrimary.withOpacity(0.92),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (article.publishedAt != null) SizedBox(width: width(12)),
                      ],
                      if (article.publishedAt != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: width(14),
                              color: scheme.onPrimary.withOpacity(0.85),
                            ),
                            SizedBox(width: width(4)),
                            Text(
                              formatDateTime(article.publishedAt),
                              style: TextStyle(
                                fontSize: emp(12),
                                color: scheme.onPrimary.withOpacity(0.85),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // —— المحتوى + أزرار عائمة على الشمال ——
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                SingleChildScrollView(
              padding: EdgeInsets.only(
                top: height(20),
                left: width(contentPadding),
                right: width(contentPadding),
                bottom: height(32) + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(imageRadius),
                      child: CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            height: imageHeight,
                            color: colors.border,
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: colors.textSecondary,
                              size: width(40),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: height(22)),
                  ],
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
                          lineHeight: LineHeight(1.75),
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 16),
                          fontSize: FontSize(emp(16)),
                          lineHeight: LineHeight(1.75),
                        ),
                        "h1": Style(
                          fontSize: FontSize(emp(26)),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(bottom: 16, top: 22),
                          color: scheme.onSurface,
                        ),
                        "h2": Style(
                          fontSize: FontSize(emp(20)),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(bottom: 12, top: 18),
                          color: scheme.onSurface,
                        ),
                        "h3": Style(
                          fontSize: FontSize(emp(18)),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(bottom: 10, top: 14),
                          color: scheme.onSurface,
                        ),
                        "ul": Style(
                          margin: Margins.only(bottom: 16),
                          padding: HtmlPaddings.only(left: 18),
                        ),
                        "li": Style(
                          margin: Margins.only(bottom: 6),
                          fontSize: FontSize(emp(16)),
                          lineHeight: LineHeight(1.75),
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
                          padding: HtmlPaddings.only(bottom: 14),
                          margin: Margins.only(bottom: 16),
                          border: Border(
                            bottom: BorderSide(
                              color: colors.borderStrong,
                              width: 1,
                            ),
                          ),
                        ),
                        "section": Style(margin: Margins.only(top: 16)),
                        "footer": Style(
                          margin: Margins.only(top: 22),
                          padding: HtmlPaddings.only(top: 12),
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
                ],
              ),
            ),
                if (article.pdfUrl != null && article.pdfUrl!.isNotEmpty)
                  Positioned(
                    left: width(12),
                    top: height(16),
                    child: GetBuilder<ArticleDetailsController>(
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ArticleActionButton(
                              icon: Icons.visibility_rounded,
                              onTap: controller.previewArticlePdf,
                              tooltip: 'معاينة',
                            ),
                            SizedBox(height: height(8)),
                            _ArticleActionButton(
                              icon: Icons.download_rounded,
                              onTap: controller.isDownloadingPdf
                                  ? null
                                  : controller.downloadArticlePdf,
                              loading: controller.isDownloadingPdf,
                              tooltip: 'تحميل',
                            ),
                            SizedBox(height: height(8)),
                            _ArticleActionButton(
                              icon: Icons.share_rounded,
                              onTap: controller.isSharingPdf
                                  ? null
                                  : controller.shareArticlePdf,
                              loading: controller.isSharingPdf,
                              tooltip: 'مشاركة',
                            ),
                            SizedBox(height: height(8)),
                            _ArticleActionButton(
                              icon: Icons.link_rounded,
                              onTap: controller.copyArticleLink,
                              tooltip: 'نسخ الرابط',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  final String tooltip;

  const _ArticleActionButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = width(36);
    final radius = size / 2;

    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.92),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: emp(16),
                        height: emp(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Icon(
                        icon,
                        size: emp(18),
                        color: scheme.onPrimary,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
