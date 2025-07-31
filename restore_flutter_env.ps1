# restore_flutter_env.ps1
Write-Host "🛠️ Restauration de la configuration Flutter"

if (!(Get-Command flutter -ErrorAction SilentlyContinue))
{
    Write-Host "❌ Flutter n'est pas installé. Exécutez 'choco install flutter' d'abord."
    exit 1
}

flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --android-sdk "D:\AppData\SDK"
flutter config --android-studio-dir "C:\Program Files\Android\Android Studio"
flutter config --no-analytics
flutter config --enable-cli-animations
flutter config --enable-explicit-package-dependencies
flutter config --chrome-executable="C:\Program Files\Google\Chrome\Application\chrome.exe"

Write-Host "`n✅ Configuration Flutter restaurée."
