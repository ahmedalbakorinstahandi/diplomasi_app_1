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

  List<Color> _matchPalette(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      colors.info,
      colors.success,
      colors.warning,
      colors.highlight,
      scheme.error,
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

    // Separate left and right options
    final leftOptions = <LessonQuestionOptionModel>[];
    final rightOptions = <LessonQuestionOptionModel>[];

    // Group options by pair_key or assume first half is left, second half is right
    final half = widget.question.options.length ~/ 2;
    for (int i = 0; i < widget.question.options.length; i++) {
      if (i < half) {
        leftOptions.add(widget.question.options[i]);
      } else {
        rightOptions.add(widget.question.options[i]);
      }
    }

    return QuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instruction
          Text(
            'صل بين العناصر',
            style: TextStyle(
              fontSize: emp(18),
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: height(24)),

          // Match grid
          Row(
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: leftOptions.map((leftOption) {
                    final isSelected = selectedLeftOptionId == leftOption.id;
                    final matchedRightId = selectedMatches[leftOption.id];
                    final isMatched = matchedRightId != null;
                    final matchColor = isMatched
                        ? getMatchColor(context, leftOption.id)
                        : (isSelected
                              ? getColorForNewSelection(context)
                              : scheme.primary);

                    Color borderColor = colors.border;
                    Color backgroundColor = colors.surfaceCard;

                    if (isAnswered) {
                      // Check if this match was correct
                      AnswerMatch? userMatch;
                      if (widget.question.userAnswer?.matches != null) {
                        try {
                          userMatch = widget.question.userAnswer!.matches!
                              .firstWhere(
                                (m) => m.leftOptionId == leftOption.id,
                              );
                        } catch (e) {
                          userMatch = null;
                        }
                      }
                      if (userMatch != null) {
                        if (userMatch.isCorrect) {
                          borderColor = colors.success;
                          backgroundColor = colors.success.withOpacity(0.12);
                        } else {
                          borderColor = scheme.error;
                          backgroundColor = scheme.error.withOpacity(0.12);
                        }
                      }
                    } else if (isSelected) {
                      borderColor = matchColor;
                      backgroundColor = matchColor.withOpacity(0.2);
                    } else if (isMatched) {
                      borderColor = matchColor;
                      backgroundColor = matchColor.withOpacity(0.1);
                    }

                    return GestureDetector(
                      onTap: isAnswered
                          ? null
                          : () {
                              setState(() {
                                if (isMatched) {
                                  // Remove the match if clicking on a matched option
                                  selectedMatches.remove(leftOption.id);
                                  if (selectedLeftOptionId == leftOption.id) {
                                    selectedLeftOptionId = null;
                                  }
                                } else if (isSelected) {
                                  selectedLeftOptionId = null;
                                } else {
                                  selectedLeftOptionId = leftOption.id;
                                }
                              });
                            },
                      child: Container(
                        margin: EdgeInsets.only(bottom: height(12)),
                        padding: EdgeInsets.all(width(12)),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Text(
                          leftOption.optionText,
                          style: TextStyle(
                            fontSize: emp(14),
                            color: scheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(width: width(16)),

              // Right column
              Expanded(
                child: Column(
                  children: rightOptions.map((rightOption) {
                    // Find which left option is matched to this right option
                    int? matchedLeftId;
                    selectedMatches.forEach((leftId, rightId) {
                      if (rightId == rightOption.id) {
                        matchedLeftId = leftId;
                      }
                    });

                    final isMatched = matchedLeftId != null;
                    final isSelected =
                        selectedLeftOptionId != null &&
                        selectedMatches[selectedLeftOptionId] == rightOption.id;
                    final matchColor = isMatched && matchedLeftId != null
                        ? getMatchColor(context, matchedLeftId!)
                        : scheme.primary;

                    Color borderColor = colors.border;
                    Color backgroundColor = colors.surfaceCard;

                    if (isAnswered) {
                      // Check if this match was correct
                      AnswerMatch? userMatch;
                      if (widget.question.userAnswer?.matches != null) {
                        try {
                          userMatch = widget.question.userAnswer!.matches!
                              .firstWhere(
                                (m) => m.rightOptionId == rightOption.id,
                              );
                        } catch (e) {
                          userMatch = null;
                        }
                      }
                      if (userMatch != null) {
                        if (userMatch.isCorrect) {
                          borderColor = colors.success;
                          backgroundColor = colors.success.withOpacity(0.12);
                        } else {
                          borderColor = scheme.error;
                          backgroundColor = scheme.error.withOpacity(0.12);
                        }
                      }
                    } else if (isSelected) {
                      // Only show highlight when this right option is matched to the selected left option
                      final selectedMatchColor = selectedLeftOptionId != null
                          ? getColorForNewSelection(context)
                          : scheme.primary;
                      borderColor = selectedMatchColor;
                      backgroundColor = selectedMatchColor.withOpacity(0.2);
                    } else if (isMatched) {
                      borderColor = matchColor;
                      backgroundColor = matchColor.withOpacity(0.1);
                    }

                    return GestureDetector(
                      onTap: isAnswered
                          ? null
                          : () {
                              setState(() {
                                if (isMatched && matchedLeftId != null) {
                                  // Remove the match if clicking on a matched option
                                  selectedMatches.remove(matchedLeftId);
                                  if (selectedLeftOptionId == matchedLeftId) {
                                    selectedLeftOptionId = null;
                                  }
                                } else if (selectedLeftOptionId != null) {
                                  // Check if this right option is already matched to another left
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
                        margin: EdgeInsets.only(bottom: height(12)),
                        padding: EdgeInsets.all(width(12)),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Text(
                          rightOption.optionText,
                          style: TextStyle(
                            fontSize: emp(14),
                            color: scheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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
