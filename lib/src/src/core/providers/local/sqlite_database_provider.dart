import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../local/database/sqlite/sqlite_services.dart';
import 'secure_storage_provider.dart';

final sqliteDataBaseProvider = Provider<SQLiteServices>(
	(ref) => SQLiteServicesImpl(
    secureStorage: ref.read(secureStorageServicesProvider)
  )
);
