import 'dart:math';

/// QuadAnnotator的控制器，用于控制QuadAnnotatorBox的行为
class QuadAnnotatorController {
  /// 获取图片顶点坐标的回调函数
  List<Point<double>>? Function()? onImageVertices;

  /// 重置顶点的回调函数
  void Function()? onReset;

  /// 拖动状态的回调函数
  bool Function()? onDragging;

  /// 启动引导的回调函数
  void Function()? onStartTutorial;

  /// 构造函数
  QuadAnnotatorController();

  /// 获取当前顶点坐标（图片坐标系）
  /// 返回转换为图片真实坐标的顶点列表，如果当前没有矩形则返回null
  List<Point<double>>? get vertices {
    return onImageVertices?.call();
  }

  /// 获取当前拖拽状态
  bool get isDragging {
    return onDragging?.call() ?? false;
  }

  /// 重置顶点到默认位置
  /// 将矩形重置为组件的默认大小和位置
  void reset() {
    onReset?.call();
  }

  /// 启动引导
  /// 手动启动引导流程，从第一步开始
  void startTutorial() {
    onStartTutorial?.call();
  }

  /// 释放资源
  /// 在不再使用controller时调用，清理回调函数
  void dispose() {
    onImageVertices = null;
    onReset = null;
    onStartTutorial = null;
  }
}
