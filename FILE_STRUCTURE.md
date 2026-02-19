# Chart Context Menu - File Structure

## 📁 Directory Organization

The chart context menu has been refactored into a modular file structure for better maintainability and organization.

```
lib/widgets/chart_context_menu/
├── action_item.dart                    # Data model for menu actions
├── color_scheme.dart                   # Web UI color definitions
├── web_action_button.dart              # Action button component
├── web_close_button.dart               # Close button component
├── chart_context_menu_widget.dart      # Main menu widget
└── chart_context_menu_helper.dart      # Helper class for showing menu

lib/widgets/
└── chart_context_menu.dart             # Main export file (backward compatible)
```

## 📄 File Descriptions

### 1. `action_item.dart` (13 lines)
**Purpose**: Data model for menu action items

**Contents**:
- `ActionItem` class with icon, label, and callback

**Usage**:
```dart
final action = ActionItem(
  icon: Icons.download_rounded,
  label: 'Export Data',
  onTap: () => exportData(),
);
```

**Dependencies**: None (Flutter only)

---

### 2. `color_scheme.dart` (49 lines)
**Purpose**: Web-inspired color scheme definitions

**Contents**:
- `WebUIColorScheme` class with semantic color properties
- Factory constructors for light and dark modes

**Usage**:
```dart
final lightColors = WebUIColorScheme.light(accentColor);
final darkColors = WebUIColorScheme.dark(accentColor);
```

**Dependencies**: None (Flutter only)

**Color Properties**:
- `surfaceColor` - Background color
- `borderColor` - Border colors
- `textPrimary` - Main text
- `textSecondary` - Supporting text
- `textTertiary` - Hints/labels
- `accentColor` - Dynamic accent
- `hoverColor` - Hover backgrounds
- `dividerColor` - Separators

---

### 3. `web_action_button.dart` (82 lines)
**Purpose**: Stateful action button with hover effects

**Contents**:
- `WebActionButton` widget
- Hover state management
- Animated transitions

**Features**:
- Mouse hover detection
- Background color transition (150ms)
- Arrow rotation animation
- Divider management

**Usage**:
```dart
WebActionButton(
  action: actionItem,
  colorScheme: colorScheme,
  isLast: false,
)
```

**Dependencies**:
- `action_item.dart`
- `color_scheme.dart`

---

### 4. `web_close_button.dart` (50 lines)
**Purpose**: Stateful close button with hover effect

**Contents**:
- `WebCloseButton` widget
- Hover state management
- Smooth transitions

**Features**:
- Mouse hover detection
- Background color transition
- Rounded corners (6px)

**Usage**:
```dart
WebCloseButton(
  onTap: () => closeMenu(),
  colorScheme: colorScheme,
)
```

**Dependencies**:
- `color_scheme.dart`

---

### 5. `chart_context_menu_widget.dart` (588 lines)
**Purpose**: Main context menu widget implementation

**Contents**:
- `ChartContextMenu` stateful widget
- Menu rendering logic
- Three style variants (default, glassmorphism, neumorphism)
- Header, content, and actions sections

**Features**:
- Entry animations (scale + fade)
- Multiple style variants
- Metric card display
- Dynamic color based on values

**Usage**:
```dart
ChartContextMenu(
  point: dataPoint,
  position: Offset(100, 200),
  datasetLabel: 'Sales',
  onViewDetails: () {},
  onExport: () {},
  onShare: () {},
)
```

**Dependencies**:
- `action_item.dart`
- `color_scheme.dart`
- `web_action_button.dart`
- `web_close_button.dart`
- `models/chart_data.dart`
- `theme/chart_theme.dart`

---

### 6. `chart_context_menu_helper.dart` (149 lines)
**Purpose**: Helper class for showing menu as overlay

**Contents**:
- `ChartContextMenuHelper` static class
- Overlay management
- Position calculation
- Backdrop blur support

