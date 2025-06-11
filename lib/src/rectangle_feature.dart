import 'dart:ui';

/// 四边形特征类，用于存储和操作四个顶点坐标
/// 替代List<Offset>以提高代码严谨性，防止意外增删顶点
class RectangleFeature {
  /// 当前四边形是否有错误
  bool _hasError = false;
  
  /// 获取当前错误状态
  bool get hasError => _hasError;
  /// 左上角顶点
  Offset topLeft;
  
  /// 右上角顶点
  Offset topRight;
  
  /// 左下角顶点
  Offset bottomLeft;
  
  /// 右下角顶点
  Offset bottomRight;
  
  /// 构造函数
  RectangleFeature({
    this.topLeft = Offset.zero,
    this.topRight = Offset.zero,
    this.bottomLeft = Offset.zero,
    this.bottomRight = Offset.zero,
  });
  
  /// 从顶点列表创建矩形特征
  /// 顶点顺序：[左上, 右上, 右下, 左下]
  factory RectangleFeature.fromVertices(List<Offset> vertices) {
    if (vertices.length != 4) {
      throw ArgumentError('顶点列表必须包含4个点');
    }
    return RectangleFeature(
      topLeft: vertices[0],
      topRight: vertices[1],
      bottomRight: vertices[2],
      bottomLeft: vertices[3],
    );
  }
  
  /// 创建默认矩形（基于给定尺寸和内边距）
  factory RectangleFeature.defaultRectangle({
    required Size containerSize,
    double padding = 10.0,
  }) {
    return RectangleFeature(
      topLeft: Offset(padding, padding),
      topRight: Offset(containerSize.width - padding, padding),
      bottomRight: Offset(containerSize.width - padding, containerSize.height - padding),
      bottomLeft: Offset(padding, containerSize.height - padding),
    );
  }
  
  /// 转换为顶点列表
  /// 返回顺序：[左上, 右上, 右下, 左下]
  List<Offset> get vertices => [topLeft, topRight, bottomRight, bottomLeft];
  
  /// 获取边界矩形
  Rect get bounds {
    final points = vertices;
    double xMin = points[0].dx;
    double xMax = points[0].dx;
    double yMin = points[0].dy;
    double yMax = points[0].dy;
    
    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      if (point.dx > xMax) xMax = point.dx;
      if (point.dx < xMin) xMin = point.dx;
      if (point.dy > yMax) yMax = point.dy;
      if (point.dy < yMin) yMin = point.dy;
    }
    
    return Rect.fromLTRB(xMin, yMin, xMax, yMax);
  }
  
  /// 根据索引获取顶点
  Offset getVertex(int index) {
    switch (index) {
      case 0: return topLeft;
      case 1: return topRight;
      case 2: return bottomRight;
      case 3: return bottomLeft;
      default: throw ArgumentError('顶点索引必须在0-3之间');
    }
  }
  
  /// 根据索引设置顶点
  void setVertex(int index, Offset vertex) {
    switch (index) {
      case 0: topLeft = vertex; break;
      case 1: topRight = vertex; break;
      case 2: bottomRight = vertex; break;
      case 3: bottomLeft = vertex; break;
      default: throw ArgumentError('顶点索引必须在0-3之间');
    }
  }
  
  /// 生成一个扩大/缩小边距的矩形框
  /// dx > 0, dy > 0 表示向内缩小
  /// dx < 0, dy < 0 表示向外扩大
  RectangleFeature insetBy({required double dx, required double dy}) {
    return RectangleFeature(
      topLeft: Offset(topLeft.dx + dx, topLeft.dy + dy),
      topRight: Offset(topRight.dx - dx, topRight.dy + dy),
      bottomRight: Offset(bottomRight.dx - dx, bottomRight.dy - dy),
      bottomLeft: Offset(bottomLeft.dx + dx, bottomLeft.dy - dy),
    );
  }
  
  /// 矩形偏移
  RectangleFeature offsetBy({required double dx, required double dy}) {
    return RectangleFeature(
      topLeft: Offset(topLeft.dx + dx, topLeft.dy + dy),
      topRight: Offset(topRight.dx + dx, topRight.dy + dy),
      bottomRight: Offset(bottomRight.dx + dx, bottomRight.dy + dy),
      bottomLeft: Offset(bottomLeft.dx + dx, bottomLeft.dy + dy),
    );
  }
  
  /// 检查是否为默认的固定坐标
  bool get isFixedCoordinates {
    return topLeft == const Offset(100, 100) &&
           topRight == const Offset(300, 120) &&
           bottomRight == const Offset(280, 300) &&
           bottomLeft == const Offset(80, 280);
  }
  
  /// 复制当前矩形特征
  RectangleFeature copy() {
    return RectangleFeature(
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
    return other is RectangleFeature &&
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
      print('四边形正确，检查顶点位置关系');
      _reorderVertices();
      return true;
    } else {
      // 四边形交叉或其他错误情况，不进行自动重排序
      print('四边形交叉或错误，保持当前状态');
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
    vertices.sort((a, b) => a.dy.compareTo(b.dy));
    
    // 前两个是上方的点，后两个是下方的点
    final topPoints = [vertices[0], vertices[1]];
    final bottomPoints = [vertices[2], vertices[3]];
    
    // 在上方的点中，X坐标小的是topLeft，X坐标大的是topRight
    topPoints.sort((a, b) => a.dx.compareTo(b.dx));
    final newTopLeft = topPoints[0];
    final newTopRight = topPoints[1];
    
    // 在下方的点中，X坐标小的是bottomLeft，X坐标大的是bottomRight
    bottomPoints.sort((a, b) => a.dx.compareTo(b.dx));
    final newBottomLeft = bottomPoints[0];
    final newBottomRight = bottomPoints[1];
    
    // 更新顶点位置
    topLeft = newTopLeft;
    topRight = newTopRight;
    bottomLeft = newBottomLeft;
    bottomRight = newBottomRight;
    
    print('顶点已重新排序: TL($topLeft), TR($topRight), BL($bottomLeft), BR($bottomRight)');
  }
  
  /// 检查两个点是否在一条直线的两侧
  /// p1, p2: 要检查的两个点
  /// l1, l2: 构成直线的两个点
  bool _checkIfOppositeSides({
    required Offset p1,
    required Offset p2,
    required Offset l1,
    required Offset l2,
  }) {
    // 使用直线方程计算点到直线的位置关系
    final part1 = (l1.dy - l2.dy) * (p1.dx - l1.dx) + (l2.dx - l1.dx) * (p1.dy - l1.dy);
    final part2 = (l1.dy - l2.dy) * (p2.dx - l1.dx) + (l2.dx - l1.dx) * (p2.dy - l1.dy);
    
    // 如果两个值的乘积小于0，说明两点在直线两侧
    return (part1 * part2) < 0;
  }

  @override
  String toString() {
    return 'RectangleFeature(topLeft: $topLeft, topRight: $topRight, bottomRight: $bottomRight, bottomLeft: $bottomLeft, hasError: $_hasError)';
  }
}