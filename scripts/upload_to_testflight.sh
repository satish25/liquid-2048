#!/bin/bash

# Script to export and upload iOS app to TestFlight
# Usage: ./scripts/upload_to_testflight.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_PATH="$PROJECT_DIR/build/ios/archive/Runner.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/ios/export"
IPA_PATH="$EXPORT_PATH/Runner.ipa"

echo "📦 Exporting IPA from archive..."

# Create export options plist
cat > "$PROJECT_DIR/ios/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>WY4H3N42VQ</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export IPA
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/ios/ExportOptions.plist" \
    -allowProvisioningUpdates

if [ -f "$IPA_PATH" ]; then
    echo "✅ IPA created successfully at: $IPA_PATH"
    echo ""
    echo "📤 To upload to TestFlight, you have two options:"
    echo ""
    echo "Option 1: Using Xcode Organizer (Recommended)"
    echo "  1. Open Xcode"
    echo "  2. Go to Window > Organizer"
    echo "  3. Select your archive"
    echo "  4. Click 'Distribute App'"
    echo "  5. Choose 'App Store Connect'"
    echo "  6. Follow the prompts to upload"
    echo ""
    echo "Option 2: Using command line (requires App Store Connect API key)"
    echo "  Run: xcrun altool --upload-app --type ios --file \"$IPA_PATH\" --apiKey YOUR_API_KEY --apiIssuer YOUR_ISSUER_ID"
    echo ""
    echo "Option 3: Using Transporter app"
    echo "  1. Open Transporter app (from Mac App Store)"
    echo "  2. Drag and drop: $IPA_PATH"
    echo "  3. Click 'Deliver'"
else
    echo "❌ Failed to create IPA"
    exit 1
fi

