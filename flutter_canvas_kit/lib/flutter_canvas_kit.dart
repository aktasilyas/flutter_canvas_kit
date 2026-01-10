/// Flutter Canvas Kit - Professional drawing library for Flutter.
///
/// A comprehensive canvas/drawing library with:
/// - Multi-layer support
/// - Various drawing tools (pen, highlighter, pencil, eraser, shapes)
/// - Undo/Redo functionality
/// - Zoom and pan
/// - Export to PNG/SVG/JSON
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_canvas_kit/flutter_canvas_kit.dart';
///
/// // Create a controller
/// final controller = CanvasController();
///
/// // Use in your widget tree
/// CanvasWidget(
///   controller: controller,
///   config: const CanvasConfig(),
/// )
/// ```
library flutter_canvas_kit;

// =============================================================================
// CORE
// =============================================================================

export 'src/core/constants/canvas_constants.dart';
export 'src/core/errors/canvas_exception.dart';
export 'src/core/extensions/color_extension.dart';
export 'src/core/extensions/offset_extension.dart';
export 'src/core/extensions/rect_extension.dart';
export 'src/data/export/png_exporter.dart';
export 'src/data/export/svg_exporter.dart';
// =============================================================================
// DATA - SERIALIZATION & EXPORT
// =============================================================================

export 'src/data/serialization/document_serializer.dart';
// =============================================================================
// DOMAIN - ENTITIES
// =============================================================================

export 'src/domain/entities/canvas_document.dart';
export 'src/domain/entities/canvas_page.dart';
export 'src/domain/entities/image_element.dart';
export 'src/domain/entities/layer.dart';
export 'src/domain/entities/shape.dart';
export 'src/domain/entities/stroke.dart';
export 'src/domain/entities/text_element.dart';
export 'src/domain/enums/blend_mode.dart';
export 'src/domain/enums/page_background.dart';
export 'src/domain/enums/page_size.dart';
export 'src/domain/enums/shape_type.dart';
export 'src/domain/enums/stroke_type.dart';
// =============================================================================
// DOMAIN - ENUMS
// =============================================================================

export 'src/domain/enums/tool_type.dart';
// =============================================================================
// DOMAIN - VALUE OBJECTS
// =============================================================================

export 'src/domain/value_objects/stroke_point.dart';
export 'src/domain/value_objects/stroke_style.dart';
// =============================================================================
// PRESENTATION - CANVAS
// =============================================================================

export 'src/presentation/canvas/canvas_config.dart';
export 'src/presentation/canvas/canvas_theme.dart';
// =============================================================================
// PRESENTATION - CONTROLLERS
// =============================================================================

export 'src/presentation/controllers/canvas_controller.dart';
export 'src/presentation/controllers/history_manager.dart';
// =============================================================================
// PRESENTATION - PAINTERS
// =============================================================================

export 'src/presentation/painters/canvas_painter.dart';
export 'src/presentation/tools/eraser_tool.dart';
export 'src/presentation/tools/highlighter_tool.dart';
export 'src/presentation/tools/pen_tool.dart';
export 'src/presentation/tools/pencil_tool.dart';
export 'src/presentation/tools/selection_tool.dart';
export 'src/presentation/tools/shape_tool.dart';
// =============================================================================
// PRESENTATION - TOOLS
// =============================================================================

export 'src/presentation/tools/tool.dart';
// =============================================================================
// PRESENTATION - WIDGETS
// =============================================================================

export 'src/presentation/widgets/canvas_widget.dart';
export 'src/presentation/widgets/layers/layer_panel.dart';
export 'src/presentation/widgets/toolbar/canvas_toolbar.dart';
export 'src/presentation/widgets/toolbar/color_picker.dart';
export 'src/presentation/widgets/toolbar/stroke_width_slider.dart';
