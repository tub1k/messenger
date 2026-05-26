class Environment {
  // General
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  // Web / Windows
  static const String webApiKey = String.fromEnvironment('WEB_API_KEY');
  static const String webAppId = String.fromEnvironment('WEB_APP_ID');
  static const String webAuthDomain = String.fromEnvironment('WEB_AUTH_DOMAIN');
  static const String windowsAppId = String.fromEnvironment('WINDOWS_APP_ID');

  // Android
  static const String androidApiKey = String.fromEnvironment('ANDROID_API_KEY');
  static const String androidAppId = String.fromEnvironment('ANDROID_APP_ID');

  // iOS / macOS
  static const String iosApiKey = String.fromEnvironment('IOS_API_KEY');
  static const String iosAppId = String.fromEnvironment('IOS_APP_ID');
  static const String iosBundleId = String.fromEnvironment('IOS_BUNDLE_ID');
}