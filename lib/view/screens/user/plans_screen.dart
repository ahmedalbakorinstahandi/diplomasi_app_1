import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/snackbar.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/controllers/user/plans_controller.dart';
import 'package:diplomasi_app/data/model/user/plan_model.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/plans_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/plan_card.dart';
import 'package:diplomasi_app/view/widgets/user/plans_header.dart';
import 'package:diplomasi_app/view/screens/user/add_payment_method_screen.dart';
import 'package:diplomasi_app/view/screens/user/payment_methods_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PlansControllerImp());
    return GetBuilder<PlansControllerImp>(
      init: PlansControllerImp(),
      builder: (controller) {
        final scheme = Theme.of(context).colorScheme;
        return MyScaffold(
          backgroundColor: scheme.surface,
          body: Column(
            children: [
              // Header
              const PlansHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(20)),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Get.toNamed(AppRoutes.billingHistory);
                      },
                      icon: Icon(
                        Icons.receipt_long_outlined,
                        color: scheme.onSurface,
                      ),
                      label: Text(
                        'الفواتير',
                        style: TextStyle(
                          fontSize: emp(14),
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: width(8)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Get.to(() => const PaymentMethodsScreen());
                        await controller.loadBillingState();
                      },
                      icon: Icon(Icons.credit_card, color: scheme.onSurface),
                      label: Text(
                        'وسائل الدفع',
                        style: TextStyle(
                          fontSize: emp(14),
                          fontWeight: FontWeight.w500,

                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height(20)),
              if (controller.currentSubscription == null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width(20)),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'غير مشترك حالياً',
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.85),
                        fontSize: emp(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (controller.currentSubscription == null)
                SizedBox(height: height(8)),
              Expanded(
                child: HandlingListDataView(
                  isLoading: controller.isLoading,
                  dataIsEmpty: controller.plans.isEmpty,
                  loadingWidget: const PlansScreenShimmer(),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.getPlans();

                      await controller.loadBillingState();
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: height(8)),
                      child: Column(
                        children: [
                          // SizedBox(height: height(8)),
                          // Display plans - reorder to put premium in center
                          Builder(
                            builder: (context) {
                              final sortedPlans = <Map<String, dynamic>>[
                                ...controller.plans.where(
                                  (p) => !PlanModel.fromJson(p).isPremium,
                                ),
                                ...controller.plans.where(
                                  (p) => PlanModel.fromJson(p).isPremium,
                                ),
                              ];

                              return Column(
                                children: sortedPlans.map((planData) {
                                  final planModel = PlanModel.fromJson(
                                    planData,
                                  );
                                  final isFeatured = planModel.isPremium;
                                  final isCurrentPlan = controller
                                      .isCurrentPlan(planModel);
                                  final currentSubscriptionEnd = DateTime.tryParse(
                                    (controller.currentSubscription?['end_date'] ?? '')
                                        .toString(),
                                  );
                                  final purchaseBlocked =
                                      controller
                                          .hasBlockingCurrentSubscription &&
                                      !isCurrentPlan;

                                  return PlanCard(
                                    plan: planModel,
                                    isFeatured: isFeatured,
                                    actionLabel: isCurrentPlan
                                        ? 'هذه خطتك الحالية'
                                        : purchaseBlocked
                                        ? 'لديك خطة مفعلة'
                                        : 'شراء الآن',
                                    actionEnabled:
                                        !isCurrentPlan &&
                                        !purchaseBlocked &&
                                        !controller.isPurchaseFlowInProgress,
                                    isActionLoading:
                                        (controller.isActionLoading &&
                                            controller.actionPlanId == planModel.id) ||
                                        (controller.isPurchaseFlowInProgress &&
                                            controller.purchaseFlowPlanId == planModel.id),
                                    managementWidget: isCurrentPlan
                                        ? _buildCurrentPlanManagement(
                                            context,
                                            controller,
                                          )
                                        : null,
                                    countdownTarget: isCurrentPlan
                                        ? currentSubscriptionEnd
                                        : null,
                                    onCountdownFinished: isCurrentPlan
                                        ? () {
                                            if (!controller.isBillingLoading) {
                                              controller.loadBillingState();
                                            }
                                          }
                                        : null,
                                    onActionTap: () async {
                                      if (isCurrentPlan || purchaseBlocked) {
                                        return;
                                      }
                                      await _handlePurchasePlan(
                                        context,
                                        controller,
                                        planModel,
                                      );
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          SizedBox(height: height(24)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePurchasePlan(
    BuildContext context,
    PlansControllerImp controller,
    PlanModel plan,
  ) async {
    if (controller.isPurchaseFlowInProgress) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الشراء'),
        content: Text('هل تريد شراء باقة "${plan.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    controller.isPurchaseFlowInProgress = true;
    controller.purchaseFlowPlanId = plan.id;
    controller.update();

    try {
      await _refreshBillingState(controller);
      if (controller.hasBlockingCurrentSubscription &&
          !controller.isCurrentPlan(plan)) {
        customSnackBar(
          text: 'لا يمكنك شراء باقة جديدة قبل انتهاء/معالجة اشتراكك الحالي.',
          snackType: SnackBarType.info,
        );
        return;
      }

      final methods = controller.paymentMethods;
      if (methods.isEmpty) {
        await Get.to<bool>(
          () => AddPaymentMethodScreen(
            mode: AddPaymentMethodMode.purchasePlan,
            plan: plan,
          ),
        );
        await _refreshBillingState(controller);
        return;
      }

      if (!context.mounted) return;
      final selection = await _showPurchaseMethodSheet(
        context,
        methods: methods,
        defaultMethodId: controller.defaultPaymentMethodId,
      );
      if (selection == null || selection.action == _PurchaseAction.cancel) {
        return;
      }

      if (selection.action == _PurchaseAction.addNewCard) {
        await Get.to<bool>(
          () => AddPaymentMethodScreen(
            mode: AddPaymentMethodMode.purchasePlan,
            plan: plan,
          ),
        );
        await _refreshBillingState(controller);
        return;
      }

      if (selection.selectedMethodId == null) {
        customSnackBar(
          text: 'يرجى اختيار وسيلة دفع صالحة.',
          snackType: SnackBarType.info,
        );
        return;
      }

      await controller.purchasePlan(
        plan,
        paymentMethodId: selection.selectedMethodId,
      );
    } finally {
      controller.isPurchaseFlowInProgress = false;
      controller.purchaseFlowPlanId = null;
      controller.update();
    }
  }

  Future<_PurchaseMethodSelection?> _showPurchaseMethodSheet(
    BuildContext context, {
    required List<Map<String, dynamic>> methods,
    int? defaultMethodId,
  }) async {
    final preferredMethod = methods.firstWhere(
      (m) => m['id'] == defaultMethodId,
      orElse: () => methods.first,
    );
    int? selectedId = preferredMethod['id'] as int?;

    return showModalBottomSheet<_PurchaseMethodSelection>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'اختر وسيلة الدفع',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: emp(15),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...methods.map((method) {
                      final methodId = method['id'] as int?;
                      final isDefault = method['is_default'] == true;
                      final status = (method['status'] ?? '').toString();
                      final label =
                          '${(method['brand'] ?? 'Card').toString().toUpperCase()} •••• ${method['last4'] ?? '****'}';
                      final isActive = status == 'active';

                      return RadioListTile<int>(
                        value: methodId ?? -1,
                        groupValue: selectedId ?? -1,
                        onChanged: !isActive || methodId == null
                            ? null
                            : (value) => setModalState(() => selectedId = value),
                        title: Text(label),
                        subtitle: Text(
                          isDefault
                              ? 'افتراضية ${!isActive ? '• غير فعالة' : ''}'
                              : (!isActive ? 'غير فعالة' : 'نشطة'),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(
                            const _PurchaseMethodSelection(
                              action: _PurchaseAction.addNewCard,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_card_outlined),
                        label: const Text('إضافة بطاقة جديدة'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop(
                                const _PurchaseMethodSelection(
                                  action: _PurchaseAction.cancel,
                                ),
                              );
                            },
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedId == null) return;
                              final selectedMethod = methods.firstWhere(
                                (m) => m['id'] == selectedId,
                                orElse: () => <String, dynamic>{},
                              );
                              final isActive =
                                  selectedMethod['status'] == 'active';
                              if (!isActive) return;
                              Navigator.of(sheetContext).pop(
                                _PurchaseMethodSelection(
                                  action: _PurchaseAction.selectSaved,
                                  selectedMethodId: selectedId,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                            ),
                            child: const Text('متابعة الدفع'),
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

  Future<void> _refreshBillingState(PlansControllerImp controller) async {
    const backoff = <int>[0, 600, 1200, 1800];
    for (var i = 0; i < backoff.length; i++) {
      if (backoff[i] > 0) {
        await Future.delayed(Duration(milliseconds: backoff[i]));
      }
      await controller.loadBillingState();

      if (controller.hasBlockingCurrentSubscription) {
        break;
      }
      final currentStatus = (controller.currentSubscription?['status'] ?? '')
          .toString()
          .toLowerCase();
      if (currentStatus == 'active' || currentStatus == 'past_due') {
        break;
      }
    }
    await controller.getPlans();
  }

  Widget _buildCurrentPlanManagement(
    BuildContext context,
    PlansControllerImp controller,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final status = (controller.currentSubscription?['status'] ?? '')
        .toString()
        .toLowerCase();
    final autoRenew = controller.isAutoRenewEnabled;
    final canRetry = controller.canRetryPayment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isActionLoading
                ? null
                : () async {
                    final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('تأكيد الإجراء'),
                        content: Text(
                          autoRenew
                              ? 'هل تريد إيقاف التجديد التلقائي؟'
                              : 'هل تريد استئناف التجديد التلقائي؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            child: const Text('تأكيد'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;

                    if (autoRenew) {
                      await controller.cancelSubscription();
                    } else {
                      await controller.resumeSubscription();
                    }
                  },
            child: Text(autoRenew ? 'إيقاف التجديد' : 'استئناف التجديد'),
          ),
        ),
        if (status == 'past_due' && canRetry) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.isActionLoading
                  ? null
                  : () async {
                      await controller.retryPayment();
                    },
              child: const Text('إعادة محاولة الدفع'),
            ),
          ),
        ],
        if (controller.retryStatusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            controller.retryStatusMessage!,
            style: TextStyle(
              fontSize: emp(12),
              color: controller.retryStatusType == 'success'
                  ? scheme.primary
                  : controller.retryStatusType == 'failed'
                  ? scheme.error
                  : scheme.onSurface.withOpacity(0.75),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}

enum _PurchaseAction { cancel, selectSaved, addNewCard }

class _PurchaseMethodSelection {
  final _PurchaseAction action;
  final int? selectedMethodId;

  const _PurchaseMethodSelection({required this.action, this.selectedMethodId});
}
