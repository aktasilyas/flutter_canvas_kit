import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Tükenmez kalem aracı.
///
/// Sabit kalınlık, basınçtan etkilenmez.
/// Tutarlı, düzgün çizgiler için ideal.
class BallPenTool extends DrawingTool {
  @override
  ToolType get type => ToolType.pen;

  @override
  void onSelected(CanvasController controller) {
    super.onSelected(controller);

    controller.setStyle(
      controller.currentStyle.copyWith(
        type: StrokeType.ballPen,
        opacity: 1.0,
      ),
    );
  }
}
