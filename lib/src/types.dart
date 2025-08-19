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
  
  /// 精调模式类型
  final FineAdjustmentMode mode;
  
  /// 虚拟方向键配置
  final VirtualDPadConfiguration dpadConfig;
  
  const FineAdjustmentConfiguration({
    this.longPressDuration = const Duration(milliseconds: 800),
    this.sensitivity = 0.2,
    this.hintText = '精调模式：小幅度拖动进行精确调整',
    this.hintTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    this.hintBackgroundColor = const Color(0x88000000),
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
