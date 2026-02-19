import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/variables.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:diplomasi_app/core/classes/internet_connectivity_service.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/print.dart';
import 'package:diplomasi_app/core/functions/size.dart';

class HandlingDataView {
  final bool loading;
  final bool dataIsEmpty;
  final bool isValid;
  final Widget? response;

  HandlingDataView({required this.loading, required this.dataIsEmpty})
    : isValid = (loading && dataIsEmpty) || dataIsEmpty,
      response = (loading && dataIsEmpty) || dataIsEmpty
          ? _buildResponse(loading, dataIsEmpty)
          : null;

  static Widget _buildResponse(bool loading, bool dataIsEmpty) {
    // final InternetConnectivityService connectivityService;
    printDebug(isInternetConnected);
    if (!isInternetConnected) {
      return Scaffold(
        appBar: AppBar(
          // title: Text('no_internet'.tr),
        ),
        body: Center(child: Lottie.asset(Assets.pictures.lottie.noInternet)),
      );
    }

    if (loading && dataIsEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (dataIsEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            'no_data_found'.tr,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return const Scaffold();
  }
}

class HandlingListDataView extends StatelessWidget {
  final bool isLoading;
  final bool dataIsEmpty;
  final Widget child;
  final String emptyMessage;
  final String? lottiePath;
  // loading widget
  final Widget? loadingWidget;
  final bool? loadingIfDataNotIsEmpty;

  // physics
  final ScrollPhysics? physics;
  const HandlingListDataView({
    super.key,
    required this.isLoading,
    required this.dataIsEmpty,
    required this.child,
    this.emptyMessage = "لا يوجد بيانات",
    this.lottiePath,
    this.physics,
    this.loadingWidget,
    this.loadingIfDataNotIsEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return !InternetConnectivityService().isConnected
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(Assets.pictures.lottie.noInternet),
              Text(
                'لا يوجد اتصال بالانترنت',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
            ],
          )
        : dataIsEmpty || loadingIfDataNotIsEmpty == true
        ? ListView(
            padding: EdgeInsets.zero,
            physics: physics,
            shrinkWrap: true,
            children: [
              isLoading && loadingWidget != null
                  ? loadingWidget!
                  : SizedBox(
                      height: getHeight() / 1.4,
                      child: Center(
                        child: isLoading
                            ? loadingWidget ??
                                  CircularProgressIndicator(color: scheme.primary)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    lottiePath ??
                                        Assets.pictures.lottie.notFound,
                                  ),
                                  Text(
                                    (emptyMessage == "لا يوجد بيانات")
                                        ? 'لا يوجد بيانات'
                                        : emptyMessage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ],
          )
        : child;
  }
}
