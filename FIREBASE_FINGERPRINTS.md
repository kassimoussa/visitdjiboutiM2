# 🔐 Empreintes de certificat pour Firebase - Visit Djibouti

## ✅ Empreintes obtenues

### Debug Keystore (pour développement)

**Emplacement:** `~/.android/debug.keystore`
**Alias:** `androiddebugkey`
**Date de création:** 11 juin 2025

#### SHA-256 (Obtenu)
```
C6:98:3C:D2:0A:76:A5:C2:90:A0:10:65:C0:43:A8:81:A8:D8:50:75:0B:14:7B:5F:6B:46:79:27:4F:EC:D8:2B
```

#### SHA-1 (À obtenir)
Pour obtenir SHA-1, utilisez une des méthodes suivantes:

**Méthode 1 - Via Flutter:**
```bash
cd /Users/ctd-dsi-kassim/Desktop/flutter_projects/visitdjiboutiM2
flutter build apk --debug
# Puis vérifiez dans les logs de build
```

**Méthode 2 - Via Android Studio (Recommandé):**
1. Ouvrir le projet dans Android Studio
2. View > Tool Windows > Gradle
3. Tasks > android > signingReport
4. Copier SHA-1 depuis l'output

**Méthode 3 - Via keytool avec Java 8:**
Si vous avez Java 8, utilisez:
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

## 📋 Ajouter à Firebase Console

### Étapes à suivre:

1. **Aller sur Firebase Console:**
   ```
   https://console.firebase.google.com/project/visit-djibouti/settings/general
   ```

2. **Sélectionner l'application Android:**
   - Package name: `com.example.visitdjibouti`
   - App ID: `1:324752052195:android:a04501c3b04ef2f4cf1ad6`

3. **Cliquer sur "Add fingerprint"** (Ajouter une empreinte)

4. **Ajouter SHA-256:**
   ```
   C6:98:3C:D2:0A:76:A5:C2:90:A0:10:65:C0:43:A8:81:A8:D8:50:75:0B:14:7B:5F:6B:46:79:27:4F:EC:D8:2B
   ```

5. **Cliquer à nouveau sur "Add fingerprint"**

6. **Ajouter SHA-1** (une fois obtenu):
   ```
   [À COMPLÉTER APRÈS OBTENTION]
   ```

7. **Télécharger le nouveau `google-services.json`**

8. **Remplacer le fichier:**
   ```bash
   # Sauvegarder l'ancien
   mv android/app/google-services.json android/app/google-services.json.backup

   # Copier le nouveau depuis Downloads
   cp ~/Downloads/google-services.json android/app/google-services.json
   ```

9. **Clean et rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 🏗️ Pour la production (Release)

### Quand vous créerez le keystore de release:

```bash
# Générer le keystore (une seule fois)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Obtenir les empreintes
keytool -list -v -keystore ~/upload-keystore.jks \
  -alias upload
```

**Important:** Vous devrez aussi ajouter les empreintes SHA-1 et SHA-256 du keystore de release dans Firebase Console !

## ✅ Vérification

Après avoir ajouté les empreintes et mis à jour `google-services.json`:

```bash
# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Run
flutter run

# 4. Vérifier les logs Firebase
# Vous devriez voir:
# [FCM] Service FCM initialisé avec succès
# [FCM] Token obtenu: [VOTRE_TOKEN]
```

## 📝 Checklist

- [x] SHA-256 debug obtenu
- [ ] SHA-1 debug obtenu
- [ ] SHA-256 ajouté à Firebase Console
- [ ] SHA-1 ajouté à Firebase Console
- [ ] Nouveau google-services.json téléchargé
- [ ] Fichier remplacé dans android/app/
- [ ] flutter clean && flutter pub get exécuté
- [ ] App testée et FCM fonctionne

## 🔄 Prochaines étapes

1. **Obtenir SHA-1** via Android Studio (méthode recommandée)
2. **Ajouter SHA-256 et SHA-1** à Firebase Console
3. **Télécharger et remplacer** google-services.json
4. **Tester l'app** pour vérifier que tout fonctionne
5. **Tester une notification** depuis Firebase Console

## 💡 Aide supplémentaire

Pour plus de détails, consultez: **[GET_SHA_FINGERPRINTS.md](GET_SHA_FINGERPRINTS.md)**

## 🎯 Résumé ultra-rapide

```bash
# Obtenu:
SHA-256: C6:98:3C:D2:0A:76:A5:C2:90:A0:10:65:C0:43:A8:81:A8:D8:50:75:0B:14:7B:5F:6B:46:79:27:4F:EC:D8:2B

# À faire:
1. Obtenir SHA-1 via Android Studio
2. Ajouter les deux empreintes sur Firebase Console
3. Télécharger nouveau google-services.json
4. Remplacer android/app/google-services.json
5. flutter clean && flutter run
```
