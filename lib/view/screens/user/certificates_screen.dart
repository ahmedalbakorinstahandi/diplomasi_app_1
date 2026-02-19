import 'package:diplomasi_app/controllers/user/certificates_controller.dart';
import 'package:diplomasi_app/core/classes/handling_data_view.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/user/certificate_model.dart';
import 'package:diplomasi_app/view/shimmers/user/presentation/shimmer/certificates_screen_shimmer.dart';
import 'package:diplomasi_app/view/widgets/user/certificate_card.dart';
import 'package:diplomasi_app/view/widgets/user/certificates_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CertificatesControllerImp());
    return GetBuilder<CertificatesControllerImp>(
      init: CertificatesControllerImp(),
      builder: (controller) {
        return MyScaffold(
          body: Column(
            children: [
              // Header
              const CertificatesHeader(),
              // Certificates List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    return controller.getCertificates(reload: true);
                  },
                  child: HandlingListDataView(
                    isLoading: controller.isLoading,
                    dataIsEmpty: controller.certificates.isEmpty,
                    emptyMessage: 'لا توجد شهادات حتى الآن',
                    loadingWidget: const CertificatesScreenShimmer(),
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(vertical: height(16)),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.certificates.length,
                      itemBuilder: (context, index) {
                        final certificate = CertificateModel.fromJson(
                          controller.certificates[index],
                        );

                        final isCurrentlyDownloading = controller
                            .certificatesDownloading
                            .contains(certificate.id);

                        return CertificateCard(
                          certificate: certificate,
                          onTap: () =>
                              controller.selectCertificate(certificate),
                          onDownload: () =>
                              controller.downloadCertificate(index),
                          onShare: () =>
                              controller.shareCertificate(certificate),
                          isDownloading: isCurrentlyDownloading,
                        );
                      },
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
}
