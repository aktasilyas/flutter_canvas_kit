import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'dart:math' as math;

class ToolIconWidget extends StatelessWidget {
  final ToolType toolType;
  final bool isSelected;
  final Color? tipColor;
  final ShapeType? shapeType;

  const ToolIconWidget({
    super.key,
    required this.toolType,
    required this.isSelected,
    this.tipColor,
    this.shapeType,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ToolPainter(
        toolType: toolType,
        isSelected: isSelected,
        tipColor: tipColor ?? Colors.black,
        shapeType: shapeType,
      ),
      size: const Size(40, 100), // Base aspect ratio
    );
  }
}

class _ToolPainter extends CustomPainter {
  final ToolType toolType;
  final bool isSelected;
  final Color tipColor;
  final ShapeType? shapeType;

  _ToolPainter({
    required this.toolType,
    required this.isSelected,
    required this.tipColor,
    this.shapeType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw consistent base body for all "pen-like" tools (including shape tool)
    // Eraser is unique block
    if (toolType != ToolType.eraser) {
       _paintCommonBody(canvas, w, h);
    }

    switch (toolType) {
      case ToolType.pen:
        _paintPenTip(canvas, w, h);
        break;
      case ToolType.pencil:
        _paintPencilTip(canvas, w, h);
        break;
      case ToolType.highlighter:
        _paintHighlighterTip(canvas, w, h);
        break;
      case ToolType.neon:
        _paintNeonTip(canvas, w, h);
        break;
      case ToolType.dashed:
        _paintDashedTip(canvas, w, h);
        break;
      case ToolType.shape:
        _paintShapeTip(canvas, w, h);
        break;
      case ToolType.eraser:
        _paintEraser(canvas, w, h);
        break;
      default:
        _paintGeneric(canvas, w, h);
    }
  }

  // ... (Previous methods: _paintCommonBody, _paintPenTip, etc. remain unchanged) ...

  void _paintShapeTip(Canvas canvas, double w, double h) {
    // A technical drawing pen tip or just the shape icon on the body
    
    // Draw a generic technical circular tip
    final tipRect = Rect.fromLTWH(w * 0.35, h * 0.05, w * 0.3, h * 0.15);
    canvas.drawRect(tipRect, Paint()..color = Colors.black87);
    
    // Draw the specific shape icon on the body
    final iconPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.25;

    if (shapeType != null) {
      switch (shapeType!) {
        case ShapeType.rectangle:
        case ShapeType.square:
        case ShapeType.roundedRectangle:
           canvas.drawRect(Rect.fromCircle(center: center, radius: radius * 0.8), iconPaint);
           break;
        case ShapeType.circle:
        case ShapeType.ellipse:
           canvas.drawCircle(center, radius * 0.8, iconPaint);
           break;
        case ShapeType.triangle:
           final path = Path()
             ..moveTo(center.dx, center.dy - radius * 0.8)
             ..lineTo(center.dx + radius * 0.8, center.dy + radius * 0.8)
             ..lineTo(center.dx - radius * 0.8, center.dy + radius * 0.8)
             ..close();
           canvas.drawPath(path, iconPaint);
           break;
        case ShapeType.line:
           canvas.drawLine(Offset(center.dx - radius, center.dy + radius), Offset(center.dx + radius, center.dy - radius), iconPaint);
           break; 
        case ShapeType.star:
           // Simple 5-point star
           final path = Path();
           final outerR = radius;
           final innerR = radius * 0.4;
           final step = math.pi / 5;
           
           path.moveTo(center.dx, center.dy - outerR);
           for (int i = 1; i <= 10; i++) {
              final r = i % 2 == 0 ? outerR : innerR;
              final angle = -math.pi / 2 + step * i;
              path.lineTo(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
           }
           path.close();
           canvas.drawPath(path, iconPaint);
           break;
        case ShapeType.polygon:
           // Simple Hexagon (default polygon)
           final path = Path();
           final steps = 6;
           final stepAngle = (math.pi * 2) / steps;
           
           path.moveTo(center.dx + radius * math.cos(-math.pi / 2), center.dy + radius * math.sin(-math.pi / 2));
           for (int i = 1; i < steps; i++) {
              final angle = -math.pi / 2 + stepAngle * i;
              path.lineTo(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
           }
           path.close();
           canvas.drawPath(path, iconPaint);
           break;
        case ShapeType.arrow:
           final p1 = Offset(center.dx - radius * 0.8, center.dy);
           final p2 = Offset(center.dx + radius * 0.8, center.dy);
           canvas.drawLine(p1, p2, iconPaint);
           // Arrow head
           final headSize = radius * 0.4;
           canvas.drawLine(p2, Offset(p2.dx - headSize, p2.dy - headSize * 0.6), iconPaint);
           canvas.drawLine(p2, Offset(p2.dx - headSize, p2.dy + headSize * 0.6), iconPaint);
           break;
        default:
           // Generic
           canvas.drawRect(Rect.fromCircle(center: center, radius: radius * 0.7), iconPaint);
           canvas.drawCircle(center, radius * 0.4, iconPaint);
      }
    } else {
       // Tool without selection (shouldn't happen for Shape tool in theory if defaults are set)
       canvas.drawRect(Rect.fromCircle(center: center, radius: radius * 0.6), iconPaint);
       canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), iconPaint);
       canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), iconPaint);
    }
  }

  void _paintCommonBody(Canvas canvas, double w, double h) {
    // White uniform body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Slight gradient for 3D cylinder effect
    final gradientShader = const LinearGradient(
      colors: [Color(0xFFEEEEEE), Colors.white, Color(0xFFE0E0E0)],
      stops: [0.0, 0.4, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Make body extend fully to bottom with flat bottom corners
    final bodyRect = Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.8); 
    // Rounded top, Flat bottom
    final rrect = RRect.fromRectAndCorners(
      bodyRect, 
      topLeft: Radius.circular(w*0.35), 
      topRight: Radius.circular(w*0.35),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero
    );

    canvas.drawRRect(rrect.shift(const Offset(1, 1)), shadowPaint);
    canvas.drawRRect(rrect, Paint()..shader = gradientShader);
  }

  void _paintPenTip(Canvas canvas, double w, double h) {
    // Silver section
    final silverPaint = Paint()..color = const Color(0xFF9E9E9E);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.08), silverPaint);

    // Nib
    final path = Path()
      ..moveTo(w * 0.35, h * 0.2)
      ..lineTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.65, h * 0.2)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF333333));
    
    // Ink color indicator
    canvas.drawCircle(Offset(w*0.5, h*0.5), w*0.15, Paint()..color = tipColor);
  }

  void _paintPencilTip(Canvas canvas, double w, double h) {
    // Wood cone
    final woodPaint = Paint()..color = const Color(0xFFDEB887);
    final conePath = Path()
      ..moveTo(w * 0.15, h * 0.2)
      ..lineTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.85, h * 0.2)
      ..close();
    canvas.drawPath(conePath, woodPaint);

    // Graphite tip
    final graphitePath = Path()
      ..moveTo(w * 0.42, h * 0.06)
      ..lineTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.58, h * 0.06)
      ..close();
    canvas.drawPath(graphitePath, Paint()..color = const Color(0xFF333333));
  }

  void _paintHighlighterTip(Canvas canvas, double w, double h) {
    // Chisel tip paint
    final paint = Paint()..color = tipColor;
    final path = Path()
      ..moveTo(w * 0.2, h * 0.2)
      ..lineTo(w * 0.2, h * 0.1)
      ..lineTo(w * 0.8, h * 0.05) // Slanted
      ..lineTo(w * 0.8, h * 0.2)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintNeonTip(Canvas canvas, double w, double h) {
    // Darker top section
    canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(w*0.15, h*0.2, w*0.7, h*0.1), 
        topLeft: Radius.circular(w*0.35), topRight: Radius.circular(w*0.35)), 
        Paint()..color = const Color(0xFF263238));

    // Glowing strip
    final glowPaint = Paint()
      ..color = tipColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRect(Rect.fromLTWH(w*0.4, h*0.1, w*0.2, h*0.6), glowPaint);
    canvas.drawRect(Rect.fromLTWH(w*0.45, h*0.1, w*0.1, h*0.6), Paint()..color = Colors.white);
  }

  void _paintDashedTip(Canvas canvas, double w, double h) {
    // Technical pen tip
    final silverPaint = Paint()..color = const Color(0xFFB0BEC5);
    final smallTip = Rect.fromLTWH(w*0.4, h*0.05, w*0.2, h*0.15);
    canvas.drawRect(smallTip, silverPaint);
    canvas.drawLine(Offset(w*0.5, h*0.05), Offset(w*0.5, h*0.15), Paint()..color=Colors.black..strokeWidth=1);

    // Dashes on body
    final dashPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    canvas.drawLine(Offset(w*0.5, h*0.3), Offset(w*0.5, h*0.4), dashPaint);
    canvas.drawLine(Offset(w*0.5, h*0.45), Offset(w*0.5, h*0.55), dashPaint);
    canvas.drawLine(Offset(w*0.5, h*0.6), Offset(w*0.5, h*0.7), dashPaint);
  }

  void _paintEraser(Canvas canvas, double w, double h) {
    // White uniform body (Rectangular)
    final bodyPaint = Paint()..color = Colors.white;
    // Slight shadow
    final shadowPaint = Paint()..color = Colors.black12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final rect = Rect.fromLTWH(w*0.1, h*0.2, w*0.8, h*0.6);
    canvas.drawRect(rect.shift(const Offset(1,1)), shadowPaint);
    canvas.drawRect(rect, bodyPaint);

    // Pink tip
    canvas.drawRect(Rect.fromLTWH(w*0.1, h*0.1, w*0.8, h*0.1), Paint()..color = const Color(0xFFEF9A9A));
    
    // Label
    final textPainter = TextPainter(
      text: const TextSpan(text: "SILGI", style: TextStyle(color: Colors.grey, fontSize: 8)),
      textDirection: TextDirection.ltr
    )..layout();
    
    canvas.save();
    canvas.translate(w*0.5, h*0.5);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(canvas, Offset(-textPainter.width/2, -textPainter.height/2));
    canvas.restore();
  }

  void _paintGeneric(Canvas canvas, double w, double h) {
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.3, Paint()..color = Colors.grey);
  }

  @override
  bool shouldRepaint(covariant _ToolPainter oldDelegate) {
    return oldDelegate.toolType != toolType ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.tipColor != tipColor ||
        oldDelegate.shapeType != shapeType;
  }
}
