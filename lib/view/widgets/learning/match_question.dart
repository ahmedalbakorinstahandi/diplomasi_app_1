import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/lesson_answer_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_option_model.dart';
import 'package:diplomasi_app/view/widgets/learning/question_card.dart';
import 'package:flutter/material.dart';

class MatchQuestion extends StatefulWidget {
  final LessonQuestionModel question;
  final Future<void> Function(List<Map<String, int>> matches) onSubmit;

  const MatchQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<MatchQuestion> createState() => _MatchQuestionState();
}

class _MatchQuestionState extends State<MatchQuestion> {
  final Map<int, int> selectedMatches = {}; // leftOptionId -> rightOptionId
  int? selectedLeftOptionId;
  bool isLoading = false;

  /// ألوان واضحة ومختلفة تماماً لكل زوج اختيار (حتى يُميّز المستخدم بين أزواج التحديد)
  List<Color> _matchPalette(BuildContext context) {
    return [
      const Color(0xFF1976D2), // أزرق
      const Color(0xFFE65100), // برتقالي غامق
      const Color(0xFF2E7D32), // أخضر
      const Color(0xFFC62828), // أحمر
      const Color(0xFF6A1B9A), // بنفسجي
      const Color(0xFF00838F), // تركواز
      const Color(0xFFF9A825), // كهرماني
      const Color(0xFF283593), // نيلي
    ];
  }

  Color getMatchColor(BuildContext context, int leftOptionId) {
    final palette = _matchPalette(context);
    final index = selectedMatches.keys.toList().indexOf(leftOptionId);
    if (index >= 0 && palette.isNotEmpty) {
      return palette[index % palette.length];
    }
    return Theme.of(context).colorScheme.primary;
  }

