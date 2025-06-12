import 'dart:math';
import '../types.dart';

/// 坐标转换工具类
/// 提供屏幕坐标、视图坐标和图片坐标之间的转换功能
class CoordinateUtils {
  /// 将屏幕坐标转换为图片坐标系（用于放大镜）
  /// [screenPoint] 屏幕坐标点
  /// [imageInfo] 图片信息
  /// 返回图片坐标系中的点
  static Point<double> convertScreenToImageCoordinates(Point<double> screenPoint, QuadImageInfo imageInfo) {
    // 减去图片在容器中的偏移量
    final adjustedPoint = screenPoint.subtractOffset(imageInfo.offset);
    
    // 计算在显示图片中的相对位置（0-1）
    final relativeX = (adjustedPoint.x / imageInfo.displaySize.width).clamp(0.0, 1.0);
    final relativeY = (adjustedPoint.y / imageInfo.displaySize.height).clamp(0.0, 1.0);
    
    // 转换为图片真实坐标
    final realX = relativeX * imageInfo.realSize.width;
    final realY = relativeY * imageInfo.realSize.height;
    
    return Point(realX, realY);
  }

  /// 将视图坐标转换为图片真实坐标
  /// [viewCoordinates] 视图坐标列表
  /// [imageInfo] 图片信息
  /// 返回图片真实坐标列表
  static List<Point<double>> convertToImageCoordinates(List<Point<double>> viewCoordinates, QuadImageInfo imageInfo) {
    return viewCoordinates.map((viewPoint) {
      // 减去图片在容器中的偏移量
      final adjustedPoint = viewPoint.subtractOffset(imageInfo.offset);
      
      // 计算在显示图片中的相对位置（0-1）
      final relativeX = adjustedPoint.x / imageInfo.displaySize.width;
      final relativeY = adjustedPoint.y / imageInfo.displaySize.height;
      
      // 转换为图片真实坐标
      final realX = relativeX * imageInfo.realSize.width;
      final realY = relativeY * imageInfo.realSize.height;
      
      return Point(realX, realY);
    }).toList();
  }
  
  /// 将图片真实坐标转换为视图坐标
  /// [imageCoordinates] 图片真实坐标列表
  /// [imageInfo] 图片信息
  /// 返回视图坐标列表
  static List<Point<double>> convertToViewCoordinates(List<Point<double>> imageCoordinates, QuadImageInfo imageInfo) {
    return imageCoordinates.map((imagePoint) {
      // 计算在图片中的相对位置（0-1）
      final relativeX = imagePoint.x / imageInfo.realSize.width;
      final relativeY = imagePoint.y / imageInfo.realSize.height;
      
      // 转换为显示坐标
      final displayX = relativeX * imageInfo.displaySize.width;
      final displayY = relativeY * imageInfo.displaySize.height;
      
      // 加上图片在容器中的偏移量
      return Point(displayX, displayY).addOffset(imageInfo.offset);
    }).toList();
  }

  /// 将坐标限制在图片显示区域边界内
  /// 这确保顶点只能在图片的实际显示范围内移动
  /// [position] 原始坐标
  /// [imageInfo] 图片信息
  /// 返回限制后的坐标
  static Point<double> clampToImageBounds(Point<double> position, QuadImageInfo imageInfo) {
    // 计算图片显示区域的边界
    final left = imageInfo.offset.dx;
    final top = imageInfo.offset.dy;
    final right = left + imageInfo.displaySize.width;
    final bottom = top + imageInfo.displaySize.height;
    
    return Point<double>(
      position.x.clamp(left, right),
      position.y.clamp(top, bottom),
    );
  }
}