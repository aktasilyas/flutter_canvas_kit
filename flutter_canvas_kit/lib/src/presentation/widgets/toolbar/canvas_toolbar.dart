import 'package:flutter/material.dart';

import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';

/// Toolbar konumu.
enum ToolbarPosition {
  top,
  bottom,
  left,
  right,
}

/// Canvas araç çubuğu.
class CanvasToolbar extends StatelessWidget {
  /// Canvas kontrolcüsü.
  final CanvasController controller;

  /// Toolbar konumu.
  final ToolbarPosition position;

  /// Gösterilecek araçlar.
  final List<ToolType>? tools;

  /// Toolbar yüksekliği.
  final double height;

  /// Arka plan rengi.
  final Color? backgroundColor;

  /// Seçili araç arka plan rengi.
  final Color? selectedColor;

  /// Undo/Redo butonları gösterilsin mi?
  final bool showUndoRedo;

  const CanvasToolbar({
    super.key,
    required this.controller,
    this.position = ToolbarPosition.bottom,
    this.tools,
    this.height = 56.0,
    this.backgroundColor,
    this.selectedColor,
    this.showUndoRedo = true,
  });

  /// Varsayılan araç listesi.
  static const List<ToolType> defaultTools = [
    ToolType.pen,
    ToolType.highlighter,
    ToolType.pencil,
    ToolType.eraser,
    ToolType.selection,
  ];

  bool get _isHorizontal =>
      position == ToolbarPosition.top || position == ToolbarPosition.bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final selColor = selectedColor ?? theme.colorScheme.primaryContainer;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          height: _isHorizontal ? height : null,
          width: _isHorizontal ? null : height,
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: position == ToolbarPosition.bottom
                    ? const Offset(0, -2)
                    : const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: _isHorizontal
                ? _buildHorizontalToolbar(context, selColor)
                : _buildVerticalToolbar(context, selColor),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalToolbar(BuildContext context, Color selColor) {
    return Row(
      children: [
        if (showUndoRedo) ...[
          _buildUndoRedoButtons(context),
          const VerticalDivider(width: 16),
        ],
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildToolButtons(context, selColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalToolbar(BuildContext context, Color selColor) {
    return Column(
      children: [
        if (showUndoRedo) ...[
          _buildUndoRedoButtons(context, vertical: true),
          const Divider(height: 16),
        ],
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildToolButtons(context, selColor),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildToolButtons(BuildContext context, Color selColor) {
    final toolList = tools ?? defaultTools;

    return toolList.map((tool) {
      final isSelected = controller.currentTool == tool;

      return Tooltip(
        message: tool.displayName,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectTool(tool),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: height - 8,
              height: height - 8,
              decoration: BoxDecoration(
                color: isSelected ? selColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getToolIcon(tool),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  IconData _getToolIcon(ToolType tool) {
    return switch (tool) {
      ToolType.pen => Icons.edit,
      ToolType.highlighter => Icons.highlight,
      ToolType.pencil => Icons.create,
      ToolType.eraser => Icons.auto_fix_normal,
      ToolType.shape => Icons.category,
      ToolType.text => Icons.text_fields,
      ToolType.image => Icons.image,
      ToolType.selection => Icons.touch_app,
      ToolType.lasso => Icons.gesture,
      ToolType.hand => Icons.pan_tool,
    };
  }

  Widget _buildUndoRedoButtons(BuildContext context, {bool vertical = false}) {
    final children = [
      IconButton(
        icon: const Icon(Icons.undo),
        onPressed: controller.canUndo ? controller.undo : null,
        tooltip: 'Undo',
      ),
      IconButton(
        icon: const Icon(Icons.redo),
        onPressed: controller.canRedo ? controller.redo : null,
        tooltip: 'Redo',
      ),
    ];

    return vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: children)
        : Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
