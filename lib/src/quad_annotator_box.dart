import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'rectangle_feature.dart';

/// 单点触控拖拽手势识别器
/// 只允许第一个触摸点进行拖拽操作，忽略后续的触摸点
class _SingleTouchPanGestureRecognizer extends PanGestureRecognizer {
  int? _activePointer;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // 如果已经有活跃的触摸点，忽略新的触摸点
    if (_activePointer != null) {
      return;
    }
    
    _activePointer = event.pointer;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    // 只处理活跃触摸点的事件
    if (event.pointer == _activePointer) {
      super.handleEvent(event);
      
      // 如果触摸点抬起，重置活跃触摸点
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        _activePointer = null;
      }
    }
  }

  @override
  void dispose() {
    _activePointer = null;
    super.dispose();
  }
}

/// 放大镜位置模式
enum MagnifierPositionMode {
  /// 放大镜圆心在手势点击位置（默认模式）
  center,
  /// 放大镜固定在四个角之一
  corner,
  /// 放大镜边缘在手势点击位置，有偏移避免遮挡
  edge,
}

/// 放大镜角落位置
enum MagnifierCornerPosition {
  /// 左上角
  topLeft,
  /// 右上角
  topRight,
  /// 左下角
  bottomLeft,
  /// 右下角
  bottomRight,
}

/// 放大镜形状
enum MagnifierShape {
  circle,
  rectangle,
}

/// 四边形裁剪组件的回调函数类型定义
typedef OnVerticesChanged = void Function(RectangleFeature rectangle);

/// 顶点拖动开始时的回调函数类型定义
typedef OnVertexDragStart = void Function(int vertexIndex, Offset position);

/// 顶点拖动结束时的回调函数类型定义
typedef OnVertexDragEnd = void Function(int vertexIndex, Offset position);

/// 边拖动开始时的回调函数类型定义
typedef OnEdgeDragStart = void Function(int edgeIndex, Offset position);

/// 边拖动结束时的回调函数类型定义
typedef OnEdgeDragEnd = void Function(int edgeIndex, Offset position);

/// 图片信息类，包含图片的真实尺寸和显示尺寸
class QuadImageInfo {
  final Size realSize;    // 图片真实尺寸
  final Size displaySize; // 图片显示尺寸
  final Offset offset;    // 图片在容器中的偏移量
  
  const QuadImageInfo({
    required this.realSize,
    required this.displaySize,
    required this.offset,
  });
}

/// 四边形裁剪组件State类型定义（用于GlobalKey）
typedef QuadAnnotatorBoxState = _QuadAnnotatorBoxState;

