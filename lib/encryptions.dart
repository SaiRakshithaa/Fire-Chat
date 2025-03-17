import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class EncryptionHelper {
  static final EncryptionHelper _instance = EncryptionHelper._internal();

  factory EncryptionHelper() {
    return _instance;
  }

  EncryptionHelper._internal();

  //final encrypt.Key _key = encrypt.Key.fromUtf8('my32charpassword12345678901234'); // 32-byte key
  final encrypt.Key _key = encrypt.Key.fromUtf8('12345678901234567890123456789012'); 

  String encryptMessage(String plainText) {
    final iv = encrypt.IV.fromLength(16); // Generate a fresh IV for each message
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Store IV with encrypted message (both are needed for decryption)
    print(encrypted);
    return jsonEncode({"iv": iv.base64, "message": encrypted.base64});
  }

  String decryptMessage(String encryptedText) {
    try {
      final jsonData = jsonDecode(encryptedText);
      final iv = encrypt.IV.fromBase64(jsonData["iv"]); // Extract IV
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

      return encrypter.decrypt64(jsonData["message"], iv: iv);
    } catch (e) {
      return "Decryption error: ${e.toString()}";
    }
  }
}
