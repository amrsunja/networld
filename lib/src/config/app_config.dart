class AppConfig {
	String appName = '';
	bool isDebug;

	static const String appVersion = '1.0.0';

	AppConfig(
		this.appName, {
		required this.isDebug,
	});

  factory AppConfig.create({
    String appName = 'Kitaba dev',
    bool isDebug = false,
  }) => shared = AppConfig(
		appName,
		isDebug: isDebug,
	);

	static AppConfig shared = AppConfig.create();
}
