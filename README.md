<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

一个Flutter四边形标注工具包，提供可拖拽的四点定位四边形组件，支持放大镜、网格辅助线等功能。

## 功能特性

- ✅ **四边形顶点拖拽** - 支持拖拽四个顶点来调整四边形形状
- ✅ **四边形边线拖拽** - 支持拖拽边线来移动整个四边形
- ✅ **放大镜功能** - 拖拽时显示放大镜，便于精确定位
- ✅ **网格辅助线** - 可选的网格背景，帮助对齐
- ✅ **高度可定制** - 支持自定义颜色、大小、样式等
- ✅ **事件回调** - 提供丰富的拖拽事件回调
- ✅ **单点触控** - 智能的单点触控识别，避免多点触控干扰

## 快速开始

### 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  flutter_quad_annotator: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

### 导入

```dart
import 'package:flutter_quad_annotator/flutter_quad_annotator.dart';
```

## 基本用法

```dart
QuadAnnotatorBox(
  backgroundColor: Colors.grey[100]!,
  onVerticesChanged: (RectangleFeature rectangle) {
    print('四边形顶点已更新: ${rectangle.vertices}');
  },
  showMagnifier: true,
  showGrid: true,
  vertexColor: Colors.blue,
  edgeColor: Colors.red,
)
```

## 完整示例

查看 `/example` 文件夹中的完整示例应用，演示了所有功能的使用方法：

```bash
cd example
flutter pub get
flutter run
```

示例应用包含：
- 交互式控制面板
- 实时坐标显示
- 所有配置选项的演示
- 事件回调的使用示例

## API 文档

### QuadAnnotatorBox

主要的四边形标注组件。

#### 主要参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|---------|
| `backgroundColor` | `Color` | `Colors.white` | 背景颜色 |
| `initialRectangle` | `RectangleFeature?` | `null` | 初始四边形 |
| `onVerticesChanged` | `OnVerticesChanged?` | `null` | 顶点变化回调 |
| `showMagnifier` | `bool` | `true` | 是否显示放大镜 |
| `showGrid` | `bool` | `false` | 是否显示网格 |
| `showVertices` | `bool` | `true` | 是否显示顶点 |
| `showEdges` | `bool` | `true` | 是否显示边线 |
| `vertexSize` | `double` | `20.0` | 顶点大小 |
| `edgeWidth` | `double` | `2.0` | 边线宽度 |
| `vertexColor` | `Color` | `Colors.blue` | 顶点颜色 |
| `edgeColor` | `Color` | `Colors.red` | 边线颜色 |

### RectangleFeature

四边形特征类，用于存储和操作四个顶点坐标。

```dart
// 创建四边形
final rectangle = RectangleFeature(
  topLeft: Offset(10, 10),
  topRight: Offset(100, 10),
  bottomRight: Offset(100, 100),
  bottomLeft: Offset(10, 100),
);

// 获取顶点列表
List<Offset> vertices = rectangle.vertices;

// 获取边界矩形
Rect bounds = rectangle.bounds;
```

## 高级配置

### 放大镜配置

```dart
QuadAnnotatorBox(
  magnifierSize: 120.0,
  magnificationScale: 2.0,
  magnifierPositionMode: MagnifierPositionMode.edge,
)
```

### 网格配置

```dart
QuadAnnotatorBox(
  gridSpacing: 20.0,
  gridColor: Colors.grey.withOpacity(0.3),
  gridWidth: 0.5,
)
```

### 事件回调

```dart
QuadAnnotatorBox(
  onVerticesChanged: (rectangle) {
    // 四边形顶点变化
  },
  onVertexDragStart: (vertexIndex, position) {
    // 开始拖拽顶点
  },
  onVertexDragEnd: (vertexIndex, position) {
    // 结束拖拽顶点
  },
  onEdgeDragStart: (edgeIndex, position) {
    // 开始拖拽边线
  },
  onEdgeDragEnd: (edgeIndex, position) {
    // 结束拖拽边线
  },
)
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。
