import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/custom_scaffold.dart';
import 'package:diplomasi_app/data/resource/remote/learning/lessons_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessonAttemptReviewScreen extends StatefulWidget {
  const LessonAttemptReviewScreen({super.key});

  @override
  State<LessonAttemptReviewScreen> createState() =>
      _LessonAttemptReviewScreenState();
}

class _LessonAttemptReviewScreenState extends State<LessonAttemptReviewScreen> {
  final LessonsData _lessonsData = LessonsData();
  bool _isLoading = true;
  String? _error;
  int? _lessonId;
  int? _attemptId;
  Map<String, dynamic>? _attempt;
  List<dynamic> _questions = [];

  @override
  void initState() {
    super.initState();
    _lessonId = int.tryParse(Get.parameters['lesson_id'] ?? '');
    _attemptId = int.tryParse(Get.parameters['attempt_id'] ?? '');
    _loadReview();
  }

  Future<void> _loadReview() async {
    if (_lessonId == null || _attemptId == null) {
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
      final ApiResponse response = await _lessonsData.getAttemptReview(
        lessonId: _lessonId!,
        attemptId: _attemptId!,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _attempt = data['attempt'] as Map<String, dynamic>?;
        _questions = (data['questions'] as List<dynamic>? ?? []);
      } else {
        _error = 'تعذر تحميل مراجعة المحاولة';
      }
    } catch (_) {
      _error = 'حدث خطأ أثناء تحميل المراجعة';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Set<int> _selectedOptionIds(Map<String, dynamic>? userAnswer) {
    final options = userAnswer?['options'] as List<dynamic>? ?? [];
    return options
        .map((e) => (e as Map<String, dynamic>)['option_id'] as int)
        .toSet();
  }

  Widget _buildSingleOrTrueFalse(
    BuildContext context,
    Map<String, dynamic> question,
  ) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final userAnswer = question['user_answer'] as Map<String, dynamic>?;
    final correctPayload =
        question['correct_answer_payload'] as Map<String, dynamic>?;
    final selectedIds = _selectedOptionIds(userAnswer);
    final correctId = correctPayload?['correct_option_id'] as int?;
    final options = question['options'] as List<dynamic>? ?? [];

    return Column(
      children: options.map((o) {
        final option = o as Map<String, dynamic>;
        final optionId = option['id'] as int;
        final isSelected = selectedIds.contains(optionId);
        final isCorrect = optionId == correctId;

        Color border = colors.border;
        Color bg = scheme.surface;
        if (isCorrect) {
          border = colors.success;
          bg = colors.success.withOpacity(0.10);
        } else if (isSelected && !isCorrect) {
          border = scheme.error;
          bg = scheme.error.withOpacity(0.10);
        }

        return Container(
          margin: EdgeInsets.only(bottom: height(8)),
          padding: EdgeInsets.all(width(12)),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(option['option_text'] as String? ?? '')),
              if (isSelected)
                Text(
                  'اختيارك',
                  style: TextStyle(
                    color: isCorrect ? colors.success : scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (isCorrect) ...[
                SizedBox(width: width(8)),
                Text(
                  'الصحيح',
                  style: TextStyle(
                    color: colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(
    BuildContext context,
    Map<String, dynamic> question,
  ) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final userAnswer = question['user_answer'] as Map<String, dynamic>?;
    final correctPayload =
        question['correct_answer_payload'] as Map<String, dynamic>?;
    final selectedIds = _selectedOptionIds(userAnswer);
    final correctIds =
        (correctPayload?['correct_option_ids'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toSet();
    final options = question['options'] as List<dynamic>? ?? [];

    return Column(
      children: options.map((o) {
        final option = o as Map<String, dynamic>;
        final optionId = option['id'] as int;
        final isSelected = selectedIds.contains(optionId);
        final isCorrect = correctIds.contains(optionId);

        Color border = colors.border;
        Color bg = scheme.surface;
        if (isCorrect) {
          border = colors.success;
          bg = colors.success.withOpacity(0.10);
        } else if (isSelected && !isCorrect) {
          border = scheme.error;
          bg = scheme.error.withOpacity(0.10);
        }

        return Container(
          margin: EdgeInsets.only(bottom: height(8)),
          padding: EdgeInsets.all(width(12)),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(option['option_text'] as String? ?? '')),
              if (isSelected)
                Text(
                  'اختيارك',
                  style: TextStyle(
                    color: isCorrect ? colors.success : scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (isCorrect) ...[
                SizedBox(width: width(8)),
                Text(
                  'الصحيح',
                  style: TextStyle(
                    color: colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchReview(
    BuildContext context,
    Map<String, dynamic> question,
  ) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final userAnswer = question['user_answer'] as Map<String, dynamic>?;
    final correctPayload =
        question['correct_answer_payload'] as Map<String, dynamic>?;
    final userPairs = userAnswer?['matches'] as List<dynamic>? ?? [];
    final correctPairs =
        correctPayload?['correct_pairs'] as List<dynamic>? ?? [];
    final correctCount =
        (correctPayload?['correct_count'] as num?)?.toInt() ?? 0;
    final totalCount =
        (correctPayload?['total_count'] as num?)?.toInt() ??
        correctPairs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width(10)),
          margin: EdgeInsets.only(bottom: height(10)),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'نتيجة التوصيل: $correctCount من $totalCount',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        Text(
          'اختياراتك',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: emp(14),
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: height(8)),
        ...userPairs.map((entry) {
          final pair = entry as Map<String, dynamic>;
          final isCorrect = pair['is_correct'] == true;
          final border = isCorrect ? colors.success : scheme.error;
          final bg = isCorrect
              ? colors.success.withOpacity(0.10)
              : scheme.error.withOpacity(0.10);
          return Container(
            margin: EdgeInsets.only(bottom: height(8)),
            padding: EdgeInsets.all(width(12)),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(pair['left_option_text'] as String? ?? ''),
                ),
                Icon(Icons.arrow_right_alt, color: border),
                Expanded(
                  child: Text(
                    pair['right_option_text'] as String? ?? '',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: height(10)),
        Text(
          'التوصيل الصحيح',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: emp(14),
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: height(8)),
        ...correctPairs.map((entry) {
          final pair = entry as Map<String, dynamic>;
          return Container(
            margin: EdgeInsets.only(bottom: height(8)),
            padding: EdgeInsets.all(width(12)),
            decoration: BoxDecoration(
              color: colors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.success.withOpacity(0.7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(pair['left_option_text'] as String? ?? ''),
                ),
                Icon(Icons.arrow_right_alt, color: colors.success),
                Expanded(
                  child: Text(
                    pair['right_option_text'] as String? ?? '',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    int index,
    Map<String, dynamic> question,
  ) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final userAnswer = question['user_answer'] as Map<String, dynamic>?;
    final bool isCorrect = userAnswer?['is_correct'] == true;
    final type = question['type'] as String? ?? '';

    Widget body;
    if (type == 'single_choice' || type == 'true_false') {
      body = _buildSingleOrTrueFalse(context, question);
    } else if (type == 'multiple_choice') {
      body = _buildMultipleChoice(context, question);
    } else if (type == 'match') {
      body = _buildMatchReview(context, question);
    } else {
      body = Text(
        'نوع سؤال غير مدعوم: $type',
        style: TextStyle(color: colors.textSecondary),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: height(12)),
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
                  'السؤال ${index + 1}',
                  style: TextStyle(
                    fontSize: emp(15),
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
                  color:
                      (isCorrect
                              ? colors.success
                              : Theme.of(context).colorScheme.error)
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCorrect ? 'صحيح' : 'خاطئ',
                  style: TextStyle(
                    color: isCorrect
                        ? colors.success
                        : Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                    fontSize: emp(12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height(8)),
          Text(
            question['question_text'] as String? ?? '',
            style: TextStyle(fontSize: emp(15), color: scheme.onSurface),
          ),
          SizedBox(height: height(12)),
          body,
        ],
      ),
    );
  }

  String _formatScore(dynamic scoreValue) {
    if (scoreValue is num) {
      return scoreValue.toDouble().toStringAsFixed(2);
    }
    final parsed = double.tryParse(scoreValue?.toString() ?? '');
    return (parsed ?? 0).toStringAsFixed(2);
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
                    'مراجعة المحاولة',
                    style: TextStyle(
                      fontSize: emp(18),
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (_attempt != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width(16),
                  vertical: height(4),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width(12)),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'النتيجة: ${_formatScore(_attempt!['score'])}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
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
                  : ListView.builder(
                      padding: EdgeInsets.all(width(16)),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(
                          context,
                          index,
                          _questions[index] as Map<String, dynamic>,
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
