import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rectangle_detector/rectangle_detector.dart';

import 'gesture_recognizer.dart';
import 'quad_annotation.dart';
import 'quad_annotator_controller.dart';
import 'quadrilateral_painter.dart';
import 'types.dart';
import 'utils/coordinate_utils.dart';
import 'utils/geometry_utils.dart';
import 'utils/image_utils.dart';
import 'utils/magnifier_utils.dart';

/// 四边形标注组件
/// 支持在图片上绘制和编辑四边形区域
class QuadAnnotatorBox extends StatefulWidget {
  /// 背景图片对象（用于显示和获取真实尺寸）
  final ui.Image? image;

  /// 图片提供者（用于显示图片，可选）
  final ImageProvider? imageProvider;

  /// 初始矩形特征（图片真实坐标系），如果不提供则使用默认值
  final QuadAnnotation? rectangle;

  /// 顶点坐标变化时的回调函数
  final OnVerticesChanged? onVerticesChanged;

  /// 顶点拖动开始时的回调函数（传递图片坐标系中的位置）
  final OnVertexDragStart? onVertexDragStart;

  /// 顶点拖动结束时的回调函数（传递图片坐标系中的位置）
  final OnVertexDragEnd? onVertexDragEnd;

  /// 边拖动开始时的回调函数（传递图片坐标系中的位置）
  final OnEdgeDragStart? onEdgeDragStart;

  /// 边拖动结束时的回调函数（传递图片坐标系中的位置）
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

  /// 是否自动检测图片中的矩形
  /// 当为 true 时，如果没有提供初始矩形，会尝试自动检测图片中的矩形
  /// 当为 false 时，直接使用默认矩形，不进行自动检测
  final bool autoDetect;

  /// 是否为预览模式
  /// 当为 true 时，禁止手势操作、禁用放大镜、禁止自动检测矩形
  final bool preview;

  /// 控制器，用于外部控制组件状态
  final QuadAnnotatorController? controller;

  /// 基础构造函数，直接接收ui.Image对象
  const QuadAnnotatorBox({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.controller,
    this.rectangle,
    this.onVerticesChanged,
    this.onVertexDragStart,
    this.onVertexDragEnd,
    this.onEdgeDragStart,
    this.onEdgeDragEnd,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.errorColor = Colors.red,
    this.fillColor = Colors.transparent,
    this.vertexColor = Colors.white,
    this.highlightColor = Colors.green,
    this.vertexRadius = 8.0,
    this.borderWidth = 2.0,
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
    this.magnifierCrosshairColor = Colors.white,
    this.magnifierCrosshairRadius = 0.3,
    this.magnifierPositionMode = MagnifierPositionMode.edge,
    this.magnifierCornerPosition = MagnifierCornerPosition.topLeft,
    this.magnifierEdgeOffset = 20.0,
    this.magnifierShape = MagnifierShape.circle,
    this.autoDetect = true,
    this.preview = false,
  }) : imageProvider = null;

  /// 从ImageProvider创建QuadAnnotatorBox的便捷构造函数
  const QuadAnnotatorBox.fromProvider({
    super.key,
    required this.imageProvider,
    required this.width,
    required this.height,
    this.controller,
    this.rectangle,
    this.onVerticesChanged,
    this.onVertexDragStart,
    this.onVertexDragEnd,
    this.onEdgeDragStart,
    this.onEdgeDragEnd,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.white,
    this.errorColor = Colors.red,
    this.fillColor = Colors.transparent,
    this.vertexColor = Colors.white,
    this.highlightColor = Colors.green,
    this.vertexRadius = 8.0,
    this.borderWidth = 2.0,
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
    this.magnifierCrosshairColor = Colors.white,
    this.magnifierCrosshairRadius = 0.3,
    this.magnifierPositionMode = MagnifierPositionMode.edge,
    this.magnifierCornerPosition = MagnifierCornerPosition.topLeft,
    this.magnifierEdgeOffset = 20.0,
    this.magnifierShape = MagnifierShape.circle,
    this.autoDetect = true,
    this.preview = false,
  }) : image = null;

  @override
  State<QuadAnnotatorBox> createState() => _QuadAnnotatorBoxState();
}

