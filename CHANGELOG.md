# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-12-19

### Added
- 🎉 Initial release of Flutter Quad Annotator package
- ✨ **Core Features:**
  - Draggable quadrilateral vertices for precise shape adjustment
  - Draggable edges for moving entire quadrilateral
  - Interactive magnifier with customizable size and scale
  - Optional grid overlay for alignment assistance
  - Single-touch gesture recognition to avoid multi-touch interference
  
- 🎨 **Customization Options:**
  - Configurable vertex colors, sizes, and styles
  - Customizable edge colors and widths
  - Adjustable background colors
  - Grid spacing and appearance settings
  - Magnifier positioning and behavior options
  
- 📱 **Event System:**
  - `onVerticesChanged` - Triggered when quadrilateral shape changes
  - `onVertexDragStart` / `onVertexDragEnd` - Vertex drag lifecycle events
  - `onEdgeDragStart` / `onEdgeDragEnd` - Edge drag lifecycle events
  
- 🔧 **Developer Experience:**
  - Comprehensive example application
  - Interactive control panel for testing all features
  - Real-time coordinate display
  - Well-documented API with inline comments
  
- 🏗️ **Architecture:**
  - `QuadAnnotatorBox` - Main annotation widget
  - `QuadAnnotatorController` - State management
  - `RectangleFeature` - Quadrilateral data model
  - `QuadrilateralPainter` - Custom rendering engine
  - `SingleTouchPanGestureRecognizer` - Gesture handling
  
- 🎯 **Additional Features:**
  - Auto-detection support with `rectangle_detector` integration
  - Preview mode for read-only display
  - Flexible initialization with custom or auto-detected rectangles
  - Optimized performance with efficient rendering

### Technical Details
- **Flutter SDK:** >=1.17.0
- **Dart SDK:** ^3.8.1
- **Dependencies:** rectangle_detector ^1.0.0
- **Platform Support:** iOS, Android, Web, Desktop

### Documentation
- Comprehensive README with usage examples
- API documentation with parameter descriptions
- Example application demonstrating all features
- MIT License for open-source usage

---

## [Unreleased]

### Planned Features
- [ ] Undo/Redo functionality
- [ ] Keyboard shortcuts support
- [ ] Export/Import quadrilateral data
- [ ] Multiple quadrilateral support
- [ ] Animation transitions
- [ ] Accessibility improvements
- [ ] Performance optimizations
- [ ] Additional gesture recognizers

---

**Note:** This changelog follows the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.
For migration guides and breaking changes, please refer to the documentation.
