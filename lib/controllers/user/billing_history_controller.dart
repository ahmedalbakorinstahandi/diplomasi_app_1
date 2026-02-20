import 'dart:io';

import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';
import 'package:diplomasi_app/view/screens/user/invoice_pdf_preview_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract class BillingHistoryController extends GetxController {
  bool isInvoicesLoading = false;
  bool isPaymentsLoading = false;
  bool isInvoicesLoadingMore = false;
  bool isPaymentsLoadingMore = false;
  bool isDownloadingInvoice = false;
  String? invoicesErrorMessage;
  String? paymentsErrorMessage;

  List invoices = [];
  List payments = [];

  int invoicesPage = 1;
  int paymentsPage = 1;
  final int perPage = 20;

  Meta? invoicesMeta;
  Meta? paymentsMeta;

  BillingData billingData = BillingData();
  ScrollController invoicesScrollController = ScrollController();
  ScrollController paymentsScrollController = ScrollController();

  // Invoices filters
  String invoicesSearchQuery = '';
  String? invoicesStatusFilter;
  DateTime? invoicesDateFrom;
  DateTime? invoicesDateTo;
  double? invoicesMinAmount;
  double? invoicesMaxAmount;
  String invoicesSortField = 'issued_at';
  String invoicesSortOrder = 'desc';

  // Payments filters
  String paymentsSearchQuery = '';
  String? paymentsStatusFilter;
  DateTime? paymentsDateFrom;
  DateTime? paymentsDateTo;
  double? paymentsMinAmount;
  double? paymentsMaxAmount;
  String paymentsSortField = 'finalized_at';
  String paymentsSortOrder = 'desc';

  Future<void> loadInvoices({bool reload = false});
  Future<void> loadPayments({bool reload = false});
  Future<void> refreshAll();
  Future<void> downloadInvoicePdf(int invoiceId);
  Future<void> shareInvoicePdfLink(int invoiceId);
  Future<void> previewInvoicePdf({
    required int invoiceId,
    String? invoiceNumber,
  });
  Future<void> applyInvoicesFilters({
    required String search,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minAmount,
    double? maxAmount,
    required String sortField,
    required String sortOrder,
  });
  Future<void> applyPaymentsFilters({
    required String search,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minAmount,
    double? maxAmount,
    required String sortField,
    required String sortOrder,
  });
  Future<void> resetInvoicesFilters();
  Future<void> resetPaymentsFilters();
}

class BillingHistoryControllerImp extends BillingHistoryController {
  Map<String, dynamic>? _lastFetchedInvoiceData;

  int _toMinorUnits(num amountMajor) => (amountMajor * 100).round();

  Map<String, dynamic> _buildInvoicesFiltersParams() {
    final params = <String, dynamic>{};
    if (invoicesSearchQuery.trim().isNotEmpty) {
      params['search'] = invoicesSearchQuery.trim();
    }
    if (invoicesStatusFilter != null && invoicesStatusFilter!.isNotEmpty) {
      params['status'] = invoicesStatusFilter;
    }
    if (invoicesDateFrom != null) {
      params['issued_at_from'] = invoicesDateFrom!.toIso8601String().split('T').first;
    }
    if (invoicesDateTo != null) {
      params['issued_at_to'] = invoicesDateTo!.toIso8601String().split('T').first;
    }
    if (invoicesMinAmount != null) {
      params['amount_minor_min'] = _toMinorUnits(invoicesMinAmount!);
    }
    if (invoicesMaxAmount != null) {
      params['amount_minor_max'] = _toMinorUnits(invoicesMaxAmount!);
    }
    params['sort_field'] = invoicesSortField;
    params['sort_order'] = invoicesSortOrder;
    return params;
  }

  Map<String, dynamic> _buildPaymentsFiltersParams() {
    final params = <String, dynamic>{};
    if (paymentsSearchQuery.trim().isNotEmpty) {
      params['search'] = paymentsSearchQuery.trim();
    }
    if (paymentsStatusFilter != null && paymentsStatusFilter!.isNotEmpty) {
      params['status'] = paymentsStatusFilter;
    }
    if (paymentsDateFrom != null) {
      params['finalized_at_from'] = paymentsDateFrom!.toIso8601String().split('T').first;
    }
    if (paymentsDateTo != null) {
      params['finalized_at_to'] = paymentsDateTo!.toIso8601String().split('T').first;
    }
    if (paymentsMinAmount != null) {
      params['amount_minor_min'] = _toMinorUnits(paymentsMinAmount!);
    }
    if (paymentsMaxAmount != null) {
      params['amount_minor_max'] = _toMinorUnits(paymentsMaxAmount!);
    }
    params['sort_field'] = paymentsSortField;
    params['sort_order'] = paymentsSortOrder;
    return params;
  }

