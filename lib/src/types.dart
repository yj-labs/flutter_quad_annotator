import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'quad_annotation.dart';

/// Offset 扩展方法
extension OffsetExtension on Offset {
  /// 转换为 Point<double>
  Point<double> toPoint() => Point<double>(dx, dy);
}

/// Point<double> 扩展方法
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
typedef OnVertexDragStart =
    void Function(int vertexIndex, Point<double> position);

/// 顶点拖动结束时的回调函数类型定义
/// [vertexIndex] 顶点索引
/// [position] 顶点在图片坐标系中的位置
typedef OnVertexDragEnd =
    void Function(int vertexIndex, Point<double> position);

/// 边拖动开始时的回调函数类型定义
/// [edgeIndex] 边的索引
/// [position] 拖动开始时的位置（图片坐标系）
typedef OnEdgeDragStart = void Function(int edgeIndex, Point<double> position);

/// 边拖动结束时的回调函数类型定义
/// [edgeIndex] 边的索引
/// [position] 拖动结束时的位置（图片坐标系）
typedef OnEdgeDragEnd = void Function(int edgeIndex, Point<double> position);

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
