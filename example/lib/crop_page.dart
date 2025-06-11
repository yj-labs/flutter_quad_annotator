import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_quad_annotator/flutter_quad_annotator.dart';
import 'floating_control_panel.dart';

/// 四边形裁剪页面
class CropPage extends StatefulWidget {
  /// 图片数据源，可以是Asset路径或File对象
  final dynamic imageSource;
  /// 图片源类型：'asset', 'file', 'ui_image'
  final String sourceType;
  
  const CropPage({
    super.key,
    required this.imageSource,
    required this.sourceType,
  });

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  /// 当前四个顶点的坐标（视图坐标）
  RectangleFeature currentRectangle = RectangleFeature(
    topLeft: const Offset(100, 100),
    topRight: const Offset(300, 120),
    bottomRight: const Offset(280, 300),
    bottomLeft: const Offset(80, 280),
  );

  /// 当前顶点的图片真实坐标
  List<Offset> currentImageVertices = [];

  /// 裁剪组件的Key，用于获取和设置顶点坐标
  final GlobalKey<QuadAnnotatorBoxState> _boxKey =
      GlobalKey<QuadAnnotatorBoxState>();
  
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
  MagnifierCornerPosition _magnifierCornerPosition = MagnifierCornerPosition.topLeft;
  MagnifierShape _magnifierShape = MagnifierShape.circle;
  
