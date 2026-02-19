import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/constants/assets.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/core/widgets/icon_svg.dart';
import 'package:diplomasi_app/data/model/public/glossary_term_model.dart';
import 'package:flutter/material.dart';

class GlossaryTermCard extends StatefulWidget {
  final GlossaryTermModel term;
  final String? searchQuery;

  const GlossaryTermCard({super.key, required this.term, this.searchQuery});

  @override
  State<GlossaryTermCard> createState() => _GlossaryTermCardState();
}

class _GlossaryTermCardState extends State<GlossaryTermCard> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(GlossaryTermCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand/collapse based on search query or term data changes
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.term.id != widget.term.id ||
        oldWidget.term.term != widget.term.term ||
        oldWidget.term.definition != widget.term.definition) {
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
    // Auto-expand if search query matches definition
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
    final String lowerTerm = widget.term.term.toLowerCase();
    final String lowerDefinition = widget.term.definition.toLowerCase();

    final bool matchInTerm = lowerTerm.contains(lowerQuery);
    final bool matchInDefinition = lowerDefinition.contains(lowerQuery);

    // If match is in definition, expand automatically to show the match
    if (matchInDefinition) {
      if (!_isExpanded) {
        setState(() {
          _isExpanded = true;
        });
      }
    }
    // If match is ONLY in term (not in definition), collapse if expanded
    else if (matchInTerm && !matchInDefinition && _isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
    // If match is NOT in definition and NOT in term, collapse if expanded
    else if (!matchInTerm && !matchInDefinition && _isExpanded) {
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
      margin: EdgeInsets.only(bottom: height(12)),
      padding: EdgeInsets.all(width(16)),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term Title with Expand Button
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Term Title
              Expanded(
                child: RichText(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  text: _buildHighlightedText(
                    text: widget.term.term,
                    searchQuery: widget.searchQuery,
                    baseStyle: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      fontSize: emp(18),
                      fontFamily: 'itfHuwiyaArabic',
                      color: scheme.primary,
                    ),
                    highlightColor: colors.warning,
                    highlightTextColor: colors.onWarning,
                  ),
                ),
              ),
              SizedBox(width: width(12)),
              // Expand/Collapse Button
              MySvgIcon(
                path: _isExpanded
                    ? Assets.icons.svg.minus
                    : Assets.icons.svg.plus,
                size: emp(24),
                color: scheme.primary,
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
          // Definition with Animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.only(top: height(12)),
                    child: RichText(
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      text: _buildHighlightedText(
                        text: widget.term.definition,
                        searchQuery: widget.searchQuery,
                        baseStyle: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w400,
                          fontSize: emp(14),
                          color: scheme.onSurface,
                          height: 1.5,
                          fontFamily: 'itfHuwiyaArabic',
                        ),
                        highlightColor: colors.warning,
                        highlightTextColor: colors.onWarning,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
