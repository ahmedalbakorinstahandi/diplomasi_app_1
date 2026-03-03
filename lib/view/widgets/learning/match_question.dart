import 'dart:math' show sqrt;

import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/lesson_answer_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_model.dart';
import 'package:diplomasi_app/data/model/learning/lesson_question_option_model.dart';
import 'package:diplomasi_app/view/widgets/learning/question_card.dart';
import 'package:flutter/material.dart';

/// نقطة بداية ونهاية ولون لخط ربط زوج
class _LineSegment {
  final Offset start;
  final Offset end;
  final Color color;

  _LineSegment(this.start, this.end, this.color);
}

/// يرسم خطوطاً منحنية (Bezier) بين الأزواج مع رأس سهم (السهم يمكن إيقافه عبر [showArrows])
class _MatchLinesPainter extends CustomPainter {
  final List<_LineSegment> segments;
  final bool showArrows;

  _MatchLinesPainter(this.segments, {this.showArrows = false});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in segments) {
      _drawCurvedArrow(canvas, s.start, s.end, s.color, showArrows: showArrows);
    }
  }

  void _drawCurvedArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    bool showArrows = false,
  }) {
    const double strokeWidth = 2.5;
    const double arrowSize = 12;

    // انحناء داخل الفراغ بين العمودين فقط: منحنى تربيعي نقطة تحكمه في المنتصف
    final mid = Offset((start.dx + end.dx) * 0.5, (start.dy + end.dy) * 0.5);

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    // رأس السهم (معطّل حالياً، الكود محفوظ للاستخدام لاحقاً)
    if (showArrows) {
      final endTangent = Offset(2 * (end.dx - mid.dx), 2 * (end.dy - mid.dy));
      final tangentLen = sqrt(
        endTangent.dx * endTangent.dx + endTangent.dy * endTangent.dy,
      );
      if (tangentLen > 0.1) {
        final unit = Offset(
          endTangent.dx / tangentLen,
          endTangent.dy / tangentLen,
        );
        final inward = Offset(-unit.dx, -unit.dy);
        final arrowPath = Path();
        arrowPath.moveTo(end.dx, end.dy);
        arrowPath.lineTo(
          end.dx + arrowSize * inward.dx - arrowSize * 0.5 * (-inward.dy),
          end.dy + arrowSize * inward.dy + arrowSize * 0.5 * (-inward.dx),
        );
        arrowPath.lineTo(
          end.dx + arrowSize * inward.dx + arrowSize * 0.5 * (-inward.dy),
          end.dy + arrowSize * inward.dy - arrowSize * 0.5 * (-inward.dx),
        );
        arrowPath.close();
        final arrowFill = Paint()..color = color;
        canvas.drawPath(arrowPath, arrowFill);
        final arrowStroke = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawPath(arrowPath, arrowStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatchLinesPainter old) {
    if (old.showArrows != showArrows || old.segments.length != segments.length) {
      return true;
    }
    for (int i = 0; i < segments.length; i++) {
      if (segments[i].start != old.segments[i].start ||
          segments[i].end != old.segments[i].end ||
          segments[i].color != old.segments[i].color) {
        return true;
      }
    }
    return false;
  }
}

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
  /// true = إظهار خطوط التوصيل بين الأزواج، false = إخفاؤها
  static const bool showConnectionLines = false;

  final Map<int, int> selectedMatches = {}; // leftOptionId -> rightOptionId
  /// ترتيب اختيار الأزواج (leftOptionId بالترتيب) لترقيم 1، 2، 3... بدون ثغرات عند الحذف
  final List<int> _selectionOrder = [];

  /// لون ثابت لكل زوج (leftOptionId -> index في الباليت)؛ يبقى حتى بعد حذف أزواج أخرى
  final Map<int, int> _pairColorIndex = {};
  int _nextColorIndex = 0;

  int? selectedLeftOptionId;
  bool isLoading = false;
  final Map<int, GlobalKey> _leftKeys = {};
  final Map<int, GlobalKey> _rightKeys = {};
  final GlobalKey _linesOverlayKey = GlobalKey();
  List<_LineSegment> _lineSegments = [];

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
    final index = _pairColorIndex[leftOptionId];
    if (index != null && palette.isNotEmpty) {
      return palette[index % palette.length];
    }
    return Theme.of(context).colorScheme.primary;
  }

  Color getColorForNewSelection(BuildContext context) {
    final palette = _matchPalette(context);
    if (palette.isNotEmpty) {
      return palette[_nextColorIndex % palette.length];
    }
    return Theme.of(context).colorScheme.primary;
  }

  /// رقم الزوج للعنصر الأيسر (1، 2، 3... حسب ترتيب الاختيار، بدون ثغرات)
  int? getPairNumberForLeft(int leftId) {
    final idx = _selectionOrder.indexOf(leftId);
    return idx >= 0 ? idx + 1 : null;
  }

  /// رقم الزوج للعنصر الأيمن (نفس رقم الشريك الأيسر)
  int? getPairNumberForRight(int rightId) {
    for (final e in selectedMatches.entries) {
      if (e.value == rightId) return getPairNumberForLeft(e.key);
    }
    return null;
  }

  GlobalKey _keyForLeft(int id) => _leftKeys.putIfAbsent(id, () => GlobalKey());
  GlobalKey _keyForRight(int id) =>
      _rightKeys.putIfAbsent(id, () => GlobalKey());

  void _updateLineSegments(BuildContext context) {
    if (!showConnectionLines || selectedMatches.isEmpty) {
      if (_lineSegments.isNotEmpty) setState(() => _lineSegments = []);
      return;
    }
    final overlayBox =
        _linesOverlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final List<_LineSegment> segments = [];
    for (final e in selectedMatches.entries) {
      final leftId = e.key;
      final rightId = e.value;
      final leftKey = _leftKeys[leftId];
      final rightKey = _rightKeys[rightId];
      final lCtx = leftKey?.currentContext;
      final rCtx = rightKey?.currentContext;
      if (lCtx == null || rCtx == null) continue;
      final leftBox = lCtx.findRenderObject() as RenderBox?;
      final rightBox = rCtx.findRenderObject() as RenderBox?;
      if (leftBox == null || rightBox == null) continue;
      // في الواجهة RTL: العمود الأول (المفردات) يظهر على اليمين، العمود الثاني (الوصف) على اليسار
      // الجهة الداخلية = التي تواجه العمود الآخر: للعمود الأول = يساره، للعمود الثاني = يمينه
      final column1Inner = leftBox.localToGlobal(
        Offset(0, leftBox.size.height * 0.5),
      );
      final column2Inner = rightBox.localToGlobal(
        Offset(rightBox.size.width, rightBox.size.height * 0.5),
      );
      final start = overlayBox.globalToLocal(column1Inner);
      final end = overlayBox.globalToLocal(column2Inner);
      segments.add(_LineSegment(start, end, getMatchColor(context, leftId)));
    }
    if (mounted) setState(() => _lineSegments = segments);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final isAnswered = widget.question.userAnswer != null;

    if (showConnectionLines && selectedMatches.isNotEmpty && !isAnswered) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateLineSegments(context),
      );
    }

    // Use API left/right columns when provided; otherwise fallback to splitting options in half
    final List<LessonQuestionOptionModel> leftOptions;
    final List<LessonQuestionOptionModel> rightOptions;
    final leftProvided =
        widget.question.leftOptions != null &&
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

          // Match grid: الخطوط تُرسم أولاً (خلف المحتوى) ثم العمودان فوقها فتظهر التوصيلات في المسافة بين العمودين فقط
          Stack(
            key: _linesOverlayKey,
            children: [
              if (showConnectionLines &&
                  selectedMatches.isNotEmpty &&
                  !isAnswered)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _MatchLinesPainter(
                        _lineSegments,
                        showArrows: false,
                      ),
                    ),
                  ),
                ),
              Column(
                key: const ValueKey('match_rows'),
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
                  final isSelectedRight =
                      selectedLeftOptionId != null &&
                      selectedMatches[selectedLeftOptionId] == rightOption.id;

                  // لون الخلية اليسرى: حسب الزوج الذي يشمله (إن وُجد)
                  final Color leftCellColor = isMatchedLeft
                      ? getMatchColor(context, leftOption.id)
                      : (isSelectedLeft
                            ? getColorForNewSelection(context)
                            : scheme.primary);
                  // لون الخلية اليمنى: حسب الزوج الذي يشمله (نفس لون الشريك الأيسر)، وليس لون الصف
                  final Color rightCellColor =
                      isMatchedRight && matchedLeftId != null
                      ? getMatchColor(context, matchedLeftId!)
                      : (isSelectedRight
                            ? getColorForNewSelection(context)
                            : scheme.primary);

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
                            .firstWhere(
                              (m) => m.rightOptionId == rightOption.id,
                            );
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
                                          _selectionOrder.remove(leftOption.id);
                                          _pairColorIndex.remove(leftOption.id);
                                          if (selectedLeftOptionId ==
                                              leftOption.id) {
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
                                key: _keyForLeft(leftOption.id),
                                padding: EdgeInsets.all(width(12)),
                                decoration: BoxDecoration(
                                  color: leftBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: leftBorder,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Align(
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
                                    if (getPairNumberForLeft(leftOption.id) !=
                                        null)
                                      Positioned(
                                        bottom: -4,
                                        left: -4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width(6),
                                            vertical: height(2),
                                          ),
                                          decoration: BoxDecoration(
                                            color: leftCellColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: leftBorder,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${getPairNumberForLeft(leftOption.id)}',
                                            style: TextStyle(
                                              fontSize: emp(12),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width(32)),
                          Expanded(
                            child: GestureDetector(
                              onTap: isAnswered
                                  ? null
                                  : () {
                                      setState(() {
                                        if (isMatchedRight &&
                                            matchedLeftId != null) {
                                          selectedMatches.remove(matchedLeftId);
                                          _selectionOrder.remove(matchedLeftId);
                                          _pairColorIndex.remove(matchedLeftId);
                                          if (selectedLeftOptionId ==
                                              matchedLeftId) {
                                            selectedLeftOptionId = null;
                                          }
                                        } else if (selectedLeftOptionId !=
                                            null) {
                                          int? existingLeftId;
                                          selectedMatches.forEach((
                                            leftId,
                                            rightId,
                                          ) {
                                            if (rightId == rightOption.id) {
                                              existingLeftId = leftId;
                                            }
                                          });
                                          if (existingLeftId != null) {
                                            selectedMatches.remove(
                                              existingLeftId,
                                            );
                                            _selectionOrder.remove(
                                              existingLeftId,
                                            );
                                            _pairColorIndex.remove(
                                              existingLeftId,
                                            );
                                          }
                                          _pairColorIndex[selectedLeftOptionId!] =
                                              _nextColorIndex++;
                                          selectedMatches[selectedLeftOptionId!] =
                                              rightOption.id;
                                          _selectionOrder.add(
                                            selectedLeftOptionId!,
                                          );
                                          selectedLeftOptionId = null;
                                        }
                                      });
                                    },
                              child: Container(
                                key: _keyForRight(rightOption.id),
                                padding: EdgeInsets.all(width(12)),
                                decoration: BoxDecoration(
                                  color: rightBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: rightBorder,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Align(
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
                                    if (getPairNumberForRight(rightOption.id) !=
                                        null)
                                      Positioned(
                                        bottom: -4,
                                        left: -4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: width(6),
                                            vertical: height(2),
                                          ),
                                          decoration: BoxDecoration(
                                            color: rightCellColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: rightBorder,
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${getPairNumberForRight(rightOption.id)}',
                                            style: TextStyle(
                                              fontSize: emp(12),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
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
