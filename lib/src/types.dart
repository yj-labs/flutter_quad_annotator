import 'package:flutter/material.dart';
import 'rectangle_feature.dart';

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