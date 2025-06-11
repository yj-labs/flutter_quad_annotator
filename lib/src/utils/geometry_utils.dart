import 'dart:ui';

/// 几何计算工具类
/// 提供点、线段、距离等几何计算功能
class GeometryUtils {
  /// 检查点是否靠近顶点
  /// [point] 检查的点
  /// [vertex] 顶点位置
  /// [threshold] 距离阈值，默认20.0
  /// 返回是否靠近
  static bool isPointNearVertex(Offset point, Offset vertex, {double threshold = 20.0}) {
    return (point - vertex).distance < threshold;
  }

  /// 检查点是否靠近边
  /// [point] 检查的点
  /// [start] 边的起点
  /// [end] 边的终点
  /// [threshold] 距离阈值，默认15.0
  /// 返回是否靠近
  static bool isPointNearEdge(Offset point, Offset start, Offset end, {double threshold = 15.0}) {
    // 计算点到线段的距离
    final double distance = pointToLineDistance(point, start, end);
    
    // 检查点是否在线段范围内
    final double segmentLength = (end - start).distance;
    final double distanceToStart = (point - start).distance;
    final double distanceToEnd = (point - end).distance;
    
    return distance < threshold && 
           distanceToStart <= segmentLength + threshold && 
           distanceToEnd <= segmentLength + threshold;
  }

  /// 计算点到线段的距离
  /// [point] 目标点
  /// [lineStart] 线段起点
  /// [lineEnd] 线段终点
  /// 返回最短距离
  static double pointToLineDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final double A = point.dx - lineStart.dx;
    final double B = point.dy - lineStart.dy;
    final double C = lineEnd.dx - lineStart.dx;
    final double D = lineEnd.dy - lineStart.dy;
    
    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      return (point - lineStart).distance;
    }
    
    final double param = dot / lenSq;
    
    Offset projection;
    if (param < 0) {
      projection = lineStart;
    } else if (param > 1) {
      projection = lineEnd;
    } else {
      projection = Offset(
        lineStart.dx + param * C,
        lineStart.dy + param * D,
      );
    }
    
    return (point - projection).distance;
  }

  /// 计算两点之间的距离
  /// [point1] 第一个点
  /// [point2] 第二个点
  /// 返回距离值
  static double distanceBetweenPoints(Offset point1, Offset point2) {
    return (point1 - point2).distance;
  }

  /// 计算线段的长度
  /// [start] 起点
  /// [end] 终点
  /// 返回线段长度
  static double lineLength(Offset start, Offset end) {
    return distanceBetweenPoints(start, end);
  }

  /// 计算线段的中点
  /// [start] 起点
  /// [end] 终点
  /// 返回中点坐标
  static Offset midPoint(Offset start, Offset end) {
    return Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
  }
}