# Flutter Authentication

## Scope

This phase implements frontend authentication and account-session management only. It does not add password reset, dashboards, classes, or payment features, and it does not change Laravel code.

## Requests

`AuthService` is the sole remote source for these existing Laravel endpoints:

| Method | Path                           | Use                                                           |
| ------ | ------------------------------ | ------------------------------------------------------------- |
| POST   | `/api/v1/auth/login`           | Starts a session with `phone`, `password`, and `device_name`. |
| POST   | `/api/v1/auth/logout`          | Invalidates the remote session before local cleanup.          |
| GET    | `/api/v1/auth/me`              | Restores and validates a persisted session.                   |
| POST   | `/api/v1/auth/change-password` | Changes an authenticated user's password.                     |
| POST   | `/api/v1/auth/set-password`    | Sets an authenticated user's password.                        |
| POST   | `/api/v1/auth/refresh-token`   | Supports token renewal when a calling feature requires it.    |

No `user_type` is sent with the login request. The role segmented control is presentation-only. After login, `AuthSession` parses `user.user_type` from the backend response and `AuthGuard` routes only to the matching `/admin`, `/student`, or `/sponsor` area.

## Session Lifecycle

1. `SessionManager` checks secure storage during app startup.
2. When a token is present, it calls `/auth/me` before treating the session as authenticated.
3. Login stores the Sanctum token and minimal session metadata (`id`, `name`, `user_type`) in encrypted storage.
4. Logout calls `/auth/logout`; local token and session data are cleared even when the remote call fails.
5. A `401` from an authenticated password action, or a failed `/auth/me` restore, clears local authentication state. GoRouter then redirects to `/login`.

## Password Screens

`ChangePasswordScreen` submits the current password, new password, and matching confirmation. `SetPasswordScreen` submits a new password and confirmation. Both screens are authenticated-only routes and show validation, loading, API-error, and completion states.

The supplied user schema does not include a field that states whether a password has already been set. Consequently, the frontend provides the authenticated `/set-password` route but does not infer password state from another user field. When the backend exposes an authoritative password-setup flag in its existing user response, `SessionManager` can use it to redirect eligible users to this route.
