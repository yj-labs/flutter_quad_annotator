import 'dart:math';
import 'package:flutter/material.dart';
import 'quad_annotation.dart';

/// Offset 扩展方法
extension OffsetExtension on Offset {
  /// 转换为 `Point<double>`
  Point<double> toPoint() => Point<double>(dx, dy);
}

/// `Point<double>` 扩展方法
extension PointExtension on Point<double> {
  /// 重载 + 运算符，支持 Point 与 Point 的加法
  Point<double> operator +(Point<double> other) {
    return Point<double>(x + other.x, y + other.y);
  }

  /// 重载 - 运算符，支持 Point 与 Point 的减法
  Point<double> operator -(Point<double> other) {
    return Point<double>(x - other.x, y - other.y);
  }

  /// 支持 Point 与 Offset 的加法
  Point<double> addOffset(Offset offset) {
    return Point<double>(x + offset.dx, y + offset.dy);
  }

  /// 支持 Point 与 Offset 的减法
  Point<double> subtractOffset(Offset offset) {
    return Point<double>(x - offset.dx, y - offset.dy);
  }

  /// 转换为 Offset
  Offset toOffset() {
    return Offset(x, y);
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
enum MagnifierShape { circle, rectangle }

/// 四边形裁剪组件的回调函数类型定义
/// 回调参数为图片真实坐标系的QuadAnnotation
typedef OnVerticesChanged = void Function(QuadAnnotation rectangle);

/// 顶点拖动开始时的回调函数类型定义
/// [vertexIndex] 顶点索引
/// [position] 顶点在图片坐标系中的位置
typedef OnVertexDragStart = void Function(
    int vertexIndex, Point<double> position);

/// 顶点拖动结束时的回调函数类型定义
/// [vertexIndex] 顶点索引
/// [position] 顶点在图片坐标系中的位置
typedef OnVertexDragEnd = void Function(
    int vertexIndex, Point<double> position);

/// 边拖动开始时的回调函数类型定义
/// [edgeIndex] 边的索引
/// [position] 拖动开始时的位置（图片坐标系）
typedef OnEdgeDragStart = void Function(int edgeIndex, Point<double> position);

/// 边拖动结束时的回调函数类型定义
/// [edgeIndex] 边的索引
/// [position] 拖动结束时的位置（图片坐标系）
typedef OnEdgeDragEnd = void Function(int edgeIndex, Point<double> position);

/// 呼吸动画配置类
/// 包含呼吸灯效果的所有相关配置参数
class BreathingAnimation {
  /// 是否启用呼吸动画
  final bool enabled;

  /// 呼吸动画颜色
  final Color color;

  /// 呼吸动画持续时间
  final Duration duration;

  /// 呼吸动画最小透明度
  final double opacityMin;

  /// 呼吸动画最大透明度
  final double opacityMax;

  /// 呼吸动画与顶点的间距
  final double gap;

  /// 呼吸动画线条宽度
  final double strokeWidth;

  /// 创建呼吸动画配置
  const BreathingAnimation({
    this.enabled = true,
    this.color = Colors.white,
    this.duration = const Duration(seconds: 2),
    this.opacityMin = 0.2,
    this.opacityMax = 0.9,
    this.gap = 2.0,
    this.strokeWidth = 3.0,
  });

  /// 创建禁用呼吸动画的配置
  const BreathingAnimation.disabled() : this(enabled: false);

  /// 复制并修改配置
  BreathingAnimation copyWith({
    bool? enabled,
    Color? color,
    Duration? duration,
    double? opacityMin,
    double? opacityMax,
    double? gap,
    double? strokeWidth,
  }) {
    return BreathingAnimation(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      duration: duration ?? this.duration,
      opacityMin: opacityMin ?? this.opacityMin,
      opacityMax: opacityMax ?? this.opacityMax,
      gap: gap ?? this.gap,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

/// 放大镜配置类
/// 包含放大镜功能的所有相关配置参数
class MagnifierConfiguration {
  /// 是否启用放大镜
  final bool enabled;

  /// 放大镜半径
  final double radius;

  /// 放大倍数
  final double magnification;

  /// 放大镜边框颜色
  final Color borderColor;

  /// 放大镜边框宽度
  final double borderWidth;

  /// 放大镜十字线颜色
  final Color crosshairColor;

  /// 放大镜十字线半径比例（相对于放大镜半径）
  final double crosshairRadius;

  /// 放大镜位置模式
  final MagnifierPositionMode positionMode;

  /// 放大镜角落位置（仅在corner模式下生效）
  final MagnifierCornerPosition cornerPosition;

  /// 放大镜边缘模式下的偏移距离
  final Offset edgeOffset;

  /// 放大镜形状
  final MagnifierShape shape;

  /// 创建放大镜配置
  const MagnifierConfiguration({
    this.enabled = true,
    this.radius = 60.0,
    this.magnification = 1.0,
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.crosshairColor = Colors.white,
    this.crosshairRadius = 0.3,
    this.positionMode = MagnifierPositionMode.edge,
    this.cornerPosition = MagnifierCornerPosition.topLeft,
    this.edgeOffset = const Offset(20.0, 0.0),
    this.shape = MagnifierShape.circle,
  });

  /// 创建禁用放大镜的配置
  const MagnifierConfiguration.disabled() : this(enabled: false);

  /// 复制并修改配置
  MagnifierConfiguration copyWith({
    bool? enabled,
    double? radius,
    double? magnification,
    Color? borderColor,
    double? borderWidth,
    Color? crosshairColor,
    double? crosshairRadius,
    MagnifierPositionMode? positionMode,
    MagnifierCornerPosition? cornerPosition,
    Offset? edgeOffset,
    MagnifierShape? shape,
  }) {
    return MagnifierConfiguration(
      enabled: enabled ?? this.enabled,
      radius: radius ?? this.radius,
      magnification: magnification ?? this.magnification,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      crosshairColor: crosshairColor ?? this.crosshairColor,
      crosshairRadius: crosshairRadius ?? this.crosshairRadius,
      positionMode: positionMode ?? this.positionMode,
      cornerPosition: cornerPosition ?? this.cornerPosition,
      edgeOffset: edgeOffset ?? this.edgeOffset,
      shape: shape ?? this.shape,
    );
  }
}

/// 精调模式类型
enum FineAdjustmentMode {
  /// 拖动模式：长按后小幅度拖动
  drag,

  /// 方向键模式：显示虚拟十字方向键
  dpad,

  /// 两种模式都启用
  both,
}

/// 精调模式配置
class FineAdjustmentConfiguration {
  /// 长按触发精调模式的时间（毫秒）
  final Duration longPressDuration;

  /// 精调模式下的灵敏度系数（0.1表示正常速度的1/10）
  final double sensitivity;

  /// 精调模式提示文本
  final String hintText;

  /// 精调模式提示文本样式
  final TextStyle hintTextStyle;

  /// 精调模式背景色
  final Color hintBackgroundColor;

  /// 精调模式提示距离屏幕边缘的距离
  final double hintMargin;

  /// 精调模式类型
  final FineAdjustmentMode mode;

  /// 虚拟方向键配置
  final VirtualDPadConfiguration dpadConfig;

  const FineAdjustmentConfiguration({
    this.longPressDuration = const Duration(milliseconds: 800),
    this.sensitivity = 0.2,
    this.hintText =
        'Fine adjustment mode: Drag slightly for precise adjustments',
    this.hintTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.hintBackgroundColor = const Color(0x88000000),
    this.hintMargin = 20.0,
    this.mode = FineAdjustmentMode.both,
    this.dpadConfig = const VirtualDPadConfiguration(),
  });
}

/// 虚拟方向键配置
class VirtualDPadConfiguration {
  /// 方向键背景色
  final Color backgroundColor;

  /// 方向键高亮背景色
  final Color highlightColor;

  /// 虚拟摇杆边框色
  final Color borderColor;

  /// 虚拟摇杆边框宽度
  final double borderWidth;

  /// 方向键初始位置（相对于屏幕）
  final Alignment position;

  /// 虚拟按键外边距
  final double margin;

  /// 方向键大小
  final double size;

  /// 方向键图标色
  final Color iconColor;

  /// 方向键图标大小
  final double iconSize;

  /// 每次点击移动的像素数
  final double stepSize;

  /// 中心按钮大小
  final double centerButtonSize;

  /// 中心按钮背景色
  final Color centerButtonColor;

  /// 中心按钮文字样式
  final TextStyle centerButtonTextStyle;

  /// 是否启用触觉反馈
  final bool enableHapticFeedback;

  /// 构造函数
  const VirtualDPadConfiguration({
    this.backgroundColor = const Color(0x4D000000),
    this.highlightColor = const Color(0x4DFFFFFF),
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.position = Alignment.bottomLeft,
    this.margin = 20.0,
    this.size = 40.0,
    this.iconColor = Colors.white,
    this.iconSize = 8,
    this.stepSize = 1.0,
    this.centerButtonSize = 50.0,
    this.centerButtonColor = const Color(0x4D000000),
    this.centerButtonTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    this.enableHapticFeedback = true,
  });
}

/// 引导步骤枚举
enum TutorialStep {
  /// 无引导
  none,

  /// 步骤1：拖拽顶点引导
  dragVertex,

  /// 步骤2：长按进入精调模式引导
  longPressVertex,

  /// 步骤3：双击顶点引导
  doubleTapVertex,

  /// 步骤4：使用方向键引导
  useDPad,

  /// 步骤5：切换顶点引导
  switchVertex,

  /// 步骤6：拖拽方向键面板引导
  dragDPadPanel,

  /// 引导完成
  completed,
}

/// 引导动画类型
enum TutorialAnimationType {
  bounce,
  pulse,
  breathing,
  shake,
  rotate,
}

/// 引导配置类
class TutorialConfiguration {
  /// 是否启用引导
  final bool enabled;

  /// 是否自动开始引导
  final bool autoStart;

  /// 遮罩颜色
  final Color overlayColor;

  /// 跳过按钮文本
  final String skipButtonText;

  /// 跳过按钮样式
  final ButtonStyle? skipButtonStyle;

  /// 跳过按钮距离屏幕边缘的距离
  final double skipButtonMargin;

  /// 引导提示样式
  final TextStyle hintStyle;

  /// 引导提示背景颜色
  final Color hintBackgroundColor;

  /// 引导提示圆角半径
  final double hintBorderRadius;

  /// 引导提示内边距
  final EdgeInsets hintPadding;

  /// 引导提示容器边距（距离屏幕边缘的距离）
  final double hintContainerMargin;

  /// 引导提示容器预估高度（用于位置计算）
  final double hintEstimatedHeight;

  /// 连接线长度
  final double connectionLineLength;

  /// 图标尺寸
  final double iconSize;

  /// 连接线到图标的间距
  final double lineToIconDistance;

  /// 图标到文本的间距
  final double iconToTextDistance;

  /// 聚光灯边距（在实际内容基础上增加的大小）
  final double spotlightPadding;

  /// 聚光灯动画持续时间
  final Duration spotlightAnimationDuration;

  /// 高亮边框颜色
  final Color highlightBorderColor;

  /// 高亮边框宽度
  final double highlightBorderWidth;

  /// 是否启用脉冲动画
  final bool enablePulseAnimation;

  /// 脉冲动画颜色
  final Color pulseColor;

  /// 脉冲动画持续时间
  final Duration pulseAnimationDuration;

  /// 引导开始的延迟时间
  final Duration startDelay;

  /// 引导步骤之间的间隔时间
  final Duration stepInterval;

  /// 每个步骤的引导文本
  final Map<TutorialStep, String> stepTexts;

  /// 每个步骤的聚光灯边距
  final Map<TutorialStep, double> stepSpotlightPadding;

  /// 构造函数
  const TutorialConfiguration({
    this.enabled = true,
    this.autoStart = false,
    this.overlayColor = const Color(0xCC000000),
    this.skipButtonText = 'Skip',
    this.skipButtonStyle,
    this.skipButtonMargin = 20.0,
    this.hintStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    this.hintBackgroundColor = Colors.transparent,
    this.hintBorderRadius = 8.0,
    this.hintPadding = EdgeInsets.zero,
    this.hintContainerMargin = 20.0,
    this.hintEstimatedHeight = 150.0,
    this.connectionLineLength = 60.0,
    this.iconSize = 56.0,
    this.lineToIconDistance = 20.0,
    this.iconToTextDistance = 12.0,
    this.spotlightPadding = 20.0,
    this.spotlightAnimationDuration = const Duration(milliseconds: 800),
    this.highlightBorderColor = Colors.orange,
    this.highlightBorderWidth = 3.0,
    this.enablePulseAnimation = true,
    this.pulseColor = Colors.orange,
    this.pulseAnimationDuration = const Duration(milliseconds: 2000),
    this.startDelay = const Duration(milliseconds: 1000),
    this.stepInterval = const Duration(milliseconds: 800),
    this.stepTexts = const {
      TutorialStep.none: '',
      TutorialStep.dragVertex:
          'Drag the highlighted vertex to adjust the quadrilateral shape.\nPerfect for quick and rough positioning.',
      TutorialStep.longPressVertex:
          'Long press the highlighted vertex to enter precision mode.\nIdeal for fine-tuning vertex positions with enhanced accuracy.',
      TutorialStep.doubleTapVertex:
          'Double tap the highlighted vertex to reveal the virtual D-pad.\nEnables pixel-perfect vertex positioning with directional controls.',
      TutorialStep.useDPad:
          'Use the directional buttons to move the vertex precisely.\nEach tap moves the vertex by one pixel for ultimate precision.',
      TutorialStep.switchVertex:
          'Tap the center button to switch between different vertices.\nCycle through all four corners of your quadrilateral.',
      TutorialStep.dragDPadPanel:
          'Hold and drag the center of the D-pad panel to reposition it.\nPlace the controls wherever they feel most comfortable.',
      TutorialStep.completed:
          'Congratulations! You\'ve mastered all the annotation features.\nYou\'re now ready to create precise quadrilateral annotations.',
    },
    this.stepSpotlightPadding = const {
      TutorialStep.dragVertex: 20.0,
      TutorialStep.longPressVertex: 20.0,
      TutorialStep.doubleTapVertex: 20.0,
      TutorialStep.useDPad: 0.0,
      TutorialStep.switchVertex: 0.0,
      TutorialStep.dragDPadPanel: 0.0,
    },
  });
}

/// 图片信息类，包含图片的真实尺寸和显示尺寸
class QuadImageInfo {
  final Size realSize; // 图片真实尺寸
  final Size displaySize; // 图片显示尺寸
  final Offset offset; // 图片在容器中的偏移量

  const QuadImageInfo({
    required this.realSize,
    required this.displaySize,
    required this.offset,
  });
}
