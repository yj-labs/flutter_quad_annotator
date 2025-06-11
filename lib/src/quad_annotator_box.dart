import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


import 'types.dart';
import 'gesture_recognizer.dart';
import 'quadrilateral_painter.dart';
import 'rectangle_feature.dart';
import 'utils/coordinate_utils.dart';
import 'utils/geometry_utils.dart';
import 'utils/magnifier_utils.dart';
import 'utils/image_utils.dart';

/// 四边形裁剪组件State类型定义（用于GlobalKey）
typedef QuadAnnotatorBoxState = _QuadAnnotatorBoxState;

/// 四边形标注组件
/// 支持在图片上绘制和编辑四边形区域
class QuadAnnotatorBox extends StatefulWidget {
  /// 背景图片对象（用于显示和获取真实尺寸）
  final ui.Image? image;
  
  /// 图片提供者（用于显示图片，可选）
  final ImageProvider? imageProvider;
  
  /// 初始矩形特征，如果不提供则使用默认值
  final RectangleFeature? initialRectangle;
  
  /// 顶点坐标变化时的回调函数
  final OnVerticesChanged? onVerticesChanged;
  
  /// 顶点拖动开始时的回调函数
  final OnVertexDragStart? onVertexDragStart;
  
  /// 顶点拖动结束时的回调函数
  final OnVertexDragEnd? onVertexDragEnd;
  
  /// 边拖动开始时的回调函数
  final OnEdgeDragStart? onEdgeDragStart;
  
  /// 边拖动结束时的回调函数
  final OnEdgeDragEnd? onEdgeDragEnd;
  
  /// 组件的宽度
  final double width;
  
  /// 组件的高度
  final double height;

  /// 背景色
  final Color backgroundColor;
  
  /// 四边形线条颜色
  final Color borderColor;
  
  /// 四边形错误状态线条颜色（交叉时）
  final Color errorColor;
  
  /// 四边形填充颜色
  final Color fillColor;
  
  /// 顶点颜色
  final Color vertexColor;
  
  /// 高亮颜色（拖动时显示）
  final Color highlightColor;
  
  /// 顶点半径
  final double vertexRadius;
  
  /// 边框宽度
  final double borderWidth;
  
  /// 是否显示顶点编号
  final bool showVertexNumbers;
  
  /// 遮罩颜色（设置为透明色可关闭遮罩效果）
  final Color maskColor;
  
  /// 呼吸灯效果颜色
  final Color breathingColor;
  
  /// 呼吸灯动画时长（秒）
  final Duration breathingDuration;
  
  /// 呼吸灯透明度最小值（0.0-1.0）
  final double breathingOpacityMin;
  
  /// 呼吸灯透明度最大值（0.0-1.0）
  final double breathingOpacityMax;
  
  /// 呼吸灯边框内边缘到顶点圆圈外边缘的间距
  final double breathingGap;
  
  /// 呼吸灯边框宽度
  final double breathingStrokeWidth;

  /// 是否启用呼吸灯动画效果
  final bool enableBreathing;

  /// 是否启用拖动时的放大镜效果
  final bool enableMagnifier;

  /// 放大镜圆圈半径
  final double magnifierRadius;

  /// 放大镜放大倍数
  final double magnification;

  /// 放大镜边框颜色
  final Color magnifierBorderColor;

  /// 放大镜边框宽度
  final double magnifierBorderWidth;

  /// 放大镜准心颜色
  final Color magnifierCrosshairColor;

  /// 放大镜准心半径（相对于放大镜半径的比例，0.0-1.0）
  final double magnifierCrosshairRadius;

  /// 放大镜位置模式
  final MagnifierPositionMode magnifierPositionMode;

  /// 放大镜角落位置（仅在corner模式下生效）
  final MagnifierCornerPosition magnifierCornerPosition;

  /// 放大镜边缘模式下的偏移距离
  final double magnifierEdgeOffset;

  /// 放大镜形状
  final MagnifierShape magnifierShape;

