import 'dart:io';

import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/model/user/article_model.dart';
import 'package:diplomasi_app/view/screens/user/pdf_preview_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ArticleDetailsController extends GetxController {
  ArticleModel get article => Get.arguments as ArticleModel;

  bool isDownloadingPdf = false;
  bool isSharingPdf = false;

  String _sanitizeFileName(String title) {
    final sanitized = title.replaceAll(
      RegExp(r'[^\p{L}\p{N}\s-]', unicode: true),
      '',
    );
    return sanitized.trim().replaceAll(RegExp(r'\s+'), '_').isEmpty
        ? 'article_${article.id}'
        : sanitized.trim().replaceAll(RegExp(r'\s+'), '_');
  }

  Future<File> _downloadPdfToFile({
    required String pdfUrl,
    required String fileName,
    required bool persistent,
  }) async {
    final uri = Uri.tryParse(pdfUrl);
    if (uri == null) {
      throw Exception('invalid_pdf_url');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final responseStream = await request.close();
      if (responseStream.statusCode < 200 || responseStream.statusCode > 299) {
        throw Exception('pdf_download_http_${responseStream.statusCode}');
      }

      final bytes = await consolidateHttpClientResponseBytes(responseStream);
      if (bytes.isEmpty) {
        throw Exception('empty_pdf_bytes');
      }

      final dir = persistent
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();
      final path = '${dir.path}/$fileName.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      client.close(force: true);
    }
  }

  void previewArticlePdf() {
    final url = article.pdfUrl;
    if (url == null || url.isEmpty) return;
    final title = article.title;
    Get.to(() => PdfPreviewScreen(title: title, pdfUrl: url));
  }

  Future<void> downloadArticlePdf() async {
    final url = article.pdfUrl;
    if (url == null || url.isEmpty) return;
    if (isDownloadingPdf) return;

    isDownloadingPdf = true;
    update();

    try {
      final fileName = _sanitizeFileName(article.title);
      final file = await _downloadPdfToFile(
        pdfUrl: url,
        fileName: fileName,
        persistent: true,
      );
      customSnackBar(text: 'تم تنزيل الملف', snackType: SnackBarType.correct);
      await Share.shareXFiles([XFile(file.path)], subject: article.title);
    } catch (_) {
      customSnackBar(text: 'تعذر تنزيل الملف.', snackType: SnackBarType.error);
    } finally {
      isDownloadingPdf = false;
      update();
    }
  }

  Future<void> shareArticlePdf() async {
    final url = article.pdfUrl;
    if (url == null || url.isEmpty) return;
    if (isSharingPdf) return;

    isSharingPdf = true;
    update();

    try {
      final fileName = _sanitizeFileName(article.title);
      final file = await _downloadPdfToFile(
        pdfUrl: url,
        fileName: fileName,
        persistent: false,
      );
      await Share.shareXFiles([XFile(file.path)], subject: article.title);
    } catch (_) {
      customSnackBar(text: 'تعذر مشاركة الملف.', snackType: SnackBarType.error);
    } finally {
      isSharingPdf = false;
      update();
    }
  }

  void copyArticleLink() {
    final url = article.pdfUrl;
    if (url == null || url.isEmpty) return;
    Clipboard.setData(ClipboardData(text: url));
    customSnackBar(text: 'تم نسخ الرابط', snackType: SnackBarType.correct);
  }
}
