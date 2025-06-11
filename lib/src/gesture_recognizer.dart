import 'package:flutter/gestures.dart';

/// 单点触控拖拽手势识别器
/// 只允许第一个触摸点进行拖拽操作，忽略后续的触摸点
class SingleTouchPanGestureRecognizer extends PanGestureRecognizer {
  int? _activePointer;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // 如果已经有活跃的触摸点，忽略新的触摸点
    if (_activePointer != null) {
      return;
    }
    
    _activePointer = event.pointer;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    // 只处理活跃触摸点的事件
    if (event.pointer == _activePointer) {
      super.handleEvent(event);
      
      // 如果触摸点抬起，重置活跃触摸点
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        _activePointer = null;
      }
    }
  }

  @override
  void dispose() {
    _activePointer = null;
    super.dispose();
  }
}