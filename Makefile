# Variables
DEV_FLAGS = --target lib/main.dart #--flavor development
STG_FLAGS = --target lib/main.dart #--flavor staging
PROD_FLAGS = --target lib/main.dart #--flavor production

APPSTORE_KEY = your_key
APPSTORE_ISSUER = your_appstore_issuer

ANDROID_FLAGS = --no-tree-shake-icons --release
WEB_FLAGS = -d chrome --web-renderer html
XC_FLAGS = --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey $(APPSTORE_KEY) --apiIssuer $(APPSTORE_ISSUER)

RUN = flutter run
BUILD = flutter build
XCRUN = xcrun altool

# Map environment flags
define get-flags
$(if $(filter $(ENV),dev),$(DEV_FLAGS),\
$(if $(filter $(ENV),stg),$(STG_FLAGS),\
$(if $(filter $(ENV),prod),$(PROD_FLAGS),)))
endef

# Default Goal
.DEFAULT_GOAL := help

# Phony Targets
.PHONY: help run-app build-web build-apk build-bundle build-ios upload_to_appstore gen-code gen-appicon gen-splashscreen format lint init-app

# Run app for environment
run-app:
	@echo "Running app on $(ENV)..."
	$(RUN) $(call get-flags)

# Build APK for environment
build-apk:
	@echo "Building APK for $(ENV)..."
	$(BUILD) apk $(call get-flags) $(ANDROID_FLAGS)

# Build app bundle for environment
build-bundle:
	@echo "Building app bundle for $(ENV)..."
	$(BUILD) appbundle $(call get-flags) $(ANDROID_FLAGS)

# Build web app for environment
build-web:
	@echo "Building WEB app for $(ENV)..."
	$(BUILD) web $(call get-flags) $(WEB_FLAGS)

# Build iOS app
build-ios:
	@echo "Building iOS app for $(ENV)..."
	$(BUILD) ipa $(call get-flags)
	$(XCRUN) $(XC_FLAGS)

# Upload to App Store
upload_to_appstore:
	$(XCRUN) $(XC_FLAGS)

# Code Generation
gen-code:
	@echo "Generating code..."
	@flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate app icon
gen-appicon:
	@flutter clean
	@flutter pub get
	@flutter pub run icons_launcher:create --path ./app_icon_config.yaml 

rename-app:
	@dart run package_rename --path="./app_rename_config.yaml"

# Generate splashscreen
gen-splashscreen:
	@flutter clean
	@flutter pub get
	@flutter pub run flutter_native_splash:create --path=./app_splash_config.yaml

# Initialize app
init-app:
	@flutter clean
	@flutter pub get
	@cd ios && pod install && cd ..
	@flutter packages pub run build_runner build --delete-conflicting-outputs

# Format code
format:
	@dart format .

# Lint code
lint:
	@dart analyze .

# Help dialog
help:
	@echo "Available Commands:"
	@echo "  make run-app ENV=dev          Run app on dev environment"
	@echo "  make build-apk ENV=stg        Build APK for staging"
	@echo "  make build-bundle ENV=prod    Build app bundle for production"
	@echo "  make build-web ENV=prod       Build web app for production"
	@echo "  make build-ios ENV=prod       Build iOS app for production"
	@echo "  make upload_to_appstore       Upload iOS app to App Store"
	@echo "  make gen-code                 Generate code"
	@echo "  make gen-appicon              Generate app icon"
	@echo "  make gen-splashscreen         Generate splashscreen"
	@echo "  make format                   Format code"
	@echo "  make lint                     Verify code"
