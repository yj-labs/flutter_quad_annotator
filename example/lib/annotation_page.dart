import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_quad_annotator/flutter_quad_annotator.dart';
import 'floating_control_panel.dart';

/// 四边形标注页面
class AnnotationPage extends StatefulWidget {
  /// 图片数据源，可以是Asset路径或File对象
  final dynamic imageSource;

  /// 图片源类型：'asset', 'file', 'ui_image'
  final String sourceType;

  /// 初始四边形点位数据（可选）
  final QuadAnnotation? initialRectangle;

  const AnnotationPage({
    super.key,
    required this.imageSource,
    required this.sourceType,
    this.initialRectangle,
  });

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  /// 当前四个顶点的坐标（图片真实坐标）
  QuadAnnotation? currentRectangle;

  /// 标注组件的controller，用于获取和设置顶点坐标
  final QuadAnnotatorController _controller = QuadAnnotatorController();

  /// 遮罩颜色（透明表示关闭遮罩效果）
  Color _maskColor = const Color(0x80000000);

  /// 当前拖动状态信息
  String _dragStatus = '未拖动';

  /// 拖动历史记录
  final List<String> _dragHistory = [];

  /// 控制面板是否折叠
  bool _isPanelCollapsed = true;

  /// 是否启用放大镜效果
  bool _enableMagnifier = true;

  /// 是否启用呼吸灯动画效果
  bool _enableBreathing = true;

  /// 放大镜位置模式
  MagnifierPositionMode _magnifierPositionMode = MagnifierPositionMode.center;
  MagnifierCornerPosition _magnifierCornerPosition =
      MagnifierCornerPosition.topLeft;
  MagnifierShape _magnifierShape = MagnifierShape.circle;

