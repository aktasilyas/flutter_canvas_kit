import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/flutter_canvas_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Canvas Kit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DrawingPage(),
    );
  }
}

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  late final CanvasController _controller;

  // Tool'lar
  late final PenTool _penTool;
  late final HighlighterTool _highlighterTool;
  late final PencilTool _pencilTool;
  late final EraserTool _eraserTool;
  late final ShapeTool _shapeTool;
  late final SelectionTool _selectionTool;
  Tool? _activeTool;
  ToolType _activeToolType = ToolType.pen;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController(
      document: CanvasDocument.empty(
        title: 'My Drawing',
        background: PageBackground.dotted,
      ),
    );

    // Tool'ları oluştur
    _penTool = PenTool();
    _highlighterTool = HighlighterTool();
    _pencilTool = PencilTool();
    _eraserTool = EraserTool();
    _shapeTool = ShapeTool();
    _selectionTool = SelectionTool();
    // Varsayılan: Pen
    _activeTool = _penTool;
    _penTool.onSelected(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTool(ToolType type) {
    _activeTool?.onDeselected(_controller);

    setState(() {
      _activeToolType = type;
      _activeTool = switch (type) {
        ToolType.pen => _penTool,
        ToolType.highlighter => _highlighterTool,
        ToolType.pencil => _pencilTool,
        ToolType.eraser => _eraserTool,
        ToolType.shape => _shapeTool,
        ToolType.selection => _selectionTool,
        _ => _penTool,
      };
    });

    _activeTool?.onSelected(_controller);
    debugPrint('Tool selected: $type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Canvas Kit'),
        actions: [
          // Undo
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _controller.canUndo ? _controller.undo : null,
              );
            },
          ),
          // Redo
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return IconButton(
                icon: const Icon(Icons.redo),
                onPressed: _controller.canRedo ? _controller.redo : null,
              );
            },
          ),
          // Clear
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(),
          ),
          // Background
          PopupMenuButton<PageBackground>(
            icon: const Icon(Icons.grid_on),
            onSelected: (bg) => _controller.setPageBackground(bg),
            itemBuilder: (context) => PageBackground.values.map((bg) {
              return PopupMenuItem(
                value: bg,
                child: Text(bg.displayName),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tool seçici
          _buildToolSelector(),
          // Şekil seçici (sadece shape tool seçiliyken)
          if (_activeToolType == ToolType.shape) _buildShapeSelector(),
          // Renk ve kalınlık
          _buildStyleBar(),
          // Canvas + Zoom kontrolü
          Expanded(
            child: Stack(
              children: [
                CanvasWidget(
                  controller: _controller,
                  config: const CanvasConfig(debugMode: true),
                  tool: _activeTool,
                  onZoomChanged: (zoom) => setState(() {}),
                ),
                // Zoom göstergesi
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: _buildZoomControls(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _controller.zoomIn(),
                  tooltip: 'Yakınlaştır',
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(_controller.zoom * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _controller.zoomOut(),
                  tooltip: 'Uzaklaştır',
                ),
                const Divider(height: 8),
                IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: () => _controller.resetZoom(),
                  tooltip: 'Sıfırla',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolButton(ToolType.pen, Icons.edit, 'Kalem'),
          _buildToolButton(ToolType.highlighter, Icons.highlight, 'Fosforlu'),
          _buildToolButton(ToolType.pencil, Icons.create, 'Kurşun'),
          _buildToolButton(ToolType.eraser, Icons.auto_fix_normal, 'Silgi'),
          _buildToolButton(ToolType.selection, Icons.touch_app, 'Seçim'),
          _buildToolButton(ToolType.shape, Icons.category, 'Şekil'),
        ],
      ),
    );
  }

  Widget _buildToolButton(ToolType type, IconData icon, String label) {
    final isSelected = _activeToolType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () => _selectTool(type),
            style: IconButton.styleFrom(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              foregroundColor:
                  isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blue[50],
      child: Row(
        children: [
          const Text('Şekil: ', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _buildShapeButton(
              ShapeType.rectangle, Icons.rectangle_outlined, 'Dikdörtgen'),
          _buildShapeButton(ShapeType.ellipse, Icons.circle_outlined, 'Daire'),
          _buildShapeButton(ShapeType.line, Icons.show_chart, 'Çizgi'),
          _buildShapeButton(ShapeType.triangle, Icons.change_history, 'Üçgen'),
          const Spacer(),
          // Dolgulu mu?
          Row(
            children: [
              const Text('Dolgulu: '),
              Switch(
                value: _controller.shapeFilled,
                onChanged: (v) {
                  setState(() {
                    _controller.setShapeFilled(v);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShapeButton(ShapeType type, IconData icon, String tooltip) {
    final isSelected = _controller.currentShapeType == type;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {
          setState(() {
            _controller.setShapeType(type);
          });
        },
        style: IconButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[200] : null,
        ),
      ),
    );
  }

  Widget _buildStyleBar() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              // Renk seçici
              const Text('Renk: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              ..._buildColorButtons(),

              const SizedBox(width: 24),

              // Kalınlık seçici
              const Text('Kalınlık: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Expanded(
                child: Slider(
                  value: _controller.currentWidth,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: _controller.currentWidth.toInt().toString(),
                  onChanged: _controller.setStrokeWidth,
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${_controller.currentWidth.toInt()}',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildColorButtons() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return colors.map((color) {
      final isSelected = _controller.currentColor.value == color.value;
      return GestureDetector(
        onTap: () => _controller.setColor(color),
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey[400]!,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                : null,
          ),
        ),
      );
    }).toList();
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayfayı Temizle'),
        content: const Text('Tüm çizimler silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              _controller.clearActiveLayer();
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}
