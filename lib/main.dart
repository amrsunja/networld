import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:brokies/src/config/app_config.dart';
import 'package:brokies/src/config/app_runner.dart';
import 'package:brokies/src/src/core/utils/constants/constants.dart';
import 'package:brokies/src/src/core/utils/env_services.dart';
import 'package:brokies/src/src/core/utils/screen_rotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() {
	runZonedGuarded<Future<void>>(
		() async {
			WidgetsFlutterBinding.ensureInitialized();

			// init env
			await dotenv.load();

			// App configuration
			AppConfig.create(
				appName: kAppName,
        isDebug: false
			);

      await Supabase.initialize(
        url: EnvServices.supabaseUrl,
        anonKey: EnvServices.supabaseKey
      );

			// Init Firebase
  		//await Firebase.initializeApp();

  		//FlutterNativeSplash.remove();
      //FlutterError.onError = (errorDetails) {
        //FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      //};

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      //PlatformDispatcher.instance.onError = (error, stack) {
        //FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        //return true;
      //};

			// Lock screen rotation
			ScreenRotation.toPortrait();

  		AppRunner.runApplication();

		}, (error, stack) async {
			//await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
		}
	);
}
