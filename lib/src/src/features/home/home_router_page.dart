import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class HomeRouterPage extends StatelessWidget {
	const HomeRouterPage({super.key});

	@override
	Widget build(BuildContext context) {
		return HeroControllerScope(
			controller: HeroController(),
			child: const AutoRouter()
		);
	}
}