class _QuadAnnotatorBoxState extends State<QuadAnnotatorBox>
    with TickerProviderStateMixin {
  /// 矩形特征对象
  QuadAnnotation? _rectangle;

  /// 获取图片坐标系的矩形特征对象
  /// 返回转换为图片真实坐标的 QuadAnnotation 对象，如果当前没有矩形则返回 null
  QuadAnnotation? get _imageQuad {
    if (_rectangle == null) return null;
    final imageVertices = _convertToImageCoordinates(_rectangle!.vertices);
    return QuadAnnotation.fromVertices(imageVertices);
  }

  /// 当前拖动的顶点索引，-1表示没有拖动顶点
  int _draggedVertexIndex = -1;

  /// 当前拖动的边索引，-1表示没有拖动边
  int _draggedEdgeIndex = -1;

  /// 是否正在拖动状态
  bool _isDragging = false;

  /// 拖动开始时的偏移量
  Point<double> _dragStartPosition = const Point(0, 0);

  /// 拖动开始时的矩形特征
  QuadAnnotation? _dragStartRectangle;

  /// 图片信息缓存
  QuadImageInfo? _cachedImageInfo;

  /// 保存第一次进入时的初始坐标（图片坐标系），用于重置功能
  QuadAnnotation? _initialImageRectangleFeature;

  /// 获取图片信息（懒加载）
  /// 根据图片和容器的长宽比自动选择最佳适配方式
  /// 返回包含真实尺寸和显示信息的图片信息对象
  QuadImageInfo get _imageInfo {
    return _cachedImageInfo ??= ImageUtils.getImageInfo(
      _loadedImage!,
      widget.width,
      widget.height,
    );
  }

  /// 清空图片信息缓存
  /// 在图片或容器尺寸变化时调用，强制重新计算图片布局信息
  void _clearImageInfoCache() {
    _cachedImageInfo = null;
  }

  /// 呼吸灯动画控制器
  late AnimationController _breathingController;

  /// 呼吸灯动画
  late Animation<double> _breathingAnimation;

  /// 是否显示放大镜
  bool _showMagnifier = false;

  /// 放大镜位置
  Point<double> _magnifierPosition = const Point(0, 0);

  /// 放大镜中心对应的原图位置
  Point<double> _magnifierSourcePosition = const Point(0, 0);

  /// 异步加载的图片对象
  ui.Image? _loadedImage;

  /// 构建Widget
  @override
  Widget build(BuildContext context) {
    // 如果图片还未加载完成 | 矩形还未初始化，显示加载占位符
    if (_loadedImage == null || _rectangle == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: widget.backgroundColor,
        child: const Center(child: CircularProgressIndicator()),
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
                child: RawImage(image: _loadedImage, fit: BoxFit.contain),
              ),
              // 四边形绘制层
              CustomPaint(
                painter: QuadrilateralPainter(
                  image: _loadedImage!,
                  vertices: _rectangle!.vertices,
                  rectangle: _rectangle!,
                  draggedVertexIndex: _draggedVertexIndex,
                  draggedEdgeIndex: _draggedEdgeIndex,
                  borderColor: widget.borderColor,
                  errorColor: widget.errorColor,
                  fillColor: widget.fillColor,
                  vertexColor: widget.vertexColor,
                  highlightColor: widget.highlightColor,
                  vertexRadius: widget.vertexRadius,
                  borderWidth: widget.borderWidth,
                  maskColor: widget.maskColor,
                  breathingAnimation: _breathingAnimation.value,
                  breathingColor: widget.breathingColor,
                  breathingGap: widget.breathingGap,
                  breathingStrokeWidth: widget.breathingStrokeWidth,
                  enableBreathing: widget.enableBreathing,
                  enableMagnifier: widget.preview
                      ? false
                      : widget.enableMagnifier,
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
                child: widget.preview
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      )
                    : RawGestureDetector(
                        gestures: {
                          SingleTouchPanGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                SingleTouchPanGestureRecognizer
                              >(() => SingleTouchPanGestureRecognizer(), (
                                SingleTouchPanGestureRecognizer instance,
                              ) {
                                instance
                                  ..onStart = _onPanStart
                                  ..onUpdate = _onPanUpdate
                                  ..onEnd = _onPanEnd;
                              }),
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

  @override
  void initState() {
    super.initState();

    // 设置控制器回调函数
    if (widget.controller != null) {
      widget.controller!.onImageVertices = (() => _getImageVertices());
      widget.controller!.onReset = () => _resetVertices();
      widget.controller!.onDragging = (() => _isDragging);
    }

    // 初始化呼吸灯动画控制器
    _breathingController = AnimationController(
      duration: widget.breathingDuration,
      vsync: this,
    );

    // 创建呼吸灯动画（透明度从配置的最小值到最大值循环变化）
    _breathingAnimation =
        Tween<double>(
          begin: widget.breathingOpacityMin,
          end: widget.breathingOpacityMax,
        ).animate(
          CurvedAnimation(
            parent: _breathingController,
            curve: Curves.easeInOut,
          ),
        );

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

  @override
  void dispose() {
    // 释放动画控制器资源
    _breathingController.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  /// 当Widget配置更新时调用（例如屏幕方向变化）
  @override
  void didUpdateWidget(QuadAnnotatorBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查图片或图片提供者是否发生变化
    if (oldWidget.image != widget.image ||
        oldWidget.imageProvider != widget.imageProvider) {
      _clearImageInfoCache();

      // 按照 initState 的逻辑：优先使用 imageProvider，否则使用 image
      if (widget.imageProvider != null) {
        _loadedImage = null;
        _loadImageFromProvider();
      } else {
        _loadedImage = widget.image;
        _initializeRectangle();
      }
    }

    // 检查矩形参数是否发生变化
    if (oldWidget.rectangle != widget.rectangle) {
      _initializeRectangle();
    }

    // 如果组件尺寸发生变化，保持四边形的相对位置
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _handleSizeChange();
    }
  }

  /// 处理组件尺寸变化时的四边形位置调整
  /// 当容器尺寸发生变化时，保持四边形在图片中的相对位置不变
  void _handleSizeChange() {
    // 保存当前四边形在图片中的真实坐标
    final savedImageCoordinates = _saveCurrentImageCoordinates();

    // 清除图片信息缓存以重新计算布局
    _clearImageInfoCache();

    // 根据保存的坐标恢复四边形位置
    _restoreQuadrilateralPosition(savedImageCoordinates);
  }

  /// 保存第一次进入时的初始坐标（图片坐标系）
  /// 将当前UI坐标转换为图片坐标系并保存，用于重置功能
  void _saveInitialImageCoordinates() {
    if (_rectangle == null) return;

    // 使用现有的坐标转换方法将UI坐标转换为图片坐标
    final imageVertices = _convertToImageCoordinates(_rectangle!.vertices);
    _initialImageRectangleFeature = QuadAnnotation.fromVertices(imageVertices);
  }

  /// 保存当前四边形在图片中的真实坐标
  /// 返回图片坐标系中的顶点列表，如果无法保存则返回null
  List<Point<double>>? _saveCurrentImageCoordinates() {
    if (_rectangle == null) return null;

    final oldImageInfo = _cachedImageInfo;
    if (oldImageInfo == null) return null;

    // 使用旧的图片信息将当前视图坐标转换为图片坐标
    return _rectangle!.vertices.map((viewPoint) {
      // 减去图片在容器中的偏移量
      final adjustedPoint = viewPoint.subtractOffset(oldImageInfo.offset);

      // 计算在显示图片中的相对位置（0-1）
      final relativeX = adjustedPoint.x / oldImageInfo.displaySize.width;
      final relativeY = adjustedPoint.y / oldImageInfo.displaySize.height;

      // 转换为图片真实坐标
      final realX = relativeX * oldImageInfo.realSize.width;
      final realY = relativeY * oldImageInfo.realSize.height;

      return Point(realX, realY);
    }).toList();
  }

  /// 根据保存的图片坐标恢复四边形位置
  /// [savedImageCoordinates] 图片坐标系中的顶点列表
  void _restoreQuadrilateralPosition(
    List<Point<double>>? savedImageCoordinates,
  ) {
    if (savedImageCoordinates != null) {
      // 获取新的图片信息
      final newImageInfo = _imageInfo;

      // 将保存的图片坐标转换为新布局下的视图坐标
      final newViewCoordinates = savedImageCoordinates.map((imagePoint) {
        // 计算在图片中的相对位置（0-1）
        final relativeX = imagePoint.x / newImageInfo.realSize.width;
        final relativeY = imagePoint.y / newImageInfo.realSize.height;

        // 转换为显示坐标
        final displayX = relativeX * newImageInfo.displaySize.width;
        final displayY = relativeY * newImageInfo.displaySize.height;

        // 加上图片在容器中的偏移量
        return Point(displayX, displayY).addOffset(newImageInfo.offset);
      }).toList();

      // 更新四边形顶点位置
      for (int i = 0; i < newViewCoordinates.length && i < 4; i++) {
        _rectangle?.setVertex(i, newViewCoordinates[i]);
      }

      // 验证四边形正确性
      _rectangle?.validateQuadrilateral();
    } else {
      // 如果没有保存的坐标，使用默认矩形
      _rectangle = _getDefaultRectangle();
    }
  }

  /// 获取默认的矩形特征（基于图片显示区域）
  QuadAnnotation _getDefaultRectangle() {
    final imageInfoData = _imageInfo;
    // 根据顶点半径计算内边距，确保顶点完全显示且有适当间距
    final padding = widget.vertexRadius;

    // 计算图片显示区域的边界
    final left = imageInfoData.offset.dx;
    final top = imageInfoData.offset.dy;
    final right = left + imageInfoData.displaySize.width;
    final bottom = top + imageInfoData.displaySize.height;

    return QuadAnnotation(
      topLeft: Point(left + padding, top + padding),
      topRight: Point(right - padding, top + padding),
      bottomRight: Point(right - padding, bottom - padding),
      bottomLeft: Point(left + padding, bottom - padding),
    );
  }

  /// 初始化矩形特征
  /// 如果没有提供 rectangle，则尝试使用 rectangle_detector 自动检测
  /// 如果检测失败，则使用默认矩形
  void _initializeRectangle() async {
    if (_loadedImage != null) {
      QuadAnnotation? detectedRectangle;

      // 如果没有提供初始矩形且启用了自动检测且不是预览模式，尝试自动检测
      if (widget.rectangle == null && widget.autoDetect && !widget.preview) {
        try {
          detectedRectangle = await _detectRectangleFromImage();
        } catch (e) {
          // 检测失败，使用默认矩形
        }
      }

      // 初始化矩形特征：优先使用提供的初始矩形，其次使用检测到的矩形，最后使用默认矩形
      QuadAnnotation? initialQuad;
      if (widget.rectangle != null) {
        // 将图片真实坐标转换为视图坐标
        final imageVertices = widget.rectangle!.vertices;
        final viewVertices = _convertToViewCoordinates(imageVertices);
        initialQuad = QuadAnnotation.fromVertices(viewVertices);
      }

      _rectangle = initialQuad ?? detectedRectangle ?? _getDefaultRectangle();

      // 保存第一次进入时的初始坐标（图片坐标系），用于重置功能
      _saveInitialImageCoordinates();

      // 验证初始四边形正确性
      _rectangle?.validateQuadrilateral();

      // 触发重建以显示矩形
      if (mounted) {
        setState(() {});
        // 在下一帧触发初始矩形的顶点变化回调，避免在构建过程中调用setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onVerticesChanged();
          }
        });
      }
    }
  }

  /// 从ImageProvider异步加载图片
  Future<void> _loadImageFromProvider() async {
    if (widget.imageProvider != null) {
      try {
        final image = await ImageUtils.loadImageFromProvider(
          widget.imageProvider!,
        );

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

  /// 计算放大镜位置
  /// [gesturePosition] 手势位置
  /// [sourcePosition] 源位置（图片坐标系）
  /// 返回放大镜应该显示的位置
  Point<double> _calculateMagnifierPosition(
    Point<double> gesturePosition,
    Point<double> sourcePosition,
  ) {
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

  /// 更新组件状态的统一方法
  /// [callback] 状态更新回调函数
  void _updateState(VoidCallback callback) {
    setState(callback);
  }

  /// 检查点是否靠近顶点
  bool _isPointNearVertex(Point<double> point, Point<double> vertex) {
    return GeometryUtils.isPointNearVertex(point, vertex);
  }

  /// 检查点是否靠近边
  bool _isPointNearEdge(
    Point<double> point,
    Point<double> start,
    Point<double> end,
  ) {
    return GeometryUtils.isPointNearEdge(point, start, end);
  }

  /// 将坐标限制在图片显示区域边界内
  /// 这确保顶点只能在图片的实际显示范围内移动
  Point<double> _clampToImageBounds(Point<double> position) {
    final imageInfoData = _imageInfo;
    return CoordinateUtils.clampToImageBounds(position, imageInfoData);
  }

  /// 将屏幕坐标转换为图片坐标系（用于放大镜）
  Point<double> _convertScreenToImageCoordinates(Point<double> screenPoint) {
    final imageInfoData = _imageInfo;
    return CoordinateUtils.convertScreenToImageCoordinates(
      screenPoint,
      imageInfoData,
    );
  }

  /// 将视图坐标转换为图片真实坐标
  List<Point<double>> _convertToImageCoordinates(
    List<Point<double>> viewCoordinates,
  ) {
    final imageInfoData = _imageInfo;
    return CoordinateUtils.convertToImageCoordinates(
      viewCoordinates,
      imageInfoData,
    );
  }

  /// 将图片真实坐标转换为视图坐标
  List<Point<double>> _convertToViewCoordinates(
    List<Point<double>> imageCoordinates,
  ) {
    final imageInfoData = _imageInfo;
    return CoordinateUtils.convertToViewCoordinates(
      imageCoordinates,
      imageInfoData,
    );
  }

  /// 获取当前顶点的图片真实坐标
  List<Point<double>> _getImageVertices() {
    return _rectangle != null
        ? _convertToImageCoordinates(_rectangle!.vertices)
        : [];
  }

  /// 设置矩形特征（会自动应用边界限制）
  void setRectangle(QuadAnnotation newRectangle) {
    setState(() {
      // 对每个顶点应用边界限制
      final clampedVertices = newRectangle.vertices
          .map((vertex) => _clampToImageBounds(vertex))
          .toList();
      _rectangle = QuadAnnotation.fromVertices(clampedVertices);
      // 验证四边形正确性
      _rectangle?.validateQuadrilateral();
    });
    _onVerticesChanged();
  }

  /// 重置顶点到初始位置
  /// 如果保存了初始坐标，则恢复到初始坐标；否则使用默认矩形
  void _resetVertices() {
    if (_initialImageRectangleFeature != null) {
      // 将保存的图片坐标转换为当前视图坐标
      final viewVertices = _convertToViewCoordinates(
        _initialImageRectangleFeature!.vertices,
      );
      setRectangle(QuadAnnotation.fromVertices(viewVertices));
    } else {
      setRectangle(_getDefaultRectangle());
    }
  }

  /// 使用 rectangle_detector 检测图片中的矩形特征点
  /// 返回检测到的矩形，如果检测失败则返回 null
  Future<QuadAnnotation?> _detectRectangleFromImage() async {
    if (_loadedImage == null) {
      return null;
    }

    try {
      // 将图片转换为字节数据
      // 使用 rawRgba 格式确保跨平台兼容性，避免 iOS 平台的 INVALID_IMAGE 错误
      final byteData = await _loadedImage!.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        return null;
      }

      final imageBytes = byteData.buffer.asUint8List();

      // 使用 rectangle_detector 检测矩形
      final result = await RectangleDetector.detectRectangle(imageBytes);

      if (result != null) {
        final annotation = QuadAnnotation.fromRectangleFeature(result);
        final viewVertices = _convertToViewCoordinates(annotation.vertices);
        return QuadAnnotation.fromVertices(viewVertices);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

/// 手势处理扩展
/// 将手势拖动相关的回调方法统一管理，提高代码的模块化程度
extension _GestureHandlers on _QuadAnnotatorBoxState {
  /// 处理拖动开始手势
  /// [details] 拖动开始的详细信息
  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition.toPoint();
    _dragStartPosition = localPosition;
    _dragStartRectangle = _rectangle?.copy();

    final vertices = _rectangle?.vertices ?? [];

    // 检查是否点击在顶点上
    for (int i = 0; i < vertices.length; i++) {
      if (_isPointNearVertex(localPosition, vertices[i])) {
        _updateState(() {
          _draggedVertexIndex = i;
          _draggedEdgeIndex = -1;
          _isDragging = true;
          // 启用放大镜效果
          if (widget.enableMagnifier) {
            _showMagnifier = true;
            // 将屏幕坐标转换为图片坐标系
            _magnifierSourcePosition = _convertScreenToImageCoordinates(
              vertices[i],
            );
            // 根据模式计算放大镜位置
            _magnifierPosition = _calculateMagnifierPosition(
              localPosition,
              _magnifierSourcePosition,
            );
          }
        });
        // 触发顶点拖动开始回调（传递图片坐标）
        final imageCoordinates = _convertToImageCoordinates([vertices[i]]);
        widget.onVertexDragStart?.call(i, imageCoordinates.first);
        return;
      }
    }

    // 检查是否点击在边上
    for (int i = 0; i < vertices.length; i++) {
      final nextIndex = (i + 1) % vertices.length;
      if (_isPointNearEdge(localPosition, vertices[i], vertices[nextIndex])) {
        _updateState(() {
          _draggedEdgeIndex = i;
          _draggedVertexIndex = -1;
          _isDragging = true;
        });
        // 触发边拖动开始回调（传递图片坐标）
        final imageCoordinates = _convertToImageCoordinates([localPosition]);
        widget.onEdgeDragStart?.call(i, imageCoordinates.first);
        return;
      }
    }

    // 重置拖动状态
    _updateState(() {
      _draggedVertexIndex = -1;
      _draggedEdgeIndex = -1;
      _isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }

  /// 处理拖动更新手势
  /// [details] 拖动更新的详细信息
  void _onPanUpdate(DragUpdateDetails details) {
    final localPosition = details.localPosition.toPoint();
    final delta = localPosition - _dragStartPosition;

    if (_draggedVertexIndex != -1) {
      // 拖动顶点
      _handleVertexDrag(localPosition, delta);
    } else if (_draggedEdgeIndex != -1) {
      // 拖动边（移动整个四边形）
      _handleEdgeDrag(delta);
    }
  }

  /// 处理拖动结束手势
  /// [details] 拖动结束的详细信息
  void _onPanEnd(DragEndDetails details) {
    // 在拖拽结束后验证和重排四边形
    _updateState(() {
      _rectangle?.validateQuadrilateral();
    });

    // 触发拖动结束回调
    if (_draggedVertexIndex != -1) {
      _handleVertexDragEnd();
    } else if (_draggedEdgeIndex != -1) {
      _handleEdgeDragEnd(details.localPosition.toPoint());
    }

    // 重置拖动状态
    _resetDragState();
  }

  /// 处理顶点拖动
  /// [localPosition] 当前手势位置
  /// [delta] 位置变化量
  void _handleVertexDrag(Point<double> localPosition, Point<double> delta) {
    _updateState(() {
      final startVertex = _dragStartRectangle!.getVertex(_draggedVertexIndex);
      final newPosition = startVertex + delta;
      final clampedPosition = _clampToImageBounds(newPosition);
      _rectangle?.setVertex(_draggedVertexIndex, clampedPosition);

      // 更新放大镜位置
      if (widget.enableMagnifier && _showMagnifier) {
        // 将屏幕坐标转换为图片坐标系
        _magnifierSourcePosition = _convertScreenToImageCoordinates(
          clampedPosition,
        );
        // 根据模式计算放大镜位置
        _magnifierPosition = _calculateMagnifierPosition(
          localPosition,
          _magnifierSourcePosition,
        );
      }

      // 触发顶点变化回调
      _onVerticesChanged();
    });
  }

  /// 处理边拖动（移动整个四边形）
  /// [delta] 位置变化量
  void _handleEdgeDrag(Point<double> delta) {
    _updateState(() {
      final startVertices = _dragStartRectangle!.vertices;
      final newVertices = <Point<double>>[];
      bool canMove = true;

      // 先检查所有顶点移动后是否都在边界内
      for (int i = 0; i < startVertices.length; i++) {
        final newPosition = startVertices[i] + delta;
        final clampedPosition = _clampToImageBounds(newPosition);
        newVertices.add(clampedPosition);

        // 如果任何顶点被限制，则不允许整体移动
        if (newPosition.distanceTo(clampedPosition) > 0.1) {
          canMove = false;
          break;
        }
      }

      if (canMove) {
        for (int i = 0; i < newVertices.length; i++) {
          _rectangle?.setVertex(i, newVertices[i]);
        }
        // 触发顶点变化回调
        _onVerticesChanged();
      }
    });
  }

  /// 处理顶点拖动结束
  void _handleVertexDragEnd() {
    if (_rectangle != null) {
      // 将视图坐标转换为图片坐标
      final viewVertex = _rectangle!.getVertex(_draggedVertexIndex);
      final imageCoordinates = _convertToImageCoordinates([viewVertex]);
      widget.onVertexDragEnd?.call(_draggedVertexIndex, imageCoordinates.first);
    }
  }

  /// 处理边拖动结束
  /// [localPosition] 结束位置（视图坐标）
  void _handleEdgeDragEnd(Point<double> localPosition) {
    // 将视图坐标转换为图片坐标
    final imageCoordinates = _convertToImageCoordinates([localPosition]);
    widget.onEdgeDragEnd?.call(_draggedEdgeIndex, imageCoordinates.first);
  }

  /// 触发顶点变化回调
  void _onVerticesChanged() {
    if (_imageQuad != null) {
      widget.onVerticesChanged?.call(_imageQuad!);
    }
  }

  /// 重置拖动状态
  void _resetDragState() {
    _updateState(() {
      _draggedVertexIndex = -1;
      _draggedEdgeIndex = -1;
      _isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }
}
