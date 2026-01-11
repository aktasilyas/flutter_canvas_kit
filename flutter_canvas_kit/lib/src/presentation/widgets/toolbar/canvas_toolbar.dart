import 'package:flutter/material.dart';

import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/widgets/toolbar/color_picker.dart';
import 'package:flutter_canvas_kit/src/presentation/widgets/toolbar/tool_icon_painter.dart';

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
    ToolType.pencil,
    ToolType.highlighter,
    ToolType.neon,
    ToolType.dashed,
    ToolType.eraser,
    ToolType.selection,
  ];

  bool get _isHorizontal =>
      position == ToolbarPosition.top || position == ToolbarPosition.bottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(context),
        ),

        // Bottom Bar
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildBottomBar(context),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white, // Or transparent if overlay
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC1E3), // Pinkish "Tamamlandı" bg
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tamamlandı',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showUndoRedo)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: _buildUndoRedoButtons(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? Colors.white;

    return Container(
      height: 80, 
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
           // Pen Tools
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Clip to hide the bottom of the tools if they 'slide up' from a hidden area
              clipBehavior: Clip.none, 
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: _buildToolButtons(context, theme.primaryColor),
              ),
            ),
          ),
          
          const VerticalDivider(width: 1),

          // Settings (Size & Color)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSizeControls(context),
                  const SizedBox(width: 16),
                  _buildColorButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              // Constant size
              width: 40, 
              height: 100, 
              // Pop up effect
              transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.transparent, 
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildToolIcon(tool, isSelected, context),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildColorButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showColorPickerDialog(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: controller.currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: const Icon(Icons.palette, color: Colors.white, size: 20),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Renk',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for close button
                ],
              ),
            ),
             const Divider(),
             Expanded(
               child: ListView(
                 padding: const EdgeInsets.all(16),
                 children: [
                   _buildColorSection('Varsayılan', ColorPicker.defaultColorPalette),
                   const SizedBox(height: 24),
                   _buildColorSection('Renk Paleti', [
                     Colors.pinkAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.blueAccent,
                     Colors.greenAccent, Colors.tealAccent, Colors.amberAccent, Colors.deepOrangeAccent
                   ], titleAction: 'Spring'),
                   const SizedBox(height: 24),
                    _buildColorSection('Nature', [
                     Colors.green[900]!, Colors.green[700]!, Colors.green[500]!, Colors.lightGreen[400]!,
                     Colors.brown[800]!, Colors.brown[600]!, Colors.brown[400]!, Colors.orange[200]!
                   ]),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(String title, List<Color> colors, {String? titleAction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             if (titleAction != null)
               Text(titleAction, style: const TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) => _buildColorCircle(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    final isSelected = controller.currentColor.value == color.value;
    return GestureDetector(
      onTap: () {
         controller.setColor(color);
         // Navigator.pop(context); // Optional: keep open for multiple selections? User screenshot shows it as a mode.
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
           border: Border.all(
             color: isSelected ? Colors.blue : Colors.grey.shade200, 
             width: isSelected ? 3 : 1
           ),
        ),
         child: isSelected 
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : null,
      ),
    );
  }

  Widget _buildToolIcon(ToolType tool, bool isSelected, BuildContext context) {
    return ToolIconWidget(
      toolType: tool, 
      isSelected: isSelected,
      tipColor: controller.currentColor, // Pass dynamic color
    );
  }

  Widget _buildSizeControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () {
                final newWidth = (controller.currentWidth - 1).clamp(1.0, 50.0);
                controller.setStrokeWidth(newWidth);
              },
            ),
             IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {
                final newWidth = (controller.currentWidth + 1).clamp(1.0, 50.0);
                controller.setStrokeWidth(newWidth);
              },
            ),
        ],
      )
    );
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