**Features**:
- Auto-positioning within screen bounds
- Background blur effect
- Tap-to-dismiss backdrop
- Cached blur filter for performance

**Usage**:
```dart
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  segment: null,
  position: tapPosition,
  onViewDetails: () {},
);

ChartContextMenuHelper.hide();
```

**Dependencies**:
- `chart_context_menu_widget.dart`
- `models/chart_data.dart`
- `theme/chart_theme.dart`

---

### 7. `chart_context_menu.dart` (7 lines)
**Purpose**: Main export file for backward compatibility

**Contents**:
- Export statements for all components

**Usage**:
```dart
// Import everything at once
import 'package:save_points_chart/widgets/chart_context_menu.dart';

// Now you can use:
// - ChartContextMenuHelper
// - ChartContextMenu
// - WebUIColorScheme
// - ActionItem
// - WebActionButton
// - WebCloseButton
```

**Note**: This maintains backward compatibility with existing code.

---

## 🔗 Dependency Graph

```
chart_context_menu.dart (exports all)
    │
    ├── action_item.dart (standalone)
    │
    ├── color_scheme.dart (standalone)
    │
    ├── web_action_button.dart
    │   ├── action_item.dart
    │   └── color_scheme.dart
    │
    ├── web_close_button.dart
    │   └── color_scheme.dart
    │
    ├── chart_context_menu_widget.dart
    │   ├── action_item.dart
    │   ├── color_scheme.dart
    │   ├── web_action_button.dart
    │   ├── web_close_button.dart
    │   ├── models/chart_data.dart
    │   └── theme/chart_theme.dart
    │
    └── chart_context_menu_helper.dart
        ├── chart_context_menu_widget.dart
        ├── models/chart_data.dart
        └── theme/chart_theme.dart
```

## 📊 File Statistics

| File | Lines | Purpose | Dependencies |
|------|-------|---------|--------------|
| `action_item.dart` | 13 | Data model | 0 |
| `color_scheme.dart` | 49 | Colors | 0 |
| `web_action_button.dart` | 82 | Button | 2 |
| `web_close_button.dart` | 50 | Button | 1 |
| `chart_context_menu_widget.dart` | 588 | Main widget | 6 |
| `chart_context_menu_helper.dart` | 149 | Helper | 3 |
| `chart_context_menu.dart` | 7 | Exports | 6 |
| **Total** | **938** | | |

## 🎯 Import Patterns

### For End Users (Recommended)
```dart
// Import the main file - gets everything
import 'package:save_points_chart/widgets/chart_context_menu.dart';

// Use the helper
ChartContextMenuHelper.show(context, ...);
```

### For Library Developers
```dart
// Import specific components
import 'package:save_points_chart/widgets/chart_context_menu/color_scheme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/web_action_button.dart';

// Use directly
final colors = WebUIColorScheme.light(Colors.blue);
```

### For Testing
```dart
// Import only what you need
import 'package:save_points_chart/widgets/chart_context_menu/action_item.dart';
import 'package:save_points_chart/widgets/chart_context_menu/web_close_button.dart';

// Test individual components
testWidgets('Close button test', (tester) async {
  await tester.pumpWidget(WebCloseButton(...));
});
```

## 🔄 Migration from Monolithic File

### Before (Single File)
```dart
// Everything in one file
lib/widgets/chart_context_menu.dart (876 lines)
```

### After (Modular Structure)
```dart
// Organized into logical components
lib/widgets/chart_context_menu/
  ├── action_item.dart (13 lines)
  ├── color_scheme.dart (49 lines)
  ├── web_action_button.dart (82 lines)
  ├── web_close_button.dart (50 lines)
  ├── chart_context_menu_widget.dart (588 lines)
  └── chart_context_menu_helper.dart (149 lines)

Total: 931 lines (organized)
```

