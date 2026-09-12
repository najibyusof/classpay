# ClassPay Flutter Frontend

ClassPay is a Material 3 Flutter client for administrators, students, and sponsors. It communicates with the existing Laravel backend through its `/api/v1` API and uses Laravel Sanctum bearer tokens for authenticated requests.

## Requirements

- Flutter SDK 3.41 or later
- Dart SDK 3.11 or later

## Setup

```powershell
flutter pub get
flutter run
```

The default API URL is `https://classpay.padat.net/api/v1`.

To point a local build at another deployment, provide the API host at build time. The app adds the `/api/v1` suffix when it is omitted.

```powershell
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

## Quality Checks

```powershell
flutter analyze
flutter test
```

## Architecture

The application uses Riverpod for state and dependency management, GoRouter for guarded navigation, Dio for HTTP transport, and `flutter_secure_storage` for Sanctum token storage. Further architecture, security, error-handling, and navigation notes are in [docs/flutter-frontend.md](docs/flutter-frontend.md).
