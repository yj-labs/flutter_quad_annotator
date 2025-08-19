import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'virtual_dpad_widget.dart';

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

  /// 组件的宽度（可选，如果不提供则自动适应父容器）
  final double? width;

  /// 组件的高度（可选，如果不提供则自动适应父容器）
  final double? height;

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

  /// 呼吸动画配置
  final BreathingAnimation breathing;

  /// 放大镜配置
  final MagnifierConfiguration magnifier;

  /// 是否自动检测图片中的矩形
  /// 当为 true 时，如果没有提供初始矩形，会尝试自动检测图片中的矩形
  /// 当为 false 时，直接使用默认矩形，不进行自动检测
  final bool autoDetect;

  /// 是否为预览模式
  /// 当为 true 时，禁止手势操作、禁用放大镜、禁止自动检测矩形
  final bool preview;

  /// 是否允许拖动边框来移动整个四边形
  /// 当为 false 时，只能通过拖动顶点来调整四边形，不能拖动边框移动
  final bool allowEdgeDrag;

  /// 精调模式配置，传null则禁用精调模式
  final FineAdjustmentConfiguration? fineAdjustment;

  /// 控制器，用于外部控制组件状态
  final QuadAnnotatorController? controller;

  /// 基础构造函数，直接接收ui.Image对象
  const QuadAnnotatorBox({
    super.key,
    required this.image,
    this.width,
    this.height,
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
    this.breathing = const BreathingAnimation(),
    this.magnifier = const MagnifierConfiguration(),
    this.autoDetect = true,
    this.preview = false,
    this.allowEdgeDrag = true,
    this.fineAdjustment = const FineAdjustmentConfiguration(),
  }) : imageProvider = null;

  /// 从ImageProvider创建QuadAnnotatorBox的便捷构造函数
  const QuadAnnotatorBox.fromProvider({
    super.key,
    required this.imageProvider,
    this.width,
    this.height,
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
    this.breathing = const BreathingAnimation(),
    this.magnifier = const MagnifierConfiguration(),
    this.autoDetect = true,
    this.preview = false,
    this.allowEdgeDrag = true,
    this.fineAdjustment = const FineAdjustmentConfiguration(),
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

  /// 获取实际使用的宽度
  late double _actualWidth;

  /// 获取实际使用的高度
  late double _actualHeight;

  /// 获取图片信息（懒加载）
  /// 根据图片和容器的长宽比自动选择最佳适配方式
  /// 返回包含真实尺寸和显示信息的图片信息对象
  QuadImageInfo get _imageInfo {
    return _cachedImageInfo ??= ImageUtils.getImageInfo(
      _loadedImage!,
      _actualWidth,
      _actualHeight,
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

  /// 是否处于精调模式
  bool _isFineAdjustmentMode = false;

  /// 长按定时器
  Timer? _longPressTimer;

  /// 精调模式开始时的拖动位置
  Point<double> _fineAdjustmentStartPosition = const Point(0, 0);
  
  /// 是否处于虚拟方向键精调模式
  bool _isDPadMode = false;
  
  /// 当前选中的顶点索引（用于方向键模式）
  int _selectedVertexIndex = 0;
  
  /// 双击检测相关
  int _tapCount = 0;
  Timer? _doubleTapTimer;
  Point<double> _lastTapPosition = const Point(0, 0);
  
  /// 双击检测的时间窗口（毫秒）
  static const int _doubleTapTimeWindow = 300;
  
  /// 双击检测的距离阈值（像素）
  static const double _doubleTapDistanceThreshold = 20.0;

  /// 构建Widget
  @override
  Widget build(BuildContext context) {
    // 宽高给定了确定的值
    if (widget.width.isValid && widget.height.isValid) {
      _actualWidth = widget.width!;
      _actualHeight = widget.height!;
      return _buildContent();
    }
    // 检查是否需要自动获取尺寸
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据约束设置实际尺寸
        if (widget.width.isValid) {
          _actualWidth = widget.width!;
        } else {
          _actualWidth = constraints.maxWidth;
        }
        if (widget.height.isValid) {
          _actualHeight = widget.height!;
        } else {
          _actualHeight = constraints.maxHeight;
        }
        return _buildContent();
      },
    );
  }

  /// 构建主要内容
  /// 根据当前的实际尺寸构建四边形标注组件的主要内容
  Widget _buildContent() {
    // 如果图片还未加载完成 | 矩形还未初始化，显示加载占位符
    if (_loadedImage == null || _rectangle == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: widget.backgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: _actualWidth,
      height: _actualHeight,
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
                  draggedEdgeIndex: _draggedEdgeIndex,
                  selectedVertexIndex: _isDPadMode ? _selectedVertexIndex : (_isDragging ? _draggedVertexIndex : -1),
                  borderColor: widget.borderColor,
                  errorColor: widget.errorColor,
                  fillColor: widget.fillColor,
                  vertexColor: widget.vertexColor,
                  highlightColor: widget.highlightColor,
                  vertexRadius: widget.vertexRadius,
                  borderWidth: widget.borderWidth,
                  maskColor: widget.maskColor,
                  breathingAnimation: _breathingAnimation.value,
                  breathing: widget.breathing,
                  magnifier: widget.magnifier,
                  enableMagnifier:
                      widget.preview ? false : widget.magnifier.enabled,
                  showMagnifier: _showMagnifier,
                  magnifierPosition: _magnifierPosition,
                  magnifierSourcePosition: _magnifierSourcePosition,
                ),
                size: Size(_actualWidth, _actualHeight),
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
                                      SingleTouchPanGestureRecognizer>(
                                  () => SingleTouchPanGestureRecognizer(), (
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
              // 精调模式提示（仅在拖拽精调模式下显示）
              if (_isFineAdjustmentMode && !_isDPadMode)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.fineAdjustment?.hintBackgroundColor ?? const Color(0x88000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.fineAdjustment?.hintText ?? '精调模式：小幅度拖动进行精确调整',
                      style: widget.fineAdjustment?.hintTextStyle ?? const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              // 点击方向键以外区域退出精调模式
              if (_isDPadMode)
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      // 点击方向键以外的区域退出精调模式
                      _exitDPadMode();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              // 虚拟方向键组件
              if (_isDPadMode && widget.fineAdjustment != null)
                VirtualDPadWidget(
                  config: widget.fineAdjustment!.dpadConfig,
                  screenSize: Size(_actualWidth, _actualHeight),
                  selectedVertexIndex: _selectedVertexIndex,
                  totalVertices: _rectangle?.vertices.length ?? 4,
                  onDirectionPressed: _onDPadDirectionPressed,
                  onVertexChanged: _onDPadVertexChanged,
                  onExit: _exitDPadMode,
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
      duration: widget.breathing.duration,
      vsync: this,
    );

    // 创建呼吸灯动画（透明度从配置的最小值到最大值循环变化）
    _breathingAnimation = Tween<double>(
      begin: widget.breathing.opacityMin,
      end: widget.breathing.opacityMax,
    ).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // 根据配置决定是否启动循环动画
    if (widget.breathing.enabled) {
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
    _longPressTimer?.cancel();
    _doubleTapTimer?.cancel();
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

  /// 触发顶点变化回调
  void _onVerticesChanged() {
    if (_imageQuad != null) {
      widget.onVerticesChanged?.call(_imageQuad!);
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
  /// 只在第一次调用时保存，避免在didUpdate中被覆盖
  void _saveInitialImageCoordinates() {
    if (_rectangle == null) return;

    // 只在第一次调用时保存初始坐标，避免在didUpdate中被覆盖
    if (_initialImageRectangleFeature != null) return;

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
      widget.magnifier.positionMode,
      widget.magnifier.cornerPosition,
      widget.magnifier.edgeOffset,
      widget.magnifier.radius,
      Size(_actualWidth, _actualHeight),
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

  /// 启动长按定时器
  void _startLongPressTimer(Point<double> position) {
    if (widget.fineAdjustment == null) return;
    
    _longPressTimer?.cancel();
    _fineAdjustmentStartPosition = position;
    
    _longPressTimer = Timer(widget.fineAdjustment!.longPressDuration, () {
      // 只有在拖动顶点且手指基本没有移动的情况下才进入精调模式
      if (_draggedVertexIndex != -1 && !_isFineAdjustmentMode) {
        setState(() {
          _isFineAdjustmentMode = true;
        });
      }
    });
  }

  /// 取消长按定时器
  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  /// 检查手指是否移动过多（超过阈值则取消精调模式触发）
  void _checkFingerMovement(Point<double> currentPosition) {
    if (_longPressTimer != null && !_isFineAdjustmentMode) {
      const double movementThreshold = 10.0; // 10像素的移动阈值
      final distance = currentPosition.distanceTo(_fineAdjustmentStartPosition);
      
      if (distance > movementThreshold) {
        // 手指移动过多，取消精调模式触发
        _cancelLongPressTimer();
      }
    }
  }

  /// 退出精调模式
  void _exitFineAdjustmentMode() {
    if (_isFineAdjustmentMode) {
      setState(() {
        _isFineAdjustmentMode = false;
      });
    }
  }
  
  /// 进入虚拟方向键精调模式
  void _enterDPadMode(int vertexIndex) {
    if (widget.fineAdjustment == null) return;
    
    setState(() {
      _isDPadMode = true;
      _selectedVertexIndex = vertexIndex;
      // 显示放大镜
      if (widget.magnifier.enabled && _rectangle != null) {
        _showMagnifier = true;
        final vertex = _rectangle!.getVertex(vertexIndex);
        _magnifierSourcePosition = _convertScreenToImageCoordinates(vertex);
        _magnifierPosition = _calculateMagnifierPosition(
          vertex,
          _magnifierSourcePosition,
        );
      }
    });
  }
  
  /// 退出虚拟方向键精调模式
  void _exitDPadMode() {
    setState(() {
      _isDPadMode = false;
      _showMagnifier = false;
    });
  }
  
  /// 处理虚拟方向键方向按下
  void _onDPadDirectionPressed(double dx, double dy) {
    if (_rectangle == null || !_isDPadMode) return;
    
    if (widget.fineAdjustment?.dpadConfig.enableHapticFeedback == true) {
      // 添加震动反馈
      HapticFeedback.lightImpact();
    }
    
    final currentVertex = _rectangle!.getVertex(_selectedVertexIndex);
    final newPosition = Point(currentVertex.x + dx, currentVertex.y + dy);
    final clampedPosition = _clampToImageBounds(newPosition);
    
    setState(() {
      _rectangle!.setVertex(_selectedVertexIndex, clampedPosition);
      
      // 更新放大镜位置
      if (widget.magnifier.enabled && _showMagnifier) {
        _magnifierSourcePosition = _convertScreenToImageCoordinates(clampedPosition);
        _magnifierPosition = _calculateMagnifierPosition(
          clampedPosition,
          _magnifierSourcePosition,
        );
      }
    });
    
    // 触发顶点变化回调
    _onVerticesChanged();
  }
  
  /// 处理虚拟方向键顶点切换
  void _onDPadVertexChanged(int vertexIndex) {
    if (_rectangle == null || !_isDPadMode) return;
    
    if (widget.fineAdjustment?.dpadConfig.enableHapticFeedback == true) {
      // 添加震动反馈
      HapticFeedback.selectionClick();
    }
    
    setState(() {
      _selectedVertexIndex = vertexIndex;
      
      // 更新放大镜位置到新选中的顶点
      if (widget.magnifier.enabled && _showMagnifier) {
        final vertex = _rectangle!.getVertex(vertexIndex);
        _magnifierSourcePosition = _convertScreenToImageCoordinates(vertex);
        _magnifierPosition = _calculateMagnifierPosition(
          vertex,
          _magnifierSourcePosition,
        );
      }
    });
  }
  
  /// 检测双击事件
  void _handleTapForDoubleTap(Point<double> position, int vertexIndex) {
    _tapCount++;
    
    if (_tapCount == 1) {
      // 第一次点击，启动定时器
      _doubleTapTimer?.cancel();
      _lastTapPosition = position;
      
      _doubleTapTimer = Timer(const Duration(milliseconds: _doubleTapTimeWindow), () {
        // 定时器到期，重置点击计数
        _tapCount = 0;
      });
    } else if (_tapCount == 2) {
      // 第二次点击，检查是否为有效双击
      _doubleTapTimer?.cancel();
      
      final distance = position.distanceTo(_lastTapPosition);
      if (distance <= _doubleTapDistanceThreshold) {
        // 有效双击，进入方向键精调模式
        _onDoubleTapVertex(vertexIndex);
      }
      
      _tapCount = 0;
    }
  }
  
  /// 处理顶点双击事件
  void _onDoubleTapVertex(int vertexIndex) {
    if (widget.fineAdjustment == null) return;
    
    final mode = widget.fineAdjustment!.mode;
    if (mode == FineAdjustmentMode.dpad || mode == FineAdjustmentMode.both) {
      _enterDPadMode(vertexIndex);
    }
  }
}

/// 扩展方法：手势处理
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
        // 检测双击事件（用于方向键精调模式）
        if (widget.fineAdjustment != null) {
          final mode = widget.fineAdjustment!.mode;
          if (mode == FineAdjustmentMode.dpad || mode == FineAdjustmentMode.both) {
            _handleTapForDoubleTap(localPosition, i);
          }
        }
        
        _updateState(() {
          _draggedVertexIndex = i;
          _draggedEdgeIndex = -1;
          _isDragging = true;
          // 启用放大镜效果（仅在非方向键模式下）
          if (widget.magnifier.enabled && !_isDPadMode) {
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
        
        // 启动长按定时器（仅在拖拽精调模式下）
        if (widget.fineAdjustment != null) {
          final mode = widget.fineAdjustment!.mode;
          if (mode == FineAdjustmentMode.drag || mode == FineAdjustmentMode.both) {
            _startLongPressTimer(localPosition);
          }
        }
        
        // 触发顶点拖动开始回调（传递图片坐标）
        final imageCoordinates = _convertToImageCoordinates([vertices[i]]);
        widget.onVertexDragStart?.call(i, imageCoordinates.first);
        return;
      }
    }

    // 检查是否点击在边上（仅在允许边框拖动时）
    if (widget.allowEdgeDrag) {
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
    
    // 检查手指移动距离，如果移动过多则取消精调模式触发
    _checkFingerMovement(localPosition);
    
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
    // 取消长按定时器
    _cancelLongPressTimer();
    
    // 退出拖拽精调模式（但不退出方向键精调模式）
    if (!_isDPadMode) {
      _exitFineAdjustmentMode();
    }
    
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

    // 重置拖动状态（但在方向键模式下保持放大镜显示）
    _resetDragState();
  }

  /// 处理顶点拖动
  /// [localPosition] 当前手势位置
  /// [delta] 位置变化量
  void _handleVertexDrag(Point<double> localPosition, Point<double> delta) {
    _updateState(() {
      final startVertex = _dragStartRectangle!.getVertex(_draggedVertexIndex);
      
      // 如果处于精调模式，应用灵敏度系数
      final adjustedDelta = _isFineAdjustmentMode && widget.fineAdjustment != null
          ? delta * widget.fineAdjustment!.sensitivity
          : delta;
      
      final newPosition = startVertex + adjustedDelta;
      final clampedPosition = _clampToImageBounds(newPosition);
      _rectangle?.setVertex(_draggedVertexIndex, clampedPosition);

      // 更新放大镜位置
      if (widget.magnifier.enabled && _showMagnifier) {
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

  /// 重置拖动状态
  void _resetDragState() {
    _updateState(() {
      _draggedVertexIndex = -1;
      _draggedEdgeIndex = -1;
      _isDragging = false;
      // 隐藏放大镜（除非在方向键模式下）
      if (!_isDPadMode) {
        _showMagnifier = false;
      }
    });
  }
}

extension _DoubleValidation on double? {
  /// 检查是否为确定的有限数字
  bool get isValid {
    final value = this;
    return value != null && value.isFinite && !value.isNaN && value > 0;
  }
}