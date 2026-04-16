import 'package:diplomasi_app/controllers/user/plans_controller.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/view/screens/user/add_payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlansControllerImp>();

    return GetBuilder<PlansControllerImp>(
      builder: (_) {
        return MyScaffold(
          appBar: AppBar(title: const Text('وسائل الدفع')),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = controller.paymentMethods[index];
                    final id = method['id'] as int?;
                    final isDefault = method['is_default'] == true;
                    final status = (method['status'] ?? '').toString();
                    final brand = (method['brand'] ?? 'Card').toString();
                    final last4 = (method['last4'] ?? '----').toString();
                    final refund = method['verification_refund'];
                    final refundText =
                        refund is Map && refund['requested'] == true
                        ? ((refund['success'] == true)
                              ? 'تحقق وسيلة الدفع: تم الاسترجاع'
                              : 'تحقق وسيلة الدفع: بانتظار/فشل الاسترجاع')
                        : null;

                    return Card(
                      child: ListTile(
                        title: Text('$brand **** $last4'),
                        subtitle: Text(
                          '${isDefault ? 'افتراضية' : 'غير افتراضية'} - ${status == 'active' ? 'فعّالة' : 'غير فعّالة'}${refundText != null ? '\n$refundText' : ''}',
                        ),
                        isThreeLine: refundText != null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDefault && id != null)
                              IconButton(
                                icon: const Icon(Icons.star_outline),
                                tooltip: 'تعيين افتراضية',
                                onPressed: () async {
                                  await controller.setDefaultPaymentMethod(id);
                                },
                              ),
                            if (id != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'حذف',
                                onPressed: () async {
                                  final confirm = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text(
                                        'هل تريد حذف وسيلة الدفع؟',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: false),
                                          child: const Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await controller.deletePaymentMethod(id);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Get.to<bool>(() => const AddPaymentMethodScreen());
                      await controller.loadBillingState();
                    },
                    child: const Text('إضافة وسيلة دفع جديدة'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
