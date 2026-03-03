import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/resource/remote/learning/scenarios_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScenarioAttemptsScreen extends StatefulWidget {
  const ScenarioAttemptsScreen({super.key});

  @override
  State<ScenarioAttemptsScreen> createState() => _ScenarioAttemptsScreenState();
}

class _ScenarioAttemptsScreenState extends State<ScenarioAttemptsScreen> {
  final ScenariosData _scenariosData = ScenariosData();
  bool _isLoading = true;
  String? _error;
  int? _scenarioId;
  List<dynamic> _attempts = [];

  @override
  void initState() {
    super.initState();
    _scenarioId = int.tryParse(Get.parameters['scenario_id'] ?? '');
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    if (_scenarioId == null) {
      setState(() {
        _isLoading = false;
        _error = 'معرف السيناريو غير صالح';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ApiResponse response = await _scenariosData.getAttempts(
        scenarioId: _scenarioId!,
      );
      if (response.isSuccess && response.data != null) {
        _attempts = response.data as List<dynamic>;
      } else {
        _error = 'تعذر تحميل المحاولات';
      }
    } catch (_) {
      _error = 'حدث خطأ أثناء تحميل المحاولات';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return MyScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width(12)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: width(8)),
                  Text(
                    'محاولات السيناريو',
                    style: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(_error!, style: TextStyle(color: scheme.error)),
                    )
                  : _attempts.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد محاولات سابقة',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(width(16)),
                      itemCount: _attempts.length,
                      separatorBuilder: (_, __) => SizedBox(height: height(10)),
                      itemBuilder: (context, index) {
                        final attempt = _attempts[index] as Map<String, dynamic>;
                        final status = (attempt['status'] as String? ?? '');
                        final finished = status == 'finished';
                        final statusColor = finished ? colors.success : colors.warning;
                        final statusText = finished ? 'مكتملة' : 'قيد التنفيذ';

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.scenarioAttemptJourney,
                              parameters: {
                                'scenario_id': attempt['scenario_id'].toString(),
                                'attempt_id': attempt['id'].toString(),
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(width(14)),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'محاولة #${attempt['id']}',
                                        style: TextStyle(
                                          fontSize: emp(16),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width(10),
                                        vertical: height(4),
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: emp(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height(8)),
                                Text(
                                  'عدد الخطوات: ${attempt['steps_count'] ?? 0}',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                                SizedBox(height: height(4)),
                                Text(
                                  'بدأت: ${_formatDate(attempt['started_at'])}',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

