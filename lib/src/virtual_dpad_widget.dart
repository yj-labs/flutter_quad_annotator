import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'types.dart';

/// 圆形方向键绘制器
/// 绘制圆形背景和四个扇形方向键
class CircularDPadPainter extends CustomPainter {
  final VirtualDPadConfiguration config;
  final int? pressedDirection; // 0=上, 1=右, 2=下, 3=左

  CircularDPadPainter({
    required this.config,
    this.pressedDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = config.centerButtonSize / 2;

    // 绘制半透明外圆背景
    final backgroundPaint = Paint()
      ..color = config.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制外圆边框
    final borderPaint = Paint()
      ..color = config.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.borderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    // 绘制四个扇形方向键
    for (int i = 0; i < 4; i++) {
      _drawSectorButton(canvas, center, radius, innerRadius, i);
    }
  }

  /// 绘制扇形按钮
  /// [direction] 方向：0=上, 1=右, 2=下, 3=左
  void _drawSectorButton(Canvas canvas, Offset center, double radius,
      double innerRadius, int direction) {
    // 修正角度计算，确保扇形位置与点击检测一致
    // -90度为正上方，顺时针旋转，每个扇形从-45度偏移开始
    final startAngle = (direction * 90 - 90 - 45) * pi / 180;
    const sweepAngle = 90 * pi / 180; // 90度扇形

    // 扇形按钮颜色（按下时高亮）
    final sectorColor = pressedDirection == direction
        ? config.highlightColor
        : Colors.transparent;

    if (sectorColor != Colors.transparent) {
      final sectorPaint = Paint()
        ..color = sectorColor
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();

      // 裁剪掉中心圆形区域
      final clipPath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius))
        ..addOval(Rect.fromCircle(center: center, radius: innerRadius));
      clipPath.fillType = PathFillType.evenOdd;

      canvas.save();
      canvas.clipPath(clipPath);
      canvas.drawPath(path, sectorPaint);
      canvas.restore();
    }

    // 绘制方向箭头图标
    _drawDirectionIcon(canvas, center, radius, innerRadius, direction);
  }

  /// 绘制方向图标
  void _drawDirectionIcon(Canvas canvas, Offset center, double radius,
      double innerRadius, int direction) {
    final iconRadius = (radius + innerRadius) / 2; // 图标位置半径
    // 修正图标角度计算：0=上(-90度), 1=右(0度), 2=下(90度), 3=左(180度)
    final iconAngle = (direction * 90 - 90) * pi / 180;

    final iconCenter = Offset(
      center.dx + iconRadius * cos(iconAngle),
      center.dy + iconRadius * sin(iconAngle),
    );

    // 绘制更大角度的箭头
    final paint = Paint()
      ..color = config.iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arrowSize = config.iconSize; // 增大箭头尺寸
    final arrowWidth = arrowSize * 1; // 增大箭头宽度，增大开口角度
    final path = Path();

    switch (direction) {
      case 0: // 上 - 绘制向上箭头
        path.moveTo(iconCenter.dx - arrowWidth, iconCenter.dy + arrowSize / 2);
        path.lineTo(iconCenter.dx, iconCenter.dy - arrowSize / 2);
        path.lineTo(iconCenter.dx + arrowWidth, iconCenter.dy + arrowSize / 2);
        break;
      case 1: // 右 - 绘制向右箭头
        path.moveTo(iconCenter.dx - arrowSize / 2, iconCenter.dy - arrowWidth);
        path.lineTo(iconCenter.dx + arrowSize / 2, iconCenter.dy);
        path.lineTo(iconCenter.dx - arrowSize / 2, iconCenter.dy + arrowWidth);
        break;
      case 2: // 下 - 绘制向下箭头
        path.moveTo(iconCenter.dx - arrowWidth, iconCenter.dy - arrowSize / 2);
        path.lineTo(iconCenter.dx, iconCenter.dy + arrowSize / 2);
        path.lineTo(iconCenter.dx + arrowWidth, iconCenter.dy - arrowSize / 2);
        break;
      case 3: // 左 - 绘制向左箭头
        path.moveTo(iconCenter.dx + arrowSize / 2, iconCenter.dy - arrowWidth);
        path.lineTo(iconCenter.dx - arrowSize / 2, iconCenter.dy);
        path.lineTo(iconCenter.dx + arrowSize / 2, iconCenter.dy + arrowWidth);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CircularDPadPainter ||
        oldDelegate.pressedDirection != pressedDirection;
  }
}

