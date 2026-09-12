# Flutter Architecture

## Scope

This project is the ClassPay Flutter frontend. It consumes the existing Laravel API beneath `/api/v1` and does not include backend implementation. Authentication screens and flows are intentionally deferred.

## Layers

| Location                                   | Responsibility                                                                                                                               |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `core/config`                              | Runtime configuration. Set the API host with `--dart-define=API_BASE_URL=https://example.com`. The `/api/v1` suffix is applied when omitted. |
| `core/network`                             | Dio client, Sanctum bearer header injection, standard API response parsing, pagination and transport error translation.                      |
| `core/storage`                             | Encrypted token persistence using `flutter_secure_storage`.                                                                                  |
| `core/errors`                              | Shared typed exceptions exposed to repositories and providers.                                                                               |
| `core/theme`, `core/widgets`, `core/utils` | Material 3 theme, shared interface elements, and presentation utilities including RM currency formatting.                                    |
| `models`                                   | Immutable API/domain models as features are added.                                                                                           |
| `services`                                 | Feature-specific remote data source wrappers where needed.                                                                                   |
| `repositories`                             | Mapping and coordination between services and domain-facing providers.                                                                       |
| `providers`                                | Riverpod providers and feature state notifiers. Widgets consume state here, not services directly.                                           |
| `screens`                                  | Feature screens grouped under `auth`, `admin`, `student`, and `sponsor`.                                                                     |
| `routes`                                   | Declarative app navigation and future role-aware route guards.                                                                               |

## API Contract

`ApiClient` uses Dio with a base URL that terminates in `/api/v1`. Its request interceptor reads the stored Sanctum token and supplies `Authorization: Bearer <token>` when present. No endpoint paths are defined until their backend contract is introduced.

`ApiResponse<T>` accepts the standard response envelope:

```json
{ "success": true, "message": "...", "data": {} }
```

Failed envelopes are surfaced as `ApiException`, retaining the message, HTTP status where available, and validation `errors` map. `PaginatedResponse<T>` supports standard Laravel paginator payloads.

## Conventions

- Keep business rules in repositories and Riverpod notifiers, never in widgets.
- Model each feature's loading, empty, error, and success state explicitly.
- Use `AppButton`, `AppTextField`, `AppCard`, and the widgets in `async_states.dart` for shared UI states.
- Show monetary values with `formatMyCurrency`, which formats values as `RM 0.00`.
- Add feature tests at the repository/provider level and widget tests for user-facing screen states.
