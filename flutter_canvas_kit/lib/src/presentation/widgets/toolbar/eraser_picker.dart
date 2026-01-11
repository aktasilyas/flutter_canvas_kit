import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/src/domain/enums/eraser_mode.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';

/// Silgi modu seçici.
class EraserPicker extends StatelessWidget {
  final CanvasController controller;

  const EraserPicker({super.key, required this.controller});

  /// Picker'ı gösterir.
  static void show(BuildContext context, CanvasController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EraserPicker(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(bottom: 24, top: 16, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Silgi Tipi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildOption(
            context,
            mode: EraserMode.stroke,
            icon: Icons.cleaning_services_outlined,
            title: 'Nesne Silici (Standart)',
            subtitle: 'Dokunulan çizimlerin tamamını siler.',
          ),
          _buildOption(
            context,
            mode: EraserMode.pixel,
            icon: Icons.auto_fix_high_outlined,
            title: 'Piksel Silici (Hassas)',
            subtitle: 'Sadece dokunulan kısımları siler.',
          ),
          _buildOption(
            context,
            mode: EraserMode.area,
            icon: Icons.crop_square,
            title: 'Alan Silici',
            subtitle: 'Seçilen dikdörtgen alan içindekileri siler.',
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required EraserMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = controller.eraserMode == mode;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        controller.setEraserMode(mode);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.black, width: 2)
            : BorderSide.none,
      ),
    );
  }
}
