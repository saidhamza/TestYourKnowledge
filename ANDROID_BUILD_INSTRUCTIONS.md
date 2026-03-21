# Android Build Instructions

This document explains how the native Android wrapper for the "TestYourKnowledge" game is set up and how to update it when changes are made to the game's core web files.

## Project Structure and Security Check
The native Android project is set up inside a hidden folder: `.android-app/` location. 

Based on the server's Nginx configuration (`/etc/nginx/sites-available/nikforge`), access to any folder or file that starts with a dot `.` is explicitly rejected:
```nginx
# Security: Deny access to hidden files
location ~ /\. {
    deny all;
}
```
Thus, the actual Android build environment remains **completely inaccessible from the web**.

## How to Work With the Android Project

The Android app acts as a cross-compiled Capacitor WebView wrapper. 

### 1. Opening the Project
If you intend to manually test the app, or compile the raw APK/AAB builds for publication, you can open the target project directory within Android Studio:
```bash
/var/www/TestYourKnowledge/.android-app/android
```

### 2. Pushing Web Updates to Android
Whenever you modify your core HTML, JS, or image files within `/var/www/TestYourKnowledge/`, you will need to push those new changes to the Android native app for compiling before issuing a new release.

Use the following commands from your game's root directory:
```bash
# Navigate to the hidden Android wrapper directory
cd /var/www/TestYourKnowledge/.android-app

# Copy all the updated web assets into the capacitor 'www' web directory
cp -r ../*.html ../*.js ../*.json ../*.png ../*.xml www/

# Sync those files to the Android native project natively
npx cap sync android
```

These steps ensure that your latest changes are always appropriately synchronized into the bundled APK during compilation.
