import 'dart:io';
import 'dart:typed_data';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:diplomasi_app/data/resource/remote/user/certificates_data.dart';
import 'package:diplomasi_app/routes/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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

      // Download and save the certificate image
      final file = await _downloadCertificateImage(certificateModel);

      if (file != null) {
        customSnackBar(
          text: 'تم تحميل الشهادة بنجاح',
          snackType: SnackBarType.info,
        );

        // Share the downloaded file
        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'شهادة: ${certificateModel.title}');
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

  /// Downloads the certificate image and saves it to a temporary file
  Future<File?> _downloadCertificateImage(CertificateModel certificate) async {
    try {
      Uint8List? imageBytes;

      // Try to download from imageUrl first
      if (certificate.imageUrl != null && certificate.imageUrl!.isNotEmpty) {
        imageBytes = await _downloadImageFromUrl(certificate.imageUrl!);
      }

      // If imageUrl download failed, try API endpoint
      if (imageBytes == null) {
        final apiService = Get.find<ApiService>();
        final response = await apiService.get(
          EndPoints.certificateDownload,
          pathVariables: {'id': certificate.id.toString()},
        );

        if (response.isSuccess && response.data is Uint8List) {
          imageBytes = response.data as Uint8List;
        }
      }

      // Save the image to temporary directory
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${certificate.certificateCode}.png');
        await file.writeAsBytes(imageBytes);
        return file;
      }

      return null;
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
      // Download and share the certificate image
      final file = await _downloadCertificateImage(certificate);

      if (file != null) {
        // Share the image file
        await Share.shareXFiles([
          XFile(file.path),
        ], subject: 'شهادة: ${certificate.title}');

        // Delete the temporary file after sharing
        try {
          await file.delete();
        } catch (_) {
          // Ignore deletion errors
        }
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
