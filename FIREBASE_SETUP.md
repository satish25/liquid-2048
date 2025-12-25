# Firebase & Social Login Setup Guide

This guide walks you through setting up Firebase Authentication with Google, Apple, Facebook, and X (Twitter) sign-in for Liquid 2048.

---

## 📋 Prerequisites

- Firebase account (https://console.firebase.google.com)
- Apple Developer account (for Sign in with Apple)
- Facebook Developer account (for Facebook Login)
- Twitter/X Developer account (for X Login)

---

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it "Liquid 2048" (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

---

## 📱 Step 2: Add Apps to Firebase

### iOS App
1. Click "Add app" → iOS
2. Enter iOS bundle ID: `com.example.liquid2048Game`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### Android App
1. Click "Add app" → Android
2. Enter package name: `com.example.liquid_2048_game`
3. Download `google-services.json`
4. Place it in `android/app/`

### Web App
1. Click "Add app" → Web
2. Name it "Liquid 2048 Web"
3. Copy the Firebase config and update `web/index.html`

---

## 🔐 Step 3: Enable Authentication Providers

In Firebase Console → Authentication → Sign-in method:

### Google Sign-In
1. Click "Google" → Enable
2. Add your support email
3. Save

### Apple Sign-In
1. Click "Apple" → Enable
2. Add your Apple Services ID
3. Save

### Facebook Login
1. Click "Facebook" → Enable
2. Enter App ID and App Secret (from Facebook Developer Console)
3. Copy the OAuth redirect URI for Facebook setup
4. Save

### Twitter/X Login
1. Click "Twitter" → Enable
2. Enter API Key and API Secret (from Twitter Developer Portal)
3. Copy the callback URL for Twitter setup
4. Save

---

## 🍎 Step 4: Configure Apple Sign-In (iOS/macOS)

### In Apple Developer Console:
1. Go to Certificates, Identifiers & Profiles
2. Register an App ID with "Sign in with Apple" capability
3. Create a Services ID for web authentication

### In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Add "Sign in with Apple" capability

### Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Reversed client ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

---

## 📘 Step 5: Configure Facebook Login

### In Facebook Developer Console:
1. Create a new app at https://developers.facebook.com
2. Add "Facebook Login" product
3. Configure OAuth settings with Firebase redirect URI

### Android Setup:
Add to `android/app/src/main/res/values/strings.xml`:
```xml
<resources>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
</resources>
```

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data 
    android:name="com.facebook.sdk.ApplicationId" 
    android:value="@string/facebook_app_id"/>
<meta-data 
    android:name="com.facebook.sdk.ClientToken" 
    android:value="@string/facebook_client_token"/>
    
<activity 
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

### iOS Setup:
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_FACEBOOK_APP_ID</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Liquid 2048</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>
```

---

## 🐦 Step 6: Configure X (Twitter) Login

### In Twitter Developer Portal:
1. Create a project at https://developer.twitter.com
2. Create an app within the project
3. Enable OAuth 2.0
4. Add callback URL: `liquid2048://`

### Update `lib/core/services/auth_service.dart`:
```dart
static const String _twitterApiKey = 'YOUR_TWITTER_API_KEY';
static const String _twitterApiSecret = 'YOUR_TWITTER_API_SECRET';
static const String _twitterRedirectUri = 'liquid2048://';
```

### Android Setup:
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<activity
    android:name="com.twitter.sdk.android.core.identity.OAuthActivity"
    android:configChanges="orientation|screenSize"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="liquid2048" />
    </intent-filter>
</activity>
```

---

## 🌐 Step 7: Configure Google Sign-In

### Android Setup:
The `google-services.json` file handles most configuration.

Add SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```
Add the SHA-1 to Firebase Console → Project Settings → Your Android App

### iOS Setup:
Add URL scheme to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID</string>
```

---

## 📦 Step 8: Install Dependencies

Run:
```bash
flutter pub get
```

For iOS:
```bash
cd ios
pod install
cd ..
```

---

## ✅ Step 9: Test Authentication

1. Run the app:
```bash
flutter run
```

2. Test each login method:
   - Google Sign-In
   - Apple Sign-In (iOS/macOS only)
   - Facebook Login
   - X (Twitter) Login
   - Guest mode

---

## 🔧 Troubleshooting

### Google Sign-In Issues
- Verify SHA-1 fingerprint is added to Firebase
- Check `google-services.json` is in correct location
- Ensure URL schemes are configured

### Apple Sign-In Issues
- Verify capability is enabled in Xcode
- Check bundle ID matches Apple Developer Console
- Ensure Services ID is configured correctly

### Facebook Login Issues
- Verify App ID and Client Token
- Check Facebook app is in "Live" mode
- Ensure URL schemes are configured

### Twitter Login Issues
- Verify API keys are correct
- Check callback URL matches
- Ensure OAuth 2.0 is enabled

---

## 📝 Security Notes

1. **Never commit API keys** to version control
2. Use environment variables for sensitive data
3. Enable App Check in Firebase for production
4. Review Firebase Security Rules

---

## 📚 Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple for Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Flutter Facebook Auth](https://pub.dev/packages/flutter_facebook_auth)
- [Twitter Login for Flutter](https://pub.dev/packages/twitter_login)

