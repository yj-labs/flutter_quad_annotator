import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'quad_annotation.dart';
import 'types.dart';

/// 四边形绘制器
/// 负责在Canvas上绘制四边形选区、顶点、遮罩和放大镜效果
class QuadrilateralPainter extends CustomPainter {
  /// 四边形的顶点坐标列表
  final List<Point<double>> vertices;

  /// 四边形注释对象
  final QuadAnnotation rectangle;

  /// 当前被拖动的顶点索引，-1表示没有顶点被拖动
  final int draggedVertexIndex;

  /// 当前被拖动的边索引，-1表示没有边被拖动
  final int draggedEdgeIndex;

  /// 四边形边框颜色
  final Color borderColor;

  /// 错误状态下的边框颜色
  final Color errorColor;

  /// 四边形填充颜色
  final Color fillColor;

  /// 顶点圆圈颜色
  final Color vertexColor;

  /// 高亮颜色（用于被拖动的顶点或边）
  final Color highlightColor;

  /// 顶点圆圈半径
  final double vertexRadius;

  /// 边框线条宽度
  final double borderWidth;

  /// 外部遮罩颜色
  final Color maskColor;

  /// 呼吸灯动画的透明度值（0.0-1.0）
  final double breathingAnimation;

  /// 呼吸灯颜色
  final Color breathingColor;

  /// 呼吸灯与顶点之间的间距
  final double breathingGap;

  /// 呼吸灯边框宽度
  final double breathingStrokeWidth;

  /// 是否启用呼吸灯动画
  final bool enableBreathing;

  /// 是否启用放大镜功能
  final bool enableMagnifier;

  /// 是否显示放大镜
  final bool showMagnifier;

  /// 放大镜显示位置
  final Point<double> magnifierPosition;

  /// 放大镜源内容位置（要放大的区域中心点）
  final Point<double> magnifierSourcePosition;

  /// 放大镜半径
  final double magnifierRadius;

  /// 放大倍数
  final double magnification;

  /// 放大镜边框颜色
  final Color magnifierBorderColor;

  /// 放大镜边框宽度
  final double magnifierBorderWidth;

  /// 放大镜准心十字线颜色
  final Color magnifierCrosshairColor;

  /// 放大镜准心十字线半径比例
  final double magnifierCrosshairRadius;

  /// 放大镜形状（圆形或方形）
  final MagnifierShape magnifierShape;

  /// 要显示的图片对象
  final ui.Image image;

