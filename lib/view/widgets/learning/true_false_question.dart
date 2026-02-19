import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/view/widgets/learning/question_card.dart';
import 'package:flutter/material.dart';

class TrueFalseQuestion extends StatefulWidget {
  final LessonQuestionModel question;
  final Future<void> Function(int optionId) onSubmit;

  const TrueFalseQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<TrueFalseQuestion> createState() => _TrueFalseQuestionState();
}

class _TrueFalseQuestionState extends State<TrueFalseQuestion> {
  int? selectedOptionId;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isAnswered = widget.question.userAnswer != null;
    
    // Find True and False options
    final trueOption = widget.question.options.firstWhere(
      (opt) => opt.optionText.toLowerCase().contains('صح') ||
               opt.optionText.toLowerCase().contains('true'),
      orElse: () => widget.question.options.first,
    );
    
    final falseOption = widget.question.options.firstWhere(
      (opt) => opt.optionText.toLowerCase().contains('خطأ') ||
               opt.optionText.toLowerCase().contains('false'),
      orElse: () => widget.question.options.length > 1
          ? widget.question.options[1]
          : widget.question.options.first,
    );

    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text or image
          if (widget.question.attachedPath != null) ...[
            Container(
              width: double.infinity,
              height: height(200),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.question.attachedPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'لا يمكن تحميل الصورة',
                        style: TextStyle(
                          fontSize: emp(14),
                          color: colors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: height(16)),
          ],
          
          if (widget.question.questionText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width(16)),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.question.questionText,
                style: TextStyle(
                  fontSize: emp(16),
                  color: scheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: height(20)),
          ],
          
          // True/False options
          _buildOption(context, trueOption, 'صح'),
          SizedBox(height: height(12)),
          _buildOption(context, falseOption, 'خطأ'),
          
          SizedBox(height: height(24)),
          
          // Submit button
          if (!isAnswered)
            Container(
              width: double.infinity,
              height: height(48),
              decoration: BoxDecoration(
                color: isLoading || selectedOptionId == null
                    ? scheme.primary.withOpacity(0.6)
                    : scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: (isLoading || selectedOptionId == null)
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await widget.onSubmit(selectedOptionId!);
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
                            'تحقق',
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

  Widget _buildOption(BuildContext context, option, String label) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isSelected = selectedOptionId == option.id;
    final isAnswered = widget.question.userAnswer != null;
    final isCorrect = option.isCorrect == true;
    final isWrong = isAnswered && isSelected && !isCorrect;
    
    Color borderColor = colors.border;
    Color backgroundColor = colors.surfaceCard;
    
    if (isAnswered) {
      if (isCorrect) {
        borderColor = colors.success;
        backgroundColor = colors.success.withOpacity(0.12);
      } else if (isWrong) {
        borderColor = scheme.error;
        backgroundColor = scheme.error.withOpacity(0.12);
      }
    } else if (isSelected) {
      borderColor = scheme.primary;
      backgroundColor = scheme.primary.withOpacity(0.12);
    }
    
    return GestureDetector(
      onTap: isAnswered ? null : () {
        setState(() {
          selectedOptionId = option.id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(width(16)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: emp(16),
                  color: scheme.onSurface,
                ),
              ),
            ),
            SizedBox(width: width(12)),
            Container(
              width: width(20),
              height: width(20),
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
              child: isAnswered && isCorrect
                  ? Icon(
                      Icons.check,
                      color: colors.onSuccess,
                      size: emp(14),
                    )
                  : isAnswered && isWrong
                      ? Icon(
                          Icons.close,
                          color: colors.onError,
                          size: emp(14),
                        )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

