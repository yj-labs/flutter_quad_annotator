import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'types.dart';

/// 简化的引导覆盖层组件
/// 支持分步独立的引导模式，不影响原有的四点标注框功能
class SimpleTutorialOverlay extends StatefulWidget {
  /// 引导配置
  final TutorialConfiguration config;

  /// 当前引导步骤
  final TutorialStep currentStep;

  /// 屏幕尺寸
  final Size screenSize;

  /// 需要高亮的区域（相对于屏幕的矩形区域）
  final Rect? highlightRect;

  /// 跳过引导回调
  final VoidCallback onSkip;

  /// 完成引导回调
  final VoidCallback onComplete;

  const SimpleTutorialOverlay({
    super.key,
    required this.config,
    required this.currentStep,
    required this.screenSize,
    this.highlightRect,
    required this.onSkip,
    required this.onComplete,
  });

  @override
  State<SimpleTutorialOverlay> createState() => _SimpleTutorialOverlayState();
}

class _SimpleTutorialOverlayState extends State<SimpleTutorialOverlay>
    with TickerProviderStateMixin {
  /// 聚光灯动画控制器
  late AnimationController _spotlightController;

  /// 脉冲动画控制器
  late AnimationController _pulseController;

  /// 聚光灯缩放动画
  late Animation<double> _spotlightAnimation;

  /// 脉冲动画
  late Animation<double> _pulseAnimation;

  // 引导元素动画控制器
  late AnimationController _guideElementsController;
  late Animation<double> _connectionLineAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;

  /// 用于获取提示容器实际高度的GlobalKey
  final GlobalKey _hintContainerKey = GlobalKey();

  /// 提示容器的实际高度，初始为null
  double? _actualHintHeight;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // 确保在初始渲染完成后尝试获取实际高度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getActualHintHeight();
      }
    });
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _pulseController.dispose();
    _guideElementsController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SimpleTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentStep != widget.currentStep) {
      // 步骤切换时重置实际高度，因为不同步骤的内容高度可能不同
      _actualHintHeight = null;
      // 重置引导元素动画
      _guideElementsController.reset();
      _startAnimations();
    }
  }

  /// 初始化动画控制器
  void _initializeAnimations() {
    // 聚光灯动画
    _spotlightController = AnimationController(
      duration: widget.config.spotlightAnimationDuration,
      vsync: this,
    );
    _spotlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.easeOutCubic,
    ));

    // 脉冲动画
    _pulseController = AnimationController(
      duration: widget.config.pulseAnimationDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 引导元素动画（连接线、图标、文本的入场动画）
    _guideElementsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 连接线动画（延迟200ms开始，持续400ms）
    _connectionLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _guideElementsController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    // 图标动画（延迟400ms开始，持续400ms）
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _guideElementsController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    ));

    // 文本动画（延迟600ms开始，持续400ms）
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _guideElementsController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
  }

  /// 开始动画
  void _startAnimations() {
    _spotlightController.forward();
    if (widget.config.enablePulseAnimation) {
      _pulseController.repeat(reverse: true);
    }
    // 启动引导元素动画
    _guideElementsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStep == TutorialStep.none ||
        widget.currentStep == TutorialStep.completed) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: false,
      child: SizedBox(
        width: widget.screenSize.width,
        height: widget.screenSize.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 聚光灯遮罩层（不阻止交互）
            IgnorePointer(
              child: _buildSpotlightMask(),
            ),
            // 手势拦截层（只允许聚光灯区域内的手势，但不影响引导层UI）
            _buildGestureInterceptor(),
            // 脉冲动画（不阻止交互）
            if (widget.config.enablePulseAnimation &&
                widget.highlightRect != null)
              IgnorePointer(
                child: _buildPulseAnimation(),
              ),
            // 连接线和指示器（不阻止交互）
            if (widget.highlightRect != null)
              IgnorePointer(
                child: _buildConnectionLine(),
              ),
            // 引导文本（不阻止交互）
            _buildTutorialText(),
            // 手势图标（独立定位）
            if (widget.highlightRect != null) _buildGestureIconPositioned(),
            // 跳过按钮（可交互）
            _buildSkipButton(),
          ],
        ),
      ),
    );
  }

  /// 构建手势拦截层
  /// 使用自定义的hitTest逻辑，只允许聚光灯区域内的手势事件通过到底层组件
  Widget _buildGestureInterceptor() {
    if (widget.highlightRect == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: _SpotlightGestureFilter(
        highlightRect: widget.highlightRect!,
        spotlightRadius: _getCurrentSpotlightRadius(),
      ),
    );
  }

  /// 构建聚光灯遮罩层
  Widget _buildSpotlightMask() {
    return AnimatedBuilder(
      animation: _spotlightAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SpotlightMaskPainter(
            config: widget.config,
            highlightRect: widget.highlightRect,
            animationValue: _spotlightAnimation.value,
            currentStep: widget.currentStep,
          ),
          size: widget.screenSize,
        );
      },
    );
  }

  /// 构建脉冲动画
  Widget _buildPulseAnimation() {
    if (widget.highlightRect == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final rect = widget.highlightRect!;
        final center = rect.center;
        final radius = _getCurrentSpotlightRadius();
        final pulseRadius = radius + (_pulseAnimation.value * 20);

        return CustomPaint(
          painter: PulsePainter(
            center: center,
            radius: pulseRadius,
            color: widget.config.pulseColor.withOpacity(
              0.5 * (1 - _pulseAnimation.value),
            ),
          ),
          size: widget.screenSize,
        );
      },
    );
  }

  /// 构建引导文本
  Widget _buildTutorialText() {
    final stepText = widget.config.stepTexts[widget.currentStep] ?? '';
    if (stepText.isEmpty) return const SizedBox.shrink();

    final textPosition = _calculateTextPosition();
    final maxWidth = widget.screenSize.width * 0.8;

    return Positioned(
      left: textPosition.dx,
      top: textPosition.dy,
      child: AnimatedBuilder(
        animation: _textAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _textAnimation.value)),
            child: Opacity(
              opacity: _textAnimation.value.clamp(0.0, 1.0), // 确保opacity在有效范围内
              child: IgnorePointer(
                child: Container(
                  key: _hintContainerKey,
                  width: maxWidth,
                  padding: widget.config.hintPadding,
                  decoration: BoxDecoration(
                    color: widget.config.hintBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.config.hintBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      stepText,
                      style: widget.config.hintStyle,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建独立定位的手势图标
  /// 布局关系：聚光灯 - 线 - 间距 - 图标 - 间距 - 文本
  Widget _buildGestureIconPositioned() {
    if (widget.highlightRect == null) return const SizedBox.shrink();

    final rect = widget.highlightRect!;
    final screenCenterY = widget.screenSize.height / 2;
    final rectCenterY = rect.center.dy;
    final connectionLineLength = widget.config.connectionLineLength;
    final spotlightRadius = _getCurrentSpotlightRadius();
    final iconSize = widget.config.iconSize;
    final lineToIconDistance = widget.config.lineToIconDistance;

    // 计算图标位置
    double iconY;
    if (rectCenterY < screenCenterY) {
      // 聚光灯在上半屏：聚光灯底部 + 连接线长度 + 线到图标间距
      final spotlightBottomY = rect.center.dy + spotlightRadius;
      final lineEndY = spotlightBottomY + connectionLineLength;
      iconY = lineEndY + lineToIconDistance;
    } else {
      // 聚光灯在下半屏：聚光灯顶部 - 连接线长度 - 线到图标间距 - 图标高度
      final spotlightTopY = rect.center.dy - spotlightRadius;
      final lineEndY = spotlightTopY - connectionLineLength;
      iconY = lineEndY - lineToIconDistance - iconSize;
    }

    return Positioned(
      left: rect.center.dx - iconSize / 2, // 图标中心与聚光灯中心水平对齐
      top: iconY,
      child: AnimatedBuilder(
        animation: _iconAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _iconAnimation.value)),
            child: Opacity(
              opacity: _iconAnimation.value.clamp(0.0, 1.0),
              child: _buildGestureIcon(),
            ),
          );
        },
      ),
    );
  }

  /// 构建连接线和圆形指示器
  Widget _buildConnectionLine() {
    if (widget.highlightRect == null) return const SizedBox.shrink();

    final rect = widget.highlightRect!;
    final screenCenterY = widget.screenSize.height / 2;
    final rectCenterY = rect.center.dy;

    // 连接线长度（从配置获取）
    final lineLength = widget.config.connectionLineLength;

    // 获取聚光灯的实际半径
    final spotlightRadius = _getCurrentSpotlightRadius();

    return AnimatedBuilder(
      animation: _connectionLineAnimation,
      builder: (context, child) {
        // 根据动画值计算连接线的实际长度
        final animatedLineLength = lineLength * _connectionLineAnimation.value;

        // 根据聚光灯位置决定连接线方向
        Offset startPoint;
        Offset endPoint;

        if (rectCenterY < screenCenterY) {
          // 聚光灯在上半屏，从聚光灯圆形底部边缘垂直向下延伸
          final spotlightBottomY = rect.center.dy + spotlightRadius;
          startPoint = Offset(rect.center.dx, spotlightBottomY);
          endPoint =
              Offset(rect.center.dx, spotlightBottomY + animatedLineLength);
        } else {
          // 聚光灯在下半屏，从聚光灯圆形顶部边缘垂直向上延伸
          final spotlightTopY = rect.center.dy - spotlightRadius;
          startPoint = Offset(rect.center.dx, spotlightTopY);
          endPoint = Offset(rect.center.dx, spotlightTopY - animatedLineLength);
        }

        return CustomPaint(
          painter: ConnectionLinePainter(
            startPoint: startPoint,
            endPoint: endPoint,
            lineColor: Colors.white.withOpacity(0.8),
            indicatorColor: Colors.orange,
          ),
          size: widget.screenSize,
        );
      },
    );
  }

  /// 构建跳过按钮
  Widget _buildSkipButton() {
    return Positioned(
      bottom: widget.config.skipButtonMargin,
      right: widget.config.skipButtonMargin,
      child: Material(
        color: Colors.transparent,
        child: TextButton(
          onPressed: widget.onSkip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          child: Text(
            widget.config.skipButtonText,
          ),
        ),
      ),
    );
  }

  /// 计算引导文本的位置
  /// 布局关系：聚光灯 - 线 - 间距 - 图标 - 间距 - 文本
  Offset _calculateTextPosition() {
    final padding = widget.config.hintContainerMargin;
    final screenHeight = widget.screenSize.height;

    if (widget.highlightRect == null) {
      return Offset(
        padding,
        padding,
      );
    }

    final rect = widget.highlightRect!;
    final rectCenterY = rect.center.dy;
    final screenCenterY = screenHeight / 2;

    // 获取实际高度，如果还没有测量过则使用估算高度
    final hintHeight =
        _getActualHintHeight() ?? widget.config.hintEstimatedHeight;

    // 获取配置参数
    final connectionLineLength = widget.config.connectionLineLength;
    final spotlightRadius = _getCurrentSpotlightRadius();
    final iconSize = widget.config.iconSize;
    final lineToIconDistance = widget.config.lineToIconDistance;
    final iconToTextDistance = widget.config.iconToTextDistance;

    // 如果聚光灯在屏幕上半部分，文本显示在图标下方
    if (rectCenterY < screenCenterY) {
      // 按照布局关系计算：聚光灯底部 + 连接线长度 + 线到图标间距 + 图标高度 + 图标到文本间距
      final spotlightBottomY = rect.center.dy + spotlightRadius;
      final lineEndY = spotlightBottomY + connectionLineLength;
      final iconY = lineEndY + lineToIconDistance;
      final iconBottomY = iconY + iconSize;
      final textY = iconBottomY + iconToTextDistance;

      // 确保文本不会超出屏幕底部
      if (textY + hintHeight < screenHeight) {
        return Offset(padding, textY);
      }
    }

    // 如果聚光灯在屏幕下半部分，文本显示在图标上方
    if (rectCenterY >= screenCenterY) {
      // 按照布局关系计算：聚光灯顶部 - 连接线长度 - 线到图标间距 - 图标高度 - 图标到文本间距 - 文本高度
      final spotlightTopY = rect.center.dy - spotlightRadius;
      final lineEndY = spotlightTopY - connectionLineLength;
      final iconBottomY = lineEndY - lineToIconDistance;
      final iconY = iconBottomY - iconSize;
      final textY = iconY - iconToTextDistance - hintHeight;

      // 确保文本不会超出屏幕顶部
      if (textY > 0) {
        return Offset(padding, textY);
      }
    }

    // 兜底：如果上述位置都不合适，显示在屏幕顶部
    return Offset(padding, padding);
  }

  /// 获取提示容器的实际高度
  double? _getActualHintHeight() {
    if (_actualHintHeight != null) {
      return _actualHintHeight;
    }

    // 尝试从GlobalKey获取实际高度
    final renderBox =
        _hintContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      // 只有当高度发生变化时才触发重新构建
      if (_actualHintHeight != newHeight) {
        _actualHintHeight = newHeight;
        // 延迟触发重新构建，确保位置计算使用最新高度
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
      return _actualHintHeight;
    }

    return null;
  }

  /// 获取当前步骤的聚光灯半径
  /// 根据highlightRect的实际尺寸和配置的padding计算最终半径
  double _getCurrentSpotlightRadius() {
    if (widget.highlightRect == null) {
      return widget.config.stepSpotlightPadding[widget.currentStep] ??
          widget.config.spotlightPadding;
    }

    final rect = widget.highlightRect!;
    final padding = widget.config.stepSpotlightPadding[widget.currentStep] ??
        widget.config.spotlightPadding;
    // 使用width和height中的较大值确保完全覆盖
    final maxSide = max(rect.width, rect.height);
    final radius = maxSide / 2 + padding;
    return radius;
  }

  /// 构建手势图标
  Widget _buildGestureIcon() {
    String? imagePath;

    switch (widget.currentStep) {
      case TutorialStep.dragVertex:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/tap_drag.png';
        break;
      case TutorialStep.longPressVertex:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/tap_hold.png';
        break;
      case TutorialStep.doubleTapVertex:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/tap_double.png';
        break;
      case TutorialStep.useDPad:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/gamepad.png';
        break;
      case TutorialStep.switchVertex:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/tap_single.png';
        break;
      case TutorialStep.dragDPadPanel:
        imagePath =
            'packages/flutter_quad_annotator/lib/src/assets/tap_pan.png';
        break;
      default:
        return const SizedBox.shrink();
    }

    final iconSize = widget.config.iconSize;
    final imageSize = iconSize * 0.7; // 图片占图标容器的70%

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: imageSize,
          height: imageSize,
          child: _buildImageIcon(imagePath),
        ),
      ),
    );
  }

  /// 构建PNG图标
  Widget _buildImageIcon(String imagePath) {
    final imageSize = widget.config.iconSize * 0.7;

    return Image.asset(
      imagePath,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.contain,
      color: Colors.white,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) {
        // 如果图片加载失败，显示默认图标
        return Icon(
          Icons.help_outline,
          color: Colors.white,
          size: imageSize * 0.8,
        );
      },
    );
  }
}