### Benefits
- ✅ **Better organization** - Each file has a single responsibility
- ✅ **Easier testing** - Test components independently
- ✅ **Improved maintainability** - Changes are isolated
- ✅ **Better IDE support** - Faster navigation and autocomplete
- ✅ **Reusability** - Components can be used elsewhere
- ✅ **Backward compatible** - Existing code works unchanged

## 🧪 Testing Strategy

### Unit Tests
```dart
// Test individual components
test('ActionItem creation', () {
  final item = ActionItem(
    icon: Icons.share,
    label: 'Share',
    onTap: () {},
  );
  expect(item.label, 'Share');
});

test('Color scheme light mode', () {
  final colors = WebUIColorScheme.light(Colors.blue);
  expect(colors.surfaceColor, Colors.white);
});
```

### Widget Tests
```dart
// Test UI components
testWidgets('WebCloseButton renders', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WebCloseButton(
        onTap: () {},
        colorScheme: WebUIColorScheme.light(Colors.blue),
      ),
    ),
  );
  expect(find.byIcon(Icons.close_rounded), findsOneWidget);
});
```

### Integration Tests
```dart
// Test complete menu
testWidgets('Menu shows and hides', (tester) async {
  await tester.pumpWidget(MyApp());
  
  ChartContextMenuHelper.show(
    tester.element(find.byType(MyApp)),
    point: testPoint,
    segment: null,
    position: Offset.zero,
    onViewDetails: () {},
  );
  
  await tester.pumpAndSettle();
  expect(find.byType(ChartContextMenu), findsOneWidget);
  
  ChartContextMenuHelper.hide();
  await tester.pumpAndSettle();
  expect(find.byType(ChartContextMenu), findsNothing);
});
```

## 📝 Best Practices

### 1. **Always use package imports**
```dart
// ✅ Good
import 'package:save_points_chart/widgets/chart_context_menu/color_scheme.dart';

// ❌ Bad
import '../chart_context_menu/color_scheme.dart';
```

### 2. **Import from main file for end users**
```dart
// ✅ Good (for app developers)
import 'package:save_points_chart/widgets/chart_context_menu.dart';

// ⚠️ Only for library development
import 'package:save_points_chart/widgets/chart_context_menu/web_action_button.dart';
```

### 3. **Keep components focused**
- Each file should have a single responsibility
- Don't mix UI and business logic
- Keep helper functions separate

### 4. **Document public APIs**
- All public classes should have doc comments
- Include usage examples
- Document parameters and return values

## 🚀 Future Enhancements

### Potential Additions
1. **Animations** - Separate animation configurations
2. **Themes** - Custom theme presets
3. **Layouts** - Alternative layout options
4. **Builders** - Custom builder patterns

### File Structure Evolution
```
lib/widgets/chart_context_menu/
├── core/
│   ├── action_item.dart
│   ├── color_scheme.dart
│   └── menu_config.dart
├── components/
│   ├── buttons/
│   │   ├── web_action_button.dart
│   │   └── web_close_button.dart
│   ├── cards/
│   │   └── metric_card.dart
│   └── headers/
│       └── menu_header.dart
├── styles/
│   ├── glassmorphism_style.dart
│   ├── neumorphism_style.dart
│   └── default_style.dart
├── utils/
│   ├── position_calculator.dart
│   └── animation_config.dart
├── chart_context_menu_widget.dart
└── chart_context_menu_helper.dart
```

## 📚 Related Documentation

- [WEB_UI_REDESIGN.md](./WEB_UI_REDESIGN.md) - Design documentation
- [QUICK_START_WEB_UI.md](./QUICK_START_WEB_UI.md) - Quick start guide
- [VISUAL_GUIDE.md](./VISUAL_GUIDE.md) - Visual specifications
- [DESIGN_COMPARISON.md](./DESIGN_COMPARISON.md) - Before/after comparison

---

**Last Updated**: 2024
**Version**: 2.0
**Status**: ✅ Complete and tested