  /// 基础构造函数，直接接收ui.Image对象
  const QuadAnnotatorBox({
    super.key,
    required this.image,
    this.initialRectangle,
    this.onVerticesChanged,
    this.onVertexDragStart,
    this.onVertexDragEnd,
    this.onEdgeDragStart,
    this.onEdgeDragEnd,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.errorColor = Colors.red,
    this.fillColor = Colors.transparent,
    this.vertexColor = Colors.white,
    this.highlightColor = Colors.orange,
    this.vertexRadius = 8.0,
    this.borderWidth = 2.0,
    this.showVertexNumbers = true,
    this.maskColor = Colors.transparent,
    this.breathingColor = Colors.white,
    this.breathingDuration = const Duration(seconds: 2),
    this.breathingOpacityMin = 0.2,
    this.breathingOpacityMax = 0.9,
    this.breathingGap = 2.0,
    this.breathingStrokeWidth = 3.0,
    this.enableBreathing = true,
    this.enableMagnifier = true,
    this.magnifierRadius = 60.0,
    this.magnification = 1.0,
    this.magnifierBorderColor = Colors.white,
    this.magnifierBorderWidth = 3.0,
    this.magnifierCrosshairColor = Colors.red,
    this.magnifierCrosshairRadius = 0.3,
    this.magnifierPositionMode = MagnifierPositionMode.center,
    this.magnifierCornerPosition = MagnifierCornerPosition.topLeft,
    this.magnifierEdgeOffset = 20.0,
    this.magnifierShape = MagnifierShape.circle,
  }) : imageProvider = null;
  
  /// 从ImageProvider创建QuadAnnotatorBox的便捷构造函数
  const QuadAnnotatorBox.fromProvider({
    super.key,
    required this.imageProvider,
    this.initialRectangle,
    this.onVerticesChanged,
    this.onVertexDragStart,
    this.onVertexDragEnd,
    this.onEdgeDragStart,
    this.onEdgeDragEnd,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.errorColor = Colors.red,
    this.fillColor = Colors.transparent,
    this.vertexColor = Colors.white,
    this.highlightColor = Colors.orange,
    this.vertexRadius = 8.0,
    this.borderWidth = 2.0,
    this.showVertexNumbers = true,
    this.maskColor = Colors.transparent,
    this.breathingColor = Colors.white,
    this.breathingDuration = const Duration(seconds: 2),
    this.breathingOpacityMin = 0.2,
    this.breathingOpacityMax = 0.9,
    this.breathingGap = 2.0,
    this.breathingStrokeWidth = 3.0,
    this.enableBreathing = true,
    this.enableMagnifier = true,
    this.magnifierRadius = 60.0,
    this.magnification = 1.0,
    this.magnifierBorderColor = Colors.white,
    this.magnifierBorderWidth = 3.0,
    this.magnifierCrosshairColor = Colors.red,
    this.magnifierCrosshairRadius = 0.3,
    this.magnifierPositionMode = MagnifierPositionMode.center,
    this.magnifierCornerPosition = MagnifierCornerPosition.topLeft,
    this.magnifierEdgeOffset = 20.0,
    this.magnifierShape = MagnifierShape.circle,
  }) : image = null;
  
  @override
  State<QuadAnnotatorBox> createState() => _QuadAnnotatorBoxState();
}

class _QuadAnnotatorBoxState extends State<QuadAnnotatorBox> with TickerProviderStateMixin {
  /// 矩形特征对象
  RectangleFeature? rectangle;

  /// 当前拖动的顶点索引，-1表示没有拖动顶点
  int draggedVertexIndex = -1;
  
  /// 当前拖动的边索引，-1表示没有拖动边
  int draggedEdgeIndex = -1;
  
  /// 是否正在拖动状态
  bool isDragging = false;
  
  /// 拖动开始时的偏移量
  Offset dragStartOffset = Offset.zero;
  
  /// 拖动开始时的矩形特征
  RectangleFeature? dragStartRectangle;
  
  /// 图片信息缓存
  QuadImageInfo? _imageInfo;
  
  /// 呼吸灯动画控制器
  late AnimationController _breathingController;
  
  /// 呼吸灯动画
  late Animation<double> _breathingAnimation;

