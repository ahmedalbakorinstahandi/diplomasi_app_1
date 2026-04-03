import 'package:cached_network_image/cached_network_image.dart';
import 'package:diplomasi_app/core/constants/app_colors.dart';
import 'package:diplomasi_app/core/functions/size.dart';
import 'package:flutter/material.dart';

void _showImagePreviewDialog(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.88),
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: width(12),
          vertical: height(28),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: Colors.black,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, _) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                      errorWidget: (context, _, __) => Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: width(40),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: width(8),
              right: width(8),
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Padding(
                    padding: EdgeInsets.all(width(6)),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: width(18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class QuestionTextWithAttachment extends StatelessWidget {
  final String text;
  final String? imageUrl;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final double? textMinHeight;
  final int? textMaxLines;
  final bool pinImageToBottom;
  final double imageHeight;
  final BoxFit imageFit;
  final double? imageAspectRatio;
  final double? imageWidth;
  final double? imageWidthFactor;
  final bool reserveImageSpace;
  final Alignment imageAlignment;
  final Color? imageBackgroundColor;
  final bool enableImagePreview;

  const QuestionTextWithAttachment({
    super.key,
    required this.text,
    required this.imageUrl,
    required this.textStyle,
    this.textAlign = TextAlign.right,
    this.textMinHeight,
    this.textMaxLines,
    this.pinImageToBottom = false,
    required this.imageHeight,
    this.imageFit = BoxFit.cover,
    this.imageAspectRatio,
    this.imageWidth,
    this.imageWidthFactor,
    this.reserveImageSpace = false,
    this.imageAlignment = Alignment.centerRight,
    this.imageBackgroundColor,
    this.enableImagePreview = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = text.trim().isNotEmpty;
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;
    final shouldShowImage = hasImage || reserveImageSpace;
    final textWidget = Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: textMaxLines,
      overflow: textMaxLines != null ? TextOverflow.ellipsis : null,
    );

    Widget imageSlot() {
      if (hasImage) {
        return AttachmentImageFrame(
          imageUrl: imageUrl!.trim(),
          imageHeight: imageHeight,
          imageFit: imageFit,
          imageAspectRatio: imageAspectRatio,
          imageWidth: imageWidth,
          imageWidthFactor: imageWidthFactor,
          imageAlignment: imageAlignment,
          imageBackgroundColor: imageBackgroundColor,
          enableImagePreview: enableImagePreview,
        );
      }
      return Align(
        alignment: imageAlignment,
        child: FractionallySizedBox(
          widthFactor: imageWidthFactor,
          child: SizedBox(
            height: imageHeight,
            width:
                imageWidth ??
                (imageAspectRatio != null && imageAspectRatio! > 0
                    ? imageHeight * imageAspectRatio!
                    : double.infinity),
          ),
        ),
      );
    }

    if (pinImageToBottom && shouldShowImage) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasText)
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: textMinHeight ?? 0),
                    child: textWidget,
                  ),
                ),
              ),
            if (!hasText) const Spacer(),
            if (hasText) SizedBox(height: height(7)),
            imageSlot(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasText)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: textMinHeight ?? 0),
            child: textWidget,
          ),
        if (shouldShowImage) ...[
          if (hasText) SizedBox(height: height(8)),
          imageSlot(),
        ],
      ],
    );
  }
}

class AttachmentImageFrame extends StatelessWidget {
  final String imageUrl;
  final double? imageHeight;
  final BoxFit imageFit;
  final double? imageAspectRatio;
  final double? imageWidth;
  final double? imageWidthFactor;
  final Alignment imageAlignment;
  final Color? imageBackgroundColor;
  final bool enableImagePreview;

  const AttachmentImageFrame({
    super.key,
    required this.imageUrl,
    this.imageHeight,
    required this.imageFit,
    required this.imageAspectRatio,
    required this.imageWidth,
    required this.imageWidthFactor,
    required this.imageAlignment,
    required this.imageBackgroundColor,
    required this.enableImagePreview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final frameHeight = imageHeight ?? height(180);

    final imageWithPreviewButton = GestureDetector(
      onTap: enableImagePreview
          ? () => _showImagePreviewDialog(context, imageUrl)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: imageBackgroundColor ?? colors.backgroundSecondary,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: imageFit,
                placeholder: (context, _) => Center(
                  child: SizedBox(
                    width: width(20),
                    height: width(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, _, __) => Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.textSecondary,
                  size: width(28),
                ),
              ),
            ),
          ),
          if (enableImagePreview)
            Positioned(
              top: width(6),
              left: width(6),
              child: Material(
                color: Colors.black38,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _showImagePreviewDialog(context, imageUrl),
                  child: Padding(
                    padding: EdgeInsets.all(width(5)),
                    child: Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: width(15),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget frame = SizedBox(
      width: imageWidth ?? double.infinity,
      height: frameHeight,
      child: imageWithPreviewButton,
    );

    if (imageAspectRatio != null &&
        imageAspectRatio! > 0 &&
        imageWidth == null) {
      frame = AspectRatio(
        aspectRatio: imageAspectRatio!,
        child: imageWithPreviewButton,
      );
    }

    if (imageWidthFactor != null) {
      frame = FractionallySizedBox(widthFactor: imageWidthFactor, child: frame);
    }

    return Align(alignment: imageAlignment, child: frame);
  }
}
