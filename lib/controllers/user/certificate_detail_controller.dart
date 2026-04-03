import 'dart:io';

import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/functions/user_download_file.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/certificates_data.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class CertificateDetailController extends GetxController {
  bool isLoading = false;
  bool isDownloading = false;
  CertificateModel? certificate;

  CertificatesData certificatesData = CertificatesData();

  Future<void> getCertificate(int id);
  Future<void> downloadCertificate();
  Future<void> shareCertificate();
  Future<void> verifyAndIssueCertificate();
  void showVerificationUrl();
}

class CertificateDetailControllerImp extends CertificateDetailController {
  @override
  void onInit() {
    super.onInit();
    final certificateId = int.tryParse(Get.parameters['id'] ?? '');
    if (certificateId != null) {
      getCertificate(certificateId);
    }
  }

  @override
  Future<void> getCertificate(int id) async {
    if (isLoading) return;

    isLoading = true;
    update();

    try {
      final response = await certificatesData.getCertificate(id);

      if (response.isSuccess) {
        certificate = CertificateModel.fromJson(response.data);
      } else {
        customSnackBar(
          text: response.message ?? 'فشل في تحميل الشهادة',
          snackType: SnackBarType.error,
        );
      }
    } catch (e) {
      customSnackBar(
        text: 'حدث خطأ أثناء تحميل الشهادة: ${e.toString()}',
        snackType: SnackBarType.error,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  Future<void> downloadCertificate() async {
    if (certificate == null || isDownloading) return;

    isDownloading = true;
    update();

    try {
      final bytes = await _loadCertificateBytes(certificate!);

      if (bytes != null) {
        final name = sanitizeDownloadFileName(
          certificate!.certificateCode,
          fallback: 'certificate_${certificate!.id}',
        );
        final path = await saveBytesToUserLocation(
          name: name,
          bytes: bytes,
          fileExtension: 'png',
          mimeType: MimeType.png,
        );
        if (path == null) {
          return;
        }
        if (looksLikeFileSaverFailure(path)) {
          customSnackBar(
            text: 'تعذر حفظ صورة الشهادة.',
            snackType: SnackBarType.error,
          );
          return;
        }
        customSnackBar(
          text: 'تم حفظ الشهادة',
          snackType: SnackBarType.correct,
        );
        if (!kIsWeb) {
          try {
            await shareFileByPath(
              path,
              subject: 'شهادة: ${certificate!.title}',
            );
          } catch (_) {
            customSnackBar(
              text: 'حُفظت الشهادة. يمكنك مشاركتها من تطبيق الملفات.',
              snackType: SnackBarType.info,
            );
          }
        }
      } else {
        customSnackBar(
          text: 'فشل تحميل الشهادة',
          snackType: SnackBarType.error,
        );
      }
    } catch (e) {
      customSnackBar(
        text: 'حدث خطأ أثناء تحميل الشهادة: ${e.toString()}',
        snackType: SnackBarType.error,
      );
    } finally {
      isDownloading = false;
      update();
    }
  }

  @override
  Future<void> shareCertificate() async {
    if (certificate == null) return;

    try {
      final bytes = await _loadCertificateBytes(certificate!);

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cert_share_${certificate!.id}_${certificate!.certificateCode}.png',
        );
        await file.writeAsBytes(bytes, flush: true);
        await shareFileByPath(
          file.path,
          subject: 'شهادة: ${certificate!.title}',
        );
        try {
          await file.delete();
        } catch (_) {}
      } else {
        await Share.share(
          'شهادة من منصة دبلوماسي\n${certificate!.title}\n${certificate!.verificationUrl}',
          subject: 'شهادة: ${certificate!.title}',
        );
      }
    } catch (e) {
      customSnackBar(
        text: 'حدث خطأ أثناء مشاركة الشهادة',
        snackType: SnackBarType.error,
      );
    }
  }

  @override
  Future<void> verifyAndIssueCertificate() async {
    if (certificate == null) return;

    isLoading = true;
    update();

    final response = await certificatesData.verifyCertificateImage(
      certificate!.id,
    );

    if (response.isSuccess) {
      final updatedCertificate = CertificateModel.fromJson(response.data);
      certificate = updatedCertificate;

      final hadImage =
          certificate!.imageUrl != null && certificate!.imageUrl!.isNotEmpty;

      final hasImage =
          updatedCertificate.imageUrl != null &&
          updatedCertificate.imageUrl!.isNotEmpty;

      if (!hadImage && hasImage) {
        customSnackBar(
          text: 'تم إنشاء صورة الشهادة بنجاح',
          snackType: SnackBarType.correct,
        );
      } else if (hasImage) {
        customSnackBar(
          text: 'صورة الشهادة جاهزة',
          snackType: SnackBarType.info,
        );
      }

      // showVerificationUrl();
      update();
    } else {
      customSnackBar(
        text: response.message ?? 'فشل في التحقق من صورة الشهادة',
        snackType: SnackBarType.error,
      );
    }

    isLoading = false;
    update();
  }

  @override
  void showVerificationUrl() {
    if (certificate == null) return;

    Get.dialog(
      Builder(
        builder: (context) {
          final colors = context.appColors;
          final scheme = Theme.of(context).colorScheme;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(width(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: scheme.primary,
                        size: emp(24),
                      ),
                      SizedBox(width: width(12)),
                      Expanded(
                        child: Text(
                          'رابط التحقق من الشهادة',
                          style: TextStyle(
                            fontSize: emp(20),
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: height(20)),
                  Container(
                    padding: EdgeInsets.all(width(12)),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.divider, width: 1),
                    ),
                    child: SelectableText(
                      certificate!.verificationUrl,
                      style: TextStyle(
                        fontSize: emp(14),
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: height(20)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: certificate!.verificationUrl),
                            );
                            Get.back();
                            customSnackBar(
                              text: 'تم نسخ الرابط',
                              snackType: SnackBarType.correct,
                            );
                          },
                          icon: Icon(Icons.copy, size: emp(18)),
                          label: Text('نسخ الرابط'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: height(12)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width(12)),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Share.share(
                              certificate!.verificationUrl,
                              subject: 'رابط التحقق من الشهادة',
                            );
                          },
                          icon: Icon(Icons.share, size: emp(18)),
                          label: Text('مشاركة'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: height(12)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Uint8List?> _loadCertificateBytes(CertificateModel certificate) async {
    try {
      Uint8List? imageBytes;

      if (certificate.imageUrl != null && certificate.imageUrl!.isNotEmpty) {
        imageBytes = await _downloadImageFromUrl(certificate.imageUrl!);
      }

      if (imageBytes == null) {
        try {
          final res = await certificatesData.downloadCertificate(certificate.id);
          if (res.statusCode != null &&
              res.statusCode! >= 200 &&
              res.statusCode! < 300 &&
              res.data != null) {
            final data = res.data;
            if (data is Uint8List) {
              imageBytes = data;
            } else if (data is List<int>) {
              imageBytes = Uint8List.fromList(data);
            }
          }
        } catch (_) {}
      }

      return imageBytes;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _downloadImageFromUrl(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
