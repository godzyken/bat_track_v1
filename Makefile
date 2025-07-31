.PHONY: all install_flutter restore_config doctor

all: install_flutter restore_config doctor

install_flutter:
	@echo "🚀 Installation de Flutter avec Chocolatey..."
	@choco install flutter -y --force

restore_config:
	@echo "♻️ Restauration de la configuration Flutter..."
	@powershell -ExecutionPolicy Bypass -File restore_flutter_env.ps1

doctor:
	@echo "🩺 Vérification de l'installation avec flutter doctor..."
	@flutter doctor -v
