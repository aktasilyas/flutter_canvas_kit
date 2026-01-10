import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Kurşun kalem aracı.
///
/// Yüksek basınç hassasiyeti, daha az yumuşatma.
/// Doğal, eskiz benzeri çizgiler.
class PencilTool extends DrawingTool {
  @override
  ToolType get type => ToolType.pencil;

  @override
  void onSelected(CanvasController controller) {
    super.onSelected(controller);

    // Pencil ayarlarını uygula
    controller.setStyle(
      controller.currentStyle.copyWith(
        type: StrokeType.pencil,
        opacity: 0.85,
      ),
    );
  }
}
