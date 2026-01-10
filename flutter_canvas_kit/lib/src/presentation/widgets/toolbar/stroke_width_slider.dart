import 'package:flutter/material.dart';

import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';

/// Çizgi kalınlığı slider'ı.
class StrokeWidthSlider extends StatelessWidget {
  /// Mevcut kalınlık değeri.
  final double value;

  /// Değer değiştiğinde callback.
  final ValueChanged<double> onChanged;

  /// Minimum kalınlık.
  final double min;

  /// Maksimum kalınlık.
  final double max;

  /// Çizgi rengi (preview için).
  final Color? color;

  /// Preview gösterilsin mi?
  final bool showPreview;

  /// Label gösterilsin mi?
  final bool showLabel;

  const StrokeWidthSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = CanvasConstants.minStrokeWidth,
    this.max = CanvasConstants.maxStrokeWidth,
    this.color,
    this.showPreview = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPreview)
          Container(
            height: 60,
            alignment: Alignment.center,
            child: CustomPaint(
              size: const Size(200, 40),
              painter: _StrokePreviewPainter(
                strokeWidth: value,
                color: color ?? Colors.black,
              ),
            ),
          ),
        Row(
          children: [
            if (showLabel)
              SizedBox(
                width: 32,
                child: Text(
                  min.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
            if (showLabel)
              SizedBox(
                width: 32,
                child: Text(
                  max.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        if (showLabel)
          Center(
            child: Text(
              '${value.toStringAsFixed(1)} px',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }
}

/// Preview painter.
class _StrokePreviewPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  _StrokePreviewPainter({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startY = size.height / 2;

    path.moveTo(20, startY);

    path.cubicTo(
      size.width * 0.25,
      startY - 15,
      size.width * 0.35,
      startY + 15,
      size.width * 0.5,
      startY,
    );
    path.cubicTo(
      size.width * 0.65,
      startY - 15,
      size.width * 0.75,
      startY + 15,
      size.width - 20,
      startY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StrokePreviewPainter oldDelegate) {
    return strokeWidth != oldDelegate.strokeWidth || color != oldDelegate.color;
  }
}

/// Stroke width dialog.
Future<double?> showStrokeWidthDialog({
  required BuildContext context,
  required double initialValue,
  double min = CanvasConstants.minStrokeWidth,
  double max = CanvasConstants.maxStrokeWidth,
  Color? color,
}) async {
  return showDialog<double>(
    context: context,
    builder: (context) {
      double currentValue = initialValue;

      return AlertDialog(
        title: const Text('Stroke Width'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return StrokeWidthSlider(
              value: currentValue,
              onChanged: (v) => setState(() => currentValue = v),
              min: min,
              max: max,
              color: color,
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, currentValue),
            child: const Text('Apply'),
          ),
        ],
      );
    },
  );
}