  @override
  void initState() {
    super.initState();
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
          title: const Text('图片四边形裁剪演示'),
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
              onPressed: _confirmCrop,
              icon: const Icon(Icons.check),
              tooltip: '确认裁剪',
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // 四点标注组件
                _buildQuadAnnotatorBox(constraints),
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
                  currentImageVertices: currentImageVertices,
                  onGetVertices: _getVertices,
                  onGetImageVertices: _getImageVertices,
                  onSetRandomVertices: _setRandomVertices,
                  onResetVertices: _resetVertices,
                  maxHeight: constraints.maxHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建四点标注组件
  /// [constraints] 布局约束
  Widget _buildQuadAnnotatorBox(BoxConstraints constraints) {
    // 根据图片源类型选择构造函数
    if (widget.sourceType == 'ui_image') {
      // 直接使用 ui.Image
      return QuadAnnotatorBox(
        key: _boxKey,
        image: widget.imageSource as ui.Image,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        initialRectangle: currentRectangle,
        onVerticesChanged: _onVerticesChanged,
        onVertexDragStart: _onVertexDragStart,
        onVertexDragEnd: _onVertexDragEnd,
        onEdgeDragStart: _onEdgeDragStart,
        onEdgeDragEnd: _onEdgeDragEnd,
        fillColor: _maskColor.alpha > 0 ? Colors.transparent : Colors.red.withOpacity(0.1),
        vertexColor: Colors.white,
        maskColor: _maskColor,
        highlightColor: Colors.yellow,
        vertexRadius: 10.0,
        borderWidth: 2.5,
        showVertexNumbers: true,
        enableBreathing: _enableBreathing,
        breathingDuration: const Duration(milliseconds: 1500),
        breathingOpacityMin: 0.2,
        breathingOpacityMax: 0.9,
        breathingGap: 0.0,
        breathingStrokeWidth: 4.0,
        enableMagnifier: _enableMagnifier,
        magnifierRadius: 60.0,
        magnification: 2.0,
        magnifierBorderColor: Colors.blue,
        magnifierBorderWidth: 3.0,
        magnifierCrosshairColor: Colors.red,
        magnifierCrosshairRadius: 0.4,
        magnifierPositionMode: _magnifierPositionMode,
        magnifierCornerPosition: _magnifierCornerPosition,
        magnifierEdgeOffset: 20.0,
        magnifierShape: _magnifierShape,
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
        key: _boxKey,
        imageProvider: imageProvider,
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        initialRectangle: currentRectangle,
        onVerticesChanged: _onVerticesChanged,
        onVertexDragStart: _onVertexDragStart,
        onVertexDragEnd: _onVertexDragEnd,
        onEdgeDragStart: _onEdgeDragStart,
        onEdgeDragEnd: _onEdgeDragEnd,
        fillColor: _maskColor.alpha > 0 ? Colors.transparent : Colors.red.withOpacity(0.1),
        vertexColor: Colors.white,
        maskColor: _maskColor,
        highlightColor: Colors.yellow,
        vertexRadius: 10.0,
        borderWidth: 2.5,
        showVertexNumbers: true,
        enableBreathing: _enableBreathing,
        breathingDuration: const Duration(milliseconds: 1500),
        breathingOpacityMin: 0.2,
        breathingOpacityMax: 0.9,
        breathingGap: 0.0,
        breathingStrokeWidth: 4.0,
        enableMagnifier: _enableMagnifier,
        magnifierRadius: 60.0,
        magnification: 2.0,
        magnifierBorderColor: Colors.blue,
        magnifierBorderWidth: 3.0,
        magnifierCrosshairColor: Colors.red,
        magnifierCrosshairRadius: 0.4,
        magnifierPositionMode: _magnifierPositionMode,
        magnifierCornerPosition: _magnifierCornerPosition,
        magnifierEdgeOffset: 20.0,
        magnifierShape: _magnifierShape,
      );
    }
  }

  /// 顶点坐标变化时的回调函数
  void _onVerticesChanged(RectangleFeature rectangle) {
    setState(() {
      currentRectangle = rectangle;
    });
    
    // 同时获取图片真实坐标
    try {
      final imageVertices = _boxKey.currentState?.getImageVertices();
      if (imageVertices != null) {
        setState(() {
          currentImageVertices = imageVertices;
        });
      }
    } catch (e) {
      print('获取图片坐标失败: $e');
    }
  }
  
  /// 顶点拖动开始时的回调函数
  void _onVertexDragStart(int vertexIndex, Offset position) {
    setState(() {
      _dragStatus = '正在拖动顶点 ${vertexIndex + 1}';
    });
    _addDragHistory('开始拖动顶点 ${vertexIndex + 1} 从位置 (${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)})');
  }
  
  /// 顶点拖动结束时的回调函数
  void _onVertexDragEnd(int vertexIndex, Offset position) {
    setState(() {
      _dragStatus = '未拖动';
    });
    _addDragHistory('结束拖动顶点 ${vertexIndex + 1} 到位置 (${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)})');
  }
  
  /// 边拖动开始时的回调函数
  void _onEdgeDragStart(int edgeIndex, Offset position) {
    setState(() {
      _dragStatus = '正在拖动边 ${edgeIndex + 1}';
    });
    _addDragHistory('开始拖动边 ${edgeIndex + 1} 从位置 (${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)})');
  }
  
  /// 边拖动结束时的回调函数
  void _onEdgeDragEnd(int edgeIndex, Offset position) {
    setState(() {
      _dragStatus = '未拖动';
    });
    _addDragHistory('结束拖动边 ${edgeIndex + 1} 到位置 (${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)})');
  }
  
  /// 添加拖动历史记录
  void _addDragHistory(String action) {
    setState(() {
      _dragHistory.add('${DateTime.now().toString().substring(11, 19)} - $action');
      // 只保留最近10条记录
      if (_dragHistory.length > 10) {
        _dragHistory.removeAt(0);
      }
    });
  }

  /// 获取当前顶点坐标（视图坐标）
  void _getVertices() {
    final vertices = _boxKey.currentState?.getVertices();
    if (vertices != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('当前顶点坐标（视图坐标）'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: vertices.asMap().entries.map((entry) {
              final index = entry.key;
              final vertex = entry.value;
              return Text(
                '顶点${index + 1}: (${vertex.dx.toStringAsFixed(2)}, ${vertex.dy.toStringAsFixed(2)})',
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
  }
  
  /// 获取当前顶点的图片真实坐标
  void _getImageVertices() {
    try {
      final imageVertices = _boxKey.currentState?.getImageVertices();
      if (imageVertices != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('当前顶点坐标（图片真实坐标）'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: imageVertices.asMap().entries.map((entry) {
                final index = entry.key;
                final vertex = entry.value;
                return Text(
                  '顶点${index + 1}: (${vertex.dx.toStringAsFixed(2)}, ${vertex.dy.toStringAsFixed(2)})',
                  style: const TextStyle(color: Colors.green),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取图片坐标失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 设置随机顶点位置
  void _setRandomVertices() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final newVertices = [
      Offset(50 + (random % 100).toDouble(), 50 + ((random ~/ 100) % 100).toDouble()),
      Offset(250 + (random % 150).toDouble(), 50 + ((random ~/ 150) % 100).toDouble()),
      Offset(200 + (random % 180).toDouble(), 250 + ((random ~/ 180) % 150).toDouble()),
      Offset(50 + (random % 120).toDouble(), 200 + ((random ~/ 120) % 180).toDouble()),
    ];
    
    _boxKey.currentState?.setVertices(newVertices);
  }

  /// 确认裁剪，返回图片和RectangleFeature数据
  void _confirmCrop() {
    try {
      // 获取当前顶点的图片真实坐标（而不是UI坐标）
      final imageVertices = _boxKey.currentState?.getImageVertices();
      if (imageVertices == null || imageVertices.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法获取图片真实坐标'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 创建RectangleFeature对象（使用图片真实坐标）
      final rectangleFeature = RectangleFeature(
        topLeft: imageVertices[0],
        topRight: imageVertices[1],
        bottomRight: imageVertices[2],
        bottomLeft: imageVertices[3],
      );

      // 创建返回数据
      final cropResult = {
        'imageSource': widget.imageSource,
        'sourceType': widget.sourceType,
        'rectangleFeature': rectangleFeature,
        'imageVertices': imageVertices, // 额外提供图片真实坐标数组
      };

      // 返回到首页并传递数据
      Navigator.of(context).pop(cropResult);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('确认裁剪失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 重置顶点到默认位置
  void _resetVertices() {
    _boxKey.currentState?.resetVertices();
  }
}