import 'package:diplomasi_app/controllers/user/billing_history_controller.dart';
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
          return MyScaffold(
            appBar: AppBar(
              title: const Text('الفواتير والمدفوعات'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'الفواتير'),
                  Tab(text: 'الدفعات'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _InvoicesTab(controller: controller),
                _PaymentsTab(controller: controller),
              ],
            ),
          );
        },
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
      child: controller.invoicesErrorMessage != null
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(child: Text(controller.invoicesErrorMessage!)),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton(
                    onPressed: () => controller.loadInvoices(reload: true),
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
                final currency = invoice['currency']?.toString() ?? 'SAR';
                final issuedAt = invoice['issued_at']?.toString() ?? '-';

                return Card(
                  child: ListTile(
                    title: Text(invoiceNumber),
                    subtitle: Text(
                      'الحالة: $status\nالمبلغ: ${(amountMinor / 100).toStringAsFixed(2)} $currency\nتاريخ الإصدار: $issuedAt',
                    ),
                    isThreeLine: true,
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
                              : () => controller.downloadInvoicePdf(invoiceId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showInvoiceDetails(BuildContext context, Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number']?.toString() ?? '-';
    final status = invoice['status']?.toString() ?? '-';
    final amountMinor = (invoice['amount_minor'] as num?)?.toDouble() ?? 0;
    final currency = invoice['currency']?.toString() ?? 'SAR';
    final issuedAt = invoice['issued_at']?.toString() ?? '-';
    final dueAt = invoice['due_at']?.toString() ?? '-';
    final paidAt = invoice['paid_at']?.toString() ?? '-';

    Get.dialog(
      AlertDialog(
        title: Text('فاتورة $invoiceNumber'),
        content: Text(
          'الحالة: $status\n'
          'المبلغ: ${(amountMinor / 100).toStringAsFixed(2)} $currency\n'
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
      child: controller.paymentsErrorMessage != null
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 120),
                Center(child: Text(controller.paymentsErrorMessage!)),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton(
                    onPressed: () => controller.loadPayments(reload: true),
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
                final finalizedAt = payment['finalized_at']?.toString() ?? '-';

                return Card(
                  child: ListTile(
                    title: Text('Ref: $merchantReference'),
                    subtitle: Text(
                      'الحالة الداخلية: $status\nالحالة البنكية: $gatewayStatus\nالمبلغ: ${(amountMinor / 100).toStringAsFixed(2)} $currency\nأُغلقت: $finalizedAt',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