  @override
  void initState() {
    super.initState();
    // 如果传入了初始点位数据，则设置为当前矩形
    if (widget.initialRectangle != null) {
      currentRectangle = widget.initialRectangle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // 直接返回，绕过PopScope拦截
              Navigator.of(context).pop();
            },
          ),
          title: const Text('图片四边形标注演示'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // 重置按钮
            IconButton(
              onPressed: _resetVertices,
              icon: const Icon(Icons.refresh),
              tooltip: '重置顶点',
            ),
            // 确认按钮
            IconButton(
              onPressed: _confirmAnnotation,
              icon: const Icon(Icons.check),
              tooltip: '确认标注',
            ),
          ],
        ),
        body: Stack(
          children: [
            // 四点标注组件
            _buildQuadAnnotatorBox(),
            // 悬浮控制面板
            FloatingControlPanel(
              isPanelCollapsed: _isPanelCollapsed,
              onPanelCollapseChanged: (value) {
                setState(() {
                  _isPanelCollapsed = value;
                });
              },
              maskColor: _maskColor,
              onMaskColorChanged: (value) {
                setState(() {
                  _maskColor = value;
                });
              },
              enableMagnifier: _enableMagnifier,
              onEnableMagnifierChanged: (value) {
                setState(() {
                  _enableMagnifier = value;
                });
              },
              enableBreathing: _enableBreathing,
              onEnableBreathingChanged: (value) {
                setState(() {
                  _enableBreathing = value;
                });
              },
              magnifierPositionMode: _magnifierPositionMode,
              onMagnifierPositionModeChanged: (value) {
                setState(() {
                  _magnifierPositionMode = value;
                });
              },
              magnifierCornerPosition: _magnifierCornerPosition,
              onMagnifierCornerPositionChanged: (value) {
                setState(() {
                  _magnifierCornerPosition = value;
                });
              },
              magnifierShape: _magnifierShape,
              onMagnifierShapeChanged: (value) {
                setState(() {
                  _magnifierShape = value;
                });
              },
              dragStatus: _dragStatus,
              currentRectangle: currentRectangle,
              onGetVertices: _getImageVertices,
              onResetVertices: _resetVertices,
              maxHeight: MediaQuery.of(context).size.height,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建四点标注组件
  /// 自动适应父容器尺寸
  Widget _buildQuadAnnotatorBox() {
    // 根据图片源类型选择构造函数
    if (widget.sourceType == 'ui_image') {
      // 直接使用 ui.Image
      return QuadAnnotatorBox(
        image: widget.imageSource as ui.Image,
        controller: _controller,
        rectangle: currentRectangle,
        onVerticesChanged: _onVerticesChanged,
        onVertexDragStart: _onVertexDragStart,
        onVertexDragEnd: _onVertexDragEnd,
        onEdgeDragStart: _onEdgeDragStart,
        onEdgeDragEnd: _onEdgeDragEnd,
        fillColor: (_maskColor.a * 255.0).round() & 0xff > 0
            ? Colors.transparent
            : Colors.red.withValues(alpha: 0.1),
        vertexColor: Colors.white,
        maskColor: _maskColor,
        highlightColor: Colors.yellow,
        vertexRadius: 10.0,
        borderWidth: 2.5,
        allowEdgeDrag: false,
        breathing: BreathingAnimation(
          enabled: _enableBreathing,
          duration: const Duration(milliseconds: 1500),
          opacityMin: 0.2,
          opacityMax: 0.9,
          gap: 0.0,
          strokeWidth: 4.0,
        ),
        magnifier: MagnifierConfiguration(
          enabled: _enableMagnifier,
          radius: 60.0,
          magnification: 1.0,
          borderColor: Colors.blue,
          borderWidth: 3.0,
          crosshairColor: Colors.red,
          crosshairRadius: 0.4,
          positionMode: _magnifierPositionMode,
          cornerPosition: _magnifierCornerPosition,
          edgeOffset: const Offset(20.0, -50.0),
          shape: _magnifierShape,
        ),
      );
    } else {
      // 统一使用 ImageProvider
      ImageProvider imageProvider;
      switch (widget.sourceType) {
        case 'asset':
          imageProvider = AssetImage(widget.imageSource as String);
          break;
        case 'file':
          imageProvider = FileImage(widget.imageSource as File);
          break;
        default:
          throw ArgumentError('Unsupported source type: ${widget.sourceType}');
      }

      return QuadAnnotatorBox.fromProvider(
        imageProvider: imageProvider,
        controller: _controller,
        rectangle: currentRectangle,
        onVerticesChanged: _onVerticesChanged,
        onVertexDragStart: _onVertexDragStart,
        onVertexDragEnd: _onVertexDragEnd,
        onEdgeDragStart: _onEdgeDragStart,
        onEdgeDragEnd: _onEdgeDragEnd,
        fillColor: (_maskColor.a * 255.0).round() & 0xff > 0
            ? Colors.transparent
            : Colors.red.withValues(alpha: 0.1),
        vertexColor: Colors.white,
        maskColor: _maskColor,
        highlightColor: Colors.yellow,
        vertexRadius: 10.0,
        borderWidth: 2.5,
        allowEdgeDrag: false,
        breathing: BreathingAnimation(
          enabled: _enableBreathing,
          duration: const Duration(milliseconds: 1500),
          opacityMin: 0.2,
          opacityMax: 0.9,
          gap: 0.0,
          strokeWidth: 4.0,
        ),
        magnifier: MagnifierConfiguration(
          enabled: _enableMagnifier,
          radius: 60.0,
          magnification: 1.0,
          borderColor: Colors.blue,
          borderWidth: 3.0,
          crosshairColor: Colors.red,
          crosshairRadius: 0.4,
          positionMode: _magnifierPositionMode,
          cornerPosition: _magnifierCornerPosition,
          edgeOffset: const Offset(20.0, -50.0),
          shape: _magnifierShape,
        ),
      );
    }
  }

  /// 顶点坐标变化时的回调函数
  /// 顶点坐标变化时的回调函数
  void _onVerticesChanged(QuadAnnotation rectangle) {
    setState(() {
      // 直接使用QuadAnnotation类型
      currentRectangle = rectangle;
    });
  }

  /// 顶点拖动开始时的回调函数
  void _onVertexDragStart(int vertexIndex, Point<double> position) {
    setState(() {
      _dragStatus = '正在拖动顶点 ${vertexIndex + 1}';
    });
    _addDragHistory(
        '开始拖动顶点 ${vertexIndex + 1} 从位置 (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})');
  }

  /// 顶点拖动结束时的回调函数
  void _onVertexDragEnd(int vertexIndex, Point<double> position) {
    setState(() {
      _dragStatus = '未拖动';
    });
    _addDragHistory(
        '结束拖动顶点 ${vertexIndex + 1} 到位置 (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})');
  }

  /// 边拖动开始时的回调函数
  void _onEdgeDragStart(int edgeIndex, Point<double> position) {
    setState(() {
      _dragStatus = '正在拖动边 ${edgeIndex + 1}';
    });
    _addDragHistory(
        '开始拖动边 ${edgeIndex + 1} 从位置 (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})');
  }

  /// 边拖动结束时的回调函数
  void _onEdgeDragEnd(int edgeIndex, Point<double> position) {
    setState(() {
      _dragStatus = '未拖动';
    });
    _addDragHistory(
        '结束拖动边 ${edgeIndex + 1} 到位置 (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})');
  }

  /// 添加拖动历史记录
  void _addDragHistory(String action) {
    setState(() {
      _dragHistory
          .add('${DateTime.now().toString().substring(11, 19)} - $action');
      // 只保留最近10条记录
      if (_dragHistory.length > 10) {
        _dragHistory.removeAt(0);
      }
    });
  }

  /// 获取当前顶点的图片真实坐标
  void _getImageVertices() {
    final vertices = _controller.vertices;
    if (vertices == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('当前没有矩形数据，请先进行标注。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前顶点坐标（图片真实坐标）'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: vertices.asMap().entries.map((entry) {
            final index = entry.key;
            final vertex = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '顶点${index + 1}: (${vertex.x.toStringAsFixed(2)}, ${vertex.y.toStringAsFixed(2)})',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 确认标注，返回图片和QuadAnnotation数据
  void _confirmAnnotation() {
    try {
      if (currentRectangle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请先进行矩形标注'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 现在currentRectangle已经是图片真实坐标的QuadAnnotation类型
      final rectangleFeature = currentRectangle!;
      final imageVertices = rectangleFeature.vertices;

      // 创建返回数据
      final annotationResult = {
        'imageSource': widget.imageSource,
        'sourceType': widget.sourceType,
        'rectangleFeature': rectangleFeature,
        'imageVertices': imageVertices, // 额外提供图片真实坐标数组
      };

      // 返回到首页并传递数据
      Navigator.of(context).pop(annotationResult);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('确认标注失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 重置顶点到默认位置
  void _resetVertices() {
    _controller.reset();
  }
}
