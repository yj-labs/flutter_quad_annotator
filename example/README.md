# Flutter Quad Annotator Example

这是一个演示如何使用 `flutter_quad_annotator` package 的示例应用。

## 功能特性

这个示例应用展示了四边形标注工具的以下功能：

### 基本功能
- ✅ 四边形顶点拖拽
- ✅ 四边形边线拖拽
- ✅ 实时坐标显示
- ✅ 放大镜功能
- ✅ 网格辅助线
- ✅ 可自定义样式

### 交互控制
- **开关控制**：可以独立控制放大镜、网格、顶点、边线的显示/隐藏
- **滑块控制**：可以调整顶点大小和边线宽度
- **重置功能**：点击右上角刷新按钮可以重置四边形

### 实时反馈
- 拖拽过程中会在控制台输出日志
- 底部实时显示当前四边形的四个顶点坐标
- 支持顶点和边线的拖拽开始/结束事件回调

## 运行示例

1. 确保你已经安装了 Flutter SDK
2. 在项目根目录运行以下命令：

```bash
cd example
flutter pub get
flutter run
```

## 代码结构

### 主要文件
- `lib/main.dart` - 主应用代码，包含完整的示例实现
- `pubspec.yaml` - 项目依赖配置

### 核心组件使用

```dart
QuadAnnotatorBox(
  // 背景颜色
  backgroundColor: Colors.grey[100]!,
  
  // 初始四边形
  initialRectangle: _currentRectangle,
  
  // 回调函数
  onVerticesChanged: _onVerticesChanged,
  onVertexDragStart: _onVertexDragStart,
  onVertexDragEnd: _onVertexDragEnd,
  onEdgeDragStart: _onEdgeDragStart,
  onEdgeDragEnd: _onEdgeDragEnd,
  
  // 显示控制
  showMagnifier: _showMagnifier,
  showGrid: _showGrid,
  showVertices: _showVertices,
  showEdges: _showEdges,
  
  // 样式配置
  vertexSize: _vertexSize,
  edgeWidth: _edgeWidth,
  vertexColor: Colors.blue,
  edgeColor: Colors.red,
  
  // 放大镜配置
  magnifierSize: 120.0,
  magnificationScale: 2.0,
  magnifierPositionMode: MagnifierPositionMode.edge,
  
  // 网格配置
  gridSpacing: 20.0,
  gridColor: Colors.grey.withOpacity(0.3),
  gridWidth: 0.5,
)
```

## 自定义配置

你可以通过修改以下参数来自定义四边形标注工具的外观和行为：

### 样式配置
- `vertexSize`: 顶点大小
- `edgeWidth`: 边线宽度
- `vertexColor`: 顶点颜色
- `edgeColor`: 边线颜色
- `backgroundColor`: 背景颜色

### 放大镜配置
- `magnifierSize`: 放大镜大小
- `magnificationScale`: 放大倍数
- `magnifierPositionMode`: 放大镜位置模式

### 网格配置
- `gridSpacing`: 网格间距
- `gridColor`: 网格颜色
- `gridWidth`: 网格线宽度

### 显示控制
- `showMagnifier`: 是否显示放大镜
- `showGrid`: 是否显示网格
- `showVertices`: 是否显示顶点
- `showEdges`: 是否显示边线

## 回调函数

示例中演示了如何使用各种回调函数来响应用户交互：

- `onVerticesChanged`: 四边形顶点变化时触发
- `onVertexDragStart`: 开始拖拽顶点时触发
- `onVertexDragEnd`: 结束拖拽顶点时触发
- `onEdgeDragStart`: 开始拖拽边线时触发
- `onEdgeDragEnd`: 结束拖拽边线时触发

这些回调函数可以用于实现更复杂的业务逻辑，比如数据保存、状态同步等。
