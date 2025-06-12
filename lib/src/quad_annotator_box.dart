import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rectangle_detector/rectangle_detector.dart';

import 'gesture_recognizer.dart';
import 'quad_annotation.dart';
import 'quadrilateral_painter.dart';
import 'types.dart';
import 'utils/coordinate_utils.dart';
import 'utils/geometry_utils.dart';
import 'utils/image_utils.dart';
import 'utils/magnifier_utils.dart';

/// 四边形裁剪组件State类型定义（用于GlobalKey）
typedef QuadAnnotatorBoxState = _QuadAnnotatorBoxState;

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

  /// 是否自动检测图片中的矩形
  /// 当为 true 时，如果没有提供初始矩形，会尝试自动检测图片中的矩形
  /// 当为 false 时，直接使用默认矩形，不进行自动检测
  final bool autoDetect;

  /// 基础构造函数，直接接收ui.Image对象
  const QuadAnnotatorBox({
    super.key,
    required this.image,
    this.rectangle,
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
    this.autoDetect = true,
  }) : imageProvider = null;

  /// 从ImageProvider创建QuadAnnotatorBox的便捷构造函数
  const QuadAnnotatorBox.fromProvider({
    super.key,
    required this.imageProvider,
    this.rectangle,
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
    this.autoDetect = true,
  }) : image = null;

  @override
  State<QuadAnnotatorBox> createState() => _QuadAnnotatorBoxState();
}

