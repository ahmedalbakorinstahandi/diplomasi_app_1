import 'dart:io';

import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/functions/user_download_file.dart';
import 'package:diplomasi_app/data/model/user/article_model.dart';
import 'package:diplomasi_app/view/screens/user/pdf_preview_screen.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

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
      final api = Get.find<ApiService>();
      final bytes = await fetchUrlBytesWithDioFallback(
        url,
        (u) => api.getBytesAbsoluteUrl(u),
      );
      final path = await saveBytesToUserLocation(
        name: fileName,
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (path == null) {
        return;
      }
      if (looksLikeFileSaverFailure(path)) {
        customSnackBar(
          text: 'تعذر حفظ الملف.',
          snackType: SnackBarType.error,
        );
        return;
      }
      customSnackBar(text: 'تم حفظ الملف', snackType: SnackBarType.correct);
      if (!kIsWeb) {
        try {
          await shareFileByPath(path, subject: article.title);
        } catch (_) {
          customSnackBar(
            text: 'حُفظ الملف. يمكنك مشاركته من تطبيق الملفات.',
            snackType: SnackBarType.info,
          );
        }
      }
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
      final api = Get.find<ApiService>();
      final bytes = await fetchUrlBytesWithDioFallback(
        url,
        (u) => api.getBytesAbsoluteUrl(u),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/article_share_${article.id}_$fileName.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await shareFileByPath(file.path, subject: article.title);
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
