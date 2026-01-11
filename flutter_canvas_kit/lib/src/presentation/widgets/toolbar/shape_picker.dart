import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';

class ShapePicker extends StatelessWidget {
  final CanvasController controller;
  final VoidCallback? onClose;

  const ShapePicker({
    super.key,
    required this.controller,
    this.onClose,
  });

  static void show(BuildContext context, CanvasController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShapePicker(
        controller: controller,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                  onPressed: onClose,
                ),
                const Expanded(
                  child: Text(
                    'Şekiller',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48), // Balance
              ],
            ),
          ),
          const Divider(),
          
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection('Temel Şekiller', [
                      ShapeType.line,
                      ShapeType.arrow,
                      ShapeType.rectangle,
                      ShapeType.circle,
                      ShapeType.triangle,
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Diğer', [
                       ShapeType.roundedRectangle,
                       ShapeType.square,
                       ShapeType.ellipse,
                       ShapeType.star,
                    ]),
                     const SizedBox(height: 24),
                    _buildFillOption(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<ShapeType> shapes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: shapes.map((type) => _buildShapeOption(type)).toList(),
        ),
      ],
    );
  }

  Widget _buildShapeOption(ShapeType type) {
    final isSelected = controller.currentShapeType == type;
    return GestureDetector(
      onTap: () {
        controller.setShapeType(type);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          _getShapeIcon(type),
          color: isSelected ? Colors.blue : Colors.black87,
          size: 30,
        ),
      ),
    );
  }
  
  Widget _buildFillOption() {
     return SwitchListTile(
       title: const Text('Şekli Doldur', style: TextStyle(fontWeight: FontWeight.bold)),
       subtitle: const Text('Şeklin içini seçili renkle doldurur'),
       value: controller.shapeFilled, 
       onChanged: (val) => controller.setShapeFilled(val),
       secondary: Icon(controller.shapeFilled ? Icons.format_color_fill : Icons.check_box_outline_blank),
     );
  }

  IconData _getShapeIcon(ShapeType type) {
    return switch (type) {
      ShapeType.line => Icons.horizontal_rule,
      ShapeType.arrow => Icons.arrow_right_alt,
      ShapeType.rectangle => Icons.crop_square,
      ShapeType.circle => Icons.circle_outlined,
      ShapeType.triangle => Icons.change_history,
      ShapeType.star => Icons.star_border,
      ShapeType.polygon => Icons.hexagon_outlined,
      ShapeType.roundedRectangle => Icons.crop_free, // Approximation
      ShapeType.square => Icons.square_outlined,
      ShapeType.ellipse => Icons.egg_outlined, // Approximation
       _ => Icons.category,
    };
  }
}
