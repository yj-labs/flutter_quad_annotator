import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter/widgets.dart';

import '../types.dart';

/// 图片信息计算工具类
/// 提供图片加载、尺寸计算等功能
class ImageUtils {
  /// 从ImageProvider异步加载图片
  /// [imageProvider] 图片提供者
  /// 返回加载的图片对象
  static Future<ui.Image> loadImageFromProvider(
    flutter.ImageProvider imageProvider,
  ) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();
    final flutter.ImageStream stream = imageProvider.resolve(
      const flutter.ImageConfiguration(),
    );

    late flutter.ImageStreamListener listener;
    listener = flutter.ImageStreamListener(
      (flutter.ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    return await completer.future;
  }

  /// 获取图片信息（包含真实尺寸和显示信息）
  /// 根据图片和容器的长宽比自动选择最佳适配方式
  /// [image] 图片对象
  /// [containerWidth] 容器宽度
  /// [containerHeight] 容器高度
  /// 返回图片信息对象
  static QuadImageInfo getImageInfo(
    ui.Image image,
    double containerWidth,
    double containerHeight,
  ) {
    // 从Image对象获取真实尺寸
    final realSize = Size(image.width.toDouble(), image.height.toDouble());

    // 计算显示尺寸和偏移量（自适应缩放）
    final containerSize = Size(containerWidth, containerHeight);
    final imageAspectRatio = realSize.width / realSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;

    double displayWidth, displayHeight, offsetX, offsetY;

    if (imageAspectRatio > containerAspectRatio) {
      // 图片更宽，按宽度适配
      displayWidth = containerSize.width;
      displayHeight = displayWidth / imageAspectRatio;
      offsetX = 0;
      offsetY = (containerSize.height - displayHeight) / 2;
    } else {
      // 图片更高，按高度适配
      displayHeight = containerSize.height;
      displayWidth = displayHeight * imageAspectRatio;
      offsetX = (containerSize.width - displayWidth) / 2;
      offsetY = 0;
    }

    // 确保偏移量不为负数
    offsetX = offsetX.clamp(0, double.infinity);
    offsetY = offsetY.clamp(0, double.infinity);

    // 确保显示尺寸不超出容器边界
    displayWidth = displayWidth.clamp(0, containerSize.width);
    displayHeight = displayHeight.clamp(0, containerSize.height);

    final displaySize = Size(displayWidth, displayHeight);
    final offset = Offset(offsetX, offsetY);

    return QuadImageInfo(
      realSize: realSize,
      displaySize: displaySize,
      offset: offset,
    );
  }

  /// 计算图片的缩放比例
  /// [imageSize] 图片真实尺寸
  /// [containerSize] 容器尺寸
  /// 返回缩放比例
  static double calculateScaleRatio(Size imageSize, Size containerSize) {
    final imageAspectRatio = imageSize.width / imageSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;

    if (imageAspectRatio > containerAspectRatio) {
      // 按宽度适配
      return containerSize.width / imageSize.width;
    } else {
      // 按高度适配
      return containerSize.height / imageSize.height;
    }
  }

  /// 检查图片是否已加载
  /// [image] 图片对象
  /// 返回是否已加载
  static bool isImageLoaded(ui.Image? image) {
    return image != null && !image.debugDisposed;
  }

  /// 获取图片的宽高比
  /// [image] 图片对象
  /// 返回宽高比
  static double getAspectRatio(ui.Image image) {
    return image.width / image.height;
  }

  /// 计算适配后的图片尺寸
  /// [imageSize] 原始图片尺寸
  /// [containerSize] 容器尺寸
  /// [fitMode] 适配模式（contain或cover）
  /// 返回适配后的尺寸
  static Size calculateFittedSize(
    Size imageSize,
    Size containerSize, {
    BoxFit fitMode = BoxFit.contain,
  }) {
    final imageAspectRatio = imageSize.width / imageSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;

    switch (fitMode) {
      case BoxFit.contain:
        if (imageAspectRatio > containerAspectRatio) {
          // 按宽度适配
          final width = containerSize.width;
          final height = width / imageAspectRatio;
          return Size(width, height);
        } else {
          // 按高度适配
          final height = containerSize.height;
          final width = height * imageAspectRatio;
          return Size(width, height);
        }
      case BoxFit.cover:
        if (imageAspectRatio > containerAspectRatio) {
          // 按高度适配
          final height = containerSize.height;
          final width = height * imageAspectRatio;
          return Size(width, height);
        } else {
          // 按宽度适配
          final width = containerSize.width;
          final height = width / imageAspectRatio;
          return Size(width, height);
        }
      default:
        return containerSize;
    }
  }
}