  /// 是否显示放大镜
  bool _showMagnifier = false;

  /// 放大镜位置
  Offset _magnifierPosition = Offset.zero;

  /// 放大镜中心对应的原图位置
  Offset _magnifierSourcePosition = Offset.zero;

  /// 异步加载的图片对象
  ui.Image? _loadedImage;

  /// 计算放大镜位置
  /// [gesturePosition] 手势位置
  /// [sourcePosition] 源位置（图片坐标系）
  /// 返回放大镜应该显示的位置
  Offset _calculateMagnifierPosition(Offset gesturePosition, Offset sourcePosition) {
    return MagnifierUtils.calculateMagnifierPosition(
      gesturePosition,
      sourcePosition,
      widget.magnifierPositionMode,
      widget.magnifierCornerPosition,
      widget.magnifierEdgeOffset,
      widget.magnifierRadius,
      Size(widget.width, widget.height),
    );
  }

  @override
  void initState() {
    super.initState();
    
    // 初始化呼吸灯动画控制器
    _breathingController = AnimationController(
      duration: widget.breathingDuration,
      vsync: this,
    );
    
    // 创建呼吸灯动画（透明度从配置的最小值到最大值循环变化）
    _breathingAnimation = Tween<double>(
      begin: widget.breathingOpacityMin,
      end: widget.breathingOpacityMax,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // 根据配置决定是否启动循环动画
    if (widget.enableBreathing) {
      _breathingController.repeat(reverse: true);
    }
    
    // 如果使用ImageProvider，异步加载图片
    if (widget.imageProvider != null) {
      _loadImageFromProvider();
    } else {
      _loadedImage = widget.image;
      _initializeRectangle();
    }
  }
  
  /// 初始化矩形特征
  /// 在图片加载完成后调用
  void _initializeRectangle() {
    if (_loadedImage != null) {
      // 初始化矩形特征
      rectangle = widget.initialRectangle ?? _getDefaultRectangle();
      // 验证初始四边形正确性
      rectangle?.validateQuadrilateral();
      
      // 触发重建以显示矩形
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  /// 从ImageProvider异步加载图片
  Future<void> _loadImageFromProvider() async {
    if (widget.imageProvider != null) {
      try {
        final image = await ImageUtils.loadImageFromProvider(widget.imageProvider!);
        
        if (mounted) {
          setState(() {
            _loadedImage = image;
          });
          _initializeRectangle();
        }
      } catch (e) {
        // 图片加载失败，保持_loadedImage为null
        // Failed to load image
      }
    }
  }

  @override
  void dispose() {
    // 释放动画控制器资源
    _breathingController.dispose();
    super.dispose();
  }

  /// 当Widget配置更新时调用（例如屏幕方向变化）
  @override
  void didUpdateWidget(QuadAnnotatorBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果组件尺寸发生变化，保持四边形的相对位置
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      // 保存当前四边形在图片中的真实坐标
      List<Offset>? savedImageCoordinates;
      QuadImageInfo? oldImageInfo;
      
      if (rectangle != null && !rectangle!.isFixedCoordinates) {
        // 先获取旧的图片信息
        oldImageInfo = _imageInfo;
        if (oldImageInfo != null) {
          // 使用旧的图片信息将当前视图坐标转换为图片坐标
          savedImageCoordinates = rectangle!.vertices.map((viewPoint) {
            // 减去图片在容器中的偏移量
            final adjustedPoint = viewPoint - oldImageInfo!.offset;
            
            // 计算在显示图片中的相对位置（0-1）
            final relativeX = adjustedPoint.dx / oldImageInfo.displaySize.width;
            final relativeY = adjustedPoint.dy / oldImageInfo.displaySize.height;
            
            // 转换为图片真实坐标
            final realX = relativeX * oldImageInfo.realSize.width;
            final realY = relativeY * oldImageInfo.realSize.height;
            
            return Offset(realX, realY);
          }).toList();
        }
      }
      
      // 清除图片信息缓存以重新计算布局
      _imageInfo = null;
      
      if (savedImageCoordinates != null) {
        // 获取新的图片信息
        final newImageInfo = _getImageInfo();
        
        // 将保存的图片坐标转换为新布局下的视图坐标
        final newViewCoordinates = savedImageCoordinates.map((imagePoint) {
          // 计算在图片中的相对位置（0-1）
          final relativeX = imagePoint.dx / newImageInfo.realSize.width;
          final relativeY = imagePoint.dy / newImageInfo.realSize.height;
          
          // 转换为显示坐标
          final displayX = relativeX * newImageInfo.displaySize.width;
          final displayY = relativeY * newImageInfo.displaySize.height;
          
          // 加上图片在容器中的偏移量
          return Offset(displayX, displayY) + newImageInfo.offset;
        }).toList();
        
        // 更新四边形顶点位置
        for (int i = 0; i < newViewCoordinates.length && i < 4; i++) {
          rectangle?.setVertex(i, newViewCoordinates[i]);
        }
        
        // 验证四边形正确性
        rectangle?.validateQuadrilateral();
      } else {
        // 如果没有保存的坐标，使用默认矩形
        rectangle = _getDefaultRectangle();
      }
        }
  }

  /// 检查并更新矩形坐标（确保在图片加载后初始化）
  void _ensureRectangleInitialized() {
    if (rectangle?.isFixedCoordinates == true) {
      // 如果当前是固定坐标，重新计算基于图片的坐标
      rectangle = _getDefaultRectangle();
    }
  }

  /// 获取默认的矩形特征（基于图片显示区域）
  RectangleFeature _getDefaultRectangle() {
    final imageInfo = _getImageInfo();
    // 根据顶点半径计算内边距，确保顶点完全显示且有适当间距
    final padding = widget.vertexRadius;
    
    // 计算图片显示区域的边界
    final left = imageInfo.offset.dx;
    final top = imageInfo.offset.dy;
    final right = left + imageInfo.displaySize.width;
    final bottom = top + imageInfo.displaySize.height;
    
    return RectangleFeature(
      topLeft: Offset(left + padding, top + padding),
      topRight: Offset(right - padding, top + padding),
      bottomRight: Offset(right - padding, bottom - padding),
      bottomLeft: Offset(left + padding, bottom - padding),
    );
  }

  /// 构建Widget
  @override
  Widget build(BuildContext context) {
    // 如果图片还未加载完成，显示加载占位符
    if (_loadedImage == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: widget.backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // 确保矩形在图片加载后正确初始化
    _ensureRectangleInitialized();
    
    // 如果矩形还未初始化，显示加载占位符
    if (rectangle == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: widget.backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 背景图片
              Positioned.fill(
                child: RawImage(
                  image: _loadedImage,
                  fit: BoxFit.contain,
                ),
              ),
              // 四边形绘制层
              CustomPaint(
                painter: QuadrilateralPainter(
                  image: _loadedImage!,
                  vertices: rectangle!.vertices,
                  rectangle: rectangle!,
                  draggedVertexIndex: draggedVertexIndex,
                  draggedEdgeIndex: draggedEdgeIndex,
                  borderColor: widget.borderColor,
                  errorColor: widget.errorColor,
                  fillColor: widget.fillColor,
                  vertexColor: widget.vertexColor,
                  highlightColor: widget.highlightColor,
                  vertexRadius: widget.vertexRadius,
                  borderWidth: widget.borderWidth,
                  showVertexNumbers: widget.showVertexNumbers,
                  maskColor: widget.maskColor,
                  breathingAnimation: _breathingAnimation.value,
                  breathingColor: widget.breathingColor,
                  breathingGap: widget.breathingGap,
                  breathingStrokeWidth: widget.breathingStrokeWidth,
                  enableBreathing: widget.enableBreathing,
                  enableMagnifier: widget.enableMagnifier,
                  showMagnifier: _showMagnifier,
                  magnifierPosition: _magnifierPosition,
                  magnifierSourcePosition: _magnifierSourcePosition,
                  magnifierRadius: widget.magnifierRadius,
                  magnification: widget.magnification,
                  magnifierBorderColor: widget.magnifierBorderColor,
                  magnifierBorderWidth: widget.magnifierBorderWidth,
                  magnifierCrosshairColor: widget.magnifierCrosshairColor,
                  magnifierCrosshairRadius: widget.magnifierCrosshairRadius,
                  magnifierShape: widget.magnifierShape,
                ),
                size: Size(widget.width, widget.height),
                child: RawGestureDetector(
                   gestures: {
                     SingleTouchPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<SingleTouchPanGestureRecognizer>(
                       () => SingleTouchPanGestureRecognizer(),
                       (SingleTouchPanGestureRecognizer instance) {
                         instance
                           ..onStart = _onPanStart
                           ..onUpdate = _onPanUpdate
                           ..onEnd = _onPanEnd;
                       },
                     ),
                   },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 开始拖动手势
  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    dragStartOffset = localPosition;
    dragStartRectangle = rectangle?.copy();
    
    final vertices = rectangle?.vertices ?? [];
    
    // 检查是否点击在顶点上
    for (int i = 0; i < vertices.length; i++) {
      if (_isPointNearVertex(localPosition, vertices[i])) {
        setState(() {
          draggedVertexIndex = i;
          draggedEdgeIndex = -1;
          isDragging = true;
          // 启用放大镜效果
          if (widget.enableMagnifier) {
            _showMagnifier = true;
            // 将屏幕坐标转换为图片坐标系
            _magnifierSourcePosition = _convertScreenToImageCoordinates(vertices[i]);
            // 根据模式计算放大镜位置
            _magnifierPosition = _calculateMagnifierPosition(localPosition, _magnifierSourcePosition);
          }
        });
        // 触发顶点拖动开始回调
        widget.onVertexDragStart?.call(i, vertices[i]);
        return;
      }
    }
    
    // 检查是否点击在边上
    for (int i = 0; i < vertices.length; i++) {
      final nextIndex = (i + 1) % vertices.length;
      if (_isPointNearEdge(localPosition, vertices[i], vertices[nextIndex])) {
        setState(() {
          draggedEdgeIndex = i;
          draggedVertexIndex = -1;
          isDragging = true;
        });
        // 触发边拖动开始回调
        widget.onEdgeDragStart?.call(i, localPosition);
        return;
      }
    }
    
    // 重置拖动状态
    setState(() {
      draggedVertexIndex = -1;
      draggedEdgeIndex = -1;
      isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }

  /// 更新拖动手势
  void _onPanUpdate(DragUpdateDetails details) {
    final localPosition = details.localPosition;
    final delta = localPosition - dragStartOffset;
    
    if (draggedVertexIndex != -1) {
      // 拖动顶点
      setState(() {
        final startVertex = dragStartRectangle!.getVertex(draggedVertexIndex);
        final newPosition = startVertex + delta;
        final clampedPosition = _clampToImageBounds(newPosition);
        rectangle?.setVertex(draggedVertexIndex, clampedPosition);
        
        // 更新放大镜位置
        if (widget.enableMagnifier && _showMagnifier) {
          // 将屏幕坐标转换为图片坐标系
          _magnifierSourcePosition = _convertScreenToImageCoordinates(clampedPosition);
          // 根据模式计算放大镜位置
          _magnifierPosition = _calculateMagnifierPosition(localPosition, _magnifierSourcePosition);
        }
        
        // 触发回调
        if (rectangle != null) {
          widget.onVerticesChanged?.call(rectangle!);
        }
      });
    } else if (draggedEdgeIndex != -1) {
      // 拖动边（移动整个四边形）
      setState(() {
        final startVertices = dragStartRectangle!.vertices;
        final newVertices = <Offset>[];
        bool canMove = true;
        
        // 先检查所有顶点移动后是否都在边界内
        for (int i = 0; i < startVertices.length; i++) {
          final newPosition = startVertices[i] + delta;
          final clampedPosition = _clampToImageBounds(newPosition);
          newVertices.add(clampedPosition);
          
          // 如果任何顶点被限制，则不允许整体移动
          if ((newPosition - clampedPosition).distance > 0.1) {
            canMove = false;
            break;
          }
        }
        
        if (canMove) {
          for (int i = 0; i < newVertices.length; i++) {
            rectangle?.setVertex(i, newVertices[i]);
          }
          // 触发回调
          if (rectangle != null) {
            widget.onVerticesChanged?.call(rectangle!);
          }
        }
      });
    }
  }

  /// 结束拖动手势
  void _onPanEnd(DragEndDetails details) {
    // 在拖拽结束后验证和重排四边形
    setState(() {
      rectangle?.validateQuadrilateral();
    });
    
    // 触发拖动结束回调
    if (draggedVertexIndex != -1) {
      if (rectangle != null) {
        widget.onVertexDragEnd?.call(draggedVertexIndex, rectangle!.getVertex(draggedVertexIndex));
      }
    } else if (draggedEdgeIndex != -1) {
      widget.onEdgeDragEnd?.call(draggedEdgeIndex, details.localPosition);
    }
    
    setState(() {
      draggedVertexIndex = -1;
      draggedEdgeIndex = -1;
      isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }

  /// 检查点是否靠近顶点
  bool _isPointNearVertex(Offset point, Offset vertex) {
    return GeometryUtils.isPointNearVertex(point, vertex);
  }

  /// 检查点是否靠近边
  bool _isPointNearEdge(Offset point, Offset start, Offset end) {
    return GeometryUtils.isPointNearEdge(point, start, end);
  }

  /// 将坐标限制在图片显示区域边界内
  /// 这确保顶点只能在图片的实际显示范围内移动
  Offset _clampToImageBounds(Offset position) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.clampToImageBounds(position, imageInfo);
  }



  /// 获取图片信息（包含真实尺寸和显示信息）
  /// 根据图片和容器的长宽比自动选择最佳适配方式
  QuadImageInfo _getImageInfo() {
    if (_imageInfo != null) {
      return _imageInfo!;
    }
    
    _imageInfo = ImageUtils.getImageInfo(
      _loadedImage!,
      widget.width,
      widget.height,
    );
    
    return _imageInfo!;
  }
  
  /// 将屏幕坐标转换为图片坐标系（用于放大镜）
  Offset _convertScreenToImageCoordinates(Offset screenPoint) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.convertScreenToImageCoordinates(screenPoint, imageInfo);
  }

  /// 将视图坐标转换为图片真实坐标
  List<Offset> convertToImageCoordinates(List<Offset> viewCoordinates) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.convertToImageCoordinates(viewCoordinates, imageInfo);
  }
  
  /// 将图片真实坐标转换为视图坐标
  List<Offset> convertToViewCoordinates(List<Offset> imageCoordinates) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.convertToViewCoordinates(imageCoordinates, imageInfo);
  }
  
  /// 获取当前矩形特征
   RectangleFeature getRectangle() {
     return rectangle?.copy() ?? RectangleFeature.fromVertices([]);
   }
  
  /// 获取当前顶点坐标（视图坐标）
  List<Offset> getVertices() {
    return rectangle?.vertices ?? [];
  }
  
  /// 获取当前顶点的图片真实坐标
  List<Offset> getImageVertices() {
    return rectangle != null ? convertToImageCoordinates(rectangle!.vertices) : [];
  }

  /// 设置矩形特征（会自动应用边界限制）
  void setRectangle(RectangleFeature newRectangle) {
    setState(() {
      // 对每个顶点应用边界限制
      final clampedVertices = newRectangle.vertices.map((vertex) => _clampToImageBounds(vertex)).toList();
      rectangle = RectangleFeature.fromVertices(clampedVertices);
      // 验证四边形正确性
      rectangle?.validateQuadrilateral();
    });
    if (rectangle != null) {
      widget.onVerticesChanged?.call(rectangle!);
    }
  }
  
  /// 设置顶点坐标（会自动应用边界限制）
  void setVertices(List<Offset> newVertices) {
    if (newVertices.length == 4) {
      setRectangle(RectangleFeature.fromVertices(newVertices));
    }
  }

  /// 重置为默认顶点坐标（会自动应用边界限制）
  void resetVertices() {
    setRectangle(_getDefaultRectangle());
  }
}