# ClassPay Flutter Frontend

## Scope

ClassPay is a Material 3 Flutter client for Android and iOS. The application uses the existing Laravel API only; it does not contain Laravel code or define backend routes. API hosts are configured at build time and all client paths are relative to `/api/v1`.

## Architecture

The application follows a layered Flutter structure:

| Folder             | Responsibility                                                                                           |
| ------------------ | -------------------------------------------------------------------------------------------------------- |
| `lib/core`         | Configuration, transport, secure storage, exceptions, theme, reusable widgets, and formatting utilities. |
| `lib/models`       | Immutable API response and request presentation models.                                                  |
| `lib/services`     | Endpoint-specific Dio calls.                                                                             |
| `lib/repositories` | Feature-facing data APIs over services.                                                                  |
| `lib/providers`    | Riverpod state and async data providers.                                                                 |
| `lib/screens`      | Role and feature screens. Widgets delegate requests and state ownership to providers and repositories.   |
| `lib/routes`       | GoRouter navigation and backend-role-based guards.                                                       |

Riverpod is used for dependency injection and async feature state. GoRouter owns redirects and deep links. Dio provides HTTP transport.

## Environment And Build

The fallback API host is intended for local development. Supply a deployed API host with `API_BASE_URL`; the app appends `/api/v1` if it is not present.

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.example.com
flutter analyze
flutter test
```

## Authentication And Security

Authentication uses Sanctum bearer tokens. `flutter_secure_storage` stores the token and minimal session metadata only: user ID, name, and backend `user_type`. Passwords, password hashes, payment credentials, tokens in plain storage, and client-supplied payer/participant/payment values are not persisted.

On startup, `SessionManager` verifies a stored token through `/auth/me`. Every Dio request injects the bearer token when present. Any HTTP `401` clears secure storage, notifies the session manager, marks the session unauthenticated, and lets GoRouter redirect to `/login`; guarded authenticated routes then cannot be revisited.

Login role choices are presentation aids only. The backend `user.user_type` returned by login and `/auth/me` is authoritative for navigation and access checks.

## Navigation And Roles

`AuthGuard` permits `/admin/*` only to admins, `/student/*` only to students, and `/sponsor/*` only to sponsors. Notifications and profile are available only to an authenticated session. Unknown or cross-role deep links redirect to the role home route.

The role drawer integrates available feature routes, profile, notifications, password changes, and logout. Notifications display the backend unread count. Normal GoRouter pushes provide back navigation; logout and token expiry replace protected access through router redirects.

## API And Errors

All services consume the standard Laravel envelope (`success`, `message`, `data`). `ApiException` retains backend validation errors for form fields. The shared client provides clear fallbacks for `403`, `404`, `422`, `500`, connection failures, and request timeouts. API-driven list screens use loading, error/retry, empty, and refresh states; forms use local validation, disabled processing controls, and backend validation messages.

## Payments And Notifications

Participant payment creation sends only `additional_infaq` and `payment_method`; the backend determines payment totals, status, payer, participant, and schedule results. Payment history and administrative reports display backend-returned values and aggregates without local financial calculations.

The notification center supports unread count, pagination, unread/type filters, marking one notification read or unread, and marking all read. Related-resource actions are deliberately limited to known, role-owned routes.

## Current Boundaries

Several earlier requested feature contracts/screens are not present in the workspace and were not invented during hardening: student/sponsor class discovery, admin student/sponsor/participant management screens, and class payment-setting/QR screens. Their existing models/services may be extended only when their documented endpoint contracts and UI requirements are completed. This phase makes no new business feature claims beyond the implemented screens and routes.
