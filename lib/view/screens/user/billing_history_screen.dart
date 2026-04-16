import 'package:diplomasi_app/controllers/user/billing_history_controller.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/format_date.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingHistoryScreen extends StatelessWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BillingHistoryControllerImp());

    return DefaultTabController(
      length: 2,
      child: GetBuilder<BillingHistoryControllerImp>(
        init: BillingHistoryControllerImp(),
        builder: (controller) {
          final scheme = Theme.of(context).colorScheme;
          return MyScaffold(
            appBar: AppBar(title: const Text('الفواتير والمدفوعات')),
            body: Column(
              children: [
                // _Billing
                //Header(controller: controller),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width(16)),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'الفواتير'),
                      Tab(text: 'الدفعات'),
                    ],
                  ),
                ),
                SizedBox(height: height(10)),
                Expanded(
                  child: TabBarView(
                    children: [
                      _InvoicesTab(controller: controller),
                      _PaymentsTab(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ignore: unused_element
class _BillingHeader extends StatelessWidget {
  final BillingHistoryControllerImp controller;

  const _BillingHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.fromLTRB(width(16), height(10), width(16), height(12)),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width(14),
        vertical: height(12),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            scheme.primary.withOpacity(0.14),
            scheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل الفوترة',
            style: TextStyle(
              fontSize: emp(16),
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: height(6)),
          Text(
            'ابحث وفلتر الفواتير والدفعات بسهولة بنفس نمط التطبيق.',
            style: TextStyle(
              fontSize: emp(12),
              color: scheme.onSurface.withOpacity(0.7),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _InvoicesTab extends StatelessWidget {
  final BillingHistoryControllerImp controller;

  const _InvoicesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isFirstLoad =
        controller.isInvoicesLoading && controller.invoices.isEmpty;

    if (isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadInvoices(reload: true),
      child: Column(
        children: [
          _FiltersBar(
            searchHint: 'ابحث برقم الفاتورة أو الحالة...',
            searchValue: controller.invoicesSearchQuery,
            onSearchSubmitted: (value) => controller.applyInvoicesFilters(
              search: value,
              status: controller.invoicesStatusFilter,
              dateFrom: controller.invoicesDateFrom,
              dateTo: controller.invoicesDateTo,
              minAmount: controller.invoicesMinAmount,
              maxAmount: controller.invoicesMaxAmount,
              sortField: controller.invoicesSortField,
              sortOrder: controller.invoicesSortOrder,
            ),
            onOpenFilters: () => _showInvoicesFiltersSheet(context, controller),
          ),
          Expanded(
            child: controller.invoicesErrorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(controller.invoicesErrorMessage!)),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton(
                          onPressed: controller.resetInvoicesFilters,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ),
                    ],
                  )
                : controller.invoices.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(child: Text('لا توجد فواتير حتى الآن')),
                    ],
                  )
                : ListView.builder(
                    controller: controller.invoicesScrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: width(14),
                      vertical: height(12),
                    ),
                    itemCount:
                        controller.invoices.length +
                        (controller.isInvoicesLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.invoices.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = controller.invoices[index];
                      final invoice = item is Map<String, dynamic>
                          ? item
                          : <String, dynamic>{};
                      final invoiceId = invoice['id'] as int?;
                      final invoiceNumber =
                          invoice['invoice_number']?.toString() ?? '-';
                      final status = invoice['status']?.toString() ?? '-';
                      final amountMinor =
                          (invoice['amount_minor'] as num?)?.toDouble() ?? 0;
                      final currency = invoice['currency']?.toString() ?? 'USD';
                      final chargedAmountMinor =
                          (invoice['charged_amount_minor'] as num?)?.toDouble() ??
                              0;
                      final chargedCurrency =
                          invoice['charged_currency']?.toString() ?? 'SAR';
                      final issuedAt = invoice['issued_at'] != null
                          ? formatDateTime(invoice['issued_at']?.toString())
                          : '-';

                      return _BillingCard(
                        title: invoiceNumber,
                        subtitle:
                            'الحالة: $status\nالسعر المرجعي: ${(amountMinor / 100).toStringAsFixed(2)} $currency\nالمبلغ المدفوع: ${(chargedAmountMinor / 100).toStringAsFixed(2)} $chargedCurrency\nتاريخ الإصدار: $issuedAt',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined),
                              tooltip: 'عرض',
                              onPressed: invoiceId == null
                                  ? () => _showInvoiceDetails(context, invoice)
                                  : () => controller.previewInvoicePdf(
                                      invoiceId: invoiceId,
                                      invoiceNumber: invoiceNumber,
                                    ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_outlined),
                              tooltip: 'تنزيل PDF',
                              onPressed: invoiceId == null
                                  ? null
                                  : () => controller.downloadInvoicePdf(
                                      invoiceId,
                                    ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              tooltip: 'مشاركة',
                              onPressed: invoiceId == null
                                  ? null
                                  : () => controller.shareInvoicePdfLink(
                                      invoiceId,
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInvoicesFiltersSheet(
    BuildContext context,
    BillingHistoryControllerImp controller,
  ) async {
    final minCtrl = TextEditingController(
      text: controller.invoicesMinAmount?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: controller.invoicesMaxAmount?.toString() ?? '',
    );
    String? status = controller.invoicesStatusFilter;
    DateTime? from = controller.invoicesDateFrom;
    DateTime? to = controller.invoicesDateTo;
    String sortField = controller.invoicesSortField;
    String sortOrder = controller.invoicesSortOrder;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                width(16),
                height(12),
                width(16),
                MediaQuery.of(ctx).viewInsets.bottom + height(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فلاتر الفواتير',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: emp(15),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: height(12)),
                    DropdownButtonFormField<String?>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'الحالة'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('الكل')),
                        DropdownMenuItem(
                          value: 'issued',
                          child: Text('issued'),
                        ),
                        DropdownMenuItem(value: 'paid', child: Text('paid')),
                        DropdownMenuItem(
                          value: 'failed',
                          child: Text('failed'),
                        ),
                      ],
                      onChanged: (v) => setStateSheet(() => status = v),
                    ),
                    SizedBox(height: height(10)),
                    _DateRangeRow(
                      from: from,
                      to: to,
                      onFromPick: (d) => setStateSheet(() => from = d),
                      onToPick: (d) => setStateSheet(() => to = d),
                    ),
                    SizedBox(height: height(10)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'أدنى مبلغ (USD)',
                            ),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'أعلى مبلغ (USD)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height(10)),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortField,
                            decoration: const InputDecoration(
                              labelText: 'ترتيب حسب',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'issued_at',
                                child: Text('تاريخ الإصدار'),
                              ),
                              DropdownMenuItem(
                                value: 'display_amount_minor',
                                child: Text('السعر المرجعي'),
                              ),
                              DropdownMenuItem(
                                value: 'created_at',
                                child: Text('تاريخ الإنشاء'),
                              ),
                            ],
                            onChanged: (v) => setStateSheet(
                              () => sortField = v ?? 'issued_at',
                            ),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortOrder,
                            decoration: const InputDecoration(
                              labelText: 'الاتجاه',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'desc',
                                child: Text('الأحدث'),
                              ),
                              DropdownMenuItem(
                                value: 'asc',
                                child: Text('الأقدم'),
                              ),
                            ],
                            onChanged: (v) =>
                                setStateSheet(() => sortOrder = v ?? 'desc'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height(14)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await controller.resetInvoicesFilters();
                            },
                            child: const Text('إعادة ضبط'),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await controller.applyInvoicesFilters(
                                search: controller.invoicesSearchQuery,
                                status: status,
                                dateFrom: from,
                                dateTo: to,
                                minAmount: double.tryParse(minCtrl.text.trim()),
                                maxAmount: double.tryParse(maxCtrl.text.trim()),
                                sortField: sortField,
                                sortOrder: sortOrder,
                              );
                            },
                            child: const Text('تطبيق'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number']?.toString() ?? '-';
    final status = invoice['status']?.toString() ?? '-';
    final amountMinor = (invoice['amount_minor'] as num?)?.toDouble() ?? 0;
    final currency = invoice['currency']?.toString() ?? 'USD';
    final chargedAmountMinor =
        (invoice['charged_amount_minor'] as num?)?.toDouble() ?? 0;
    final chargedCurrency =
        invoice['charged_currency']?.toString() ?? 'SAR';
    final issuedAt = invoice['issued_at'] != null
        ? formatDateTime(invoice['issued_at']?.toString())
        : '-';
    final dueAt = invoice['due_at'] != null
        ? formatDateTime(invoice['due_at']?.toString())
        : '-';
    final paidAt = invoice['paid_at'] != null
        ? formatDateTime(invoice['paid_at']?.toString())
        : '-';

    Get.dialog(
      AlertDialog(
        title: Text('فاتورة $invoiceNumber'),
        content: Text(
          'الحالة: $status\n'
          'السعر المرجعي: ${(amountMinor / 100).toStringAsFixed(2)} $currency\n'
          'المبلغ المدفوع: ${(chargedAmountMinor / 100).toStringAsFixed(2)} $chargedCurrency\n'
          'تاريخ الإصدار: $issuedAt\n'
          'تاريخ الاستحقاق: $dueAt\n'
          'تاريخ الدفع: $paidAt',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final BillingHistoryControllerImp controller;

  const _PaymentsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isFirstLoad =
        controller.isPaymentsLoading && controller.payments.isEmpty;

    if (isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadPayments(reload: true),
      child: Column(
        children: [
          _FiltersBar(
            searchHint: 'ابحث بالمرجع أو الحالة...',
            searchValue: controller.paymentsSearchQuery,
            onSearchSubmitted: (value) => controller.applyPaymentsFilters(
              search: value,
              status: controller.paymentsStatusFilter,
              dateFrom: controller.paymentsDateFrom,
              dateTo: controller.paymentsDateTo,
              minAmount: controller.paymentsMinAmount,
              maxAmount: controller.paymentsMaxAmount,
              sortField: controller.paymentsSortField,
              sortOrder: controller.paymentsSortOrder,
            ),
            onOpenFilters: () => _showPaymentsFiltersSheet(context, controller),
          ),
          Expanded(
            child: controller.paymentsErrorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(child: Text(controller.paymentsErrorMessage!)),
                      const SizedBox(height: 12),
                      Center(
                        child: OutlinedButton(
                          onPressed: controller.resetPaymentsFilters,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ),
                    ],
                  )
                : controller.payments.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 140),
                      Center(child: Text('لا توجد دفعات حتى الآن')),
                    ],
                  )
                : ListView.builder(
                    controller: controller.paymentsScrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: width(14),
                      vertical: height(12),
                    ),
                    itemCount:
                        controller.payments.length +
                        (controller.isPaymentsLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.payments.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = controller.payments[index];
                      final payment = item is Map<String, dynamic>
                          ? item
                          : <String, dynamic>{};
                      final merchantReference =
                          payment['merchant_reference_id']?.toString() ?? '-';
                      final gatewayStatus =
                          payment['gateway_status']?.toString() ?? '-';
                      final status = payment['status']?.toString() ?? '-';
                      final amountMinor =
                          (payment['amount_minor'] as num?)?.toDouble() ?? 0;
                      final currency = payment['currency']?.toString() ?? 'SAR';
                      final displayAmountMinor =
                          (payment['display_amount_minor'] as num?)?.toDouble() ?? 0;
                      final displayCurrency =
                          payment['display_currency']?.toString() ?? 'USD';
                      final finalizedAt = payment['finalized_at'] != null
                          ? formatDateTime(payment['finalized_at']?.toString())
                          : '-';

                      return _BillingCard(
                        title: 'Ref: $merchantReference',
                        subtitle:
                            'الحالة الداخلية: $status\nالحالة البنكية: $gatewayStatus\nالسعر المرجعي: ${(displayAmountMinor / 100).toStringAsFixed(2)} $displayCurrency\nالمبلغ المدفوع: ${(amountMinor / 100).toStringAsFixed(2)} $currency\nأُغلقت: $finalizedAt',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentsFiltersSheet(
    BuildContext context,
    BillingHistoryControllerImp controller,
  ) async {
    final minCtrl = TextEditingController(
      text: controller.paymentsMinAmount?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: controller.paymentsMaxAmount?.toString() ?? '',
    );
    String? status = controller.paymentsStatusFilter;
    DateTime? from = controller.paymentsDateFrom;
    DateTime? to = controller.paymentsDateTo;
    String sortField = controller.paymentsSortField;
    String sortOrder = controller.paymentsSortOrder;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                width(16),
                height(12),
                width(16),
                MediaQuery.of(ctx).viewInsets.bottom + height(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فلاتر الدفعات',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: emp(15),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: height(12)),
                    DropdownButtonFormField<String?>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'الحالة'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('الكل')),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('pending'),
                        ),
                        DropdownMenuItem(value: 'paid', child: Text('paid')),
                        DropdownMenuItem(
                          value: 'failed',
                          child: Text('failed'),
                        ),
                      ],
                      onChanged: (v) => setStateSheet(() => status = v),
                    ),
                    SizedBox(height: height(10)),
                    _DateRangeRow(
                      from: from,
                      to: to,
                      onFromPick: (d) => setStateSheet(() => from = d),
                      onToPick: (d) => setStateSheet(() => to = d),
                    ),
                    SizedBox(height: height(10)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'أدنى مبلغ (USD)',
                            ),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'أعلى مبلغ (USD)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height(10)),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortField,
                            decoration: const InputDecoration(
                              labelText: 'ترتيب حسب',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'finalized_at',
                                child: Text('تاريخ الإغلاق'),
                              ),
                              DropdownMenuItem(
                                value: 'amount_minor',
                                child: Text('المبلغ'),
                              ),
                              DropdownMenuItem(
                                value: 'created_at',
                                child: Text('تاريخ الإنشاء'),
                              ),
                            ],
                            onChanged: (v) => setStateSheet(
                              () => sortField = v ?? 'finalized_at',
                            ),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: sortOrder,
                            decoration: const InputDecoration(
                              labelText: 'الاتجاه',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'desc',
                                child: Text('الأحدث'),
                              ),
                              DropdownMenuItem(
                                value: 'asc',
                                child: Text('الأقدم'),
                              ),
                            ],
                            onChanged: (v) =>
                                setStateSheet(() => sortOrder = v ?? 'desc'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height(14)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await controller.resetPaymentsFilters();
                            },
                            child: const Text('إعادة ضبط'),
                          ),
                        ),
                        SizedBox(width: width(10)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await controller.applyPaymentsFilters(
                                search: controller.paymentsSearchQuery,
                                status: status,
                                dateFrom: from,
                                dateTo: to,
                                minAmount: double.tryParse(minCtrl.text.trim()),
                                maxAmount: double.tryParse(maxCtrl.text.trim()),
                                sortField: sortField,
                                sortOrder: sortOrder,
                              );
                            },
                            child: const Text('تطبيق'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final String searchHint;
  final String searchValue;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onOpenFilters;

  const _FiltersBar({
    required this.searchHint,
    required this.searchValue,
    required this.onSearchSubmitted,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final textCtrl = TextEditingController(text: searchValue);
    textCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: textCtrl.text.length),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width(14), vertical: height(8)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textCtrl,
              textDirection: TextDirection.rtl,
              onSubmitted: onSearchSubmitted,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: width(8)),
          OutlinedButton.icon(
            onPressed: onOpenFilters,
            icon: const Icon(Icons.tune),
            label: const Text('فلاتر'),
          ),
        ],
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?> onFromPick;
  final ValueChanged<DateTime?> onToPick;

  const _DateRangeRow({
    required this.from,
    required this.to,
    required this.onFromPick,
    required this.onToPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: from ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              onFromPick(picked);
            },
            child: Text(
              'من: ${from != null ? formatDateByDate(from!) : 'غير محدد'}',
            ),
          ),
        ),
        SizedBox(width: width(10)),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: to ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              onToPick(picked);
            },
            child: Text(
              'إلى: ${to != null ? formatDateByDate(to!) : 'غير محدد'}',
            ),
          ),
        ),
      ],
    );
  }
}

class _BillingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _BillingCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: height(10)),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(width(14)),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: emp(14),
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: emp(12.5),
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
