#!/usr/bin/env bash
set -e

# 📌 Paramètres
FLUTTER_VERSION="3.19.0"
CACHE_DIR="$HOME/.flutter_cache"   # Cache partagé Jules / CI
INSTALL_DIR="/tmp/flutter_sdk"

# 🗑 Nettoyage ancien répertoire temporaire
rm -rf "$INSTALL_DIR"

# 📦 Utiliser le cache si disponible
if [ -d "$CACHE_DIR/flutter" ]; then
    echo "✅ Using cached Flutter from $CACHE_DIR"
    cp -r "$CACHE_DIR" "$INSTALL_DIR"
else
    echo "⬇️ Downloading Flutter $FLUTTER_VERSION..."
    mkdir -p "$INSTALL_DIR"
    curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/$(uname | tr '[:upper:]' '[:lower:]')/flutter_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz
    tar xf flutter.tar.xz -C "$INSTALL_DIR"
    rm flutter.tar.xz

    # Sauvegarder dans le cache
    mkdir -p "$CACHE_DIR"
    cp -r "$INSTALL_DIR" "$CACHE_DIR"
fi

# ➕ Ajouter Flutter au PATH
export FLUTTER_ROOT="$INSTALL_DIR/flutter"
export PATH="$FLUTTER_ROOT/bin:$PATH"

# 📢 Vérifier installation
flutter --version
