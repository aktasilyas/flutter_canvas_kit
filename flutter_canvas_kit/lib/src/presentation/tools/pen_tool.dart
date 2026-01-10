import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Standart kalem aracı.
///
/// Basınç duyarlı, yumuşak çizgiler üretir.
/// En temel ve en çok kullanılan araç.
class PenTool extends DrawingTool {
  @override
  ToolType get type => ToolType.pen;

  @override
  void onSelected(CanvasController controller) {
    super.onSelected(controller);

    // Pen ayarlarını uygula - opacity'yi tam yap
    controller.setStyle(
      controller.currentStyle.copyWith(
        type: StrokeType.pen,
        opacity: 1.0,
      ),
    );
  }
}
