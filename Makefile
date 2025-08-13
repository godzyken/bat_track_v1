.PHONY: all install_flutter restore_config doctor

all: install_flutter restore_config doctor

# Version Flutter
FLUTTER_VERSION = 3.29.3
INSTALL_DIR = $(HOME)/flutter
OS_NAME := $(shell uname -s | tr A-Z a-z)

# Chemin vers Flutter
export FLUTTER_ROOT = $(INSTALL_DIR)
export PATH := $(FLUTTER_ROOT)/bin:$(PATH)

install_flutter:
	@echo "🚀 Installation de Flutter avec Chocolatey..."
	@choco install flutter -y --force
ifeq ($(OS_NAME),linux)
	@echo "📦 Installation de Flutter $(FLUTTER_VERSION) pour Linux..."
	wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$(FLUTTER_VERSION)-stable.tar.xz -O flutter.tar.xz
	tar xf flutter.tar.xz
	rm flutter.tar.xz
	mv flutter $(INSTALL_DIR)
endif
ifeq ($(OS_NAME),darwin)
	@echo "📦 Installation de Flutter $(FLUTTER_VERSION) pour macOS..."
	curl -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_$(FLUTTER_VERSION)-stable.zip
	unzip flutter.zip
	rm flutter.zip
	mv flutter $(INSTALL_DIR)
endif
ifeq ($(findstring mingw,$(OS_NAME)),mingw)
	@echo "📦 Installation de Flutter $(FLUTTER_VERSION) pour Windows..."
	powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$(FLUTTER_VERSION)-stable.zip' -OutFile 'flutter.zip'"
	powershell -Command "Expand-Archive flutter.zip -DestinationPath $(HOME)"
	rm flutter.zip
endif

restore_config:
	@echo "♻️ Restauration de la configuration Flutter..."
	@powershell -ExecutionPolicy Bypass -File restore_flutter_env.ps1

doctor:
	@echo "🩺 Vérification de l'installation avec flutter doctor..."
	@flutter doctor -v

# Vérification installation
check-flutter:
	@which flutter || (echo "⚠️ Flutter non trouvé, exécutez 'make install-flutter'"; exit 1)
	flutter doctor

# Analyse du code
analyze: check-flutter
	flutter analyze

# Exemple de cible CI pour Jules
ci: install-flutter analyze