  Future<String?> _fetchInvoicePdfUrl(int invoiceId) async {
    final response = await billingData.getInvoiceById(
      id: invoiceId,
      includePdf: false,
    );

    if (!response.isSuccess || response.data is! Map<String, dynamic>) {
      customSnackBar(
        text: response.message ?? 'تعذر جلب رابط الفاتورة.',
        snackType: SnackBarType.error,
      );
      return null;
    }

    final data = response.data as Map<String, dynamic>;
    _lastFetchedInvoiceData = data;
    final pdfUrl = data['pdf_url']?.toString();
    if (pdfUrl == null || pdfUrl.isEmpty) {
      customSnackBar(
        text: 'لا يتوفر رابط PDF لهذه الفاتورة حالياً.',
        snackType: SnackBarType.error,
      );
      return null;
    }

    return pdfUrl;
  }

  Future<File> _downloadPdfToFile({
    required String pdfUrl,
    required String invoiceNumber,
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
      final path = '${dir.path}/$invoiceNumber.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } finally {
      client.close(force: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    refreshAll();

    invoicesScrollController.addListener(() {
      if (invoicesScrollController.position.pixels ==
          invoicesScrollController.position.maxScrollExtent) {
        loadInvoices();
      }
    });

    paymentsScrollController.addListener(() {
      if (paymentsScrollController.position.pixels ==
          paymentsScrollController.position.maxScrollExtent) {
        loadPayments();
      }
    });
  }

  @override
  Future<void> refreshAll() async {
    await Future.wait([loadInvoices(reload: true), loadPayments(reload: true)]);
  }

  @override
  Future<void> loadInvoices({bool reload = false}) async {
    if (isInvoicesLoading) return;
    if (!reload &&
        invoicesMeta != null &&
        invoicesMeta!.currentPage >= invoicesMeta!.lastPage) {
      return;
    }

    if (reload) {
      invoicesPage = 1;
      invoicesErrorMessage = null;
      invoicesMeta = null;
    }

    isInvoicesLoading = true;
    isInvoicesLoadingMore = !reload;
    update();

    final response = await billingData.getInvoices(
      page: invoicesPage,
      perPage: perPage,
      filters: _buildInvoicesFiltersParams(),
    );

    if (response.isSuccess && response.data is List && response.meta != null) {
      invoicesMeta = response.meta;
      invoicesPage = Meta.handlePagination(
        list: invoices,
        newData: response.data as List,
        meta: response.meta!,
        page: invoicesPage,
        reload: reload,
      );
      invoicesErrorMessage = null;
    } else if (reload) {
      invoices.clear();
      invoicesErrorMessage = response.statusCode == 404
          ? 'صفحة الفواتير غير متاحة حالياً.'
          : (response.message ?? 'تعذر تحميل الفواتير.');
    }

    isInvoicesLoading = false;
    isInvoicesLoadingMore = false;
    update();
  }

  @override
  Future<void> loadPayments({bool reload = false}) async {
    if (isPaymentsLoading) return;
    if (!reload &&
        paymentsMeta != null &&
        paymentsMeta!.currentPage >= paymentsMeta!.lastPage) {
      return;
    }

    if (reload) {
      paymentsPage = 1;
      paymentsErrorMessage = null;
      paymentsMeta = null;
    }

    isPaymentsLoading = true;
    isPaymentsLoadingMore = !reload;
    update();

    final response = await billingData.getPayments(
      page: paymentsPage,
      perPage: perPage,
      filters: _buildPaymentsFiltersParams(),
    );

    if (response.isSuccess && response.data is List && response.meta != null) {
      paymentsMeta = response.meta;
      paymentsPage = Meta.handlePagination(
        list: payments,
        newData: response.data as List,
        meta: response.meta!,
        page: paymentsPage,
        reload: reload,
      );
      paymentsErrorMessage = null;
    } else if (reload) {
      payments.clear();
      paymentsErrorMessage = response.statusCode == 404
          ? 'صفحة الدفعات غير متاحة حالياً.'
          : (response.message ?? 'تعذر تحميل الدفعات.');
    }

    isPaymentsLoading = false;
    isPaymentsLoadingMore = false;
    update();
  }

  @override
  Future<void> downloadInvoicePdf(int invoiceId) async {
    if (isDownloadingInvoice) return;
    isDownloadingInvoice = true;
    update();

    try {
      final pdfUrl = await _fetchInvoicePdfUrl(invoiceId);
      if (pdfUrl == null) {
        return;
      }

      final data = _lastFetchedInvoiceData ?? <String, dynamic>{};
      final invoiceNumber = data['invoice_number']?.toString() ?? 'invoice';

      await _downloadPdfToFile(
        pdfUrl: pdfUrl,
        invoiceNumber: invoiceNumber,
        persistent: true,
      );

      customSnackBar(
        text: 'تم تنزيل الفاتورة',
        snackType: SnackBarType.correct,
      );
    } catch (_) {
      customSnackBar(
        text: 'تعذر تنزيل الفاتورة.',
        snackType: SnackBarType.error,
      );
    } finally {
      isDownloadingInvoice = false;
      update();
    }
  }

  @override
  Future<void> previewInvoicePdf({
    required int invoiceId,
    String? invoiceNumber,
  }) async {
    final pdfUrl = await _fetchInvoicePdfUrl(invoiceId);
    if (pdfUrl == null) {
      return;
    }

    final data = _lastFetchedInvoiceData ?? <String, dynamic>{};

    final resolvedInvoiceNumber =
        invoiceNumber ?? data['invoice_number']?.toString() ?? 'invoice';
    await Get.to(
      () => InvoicePdfPreviewScreen(
        invoiceNumber: resolvedInvoiceNumber,
        pdfUrl: pdfUrl,
      ),
    );
  }

  @override
  Future<void> shareInvoicePdfLink(int invoiceId) async {
    try {
      final pdfUrl = await _fetchInvoicePdfUrl(invoiceId);
      if (pdfUrl == null) {
        return;
      }

      final data = _lastFetchedInvoiceData ?? <String, dynamic>{};
      final invoiceNumber = data['invoice_number']?.toString() ?? 'invoice';
      final file = await _downloadPdfToFile(
        pdfUrl: pdfUrl,
        invoiceNumber: invoiceNumber,
        persistent: false,
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'فاتورة $invoiceNumber',
      );
    } catch (_) {
      customSnackBar(
        text: 'تعذر مشاركة الفاتورة كملف.',
        snackType: SnackBarType.error,
      );
    }
  }

  @override
  Future<void> applyInvoicesFilters({
    required String search,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minAmount,
    double? maxAmount,
    required String sortField,
    required String sortOrder,
  }) async {
    invoicesSearchQuery = search;
    invoicesStatusFilter = status;
    invoicesDateFrom = dateFrom;
    invoicesDateTo = dateTo;
    invoicesMinAmount = minAmount;
    invoicesMaxAmount = maxAmount;
    invoicesSortField = sortField;
    invoicesSortOrder = sortOrder;
    await loadInvoices(reload: true);
  }

  @override
  Future<void> applyPaymentsFilters({
    required String search,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? minAmount,
    double? maxAmount,
    required String sortField,
    required String sortOrder,
  }) async {
    paymentsSearchQuery = search;
    paymentsStatusFilter = status;
    paymentsDateFrom = dateFrom;
    paymentsDateTo = dateTo;
    paymentsMinAmount = minAmount;
    paymentsMaxAmount = maxAmount;
    paymentsSortField = sortField;
    paymentsSortOrder = sortOrder;
    await loadPayments(reload: true);
  }

  @override
  Future<void> resetInvoicesFilters() async {
    invoicesSearchQuery = '';
    invoicesStatusFilter = null;
    invoicesDateFrom = null;
    invoicesDateTo = null;
    invoicesMinAmount = null;
    invoicesMaxAmount = null;
    invoicesSortField = 'issued_at';
    invoicesSortOrder = 'desc';
    await loadInvoices(reload: true);
  }

  @override
  Future<void> resetPaymentsFilters() async {
    paymentsSearchQuery = '';
    paymentsStatusFilter = null;
    paymentsDateFrom = null;
    paymentsDateTo = null;
    paymentsMinAmount = null;
    paymentsMaxAmount = null;
    paymentsSortField = 'finalized_at';
    paymentsSortOrder = 'desc';
    await loadPayments(reload: true);
  }
}
