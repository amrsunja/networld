import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
	const TimerWidget({
		super.key,
		required this.duration,
		required this.builder,
		this.onEnd
	});

	final Duration duration; 
	final Widget Function(Duration value, int minutes, int seconds) builder;
	final Function()? onEnd;

	@override
	Widget build(BuildContext context) {
		return TweenAnimationBuilder<Duration>(
			tween: Tween(begin: duration, end: Duration.zero), 
			duration: duration,
			builder: (context, value, child) {
				final minutes = value.inMinutes;
				final seconds = value.inSeconds % 60;
				return builder(value, minutes, seconds);
			},
			onEnd: onEnd,
		);
	}
}
