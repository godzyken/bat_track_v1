#!/bin/bash

# 🔍 Script de diagnostic Firebase pour Flutter
# Usage: bash check_firebase.sh

echo "🔬 DIAGNOSTIC FIREBASE POUR FLUTTER"
echo "===================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de vérification
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

# 1. Vérifier Flutter
echo "1️⃣ Vérification Flutter..."
flutter --version > /dev/null 2>&1
check "Flutter installé"
echo ""

# 2. Vérifier les packages Firebase dans pubspec.yaml
echo "2️⃣ Vérification packages Firebase..."
if [ -f "pubspec.yaml" ]; then
    echo -e "${GREEN}✅ pubspec.yaml trouvé${NC}"
    echo "   Packages Firebase détectés:"
    grep "firebase" pubspec.yaml | grep -v "#"
else
    echo -e "${RED}❌ pubspec.yaml non trouvé${NC}"
fi
echo ""

# 3. Vérifier firebase_options.dart
echo "3️⃣ Vérification firebase_options.dart..."
if [ -f "lib/firebase_options.dart" ]; then
    echo -e "${GREEN}✅ firebase_options.dart trouvé${NC}"
    echo "   Configuration détectée:"
    grep "projectId" lib/firebase_options.dart | head -1
else
    echo -e "${RED}❌ firebase_options.dart non trouvé${NC}"
    echo -e "${YELLOW}💡 Exécutez: flutterfire configure${NC}"
fi
echo ""

# 4. Vérifier google-services.json (Android)
echo "4️⃣ Vérification google-services.json (Android)..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ google-services.json trouvé${NC}"
    echo "   Project ID:"
    grep "project_id" android/app/google-services.json | head -1
else
    echo -e "${RED}❌ google-services.json non trouvé${NC}"
    echo -e "${YELLOW}💡 Téléchargez depuis Firebase Console > Project Settings${NC}"
fi
echo ""

# 5. Vérifier GoogleService-Info.plist (iOS)
echo "5️⃣ Vérification GoogleService-Info.plist (iOS)..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${GREEN}✅ GoogleService-Info.plist trouvé${NC}"
else
    echo -e "${YELLOW}⚠️ GoogleService-Info.plist non trouvé (OK si vous ne ciblez pas iOS)${NC}"
fi
echo ""

# 6. Vérifier build.gradle (Android)
echo "6️⃣ Vérification configuration Android..."
if [ -f "android/app/build.gradle.kts" ]; then
    echo -e "${GREEN}✅ build.gradle.kts trouvé${NC}"

    if grep -q "com.google.gms.google-services" android/app/build.gradle.kts; then
        echo -e "${GREEN}✅ Plugin google-services détecté${NC}"
    else
        echo -e "${RED}❌ Plugin google-services non détecté${NC}"
        echo -e "${YELLOW}💡 Ajoutez: id(\"com.google.gms.google-services\")${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Fichier Kotlin DSL non trouvé, vérification build.gradle...${NC}"
    if [ -f "android/app/build.gradle" ]; then
        echo -e "${GREEN}✅ build.gradle trouvé${NC}"
        if grep -q "com.google.gms.google-services" android/app/build.gradle; then
            echo -e "${GREEN}✅ Plugin google-services détecté${NC}"
        else
            echo -e "${RED}❌ Plugin google-services non détecté${NC}"
        fi
    fi
fi
echo ""

# 7. Vérifier que Firebase est initialisé dans main.dart
echo "7️⃣ Vérification initialisation dans main.dart..."
if [ -f "lib/main.dart" ]; then
    if grep -q "Firebase.initializeApp" lib/main.dart; then
        echo -e "${GREEN}✅ Firebase.initializeApp() détecté${NC}"
    else
        echo -e "${RED}❌ Firebase.initializeApp() non détecté${NC}"
        echo -e "${YELLOW}💡 Ajoutez dans main():${NC}"
        echo "   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);"
    fi
else
    echo -e "${RED}❌ lib/main.dart non trouvé${NC}"
fi
echo ""

# 8. Vérifier les versions
echo "8️⃣ Versions des packages Firebase..."
if [ -f "pubspec.lock" ]; then
    echo "   firebase_core:"
    grep -A 2 "firebase_core:" pubspec.lock | grep "version:"
    echo "   firebase_auth:"
    grep -A 2 "firebase_auth:" pubspec.lock | grep "version:"
    echo "   cloud_firestore:"
    grep -A 2 "cloud_firestore:" pubspec.lock | grep "version:"
else
    echo -e "${YELLOW}⚠️ pubspec.lock non trouvé${NC}"
fi
echo ""

# 9. Résumé et recommandations
echo "📊 RÉSUMÉ"
echo "=========="
echo ""
echo "Si tous les tests sont verts ✅, votre configuration Firebase est correcte."
echo ""
echo "Actions recommandées si des tests sont rouges ❌:"
echo ""
echo "1. Configurer Firebase:"
echo "   flutterfire configure"
echo ""
echo "2. Nettoyer le projet:"
echo "   flutter clean"
echo "   flutter pub get"
echo ""
echo "3. Rebuilder:"
echo "   flutter run"
echo ""
echo "4. Tester avec le FirebaseDebugScreen (voir firebase_debug_screen.dart)"
echo ""
echo "5. Vérifier Firebase Console:"
echo "   - Authentication > Sign-in method > Email/Password activé"
echo "   - Authentication > Users > Créer un utilisateur test"
echo ""
echo "🔗 Documentation:"
echo "   https://firebase.flutter.dev/docs/overview"
echo ""