/// 虚拟方向键组件
/// 提供游戏手柄样式的方向键控制，支持拖拽移动和顶点切换
class VirtualDPadWidget extends StatefulWidget {
  /// 虚拟方向键配置
  final VirtualDPadConfiguration config;

  /// 屏幕尺寸
  final Size screenSize;

  /// 当前选中的顶点索引
  final int selectedVertexIndex;

  /// 总顶点数量
  final int totalVertices;

  /// 方向键点击回调 (dx, dy)
  final void Function(double dx, double dy) onDirectionPressed;

  /// 顶点切换回调
  final void Function(int vertexIndex) onVertexChanged;

  /// 退出精调模式回调
  final VoidCallback onExit;

  const VirtualDPadWidget({
    super.key,
    required this.config,
    required this.screenSize,
    required this.selectedVertexIndex,
    required this.totalVertices,
    required this.onDirectionPressed,
    required this.onVertexChanged,
    required this.onExit,
  });

  @override
  State<VirtualDPadWidget> createState() => _VirtualDPadWidgetState();
}

class _VirtualDPadWidgetState extends State<VirtualDPadWidget> {
  /// 当前方向键面板的位置
  late Offset _position;

  /// 是否正在拖拽
  bool _isDragging = false;

  /// 当前按下的方向键 (0=上, 1=右, 2=下, 3=左, null=无)
  int? _pressedDirection;

  /// 长按定时器
  Timer? _longPressTimer;

  /// 连续移动定时器
  Timer? _continuousMoveTimer;

  /// 是否正在长按
  bool _isLongPressing = false;

  /// 是否正在拖拽面板
  bool _isDraggingPanel = false;

  @override
  void initState() {
    super.initState();
    _initializePosition();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _continuousMoveTimer?.cancel();
    super.dispose();
  }

  /// 初始化方向键面板位置
  void _initializePosition() {
    // 计算方向键面板的总尺寸
    final totalSize = _calculateTotalSize();

    // 设置边距
    final double margin = widget.config.margin;

    // 根据初始位置配置计算实际位置，考虑边距
    final alignment = widget.config.position;
    final availableWidth =
        widget.screenSize.width - totalSize.width - margin * 2;
    final availableHeight =
        widget.screenSize.height - totalSize.height - margin * 2;

    final x = margin + (alignment.x + 1) / 2 * availableWidth;
    final y = margin + (alignment.y + 1) / 2 * availableHeight;

    _position = Offset(x, y);
  }

  /// 计算方向键面板的总尺寸
  Size _calculateTotalSize() {
    final centerSize = widget.config.centerButtonSize;

    // 圆形方向键的直径，确保有足够空间容纳中心按钮和方向键
    final diameter = centerSize + widget.config.size * 2; // 中心按钮直径 + 两倍方向键区域
    final width = diameter;
    final height = diameter;

    return Size(width, height);
  }

  /// 限制位置在屏幕边界内
  Offset _clampPosition(Offset position) {
    final totalSize = _calculateTotalSize();
    final double margin = widget.config.margin;

    final maxX = widget.screenSize.width - totalSize.width - margin;
    final maxY = widget.screenSize.height - totalSize.height - margin;

    return Offset(
      position.dx.clamp(margin, maxX),
      position.dy.clamp(margin, maxY),
    );
  }