/// 四边形裁剪组件
/// 支持在图片上绘制可拖动的四边形选区
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
    switch (widget.magnifierPositionMode) {
      case MagnifierPositionMode.center:
        // 模式1：放大镜圆心在手势位置（默认模式）
        return gesturePosition;
        
      case MagnifierPositionMode.corner:
        // 模式2：放大镜固定在四个角之一
        return _getCornerPosition();
        
      case MagnifierPositionMode.edge:
        // 模式3：放大镜边缘在手势位置，有偏移避免遮挡
        return _getEdgePosition(gesturePosition);
    }
  }

  /// 获取角落位置
  Offset _getCornerPosition() {
    final double radius = widget.magnifierRadius;
    final double margin = widget.magnifierEdgeOffset;
    
    switch (widget.magnifierCornerPosition) {
      case MagnifierCornerPosition.topLeft:
        return Offset(radius + margin, radius + margin);
      case MagnifierCornerPosition.topRight:
        return Offset(widget.width - radius - margin, radius + margin);
      case MagnifierCornerPosition.bottomLeft:
        return Offset(radius + margin, widget.height - radius - margin);
      case MagnifierCornerPosition.bottomRight:
        return Offset(widget.width - radius - margin, widget.height - radius - margin);
    }
  }

  /// 获取边缘位置（参考flutter_magnifier库的实现）
  Offset _getEdgePosition(Offset gesturePosition) {
    final double radius = widget.magnifierRadius;
    final double offset = widget.magnifierEdgeOffset;
    final Size widgetSize = Size(widget.width, widget.height);
    
    // 计算Y坐标：让放大镜底部与手势位置齐平
    double adjustedY = gesturePosition.dy - radius;
    
    // 默认尝试在左侧显示
    Offset targetPosition = Offset(
      gesturePosition.dx - radius - offset,
      adjustedY,
    );
    
    // 检查是否超出左边界，如果超出则显示在右侧
    if (targetPosition.dx - radius < 0) {
      targetPosition = Offset(
        gesturePosition.dx + radius + offset,
        adjustedY,
      );
    }
    
    // 检查是否超出右边界，如果超出则调整到右边界内
    if (targetPosition.dx + radius > widgetSize.width) {
      targetPosition = Offset(
        widgetSize.width - radius,
        targetPosition.dy,
      );
    }
    
    // 检查垂直方向边界
    if (targetPosition.dy - radius < 0) {
      targetPosition = Offset(
        targetPosition.dx,
        radius,
      );
    } else if (targetPosition.dy + radius > widgetSize.height) {
      targetPosition = Offset(
        targetPosition.dx,
        widgetSize.height - radius,
      );
    }
    
    return targetPosition;
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
        final Completer<ui.Image> completer = Completer<ui.Image>();
        final ImageStream stream = widget.imageProvider!.resolve(const ImageConfiguration());
        
        late ImageStreamListener listener;
        listener = ImageStreamListener(
          (flutter.ImageInfo info, bool synchronousCall) {
            completer.complete(info.image);
            stream.removeListener(listener);
          },
          onError: (dynamic exception, StackTrace? stackTrace) {
            completer.completeError(exception, stackTrace);
            stream.removeListener(listener);
          },
        );
        
        stream.addListener(listener);
        final image = await completer.future;
        
        if (mounted) {
          setState(() {
            _loadedImage = image;
          });
          _initializeRectangle();
        }
      } catch (e) {
        // 图片加载失败，保持_loadedImage为null
        print('Failed to load image: $e');
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
                    _SingleTouchPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_SingleTouchPanGestureRecognizer>(
                      () => _SingleTouchPanGestureRecognizer(),
                      (_SingleTouchPanGestureRecognizer instance) {
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
    const double threshold = 20.0;
    return (point - vertex).distance < threshold;
  }

  /// 检查点是否靠近边
  bool _isPointNearEdge(Offset point, Offset start, Offset end) {
    const double threshold = 15.0;
    
    // 计算点到线段的距离
    final double distance = _pointToLineDistance(point, start, end);
    
    // 检查点是否在线段范围内
    final double segmentLength = (end - start).distance;
    final double distanceToStart = (point - start).distance;
    final double distanceToEnd = (point - end).distance;
    
    return distance < threshold && 
           distanceToStart <= segmentLength + threshold && 
           distanceToEnd <= segmentLength + threshold;
  }

  /// 将坐标限制在图片显示区域边界内
  /// 这确保顶点只能在图片的实际显示范围内移动
  Offset _clampToImageBounds(Offset position) {
    final imageInfo = _getImageInfo();
    
    // 计算图片显示区域的边界
    final left = imageInfo.offset.dx;
    final top = imageInfo.offset.dy;
    final right = left + imageInfo.displaySize.width;
    final bottom = top + imageInfo.displaySize.height;
    
    return Offset(
      position.dx.clamp(left, right),
      position.dy.clamp(top, bottom),
    );
  }

  /// 计算点到线段的距离
  double _pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final double A = point.dx - lineStart.dx;
    final double B = point.dy - lineStart.dy;
    final double C = lineEnd.dx - lineStart.dx;
    final double D = lineEnd.dy - lineStart.dy;
    
    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      return (point - lineStart).distance;
    }
    
    final double param = dot / lenSq;
    
    Offset projection;
    if (param < 0) {
      projection = lineStart;
    } else if (param > 1) {
      projection = lineEnd;
    } else {
      projection = Offset(
        lineStart.dx + param * C,
        lineStart.dy + param * D,
      );
    }
    
    return (point - projection).distance;
  }

  /// 获取图片信息（包含真实尺寸和显示信息）
  /// 根据图片和容器的长宽比自动选择最佳适配方式
  QuadImageInfo _getImageInfo() {
    if (_imageInfo != null) {
      return _imageInfo!;
    }
    
    // 从Image对象获取真实尺寸
    final realSize = Size(
      _loadedImage!.width.toDouble(),
      _loadedImage!.height.toDouble(),
    );
    
    // 计算显示尺寸和偏移量（自适应缩放）
    final containerSize = Size(widget.width, widget.height);
    final imageAspectRatio = realSize.width / realSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;
    
    double displayWidth, displayHeight, offsetX, offsetY;
    
    if (imageAspectRatio > containerAspectRatio) {
      // 图片更宽，按宽度适配
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspectRatio;
      offsetX = 0;
      offsetY = (containerSize.height - displayHeight) / 2;
    } else {
      // 图片更高，按高度适配
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspectRatio;
      offsetX = (containerSize.width - displayWidth) / 2;
      offsetY = 0;
    }
    
    // 确保偏移量不为负数
    offsetX = offsetX.clamp(0, double.infinity);
    offsetY = offsetY.clamp(0, double.infinity);
    
    // 确保显示尺寸不超出容器边界
    displayWidth = displayWidth.clamp(0, containerSize.width);
    displayHeight = displayHeight.clamp(0, containerSize.height);
    
    final displaySize = Size(displayWidth, displayHeight);
    final offset = Offset(offsetX, offsetY);
    
    _imageInfo = QuadImageInfo(
      realSize: realSize,
      displaySize: displaySize,
      offset: offset,
    );
    
    return _imageInfo!;
  }
  
  /// 将屏幕坐标转换为图片坐标系（用于放大镜）
  Offset _convertScreenToImageCoordinates(Offset screenPoint) {
    final imageInfo = _getImageInfo();
    
    // 减去图片在容器中的偏移量
    final adjustedPoint = screenPoint - imageInfo.offset;
    
    // 计算在显示图片中的相对位置（0-1）
    final relativeX = (adjustedPoint.dx / imageInfo.displaySize.width).clamp(0.0, 1.0);
    final relativeY = (adjustedPoint.dy / imageInfo.displaySize.height).clamp(0.0, 1.0);
    
    // 转换为图片真实坐标
    final realX = relativeX * imageInfo.realSize.width;
    final realY = relativeY * imageInfo.realSize.height;
    
    return Offset(realX, realY);
  }

  /// 将视图坐标转换为图片真实坐标
  List<Offset> convertToImageCoordinates(List<Offset> viewCoordinates) {
    final imageInfo = _getImageInfo();
    
    return viewCoordinates.map((viewPoint) {
      // 减去图片在容器中的偏移量
      final adjustedPoint = viewPoint - imageInfo.offset;
      
      // 计算在显示图片中的相对位置（0-1）
      final relativeX = adjustedPoint.dx / imageInfo.displaySize.width;
      final relativeY = adjustedPoint.dy / imageInfo.displaySize.height;
      
      // 转换为图片真实坐标
      final realX = relativeX * imageInfo.realSize.width;
      final realY = relativeY * imageInfo.realSize.height;
      
      return Offset(realX, realY);
    }).toList();
  }
  
  /// 将图片真实坐标转换为视图坐标
  List<Offset> convertToViewCoordinates(List<Offset> imageCoordinates) {
    final imageInfo = _getImageInfo();
    
    return imageCoordinates.map((imagePoint) {
      // 计算在图片中的相对位置（0-1）
      final relativeX = imagePoint.dx / imageInfo.realSize.width;
      final relativeY = imagePoint.dy / imageInfo.realSize.height;
      
      // 转换为显示坐标
      final displayX = relativeX * imageInfo.displaySize.width;
      final displayY = relativeY * imageInfo.displaySize.height;
      
      // 加上图片在容器中的偏移量
      return Offset(displayX, displayY) + imageInfo.offset;
    }).toList();
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

/// 自定义绘制器，用于绘制四边形和控制点
class QuadrilateralPainter extends CustomPainter {
  final List<Offset> vertices;
  final RectangleFeature rectangle;
  final int draggedVertexIndex;
  final int draggedEdgeIndex;
  final Color borderColor;
  final Color errorColor;
  final Color fillColor;
  final Color vertexColor;
  final Color highlightColor;
  final double vertexRadius;
  final double borderWidth;
  final bool showVertexNumbers;
  final Color maskColor;
  final double breathingAnimation;
  final Color breathingColor;
  final double breathingGap;
  final double breathingStrokeWidth;
  final bool enableBreathing;
  final bool enableMagnifier;
  final bool showMagnifier;
  final Offset magnifierPosition;
  final Offset magnifierSourcePosition;
  final double magnifierRadius;
  final double magnification;
  final Color magnifierBorderColor;
  final double magnifierBorderWidth;
  final Color magnifierCrosshairColor;
  final double magnifierCrosshairRadius;
  final MagnifierShape magnifierShape;
  final ui.Image image;

  QuadrilateralPainter({
    required this.image,
    required this.vertices,
    required this.rectangle,
    required this.draggedVertexIndex,
    required this.draggedEdgeIndex,
    required this.borderColor,
    required this.errorColor,
    required this.fillColor,
    required this.vertexColor,
    required this.highlightColor,
    required this.vertexRadius,
    required this.borderWidth,
    required this.showVertexNumbers,
    required this.maskColor,
    required this.breathingAnimation,
    required this.breathingColor,
    required this.breathingGap,
    required this.breathingStrokeWidth,
    required this.enableBreathing,
    required this.enableMagnifier,
    required this.showMagnifier,
    required this.magnifierPosition,
    required this.magnifierSourcePosition,
    required this.magnifierRadius,
    required this.magnification,
    required this.magnifierBorderColor,
    required this.magnifierBorderWidth,
    required this.magnifierCrosshairColor,
    required this.magnifierCrosshairRadius,
    required this.magnifierShape,
  });

  @override
  void paint(Canvas canvas, Size size) {    
    // 如果遮罩颜色不透明，绘制外部遮罩
    if (maskColor.alpha > 0) {
      _drawOuterMask(canvas, size);
    }
    
    // 绘制四边形填充
    _drawQuadrilateral(canvas);
    
    // 绘制顶点
    _drawVertices(canvas);
    
    // 绘制放大镜
    if (enableMagnifier && showMagnifier) {
      _drawMagnifier(canvas, size);
    }
  }

  /// 绘制外部遮罩效果
  void _drawOuterMask(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;
    
    // 创建整个画布的矩形路径
    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // 创建四边形内部路径
    final Path innerPath = Path();
    innerPath.moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      innerPath.lineTo(vertices[i].dx, vertices[i].dy);
    }
    innerPath.close();
    
    // 使用差集操作创建镂空效果
    final Path maskPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    
    // 绘制遮罩
    final Paint maskPaint = Paint()
      ..color = maskColor
      ..style = PaintingStyle.fill;
     
    canvas.drawPath(maskPath, maskPaint);
  }
 
    /// 绘制四边形（填充和边框）
  void _drawQuadrilateral(Canvas canvas) {
    if (vertices.isEmpty) return;
    
    final Path path = Path();
    path.moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();
    
    // 绘制填充
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    
    // 绘制边框（根据四边形验证结果选择颜色）
    final Paint linePaint = Paint()
      ..color = rectangle.hasError ? errorColor : borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
    
    // 高亮被拖动的边
    if (draggedEdgeIndex != -1) {
      final Paint highlightPaint = Paint()
        ..color = highlightColor
        ..strokeWidth = borderWidth + 2.0
        ..style = PaintingStyle.stroke;
      
      final int nextIndex = (draggedEdgeIndex + 1) % vertices.length;
      canvas.drawLine(
        vertices[draggedEdgeIndex],
        vertices[nextIndex],
        highlightPaint,
      );
    }
  }

  /// 绘制顶点
  void _drawVertices(Canvas canvas) {
    for (int i = 0; i < vertices.length; i++) {
      // 如果启用放大镜且当前顶点正在被拖动，则隐藏该顶点
      if (enableMagnifier && showMagnifier && draggedVertexIndex == i) {
        continue;
      }
      
      final Paint vertexPaint = Paint()
        ..color = draggedVertexIndex == i ? highlightColor : vertexColor
        ..style = PaintingStyle.fill;
      
      // 呼吸灯效果边框
      final Paint breathingBorderPaint = Paint()
        ..color = breathingColor.withOpacity(breathingAnimation)
        ..strokeWidth = breathingStrokeWidth
        ..style = PaintingStyle.stroke;
      
      final Paint borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      // 计算呼吸灯圆圈半径：顶点半径 + 间距 + 边框宽度的一半
      final double breathingRadius = vertexRadius + breathingGap + breathingStrokeWidth / 2;
      
      // 绘制顶点圆圈
      canvas.drawCircle(vertices[i], vertexRadius, vertexPaint);
      // 绘制呼吸灯边框（外层）- 仅在启用呼吸灯动画时绘制
      if (enableBreathing) {
        canvas.drawCircle(vertices[i], breathingRadius, breathingBorderPaint);
      }
      // 绘制普通边框（内层）
      canvas.drawCircle(vertices[i], vertexRadius, borderPaint);
      
      // 绘制顶点编号
      if (showVertexNumbers) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(
          canvas,
          vertices[i] - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  /// 绘制放大镜
  void _drawMagnifier(Canvas canvas, Size size) {
    // 保存画布状态
    canvas.save();
    
    // 根据形状创建裁剪区域
    final Path clipPath = Path();
    if (magnifierShape == MagnifierShape.circle) {
      clipPath.addOval(Rect.fromCircle(
        center: magnifierPosition,
        radius: magnifierRadius,
      ));
    } else {
      // 方形放大镜
      clipPath.addRect(Rect.fromCenter(
        center: magnifierPosition,
        width: magnifierRadius * 2,
        height: magnifierRadius * 2,
      ));
    }
    canvas.clipPath(clipPath);
    
    // 绘制放大的背景内容
    // 计算源区域（要放大的区域）
    final double sourceRadius = magnifierRadius / magnification;
    final Rect sourceRect = Rect.fromCenter(
      center: magnifierSourcePosition,
      width: sourceRadius * 2,
      height: sourceRadius * 2,
    );
    
    // 目标区域（放大镜圆形区域）
    final Rect destRect = Rect.fromCenter(
      center: magnifierPosition,
      width: magnifierRadius * 2,
      height: magnifierRadius * 2,
    );
    
    // 绘制放大的图片内容
    canvas.drawImageRect(
      image!,
      sourceRect,
      destRect,
      Paint(),
    );
      
    // 恢复画布状态
    canvas.restore();
    
    // 绘制放大镜边框
    final Paint borderPaint = Paint()
      ..color = magnifierBorderColor
      ..strokeWidth = magnifierBorderWidth
      ..style = PaintingStyle.stroke;
    
    if (magnifierShape == MagnifierShape.circle) {
      canvas.drawCircle(magnifierPosition, magnifierRadius, borderPaint);
    } else {
      canvas.drawRect(
        Rect.fromCenter(
          center: magnifierPosition,
          width: magnifierRadius * 2,
          height: magnifierRadius * 2,
        ),
        borderPaint,
      );
    }
    
    // 绘制准心十字线
    final Paint crosshairPaint = Paint()
      ..color = magnifierCrosshairColor
      ..strokeWidth = 1.5;
    
    final double crosshairLength = magnifierRadius * magnifierCrosshairRadius;
    
    // 水平线
    canvas.drawLine(
      Offset(magnifierPosition.dx - crosshairLength, magnifierPosition.dy),
      Offset(magnifierPosition.dx + crosshairLength, magnifierPosition.dy),
      crosshairPaint,
    );
    
    // 垂直线
    canvas.drawLine(
      Offset(magnifierPosition.dx, magnifierPosition.dy - crosshairLength),
      Offset(magnifierPosition.dx, magnifierPosition.dy + crosshairLength),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! QuadrilateralPainter) return true;
    
    return rectangle != oldDelegate.rectangle ||
        draggedVertexIndex != oldDelegate.draggedVertexIndex ||
        draggedEdgeIndex != oldDelegate.draggedEdgeIndex ||
        showMagnifier != oldDelegate.showMagnifier ||
        magnifierPosition != oldDelegate.magnifierPosition ||
        magnifierSourcePosition != oldDelegate.magnifierSourcePosition;
  }
}