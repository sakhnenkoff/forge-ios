# Forge vNext Module/Substrate Manifest Proposal

Status: transitional substrate manifest proposal for generated local proof apps.

## Purpose

Forge must treat the current template as a legacy substrate that is assembled by explicit capability selection, not copied as a golden app. The module/substrate manifest is the inventory that lets a planner decide what gets assembled, what gets rejected, and what absence gates must prove after generation.

Each generated app writes its app-specific selection to `.forge/module-plan.json` using `schema_version: forge.module-plan.v1`. The generator may still use copy-then-sanitize while Forge is transitional, but the module plan and verifier must make every optional module explicit.

## Manifest entry shape

```json
{
  "id": "auth-account",
  "purpose": "Account identity, sign-in, and authenticated session UI.",
  "product_prerequisites": ["User identity is required for the core loop", "The product gate explicitly selects account persistence"],
  "files": ["*/Features/Auth/**", "*/Managers/Auth/**"],
  "dependencies": ["FirebaseAuth", "GoogleSignIn"],
  "routes": ["auth", "account", "login"],
  "visible_surfaces": ["AuthView", "AccountView", "Login"],
  "forbidden_by_default": true,
  "absence_gates": ["path_absent", "repo_forbid_regex", "route_absent", "docs_forbid_positive_setup"]
}
```

Required fields:

- `id`: stable module id used by `.forge/module-plan.json`.
- `purpose`: what reusable capability the module provides.
- `product_prerequisites`: product/design gates that must justify selection.
- `files`: template paths copied only when the module is selected or removed by sanitizer when not selected.
- `dependencies`: packages, SDKs, entitlements, or service files introduced by the module.
- `routes`: navigation/tab/sheet identifiers introduced by the module.
- `visible_surfaces`: Swift/UI labels/symbols that prove the module is visible, routable, or compiled.
- `forbidden_by_default`: true for product-specific or external modules.
- `absence_gates`: verifier checks that must fail when rejected modules leave residue.

## Transitional default for generated proof apps

Generated local proof apps select only:

```json
{
  "selected_modules": ["local-proof-shell"],
  "rejected_modules": [
    { "id": "auth-account", "rationale": "No app-specific plan selected accounts or auth." },
    { "id": "paywall-purchases", "rationale": "No app-specific plan selected purchases, subscriptions, StoreKit, or RevenueCat." },
    { "id": "sync-backend", "rationale": "No app-specific plan selected backend sync, Firebase, or external persistence." },
    { "id": "settings-profile", "rationale": "Settings/profile is optional product surface, not default substrate." },
    { "id": "onboarding", "rationale": "Onboarding must be app-specific and evidence-backed." },
    { "id": "public-launch", "rationale": "Local proof apps exclude App Store, TestFlight, signing, launch, and credential actions." }
  ],
  "absence_gate": "scripts/forge-vnext-verifier.mjs proof-app strictness enforces rejected module absence."
}
```

## Initial substrate inventory

### local-proof-shell

- purpose: minimal SwiftUI app shell for local mock proof work.
- product_prerequisites: always selected for generated local proof apps.
- files: project scaffold, mock scheme, app target, design-system primitives, routing primitives, local/mock service pattern, `.forge` artifact contracts.
- dependencies: local-only Swift/Xcode defaults; no external account, payment, backend, launch, or credential SDKs.
- routes: only routes introduced by the app-specific proof plan.
- visible_surfaces: app-specific screens and local proof copy.
- forbidden_by_default: false.
- absence_gates: generated repo must still pass proof-app strictness so selected shell does not carry copied optional module residue.

### auth-account

- purpose: account creation, sign-in, auth session state, profile identity.
- product_prerequisites: selected only when identity is central to the core loop and product gates approve account/auth behavior.
- files: `*/Features/Auth/**`, `*/Features/Account/**`, `*/Managers/Auth/**`.
- dependencies: FirebaseAuth, GoogleSignIn, account service plists where applicable.
- routes: auth, login, sign-up, account, profile.
- visible_surfaces: AuthView, AuthViewModel, AccountView, AccountViewModel, AuthenticationManager.
- forbidden_by_default: true.
- absence_gates: path_absent for auth/account features; repo_forbid_regex for auth/account Swift symbols; docs_forbid_positive_setup for account/auth instructions.

### paywall-purchases

