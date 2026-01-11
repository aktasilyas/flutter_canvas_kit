import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/flutter_canvas_kit.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

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

  // Tools
  late final PenTool _penTool;
  late final ShapeTool _shapeTool;
  late final SelectionTool _selectionTool;
  late final EraserTool _eraserTool;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController(
      document: CanvasDocument.empty(
        title: 'My Drawing',
        background: PageBackground.dotted,
      ),
    );

    _penTool = PenTool();
    _shapeTool = ShapeTool();
    _selectionTool = SelectionTool();
    _eraserTool = EraserTool();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Tool _getToolForType(ToolType type) {
    return switch (type) {
      ToolType.pen => _penTool,
      ToolType.pencil => _penTool, // Pencil uses PenTool with specific sensitivity if needed, or we can use generic PenTool since controller handles style
      ToolType.highlighter => _penTool, // Similarly for highlighter
      ToolType.neon => _penTool,
      ToolType.dashed => _penTool,
      ToolType.eraser => _eraserTool,
      ToolType.shape => _shapeTool,
      ToolType.selection => _selectionTool,
      _ => _penTool,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Canvas
              Positioned.fill(
                child: CanvasWidget(
                  controller: _controller,
                  tool: _getToolForType(_controller.currentTool),
                  onZoomChanged: (zoom) {}, 
                ),
              ),
              
              // Toolbar (Overlay)
              CanvasToolbar(
                 controller: _controller,
                 showUndoRedo: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
