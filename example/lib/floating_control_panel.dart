import 'package:flutter/material.dart';
import 'package:flutter_quad_annotator/flutter_quad_annotator.dart';

/// 悬浮控制面板组件
/// 提供四点标注功能的各种控制选项
class FloatingControlPanel extends StatefulWidget {
  /// 面板是否折叠
  final bool isPanelCollapsed;
  
  /// 面板折叠状态变化回调
  final ValueChanged<bool> onPanelCollapseChanged;
  
  /// 镂空遮罩颜色
  final Color maskColor;
  
  /// 镂空遮罩颜色变化回调
  final ValueChanged<Color> onMaskColorChanged;
  
  /// 是否启用放大镜
  final bool enableMagnifier;
  
  /// 放大镜启用状态变化回调
  final ValueChanged<bool> onEnableMagnifierChanged;
  
  /// 是否启用呼吸灯动画
  final bool enableBreathing;
  
  /// 呼吸灯动画启用状态变化回调
  final ValueChanged<bool> onEnableBreathingChanged;
  
  /// 放大镜位置模式
  final MagnifierPositionMode magnifierPositionMode;
  
  /// 放大镜位置模式变化回调
  final ValueChanged<MagnifierPositionMode> onMagnifierPositionModeChanged;
  
  /// 放大镜角落位置
  final MagnifierCornerPosition magnifierCornerPosition;
  
  /// 放大镜角落位置变化回调
  final ValueChanged<MagnifierCornerPosition> onMagnifierCornerPositionChanged;
  
  /// 放大镜形状
  final MagnifierShape magnifierShape;
  
  /// 放大镜形状变化回调
  final ValueChanged<MagnifierShape> onMagnifierShapeChanged;
  
  /// 拖动状态文本
  final String dragStatus;
  
  /// 当前矩形顶点坐标
  final RectangleFeature currentRectangle;
  
  /// 当前图片真实坐标
  final List<Offset> currentImageVertices;
  
  /// 获取视图坐标回调
  final VoidCallback onGetVertices;
  
  /// 获取图片坐标回调
  final VoidCallback onGetImageVertices;
  
  /// 设置随机位置回调
  final VoidCallback onSetRandomVertices;
  
  /// 重置顶点回调
  final VoidCallback onResetVertices;
  
  /// 最大高度约束
  final double maxHeight;

  const FloatingControlPanel({
    super.key,
    required this.isPanelCollapsed,
    required this.onPanelCollapseChanged,
    required this.maskColor,
    required this.onMaskColorChanged,
    required this.enableMagnifier,
    required this.onEnableMagnifierChanged,
    required this.enableBreathing,
    required this.onEnableBreathingChanged,
    required this.magnifierPositionMode,
    required this.onMagnifierPositionModeChanged,
    required this.magnifierCornerPosition,
    required this.onMagnifierCornerPositionChanged,
    required this.magnifierShape,
    required this.onMagnifierShapeChanged,
    required this.dragStatus,
    required this.currentRectangle,
    required this.currentImageVertices,
    required this.onGetVertices,
    required this.onGetImageVertices,
    required this.onSetRandomVertices,
    required this.onResetVertices,
    required this.maxHeight,
  });

  @override
  State<FloatingControlPanel> createState() => _FloatingControlPanelState();
}

