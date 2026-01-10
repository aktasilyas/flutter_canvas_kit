import 'package:flutter/material.dart';

/// Basit renk seçici widget.
class ColorPicker extends StatelessWidget {
  /// Seçili renk.
  final Color selectedColor;

  /// Renk seçildiğinde callback.
  final ValueChanged<Color> onColorSelected;

  /// Renk paleti.
  final List<Color>? colors;

  /// Renk boyutu.
  final double colorSize;

  /// Aralık.
  final double spacing;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.colors,
    this.colorSize = 36,
    this.spacing = 8,
  });

  /// Varsayılan renk paleti.
  static const List<Color> defaultColorPalette = [
    Color(0xFF000000), // Siyah
    Color(0xFF424242), // Koyu gri
    Color(0xFF757575), // Gri
    Color(0xFFBDBDBD), // Açık gri
    Color(0xFFFFFFFF), // Beyaz
    Color(0xFFF44336), // Kırmızı
    Color(0xFFE91E63), // Pembe
    Color(0xFF9C27B0), // Mor
    Color(0xFF673AB7), // Koyu mor
    Color(0xFF3F51B5), // İndigo
    Color(0xFF2196F3), // Mavi
    Color(0xFF03A9F4), // Açık mavi
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Yeşil
    Color(0xFF8BC34A), // Açık yeşil
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Sarı
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Turuncu
    Color(0xFFFF5722), // Koyu turuncu
    Color(0xFF795548), // Kahverengi
  ];

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? defaultColorPalette;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: palette.map((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();

        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: colorSize,
            height: colorSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _contrastColor(color),
                    size: colorSize * 0.5,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Renk seçici dialog.
Future<Color?> showColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
  List<Color>? colors,
  String title = 'Select Color',
}) async {
  return showDialog<Color>(
    context: context,
    builder: (context) {
      Color selected = initialColor;

      return AlertDialog(
        title: Text(title),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  selectedColor: selected,
                  onColorSelected: (color) {
                    setState(() => selected = color);
                  },
                  colors: colors,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Select'),
          ),
        ],
      );
    },
  );
}
