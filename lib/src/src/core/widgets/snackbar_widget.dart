import 'package:flutter/material.dart';

import '../design_system/app_ui.dart';

class AppSnackbarWidget extends SnackBar {
	AppSnackbarWidget.sucess(
		String message, {
		super.key,
		}) : super(
		content: UIAlert.success(label: message),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);

	AppSnackbarWidget.info(
		String message, {
		super.key,
		}) : super(
		content: UIAlert.info(label: message),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);

	AppSnackbarWidget.error(
		String message, {
		super.key,
	}) : super(
		content: UIAlert.error(label: message),
		elevation: 0,
		behavior: SnackBarBehavior.floating,
		backgroundColor: Colors.transparent
	);
}
