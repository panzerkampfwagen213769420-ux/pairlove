import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../constants/app_constants.dart';

class EncryptionService {
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  EncryptionService() {
    final keyString = AppConstants.encryptionKey;
    _key = encrypt.Key.fromUtf8(keyString);
    _iv = encrypt.IV.fromUtf8(AppConstants.ivKey);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
  }

  String encryptText(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptText(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return encryptedText;
    }
  }

  String encryptJson(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encryptText(jsonString);
  }

  Map<String, dynamic>? decryptJson(String encryptedData) {
    try {
      final decrypted = decryptText(encryptedData);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPin(String inputPin, String storedHash) {
    return hashPin(inputPin) == storedHash;
  }

  String generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return '${timestamp}_$random';
  }

  Uint8List generateKeyFromPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }
}