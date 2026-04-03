import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/view/widgets/learning/question_card.dart';
import 'package:diplomasi_app/view/widgets/learning/question_text_with_attachment.dart';
import 'package:flutter/material.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final LessonQuestionModel question;
  final Future<void> Function(List<int> optionIds) onSubmit;

  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  final Set<int> selectedOptionIds = {};
  bool isLoading = false;

  @override
  void didUpdateWidget(MultipleChoiceQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear selections when the question changes (e.g. after moving to next question)
    if (oldWidget.question.id != widget.question.id) {
      selectedOptionIds.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isAnswered = widget.question.userAnswer != null;

    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction
          Text(
            'اختر الإجابات الصحيحة',
            style: TextStyle(
              fontSize: emp(15),
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: height(10)),

          // Question text + optional image
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(width(14)),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuestionTextWithAttachment(
              text: widget.question.questionText,
              imageUrl: widget.question.attachedPath,
              imageHeight: height(190),
              textAlign: TextAlign.center,
              imageAlignment: Alignment.center,
              textStyle: TextStyle(fontSize: emp(15), color: scheme.onSurface),
            ),
          ),

          SizedBox(height: height(16)),

          // Options
          ...widget.question.options.map((option) {
            final isSelected = selectedOptionIds.contains(option.id);
            final isCorrect = option.isCorrect == true;
            bool wasSelected = false;
            if (isAnswered && widget.question.userAnswer?.options != null) {
              wasSelected = widget.question.userAnswer!.options!.any(
                (a) => a.optionId == option.id,
              );
            }

            Color borderColor = colors.border;
            Color backgroundColor = colors.surfaceCard;

            if (isAnswered) {
              if (isCorrect) {
                borderColor = colors.success;
                backgroundColor = colors.success.withOpacity(0.12);
              } else if (wasSelected && !isCorrect) {
                borderColor = scheme.error;
                backgroundColor = scheme.error.withOpacity(0.12);
              }
            } else if (isSelected) {
              borderColor = scheme.primary;
              backgroundColor = scheme.primary.withOpacity(0.12);
            }

            return GestureDetector(
              onTap: isAnswered
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          selectedOptionIds.remove(option.id);
                        } else {
                          selectedOptionIds.add(option.id);
                        }
                      });
                    },
              child: Container(
                margin: EdgeInsets.only(bottom: height(10)),
                padding: EdgeInsets.symmetric(
                  horizontal: width(13),
                  vertical: height(11),
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: QuestionTextWithAttachment(
                        text: option.optionText,
                        imageUrl: option.attachedPath,
                        imageHeight: height(148),
                        imageWidth: width(200),
                        imageFit: BoxFit.cover,
                        imageAlignment: Alignment.center,
                        textAlign: TextAlign.center,
                        imageBackgroundColor: backgroundColor,
                        textStyle: TextStyle(
                          fontSize: emp(15),
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: width(10)),
                    Container(
                      width: width(19),
                      height: width(19),
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                      ),
                      child:
                          (isAnswered && isCorrect) ||
                              (isSelected && !isAnswered)
                          ? Icon(
                              Icons.check,
                              color: isAnswered
                                  ? colors.onSuccess
                                  : scheme.onPrimary,
                              size: emp(13),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: height(18)),

          // Submit button
          if (!isAnswered)
            Container(
              width: double.infinity,
              height: height(46),
              decoration: BoxDecoration(
                color: isLoading || selectedOptionIds.isEmpty
                    ? scheme.primary.withOpacity(0.6)
                    : scheme.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: (isLoading || selectedOptionIds.isEmpty)
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await widget.onSubmit(selectedOptionIds.toList());
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  borderRadius: BorderRadius.circular(11),
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
                            'تحقق',
                            style: TextStyle(
                              fontSize: emp(15),
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
