# Web UI Redesign - Chart Context Menu

## Overview

The `ChartContextMenu` has been completely redesigned with a modern web UI approach, inspired by contemporary design systems like Vercel, Linear, and Stripe. The new design focuses on clean aesthetics, subtle interactions, and responsive behavior.

## Key Design Changes

### 1. **Modern Color Palette**
- Light mode: Clean whites with subtle grays (`#F9FAFB`, `#E5E7EB`)
- Dark mode: Deep grays with better contrast (`#1F2937`, `#374151`)
- Accent colors remain dynamic based on data values
- Improved text hierarchy with primary, secondary, and tertiary colors

### 2. **Simplified Layout**
- Reduced border radius from `24px` to `12px` for a more professional look
- Cleaner card-based design with subtle borders
- Better spacing and padding (16px standard, 12px for compact areas)
- Removed heavy gradients in favor of solid colors with subtle accents

### 3. **Web-Style Interactions**
- **Hover states**: Action buttons now have smooth hover transitions
- **Micro-animations**: Subtle scale and fade animations (250ms duration)
- **Mouse region detection**: Proper hover feedback on all interactive elements
- **Arrow rotation**: Action buttons show animated arrow on hover

### 4. **Improved Typography**
- Reduced font sizes for better web readability
- Header title: 14px (down from 17px)
- Metric labels: 10px uppercase with letter spacing
- Metric values: 24px bold (down from 28px)
- Action labels: 14px medium weight

### 5. **Better Visual Hierarchy**
```
┌─────────────────────────────────┐
│ Header (16px padding)           │ ← Indicator dot + Title + Close
├─────────────────────────────────┤
│ Content (16px padding)          │ ← Metric cards side by side
├─────────────────────────────────┤
│ Actions (no padding)            │ ← Stacked action buttons
│ • View Details                  │
│ • Export Data                   │
│ • Share                         │
└─────────────────────────────────┘
```

### 6. **Component Architecture**

#### New Components:
- `_WebUIColorScheme`: Centralized color management for light/dark modes
- `_WebActionButton`: Stateful button with hover effects
- `_WebCloseButton`: Minimalist close button with hover state
- `_ActionItem`: Data class for action configuration

#### Removed:
- `_MenuColorScheme`: Replaced with `_WebUIColorScheme`
- `_MenuItemColors`: No longer needed with new design
- Complex gradient backgrounds
- Heavy shadows and neumorphic effects (still available via flags)

## Visual Features

### Header Section
- **Status Indicator**: 8px circular dot with glow effect
- **Title**: Clean typography with optional subtitle
- **Close Button**: Minimalist X icon with hover background

### Content Section
- **Metric Cards**: Side-by-side layout with subtle backgrounds
- **Value Card**: Accent color with 8% opacity background
- **X Axis Card**: Neutral background with border
- **Labels**: Uppercase 10px with letter spacing

### Actions Section
- **Divider Lines**: 1px borders between actions
- **Hover Effect**: Background color transition on hover
- **Icon + Label**: 18px icon with 14px label
- **Arrow Indicator**: Animated arrow on hover (rotates from -45° to 0°)

## Animation Details

### Entry Animation
```dart
Duration: 250ms
Curve: easeOutCubic
Scale: 0.92 → 1.0
Opacity: 0.0 → 1.0
```

### Hover Animation
```dart
Duration: 150ms
Curve: easeOut
Background: transparent → hoverColor
Arrow rotation: -22.5° → 0°
```

## Color Specifications

### Light Mode
```dart
Surface: #FFFFFF
Border: #E5E7EB
Text Primary: #111827
Text Secondary: #6B7280
Text Tertiary: #9CA3AF
Hover: #F9FAFB
Divider: #E5E7EB
```

### Dark Mode
```dart
Surface: #1F2937
Border: #374151
Text Primary: #F9FAFB
Text Secondary: #D1D5DB
Text Tertiary: #9CA3AF
Hover: #374151
Divider: #4B5563
```

## Usage Example

```dart
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  segment: null,
  position: tapPosition,
  datasetLabel: 'Q4 Sales',
  onViewDetails: () => print('View details'),
  onExport: () => print('Export data'),
  onShare: () => print('Share'),
);
```

## Backward Compatibility

The redesign maintains full backward compatibility:
- All existing parameters work unchanged
- `useGlassmorphism` and `useNeumorphism` flags still functional
- Original API remains intact
- Existing implementations require no changes

## Performance Optimizations

1. **RepaintBoundary**: Prevents unnecessary repaints
2. **SingleTickerProviderStateMixin**: Efficient animation controller
3. **Const constructors**: Where possible for better performance
4. **Cached color schemes**: Computed once per build

## Accessibility

- Proper contrast ratios in both light and dark modes
- Hover states for better discoverability
- Clear visual feedback on interactions
- Semantic structure maintained

## Browser-Like Features

The new design brings web UI patterns to Flutter:
- Clean, minimal aesthetic similar to modern web apps
- Subtle hover effects like web buttons
- Card-based layout common in web dashboards
- Professional color palette matching web design systems
- Responsive spacing and typography

## Testing Recommendations

1. Test in both light and dark modes
2. Verify hover states on desktop/web
3. Check touch interactions on mobile
4. Test with different data values for color variations
5. Verify all three style modes (default, glassmorphism, neumorphism)

## Future Enhancements

Potential improvements for future versions:
- Keyboard navigation support
- Custom action icons and colors
- Configurable metric card layout
- Animation customization options
- Tooltip support for truncated text
- Responsive width based on content
