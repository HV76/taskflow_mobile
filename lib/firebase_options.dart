import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para macos. '
          'Ejecuta `flutterfire configure` para generar las opciones.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para windows. '
          'Ejecuta `flutterfire configure` para generar las opciones.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no ha sido configurado para linux. '
          'Ejecuta `flutterfire configure` para generar las opciones.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no soporta esta plataforma.',
        );
    }
  }

  // NOTA IMPORTANTE:
  // Este archivo debe regenerarse automaticamente ejecutando:
  //   flutterfire configure
  // desde la raiz del proyecto, con la CLI de Firebase autenticada y
  // vinculada a tu proyecto real. Los valores de abajo son un esqueleto
  // de ejemplo con el formato correcto y DEBEN reemplazarse por los
  // valores reales de tu proyecto de Firebase antes de compilar.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REEMPLAZAR_CON_TU_API_KEY_WEB',
    appId: 'REEMPLAZAR_CON_TU_APP_ID_WEB',
    messagingSenderId: 'REEMPLAZAR_CON_TU_SENDER_ID',
    projectId: 'taskflow-mobile-uvm',
    authDomain: 'taskflow-mobile-uvm.firebaseapp.com',
    storageBucket: 'taskflow-mobile-uvm.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNUXtPziRzdNg8GlwWnkUkjZAIKFwp8Wg',
    appId: '1:263314174393:android:a5aeb5f9d51d733e000668',
    messagingSenderId: '263314174393',
    projectId: 'taskflowmobile-uvm-hector',
    storageBucket: 'taskflowmobile-uvm-hector.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYkktGBTDvfp99N0Udb-eIb6eklleeW_E',
    appId: '1:263314174393:ios:a41b902967f0374d000668',
    messagingSenderId: '263314174393',
    projectId: 'taskflowmobile-uvm-hector',
    storageBucket: 'taskflowmobile-uvm-hector.firebasestorage.app',
    iosBundleId: 'com.example.taskflowMobile',
  );
}
