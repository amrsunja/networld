import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/snackbar_widget.dart';
import 'scaffold_messenger_provider.dart';

final snackbarProvider = Provider(SnackbarProvider.new);

class SnackbarProvider {
	final Ref _ref;

	SnackbarProvider(Ref ref) : _ref = ref;

	void _showSnackbar(AppSnackbarWidget child) {
		_ref.read(scaffoldMessengerProvider).currentState!
				..removeCurrentSnackBar()
				..showSnackBar(
					child,
					snackBarAnimationStyle: AnimationStyle(
						curve: Curves.fastOutSlowIn,
						reverseCurve: Curves.easeOut,
						duration: Durations.long4
					)
				);
	}

	void showSuccess(String message) => _showSnackbar(AppSnackbarWidget.sucess(message));

	void showInfo(String message) => _showSnackbar(AppSnackbarWidget.info(message));

	void showError(String message) => _showSnackbar(AppSnackbarWidget.error(message));
}
