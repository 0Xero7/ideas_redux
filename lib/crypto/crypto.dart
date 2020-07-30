
import 'package:encrypt/encrypt.dart';

String encryptAES(String data, String _key, String _iv) {
  final key = Key.fromUtf8(_key);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  IV iv = IV.fromUtf8(_iv);

  final encrypted = encrypter.encrypt(data, iv: iv);
  return encrypted.base64;
}

String decryptAES(String data, String _key, String _iv) {
  print(_key);
  print(_iv);

  final key = Key.fromUtf8(_key);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  IV iv = IV.fromUtf8(_iv);

  final decrypted = encrypter.decrypt64(data, iv: iv);
  return decrypted;
}