  Color getColorForNewSelection(BuildContext context) {
    final palette = _matchPalette(context);
    final completedPairsCount = selectedMatches.length;
    if (palette.isNotEmpty) {
      return palette[completedPairsCount % palette.length];
    }
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isAnswered = widget.question.userAnswer != null;

    // Use API left/right columns when provided; otherwise fallback to splitting options in half
    final List<LessonQuestionOptionModel> leftOptions;
    final List<LessonQuestionOptionModel> rightOptions;
    final leftProvided = widget.question.leftOptions != null &&
        widget.question.leftOptions!.isNotEmpty &&
        widget.question.rightOptions != null &&
        widget.question.rightOptions!.isNotEmpty;
    if (leftProvided) {
      leftOptions = widget.question.leftOptions!;
      rightOptions = widget.question.rightOptions!;
    } else {
      final half = widget.question.options.length ~/ 2;
      leftOptions = widget.question.options.take(half).toList();
      rightOptions = widget.question.options.skip(half).toList();
    }

    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction
          Text(
            widget.question.questionText.trim().isNotEmpty
                ? widget.question.questionText
                : 'صل بين العناصر',
            style: TextStyle(
              fontSize: emp(18),
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: height(24)),

          // Match grid: صف واحد لكل زوج حتى يكون العمودان موازيين (أ فوق ب)
          Column(
            children: List.generate(leftOptions.length, (i) {
              if (i >= rightOptions.length) return const SizedBox.shrink();
              final leftOption = leftOptions[i];
              final rightOption = rightOptions[i];
              final isSelectedLeft = selectedLeftOptionId == leftOption.id;
              final matchedRightId = selectedMatches[leftOption.id];
              final isMatchedLeft = matchedRightId != null;
              int? matchedLeftId;
              selectedMatches.forEach((leftId, rightId) {
                if (rightId == rightOption.id) matchedLeftId = leftId;
              });
              final isMatchedRight = matchedLeftId != null;
              final isSelectedRight = selectedLeftOptionId != null &&
                  selectedMatches[selectedLeftOptionId] == rightOption.id;

              // لون الخلية اليسرى: حسب الزوج الذي يشمله (إن وُجد)
              final Color leftCellColor = isMatchedLeft
                  ? getMatchColor(context, leftOption.id)
                  : (isSelectedLeft ? getColorForNewSelection(context) : scheme.primary);
              // لون الخلية اليمنى: حسب الزوج الذي يشمله (نفس لون الشريك الأيسر)، وليس لون الصف
              final Color rightCellColor = isMatchedRight && matchedLeftId != null
                  ? getMatchColor(context, matchedLeftId!)
                  : (isSelectedRight ? getColorForNewSelection(context) : scheme.primary);

              Color leftBorder = colors.border;
              Color leftBg = colors.surfaceCard;
              Color rightBorder = colors.border;
              Color rightBg = colors.surfaceCard;

              if (isAnswered) {
                AnswerMatch? userMatchLeft;
                AnswerMatch? userMatchRight;
                if (widget.question.userAnswer?.matches != null) {
                  try {
                    userMatchLeft = widget.question.userAnswer!.matches!
                        .firstWhere((m) => m.leftOptionId == leftOption.id);
                  } catch (_) {}
                  try {
                    userMatchRight = widget.question.userAnswer!.matches!
                        .firstWhere((m) => m.rightOptionId == rightOption.id);
                  } catch (_) {}
                }
                if (userMatchLeft != null) {
                  if (userMatchLeft.isCorrect) {
                    leftBorder = colors.success;
                    leftBg = colors.success.withOpacity(0.12);
                  } else {
                    leftBorder = scheme.error;
                    leftBg = scheme.error.withOpacity(0.12);
                  }
                }
                if (userMatchRight != null) {
                  if (userMatchRight.isCorrect) {
                    rightBorder = colors.success;
                    rightBg = colors.success.withOpacity(0.12);
                  } else {
                    rightBorder = scheme.error;
                    rightBg = scheme.error.withOpacity(0.12);
                  }
                }
              } else {
                if (isSelectedLeft || isMatchedLeft) {
                  leftBorder = leftCellColor;
                  leftBg = isSelectedLeft
                      ? leftCellColor.withOpacity(0.2)
                      : leftCellColor.withOpacity(0.1);
                }
                if (isSelectedRight || isMatchedRight) {
                  rightBorder = rightCellColor;
                  rightBg = isSelectedRight
                      ? rightCellColor.withOpacity(0.2)
                      : rightCellColor.withOpacity(0.1);
                }
              }

              return Padding(
                padding: EdgeInsets.only(bottom: height(12)),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: isAnswered
                              ? null
                              : () {
                                  setState(() {
                                    if (isMatchedLeft) {
                                      selectedMatches.remove(leftOption.id);
                                      if (selectedLeftOptionId == leftOption.id) {
                                        selectedLeftOptionId = null;
                                      }
                                    } else if (isSelectedLeft) {
                                      selectedLeftOptionId = null;
                                    } else {
                                      selectedLeftOptionId = leftOption.id;
                                    }
                                  });
                                },
                          child: Container(
                            padding: EdgeInsets.all(width(12)),
                            decoration: BoxDecoration(
                              color: leftBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: leftBorder, width: 2),
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              leftOption.optionText,
                              style: TextStyle(
                                fontSize: emp(14),
                                color: scheme.onSurface,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width(12)),
                      Expanded(
                        child: GestureDetector(
                          onTap: isAnswered
                              ? null
                              : () {
                                  setState(() {
                                    if (isMatchedRight && matchedLeftId != null) {
                                      selectedMatches.remove(matchedLeftId);
                                      if (selectedLeftOptionId == matchedLeftId) {
                                        selectedLeftOptionId = null;
                                      }
                                    } else if (selectedLeftOptionId != null) {
                                      int? existingLeftId;
                                      selectedMatches.forEach((leftId, rightId) {
                                        if (rightId == rightOption.id) {
                                          existingLeftId = leftId;
                                        }
                                      });
                                      if (existingLeftId != null) {
                                        selectedMatches.remove(existingLeftId);
                                      }
                                      selectedMatches[selectedLeftOptionId!] =
                                          rightOption.id;
                                      selectedLeftOptionId = null;
                                    }
                                  });
                                },
                          child: Container(
                            padding: EdgeInsets.all(width(12)),
                            decoration: BoxDecoration(
                              color: rightBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: rightBorder, width: 2),
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              rightOption.optionText,
                              style: TextStyle(
                                fontSize: emp(14),
                                color: scheme.onSurface,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: height(24)),

          // Submit button
          if (!isAnswered)
            Container(
              width: double.infinity,
              height: height(48),
              decoration: BoxDecoration(
                color: isLoading || selectedMatches.length != leftOptions.length
                    ? scheme.primary.withOpacity(0.6)
                    : scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap:
                      (isLoading ||
                          selectedMatches.length != leftOptions.length)
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final matches = selectedMatches.entries
                                .map(
                                  (e) => {
                                    'left_option_id': e.key,
                                    'right_option_id': e.value,
                                  },
                                )
                                .toList();
                            await widget.onSubmit(matches);
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: width(20),
                            height: width(20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'متابعة',
                            style: TextStyle(
                              fontSize: emp(16),
                              fontWeight: FontWeight.w600,
                              color: scheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
