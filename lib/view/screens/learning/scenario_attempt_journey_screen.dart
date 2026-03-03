import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/resource/remote/learning/scenarios_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScenarioAttemptJourneyScreen extends StatefulWidget {
  const ScenarioAttemptJourneyScreen({super.key});

  @override
  State<ScenarioAttemptJourneyScreen> createState() => _ScenarioAttemptJourneyScreenState();
}

class _ScenarioAttemptJourneyScreenState extends State<ScenarioAttemptJourneyScreen> {
  final ScenariosData _scenariosData = ScenariosData();
  bool _isLoading = true;
  String? _error;
  int? _scenarioId;
  int? _attemptId;
  Map<String, dynamic>? _attempt;
  Map<String, dynamic>? _scenario;
  List<dynamic> _steps = [];

  @override
  void initState() {
    super.initState();
    _scenarioId = int.tryParse(Get.parameters['scenario_id'] ?? '');
    _attemptId = int.tryParse(Get.parameters['attempt_id'] ?? '');
    _loadJourney();
  }

  Future<void> _loadJourney() async {
    if (_scenarioId == null || _attemptId == null) {
      setState(() {
        _isLoading = false;
        _error = 'بيانات المحاولة غير صالحة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ApiResponse response = await _scenariosData.getAttemptJourney(
        scenarioId: _scenarioId!,
        attemptId: _attemptId!,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _attempt = data['attempt'] as Map<String, dynamic>?;
        _scenario = data['scenario'] as Map<String, dynamic>?;
        _steps = data['steps'] as List<dynamic>? ?? [];
      } else {
        _error = 'تعذر تحميل مسار المحاولة';
      }
    } catch (_) {
      _error = 'حدث خطأ أثناء تحميل المسار';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStepCard(BuildContext context, int index, Map<String, dynamic> step) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final question = step['question'] as Map<String, dynamic>?;
    final selectedOption = step['selected_option'] as Map<String, dynamic>?;
    final nextQuestion = step['next_question'] as Map<String, dynamic>?;
    final bool isLast = index == _steps.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width(30),
          child: Column(
            children: [
              Container(
                width: width(18),
                height: width(18),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: emp(10),
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: height(90),
                  color: colors.border,
                ),
            ],
          ),
        ),
        SizedBox(width: width(8)),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: height(12)),
            padding: EdgeInsets.all(width(12)),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question?['question_text']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: emp(14),
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: height(8)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width(10)),
                  decoration: BoxDecoration(
                    color: colors.info.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.info.withOpacity(0.5)),
                  ),
                  child: Text(
                    'اختيارك: ${selectedOption?['option_text']?.toString() ?? '-'}',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if ((selectedOption?['feedback_text']?.toString().isNotEmpty ?? false)) ...[
                  SizedBox(height: height(8)),
                  Text(
                    selectedOption!['feedback_text'].toString(),
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
                SizedBox(height: height(8)),
                Text(
                  nextQuestion != null
                      ? 'الانتقال إلى: ${nextQuestion['question_text'] ?? ''}'
                      : 'نهاية المسار',
                  style: TextStyle(
                    color: nextQuestion != null ? colors.textSecondary : colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                    'مسار المحاولة',
                    style: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (_scenario != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(16)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width(12)),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _scenario!['title']?.toString() ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            if (_attempt != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width(16), vertical: height(8)),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width(10)),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'عدد الخطوات: ${_steps.length} • الحالة: ${_attempt!['status'] == 'finished' ? 'مكتملة' : 'قيد التنفيذ'}',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            SizedBox(height: height(8)),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!, style: TextStyle(color: scheme.error)))
                  : _steps.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد خطوات محفوظة لهذه المحاولة',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(width(16)),
                      itemCount: _steps.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _steps.length) {
                          return _buildStepCard(
                            context,
                            index,
                            _steps[index] as Map<String, dynamic>,
                          );
                        }
                        final finished = _attempt?['status'] == 'finished';
                        return Container(
                          margin: EdgeInsets.only(top: height(8)),
                          padding: EdgeInsets.all(width(12)),
                          decoration: BoxDecoration(
                            color: (finished ? colors.success : colors.warning).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: finished ? colors.success : colors.warning,
                            ),
                          ),
                          child: Text(
                            finished
                                ? 'تم إنهاء المسار لهذه المحاولة'
                                : 'المحاولة لم تنتهِ بعد',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: finished ? colors.success : colors.warning,
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

