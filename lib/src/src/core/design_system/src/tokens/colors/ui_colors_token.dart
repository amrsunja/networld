import 'package:flutter/material.dart';

class UIColorsToken {
	// DYNAMIC
	final Color bgColor;
	final Color fgColor;
	final Color contentColor;
	final Color secondContentColor;
	final Color disabledContentColor;
	final Color cardColor;
	final Color cardBorderColor;
	final Color pointsBadgeColor;
	final Color selectColor;

	const UIColorsToken({
		required this.bgColor,
		required this.fgColor,
		required this.contentColor,
		required this.secondContentColor,
		required this.disabledContentColor,
		required this.cardColor,
		required this.cardBorderColor,
		required this.pointsBadgeColor,
		required this.selectColor,
	});
	
	factory UIColorsToken.light() => UIColorsToken(
		bgColor: neu50,
		fgColor: white,
		contentColor: neu700,
		secondContentColor: neu400,
		disabledContentColor: neu300,
		cardColor: neu100,
		cardBorderColor: neu200,
    pointsBadgeColor: pri100,
    selectColor: pri500,
	);

	factory UIColorsToken.dark() => UIColorsToken(
		bgColor: black,
		fgColor: black,
		contentColor: white,
		secondContentColor: neu200,
		disabledContentColor: neu400,
		cardColor: neu600,
		cardBorderColor: neu500,
    pointsBadgeColor: pri500,
    selectColor: pri500,
	);

	// GENERAL
	static const Color white = Color(0xffFFFFFF);
	static const Color grey = Color(0xff9CA3AF);
	static const Color black = Color(0xff000000);
	static final Color overlay	= black.withValues(alpha: 0.65);
	static const Color blue = Color(0xff38BDF8);
	static const Color orange = Color(0xffFB923C);
	static const Color shadow = pri500;

	// PRIMARY (Gold / brand)
  static final Color pri550 = Color(0xffFFC107).withValues(alpha: 0.2);
  static const Color pri500 = Color(0xffFFC107);
  static const Color pri400 = Color(0xffFFCA28);
  static const Color pri350 = Color(0xffFFD700);
	static const Color pri300 = Color(0xffFFD54F);
	static const Color pri200 = Color(0xffFFE082);
	static const Color pri100 = Color(0xffFFECB3);
	static const Color pri50 = Color(0xffFFF8E1);

	// SECONDARY (Warm accents)
	//static const Color sec600 = Color(0xff);
	static const Color sec500 = Color(0xffF97316);
	static const Color sec400 = Color(0xffFDBA74);
	static const Color sec300 = Color(0xffFED7AA);
	static const Color sec200 = Color(0xffFFEDD5);
	static const Color sec100 = Color(0xffFFF7ED);
	static const Color sec50 = Color(0xffFFFDF9);

	// NEUTRAL (Dark surfaces / text)
  static const Color neu700 = Color(0xff020617); // app background
	static const Color neu600 = Color(0xff0B1120); // cards / modals
	static const Color neu500 = Color(0xff111827);
	static const Color neu400 = Color(0xff1F2937);
	static const Color neu300 = Color(0xff4B5563);
	static const Color neu200 = Color(0xff6B7280);
	static const Color neu100 = Color(0xff9CA3AF);
	static const Color neu50 = Color(0xffE5E7EB);

	// NEGATIVE (Errors / destructive)
	static const Color neg600 = Color(0xff991B1B);
	static const Color neg500 = Color(0xffDC2626);
	static const Color neg400 = Color(0xffF87171);
  static const Color neg300 = Color(0xffFCA5A5);
	static const Color neg200 = Color(0xffFECACA);
	static const Color neg100 = Color(0xffFEE2E2);

  // Aliases for compatibility
  static _ColorGroup get darkBlue => _ColorGroup(normal: neu700);
  static _ColorGroup get error => _ColorGroup(normal: neg500);


	// Positive (Success / growth)
	static const Color pos500 = Color(0xff16A34A);
	static const Color pos400 = Color(0xff22C55E);
	static const Color pos300 = Color(0xff4ADE80);
	static const Color pos200 = Color(0xffBBF7D0);
	static const Color pos100 = Color(0xffDCFCE7);

	// Onboarding (hero gradient + text)
	static const Color onboardingGradientStart = Color(0xff020617); // top: deep ink
	static const Color onboardingGradientEnd = Color(0xffFFC107); // bottom: gold glow
	static const Color onboardingTitle = Color(0xffFACC15); // bright gold text
	static const Color onboardingDescription = Color(0xff9CA3AF); // muted grey text
}

class _ColorGroup {
  const _ColorGroup({required this.normal});
  final Color normal;
}