/// 聚光灯手势过滤器
/// 使用自定义hitTest逻辑，只允许聚光灯区域内的手势通过
class _SpotlightGestureFilter extends SingleChildRenderObjectWidget {
  final Rect highlightRect;
  final double spotlightRadius;

  const _SpotlightGestureFilter({
    required this.highlightRect,
    required this.spotlightRadius,
  }) : super(child: const SizedBox.expand());

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSpotlightGestureFilter(
      highlightRect: highlightRect,
      spotlightRadius: spotlightRadius,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final render = renderObject as _RenderSpotlightGestureFilter;
    render
      ..highlightRect = highlightRect
      ..spotlightRadius = spotlightRadius;
  }
}

/// 自定义渲染对象，实现聚光灯区域的手势过滤
class _RenderSpotlightGestureFilter extends RenderProxyBox {
  Rect _highlightRect;
  double _spotlightRadius;

  _RenderSpotlightGestureFilter({
    required Rect highlightRect,
    required double spotlightRadius,
  })  : _highlightRect = highlightRect,
        _spotlightRadius = spotlightRadius;

  Rect get highlightRect => _highlightRect;
  set highlightRect(Rect value) {
    if (_highlightRect != value) {
      _highlightRect = value;
    }
  }

  double get spotlightRadius => _spotlightRadius;
  set spotlightRadius(double value) {
    if (_spotlightRadius != value) {
      _spotlightRadius = value;
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    // 计算点击位置与聚光灯中心的距离
    final center = _highlightRect.center;
    final distance = (position - center).distance;

    // 如果在聚光灯区域外，拦截手势
    return distance > _spotlightRadius;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // 如果在聚光灯区域外，拦截手势但不传递给子组件
    if (hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }

    // 如果在聚光灯区域内，不拦截，让手势穿透
    return false;
  }
}

/// 聚光灯遮罩绘制器
class SpotlightMaskPainter extends CustomPainter {
  final TutorialConfiguration config;
  final Rect? highlightRect;
  final double animationValue;
  final TutorialStep currentStep;

