import 'package:get/get.dart';
import 'package:diplomasi_app/core/classes/api_service.dart';
import 'package:diplomasi_app/core/classes/internet_connectivity_service.dart';
import 'package:diplomasi_app/routes/api.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(InternetConnectivityService());
    Get.put(
      ApiService(
        baseUrl: EndPoints.baseApi,
        connectivityService: Get.find(),
        defaultHeaders: {'Accept': 'application/json'},
      ),
    );
    // Get.put(FilterStore(), permanent: true);
  }
}
