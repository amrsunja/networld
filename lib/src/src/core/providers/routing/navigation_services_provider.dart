import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../routing/app_router.dart';
import '../../routing/navigation_services.dart';


final navigationServicesProvider = Provider((ref) => NavigationServicesImpl(
	router: AppRouter(ref)
));