  SpotlightMaskPainter({
    required this.config,
    this.highlightRect,
    required this.animationValue,
    required this.currentStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (highlightRect == null) {
      // 没有高亮区域时，绘制全屏遮罩
      final paint = Paint()..color = config.overlayColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final rect = highlightRect!;
    // 使用highlightRect的实际尺寸，并根据配置添加padding
    final basePadding =
        config.stepSpotlightPadding[currentStep] ?? config.spotlightPadding;
    final baseRadius = rect.width / 2 + basePadding;
    final radius = baseRadius * animationValue;
    final center = rect.center;

    // 创建带洞的路径
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    // 绘制遮罩（带洞）
    final maskPaint = Paint()..color = config.overlayColor;
    canvas.drawPath(path, maskPaint);

    // 绘制高亮边框
    final borderPaint = Paint()
      ..color = config.highlightBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.highlightBorderWidth;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! SpotlightMaskPainter ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.highlightRect != highlightRect ||
        oldDelegate.currentStep != currentStep;
  }
}

/// 脉冲动画绘制器
class PulsePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  PulsePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! PulsePainter ||
        oldDelegate.center != center ||
        oldDelegate.radius != radius ||
        oldDelegate.color != color;
  }
}

/// 连接线绘制器
class ConnectionLinePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final Color lineColor;
  final Color indicatorColor;

  ConnectionLinePainter({
    required this.startPoint,
    required this.endPoint,
    required this.lineColor,
    required this.indicatorColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制连接线
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 绘制垂直直线
    canvas.drawLine(startPoint, endPoint, linePaint);

    // 绘制圆形指示器
    final indicatorPaint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(endPoint, 6.0, indicatorPaint);

    // 绘制指示器边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(endPoint, 6.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! ConnectionLinePainter ||
        oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.indicatorColor != indicatorColor;
  }
}