class _QuadAnnotatorBoxState extends State<QuadAnnotatorBox>
    with TickerProviderStateMixin {
  /// 矩形特征对象
  QuadAnnotation? rectangle;

  /// 获取图片坐标系的矩形特征对象
  /// 返回转换为图片真实坐标的 QuadAnnotation 对象，如果当前没有矩形则返回 null
  QuadAnnotation? get imageQuad {
    if (rectangle == null) return null;
    final imageVertices = convertToImageCoordinates(rectangle!.vertices);
    return QuadAnnotation.fromVertices(imageVertices);
  }

  /// 当前拖动的顶点索引，-1表示没有拖动顶点
  int draggedVertexIndex = -1;

  /// 当前拖动的边索引，-1表示没有拖动边
  int draggedEdgeIndex = -1;

  /// 是否正在拖动状态
  bool isDragging = false;

  /// 拖动开始时的偏移量
  Offset dragStartOffset = Offset.zero;

  /// 拖动开始时的矩形特征
  QuadAnnotation? dragStartRectangle;

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
  Offset _calculateMagnifierPosition(
    Offset gesturePosition,
    Offset sourcePosition,
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

  @override
  void initState() {
    super.initState();

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

  /// 初始化矩形特征
  /// 如果没有提供 rectangle，则尝试使用 rectangle_detector 自动检测
  /// 如果检测失败，则使用默认矩形
  void _initializeRectangle() async {
    print('🔥🔥🔥 _initializeRectangle 方法被调用了！🔥🔥🔥');
    print('🔍 [DEBUG] _loadedImage 是否为空: ${_loadedImage == null}');
    if (_loadedImage != null) {
      print('🔍 [DEBUG] 图片尺寸: ${_loadedImage!.width}x${_loadedImage!.height}');
      print('🔍 [DEBUG] widget.rectangle 是否为空: ${widget.rectangle == null}');
      QuadAnnotation? detectedRectangle;

      // 如果没有提供初始矩形且启用了自动检测，尝试自动检测
      if (widget.rectangle == null && widget.autoDetect) {
        try {
          detectedRectangle = await _detectRectangleFromImage();
          print("检测矩形成功：$detectedRectangle");
        } catch (e) {
          // 检测失败，使用默认矩形
          print('矩形检测失败: $e');
        }
      }

      // 初始化矩形特征：优先使用提供的初始矩形，其次使用检测到的矩形，最后使用默认矩形
      QuadAnnotation? initialQuad;
      if (widget.rectangle != null) {
        // 将图片真实坐标转换为视图坐标
        final imageVertices = widget.rectangle!.vertices;
        final viewVertices = convertToViewCoordinates(imageVertices);
        initialQuad = QuadAnnotation.fromVertices(viewVertices);
      }

      rectangle = initialQuad ?? detectedRectangle ?? _getDefaultRectangle();

      // 验证初始四边形正确性
      rectangle?.validateQuadrilateral();

      // 触发初始矩形的顶点变化回调，让外部能够获取到初始的矩形特征点位
      _onVerticesChanged();

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
            final relativeY =
                adjustedPoint.dy / oldImageInfo.displaySize.height;

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
  QuadAnnotation _getDefaultRectangle() {
    final imageInfo = _getImageInfo();
    // 根据顶点半径计算内边距，确保顶点完全显示且有适当间距
    final padding = widget.vertexRadius;

    // 计算图片显示区域的边界
    final left = imageInfo.offset.dx;
    final top = imageInfo.offset.dy;
    final right = left + imageInfo.displaySize.width;
    final bottom = top + imageInfo.displaySize.height;

    return QuadAnnotation(
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
        child: const Center(child: CircularProgressIndicator()),
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



  /// 更新组件状态的统一方法
  /// [callback] 状态更新回调函数
  void updateState(VoidCallback callback) {
    setState(callback);
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
    return CoordinateUtils.convertScreenToImageCoordinates(
      screenPoint,
      imageInfo,
    );
  }

  /// 将视图坐标转换为图片真实坐标
  List<Offset> convertToImageCoordinates(List<Offset> viewCoordinates) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.convertToImageCoordinates(
      viewCoordinates,
      imageInfo,
    );
  }

  /// 将图片真实坐标转换为视图坐标
  List<Offset> convertToViewCoordinates(List<Offset> imageCoordinates) {
    final imageInfo = _getImageInfo();
    return CoordinateUtils.convertToViewCoordinates(
      imageCoordinates,
      imageInfo,
    );
  }

  /// 获取当前矩形特征
  QuadAnnotation getRectangle() {
    return rectangle?.copy() ?? QuadAnnotation.fromVertices([]);
  }

  /// 获取当前顶点坐标（视图坐标）
  List<Offset> getVertices() {
    return rectangle?.vertices ?? [];
  }

  /// 获取当前顶点的图片真实坐标
  List<Offset> getImageVertices() {
    return rectangle != null
        ? convertToImageCoordinates(rectangle!.vertices)
        : [];
  }

  /// 设置矩形特征（会自动应用边界限制）
  void setRectangle(QuadAnnotation newRectangle) {
    setState(() {
      // 对每个顶点应用边界限制
      final clampedVertices = newRectangle.vertices
          .map((vertex) => _clampToImageBounds(vertex))
          .toList();
      rectangle = QuadAnnotation.fromVertices(clampedVertices);
      // 验证四边形正确性
      rectangle?.validateQuadrilateral();
    });
    _onVerticesChanged();
  }

  /// 设置顶点坐标（会自动应用边界限制）
  void setVertices(List<Offset> newVertices) {
    if (newVertices.length == 4) {
      setRectangle(QuadAnnotation.fromVertices(newVertices));
    }
  }

  /// 重置为默认顶点坐标（会自动应用边界限制）
  void resetVertices() {
    setRectangle(_getDefaultRectangle());
  }

  /// 使用 rectangle_detector 检测图片中的矩形特征点
  /// 返回检测到的矩形，如果检测失败则返回 null
  Future<QuadAnnotation?> _detectRectangleFromImage() async {
    if (_loadedImage == null) {
      print('🔍 [DEBUG] _loadedImage is null');
      return null;
    }

    try {
      print(
        '🔍 [DEBUG] 开始检测矩形，图片尺寸: ${_loadedImage!.width}x${_loadedImage!.height}',
      );

      // 将图片转换为字节数据
      // 使用 rawRgba 格式确保跨平台兼容性，避免 iOS 平台的 INVALID_IMAGE 错误
      final byteData = await _loadedImage!.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        print('🔍 [DEBUG] byteData is null');
        return null;
      }

      final imageBytes = byteData.buffer.asUint8List();
      print('🔍 [DEBUG] 图片字节数据长度: ${imageBytes.length}');

      // 使用 rectangle_detector 检测矩形
      final result = await RectangleDetector.detectRectangle(imageBytes);

      if (result != null) {
        print('🔍 [DEBUG] 检测成功！原始坐标:');
        print('  - topLeft: (${result.topLeft.x}, ${result.topLeft.y})');
        print('  - topRight: (${result.topRight.x}, ${result.topRight.y})');
        print(
          '  - bottomRight: (${result.bottomRight.x}, ${result.bottomRight.y})',
        );
        print(
          '  - bottomLeft: (${result.bottomLeft.x}, ${result.bottomLeft.y})',
        );
        final annotation = QuadAnnotation.fromRectangleFeature(result);
        final viewVertices = convertToViewCoordinates(annotation.vertices);

        print('🔍 [DEBUG] 转换后的视图坐标:');
        for (int i = 0; i < viewVertices.length; i++) {
          print(
            '  - 点${i + 1}: (${viewVertices[i].dx.toStringAsFixed(2)}, ${viewVertices[i].dy.toStringAsFixed(2)})',
          );
        }

        return QuadAnnotation.fromVertices(viewVertices);
      } else {
        print('🔍 [DEBUG] 检测失败，未找到矩形');
        return null;
      }
    } catch (e, stackTrace) {
      print('🔍 [DEBUG] 检测过程中发生错误: $e');
      print('🔍 [DEBUG] 堆栈跟踪: $stackTrace');
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
    final localPosition = details.localPosition;
    dragStartOffset = localPosition;
    dragStartRectangle = rectangle?.copy();

    final vertices = rectangle?.vertices ?? [];

    // 检查是否点击在顶点上
    for (int i = 0; i < vertices.length; i++) {
      if (_isPointNearVertex(localPosition, vertices[i])) {
        updateState(() {
          draggedVertexIndex = i;
          draggedEdgeIndex = -1;
          isDragging = true;
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
        // 触发顶点拖动开始回调
        widget.onVertexDragStart?.call(i, vertices[i]);
        return;
      }
    }

    // 检查是否点击在边上
    for (int i = 0; i < vertices.length; i++) {
      final nextIndex = (i + 1) % vertices.length;
      if (_isPointNearEdge(localPosition, vertices[i], vertices[nextIndex])) {
        updateState(() {
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
    updateState(() {
      draggedVertexIndex = -1;
      draggedEdgeIndex = -1;
      isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }

  /// 处理拖动更新手势
  /// [details] 拖动更新的详细信息
  void _onPanUpdate(DragUpdateDetails details) {
    final localPosition = details.localPosition;
    final delta = localPosition - dragStartOffset;

    if (draggedVertexIndex != -1) {
      // 拖动顶点
      _handleVertexDrag(localPosition, delta);
    } else if (draggedEdgeIndex != -1) {
      // 拖动边（移动整个四边形）
      _handleEdgeDrag(delta);
    }
  }

  /// 处理拖动结束手势
  /// [details] 拖动结束的详细信息
  void _onPanEnd(DragEndDetails details) {
    // 在拖拽结束后验证和重排四边形
    updateState(() {
      rectangle?.validateQuadrilateral();
    });

    // 触发拖动结束回调
    if (draggedVertexIndex != -1) {
      _handleVertexDragEnd();
    } else if (draggedEdgeIndex != -1) {
      _handleEdgeDragEnd(details.localPosition);
    }

    // 重置拖动状态
    _resetDragState();
  }

  /// 处理顶点拖动
  /// [localPosition] 当前手势位置
  /// [delta] 位置变化量
  void _handleVertexDrag(Offset localPosition, Offset delta) {
    updateState(() {
      final startVertex = dragStartRectangle!.getVertex(draggedVertexIndex);
      final newPosition = startVertex + delta;
      final clampedPosition = _clampToImageBounds(newPosition);
      rectangle?.setVertex(draggedVertexIndex, clampedPosition);

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
  void _handleEdgeDrag(Offset delta) {
    updateState(() {
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
        // 触发顶点变化回调
        _onVerticesChanged();
      }
    });
  }

  /// 处理顶点拖动结束
  void _handleVertexDragEnd() {
    if (rectangle != null) {
      widget.onVertexDragEnd?.call(
        draggedVertexIndex,
        rectangle!.getVertex(draggedVertexIndex),
      );
    }
  }

  /// 处理边拖动结束
  /// [localPosition] 结束位置
  void _handleEdgeDragEnd(Offset localPosition) {
    widget.onEdgeDragEnd?.call(draggedEdgeIndex, localPosition);
  }

  /// 触发顶点变化回调
  void _onVerticesChanged() {
    if (imageQuad != null) {
      widget.onVerticesChanged?.call(imageQuad!);
    }
  }

  /// 重置拖动状态
  void _resetDragState() {
    updateState(() {
      draggedVertexIndex = -1;
      draggedEdgeIndex = -1;
      isDragging = false;
      // 隐藏放大镜
      _showMagnifier = false;
    });
  }
}
