import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quad_annotator/flutter_quad_annotator.dart';
import 'dart:io';
import 'annotation_page.dart';

/// 应用主入口页面，提供图片选择功能
class ExampleUsagePage extends StatefulWidget {
  const ExampleUsagePage({super.key});

  @override
  State<ExampleUsagePage> createState() => _ExampleUsagePageState();
}

class _ExampleUsagePageState extends State<ExampleUsagePage> {
  final ImagePicker _picker = ImagePicker();

  /// 标注结果数据
  Map<String, dynamic>? _annotationResult;

  /// 是否显示结果
  bool get _hasResult => _annotationResult != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择图片源'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 标注结果显示区域
              if (_hasResult) ..._buildResultSection(),

              // 图片选择区域
              const SizedBox(height: 20),
              const Text(
                '请选择图片来源',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // 静态图片按钮
              _buildOptionButton(
                context,
                icon: Icons.image,
                title: '静态图片',
                subtitle: '使用应用内置的示例图片',
                color: Colors.blue,
                onPressed: _useStaticImage,
              ),

              const SizedBox(height: 20),

              // 拍照按钮
              _buildOptionButton(
                context,
                icon: Icons.camera_alt,
                title: '拍照',
                subtitle: '使用相机拍摄新照片',
                color: Colors.green,
                onPressed: _takePhoto,
              ),

              const SizedBox(height: 20),

              // 从相册选择按钮
              _buildOptionButton(
                context,
                icon: Icons.photo_library,
                title: '从相册选择',
                subtitle: '从设备相册中选择图片',
                color: Colors.orange,
                onPressed: _pickFromGallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建选项按钮
  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  /// 使用静态图片
  Future<void> _useStaticImage() async {
    await _navigateToCropPage(
      imageSource: 'assets/images/book.jpeg',
      sourceType: 'asset',
    );
  }

  /// 拍照
  Future<void> _takePhoto() async {
    await _pickImageAndNavigate(
      source: ImageSource.camera,
      errorMessage: '拍照失败',
    );
  }

  /// 从相册选择图片
  Future<void> _pickFromGallery() async {
    await _pickImageAndNavigate(
      source: ImageSource.gallery,
      errorMessage: '选择图片失败',
    );
  }

  /// 选择图片并导航到裁剪页面的通用方法
  Future<void> _pickImageAndNavigate({
    required ImageSource source,
    required String errorMessage,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
          source: source, maxWidth: 3840, maxHeight: 3840);

      if (image != null) {
        final File file = File(image.path);
        await _navigateToCropPage(
          imageSource: file,
          sourceType: 'file',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 导航到裁剪页面并处理返回结果的通用方法
  Future<void> _navigateToCropPage({
    required dynamic imageSource,
    required String sourceType,
  }) async {
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnnotationPage(
            imageSource: imageSource,
            sourceType: sourceType,
          ),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _annotationResult = result;
        });
      }
    }
  }

  /// 跳转到标注页面进行编辑（带初始点位数据）
  Future<void> _navigateToEditAnnotation({
    required dynamic imageSource,
    required String sourceType,
    required QuadAnnotation initialRectangle,
  }) async {
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnnotationPage(
            imageSource: imageSource,
            sourceType: sourceType,
            initialRectangle: initialRectangle,
          ),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _annotationResult = result;
        });
      }
    }
  }

  /// 构建标注结果显示区域
  List<Widget> _buildResultSection() {
    if (_annotationResult == null) return [];

    final rectangleFeature =
        _annotationResult!['rectangleFeature'] as QuadAnnotation;
    final imageSource = _annotationResult!['imageSource'];
    final sourceType = _annotationResult!['sourceType'] as String;

    return [
      // 标题和清除按钮
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '标注结果',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _annotationResult = null;
              });
            },
            icon: const Icon(Icons.clear),
            tooltip: '清除结果',
          ),
        ],
      ),

      const SizedBox(height: 16),

      // 图片预览（可点击跳转到标注页面）
      GestureDetector(
        onTap: () => _navigateToEditAnnotation(
          imageSource: imageSource,
          sourceType: sourceType,
          initialRectangle: rectangleFeature,
        ),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildAnnotatedImageWidget(
              imageSource: imageSource,
              sourceType: sourceType,
              rectangleFeature: rectangleFeature,
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),

      // 四边形顶点信息
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '四边形顶点坐标（图片真实坐标）:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                '左上角: (${rectangleFeature.topLeft.x.toStringAsFixed(1)}, ${rectangleFeature.topLeft.y.toStringAsFixed(1)})',
                style: const TextStyle(color: Colors.green)),
            Text(
                '右上角: (${rectangleFeature.topRight.x.toStringAsFixed(1)}, ${rectangleFeature.topRight.y.toStringAsFixed(1)})',
                style: const TextStyle(color: Colors.green)),
            Text(
                '右下角: (${rectangleFeature.bottomRight.x.toStringAsFixed(1)}, ${rectangleFeature.bottomRight.y.toStringAsFixed(1)})',
                style: const TextStyle(color: Colors.green)),
            Text(
                '左下角: (${rectangleFeature.bottomLeft.x.toStringAsFixed(1)}, ${rectangleFeature.bottomLeft.y.toStringAsFixed(1)})',
                style: const TextStyle(color: Colors.green))
          ],
        ),
      ),

      const SizedBox(height: 20),
      const Divider(),
    ];
  }

  /// 构建带标注点的图片组件
  Widget _buildAnnotatedImageWidget({
    required dynamic imageSource,
    required String sourceType,
    required QuadAnnotation rectangleFeature,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据sourceType创建对应的ImageProvider
        ImageProvider imageProvider;
        switch (sourceType) {
          case 'asset':
            imageProvider = AssetImage(imageSource as String);
            break;
          case 'file':
            imageProvider = FileImage(imageSource as File);
            break;
          default:
            throw ArgumentError('Unsupported source type: $sourceType');
        }

        // 使用UniqueKey强制每次重建组件
        return QuadAnnotatorBox.fromProvider(
          imageProvider: imageProvider,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          rectangle: rectangleFeature,
          preview: true,
          enableBreathing: false,
          // 设置样式
          vertexColor: Colors.white,
          borderColor: Colors.green,
          vertexRadius: 6.0,
          borderWidth: 2.0,
        );
      },
    );
  }
}
