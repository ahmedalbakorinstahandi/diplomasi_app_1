import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
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
          backgroundColor: scheme.primary,
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
                        color: scheme.onPrimary,
                      ),
                      label: Text(
                        'الفواتير',
                        style: TextStyle(
                          fontSize: emp(14),
                          fontWeight: FontWeight.w500,
                          color: scheme.onPrimary,
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
                      icon: Icon(Icons.credit_card, color: scheme.onPrimary),
                      label: Text(
                        'وسائل الدفع',
                        style: TextStyle(
                          fontSize: emp(14),
                          fontWeight: FontWeight.w500,

                          color: scheme.onPrimary,
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
                        color: scheme.onPrimary.withOpacity(0.85),
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
                                  final purchaseBlocked =
                                      controller
                                          .hasBlockingActiveSubscription &&
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
                                        !isCurrentPlan && !purchaseBlocked,
                                    isActionLoading:
                                        controller.isActionLoading &&
                                        controller.actionPlanId == planModel.id,
                                    managementWidget: isCurrentPlan
                                        ? _buildCurrentPlanManagement(
                                            context,
                                            controller,
                                          )
                                        : null,
                                    onActionTap: () async {
                                      if (isCurrentPlan || purchaseBlocked) {
                                        return;
                                      }
                                      await _handlePurchasePlan(
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
    PlansControllerImp controller,
    PlanModel plan,
  ) async {
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

    await controller.loadBillingState();

    if (controller.hasActiveDefaultMethod) {
      await controller.purchasePlan(plan);
      return;
    }

    final completed = await Get.to<bool>(
      () => AddPaymentMethodScreen(
        mode: AddPaymentMethodMode.purchasePlan,
        plan: plan,
      ),
    );
    if (completed == true) {
      await controller.loadBillingState();
    }
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
