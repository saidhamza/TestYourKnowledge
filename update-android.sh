#!/bin/bash
# =============================================================
# update-android.sh
# Pushes the latest web assets into the Android Capacitor app.
# Run this from the game root: /var/www/TestYourKnowledge/
# =============================================================

set -e  # Exit immediately on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANDROID_APP_DIR="$SCRIPT_DIR/.android-app"
WWW_DIR="$ANDROID_APP_DIR/www"

echo "🔄  Copying web assets to Android wrapper..."
cp -r "$SCRIPT_DIR"/*.html \
       "$SCRIPT_DIR"/*.js \
       "$SCRIPT_DIR"/*.json \
       "$SCRIPT_DIR"/*.png \
       "$SCRIPT_DIR"/*.xml \
       "$WWW_DIR/"

echo "✅  Assets copied to: $WWW_DIR"
echo ""
echo "📦  Syncing to native Android project..."
cd "$ANDROID_APP_DIR"
npx cap sync android

echo ""
echo "🎉  Done! Open Android Studio to build the APK/AAB:"
echo "    $ANDROID_APP_DIR/android"
