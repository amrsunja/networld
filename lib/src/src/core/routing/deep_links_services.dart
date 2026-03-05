import 'dart:async';

import 'package:auto_route/auto_route.dart';

class DeepLinksServices {
	static String cleanedLink(String link) {
		return link.replaceAll(RegExp(r'#/'), '');
	}

	static FutureOr<DeepLink> navigateDeepLink(PlatformDeepLink deepLink) async {
		//final link = cleanedLink(deepLink.uri.toString());
		//final routePath = deepLink.path;
    //print(deepLink.matches);

    return deepLink;
	}
}
