import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class DailyRouterPage extends StatelessWidget {
	const DailyRouterPage({super.key});

	@override
	Widget build(BuildContext context) {
		return const AutoRouter();
	}
}
