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
import 'tutorial_overlay.dart';

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

  /// 引导完成或跳过时的回调函数
  final VoidCallback? onTutorialCompleted;

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

  /// 引导配置，传null则禁用引导功能
  final TutorialConfiguration? tutorial;

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
    this.onTutorialCompleted,
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
    this.tutorial,
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
    this.onTutorialCompleted,
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
    this.tutorial,
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

  /// 上一次的实际宽度（用于检测尺寸变化）
  double? _previousActualWidth;

  /// 上一次的实际高度（用于检测尺寸变化）
  double? _previousActualHeight;

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

  /// 虚拟方向键面板的位置（用于记住用户拖拽后的位置）
  Offset? _dpadPanelPosition;

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

  /// 引导相关状态变量
  /// 是否正在进行引导
  bool _isTutorialActive = false;

  /// 当前引导步骤
  TutorialStep _currentTutorialStep = TutorialStep.none;

  /// 引导覆盖层的GlobalKey
  final GlobalKey _tutorialOverlayKey = GlobalKey();

  /// 是否已完成初始化（用于自动开始引导）
  bool _isInitialized = false;

  /// 是否已完成引导（防止重复触发）
  bool _isTutorialCompleted = false;

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
      child: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: RawImage(image: _loadedImage, fit: BoxFit.contain),
          ),
          // 四边形绘制层（包含呼吸动画）
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: QuadrilateralPainter(
                  image: _loadedImage!,
                  vertices: _rectangle!.vertices,
                  rectangle: _rectangle!,
                  draggedEdgeIndex: _draggedEdgeIndex,
                  selectedVertexIndex: _isDPadMode
                      ? _selectedVertexIndex
                      : (_isDragging ? _draggedVertexIndex : -1),
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
              );
            },
          ),
          // 精调模式提示（仅在拖拽精调模式下显示）
          if (_isFineAdjustmentMode && !_isDPadMode)
            Positioned(
              top: widget.fineAdjustment?.hintMargin ?? 20,
              left: widget.fineAdjustment?.hintMargin ?? 20,
              right: widget.fineAdjustment?.hintMargin ?? 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.fineAdjustment?.hintBackgroundColor ??
                      const Color(0x88000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.fineAdjustment?.hintText ?? '精调模式：小幅度拖动进行精确调整',
                  style: widget.fineAdjustment?.hintTextStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 3, // 允许最多3行显示
                  softWrap: true, // 启用软换行
                  overflow: TextOverflow.visible, // 文本溢出时可见
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
              onPanelDragged: _onDPadPanelDragged,
              onPositionChanged: _onDPadPositionChanged,
              initialPosition: _dpadPanelPosition,
              enablePanelDrag: !_isTutorialActive ||
                  _currentTutorialStep ==
                      TutorialStep.dragDPadPanel, // 除了步骤6外，引导期间禁用面板拖动
            ),
          // 引导覆盖层（独立于呼吸动画）
          if (_isTutorialActive && widget.tutorial != null)
            SimpleTutorialOverlay(
              key: _tutorialOverlayKey,
              config: widget.tutorial!,
              currentStep: _currentTutorialStep,
              screenSize: Size(_actualWidth, _actualHeight),
              highlightRect: _getTutorialHighlightRect(),
              onSkip: stopTutorial,
              onComplete: stopTutorial,
            ),
        ],
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
      widget.controller!.onStartTutorial = () => _startTutorialFromController();
    }

    // 初始化尺寸变化检测变量
    _previousActualWidth = null;
    _previousActualHeight = null;

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
      return; // 图片变化时直接返回，避免其他检查
    }

    // // 检查矩形参数是否发生变化
    // if (oldWidget.rectangle != widget.rectangle) {
    //   _initializeRectangle();
    // }

    // 检查是否需要处理尺寸变化（延迟到下一帧检查实际尺寸）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleSizeChange();
      }
    });
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
    // 检查实际尺寸是否发生变化
    bool sizeChanged = _previousActualWidth != _actualWidth ||
        _previousActualHeight != _actualHeight;
    if (!sizeChanged) {
      return;
    }
    // 更新保存的尺寸
    _previousActualWidth = _actualWidth;
    _previousActualHeight = _actualHeight;

    // 如果图片还未加载或矩形还未初始化，跳过处理
    if (_loadedImage == null || _rectangle == null) {
      return;
    }

    // 保存当前四边形在图片中的真实坐标
    final savedImageCoordinates = _saveCurrentImageCoordinates();

    // 清除图片信息缓存以重新计算布局
    _clearImageInfoCache();

    // 在下一帧恢复四边形位置，确保新的布局信息已经生效
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _restoreQuadrilateralPosition(savedImageCoordinates);
        // 如果当前处于方向键精调模式且显示放大镜，需要更新放大镜位置
        _updateMagnifierPositionAfterSizeChange();
        // 强制重建以更新引导层位置（修复步骤1、2、3横屏切换问题）
        setState(() {});
      }
    });
  }

  /// 处理虚拟方向键面板拖拽
  void _onDPadPanelDragged() {
    // 引导操作检测 - 拖拽方向键面板
    completeTutorial();
  }

  /// 处理虚拟方向键面板位置变化
  /// 保存用户拖拽后的面板位置，以便下次打开时使用
  void _onDPadPositionChanged(Offset position) {
    _dpadPanelPosition = position;
  }

  /// 在屏幕尺寸变化后更新放大镜位置
  /// 当处于方向键精调模式且显示放大镜时，重新计算放大镜位置
  void _updateMagnifierPositionAfterSizeChange() {
    // 只有在方向键精调模式下且显示放大镜时才需要更新
    if (!_isDPadMode || !_showMagnifier || _rectangle == null) {
      return;
    }

    // 只有在放大镜启用时才更新
    if (!widget.magnifier.enabled) {
      return;
    }

    setState(() {
      // 获取当前选中顶点的新位置
      final vertex = _rectangle!.getVertex(_selectedVertexIndex);
      // 重新计算放大镜源位置（图片坐标系）
      _magnifierSourcePosition = _convertScreenToImageCoordinates(vertex);
      // 重新计算放大镜显示位置
      _magnifierPosition = _calculateMagnifierPosition(
        vertex,
        _magnifierSourcePosition,
      );
    });
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
        setState(() {
          // 标记初始化完成，在检查引导之前设置
          _isInitialized = true;
        });
        // 在下一帧触发初始矩形的顶点变化回调，避免在构建过程中调用setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _onVerticesChanged();
            // 检查是否需要自动开始引导（延迟逻辑已在checkAutoStartTutorial中处理）
            checkAutoStartTutorial();
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

        // 引导操作检测 - 长按进入精调模式（立即隐藏引导）
        exitLongPressVertexStep();
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

    // 引导操作检测 - 成功进入虚拟按键模式后进入下一步
    enterUseDPadStep();
  }

  /// 退出虚拟方向键精调模式
  void _exitDPadMode() {
    setState(() {
      _isDPadMode = false;
      _showMagnifier = false;
    });

    // 如果正在进行方向键相关的引导，停止引导
    handleDPadModeExit();
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
        _magnifierSourcePosition =
            _convertScreenToImageCoordinates(clampedPosition);
        _magnifierPosition = _calculateMagnifierPosition(
          clampedPosition,
          _magnifierSourcePosition,
        );
      }
    });

    // 引导操作检测 - 使用方向键完成后进入下一步
    enterSwitchVertexStep();

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

    // 引导操作检测 - 切换顶点
    enterDragDPadPanelStep();
  }

  /// 检测双击事件
  void _handleTapForDoubleTap(Point<double> position, int vertexIndex) {
    _tapCount++;

    if (_tapCount == 1) {
      // 第一次点击，启动定时器
      _doubleTapTimer?.cancel();
      _lastTapPosition = position;

      _doubleTapTimer =
          Timer(const Duration(milliseconds: _doubleTapTimeWindow), () {
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

    // // 引导操作检测 - 双击顶点
    // exitDoubleTapVertexStep();
  }

  /// 获取当前步骤需要高亮的区域
  Rect? _getTutorialHighlightRect() {
    if (!_isTutorialActive || _rectangle == null) return null;

    switch (_currentTutorialStep) {
      case TutorialStep.dragVertex:
      case TutorialStep.longPressVertex:
      case TutorialStep.doubleTapVertex:
        // 高亮第一个顶点
        final vertex = _rectangle!.getVertex(0);
        const radius = 30.0;
        return Rect.fromCenter(
          center: Offset(vertex.x, vertex.y),
          width: radius * 2,
          height: radius * 2,
        );
      case TutorialStep.useDPad:
      case TutorialStep.dragDPadPanel:
        // 高亮虚拟方向键区域（步骤4、6统一处理）
        if (_isDPadMode && widget.fineAdjustment != null) {
          // 根据虚拟方向键配置计算实际位置
          final config = widget.fineAdjustment!.dpadConfig;
          final alignment = config.position;
          final centerSize = config.centerButtonSize;
          final diameter = centerSize + config.size * 2;
          final margin = config.margin;

          // 计算可用空间
          final availableWidth = _actualWidth - diameter - margin * 2;
          final availableHeight = _actualHeight - diameter - margin * 2;

          // 计算实际位置
          final x =
              margin + (alignment.x + 1) / 2 * availableWidth + diameter / 2;
          final y =
              margin + (alignment.y + 1) / 2 * availableHeight + diameter / 2;

          // 统一使用虚拟方向键面板的完整大小
          return Rect.fromCenter(
            center: Offset(x, y),
            width: diameter,
            height: diameter,
          );
        }
        return null;
      case TutorialStep.switchVertex:
        // switchVertex步骤只高亮中间按钮
        if (_isDPadMode && widget.fineAdjustment != null) {
          // 根据虚拟方向键配置计算中间按钮位置
          final config = widget.fineAdjustment!.dpadConfig;
          final alignment = config.position;
          final centerSize = config.centerButtonSize;
          final diameter = centerSize + config.size * 2;
          final margin = config.margin;

          // 计算可用空间
          final availableWidth = _actualWidth - diameter - margin * 2;
          final availableHeight = _actualHeight - diameter - margin * 2;

          // 计算面板中心位置
          final panelCenterX =
              margin + (alignment.x + 1) / 2 * availableWidth + diameter / 2;
          final panelCenterY =
              margin + (alignment.y + 1) / 2 * availableHeight + diameter / 2;

          // 只聚焦中间按钮区域
          return Rect.fromCenter(
            center: Offset(panelCenterX, panelCenterY),
            width: centerSize,
            height: centerSize,
          );
        }
        return null;
      case TutorialStep.none:
      case TutorialStep.completed:
        return null;
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
          if (mode == FineAdjustmentMode.dpad ||
              mode == FineAdjustmentMode.both) {
            _handleTapForDoubleTap(localPosition, i);
          }
        }

        _updateState(() {
          _draggedVertexIndex = i;
          _draggedEdgeIndex = -1;
          _isDragging = true;
          // 引导操作检测 - 确认开始拖拽顶点时隐藏引导层
          exitDragVertexStep();
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
          if (mode == FineAdjustmentMode.drag ||
              mode == FineAdjustmentMode.both) {
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

    // 触发拖动结束回调（在退出精调模式之前，确保引导检测能正确工作）
    if (_draggedVertexIndex != -1) {
      _handleVertexDragEnd();
    } else if (_draggedEdgeIndex != -1) {
      _handleEdgeDragEnd(details.localPosition.toPoint());
    }

    // 退出拖拽精调模式（但不退出方向键精调模式）
    if (!_isDPadMode) {
      _exitFineAdjustmentMode();
    }

    // 在拖拽结束后验证和重排四边形
    _updateState(() {
      _rectangle?.validateQuadrilateral();
    });

    // 处理其他拖动结束逻辑
    if (_draggedEdgeIndex != -1) {
      // 边拖动结束的其他处理已在_handleEdgeDragEnd中完成
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
      final adjustedDelta =
          _isFineAdjustmentMode && widget.fineAdjustment != null
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
      // 引导操作检测 - 拖拽操作完成后进入下一步
      enterLongPressVertexStep();

      // 引导操作检测 - 精调模式拖拽完成后进入下一步
      enterDoubleTapVertexStep();
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

/// 扩展方法：引导处理
extension _TutorialHandlers on _QuadAnnotatorBoxState {
  /// 开始指定步骤的引导
  /// [step] 要开始的引导步骤
  void startTutorialStep(TutorialStep step) {
    if (widget.tutorial == null || !widget.tutorial!.enabled) {
      return;
    }

    _updateState(() {
      _currentTutorialStep = step;
      _isTutorialActive = true;
    });

    // 引导开始时停止呼吸动画，避免持续重建
    if (widget.breathing.enabled && _breathingController.isAnimating) {
      _breathingController.stop();
    }
  }

  /// 停止引导
  void stopTutorial() {
    _updateState(() {
      _isTutorialActive = false;
      _currentTutorialStep = TutorialStep.none;
      _isTutorialCompleted = true; // 标记引导已完成
    });

    // 引导结束时恢复呼吸动画
    if (widget.breathing.enabled && !_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    }

    // 调用引导完成回调
    widget.onTutorialCompleted?.call();
  }

  /// 从控制器启动引导
  /// 通过控制器手动启动引导流程，从第一步开始
  void _startTutorialFromController() {
    if (widget.tutorial != null &&
        widget.tutorial!.enabled &&
        _rectangle != null) {
      startTutorialStep(TutorialStep.dragVertex);
    }
  }

  /// 进入下一个引导步骤
  /// 按照预定义的顺序进入下一个引导步骤，带有延迟和消失动画
  void nextTutorialStep() {
    if (widget.tutorial == null || !widget.tutorial!.enabled) {
      return;
    }

    // 记录当前步骤
    final currentStep = _currentTutorialStep;

    // 先隐藏当前步骤并重置状态
    _updateState(() {
      _isTutorialActive = false;
      _currentTutorialStep = TutorialStep.none;
    });

    // 延迟后显示下一步骤，但要检查是否还在操作状态
    Timer(widget.tutorial?.stepInterval ?? const Duration(milliseconds: 1500),
        () {
      if (!mounted || _isTutorialActive) {
        return;
      }

      switch (currentStep) {
        case TutorialStep.dragVertex:
          startTutorialStep(TutorialStep.longPressVertex);
          break;
        case TutorialStep.longPressVertex:
          startTutorialStep(TutorialStep.doubleTapVertex);
          break;
        case TutorialStep.doubleTapVertex:
          startTutorialStep(TutorialStep.useDPad);
          break;
        case TutorialStep.useDPad:
          startTutorialStep(TutorialStep.switchVertex);
          break;
        case TutorialStep.switchVertex:
          startTutorialStep(TutorialStep.dragDPadPanel);
          break;
        case TutorialStep.dragDPadPanel:
          // 显示完成消息
          showCompletionMessage();
          break;
        default:
          stopTutorial();
          break;
      }
    });
  }

  /// 显示引导完成消息
  void showCompletionMessage() {
    _updateState(() {
      _isTutorialActive = true;
      _currentTutorialStep = TutorialStep.completed;
    });

    // 显示完成消息后立即结束引导
    // 移除延迟，避免影响用户交互
    Future.microtask(() {
      if (mounted) {
        stopTutorial();
      }
    });
  }

  /// 开始拖拽顶点引导
  void startDragVertexTutorial() {
    startTutorialStep(TutorialStep.dragVertex);
  }

  /// 检查是否应该自动开始引导
  void checkAutoStartTutorial() {
    if (widget.tutorial != null &&
        widget.tutorial!.enabled &&
        widget.tutorial!.autoStart &&
        !_isTutorialActive &&
        !_isTutorialCompleted && // 检查是否已完成引导
        _isInitialized &&
        _rectangle != null) {
      // 延迟开始引导，确保UI已经渲染完成
      Timer(widget.tutorial?.startDelay ?? const Duration(milliseconds: 500),
          () {
        startDragVertexTutorial();
      });
    }
  }

  // ==================== 引导退出方法 ====================
  /// 退出拖拽顶点引导步骤
  void exitDragVertexStep() {
    if (_currentTutorialStep == TutorialStep.dragVertex) {
      _updateState(() {
        _isTutorialActive = false;
      });
    }
  }

  /// 退出长按顶点引导步骤
  void exitLongPressVertexStep() {
    if (_currentTutorialStep == TutorialStep.longPressVertex) {
      _updateState(() {
        _isTutorialActive = false;
      });
    }
  }

  // ==================== 引导进入方法 ====================
  /// 进入长按顶点引导步骤
  void enterLongPressVertexStep() {
    if (_currentTutorialStep == TutorialStep.dragVertex) {
      nextTutorialStep();
    }
  }

  /// 进入双击顶点引导步骤
  void enterDoubleTapVertexStep() {
    if (_currentTutorialStep == TutorialStep.longPressVertex &&
        _isFineAdjustmentMode) {
      nextTutorialStep();
    }
  }

  /// 进入使用方向键引导步骤
  void enterUseDPadStep() {
    if (_currentTutorialStep == TutorialStep.doubleTapVertex) {
      nextTutorialStep();
    }
  }

  /// 处理引导操作检测 - 使用方向键时隐藏引导
  /// 进入切换顶点引导步骤
  void enterSwitchVertexStep() {
    if (_currentTutorialStep == TutorialStep.useDPad) {
      nextTutorialStep();
    }
  }

  /// 进入拖拽面板引导步骤
  void enterDragDPadPanelStep() {
    if (_currentTutorialStep == TutorialStep.switchVertex) {
      nextTutorialStep();
    }
  }

  /// 完成引导流程
  void completeTutorial() {
    if (_currentTutorialStep == TutorialStep.dragDPadPanel) {
      nextTutorialStep();
    }
  }

  /// 处理方向键模式退出时的引导
  void handleDPadModeExit() {
    // 如果正在进行方向键相关的引导，停止引导
    if (_currentTutorialStep == TutorialStep.useDPad ||
        _currentTutorialStep == TutorialStep.switchVertex ||
        _currentTutorialStep == TutorialStep.dragDPadPanel) {
      stopTutorial();
    }
  }
}
