class AppConfig {
	String appName = '';
	bool isDebug;
	String appVersion = '';
	String appBuildNumber = '';

	AppConfig(
		this.appName, {
		required this.isDebug,
		required this.appVersion,
		required this.appBuildNumber,
	});

  factory AppConfig.create({
    String appName = 'Kitaba dev',
    bool isDebug = false,
    String appVersion = '',
    String appBuildNumber = '',
  }) => shared = AppConfig(
		appName,
		isDebug: isDebug,
		appVersion: appVersion,
		appBuildNumber: appBuildNumber,
	);

	static AppConfig shared = AppConfig.create();
}
