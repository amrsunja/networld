import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../local/database/secure_storage/secure_storage_services.dart';

final secureStorageServicesProvider = Provider<SecureStorageServices>(
	(ref) => SecureStorageServicesImpl()
);
