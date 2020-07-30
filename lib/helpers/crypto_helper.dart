import 'dart:math';

final String validStringChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";

String randomString(int len) {
  assert(len != null && len > 0);
  
  List<int> codes = List<int>(len);
  for (int i = 0; i < len; ++i) {
    int ptr = Random.secure().nextInt(validStringChars.length);
    codes[i] = validStringChars.codeUnitAt(ptr);
  }
  return String.fromCharCodes(codes);
}