# Publishing Guide for pub.dev

This guide will help you publish `save_points_chart` to pub.dev.

## Prerequisites

1. **pub.dev Account**: Create an account at https://pub.dev
2. **Google Account**: You'll need a Google account to sign in
3. **Verified Email**: Make sure your email is verified on pub.dev

## Pre-Publishing Checklist

### 1. Verify Package Name Availability

Check if `save_points_chart` is available:
```bash
flutter pub publish --dry-run
```

If the name is taken, you'll need to change it in `pubspec.yaml`.

### 2. Update Version

Make sure your version in `pubspec.yaml` follows semantic versioning:
- `1.0.0` for initial release
- `1.0.1` for bug fixes
- `1.1.0` for new features
- `2.0.0` for breaking changes

### 3. Verify All Files

Run these commands to ensure everything is ready:

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Check for issues
flutter pub publish --dry-run
```

### 4. Update Documentation

- ✅ README.md is comprehensive
- ✅ CHANGELOG.md is up to date
- ✅ LICENSE file exists (MIT)
- ✅ All public APIs are documented

### 5. Remove Unnecessary Files

The `.pubignore` file will exclude:
- Platform-specific folders (android, ios, web, etc.)
- Build artifacts
- IDE files
- Example app (if separate)

## Publishing Steps

### Step 1: Login to pub.dev

```bash
flutter pub login
```

This will open a browser for authentication.

### Step 2: Dry Run (Test Publishing)

```bash
flutter pub publish --dry-run
```

This will:
- Check for common issues
- Show what files will be published
- Verify package structure
- Check for missing documentation

**Fix any issues before proceeding!**

### Step 3: Publish

Once the dry run passes:

```bash
flutter pub publish
```

You'll be asked to confirm. Type `y` to proceed.

### Step 4: Verify Publication

1. Visit https://pub.dev/packages/save_points_chart
2. Check that all files are present
3. Verify the README displays correctly
4. Test installation: `flutter pub add save_points_chart`

## Post-Publishing

### 1. Update Repository

Add a tag for the release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 2. Create GitHub Release

1. Go to your GitHub repository
2. Click "Releases" → "Create a new release"
3. Tag: `v1.0.0`
4. Title: `v1.0.0 - Initial Release`
5. Description: Copy from CHANGELOG.md

### 3. Share Your Package

- Add badges to README
- Share on social media
- Post in Flutter communities

## Common Issues

### Issue: Package name already taken

**Solution**: Change the name in `pubspec.yaml`:
```yaml
name: your_unique_package_name
```

### Issue: Missing documentation

**Solution**: Add dartdoc comments to all public APIs:
```dart
/// Description of the class/function
class MyClass {
  /// Description of the method
  void myMethod() {}
}
```

### Issue: SDK constraint too strict

**Solution**: Use a more flexible constraint:
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

### Issue: Missing LICENSE file

**Solution**: Ensure LICENSE file exists in the root directory.

## Updating the Package

For future updates:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run `flutter pub publish --dry-run`
4. Run `flutter pub publish`

## Resources

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [Semantic Versioning](https://semver.org/)

