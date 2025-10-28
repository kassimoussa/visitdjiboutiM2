# Obtenir les empreintes SHA-1 et SHA-256 pour Firebase

## 🎯 Pourquoi les empreintes sont-elles nécessaires ?

Les empreintes de certificat (SHA-1 et SHA-256) sont requises par Firebase pour:
- **Firebase Authentication** (Google Sign-In, Phone Auth, etc.)
- **Firebase Cloud Messaging** (FCM) - Pour certaines fonctionnalités avancées
- **Dynamic Links**
- **App Check**

## 📱 Méthode 1: Via Android Studio (Recommandé)

### Étapes:

1. **Ouvrez le projet Android dans Android Studio:**
   ```bash
   open -a "Android Studio" /Users/ctd-dsi-kassim/Desktop/flutter_projects/visitdjiboutiM2/android
   ```

2. **Ouvrez le terminal Gradle** (View > Tool Windows > Gradle)

3. **Exécutez la tâche signingReport:**
   - Dans l'arbre Gradle: `visitdjibouti > Tasks > android > signingReport`
   - Double-cliquez sur `signingReport`

4. **Copiez les empreintes** affichées dans l'onglet "Run":
   ```
   Variant: debug
   Config: debug
   Store: ~/.android/debug.keystore
   Alias: androiddebugkey
   MD5: XX:XX:XX:...
   SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
   SHA-256: 11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF
   ```

## 🖥️ Méthode 2: Via Terminal (Alternative)

### Pour le keystore de debug:

```bash
# Méthode simple - Obtenir SHA-1 et SHA-256
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA
```

### Si la commande ci-dessus ne fonctionne pas, essayez:

```bash
# Version complète
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

### Ensuite cherchez dans l'output:
```
Certificate fingerprints:
         SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
         SHA256: 11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF
```

## 🔐 Méthode 3: Via Flutter/Gradle

```bash
cd /Users/ctd-dsi-kassim/Desktop/flutter_projects/visitdjiboutiM2/android
./gradlew signingReport
```

Cherchez la section `Variant: debug` dans l'output.

## 📋 Ajouter les empreintes à Firebase Console

### Étapes:

1. **Allez sur Firebase Console:**
   - URL: https://console.firebase.google.com/project/visit-djibouti/settings/general

2. **Sélectionnez votre application Android:**
   - App ID: `1:324752052195:android:a04501c3b04ef2f4cf1ad6`
   - Package: `com.example.visitdjibouti`

3. **Cliquez sur "Add fingerprint"**

4. **Collez votre SHA-1:**
   ```
   AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
   ```

5. **Cliquez à nouveau sur "Add fingerprint"**

6. **Collez votre SHA-256:**
   ```
   11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF
   ```

7. **Téléchargez le nouveau `google-services.json`** et remplacez l'ancien dans:
   ```
   android/app/google-services.json
   ```

## 🏗️ Empreintes pour Release Build (Production)

### Quand vous créez un keystore de production:

```bash
# Générer un keystore de release (si pas déjà fait)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Obtenir les empreintes du keystore de release
keytool -list -v -keystore ~/upload-keystore.jks \
  -alias upload | grep SHA
```

**Important:** Ajoutez aussi ces empreintes de release dans Firebase Console!

## ✅ Vérification

Après avoir ajouté les empreintes:

1. **Téléchargez le nouveau `google-services.json`**
2. **Remplacez le fichier** dans `android/app/`
3. **Clean et rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Vérifiez les logs** pour confirmer que Firebase fonctionne correctement

## 🐛 Troubleshooting

### "Keystore not found"
Le keystore debug n'existe pas encore. Lancez l'app une fois:
```bash
flutter run
```
Cela créera automatiquement `~/.android/debug.keystore`

### "keytool: command not found"
Installez Java JDK ou utilisez la méthode Android Studio.

### Version Java incompatible
Utilisez Android Studio (Méthode 1) qui gère automatiquement les versions Java.

### Empreinte déjà dans Firebase mais ne fonctionne pas
1. Vérifiez que le package name correspond: `com.example.visitdjibouti`
2. Téléchargez à nouveau `google-services.json`
3. Clean et rebuild le projet

## 📝 Notes importantes

- **Debug keystore** : Utilisé pour le développement (flutter run)
- **Release keystore** : Utilisé pour la production (flutter build)
- **Vous devez ajouter les deux types d'empreintes** dans Firebase Console
- Les empreintes sont spécifiques à chaque machine de développement
- Chaque développeur doit ajouter ses propres empreintes debug

## 🎯 Résumé rapide

```bash
# 1. Obtenir SHA-1 et SHA-256
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA

# 2. Copier les valeurs

# 3. Aller sur Firebase Console
# https://console.firebase.google.com/project/visit-djibouti/settings/general

# 4. Ajouter les empreintes dans votre app Android

# 5. Télécharger nouveau google-services.json

# 6. Remplacer android/app/google-services.json

# 7. Flutter clean && flutter run
```

## 📚 Ressources

- [Firebase - Authenticate Your Client](https://firebase.google.com/docs/android/setup#add-config-file)
- [Android - Sign Your App](https://developer.android.com/studio/publish/app-signing)
- [Flutter - Build and Release Android App](https://flutter.dev/docs/deployment/android)