class _FloatingControlPanelState extends State<FloatingControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        width: 300,
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight - 100,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 面板标题栏
            _buildPanelHeader(),
            // 可折叠的内容区域
            if (!widget.isPanelCollapsed) _buildPanelContent(),
          ],
        ),
      ),
    );
  }

  /// 构建面板标题栏
  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            '控制面板',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // 折叠/展开按钮
          IconButton(
            onPressed: () {
              widget.onPanelCollapseChanged(!widget.isPanelCollapsed);
            },
            icon: Icon(
              widget.isPanelCollapsed ? Icons.expand_more : Icons.expand_less,
              color: Colors.blue,
            ),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建面板内容区域
  Widget _buildPanelContent() {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 功能开关控制
                  _buildFunctionSwitches(),
                  const SizedBox(height: 8),
                  // 放大镜配置
                  _buildMagnifierSettings(),
                  const SizedBox(height: 8),
                  // 拖动状态显示
                  _buildDragStatus(),
                  const SizedBox(height: 12),
                  // 坐标信息显示
                  _buildCoordinateInfo(),
                  const SizedBox(height: 12),
                  // 操作按钮
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能开关控制区域
  Widget _buildFunctionSwitches() {
    return Column(
      children: [
        // 镂空遮罩控制
        Row(
          children: [
            const Text(
              '镂空遮罩：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Switch(
              value: widget.maskColor.alpha > 0,
              onChanged: (value) {
                widget.onMaskColorChanged(
                  value ? const Color(0x80000000) : Colors.transparent,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 放大镜效果控制
        Row(
          children: [
            const Text(
              '放大镜效果：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Switch(
              value: widget.enableMagnifier,
              onChanged: widget.onEnableMagnifierChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 呼吸灯动画控制
        Row(
          children: [
            const Text(
              '呼吸灯动画：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Switch(
              value: widget.enableBreathing,
              onChanged: widget.onEnableBreathingChanged,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建放大镜配置区域
  Widget _buildMagnifierSettings() {
    return Column(
      children: [
        // 放大镜位置模式
        Row(
          children: [
            const Icon(Icons.zoom_in, size: 14, color: Colors.purple),
            const SizedBox(width: 4),
            const Text('放大镜模式:', style: TextStyle(fontSize: 12)),
            const Spacer(),
            DropdownButton<MagnifierPositionMode>(
              value: widget.magnifierPositionMode,
              onChanged: (value) {
                if (value != null) {
                  widget.onMagnifierPositionModeChanged(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: MagnifierPositionMode.center,
                  child: Text('圆心模式', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: MagnifierPositionMode.corner,
                  child: Text('角落模式', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: MagnifierPositionMode.edge,
                  child: Text('边缘模式', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 角落位置选择（仅在角落模式下显示）
        if (widget.magnifierPositionMode == MagnifierPositionMode.corner)
          Row(
            children: [
              const Icon(Icons.crop_free, size: 14, color: Colors.purple),
              const SizedBox(width: 4),
              const Text('角落位置:', style: TextStyle(fontSize: 12)),
              const Spacer(),
              DropdownButton<MagnifierCornerPosition>(
                value: widget.magnifierCornerPosition,
                onChanged: (value) {
                  if (value != null) {
                    widget.onMagnifierCornerPositionChanged(value);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: MagnifierCornerPosition.topLeft,
                    child: Text('左上角', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: MagnifierCornerPosition.topRight,
                    child: Text('右上角', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: MagnifierCornerPosition.bottomLeft,
                    child: Text('左下角', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: MagnifierCornerPosition.bottomRight,
                    child: Text('右下角', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        if (widget.magnifierPositionMode == MagnifierPositionMode.corner)
          const SizedBox(height: 8),
        // 放大镜形状选择
        Row(
          children: [
            const Icon(Icons.crop_square, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            const Text('放大镜形状:', style: TextStyle(fontSize: 12)),
            const Spacer(),
            DropdownButton<MagnifierShape>(
              value: widget.magnifierShape,
              onChanged: (value) {
                if (value != null) {
                  widget.onMagnifierShapeChanged(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: MagnifierShape.circle,
                  child: Text('圆形', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: MagnifierShape.rectangle,
                  child: Text('方形', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 构建拖动状态显示区域
  Widget _buildDragStatus() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            '状态: ${widget.dragStatus}',
            style: TextStyle(
              fontSize: 12,
              color: widget.dragStatus == '未拖动' ? Colors.grey : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建坐标信息显示区域
  Widget _buildCoordinateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '顶点坐标：',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // 视图坐标
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '视图坐标:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              for (int i = 0; i < widget.currentRectangle.vertices.length; i++)
                Text(
                  '点${i + 1}: (${widget.currentRectangle.vertices[i].dx.toStringAsFixed(1)}, ${widget.currentRectangle.vertices[i].dy.toStringAsFixed(1)})',
                  style: const TextStyle(fontSize: 11),
                ),
            ],
          ),
        ),
        // 图片真实坐标（如果存在）
        if (widget.currentImageVertices.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '图片真实坐标:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                for (int i = 0; i < widget.currentImageVertices.length; i++)
                  Text(
                    '点${i + 1}: (${widget.currentImageVertices[i].dx.toStringAsFixed(1)}, ${widget.currentImageVertices[i].dy.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 11, color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _buildSmallButton('获取视图坐标', widget.onGetVertices, Colors.blue),
        _buildSmallButton('获取图片坐标', widget.onGetImageVertices, Colors.green),
        _buildSmallButton('随机位置', widget.onSetRandomVertices, Colors.purple),
        _buildSmallButton('重置', widget.onResetVertices, Colors.grey),
      ],
    );
  }

  /// 构建小按钮
  /// [text] 按钮文本
  /// [onPressed] 点击回调
  /// [color] 按钮颜色
  Widget _buildSmallButton(String text, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}