- purpose: purchases, subscriptions, paywalls, StoreKit/RevenueCat entitlements.
- product_prerequisites: selected only when monetization is required and local proof scope allows payment simulation.
- files: `*/Features/Paywall/**`, `*/Managers/Purchases/**`, purchase package manifests.
- dependencies: StoreKit, RevenueCat, purchases-ios.
- routes: paywall, subscription, purchase, upgrade.
- visible_surfaces: PaywallView, PaywallViewModel, PaymentManager, PurchaseManager, PurchaseService.
- forbidden_by_default: true.
- absence_gates: path_absent for paywall features; repo_forbid_regex for payment symbols and SDKs; docs_forbid_positive_setup for payment/subscription/purchase instructions.

### sync-backend

- purpose: external backend sync, cloud persistence, analytics, remote config, crash reporting, push notification infrastructure.
- product_prerequisites: selected only when app-specific proof requires backend behavior and credentials are explicitly allowed by scope.
- files: Firebase plist references, backend managers, push entitlements, upload scripts.
- dependencies: firebase-ios-sdk, FirebaseFirestore, FirebaseMessaging, FirebaseRemoteConfig, FirebaseStorage, FirebaseAnalytics, FirebaseCrashlytics, Mixpanel.
- routes: sync/account-backed routes only when selected.
- visible_surfaces: backend manager types, FirebaseAppDelegateProxyEnabled, GoogleService-Info, upload-symbols.
- forbidden_by_default: true.
- absence_gates: repo_forbid_regex for Firebase/Mixpanel symbols, plist names, push entitlements, Crashlytics scripts, and automatic signing residue.

### settings-profile

- purpose: settings, profile, preferences, account-management UI.
- product_prerequisites: selected only when settings/profile is part of the proof app’s product loop.
- files: `*/Features/Settings/**`, `*/Features/Profile/**`, app-specific settings view models.
- dependencies: none by default; may depend on auth-account if settings manages account data.
- routes: settings, profile, preferences, account management.
- visible_surfaces: SettingsView, ProfileView, Account settings labels.
- forbidden_by_default: true.
- absence_gates: path_absent for generic settings/profile features; route_absent for generic tabs/sheets; docs_forbid_positive_setup for profile/account setup.

### onboarding

- purpose: first-run onboarding, permission education, tutorial flows.
- product_prerequisites: selected only when app-specific activation evidence requires onboarding.
- files: `*/Features/Onboarding/**` and onboarding route wiring.
- dependencies: none by default; push/photo/location permissions must be separate selected modules.
- routes: onboarding, welcome, first-run.
- visible_surfaces: OnboardingView, WelcomeView, tutorial labels.
- forbidden_by_default: true.
- absence_gates: path_absent for copied onboarding; route_absent for first-run wiring; visible label checks for generic welcome/tutorial residue.

### public-launch

- purpose: App Store/TestFlight/signing/release package wiring.
- product_prerequisites: selected only for explicit launch-package work, never for local proof generation.
- files: launch package docs, signing instructions, App Store Connect drafts, TestFlight checklists, provisioning scripts.
- dependencies: Apple developer account, credentials, signing identities, provisioning profiles.
- routes: none in-app by default.
- visible_surfaces: App Store, TestFlight, signing, provisioning profile, public launch instructions.
- forbidden_by_default: true.
- absence_gates: docs_forbid_positive_setup for launch/signing instructions; repo_forbid_regex for DEVELOPMENT_TEAM, CODE_SIGN_STYLE = Automatic, PROVISIONING_PROFILE, TestFlight, App Store, and public launch copy.

## Learning-loop rule

Every generated app trial must patch the substrate, not only the generated app. If a cleanup job removes residue from auth-account, paywall-purchases, sync-backend, settings-profile, onboarding, public-launch, copied docs, copied skills, or copied scripts, then the next pipeline patch must do one of these before the trial is considered learned:

1. update this manifest with the missed file/symbol/route/dependency;
2. update `scripts/new-app.sh` or its successor so the module is not copied unless selected;
3. update sanitizer substitutions/removals for the transitional copy-then-sanitize path;
4. update `scripts/forge-vnext-verifier.mjs` absence gates so the residue fails visibly next time;
5. add or update a fixture/test proving the no-repeat gate.

A generated app cleanup without a substrate patch is an incomplete trial.
