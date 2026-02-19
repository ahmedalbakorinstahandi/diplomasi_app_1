import 'dart:convert';
import 'dart:io';

import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/data/resource/remote/user/billing_data.dart';
import 'package:diplomasi_app/view/screens/user/invoice_pdf_preview_screen.dart';
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

  Future<void> loadInvoices({bool reload = false});
  Future<void> loadPayments({bool reload = false});
  Future<void> refreshAll();
  Future<void> downloadInvoicePdf(int invoiceId);
  Future<void> previewInvoicePdf({
    required int invoiceId,
    String? invoiceNumber,
  });
}

class BillingHistoryControllerImp extends BillingHistoryController {
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
      final response = await billingData.getInvoiceById(
        id: invoiceId,
        includePdf: true,
      );

      if (!response.isSuccess || response.data is! Map<String, dynamic>) {
        customSnackBar(
          text: response.message ?? 'تعذر تنزيل الفاتورة.',
          snackType: SnackBarType.error,
        );
        return;
      }

      final data = response.data as Map<String, dynamic>;
      final pdfBase64 = data['pdf_base64']?.toString();
      if (pdfBase64 == null || pdfBase64.isEmpty) {
        customSnackBar(
          text: 'لا يتوفر ملف PDF لهذه الفاتورة حالياً.',
          snackType: SnackBarType.error,
        );
        return;
      }

      final invoiceNumber = data['invoice_number']?.toString() ?? 'invoice';
      final bytes = base64Decode(pdfBase64);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$invoiceNumber.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      customSnackBar(
        text: 'تم تجهيز الفاتورة. يمكنك حفظها أو مشاركتها الآن.',
        snackType: SnackBarType.correct,
      );

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'فاتورة $invoiceNumber');
    } catch (_) {
      customSnackBar(
        text: 'حدث خطأ أثناء تجهيز ملف الفاتورة.',
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
    final response = await billingData.getInvoiceById(
      id: invoiceId,
      includePdf: true,
    );

    if (!response.isSuccess || response.data is! Map<String, dynamic>) {
      customSnackBar(
        text: response.message ?? 'تعذر عرض الفاتورة.',
        snackType: SnackBarType.error,
      );
      return;
    }

    final data = response.data as Map<String, dynamic>;
    final pdfBase64 = data['pdf_base64']?.toString();
    if (pdfBase64 == null || pdfBase64.isEmpty) {
      customSnackBar(
        text: 'لا يتوفر ملف PDF لهذه الفاتورة حالياً.',
        snackType: SnackBarType.error,
      );
      return;
    }

    final resolvedInvoiceNumber =
        invoiceNumber ?? data['invoice_number']?.toString() ?? 'invoice';
    await Get.to(
      () => InvoicePdfPreviewScreen(
        invoiceNumber: resolvedInvoiceNumber,
        pdfBase64: pdfBase64,
      ),
    );
  }
}
