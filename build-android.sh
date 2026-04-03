#!/bin/bash
# =============================================================
# build-android.sh
# Syncs web assets and builds a debug or release APK.
# Usage:
#   ./build-android.sh           → debug APK
#   ./build-android.sh release   → release APK (unsigned)
# =============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANDROID_APP_DIR="$SCRIPT_DIR/.android-app"
ANDROID_DIR="$ANDROID_APP_DIR/android"
WWW_DIR="$ANDROID_APP_DIR/www"
BUILD_TYPE="${1:-debug}"
LOCAL_PROPS="$ANDROID_DIR/local.properties"

# ── Validate build type ───────────────────────────────────────
if [[ "$BUILD_TYPE" != "debug" && "$BUILD_TYPE" != "release" ]]; then
  echo "❌  Unknown build type: '$BUILD_TYPE'. Use 'debug' or 'release'."
  exit 1
fi

echo "======================================================="
echo "  🏗️   TestYourKnowledge — Android APK Builder"
echo "  Build type: $BUILD_TYPE"
echo "======================================================="
echo ""

# ── Step 1: Resolve Android SDK ──────────────────────────────
echo "🔍  Resolving Android SDK location..."

SDK_DIR=""

# Priority 1: explicit ANDROID_HOME or ANDROID_SDK_ROOT env vars
if [[ -n "$ANDROID_HOME" && -d "$ANDROID_HOME" ]]; then
  SDK_DIR="$ANDROID_HOME"
elif [[ -n "$ANDROID_SDK_ROOT" && -d "$ANDROID_SDK_ROOT" ]]; then
  SDK_DIR="$ANDROID_SDK_ROOT"
fi

# Priority 2: already set in local.properties
if [[ -z "$SDK_DIR" && -f "$LOCAL_PROPS" ]]; then
  EXISTING=$(grep -E '^sdk\.dir=' "$LOCAL_PROPS" | cut -d'=' -f2- | tr -d '\\' | xargs 2>/dev/null || true)
  if [[ -n "$EXISTING" && -d "$EXISTING" ]]; then
    SDK_DIR="$EXISTING"
  fi
fi

# Priority 3: common install locations
if [[ -z "$SDK_DIR" ]]; then
  CANDIDATES=(
    "$HOME/Android/Sdk"
    "$HOME/android-sdk"
    "/opt/android-sdk"
    "/usr/lib/android-sdk"
  )
  for CANDIDATE in "${CANDIDATES[@]}"; do
    if [[ -d "$CANDIDATE/platforms" ]]; then
      SDK_DIR="$CANDIDATE"
      break
    fi
  done
fi

# ── Auto-install SDK if not found ────────────────────────────
install_android_sdk() {
  local INSTALL_DIR="$HOME/Android/Sdk"
  local TOOLS_ZIP="/tmp/android-cmdline-tools.zip"
  local TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

  echo ""
  echo "📥  Installing Android command-line tools to: $INSTALL_DIR"
  echo ""

  # Check for required tools
  for cmd in curl unzip java; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "❌  '$cmd' is required but not installed. Please install it and retry."
      exit 1
    fi
  done

  # Download command-line tools
  echo "⬇️   Downloading SDK tools..."
  curl -fL --progress-bar "$TOOLS_URL" -o "$TOOLS_ZIP"

  # Extract into the proper structure (cmdline-tools/latest)
  echo "📦  Extracting..."
  mkdir -p "$INSTALL_DIR/cmdline-tools"
  unzip -q "$TOOLS_ZIP" -d "$INSTALL_DIR/cmdline-tools"
  # Google zips the folder as 'cmdline-tools', rename to 'latest'
  mv "$INSTALL_DIR/cmdline-tools/cmdline-tools" "$INSTALL_DIR/cmdline-tools/latest" 2>/dev/null || true
  rm -f "$TOOLS_ZIP"

  local SDKMANAGER="$INSTALL_DIR/cmdline-tools/latest/bin/sdkmanager"

  # Accept licenses and install required packages
  echo ""
  echo "✅  Accepting SDK licenses..."
  yes | "$SDKMANAGER" --licenses > /dev/null 2>&1 || true

  echo "📦  Installing platform-tools, Android 35, and build-tools 35..."
  "$SDKMANAGER" "platform-tools" "platforms;android-35" "build-tools;35.0.0"

  echo ""
  echo "✅  Android SDK installed at: $INSTALL_DIR"
  SDK_DIR="$INSTALL_DIR"

  # Persist to shell profile for future sessions
  local PROFILE="$HOME/.bashrc"
  if ! grep -q 'ANDROID_HOME' "$PROFILE" 2>/dev/null; then
    echo "" >> "$PROFILE"
    echo "# Android SDK" >> "$PROFILE"
    echo "export ANDROID_HOME=\"$INSTALL_DIR\"" >> "$PROFILE"
    echo "export PATH=\"\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools\"" >> "$PROFILE"
    echo "   ℹ️   Added ANDROID_HOME to $PROFILE — run 'source ~/.bashrc' after this build."
  fi
}

if [[ -z "$SDK_DIR" ]]; then
  echo ""
  echo "⚠️   Android SDK not found."
  echo ""
  echo "   Would you like to automatically install the Android command-line tools"
  echo "   (~1 GB download) to ~/Android/Sdk? [y/N]"
  read -r -p "   > " ANSWER

  if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
    install_android_sdk
  else
    echo ""
    echo "   Skipping auto-install. You can set up the SDK manually:"
    echo "   a) Install Android Studio: https://developer.android.com/studio"
    echo "   b) Or set: export ANDROID_HOME=/path/to/android-sdk"
    echo ""
    exit 1
  fi
fi

echo "✅  Android SDK found at: $SDK_DIR"

# Write / update local.properties
echo "sdk.dir=$SDK_DIR" > "$LOCAL_PROPS"
echo "✅  Written to local.properties"
echo ""

# ── Step 2: Copy web assets ───────────────────────────────────
echo "📂  Copying web assets to Android wrapper..."
cp -r "$SCRIPT_DIR"/*.html \
       "$SCRIPT_DIR"/*.js \
       "$SCRIPT_DIR"/*.json \
       "$SCRIPT_DIR"/*.png \
       "$SCRIPT_DIR"/*.xml \
       "$WWW_DIR/"
echo "✅  Assets copied to: $WWW_DIR"
echo ""

# ── Step 3: Capacitor sync ────────────────────────────────────
echo "🔄  Running Capacitor sync..."
cd "$ANDROID_APP_DIR"
npx cap sync android
echo "✅  Capacitor sync complete."
echo ""

# ── Step 4: Build APK via Gradle ─────────────────────────────
echo "⚙️   Building $BUILD_TYPE APK with Gradle..."
cd "$ANDROID_DIR"

if [[ "$BUILD_TYPE" == "release" ]]; then
  ./gradlew assembleRelease
  APK_PATH="$ANDROID_DIR/app/build/outputs/apk/release/app-release-unsigned.apk"
else
  ./gradlew assembleDebug
  APK_PATH="$ANDROID_DIR/app/build/outputs/apk/debug/app-debug.apk"
fi

echo ""
echo "======================================================="
echo "  🎉  Build complete!"
echo "  📦  APK location:"
echo "      $APK_PATH"
echo "======================================================="
