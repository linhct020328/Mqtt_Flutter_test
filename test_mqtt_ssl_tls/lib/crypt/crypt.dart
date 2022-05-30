import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flustars/flustars.dart';

var _KEY = "qwertyuiopasdfghjklzxcvbnm123456";
var _IV = "caothithuylinh99";

//Aes 128: keysize=16，192: keysize=24，256: keysize=32

class crypt {
  //Base64 ENCODE
  static String encodeBase64(String data) {
    return base64Encode(utf8.encode(data));
  }

  //Base64 DECODE
  static String decodeBase64(String data) {
    return String.fromCharCodes(base64Decode(data));
  }

  // md5 ENCODE 32
  static String encodeMd5(String plainText) {
    return EncryptUtil.encodeMd5(plainText);
  }

  //AES ENCODE
  static aesEncrypt(plainText) {
    try {
      final key = Key.fromUtf8(_KEY);
      final iv = IV.fromUtf8(_IV);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (err) {
      print("aes encode error:$err");
      return plainText;
    }
  }

  //AES DECODE
  static dynamic aesDecrypt(encrypted) {
    try {
      final key = Key.fromUtf8(_KEY);
      final iv = IV.fromUtf8(_IV);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
      return decrypted;
    } catch (err) {
      print("aes decode error:$err");
      return encrypted;
    }
  }

//  //aes加密
//  static aesEncode(String plainText) {
//    try {
//      final key = Key.fromBase64(base64Encode(utf8.encode(_KEY)));
//      final iv = IV.fromBase64(base64Encode(utf8.encode(_IV)));
//      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
//      final encrypted = encrypter.encrypt(plainText, iv: iv);
//      return encrypted.base64;
//    } catch (err) {
//      print("aes encode error:$err");
//      return plainText;
//    }
//  }
//
//  //aes解密
//  static aesDecode(dynamic encrypted) {
//    try {
//      final key = Key.fromBase64(base64Encode(utf8.encode(_KEY)));
//      final iv = IV.fromBase64(base64Encode(utf8.encode(_IV)));
//      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
//      final decrypted = encrypter.decrypt64(encrypted, iv: iv);
//      return decrypted;
//    } catch (err) {
//      print("aes decode error:$err");
//      return encrypted;
//    }
//  }
}