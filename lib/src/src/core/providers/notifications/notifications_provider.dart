import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../notifications/notifications_services.dart';

final notificationsServicesProvider = Provider(
	(ref) => NotificationsServices()
);
