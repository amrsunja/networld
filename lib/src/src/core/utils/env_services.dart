import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvServices {
	static String supabaseUrl = _getBaseUrl(envKey: 'SUPABASE_URL');
	static String supabaseKey = _getBaseUrl(envKey: 'SUPABASE_KEY');

	static String googleAuthWebClientId = _getBaseUrl(envKey: 'GOOGLE_AUTH_WEB_CLIENT_ID');
	static String googleAuthIOSClientId = _getBaseUrl(envKey: 'GOOGLE_AUTH_IOS_CLIENT_ID');
	static String googleAuthAndroidClientId = _getBaseUrl(envKey: 'GOOGLE_AUTH_ANDROID_CLIENT_ID');

	static const String _errorValue = 'error-value';


	static String _getBaseUrl({required String envKey}) {
		return dotenv.env[envKey] ?? _errorValue;
	}
}
