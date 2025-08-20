# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2025-08-20

### 🐛 **Bug Fixes**

- **Screen Rotation Support:** Fixed virtual D-Pad position not updating correctly during screen orientation changes
- **Magnifier Position Fix:** Fixed magnifier position not updating when screen rotates in fine adjustment mode
- **Quadrilateral Position Fix:** Fixed quadrilateral annotation position not updating correctly after screen rotation

### 🔧 **Technical Improvements**

- **Smart Position Calculation:** Added intelligent relative position calculation for virtual D-Pad during screen size changes
- **Graceful Fallback:** Implemented fallback mechanism to default position when relative position calculation fails
- **Magnifier Synchronization:** Enhanced magnifier position synchronization with selected vertex during screen rotation
- **Layout Optimization:** Improved layout handling in `didUpdateWidget` for better screen orientation support

### 📱 **Enhanced User Experience**

- **Seamless Rotation:** Virtual D-Pad now maintains its relative position when rotating between portrait and landscape modes
- **Consistent Magnifier:** Magnifier follows the selected vertex correctly during screen orientation changes
- **Stable Annotations:** Quadrilateral annotations maintain their correct position relative to the image during rotation
- **Error Prevention:** Added comprehensive error handling and boundary checks for edge cases

### 🛠️ **API Enhancements**

- Added `_handleScreenSizeChange()` method in `VirtualDPadWidget` for screen size change handling
- Added `_calculateRelativePosition()` method for intelligent position calculation
- Added `_updateMagnifierPositionAfterSizeChange()` method in `QuadAnnotatorBox` for magnifier position updates
- Enhanced `didUpdateWidget` lifecycle methods with screen rotation support

## [0.2.0] - 2025-08-19

### 🎯 **Fine Adjustment Mode**

- **NEW:** Added fine adjustment mode with long press and double tap support
- **NEW:** Virtual D-Pad (directional pad) for pixel-perfect vertex adjustment
- **NEW:** Vertex switching functionality - click center button to cycle through vertices
- **NEW:** Real-time magnifier updates during fine adjustment
- **NEW:** Configurable step size for precise movement control

### ✨ **New Features**

- **FineAdjustmentConfiguration:**
  - Added `FineAdjustmentConfiguration` class for centralized fine adjustment settings
  - Support for multiple trigger modes: `longPress`, `doubleTap`, or `both`
  - Configurable long press duration for trigger sensitivity
- **VirtualDPadConfiguration:**
  - Added `VirtualDPadConfiguration` class for virtual directional pad settings
  - Customizable button size, spacing, and step size
  - Configurable position (bottomRight, bottomLeft, topRight, topLeft)
  - Full styling control: colors, opacity, border radius, and border width
  - Icon-based directional buttons with arrow indicators
  - Center button displays current vertex number (1-4)

### 🎮 **Enhanced User Experience**

- **Dual Trigger Support:** Enter fine adjustment mode via long press (500ms) or double tap
- **Pixel-Perfect Control:** Use virtual D-Pad for 1-pixel precision adjustments
- **Visual Feedback:** Current vertex number displayed in center button
- **Seamless Integration:** Fine adjustment works alongside existing drag functionality
- **Smart State Management:** Proper entry/exit of fine adjustment mode

### 🛠️ **API Enhancements**

- Added `fineAdjustment` parameter to `QuadAnnotatorBox`
- New `FineAdjustmentMode` enum with `longPress`, `doubleTap`, and `both` options
- Enhanced painter with virtual D-Pad rendering capabilities
- Improved gesture handling for dual interaction modes

### 📚 **Documentation Updates**

- Updated README.md with fine adjustment mode examples
- Added comprehensive API documentation for new configuration classes
- Enhanced usage examples demonstrating pixel-perfect adjustment workflows

### 🔧 **Technical Improvements**

- Enhanced `QuadrilateralPainter` with virtual D-Pad rendering
- Improved gesture recognition for long press and double tap detection
- Better state management for fine adjustment mode transitions
- Optimized rendering performance for virtual controls

## [0.1.0] - 2025-07-02

### 🔄 **Major Refactoring**

- **BREAKING CHANGE:** Refactored breathing animation and magnifier parameters into dedicated configuration objects
- Replaced scattered parameters with `BreathingAnimation` and `MagnifierConfiguration` classes
- Improved code organization and maintainability

### ✨ **New Features**

- **BreathingAnimation Configuration:**
  - Added `BreathingAnimation` class for centralized breathing effect configuration
  - Configurable breathing color, duration, opacity range, spacing, and stroke width
  - Enhanced visual feedback with customizable breathing light effects
- **MagnifierConfiguration Enhancement:**
  - Added `MagnifierConfiguration` class for comprehensive magnifier settings
  - Support for multiple magnifier shapes (circle, square)
  - Configurable position modes (edge, corner, follow)
  - Customizable crosshair appearance and border styling
  - Enhanced magnifier positioning with corner and edge offset options

### 🛠️ **API Improvements**

- Simplified API with grouped configuration parameters
- Better type safety with dedicated configuration classes
- Improved extensibility for future feature additions
- Enhanced code reusability across different use cases
- **Dynamic Size Detection**: Width and height parameters are now optional, supporting automatic size detection
- **Enhanced Magnifier Positioning**: `edgeOffset` parameter type changed from `double` to `Offset` for 2D positioning (`edgeOffset` 参数类型从 `double` 变为 `Offset` 以支持二维定位)

### 📚 **Documentation**

- Updated README.md with new API structure
- Added comprehensive configuration examples
- Removed outdated grid assistance feature documentation
- Enhanced API documentation with parameter tables

### 🔧 **Developer Experience**

- Better IntelliSense support with structured configuration objects
- Cleaner code organization in example applications
- Improved maintainability with logical parameter grouping

### ⚠️ **Migration Guide**

To migrate from 0.0.1 to 0.1.0:

```dart
// Old API (0.0.1)
QuadAnnotatorBox(
  enableBreathing: true,
  breathingColor: Colors.white,
  enableMagnifier: true,
  magnifierRadius: 60.0,
)

// New API (0.1.0)
QuadAnnotatorBox(
  breathing: const BreathingAnimation(
    enabled: true,
    color: Colors.white,
  ),
  magnifier: const MagnifierConfiguration(
    enabled: true,
    radius: 60.0,
  ),
)
```

## [0.0.1] - 2025-06-13

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
