# Flutter Canvas Kit

A professional Flutter canvas/drawing library with multi-layer support, various drawing tools, undo/redo, and export capabilities.

## Features

- 🎨 **Multiple Drawing Tools**: Pen, Highlighter, Pencil, Eraser, Shapes
- 📚 **Multi-Layer Support**: Create, manage, reorder layers
- ↩️ **Undo/Redo**: Full history management with batch operations
- 🔍 **Zoom & Pan**: Smooth canvas navigation
- 📄 **Multiple Pages**: Document with multiple pages
- 🎯 **Selection Tool**: Select, move, delete elements
- 📤 **Export**: PNG, SVG, JSON serialization
- 🎭 **Themes**: Customizable appearance
- 📱 **Touch & Stylus**: Pressure sensitivity support

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_canvas_kit: ^2.0.0
```

## Quick Start

```dart
import 'package:flutter_canvas_kit/flutter_canvas_kit.dart';

class DrawingPage extends StatefulWidget {
  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late final CanvasController _controller;
  late final PenTool _penTool;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
    _penTool = PenTool();
    _penTool.onSelected(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CanvasWidget(
        controller: _controller,
        tool: _penTool,
      ),
      bottomNavigationBar: CanvasToolbar(
        controller: _controller,
      ),
    );
  }
}
```

## Architecture

```
flutter_canvas_kit/
├── lib/
│   ├── flutter_canvas_kit.dart    # Barrel file
│   └── src/
│       ├── core/                   # Constants, errors, extensions
│       ├── data/                   # Serialization, export
│       ├── domain/                 # Entities, enums, value objects
│       └── presentation/           # Controllers, widgets, tools
└── example/                        # Demo application
```

## Tools

| Tool | Description |
|------|-------------|
| `PenTool` | Standard drawing pen |
| `HighlighterTool` | Semi-transparent highlighter |
| `PencilTool` | Thin pencil stroke |
| `EraserTool` | Erase strokes |
| `ShapeTool` | Draw shapes (rectangle, circle, etc.) |
| `SelectionTool` | Select and manipulate elements |

## Controller Methods

```dart
// Document
controller.loadDocument(document);
controller.clearDocument();

// Pages
controller.addPage();
controller.removePage(pageId);
controller.setCurrentPageIndex(index);

// Layers
controller.addLayer();
controller.removeLayer(layerId);
controller.setActiveLayerIndex(index);
controller.toggleLayerVisibility(layerId);
controller.toggleLayerLock(layerId);

// Drawing
controller.setColor(color);
controller.setStrokeWidth(width);
controller.selectTool(toolType);

// History
controller.undo();
controller.redo();

// Zoom
controller.zoomIn();
controller.zoomOut();
controller.resetZoom();
```

## Widgets

### CanvasWidget

Main drawing canvas:

```dart
CanvasWidget(
  controller: controller,
  config: CanvasConfig(
    minZoom: 0.1,
    maxZoom: 10.0,
    enablePressure: true,
  ),
  tool: activeTool,
)
```

### CanvasToolbar

Tool selection toolbar:

```dart
CanvasToolbar(
  controller: controller,
  position: ToolbarPosition.bottom,
  showUndoRedo: true,
)
```

### LayerPanel

Layer management panel:

```dart
LayerPanel(
  controller: controller,
  width: 250,
)
```

### ColorPicker

Color selection:

```dart
ColorPicker(
  selectedColor: currentColor,
  onColorSelected: (color) => controller.setColor(color),
)
```

## Export

```dart
// Export to PNG
final pngExporter = PngExporter();
final bytes = await pngExporter.export(controller.currentPage);

// Export to SVG
final svgExporter = SvgExporter();
final svgString = svgExporter.export(controller.currentPage);

// Serialize to JSON
final serializer = DocumentSerializer();
final json = serializer.toJson(controller.document);
```

## License

MIT License