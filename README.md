# Creatify Mobile — Engineering Handover

Creatify is a Flutter marketplace app that connects **recruiters** (people who want
content) with **creators** (talent/creators who deliver it). The app supports
discovery/search of creators, bookings with negotiation and deliverables, in-app
real-time chat, payments (Stripe + an in-app wallet), subscriptions, KYC, and push
notifications.

- **App name / bundle id:** Creatify — `com.creatify.mobile` (Android & iOS)
- **Current version:** `1.0.9+29` (see [pubspec.yaml](pubspec.yaml))
- **Flutter:** `3.41.1` pinned via FVM (see [.fvmrc](.fvmrc)); Dart SDK `>=3.3.2 <4.0.0`
- **State management:** Riverpod (`hooks_riverpod`) + `get_it` for a few singletons
- **Networking:** Dio with custom interceptors
- **Error monitoring:** Sentry · **Analytics:** Mixpanel

> This README is the project handover. Other docs in the repo:
> [PUSHER_INTEGRATION.md](PUSHER_INTEGRATION.md) (real-time chat deep dive) and
> [EXPAND_MEDIA_README.md](EXPAND_MEDIA_README.md) (the full-screen media viewer widget).

---

## 1. Getting Started

### Prerequisites
- [FVM](https://fvm.app/) with Flutter `3.41.1` installed (`fvm install 3.41.1`).
  All `flutter`/`dart` commands below assume `fvm flutter …` if you use FVM.
- Xcode + CocoaPods (iOS), Android SDK (Android).
- A populated `.env` file at the repo root (see [Environment & Secrets](#3-environment--secrets)).

### First-time setup
```bash
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates env.g.dart, etc.
cd ios && pod install && cd ..                              # iOS only
```

### Running the app
The build environment is selected at compile time via the `ENVIRONMENT`
dart-define (defaults to `prod` if omitted — see [main.dart](lib/main.dart)):

```bash
# Staging
fvm flutter run --dart-define=ENVIRONMENT=staging

# Production
fvm flutter run --dart-define=ENVIRONMENT=prod
```

When running staging, a red **STAGING** corner banner is shown in the UI
(`CustomBanner` in [app.dart](lib/app.dart)).

### App icons & splash
```bash
dart run flutter_launcher_icons    # regenerate launcher icons after changing assets/images/app_icon_square.png
dart run flutter_native_splash:create
```

---

## 2. Architecture Overview

The codebase follows a layered structure under [lib/](lib/):

```
lib/
├── main.dart                 # Entry point: Sentry init, env selection, Hive + DI bootstrap, Stripe key
├── app.dart                  # MyApp root widget: routing-to-home, deep links, lifecycle, Mixpanel, session
├── core/                     # Cross-cutting infrastructure (no UI)
│   ├── di/injector.dart      # Riverpod + get_it dependency injection
│   ├── env/                  # Envied-generated env vars (env.dart + env.g.dart)
│   ├── http/                 # HttpService interface + Dio implementation
│   ├── interceptors/         # Token (auth), cache, and kick-out interceptors
│   ├── storage/              # Hive, secure storage, SharedPreferences wrappers
│   ├── services/             # Mixpanel, receipt export, product tour
│   ├── third-party/          # environment.dart (Environmentx enum), device info
│   ├── deeplinking/          # app_links handling
│   ├── connection/, error/, extensions/, utils/
├── data/
│   ├── models/               # DTOs: requests/, responses/, chat/
│   ├── remote/               # Repositories + services per domain (see below)
│   └── local/                # Local data sources
├── domain/                   # Domain layer
└── view/
    ├── modules/              # Feature screens grouped by domain (see Modules)
    ├── route/                # NavigationService singleton + current user notifier
    ├── theme/                # AppColors, AppTheme
    ├── widgets/              # Shared widgets (incl. media_viewer/)
    └── utils/                # Biometrics, session-manager, product tour
```

### Layering pattern (per feature)
Each backend domain is wired the same way in [injector.dart](lib/core/di/injector.dart):

```
View / ViewModel (Riverpod)  →  Repo (abstract + Impl)  →  Service (HTTP calls)  →  NetworkService (Dio)
```

For example `AuthRepo` ← `AuthImpl` ← `AuthService`. Repos are exposed as Riverpod
`Provider`s (`authRepository`, `creatorRepository`, `bookingsRepository`,
`transactionsRepository`, `chatRepository`). The single `NetworkService`
(implementing `HttpService`) is shared across all services.

### Networking
- All endpoints are centralised in [app_url.dart](lib/core/utils/app_url.dart)
  (`ApiEndpoints`), which switches base URL by environment:
  - **Staging:** `https://staging-api.creatifyapp.com`
  - **Production:** `https://api.creatifyapp.com`
- [TokenInterceptor](lib/core/interceptors/token_interceptor.dart) injects the
  `Bearer` auth token. The token is **cached in memory** to avoid hitting secure
  storage on every request — `initToken()` is preloaded at app start in
  [app.dart](lib/app.dart) (`_preloadAuthToken`) to avoid a race where API calls
  fire before the token is loaded. Call `updateToken()` after login and
  `clearToken()` on logout.
- Response caching uses `dio_cache_interceptor` (Hive-backed).

### Routing
Navigation is imperative via a singleton [NavigationService](lib/view/route/navigation_service.dart)
(`NavigationService.instance.push(...)`, `pushNamed`, `pushReplacement`,
`pushAndRemoveUntil`). The app uses a single `MaterialApp` whose `home` is chosen
at runtime by `_getHomeScreen` in [app.dart](lib/app.dart):
1. First launch → `OnboardingView`
2. User still loading from storage → loading spinner
3. No user → `LoginView`
4. Logged in → `TabBarSection`

### Deep links
Handled by `AppLinksDeepLink` and wired in [app.dart](lib/app.dart). Two URI
formats are supported:
- Universal link: `https://creatifyapp.com/profile/<CODE>`
- Custom scheme: `creatify://profile/<CODE>` (simulator/local testing)

There is debounce/guard logic to handle the known cold-start echo where
`uriLinkStream` re-emits the URI that `getInitialLink()` already returned, and to
defer navigation until the user finishes loading from storage.

---

## 3. Environment & Secrets

Secrets are loaded from a root `.env` file using **envied** (obfuscated) and
exposed via [env.dart](lib/core/env/env.dart). The generated `env.g.dart` is
committed but must be regenerated with `build_runner` if `.env` changes.

> ⚠️ `.env` is **not** checked in (it's git-ignored). Obtain it from the team
> secrets store before building. Required keys:

| Key | Purpose |
|-----|---------|
| `DOJAH_WIDGET_ID` / `PROD_DOJAH_WIDGET_ID` | Dojah KYC widget |
| `PUSHER_APP_KEY` / `PROD_PUSHER_APP_KEY` / `PUSHER_CLUSTER` | Pusher real-time chat |
| `ONESIGNAL_APP_ID` | OneSignal push notifications |
| `GOOGLE_WEB_CLIENT_ID` / `GOOGLE_ANDROID_CLIENT_ID` / `GOOGLE_IOS_CLIENT_ID` | Google Sign-In |
| `MIXPANEL_TOKEN` | Mixpanel analytics |
| `STRIPE_PUBLISHABLE_KEY` / `PROD_STRIPE_PUBLISHABLE_KEY` | Stripe payments |

Other secret material in the repo (handle with care, do not leak):
- Android keystore + signing config — referenced in [flux-mobile.yml](flux-mobile.yml)
  (`android/keystore.jks`)
- Play Store service account — `keys/playstore.json`
- App Store Connect API key — `keys/AuthKey_*.p8`
- Sentry DSN is currently hard-coded in [main.dart](lib/main.dart).

---

## 4. Feature Modules

Screens live under [lib/view/modules/](lib/view/modules/), each typically with
`vm/` (Riverpod view-models), `widgets/`, and `sheets/` subfolders.

| Module | What it covers |
|--------|----------------|
| `onboarding` | First-launch onboarding carousel |
| `authentication` | Login, signup, user-type selection, email verification, forgot/reset password, Google & Apple sign-in |
| `tab-bar` | Root bottom-nav shell (`TabBarSection`) controlling the main tabs |
| `home` | Profile/settings hub: edit profile, change password, transaction PIN, notifications, favorites, referrals, ambassador program, search preferences, support, delete account |
| `search-talents` | Creator discovery/search (also the deep-link landing tab) |
| `showcase-talents` | Creator self-management: own creator/recruiter profile, payout details, portfolio upload, rates card, availability, Stripe verification, subscription management |
| `bookings` | Booking lifecycle: book a creator, booking details, sent/received/draft bookings, negotiation, deliverables, payment success |
| `transactions` | Wallet & transactions: all transactions, transaction details, withdrawals, PIN reset |
| `chats` | Real-time conversations (see Pusher integration) |
| `webview` | In-app webview container |

### User types
The domain distinguishes **creators** and **recruiters** (separate profile
endpoints and onboarding flows). A creator can be booked; a recruiter books and
pays.

### Payments
Two payment rails coexist:
- **Stripe** (`flutter_stripe`) — Connect onboarding for creators, card funding.
- **In-app wallet** — virtual accounts, wallet PIN, withdrawals, funding & verification
  (see the Wallet endpoints in [app_url.dart](lib/core/utils/app_url.dart)).

Bookings can be **time-based** or **deliverable-based**, each with its own
status-update and completion endpoints.

### Real-time chat
Built on **Pusher Channels**, authorised through `/api/broadcasting/auth`. There
are several chat service variants in [lib/data/remote/chat/](lib/data/remote/chat/)
(`pusher_service.dart`, `chat_pusher_service.dart`, `enhanced_chat_service.dart`,
`refactored_pusher_service.dart`, plus `*_example.dart` reference files).
Pusher reconnection is re-attempted on app resume (`_ensurePusherReconnection`
in [app.dart](lib/app.dart)). See [PUSHER_INTEGRATION.md](PUSHER_INTEGRATION.md).

> 🔧 **Tech-debt note:** the chat folder contains multiple overlapping service
> implementations and `*_example.dart` files. Confirm which one is live before
> editing, and consider consolidating.

---

## 5. Key Third-Party Integrations

| Concern | Package / Service |
|---------|-------------------|
| Crash & error reporting | `sentry_flutter` (+ `sentry_dart_plugin` for symbol upload) |
| Product analytics | `mixpanel_flutter` |
| Push notifications | `onesignal_flutter` |
| Real-time | `pusher_channels_flutter` |
| Payments | `flutter_stripe` |
| KYC | `flutter_dojah_kyc` |
| Auth | `google_sign_in`, `sign_in_with_apple`, `local_auth` (biometrics) |
| Storage | `hive`/`hive_flutter`, `flutter_secure_storage`, `shared_preferences` |
| Media | `image_picker`, `image_cropper`, `camera`, `video_player`, `just_audio`, `flutter_pdfview`, `video_compress`, `flutter_image_compress` |
| Support chat | `flutter_tawkto` |

---

## 6. Build, Release & CI

- **Signing / distribution** is configured in [flux-mobile.yml](flux-mobile.yml)
  (Flux Mobile): Android → Play Store `internal` track; iOS → TestFlight via
  Transporter. App Store Connect and Play Store credentials live under `keys/`.
- **Versioning strategy:** `auto` (managed by Flux Mobile). Bump `version` in
  [pubspec.yaml](pubspec.yaml) for manual builds.
- **Sentry symbol upload** is enabled in [pubspec.yaml](pubspec.yaml)
  (`sentry:` block, org `maraz-develops`, project `creatify`).

### Common commands
```bash
dart run build_runner build --delete-conflicting-outputs   # regenerate env + any generated code
fvm flutter analyze                                         # lint (rules in analysis_options.yaml)
fvm flutter test                                            # tests
fvm flutter build apk --dart-define=ENVIRONMENT=prod
fvm flutter build ipa --dart-define=ENVIRONMENT=prod
```

---

## 7. Gotchas & Things to Know

- **Environment defaults to `prod`.** If you run without `--dart-define=ENVIRONMENT`,
  you hit the production API. Always pass `staging` for development.
- **`Environmentx` enum naming:** `staging` carries the value `'DEV'`. The
  `--dart-define` string `'staging'` maps to `Environmentx.staging`; some Stripe
  logic in [main.dart](lib/main.dart) also checks for the literal `'dev'`.
  Be careful when comparing environment strings.
- **Auth token caching:** if you change login/logout flows, make sure
  `TokenInterceptor.updateToken()`/`clearToken()` are called or requests will use
  a stale/empty token.
- **`.env` + `env.g.dart`:** must be regenerated via `build_runner` after editing
  `.env`, or you'll build with stale obfuscated values.
- **Generated/build artifacts** (`build/`, `ios/Pods/`, `.dart_tool/`) are not
  part of the source you should edit. (Do **not** put project docs inside
  `ios/Pods/…` — that directory is regenerated by `pod install`.)
- **iPad sizing:** `app.dart` computes a dynamic `designSize` for `ScreenUtilInit`
  and applies a `textScaler` of `0.98` globally.
- **Session timeout:** wrapped by `SessionTimeoutManager` — auto-logout/lock
  behaviour lives in [lib/view/utils/session-manager/](lib/view/utils/session-manager/).

---

## 8. Where to Start (new engineer checklist)

1. Get `.env` from the team and run the [first-time setup](#first-time-setup).
2. Run staging: `fvm flutter run --dart-define=ENVIRONMENT=staging`.
3. Read [main.dart](lib/main.dart) → [app.dart](lib/app.dart) →
   [injector.dart](lib/core/di/injector.dart) to understand bootstrap & DI.
4. Skim [app_url.dart](lib/core/utils/app_url.dart) for the full API surface.
5. Pick a feature in [lib/view/modules/](lib/view/modules/) and trace it down the
   View → Repo → Service → NetworkService path.
