# Configuration MCP Dart/Flutter

Le fichier `dart-flutter-mcp.json` contient la configuration officielle du serveur MCP Dart/Flutter
(`dart mcp-server`), au format générique attendu par la plupart des clients compatibles MCP.

## ⚠️ Ne pas copier aveuglément dans Android Studio

Gemini dans Android Studio possède sa propre interface de gestion des serveurs MCP
(Settings → Gemini → Agent Mode / MCP). Il ne faut donc pas déposer ce JSON tel quel dans un
fichier de config générique en espérant qu'Android Studio le lise automatiquement.

Étapes recommandées dans Android Studio :

1. `Settings` → section Gemini / Agent Mode
2. Ajouter un serveur MCP
3. Renseigner :
   - Command: `dart`
   - Args: `mcp-server`

Ce fichier `dart-flutter-mcp.json` reste utile comme référence, et pour tout autre client MCP
(VS Code, Claude Code, etc.) qui accepte directement ce format `mcpServers`.
