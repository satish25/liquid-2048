# Liquid 2048 - Version Information

## Current Version
- **Version:** 1.0.0
- **Build Number:** 1
- **Full Version String:** 1.0.0+1

---

## Version Configuration

### Single Source of Truth
All platform versions are managed from **`pubspec.yaml`**:

```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
```

### How It Works

| Platform | Version Source | Display Version | Build Number |
|----------|---------------|-----------------|--------------|
| **iOS** | pubspec.yaml → Generated.xcconfig | CFBundleShortVersionString: 1.0.0 | CFBundleVersion: 1 |
| **Android** | pubspec.yaml → build.gradle.kts | versionName: "1.0.0" | versionCode: 1 |
| **macOS** | pubspec.yaml → Generated.xcconfig | 1.0.0 | 1 |
| **Windows** | pubspec.yaml → Runner.rc | FLUTTER_VERSION: 1.0.0 | FLUTTER_VERSION_BUILD: 1 |
| **Linux** | pubspec.yaml | 1.0.0 | 1 |
| **Web** | pubspec.yaml | Embedded in build | N/A |

---

## Version History

### Version 1.0.0 (Build 1) - December 2024
🎉 Initial Release

**Features:**
- Classic 2048 gameplay
- Liquid glass UI design with neon effects
- Undo move functionality
- High score tracking with persistence
- Smooth tile animations
- Responsive layout for all screen sizes
- Cross-platform support (iOS, Android, Web, macOS, Windows, Linux)

---

## Updating the Version

### For a New Release

1. **Update `pubspec.yaml`:**
   ```yaml
   version: 1.1.0+2  # New version 1.1.0, build number 2
   ```

2. **Run clean build:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build for your platform:**
   ```bash
   flutter build ios --release
   flutter build apk --release
   flutter build web --release
   ```

### Version Number Guidelines

- **Major (X.0.0):** Breaking changes, major redesigns
- **Minor (0.X.0):** New features, significant improvements
- **Patch (0.0.X):** Bug fixes, small improvements
- **Build (+X):** Increment for every build submitted to stores

### Example Version Progression
```
1.0.0+1  → Initial release
1.0.1+2  → Bug fix release
1.1.0+3  → New feature release
2.0.0+4  → Major redesign
```

---

## Store Requirements

### Apple App Store
- Version format: `X.X.X` (e.g., 1.0.0)
- Build number: Must increment for each upload
- CFBundleShortVersionString: User-visible version
- CFBundleVersion: Internal build number

### Google Play Store
- versionName: User-visible version string (e.g., "1.0.0")
- versionCode: Integer, must increment (e.g., 1, 2, 3...)
- Each APK/AAB must have a higher versionCode than previous

---

## Verification Commands

Check the version is set correctly:

```bash
# Check pubspec version
grep "version:" pubspec.yaml

# Verify iOS version
cat ios/Flutter/Generated.xcconfig | grep FLUTTER_BUILD

# Verify Android version (after build)
./gradlew -q printVersionName  # In android/ directory
```

