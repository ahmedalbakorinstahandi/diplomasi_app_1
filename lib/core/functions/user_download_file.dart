import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

typedef DioBytesFetcher = Future<Uint8List?> Function(String url);

Future<Uint8List> fetchUrlBytesWithDioFallback(
  String url,
  DioBytesFetcher dioGetBytes,
) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    throw Exception('invalid_url');
  }
  try {
    return await fetchHttpBytes(uri);
  } catch (_) {
    final b = await dioGetBytes(url);
    if (b == null || b.isEmpty) {
      throw Exception('fetch_failed');
    }
    return b;
  }
}

Future<Uint8List> fetchHttpBytes(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final responseStream = await request.close();
    if (responseStream.statusCode < 200 || responseStream.statusCode > 299) {
      throw Exception('http_${responseStream.statusCode}');
    }
    final bytes = await consolidateHttpClientResponseBytes(responseStream);
    if (bytes.isEmpty) {
      throw Exception('empty_bytes');
    }
    return bytes;
  } finally {
    client.close(force: true);
  }
}

String sanitizeDownloadFileName(String raw, {String fallback = 'file'}) {
  final s = raw.replaceAll(RegExp(r'[^\w\u0600-\u06FF\-]+'), '_');
  final t = s.replaceAll(RegExp(r'_+'), '_').trim();
  return t.isEmpty ? fallback : t;
}

bool looksLikeFileSaverFailure(String? path) {
  if (path == null || path.isEmpty) return true;
  return path.contains('Error While Saving') ||
      path.contains('Something went wrong');
}

/// يحفظ الملف في مكان يختاره المستخدم (أندرويد/iOS/macOS) أو تنزيل المتصفح (ويب).
Future<String?> saveBytesToUserLocation({
  required String name,
  required Uint8List bytes,
  required String fileExtension,
  required MimeType mimeType,
}) async {
  try {
    if (kIsWeb) {
      return await FileSaver.instance.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: fileExtension,
        includeExtension: true,
        mimeType: mimeType,
      );
    }
    return await FileSaver.instance.saveAs(
      name: name,
      bytes: bytes,
      fileExtension: fileExtension,
      includeExtension: true,
      mimeType: mimeType,
    );
  } catch (_) {
    return null;
  }
}

Future<void> shareFileByPath(String path, {String? subject}) async {
  await Share.shareXFiles([XFile(path)], subject: subject);
}
