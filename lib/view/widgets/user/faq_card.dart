import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/user/faq_model.dart';
import 'package:flutter/material.dart';

class FaqCard extends StatefulWidget {
  const FaqCard({
    super.key,
    required this.faq,
    this.searchQuery,
  });
  final FaqModel faq;
  final String? searchQuery;

  @override
  State<FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(FaqCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand/collapse based on search query or FAQ data changes
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.faq.id != widget.faq.id ||
        oldWidget.faq.question != widget.faq.question ||
        oldWidget.faq.answer != widget.faq.answer) {
      // Use post frame callback to ensure state updates happen after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateExpansionState();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-expand if search query matches answer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateExpansionState();
      }
    });
  }

  /// Updates expansion state based on search query
  void _updateExpansionState() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      // No search query, don't change expansion state
      return;
    }

    final String lowerQuery = widget.searchQuery!.toLowerCase();
    final String lowerQuestion = widget.faq.question.toLowerCase();
    final String lowerAnswer = widget.faq.answer.toLowerCase();

    final bool matchInQuestion = lowerQuestion.contains(lowerQuery);
    final bool matchInAnswer = lowerAnswer.contains(lowerQuery);

    // If match is in answer, expand automatically to show the match
    if (matchInAnswer) {
      if (!_isExpanded) {
        setState(() {
          _isExpanded = true;
        });
      }
    }
    // If match is ONLY in question (not in answer), collapse if expanded
    else if (matchInQuestion && !matchInAnswer && _isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
    // If match is NOT in answer and NOT in question, collapse if expanded
    else if (!matchInQuestion && !matchInAnswer && _isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  /// Builds highlighted text with search query matching
  TextSpan _buildHighlightedText({
    required String text,
    required String? searchQuery,
    required TextStyle baseStyle,
    required Color highlightColor,
    required Color highlightTextColor,
  }) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    while (start < text.length) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // No more matches, add remaining text
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }

      // Add highlighted match
      final int end = index + searchQuery.length;
      spans.add(
        TextSpan(
          text: text.substring(index, end),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor,
            color: highlightTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      start = end;
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: height(16)),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(width(16)),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Section (Always Visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(width(16)),
            child: Padding(
              padding: EdgeInsets.all(width(16)),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      text: _buildHighlightedText(
                        text: widget.faq.question,
                        searchQuery: widget.searchQuery,
                        baseStyle: TextStyle(
                          fontSize: emp(16),
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                          height: 1.4,
                        ),
                        highlightColor: colors.warning,
                        highlightTextColor: colors.onWarning,
                      ),
                    ),
                  ),
                  SizedBox(width: width(12)),
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: width(24),
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Answer Section (Expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.only(
                      left: width(16),
                      right: width(16),
                      bottom: width(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divider
                        Divider(
                          color: colors.borderStrong,
                          height: height(1),
                        ),
                        SizedBox(height: height(12)),
                        // Answer Text
                        RichText(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          text: _buildHighlightedText(
                            text: widget.faq.answer,
                            searchQuery: widget.searchQuery,
                            baseStyle: TextStyle(
                              fontSize: emp(14),
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                              height: 1.6,
                            ),
                            highlightColor: colors.warning,
                            highlightTextColor: colors.onWarning,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
