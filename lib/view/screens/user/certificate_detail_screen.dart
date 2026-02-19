import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/controllers/user/certificate_detail_controller.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CertificateDetailScreen extends StatelessWidget {
  const CertificateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    Get.put(CertificateDetailControllerImp());
    return GetBuilder<CertificateDetailControllerImp>(
      builder: (controller) {
        if (controller.isLoading && controller.certificate == null) {
          return MyScaffold(
            body: Center(
              child: CircularProgressIndicator(color: scheme.primary),
            ),
          );
        }

        if (controller.certificate == null) {
          return MyScaffold(
            body: Center(
              child: Text(
                'الشهادة غير موجودة',
                style: TextStyle(
                  fontSize: emp(16),
                  color: colors.textSecondary,
                ),
              ),
            ),
          );
        }

        final certificate = controller.certificate!;

        return MyScaffold(
          body: Column(
            children: [
              // Header
              _CertificateDetailHeader(certificate: certificate),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(width(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Certificate Image
                      if (certificate.imageUrl != null &&
                          certificate.imageUrl!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: height(24)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow,
                                blurRadius: 16,
                                offset: Offset(0, height(4)),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: certificate.imageUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                height: height(400),
                                color: colors.backgroundSecondary,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: scheme.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: height(400),
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

                      // Certificate Info Card
                      Container(
                        padding: EdgeInsets.all(width(20)),
                        decoration: BoxDecoration(
                          color: colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge and Title
                            Row(
                              // textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width(12),
                                    vertical: height(6),
                                  ),
                                  decoration: BoxDecoration(
                                    color: certificate.isCourseCertificate
                                        ? scheme.primary
                                        : scheme.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    certificate.isCourseCertificate
                                        ? 'شهادة كورس'
                                        : 'شهادة مستوى',
                                    style: TextStyle(
                                      fontSize: emp(14),
                                      fontWeight: FontWeight.w600,
                                      color: certificate.isCourseCertificate
                                          ? scheme.onPrimary
                                          : scheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height(16)),

                            // Title
                            Text(
                              certificate.title,
                              style: TextStyle(
                                fontSize: emp(22),
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                              // textDirection: TextDirection.rtl,
                            ),

                            // Subtitle (Course name for level certificates)
                            if (certificate.subtitle != null) ...[
                              SizedBox(height: height(8)),
                              Text(
                                certificate.subtitle!,
                                style: TextStyle(
                                  fontSize: emp(16),
                                  fontWeight: FontWeight.w400,
                                  color: colors.textSecondary,
                                ),
                                // textDirection: TextDirection.rtl,
                              ),
                            ],

                            SizedBox(height: height(20)),
                            Divider(color: colors.divider),
                            SizedBox(height: height(20)),

                            // Certificate Code
                            _InfoRow(
                              icon: Icons.qr_code,
                              label: 'كود الشهادة',
                              value: certificate.certificateCode,
                            ),
                            SizedBox(height: height(12)),

                            // Issued Date
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'تاريخ الإصدار',
                              value: _formatDateForDisplay(
                                certificate.issuedAt,
                              ),
                            ),

                            // QR Code Section
                            if (certificate.qrCode != null &&
                                certificate.qrCode!.isNotEmpty) ...[
                              SizedBox(height: height(24)),
                              Divider(color: colors.divider),
                              SizedBox(height: height(20)),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'QR Code للتحقق',
                                      style: TextStyle(
                                        fontSize: emp(16),
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: height(16)),
                                    SvgPicture.network(
                                      certificate.qrCode!,
                                      width: width(150),
                                      height: width(150),
                                      placeholderBuilder: (context) =>
                                          Container(
                                            width: width(150),
                                            height: width(150),
                                            color: colors.backgroundSecondary,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: scheme.primary,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                      errorBuilder: (context, url, error) =>
                                          Icon(
                                            Icons.qr_code_scanner,
                                            size: emp(80),
                                            color: colors.textMuted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: height(24)),

                      // Action Buttons
                      Row(
                        // textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: _DetailActionButton(
                              icon: Icons.download,
                              label: 'تحميل',
                              onTap: () => controller.downloadCertificate(),
                              isLoading: controller.isDownloading,
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                            ),
                          ),
                          SizedBox(width: width(12)),
                          Expanded(
                            child: _DetailActionButton(
                              icon: Icons.share,
                              label: 'مشاركة',
                              onTap: () => controller.shareCertificate(),
                              backgroundColor: scheme.secondary,
                              foregroundColor: scheme.onSecondary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height(12)),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        child: _DetailActionButton(
                          icon: Icons.verified,
                          label: 'التحقق من الشهادة',
                          onTap: () => controller.verifyAndIssueCertificate(),
                          isLoading: controller.isLoading,
                          backgroundColor: colors.success,
                          foregroundColor: colors.onSuccess,
                        ),
                      ),

                      SizedBox(height: height(24)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateForDisplay(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String formatted = DateFormat('yyyy-MM-dd', 'ar').format(date);
      return formatted;
    } catch (e) {
      return dateString;
    }
  }
}

class _CertificateDetailHeader extends StatelessWidget {
  final CertificateModel certificate;

  const _CertificateDetailHeader({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: statusBarHeight + height(20),
        bottom: height(20),
        left: width(20),
        right: width(20),
      ),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        // textDirection: TextDirection.rtl,
        children: [
          // Back button
          InkWell(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back_ios_new, color: scheme.onPrimary),
          ),
          SizedBox(width: width(12)),
          // Title
          Expanded(
            child: Text(
              'تفاصيل الشهادة',
              style: TextStyle(
                fontSize: emp(24),
                fontWeight: FontWeight.bold,
                color: scheme.onPrimary,
              ),
              // textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      // textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: emp(20), color: colors.textSecondary),
        SizedBox(width: width(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // textDirection: TextDirection.rtl,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: emp(12),
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: height(4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: emp(16),
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLoading = false,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width(16),
          vertical: height(16),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // textDirection: TextDirection.rtl,
          children: [
            if (isLoading)
              SizedBox(
                width: emp(20),
                height: emp(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            else
              Icon(icon, size: emp(20), color: foregroundColor),
            SizedBox(width: width(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: emp(16),
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
