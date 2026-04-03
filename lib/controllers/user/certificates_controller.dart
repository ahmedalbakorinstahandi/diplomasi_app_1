import 'dart:io';

import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/functions/user_download_file.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/certificates_data.dart';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class CertificatesController extends GetxController {
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isDownloading = false;
  List certificates = [];
  CertificatePaginationMeta? paginationMeta;
  int page = 1;
  final int perPage = 20;

  List certificatesDownloading = [];

  CertificatesData certificatesData = CertificatesData();

  ScrollController scrollController = ScrollController();

  Future<void> getCertificates({bool reload = false});
  void selectCertificate(CertificateModel certificate);
  Future<void> downloadCertificate(int certificateIndex);
  Future<void> shareCertificate(CertificateModel certificate);
}

class CertificatesControllerImp extends CertificatesController {
  @override
  void onInit() {
    getCertificates(reload: true);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getCertificates();
      }
    });

    update();

    super.onInit();
  }

  @override
  Future<void> getCertificates({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
    }

    isLoading = true;
    update();

    ApiResponse response = await certificatesData.getCertificates(
      page: page,
      perPage: perPage,
      sortField: 'issued_at',
      sortOrder: 'desc',
    );

    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: certificates,
        newData: response.data,
        meta: response.meta!,
        page: page,
        reload: reload,
      );
    }

    isLoading = false;
    update();
  }

  @override
  void selectCertificate(CertificateModel certificate) {
    Get.toNamed(
      AppRoutes.certificateDetail.replaceAll(':id', certificate.id.toString()),
    );
  }

  @override
  Future<void> downloadCertificate(int certificateIndex) async {
    if (isDownloading) return;

    certificatesDownloading.add(certificateIndex);
    isDownloading = true;
    update();

    try {
      final certificateModel = CertificateModel.fromJson(
        certificates[certificateIndex],
      );

      final bytes = await _loadCertificateBytes(certificateModel);

      if (bytes != null) {
        final name = sanitizeDownloadFileName(
          certificateModel.certificateCode,
          fallback: 'certificate_${certificateModel.id}',
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
              subject: 'شهادة: ${certificateModel.title}',
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
      certificatesDownloading.remove(certificateIndex);
      isDownloading = false;
      update();
    }
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

  /// Downloads an image from a URL and returns its bytes
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

  @override
  Future<void> shareCertificate(CertificateModel certificate) async {
    try {
      final bytes = await _loadCertificateBytes(certificate);

      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/cert_share_${certificate.id}_${certificate.certificateCode}.png',
        );
        await file.writeAsBytes(bytes, flush: true);
        await shareFileByPath(
          file.path,
          subject: 'شهادة: ${certificate.title}',
        );
        try {
          await file.delete();
        } catch (_) {}
      } else {
        // Fallback: share verification URL if image download failed
        await Share.share(
          'شهادة من منصة دبلوماسي\n${certificate.title}\n${certificate.verificationUrl}',
          subject: 'شهادة: ${certificate.title}',
        );
      }
    } catch (e) {
      customSnackBar(
        text: 'حدث خطأ أثناء مشاركة الشهادة',
        snackType: SnackBarType.error,
      );
    }
  }
}
