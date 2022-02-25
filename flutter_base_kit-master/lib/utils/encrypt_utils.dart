import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncryptUtils {
  EncryptUtils._();

  /// MD5
  static String encryptMD5(String data, [String? salt]) {
    var content = const Utf8Encoder().convert(salt == null ? data : '$data$salt');
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  /// Base64加密
  static String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  /// Base64解密
  static String decodeBase64(String data) {
    List<int> bytes = base64Decode(data);
    String result = utf8.decode(bytes);
    return result;
  }

  /// HMAC-SHA256
  static String encryptHmacSHA256(String data, String key) {
    var hmacSha256 = Hmac(sha256, utf8.encode(key));
    var digest = hmacSha256.convert(utf8.encode(data));
    return hex.encode(digest.bytes);
  }

  // // DES
  // static Encrypted encryptDES(String data, String key, String iv,
  //     {AESMode mode = AESMode.sic, String padding = 'PKCS7'}) {
  //   final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: mode, padding: padding));
  //   final encrypted = encrypter.encrypt(data, iv: IV.fromUtf8(iv));
  //   return encrypted;
  // }

  // static String decryptDES(String data, String key, String iv, {AESMode mode = AESMode.sic, String padding = 'PKCS7'}) {
  //   final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: mode, padding: padding));
  //   final decrypted = encrypter.decrypt(Encrypted.fromUtf8(data), iv: IV.fromUtf8(iv));
  //   return decrypted;
  // }

  /// aes 加密
  ///
  /// 返回 String(base64)
  static String aesEncrypt(String data, String key, {AESMode mode = AESMode.ecb, String padding = 'PKCS7', IV? iv}) {
    final _key = Key.fromUtf8(key);
    final encrypter = Encrypter(AES(_key, mode: mode, padding: padding));
    return encrypter.encrypt(data, iv: iv ?? IV.fromLength(16)).base64;
  }

  /// aes 解密
  static String aesDecrypt(String base64Data, String key,
      {AESMode mode = AESMode.ecb, String padding = 'PKCS7', IV? iv}) {
    final _key = Key.fromUtf8(key);
    final encrypter = Encrypter(AES(_key, mode: mode, padding: padding));
    return encrypter.decrypt(Encrypted.from64(base64Data), iv: iv ?? IV.fromLength(16));
  }

  /// rsa 加密
  static String rsaEncrypt(String data,
      {String? publicKey, String? privateKey, RSAEncoding encoding = RSAEncoding.PKCS1, IV? iv}) {
    final RSAPublicKey? rsaPublicKey = publicKey != null ? RSAKeyParser().parse(publicKey) as RSAPublicKey : null;
    final RSAPrivateKey? rsaPrivateKey = privateKey != null ? RSAKeyParser().parse(privateKey) as RSAPrivateKey : null;
    final encrypter = Encrypter(RSA(publicKey: rsaPublicKey, privateKey: rsaPrivateKey, encoding: encoding));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  /// rsa 解密
  static String rsaDecrypt(String base64Data,
      {String? publicKey, String? privateKey, RSAEncoding encoding = RSAEncoding.PKCS1, IV? iv}) {
    final RSAPublicKey? rsaPublicKey = publicKey != null ? RSAKeyParser().parse(publicKey) as RSAPublicKey : null;
    final RSAPrivateKey? rsaPrivateKey = privateKey != null ? RSAKeyParser().parse(privateKey) as RSAPrivateKey : null;
    final encrypter = Encrypter(RSA(publicKey: rsaPublicKey, privateKey: rsaPrivateKey, encoding: encoding));
    return encrypter.decrypt(Encrypted.from64(base64Data), iv: iv);
  }
}
