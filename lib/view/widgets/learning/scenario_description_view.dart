import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:diplomasi_app/data/model/learning/scenario_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;

class ScenarioDescriptionView extends StatelessWidget {
  final ScenarioModel scenario;
  final VoidCallback onContinue;
  final VoidCallback? onShowAttempts;
  final bool isLoading;

  const ScenarioDescriptionView({
    super.key,
    required this.scenario,
    required this.onContinue,
    this.onShowAttempts,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(width(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            scenario.title,
            style: TextStyle(
              fontSize: emp(24),
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: height(20)),

          // Description (HTML)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(width(16)),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: scenario.description.isNotEmpty
                ? html.Html(
                    data: scenario.description,
                    style: {
                      "body": html.Style(
                        margin: html.Margins.zero,
                        padding: html.HtmlPaddings.zero,
                        fontSize: html.FontSize(emp(16)),
                        color: scheme.onSurface,
                        lineHeight: html.LineHeight(1.6),
                      ),
                      "p": html.Style(
                        margin: html.Margins.only(bottom: 12),
                      ),
                      "h1": html.Style(
                        fontSize: html.FontSize(emp(24)),
                        fontWeight: FontWeight.bold,
                        margin: html.Margins.only(bottom: 16),
                      ),
                      "h2": html.Style(
                        fontSize: html.FontSize(emp(20)),
                        fontWeight: FontWeight.bold,
                        margin: html.Margins.only(bottom: 14),
                      ),
                      "h3": html.Style(
                        fontSize: html.FontSize(emp(18)),
                        fontWeight: FontWeight.bold,
                        margin: html.Margins.only(bottom: 12),
                      ),
                    },
                  )
                : Text(
                    'لا يوجد وصف متاح',
                    style: TextStyle(
                      fontSize: emp(16),
                      color: colors.textSecondary,
                    ),
                  ),
          ),

          SizedBox(height: height(32)),

          if (onShowAttempts != null) ...[
            SizedBox(
              width: double.infinity,
              height: height(44),
              child: OutlinedButton.icon(
                onPressed: onShowAttempts,
                icon: const Icon(Icons.history),
                label: const Text('عرض المحاولات السابقة'),
              ),
            ),
            SizedBox(height: height(12)),
          ],

          // Continue button
          Container(
            width: double.infinity,
            height: height(48),
            decoration: BoxDecoration(
              color: isLoading
                  ? scheme.primary.withOpacity(0.6)
                  : scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: isLoading ? null : onContinue,
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
                          'استمرار',
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

          SizedBox(height: height(20)),
        ],
      ),
    );
  }
}

