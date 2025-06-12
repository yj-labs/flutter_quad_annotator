import 'dart:math';
import 'dart:ui';

import '../types.dart';

/// 放大镜位置计算工具类
/// 提供不同模式下的放大镜位置计算功能
class MagnifierUtils {
  /// 计算放大镜位置
  /// [gesturePosition] 手势位置
  /// [sourcePosition] 源位置（图片坐标系）
  /// [positionMode] 位置模式
  /// [cornerPosition] 角落位置（仅在corner模式下生效）
  /// [edgeOffset] 边缘模式下的偏移距离
  /// [magnifierRadius] 放大镜半径
  /// [containerSize] 容器尺寸
  /// 返回放大镜应该显示的位置
  static Point<double> calculateMagnifierPosition(
    Point<double> gesturePosition,
    Point<double> sourcePosition,
    MagnifierPositionMode positionMode,
    MagnifierCornerPosition cornerPosition,
    double edgeOffset,
    double magnifierRadius,
    Size containerSize,
  ) {
    switch (positionMode) {
      case MagnifierPositionMode.center:
        // 模式1：放大镜圆心在手势位置（默认模式）
        return gesturePosition;

      case MagnifierPositionMode.corner:
        // 模式2：放大镜固定在四个角之一
        return _getCornerPosition(
          cornerPosition,
          magnifierRadius,
          edgeOffset,
          containerSize,
        );

      case MagnifierPositionMode.edge:
        // 模式3：放大镜边缘在手势位置，有偏移避免遮挡
        return _getEdgePosition(
          gesturePosition,
          magnifierRadius,
          edgeOffset,
          containerSize,
        );
    }
  }

  /// 获取角落位置
  /// [cornerPosition] 角落位置枚举
  /// [radius] 放大镜半径
  /// [margin] 边缘间距
  /// [containerSize] 容器尺寸
  /// 返回角落位置坐标
  static Point<double> _getCornerPosition(
    MagnifierCornerPosition cornerPosition,
    double radius,
    double margin,
    Size containerSize,
  ) {
    switch (cornerPosition) {
      case MagnifierCornerPosition.topLeft:
        return Point(radius + margin, radius + margin);
      case MagnifierCornerPosition.topRight:
        return Point(containerSize.width - radius - margin, radius + margin);
      case MagnifierCornerPosition.bottomLeft:
        return Point(radius + margin, containerSize.height - radius - margin);
      case MagnifierCornerPosition.bottomRight:
        return Point(
          containerSize.width - radius - margin,
          containerSize.height - radius - margin,
        );
    }
  }

  /// 获取边缘位置（参考flutter_magnifier库的实现）
  /// [gesturePosition] 手势位置
  /// [radius] 放大镜半径
  /// [offset] 偏移距离
  /// [containerSize] 容器尺寸
  /// 返回边缘位置坐标
  static Point<double> _getEdgePosition(
    Point<double> gesturePosition,
    double radius,
    double offset,
    Size containerSize,
  ) {
    // 计算Y坐标：让放大镜底部与手势位置齐平
    double adjustedY = gesturePosition.y - radius;

    // 默认尝试在左侧显示
    Point<double> targetPosition = Point(
      gesturePosition.x - radius - offset,
      adjustedY,
    );

    // 检查是否超出左边界，如果超出则显示在右侧
    if (targetPosition.x - radius < 0) {
      targetPosition = Point(gesturePosition.x + radius + offset, adjustedY);
    }

    // 检查是否超出右边界，如果超出则调整到右边界内
    if (targetPosition.x + radius > containerSize.width) {
      targetPosition = Point(containerSize.width - radius, targetPosition.y);
    }

    // 检查垂直方向边界
    if (targetPosition.y - radius < 0) {
      targetPosition = Point(targetPosition.x, radius);
    } else if (targetPosition.y + radius > containerSize.height) {
      targetPosition = Point(targetPosition.x, containerSize.height - radius);
    }

    return targetPosition;
  }

  /// 检查放大镜是否在容器边界内
  /// [position] 放大镜位置
  /// [radius] 放大镜半径
  /// [containerSize] 容器尺寸
  /// 返回是否在边界内
  static bool isWithinBounds(
    Point<double> position,
    double radius,
    Size containerSize,
  ) {
    return position.x - radius >= 0 &&
        position.y - radius >= 0 &&
        position.x + radius <= containerSize.width &&
        position.y + radius <= containerSize.height;
  }

  /// 调整放大镜位置使其保持在容器边界内
  /// [position] 原始位置
  /// [radius] 放大镜半径
  /// [containerSize] 容器尺寸
  /// 返回调整后的位置
  static Point<double> clampToBounds(
    Point<double> position,
    double radius,
    Size containerSize,
  ) {
    return Point(
      position.x.clamp(radius, containerSize.width - radius),
      position.y.clamp(radius, containerSize.height - radius),
    );
  }
}