  /// 处理拖拽更新
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = _clampPosition(_position + details.delta);
    });
  }

  /// 处理拖拽开始
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _isDraggingPanel = true;
    });
  }

  /// 处理拖拽结束
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _isDraggingPanel = false;
    });
  }

  /// 检测点击位置对应的方向
  /// 返回方向索引：0=上, 1=右, 2=下, 3=左, null=中心或无效区域
  int? _getDirectionFromPosition(Offset localPosition) {
    final totalSize = _calculateTotalSize();
    final center = Offset(totalSize.width / 2, totalSize.height / 2);
    final radius =
        (widget.config.centerButtonSize + widget.config.size * 2) / 2;
    final innerRadius = widget.config.centerButtonSize / 2;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // 检查是否在环形区域内
    if (distance < innerRadius || distance > radius) {
      return null;
    }

    // 计算角度 (0度为正上方)
    var angle = atan2(dx, -dy) * 180 / pi;
    if (angle < 0) angle += 360;

    // 判断属于哪个扇形 (每个扇形90度)
    // 恢复原来正确的角度映射
    if (angle >= 315 || angle < 45) {
      return 0; // 上
    } else if (angle >= 45 && angle < 135) {
      return 1; // 右
    } else if (angle >= 135 && angle < 225) {
      return 2; // 下
    } else if (angle >= 225 && angle < 315) {
      return 3; // 左
    }

    return null;
  }

  /// 开始方向键按下
  void _onDirectionPressStart(Offset localPosition) {
    final direction = _getDirectionFromPosition(localPosition);
    if (direction != null) {
      // 取消之前的定时器
      _longPressTimer?.cancel();
      _continuousMoveTimer?.cancel();

      // 设置按下状态
      setState(() {
        _pressedDirection = direction;
        _isLongPressing = false;
      });

      // 立即执行一次移动
      _executeDirectionMove(direction);

      // 启动长按检测定时器
      _longPressTimer = Timer(const Duration(milliseconds: 500), () {
        if (_pressedDirection == direction && mounted) {
          setState(() {
            _isLongPressing = true;
          });

          // 开始连续移动
          _startContinuousMove(direction);
        }
      });
    }
  }

  /// 结束方向键按下
  void _onDirectionPressEnd() {
    _longPressTimer?.cancel();
    _continuousMoveTimer?.cancel();

    setState(() {
      _pressedDirection = null;
      _isLongPressing = false;
    });
  }

  /// 执行方向移动
  void _executeDirectionMove(int direction) {
    switch (direction) {
      case 0: // 上
        widget.onDirectionPressed(0, -widget.config.stepSize);
        break;
      case 1: // 右
        widget.onDirectionPressed(widget.config.stepSize, 0);
        break;
      case 2: // 下
        widget.onDirectionPressed(0, widget.config.stepSize);
        break;
      case 3: // 左
        widget.onDirectionPressed(-widget.config.stepSize, 0);
        break;
    }
  }

  /// 开始连续移动
  void _startContinuousMove(int direction) {
    _continuousMoveTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_pressedDirection == direction && _isLongPressing && mounted) {
        _executeDirectionMove(direction);
      } else {
        timer.cancel();
      }
    });
  }

  /// 检测是否点击在中心按钮
  bool _isCenterButtonTap(Offset localPosition) {
    final totalSize = _calculateTotalSize();
    final center = Offset(totalSize.width / 2, totalSize.height / 2);
    final innerRadius = widget.config.centerButtonSize / 2;

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    return distance <= innerRadius;
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = _calculateTotalSize();
    final circularSize = totalSize.height; // 圆形部分的尺寸

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 圆形方向键部分
          GestureDetector(
            onTapDown: (details) {
              if (_isCenterButtonTap(details.localPosition) &&
                  !_isDraggingPanel) {
                // 只有在非拖拽状态下才允许切换顶点
                final nextIndex =
                    (widget.selectedVertexIndex + 1) % widget.totalVertices;
                widget.onVertexChanged(nextIndex);
              }
            },
            onPanDown: (details) {
              if (!_isCenterButtonTap(details.localPosition)) {
                // 开始按下方向键
                _onDirectionPressStart(details.localPosition);
              }
            },
            onPanStart: (details) {
              // 如果不是方向键区域，则处理拖拽
              if (_isCenterButtonTap(details.localPosition) ||
                  _getDirectionFromPosition(details.localPosition) == null) {
                _onPanStart(DragStartDetails(
                  localPosition: details.localPosition,
                  globalPosition: details.globalPosition,
                ));
              }
            },
            onPanUpdate: (details) {
              // 只有在拖拽模式下才更新位置
              if (_isDragging) {
                _onPanUpdate(DragUpdateDetails(
                  localPosition: details.localPosition,
                  globalPosition: details.globalPosition,
                  delta: details.delta,
                ));
              }
            },
            onPanEnd: (details) {
              // 结束方向键按下
              _onDirectionPressEnd();
              // 结束拖拽
              if (_isDragging) {
                _onPanEnd(DragEndDetails());
              }
            },
            onPanCancel: () {
              // 取消时也要结束按下状态
              _onDirectionPressEnd();
            },
            child: SizedBox(
              width: circularSize,
              height: circularSize,
              child: Stack(
                children: [
                  // 圆形方向键背景
                  CustomPaint(
                    size: Size(circularSize, circularSize),
                    painter: CircularDPadPainter(
                      config: widget.config,
                      pressedDirection: _pressedDirection,
                    ),
                  ),
                  // 中心按钮
                  Center(
                    child: Container(
                      width: widget.config.centerButtonSize,
                      height: widget.config.centerButtonSize,
                      decoration: BoxDecoration(
                        color: widget.config.centerButtonColor,
                        border: Border.all(
                          color: widget.config.borderColor,
                          width: widget.config.borderWidth,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.selectedVertexIndex + 1}',
                          style: widget.config.centerButtonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