  QuadrilateralPainter({
    required this.image,
    required this.vertices,
    required this.rectangle,
    required this.draggedVertexIndex,
    required this.draggedEdgeIndex,
    required this.borderColor,
    required this.errorColor,
    required this.fillColor,
    required this.vertexColor,
    required this.highlightColor,
    required this.vertexRadius,
    required this.borderWidth,
    required this.maskColor,
    required this.breathingAnimation,
    required this.breathingColor,
    required this.breathingGap,
    required this.breathingStrokeWidth,
    required this.enableBreathing,
    required this.enableMagnifier,
    required this.showMagnifier,
    required this.magnifierPosition,
    required this.magnifierSourcePosition,
    required this.magnifierRadius,
    required this.magnification,
    required this.magnifierBorderColor,
    required this.magnifierBorderWidth,
    required this.magnifierCrosshairColor,
    required this.magnifierCrosshairRadius,
    required this.magnifierShape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 如果遮罩颜色不透明，绘制外部遮罩
    if ((maskColor.a * 255.0).round() & 0xff > 0) {
      _drawOuterMask(canvas, size);
    }

    // 绘制四边形填充
    _drawQuadrilateral(canvas);

    // 绘制顶点
    _drawVertices(canvas);

    // 绘制放大镜
    if (enableMagnifier && showMagnifier) {
      _drawMagnifier(canvas, size);
    }
  }

  /// 绘制外部遮罩效果
  void _drawOuterMask(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;

    // 创建整个画布的矩形路径
    final Path outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 创建四边形内部路径
    final Path innerPath = Path();
    innerPath.moveTo(vertices[0].x, vertices[0].y);
    for (int i = 1; i < vertices.length; i++) {
      innerPath.lineTo(vertices[i].x, vertices[i].y);
    }
    innerPath.close();

    // 使用差集操作创建镂空效果
    final Path maskPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    // 绘制遮罩
    final Paint maskPaint = Paint()
      ..color = maskColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true; // 启用抗锯齿

    canvas.drawPath(maskPath, maskPaint);
  }

  /// 绘制四边形（填充和边框）
  void _drawQuadrilateral(Canvas canvas) {
    if (vertices.isEmpty) return;

    final Path path = Path();
    path.moveTo(vertices[0].x, vertices[0].y);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].x, vertices[i].y);
    }
    path.close();

    // 绘制填充
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 绘制边框（根据四边形验证结果选择颜色）
    final Paint linePaint = Paint()
      ..color = rectangle.hasError ? errorColor : borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true; // 启用抗锯齿以减少线条锯齿
    canvas.drawPath(path, linePaint);

    // 高亮被拖动的边
    if (draggedEdgeIndex != -1) {
      final Paint highlightPaint = Paint()
        ..color = highlightColor
        ..strokeWidth = borderWidth + 2.0
        ..style = PaintingStyle.stroke;

      final int nextIndex = (draggedEdgeIndex + 1) % vertices.length;
      canvas.drawLine(
        vertices[draggedEdgeIndex].toOffset(),
        vertices[nextIndex].toOffset(),
        highlightPaint,
      );
    }
  }

  /// 绘制顶点
  void _drawVertices(Canvas canvas) {
    for (int i = 0; i < vertices.length; i++) {
      // 如果启用放大镜且当前顶点正在被拖动，则隐藏该顶点
      if (enableMagnifier && showMagnifier && draggedVertexIndex == i) {
        continue;
      }

      final Paint vertexPaint = Paint()
        ..color = draggedVertexIndex == i ? highlightColor : vertexColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true; // 启用抗锯齿

      // 呼吸灯效果边框
      final Paint breathingBorderPaint = Paint()
        ..color = breathingColor.withValues(alpha: breathingAnimation)
        ..strokeWidth = breathingStrokeWidth
        ..style = PaintingStyle.stroke;

      final Paint borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true; // 启用抗锯齿

      // 计算呼吸灯圆圈半径：顶点半径 + 间距 + 边框宽度的一半
      final double breathingRadius =
          vertexRadius + breathingGap + breathingStrokeWidth / 2;

      // 绘制顶点圆圈
      canvas.drawCircle(vertices[i].toOffset(), vertexRadius, vertexPaint);
      // 绘制呼吸灯边框（外层）- 仅在启用呼吸灯动画时绘制
      if (enableBreathing) {
        canvas.drawCircle(
          vertices[i].toOffset(),
          breathingRadius,
          breathingBorderPaint,
        );
      }
      // 绘制普通边框（内层）
      canvas.drawCircle(vertices[i].toOffset(), vertexRadius, borderPaint);
    }
  }

  /// 绘制放大镜
  void _drawMagnifier(Canvas canvas, Size size) {
    // 保存画布状态
    canvas.save();

    // 根据形状创建裁剪区域
    final Path clipPath = Path();
    if (magnifierShape == MagnifierShape.circle) {
      clipPath.addOval(
        Rect.fromCircle(
          center: magnifierPosition.toOffset(),
          radius: magnifierRadius,
        ),
      );
    } else {
      // 方形放大镜
      clipPath.addRect(
        Rect.fromCenter(
          center: magnifierPosition.toOffset(),
          width: magnifierRadius * 2,
          height: magnifierRadius * 2,
        ),
      );
    }
    canvas.clipPath(clipPath);

    // 绘制放大的背景内容
    // 计算源区域（要放大的区域）
    final double sourceRadius = magnifierRadius / magnification;
    final Rect sourceRect = Rect.fromCenter(
      center: magnifierSourcePosition.toOffset(),
      width: sourceRadius * 2,
      height: sourceRadius * 2,
    );

    // 目标区域（放大镜圆形区域）
    final Rect destRect = Rect.fromCenter(
      center: magnifierPosition.toOffset(),
      width: magnifierRadius * 2,
      height: magnifierRadius * 2,
    );

    // 绘制放大的图片内容
    canvas.drawImageRect(image, sourceRect, destRect, Paint());

    // 恢复画布状态
    canvas.restore();

    // 绘制放大镜边框
    final Paint borderPaint = Paint()
      ..color = magnifierBorderColor
      ..strokeWidth = magnifierBorderWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true; // 启用抗锯齿

    if (magnifierShape == MagnifierShape.circle) {
      canvas.drawCircle(
        magnifierPosition.toOffset(),
        magnifierRadius,
        borderPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromCenter(
          center: magnifierPosition.toOffset(),
          width: magnifierRadius * 2,
          height: magnifierRadius * 2,
        ),
        borderPaint,
      );
    }

    // 绘制准心十字线
    final Paint crosshairPaint = Paint()
      ..color = magnifierCrosshairColor
      ..strokeWidth = 1.5;

    final double crosshairLength = magnifierRadius * magnifierCrosshairRadius;

    // 水平线
    canvas.drawLine(
      magnifierPosition.toOffset() - Offset(crosshairLength, 0),
      magnifierPosition.toOffset() + Offset(crosshairLength, 0),
      crosshairPaint,
    );

    // 垂直线
    canvas.drawLine(
      magnifierPosition.toOffset() - Offset(0, crosshairLength),
      magnifierPosition.toOffset() + Offset(0, crosshairLength),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! QuadrilateralPainter) return true;

    return rectangle != oldDelegate.rectangle ||
        draggedVertexIndex != oldDelegate.draggedVertexIndex ||
        draggedEdgeIndex != oldDelegate.draggedEdgeIndex ||
        showMagnifier != oldDelegate.showMagnifier ||
        magnifierPosition != oldDelegate.magnifierPosition ||
        magnifierSourcePosition != oldDelegate.magnifierSourcePosition;
  }
}
