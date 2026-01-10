import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';
import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Fosforlu kalem aracı.
///
/// Yarı saydam, sabit kalınlıkta çizgiler.
/// Metin vurgulama için ideal.
class HighlighterTool extends DrawingTool {
  @override
  ToolType get type => ToolType.highlighter;

  @override
  void onSelected(CanvasController controller) {
    super.onSelected(controller);

    // Highlighter ayarlarını uygula - sadece type ve opacity
    controller.setStyle(
      controller.currentStyle.copyWith(
        type: StrokeType.highlighter,
        opacity: CanvasConstants.highlighterOpacity,
      ),
    );
  }
}
