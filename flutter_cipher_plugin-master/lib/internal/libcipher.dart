import 'dart:ffi' as ffi;
import 'dart:io' as io;

import 'package:ffi/ffi.dart';

final ffi.DynamicLibrary dylib =
    io.Platform.isAndroid ? ffi.DynamicLibrary.open("libcipher.so") : ffi.DynamicLibrary.executable();

// extern char* NativeEncrypt(char* plaintext, char* key);
typedef _NativeEncrypt = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

final _NativeEncrypt _nativeEncrypt = dylib.lookup<ffi.NativeFunction<_NativeEncrypt>>('NativeEncrypt').asFunction();

String encrypt({required String plaintext, required String key}) =>
    _nativeEncrypt(plaintext.toNativeUtf8(), key.toNativeUtf8()).toDartString();

// extern char* NativeDecrypt(char* ciphertext, char* key);
typedef _NativeDecrypt = ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

final _NativeDecrypt _nativeDecrypt = dylib.lookup<ffi.NativeFunction<_NativeDecrypt>>('NativeDecrypt').asFunction();

String decrypt({required String ciphertext, required String key}) =>
    _nativeDecrypt(ciphertext.toNativeUtf8(), key.toNativeUtf8()).toDartString();
