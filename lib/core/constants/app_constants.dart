class AppConstants {
  static const String appName = 'PairLove';
  static const String appVersion = '1.0.0';

  static const int pinLength = 4;
  static const int maxPinLength = 6;
  static const int maxMessageLength = 5000;
  static const int maxImageSize = 10 * 1024 * 1024;
  static const int maxVideoSize = 100 * 1024 * 1024;

  static const int messageTimeout = 30;
  static const int callTimeout = 60;

  static const String encryptionKey = 'PairLove2024SecureKey32Chars!';
  static const String ivKey = 'PairLove16Char';

  static const List<String> chatBackgrounds = [
    'default_dark',
    'default_light',
    'hearts',
    'stars',
    'gradient_pink',
    'gradient_purple',
    'gradient_blue',
  ];

  static const List<String> quickReactions = [
    '❤️',
    '😂',
    '😢',
    '😡',
    '🔥',
    '👍',
    '👋',
    '💯',
  ];
}

class ApiConstants {
  static const String baseUrl = 'https://api.pairlove.app';
  static const String socketUrl = 'https://socket.pairlove.app';
  static const String webrtcServer = 'https://signal.pairlove.app';
}

class StorageKeys {
  static const String pin = 'user_pin';
  static const String userId = 'user_id';
  static const String partnerId = 'partner_id';
  static const String userData = 'user_data';
  static const String chatBackground = 'chat_background';
  static const String theme = 'app_theme';
  static const String firstLaunch = 'first_launch';
  static const String encryptionKey = 'encryption_key';
}