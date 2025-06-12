import 'dart:math';

/// 几何计算工具类
/// 提供点、线段、距离等几何计算功能
class GeometryUtils {
  /// 检查点是否靠近顶点
  /// [point] 检查的点
  /// [vertex] 顶点位置
  /// [threshold] 距离阈值，默认20.0
  /// 返回是否靠近
  static bool isPointNearVertex(
    Point<double> point,
    Point<double> vertex, {
    double threshold = 20.0,
  }) {
    return point.distanceTo(vertex) < threshold;
  }

  /// 检查点是否靠近边
  /// [point] 检查的点
  /// [start] 边的起点
  /// [end] 边的终点
  /// [threshold] 距离阈值，默认15.0
  /// 返回是否靠近
  static bool isPointNearEdge(
    Point<double> point,
    Point<double> start,
    Point<double> end, {
    double threshold = 15.0,
  }) {
    // 计算点到线段的距离
    final double distance = pointToLineDistance(point, start, end);

    // 检查点是否在线段范围内
    final double segmentLength = end.distanceTo(start);
    final double distanceToStart = point.distanceTo(start);
    final double distanceToEnd = point.distanceTo(end);

    return distance < threshold &&
        distanceToStart <= segmentLength + threshold &&
        distanceToEnd <= segmentLength + threshold;
  }

  /// 计算点到线段的距离
  /// [point] 目标点
  /// [lineStart] 线段起点
  /// [lineEnd] 线段终点
  /// 返回最短距离
  /// 计算点到线段的最短距离
  static double pointToLineDistance(
    Point<double> point,
    Point<double> lineStart,
    Point<double> lineEnd,
  ) {
    final double A = point.x - lineStart.x;
    final double B = point.y - lineStart.y;
    final double C = lineEnd.x - lineStart.x;
    final double D = lineEnd.y - lineStart.y;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;
    if (lenSq == 0) {
      return point.distanceTo(lineStart); // 点在线段起点和终点之间，返回点到起点的距离
    }

    final double param = dot / lenSq;

    Point<double> projection;
    if (param < 0) {
      projection = lineStart;
    } else if (param > 1) {
      projection = lineEnd;
    } else {
      projection = Point<double>(
        lineStart.x + param * C,
        lineStart.y + param * D,
      );
    }

    return point.distanceTo(projection);
  }

  /// 计算两点之间的距离
  /// [point1] 第一个点
  /// [point2] 第二个点
  /// 返回距离值
  static double distanceBetweenPoints(
    Point<double> point1,
    Point<double> point2,
  ) {
    return point1.distanceTo(point2);
  }

  /// 计算线段的长度
  /// [start] 起点
  /// [end] 终点
  /// 返回线段长度
  static double lineLength(Point<double> start, Point<double> end) {
    return distanceBetweenPoints(start, end);
  }

  /// 计算线段的中点
  /// [start] 起点
  /// [end] 终点
  /// 返回中点坐标
  static Point<double> midPoint(Point<double> start, Point<double> end) {
    return Point((start.x + end.x) / 2, (start.y + end.y) / 2);
  }
}
