import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageServices {
  Future<String?> readData(String key);
  Future<void> writeData(String key, String? value);
}


class SecureStorageServicesImpl implements SecureStorageServices {
  final storage = const FlutterSecureStorage();

  @override
  Future<String?> readData(String key) async {
    return await storage.read(key: key, );
  }

  @override
  Future<void> writeData(String key, String? value) async {
    await storage.write(key: key, value: value);
  }
}
