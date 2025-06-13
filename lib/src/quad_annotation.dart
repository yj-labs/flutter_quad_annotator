import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:rectangle_detector/rectangle_detector.dart';

/// 四边形注释类，用于存储和操作四个顶点坐标
/// 替代List<Offset>以提高代码严谨性，防止意外增删顶点
class QuadAnnotation {
  /// 当前四边形是否有错误
  bool _hasError = false;

  /// 获取当前错误状态
  bool get hasError => _hasError;

  /// 左上角顶点
  Point<double> topLeft;

  /// 右上角顶点
  Point<double> topRight;

  /// 左下角顶点
  Point<double> bottomLeft;

  /// 右下角顶点
  Point<double> bottomRight;

  /// 构造函数
  QuadAnnotation({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  /// 从顶点列表创建四边形注释
  /// 顶点顺序：[左上, 右上, 右下, 左下]
  factory QuadAnnotation.fromVertices(List<Point<double>> vertices) {
    if (vertices.length != 4) {
      throw ArgumentError('顶点列表必须包含4个点');
    }
    return QuadAnnotation(
      topLeft: vertices[0],
      topRight: vertices[1],
      bottomRight: vertices[2],
      bottomLeft: vertices[3],
    );
  }

  /// 创建默认矩形（基于给定尺寸和内边距）
  factory QuadAnnotation.defaultRectangle({
    required Size containerSize,
    double padding = 10.0,
  }) {
    return QuadAnnotation(
      topLeft: Point<double>(padding, padding),
      topRight: Point<double>(containerSize.width - padding, padding),
      bottomRight: Point<double>(
        containerSize.width - padding,
        containerSize.height - padding,
      ),
      bottomLeft: Point<double>(padding, containerSize.height - padding),
    );
  }

  /// 从RectangleFeature创建QuadAnnotation
  factory QuadAnnotation.fromRectangleFeature(RectangleFeature rect) {
    return QuadAnnotation(
      topLeft: Point<double>(rect.topLeft.x, rect.topLeft.y),
      topRight: Point<double>(rect.topRight.x, rect.topRight.y),
      bottomLeft: Point<double>(rect.bottomLeft.x, rect.bottomLeft.y),
      bottomRight: Point<double>(rect.bottomRight.x, rect.bottomRight.y),
    );
  }

  /// 转换为顶点列表
  /// 返回顺序：[左上, 右上, 右下, 左下]
  List<Point<double>> get vertices => [
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
      ];

  /// 转换为RectangleFeature
  RectangleFeature toRectangleFeature() {
    return RectangleFeature(
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  /// 获取边界矩形
  Rect get bounds {
    final points = vertices;
    double xMin = points[0].x;
    double xMax = points[0].x;
    double yMin = points[0].y;
    double yMax = points[0].y;

    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      if (point.x > xMax) xMax = point.x;
      if (point.x < xMin) xMin = point.x;
      if (point.y > yMax) yMax = point.y;
      if (point.y < yMin) yMin = point.y;
    }

    return Rect.fromLTRB(xMin, yMin, xMax, yMax);
  }

  /// 根据索引获取顶点
  Point<double> getVertex(int index) {
    switch (index) {
      case 0:
        return topLeft;
      case 1:
        return topRight;
      case 2:
        return bottomRight;
      case 3:
        return bottomLeft;
      default:
        throw ArgumentError('顶点索引必须在0-3之间');
    }
  }

  /// 根据索引设置顶点
  void setVertex(int index, Point<double> vertex) {
    switch (index) {
      case 0:
        topLeft = vertex;
        break;
      case 1:
        topRight = vertex;
        break;
      case 2:
        bottomRight = vertex;
        break;
      case 3:
        bottomLeft = vertex;
        break;
      default:
        throw ArgumentError('顶点索引必须在0-3之间');
    }
  }

  /// 生成一个扩大/缩小边距的矩形框
  /// dx > 0, dy > 0 表示向内缩小
  /// dx < 0, dy < 0 表示向外扩大
  QuadAnnotation insetBy({required double dx, required double dy}) {
    return QuadAnnotation(
      topLeft: Point<double>(topLeft.x + dx, topLeft.y + dy),
      topRight: Point<double>(topRight.x - dx, topRight.y + dy),
      bottomRight: Point<double>(bottomRight.x - dx, bottomRight.y - dy),
      bottomLeft: Point<double>(bottomLeft.x + dx, bottomLeft.y - dy),
    );
  }

  /// 矩形偏移
  QuadAnnotation offsetBy({required double dx, required double dy}) {
    return QuadAnnotation(
      topLeft: Point<double>(topLeft.x + dx, topLeft.y + dy),
      topRight: Point<double>(topRight.x + dx, topRight.y + dy),
      bottomRight: Point<double>(bottomRight.x + dx, bottomRight.y + dy),
      bottomLeft: Point<double>(bottomLeft.x + dx, bottomLeft.y + dy),
    );
  }

  /// 复制当前矩形特征
  QuadAnnotation copy() {
    return QuadAnnotation(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );
  }

  /// 相等性比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuadAnnotation &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomRight == bottomRight &&
        other.bottomLeft == bottomLeft;
  }

  @override
  int get hashCode {
    return Object.hash(topLeft, topRight, bottomRight, bottomLeft);
  }

  /// 检查四边形是否正确 (convex/concave/complex quadrilateral)
  /// 更新内部错误状态并返回是否正确
  bool validateQuadrilateral() {
    final A = topLeft;
    final B = topRight;
    final C = bottomRight;
    final D = bottomLeft;

    _hasError = false;

    // 检查对边是否在另一条对角线的两侧
    bool oppositeSides1 = _checkIfOppositeSides(p1: B, p2: D, l1: A, l2: C);
    bool oppositeSides2 = _checkIfOppositeSides(p1: A, p2: C, l1: B, l2: D);

    if (oppositeSides1 && oppositeSides2) {
      // 正确的四边形，重新排序顶点以确保变量名与实际位置匹配
      // 四边形正确，检查顶点位置关系
      _reorderVertices();
      return true;
    } else {
      // 四边形交叉或其他错误情况，不进行自动重排序
      // 四边形交叉或错误，保持当前状态
      _hasError = true;
      return false;
    }
  }

  /// 重新排序顶点，确保顶点按照正确的位置关系排列
  /// 直接根据坐标位置来分配topLeft, topRight, bottomLeft, bottomRight
  void _reorderVertices() {
    final vertices = [topLeft, topRight, bottomRight, bottomLeft];

    // 直接根据坐标位置分配角色
    // 找到最小Y坐标（最上方）和最大Y坐标（最下方）
    vertices.sort((a, b) => a.y.compareTo(b.y));

    // 前两个是上方的点，后两个是下方的点
    final topPoints = [vertices[0], vertices[1]];
    final bottomPoints = [vertices[2], vertices[3]];

    // 在上方的点中，X坐标小的是topLeft，X坐标大的是topRight
    topPoints.sort((a, b) => a.x.compareTo(b.x));
    final newTopLeft = topPoints[0];
    final newTopRight = topPoints[1];

    // 在下方的点中，X坐标小的是bottomLeft，X坐标大的是bottomRight
    bottomPoints.sort((a, b) => a.x.compareTo(b.x));
    final newBottomLeft = bottomPoints[0];
    final newBottomRight = bottomPoints[1];

    // 更新顶点位置
    topLeft = newTopLeft;
    topRight = newTopRight;
    bottomLeft = newBottomLeft;
    bottomRight = newBottomRight;

    // 顶点已重新排序
  }

  /// 检查两个点是否在一条直线的两侧
  /// p1, p2: 要检查的两个点
  /// l1, l2: 构成直线的两个点
  bool _checkIfOppositeSides({
    required Point<double> p1,
    required Point<double> p2,
    required Point<double> l1,
    required Point<double> l2,
  }) {
    // 使用直线方程计算点到直线的位置关系
    final part1 = (l1.y - l2.y) * (p1.x - l1.x) + (l2.x - l1.x) * (p1.y - l1.y);
    final part2 = (l1.y - l2.y) * (p2.x - l1.x) + (l2.x - l1.x) * (p2.y - l1.y);

    // 如果两个值的乘积小于0，说明两点在直线两侧
    return (part1 * part2) < 0;
  }

  @override
  String toString() {
    return 'QuadAnnotation(topLeft: $topLeft, topRight: $topRight, bottomRight: $bottomRight, bottomLeft: $bottomLeft, hasError: $_hasError)';
  }
}
