# Flutter Quad Annotator

[![pub package](https://img.shields.io/pub/v/flutter_quad_annotator.svg)](https://pub.dev/packages/flutter_quad_annotator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.19.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%5E3.2.0-blue.svg)](https://dart.dev/)

[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue.svg)](https://flutter.dev/)
[![Support](https://img.shields.io/badge/Support-Mobile%20%7C%20Desktop%20%7C%20Web-green.svg)](https://flutter.dev/)

一个功能强大的 Flutter 四边形标注工具包，提供可拖拽的四点定位四边形组件，支持放大镜、精细调整、自动检测等丰富功能。

## 📱 预览

### 多平台支持展示

<table>
  <tr>
    <td align="center">
      <img src="doc/images/demo-android.png" width="200" alt="Android Demo"/>
      <br/>
      <b>Android</b>
    </td>
    <td align="center">
      <img src="doc/images/demo-ios.png" width="200" alt="iOS Demo"/>
      <br/>
      <b>iOS</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="doc/images/demo-web.png" width="200" alt="Web Demo"/>
      <br/>
      <b>Web</b>
    </td>
    <td align="center">
      <img src="doc/images/demo-macos.png" width="200" alt="macOS Demo"/>
      <br/>
      <b>macOS</b>
    </td>
  </tr>
</table>

### 🌐 在线演示

**[点击这里体验在线演示](https://yj-labs.github.io/flutter_quad_annotator/)**

_或者运行本地示例应用查看完整功能演示_

## 功能特性

- ✅ **四边形顶点拖拽** - 支持拖拽四个顶点来调整四边形形状
- ✅ **四边形边线拖拽** - 支持拖拽边线来移动整个四边形
- ✅ **放大镜功能** - 拖拽时显示放大镜，便于精确定位
- ✅ **精调模式** - 长按或双击顶点进入精调模式，支持像素级精确调整
- ✅ **虚拟方向键** - 精调模式下显示虚拟方向键，支持上下左右精确移动
- ✅ **顶点切换** - 精调模式下可快速切换不同顶点进行调整
- ✅ **交互式教程系统** - 内置分步引导教程，帮助用户快速掌握所有功能
- ✅ **教程自定义** - 支持自定义教程文本、颜色、动画效果等
- ✅ **智能位置记忆** - 虚拟方向键面板记住用户偏好位置
- ✅ **屏幕旋转支持** - 完美支持屏幕旋转，所有 UI 元素位置智能更新
- ✅ **呼吸动画效果** - 可配置的呼吸灯动画，提升视觉体验
- ✅ **高度可定制** - 支持自定义颜色、大小、样式等
- ✅ **配置对象化** - 呼吸动画、放大镜、精调模式和教程配置抽象为独立对象
- ✅ **事件回调** - 提供丰富的拖拽事件回调
- ✅ **单点触控** - 智能的单点触控识别，避免多点触控干扰
- ✅ **性能优化** - 智能的尺寸变化检测，减少不必要的重建

## 📋 平台支持

| 平台       | 支持状态 | 备注         |
| ---------- | -------- | ------------ |
| ✅ Android | 完全支持 | API 16+      |
| ✅ iOS     | 完全支持 | iOS 9.0+     |
| ✅ Web     | 完全支持 | 现代浏览器   |
| ✅ macOS   | 完全支持 | macOS 10.11+ |
| ✅ Windows | 完全支持 | Windows 7+   |
| ✅ Linux   | 完全支持 | 主流发行版   |

## 快速开始

### 安装

在你的 `pubspec.yaml` 文件中添加依赖：

````yaml
```yaml
dependencies:
  flutter_quad_annotator: ^0.3.0
````

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
  onVerticesChanged: (QuadAnnotation rectangle) {
    print('四边形顶点已更新: ${rectangle.vertices}');
  },
  breathing: const BreathingAnimation(
    enabled: true,
    color: Colors.white,
    duration: Duration(seconds: 2),
  ),
  magnifier: const MagnifierConfiguration(
    enabled: true,
    radius: 60.0,
    magnification: 2.0,
  ),
  fineAdjustment: const FineAdjustmentConfiguration(
    mode: FineAdjustmentMode.both, // 支持长按和双击
    dpadConfig: VirtualDPadConfiguration(
      enabled: true,
      size: 40.0,
      stepSize: 1.0,
      position: Alignment.bottomRight,
    ),
  ),
  tutorial: const TutorialConfiguration(
    enabled: true,
    autoStart: false, // 手动启动教程
    overlayColor: Color(0xCC000000),
    skipButtonText: '跳过',
    hintStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    enablePulseAnimation: true,
    pulseColor: Colors.orange,
  ),
  vertexColor: Colors.blue,
  borderColor: Colors.red,
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

| 参数                | 类型                           | 默认值                     | 说明                     |
| ------------------- | ------------------------------ | -------------------------- | ------------------------ |
| `image`             | `ui.Image?`                    | `null`                     | 背景图片对象             |
| `imageProvider`     | `ImageProvider?`               | `null`                     | 图片提供者               |
| `width`             | `double?`                      | `null`                     | 组件宽度（可选，自适应） |
| `height`            | `double?`                      | `null`                     | 组件高度（可选，自适应） |
| `backgroundColor`   | `Color`                        | `Colors.transparent`       | 背景颜色                 |
| `rectangle`         | `QuadAnnotation?`              | `null`                     | 初始四边形               |
| `onVerticesChanged` | `OnVerticesChanged?`           | `null`                     | 顶点变化回调             |
| `breathing`         | `BreathingAnimation`           | `BreathingAnimation()`     | 呼吸动画配置             |
| `magnifier`         | `MagnifierConfiguration`       | `MagnifierConfiguration()` | 放大镜配置               |
| `fineAdjustment`    | `FineAdjustmentConfiguration?` | `null`                     | 精调模式配置             |
| `tutorial`          | `TutorialConfiguration?`       | `null`                     | 教程系统配置             |
| `vertexRadius`      | `double`                       | `8.0`                      | 顶点半径                 |
| `borderWidth`       | `double`                       | `2.0`                      | 边框宽度                 |
| `vertexColor`       | `Color`                        | `Colors.white`             | 顶点颜色                 |
| `borderColor`       | `Color`                        | `Colors.white`             | 边框颜色                 |
| `autoDetect`        | `bool`                         | `true`                     | 是否自动检测矩形         |
| `preview`           | `bool`                         | `false`                    | 是否为预览模式           |
| `controller`        | `QuadAnnotatorController?`     | `null`                     | 外部控制器               |

### QuadAnnotation

四边形标注类，用于存储和操作四个顶点坐标。

```dart
// 创建四边形
final rectangle = QuadAnnotation(
  topLeft: Point<double>(10, 10),
  topRight: Point<double>(100, 10),
  bottomRight: Point<double>(100, 100),
  bottomLeft: Point<double>(10, 100),
);

// 从顶点列表创建
final rectangle = QuadAnnotation.fromVertices([
  Point<double>(10, 10),
  Point<double>(100, 10),
  Point<double>(100, 100),
  Point<double>(10, 100),
]);

// 获取顶点列表
List<Point<double>> vertices = rectangle.vertices;

// 获取边界矩形
Rect bounds = rectangle.bounds;
```

## 高级配置

### BreathingAnimation 配置

呼吸动画配置类，用于控制四边形的呼吸灯效果。

```dart
QuadAnnotatorBox(
  breathing: const BreathingAnimation(
    enabled: true,
    color: Colors.white,
    duration: Duration(seconds: 2),
    opacityMin: 0.2,
    opacityMax: 0.9,
    spacing: 4.0,
    strokeWidth: 2.0,
  ),
)
```

#### BreathingAnimation 参数

| 参数          | 类型       | 默认值                 | 说明             |
| ------------- | ---------- | ---------------------- | ---------------- |
| `enabled`     | `bool`     | `false`                | 是否启用呼吸动画 |
| `color`       | `Color`    | `Colors.white`         | 呼吸动画颜色     |
| `duration`    | `Duration` | `Duration(seconds: 2)` | 动画持续时间     |
| `opacityMin`  | `double`   | `0.2`                  | 最小透明度       |
| `opacityMax`  | `double`   | `0.9`                  | 最大透明度       |
| `spacing`     | `double`   | `4.0`                  | 呼吸线间距       |
| `strokeWidth` | `double`   | `2.0`                  | 呼吸线宽度       |

### MagnifierConfiguration 配置

放大镜配置类，用于控制拖拽时的放大镜效果。

```dart
QuadAnnotatorBox(
  magnifier: const MagnifierConfiguration(
    enabled: true,
    radius: 60.0,
    magnification: 2.0,
    borderColor: Colors.white,
    borderWidth: 3.0,
    crosshairColor: Colors.white,
    crosshairRadiusRatio: 0.8,
    positionMode: MagnifierPositionMode.edge,
    cornerPosition: MagnifierCornerPosition.topRight,
    edgeOffset: Offset(20.0, 20.0),
    shape: MagnifierShape.circle,
  ),
)
```

#### MagnifierConfiguration 参数

| 参数                   | 类型                      | 默认值                             | 说明             |
| ---------------------- | ------------------------- | ---------------------------------- | ---------------- |
| `enabled`              | `bool`                    | `false`                            | 是否启用放大镜   |
| `radius`               | `double`                  | `60.0`                             | 放大镜半径       |
| `magnification`        | `double`                  | `2.0`                              | 放大倍数         |
| `borderColor`          | `Color`                   | `Colors.white`                     | 边框颜色         |
| `borderWidth`          | `double`                  | `3.0`                              | 边框宽度         |
| `crosshairColor`       | `Color`                   | `Colors.white`                     | 十字线颜色       |
| `crosshairRadiusRatio` | `double`                  | `0.8`                              | 十字线半径比例   |
| `positionMode`         | `MagnifierPositionMode`   | `MagnifierPositionMode.edge`       | 位置模式         |
| `cornerPosition`       | `MagnifierCornerPosition` | `MagnifierCornerPosition.topRight` | 角落位置         |
| `edgeOffset`           | `Offset`                  | `Offset(20.0, 20.0)`               | 二维边缘偏移向量 |
| `shape`                | `MagnifierShape`          | `MagnifierShape.circle`            | 放大镜形状       |

### TutorialConfiguration 配置

教程配置类，用于控制交互式教程系统的外观和行为。

```dart
QuadAnnotatorBox(
  tutorial: const TutorialConfiguration(
    enabled: true,
    autoStart: false,
    overlayColor: Color(0xCC000000),
    skipButtonText: 'Skip',
    hintStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    hintBackgroundColor: Colors.transparent,
    spotlightPadding: 20.0,
    startDelay: Duration(milliseconds: 1000),
    stepInterval: Duration(milliseconds: 800),
    enablePulseAnimation: true,
    pulseColor: Colors.orange,
    stepTexts: {
      TutorialStep.dragVertex: 'Drag the highlighted vertex to adjust the quadrilateral shape.',
      TutorialStep.longPressVertex: 'Long press the highlighted vertex to enter precision mode.',
      // ... 其他步骤文本
    },
  ),
)
```

#### TutorialConfiguration 参数

| 参数                         | 类型                        | 默认值                         | 说明                   |
| ---------------------------- | --------------------------- | ------------------------------ | ---------------------- |
| `enabled`                    | `bool`                      | `true`                         | 是否启用教程系统       |
| `autoStart`                  | `bool`                      | `false`                        | 是否自动开始教程       |
| `overlayColor`               | `Color`                     | `Color(0xCC000000)`            | 遮罩层颜色             |
| `skipButtonText`             | `String`                    | `'Skip'`                       | 跳过按钮文本           |
| `skipButtonStyle`            | `ButtonStyle?`              | `null`                         | 跳过按钮样式           |
| `hintStyle`                  | `TextStyle`                 | 白色 16 号字体                 | 引导提示文本样式       |
| `hintBackgroundColor`        | `Color`                     | `Colors.transparent`           | 引导提示背景颜色       |
| `hintBorderRadius`           | `double`                    | `8.0`                          | 引导提示圆角半径       |
| `hintPadding`                | `EdgeInsets`                | `EdgeInsets.zero`              | 引导提示内边距         |
| `hintContainerMargin`        | `double`                    | `20.0`                         | 引导提示容器边距       |
| `hintEstimatedHeight`        | `double`                    | `150.0`                        | 引导提示容器预估高度   |
| `connectionLineLength`       | `double`                    | `60.0`                         | 连接线长度             |
| `iconSize`                   | `double`                    | `56.0`                         | 图标尺寸               |
| `lineToIconDistance`         | `double`                    | `20.0`                         | 连接线到图标的间距     |
| `iconToTextDistance`         | `double`                    | `12.0`                         | 图标到文本的间距       |
| `spotlightPadding`           | `double`                    | `20.0`                         | 聚光灯边距             |
| `spotlightAnimationDuration` | `Duration`                  | `Duration(milliseconds: 800)`  | 聚光灯动画持续时间     |
| `highlightBorderColor`       | `Color`                     | `Colors.orange`                | 高亮边框颜色           |
| `highlightBorderWidth`       | `double`                    | `3.0`                          | 高亮边框宽度           |
| `enablePulseAnimation`       | `bool`                      | `true`                         | 是否启用脉冲动画       |
| `pulseColor`                 | `Color`                     | `Colors.orange`                | 脉冲动画颜色           |
| `pulseAnimationDuration`     | `Duration`                  | `Duration(milliseconds: 2000)` | 脉冲动画持续时间       |
| `startDelay`                 | `Duration`                  | `Duration(milliseconds: 1000)` | 引导开始的延迟时间     |
| `stepInterval`               | `Duration`                  | `Duration(milliseconds: 800)`  | 引导步骤之间的间隔时间 |
| `stepTexts`                  | `Map<TutorialStep, String>` | 默认英文文本                   | 每个步骤的引导文本     |
| `stepSpotlightPadding`       | `Map<TutorialStep, double>` | 各步骤默认边距                 | 每个步骤的聚光灯边距   |

### FineAdjustmentConfiguration 配置

精调模式配置类，用于控制精调模式的行为和虚拟方向键。

```dart
QuadAnnotatorBox(
  fineAdjustment: const FineAdjustmentConfiguration(
    mode: FineAdjustmentMode.both, // 支持长按和双击
    longPressDuration: Duration(milliseconds: 500),
    dpadConfig: VirtualDPadConfiguration(
      enabled: true,
      size: 40.0,
      stepSize: 1.0,
      spacing: 8.0,
      position: Alignment.bottomRight,
      backgroundColor: Colors.black54,
      borderColor: Colors.white,
      iconColor: Colors.white,
      opacity: 0.8,
      borderRadius: 8.0,
      borderWidth: 1.0,
    ),
  ),
)
```

#### FineAdjustmentConfiguration 参数

| 参数                | 类型                       | 默认值                         | 说明             |
| ------------------- | -------------------------- | ------------------------------ | ---------------- |
| `mode`              | `FineAdjustmentMode`       | `FineAdjustmentMode.longPress` | 精调模式触发方式 |
| `longPressDuration` | `Duration`                 | `Duration(milliseconds: 500)`  | 长按触发时长     |
| `dpadConfig`        | `VirtualDPadConfiguration` | `VirtualDPadConfiguration()`   | 虚拟方向键配置   |

#### VirtualDPadConfiguration 参数

| 参数              | 类型        | 默认值                  | 说明               |
| ----------------- | ----------- | ----------------------- | ------------------ |
| `enabled`         | `bool`      | `true`                  | 是否启用虚拟方向键 |
| `size`            | `double`    | `40.0`                  | 方向键按钮大小     |
| `stepSize`        | `double`    | `1.0`                   | 每次移动的像素步长 |
| `spacing`         | `double`    | `8.0`                   | 按钮间距           |
| `position`        | `Alignment` | `Alignment.bottomRight` | 方向键面板位置     |
| `backgroundColor` | `Color`     | `Colors.black54`        | 背景颜色           |
| `borderColor`     | `Color`     | `Colors.white`          | 边框颜色           |
| `iconColor`       | `Color`     | `Colors.white`          | 图标颜色           |
| `opacity`         | `double`    | `0.8`                   | 透明度             |
| `borderRadius`    | `double`    | `8.0`                   | 圆角半径           |
| `borderWidth`     | `double`    | `1.0`                   | 边框宽度           |

#### FineAdjustmentMode 枚举

- `FineAdjustmentMode.longPress` - 仅支持长按进入精调模式
- `FineAdjustmentMode.doubleTap` - 仅支持双击进入精调模式
- `FineAdjustmentMode.both` - 同时支持长按和双击进入精调模式

### QuadAnnotatorController 控制器

控制器类，用于外部控制四边形标注组件的行为。

```dart
final controller = QuadAnnotatorController();

QuadAnnotatorBox(
  controller: controller,
  // ... 其他配置
)

// 获取当前顶点坐标（图片坐标系）
List<Point<double>>? vertices = controller.getImageVertices();

// 重置四边形到初始状态
controller.reset();

// 检查是否正在拖拽
bool isDragging = controller.isDragging();

// 手动启动教程
controller.startTutorial();
```

#### QuadAnnotatorController 方法

| 方法                 | 返回类型               | 说明                   |
| -------------------- | ---------------------- | ---------------------- |
| `getImageVertices()` | `List<Point<double>>?` | 获取图片坐标系中的顶点 |
| `reset()`            | `void`                 | 重置四边形到初始状态   |
| `isDragging()`       | `bool`                 | 检查是否正在拖拽       |
| `startTutorial()`    | `void`                 | 手动启动教程系统       |

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

## 🚀 性能特性

- **高效渲染**: 使用自定义 `CustomPainter` 实现高性能绘制
- **内存优化**: 智能的状态管理，避免不必要的重建
- **流畅交互**: 60fps 的拖拽体验，支持高刷新率设备
- **响应式设计**: 自适应不同屏幕尺寸和像素密度

## 🔧 故障排除

### 常见问题

**Q: 拖拽时出现卡顿怎么办？**
A: 确保在 `onVerticesChanged` 回调中避免执行耗时操作，可以使用防抖或节流技术。

**Q: 如何禁用某些交互功能？**
A: 使用 `preview: true` 参数可以禁用所有交互功能。

**Q: 自动检测不准确怎么办？**
A: 可以设置 `autoDetect: false` 禁用自动检测，或者提供自定义的初始矩形 `rectangle`。

### 性能优化建议

1. **避免频繁重建**: 将 `QuadAnnotatorBox` 包装在 `const` 构造函数中
2. **合理使用回调**: 只监听必要的事件，避免在回调中执行重操作
3. **内存管理**: 及时释放不需要的资源，特别是大图像数据

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. **Fork** 本仓库
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 **Pull Request**

### 开发环境设置

```bash
# 克隆仓库
git clone https://github.com/yj-labs/flutter_quad_annotator.git
cd flutter_quad_annotator

# 安装依赖
flutter pub get

# 运行测试
flutter test

# 运行示例
cd example
flutter pub get
flutter run
```

### 代码规范

- 遵循 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- 使用 `flutter analyze` 检查代码质量
- 为新功能添加相应的测试用例
- 更新文档和示例代码

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 感谢 [rectangle_detector](https://pub.dev/packages/rectangle_detector) 提供的自动检测功能
- 感谢所有贡献者和用户的支持

## 📞 联系我们

- **Issues**: [GitHub Issues](https://github.com/yj-labs/flutter_quad_annotator/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yj-labs/flutter_quad_annotator/discussions)
- **Email**: yongtaisin@qq.com

---

<div align="center">
  <p>如果这个包对你有帮助，请给我们一个 ⭐️</p>
  <p>Made with ❤️ by Flutter Community</p>
</div>
