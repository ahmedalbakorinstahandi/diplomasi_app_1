import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/format_date.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:flutter/material.dart';

class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final bool isDownloading;

  const CertificateCard({
    super.key,
    required this.certificate,
    this.onTap,
    this.onDownload,
    this.onShare,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: width(20),
          vertical: height(12),
        ),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: Offset(0, height(2)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Image Preview
            if (certificate.imageUrl != null &&
                certificate.imageUrl!.isNotEmpty)
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: height(12)),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: certificate.imageUrl!,
                      width: 340,
                      height: 240,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: height(200),
                        color: colors.backgroundSecondary,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: scheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: height(200),
                        color: colors.backgroundSecondary,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colors.textMuted,
                          size: emp(40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Certificate Info
            Padding(
              padding: EdgeInsets.all(width(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge and Title Row
                  Row(
                    // textDirection: const TextDirection.rtl,
                    children: [
                      // Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width(8),
                          vertical: height(4),
                        ),
                        decoration: BoxDecoration(
                          color: certificate.isCourseCertificate
                              ? scheme.primary
                              : scheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          certificate.isCourseCertificate ? 'كورس' : 'مستوى',
                          style: TextStyle(
                            fontSize: emp(12),
                            fontWeight: FontWeight.w600,
                            color: certificate.isCourseCertificate
                                ? scheme.onPrimary
                                : scheme.onSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: width(8)),
                      // Title
                      Expanded(
                        child: Text(
                          certificate.title,
                          style: TextStyle(
                            fontSize: emp(18),
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                          // textDirection: const TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Subtitle (Course name for level certificates)
                  if (certificate.subtitle != null) ...[
                    SizedBox(height: height(4)),
                    Text(
                      certificate.subtitle!,
                      style: TextStyle(
                        fontSize: emp(14),
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                      // textDirection: const TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: height(12)),

                  // Issued Date
                  Row(
                    // textDirection: const TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: emp(16),
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: width(8)),
                      Text(
                        'تاريخ الإصدار: ${formatDateOnly(certificate.issuedAt)}',
                        style: TextStyle(
                          fontSize: emp(14),
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height(16)),

                  // Action Buttons
                  Row(
                    // textDirection: const TextDirection.rtl,
                    children: [
                      // Download Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.download,
                          label: 'تحميل',
                          onTap: onDownload,
                          isLoading: isDownloading,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(width: width(12)),
                      // Share Button
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.share,
                          label: 'مشاركة',
                          onTap: onShare,
                          color: scheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width(12),
          vertical: height(12),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // textDirection: const TextDirection.rtl,
          children: [
            if (isLoading)
              SizedBox(
                width: emp(16),
                height: emp(16),
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: emp(16), color: color),
            SizedBox(width: width(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: emp(14),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
