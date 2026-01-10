import 'package:flutter/material.dart';

import 'package:flutter_canvas_kit/src/domain/entities/layer.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';

/// Katman yönetim paneli.
class LayerPanel extends StatelessWidget {
  /// Canvas kontrolcüsü.
  final CanvasController controller;

  /// Panel genişliği.
  final double width;

  /// Arka plan rengi.
  final Color? backgroundColor;

  /// Katman ekleme callback'i.
  final VoidCallback? onAddLayer;

  const LayerPanel({
    super.key,
    required this.controller,
    this.width = 250,
    this.backgroundColor,
    this.onAddLayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final layers = controller.currentPage.layers;
        final activeIndex = controller.activeLayerIndex;

        return Container(
          width: width,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: layers.length,
                  onReorder: (oldIndex, newIndex) {
                    final realOldIndex = layers.length - 1 - oldIndex;
                    var realNewIndex = layers.length - 1 - newIndex;
                    if (realOldIndex < realNewIndex) realNewIndex++;
                    controller.reorderLayers(realOldIndex, realNewIndex);
                  },
                  itemBuilder: (context, index) {
                    final reversedIndex = layers.length - 1 - index;
                    final layer = layers[reversedIndex];
                    final isActive = reversedIndex == activeIndex;

                    return _LayerTile(
                      key: ValueKey(layer.id),
                      layer: layer,
                      index: index,
                      isActive: isActive,
                      onTap: () =>
                          controller.setActiveLayerIndex(reversedIndex),
                      onVisibilityToggle: () =>
                          controller.toggleLayerVisibility(layer.id),
                      onLockToggle: () => controller.toggleLayerLock(layer.id),
                      onDelete: layers.length > 1
                          ? () => controller.removeLayer(layer.id)
                          : null,
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            'Layers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 20,
            onPressed: onAddLayer ?? () => controller.addLayer(),
            tooltip: 'Add Layer',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final activeLayer = controller.activeLayer;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Opacity',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${(activeLayer.opacity * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: activeLayer.opacity,
              min: 0,
              max: 1,
              onChanged: (value) {
                controller.setLayerOpacity(activeLayer.id, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek katman satırı.
class _LayerTile extends StatelessWidget {
  final Layer layer;
  final int index;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onVisibilityToggle;
  final VoidCallback onLockToggle;
  final VoidCallback? onDelete;

  const _LayerTile({
    super.key,
    required this.layer,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.onVisibilityToggle,
    required this.onLockToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle, size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.dividerColor),
                ),
                child:
                    layer.isEmpty ? null : const Icon(Icons.layers, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  layer.name,
                  style: TextStyle(
                    color: layer.isVisible
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  layer.isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: layer.isVisible
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onPressed: onVisibilityToggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                icon: Icon(
                  layer.isLocked ? Icons.lock : Icons.lock_open,
                  size: 18,
                  color: layer.isLocked
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                onPressed: onLockToggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
