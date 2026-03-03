import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/routes.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/model/learning/lesson_attempt_model.dart';
import 'package:diplomasi_app/data/resource/remote/learning/lessons_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonAttemptsScreen extends StatefulWidget {
  const LessonAttemptsScreen({super.key});

  @override
  State<LessonAttemptsScreen> createState() => _LessonAttemptsScreenState();
}

class _LessonAttemptsScreenState extends State<LessonAttemptsScreen> {
  final LessonsData _lessonsData = LessonsData();
  bool _isLoading = true;
  String? _error;
  int? _lessonId;
  List<LessonAttemptModel> _attempts = [];

  @override
  void initState() {
    super.initState();
    _lessonId = int.tryParse(Get.parameters['lesson_id'] ?? '');
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    if (_lessonId == null) {
      setState(() {
        _isLoading = false;
        _error = 'معرف الدرس غير صالح';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ApiResponse response = await _lessonsData.getAttempts(
        lessonId: _lessonId!,
      );
      if (response.isSuccess && response.data != null) {
        final list = response.data as List<dynamic>;
        _attempts = list
            .map((e) => LessonAttemptModel.fromJson(e as Map<String, dynamic>))
            .toList();
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

  String _formatDate(String value) {
    try {
      final dt = DateTime.parse(value).toLocal();
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
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
                    'المحاولات السابقة',
                    style: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
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
                      child: Text(
                        _error!,
                        style: TextStyle(color: scheme.error),
                      ),
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
                      itemBuilder: (context, index) {
                        final attempt = _attempts[index];
                        final statusText = attempt.status == 'finished'
                            ? 'مكتملة'
                            : 'قيد التنفيذ';
                        final statusColor = attempt.status == 'finished'
                            ? colors.success
                            : colors.warning;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.lessonAttemptReview,
                              parameters: {
                                'lesson_id': attempt.lessonId.toString(),
                                'attempt_id': attempt.id.toString(),
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
                                        'محاولة #${attempt.id}',
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
                                          fontWeight: FontWeight.w600,
                                          fontSize: emp(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height(8)),
                                Text(
                                  'النتيجة: ${attempt.score.toStringAsFixed(2)}%',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                                SizedBox(height: height(4)),
                                Text(
                                  'التقدم: ${attempt.progress?.answered ?? 0}/${attempt.progress?.total ?? 0}',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                                SizedBox(height: height(4)),
                                Text(
                                  'بدأت: ${_formatDate(attempt.startedAt)}',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => SizedBox(height: height(10)),
                      itemCount: _attempts.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

