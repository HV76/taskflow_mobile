# TaskFlow Mobile

Sistema de gestion operativa para tecnicos de TI: ordenes de trabajo,
seguimiento de incidencias y registro de servicios. Proyecto Integrador —
Etapa 3 (UVM).

- **Plataforma:** Flutter (Dart), Material Design 3.
- **Backend:** Firebase Cloud Firestore (tiempo real + persistencia offline).
- **Arquitectura:** capas separadas `models/`, `services/`, `screens/`, `widgets/`.

## Estructura del proyecto

```
taskflow_mobile/
├── lib/
│   ├── models/
│   │   └── task_model.dart        # Entidad TaskModel + enums Priority/Status
│   ├── services/
│   │   └── firestore_service.dart # CRUD y Streams contra Cloud Firestore
│   ├── screens/
│   │   └── home_screen.dart       # Lista en tiempo real, filtros, FAB
│   ├── widgets/
│   │   ├── task_card.dart         # Tarjeta de orden de trabajo
│   │   └── task_form_modal.dart   # Formulario reactivo crear/editar
│   ├── firebase_options.dart      # Generado por flutterfire configure
│   └── main.dart                  # Inicializacion asincrona de Firebase
├── test/
│   └── task_model_test.dart       # Pruebas unitarias del modelo
├── pubspec.yaml
└── analysis_options.yaml
```

## 0. Requisitos previos

- Flutter SDK instalado y en el PATH (`flutter --version`).
- Cuenta de Firebase y proyecto creado en https://console.firebase.google.com
- Node.js (para instalar Firebase CLI) y Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## 1. Generar las carpetas nativas (android/, ios/)

Este entregable incluye todo el codigo Dart (`lib/`, `test/`) y la
configuracion (`pubspec.yaml`, `analysis_options.yaml`) ya escritos y listos.
Como el andamiaje nativo de Android/iOS depende de la version exacta del
Flutter SDK instalado en tu maquina, generalo localmente parado en la raiz
del proyecto:

```bash
flutter create . --project-name taskflow_mobile --platforms=android,ios
flutter pub get
```

Esto no sobrescribe el codigo en `lib/` ni en `test/`; solo crea/actualiza
las carpetas nativas `android/` e `ios/` necesarias para compilar.

## 2. Configurar Firebase con FlutterFire CLI

Autentica la CLI de Firebase y vincula el proyecto:

```bash
firebase login
flutterfire configure
```

`flutterfire configure` te pedira seleccionar tu proyecto de Firebase (o
crear uno nuevo) y las plataformas a soportar (Android/iOS). Al terminar,
**regenerara automaticamente** `lib/firebase_options.dart` con tus
credenciales reales, reemplazando el esqueleto de ejemplo incluido en este
entregable.

En la consola de Firebase, habilita **Cloud Firestore** (modo produccion o
prueba segun tu entrega) desde Build > Firestore Database > Crear base de
datos.

### Reglas de seguridad sugeridas para la entrega (modo prueba/desarrollo)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /work_orders/{docId} {
      allow read, write: if true;
    }
  }
}
```

> Para un entorno real de produccion, sustituye `allow read, write: if true;`
> por reglas basadas en autenticacion (`request.auth != null`).

## 3. Instalar dependencias

```bash
flutter pub get
```

Dependencias clave declaradas en `pubspec.yaml`:
`firebase_core`, `cloud_firestore`, `intl`, `uuid`, `flutter_lints`.

## 4. Persistencia offline

La persistencia local de Firestore se configura en
`lib/services/firestore_service.dart` mediante:

```dart
_firestore.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

Esto permite que la app funcione sin conexion, sincronizando los cambios
automaticamente cuando vuelve la conectividad.

## 5. Ejecutar pruebas estaticas (analisis de codigo)

```bash
flutter analyze
```

Verifica el cumplimiento de las reglas de `flutter_lints` definidas en
`analysis_options.yaml`.

## 6. Ejecutar pruebas dinamicas (unitarias)

```bash
flutter test
```

Ejecuta `test/task_model_test.dart`, que valida:
- Conversion de cadenas a los enums `TaskPriority` y `TaskStatus` (`fromString`).
- Validacion de campos obligatorios (`isValid`).
- Serializacion a mapa para Firestore (`toMap`).
- Inmutabilidad y actualizacion parcial (`copyWith`).

## 7. Ejecutar la app en desarrollo

```bash
flutter run
```

## 8. Compilar el APK de entrega

```bash
flutter build apk --release
```

El APK resultante se genera en:
`build/app/outputs/flutter-apk/app-release.apk`

## Funcionalidad implementada (CRUD)

| Operacion | Donde | Descripcion |
|---|---|---|
| **Create** | `TaskFormModal` + `FirestoreService.createTask` | Formulario reactivo con validacion (titulo, descripcion, prioridad, ubicacion). Estado inicial `Pendiente` y `createdAt` con `Timestamp.now()`. |
| **Read** | `HomeScreen` + `FirestoreService.streamTasks` | `StreamBuilder` sobre `snapshots()` de Firestore, ordenado por `createdAt` descendente, con chips de filtro por estado. |
| **Update** | `TaskCard` (menu de estado) y `TaskFormModal` (edicion) + `FirestoreService.updateTaskStatus` / `updateTask` | Cambia el estado (Pendiente/En Progreso/Completado) o edita los campos, actualizando `updatedAt`. |
| **Delete** | `HomeScreen._confirmDelete` + `FirestoreService.deleteTask` | Dialogo de confirmacion antes de eliminar el documento en Firestore. |

## Notas para la entrega

- El archivo `lib/firebase_options.dart` incluido es un **esqueleto de
  ejemplo** con el formato correcto; debe regenerarse con
  `flutterfire configure` usando tu propio proyecto de Firebase antes de
  compilar, ya que las credenciales son unicas por proyecto y no pueden
  generarse sin acceso a tu cuenta de Firebase.
- La coleccion de Firestore utilizada es `work_orders`.
