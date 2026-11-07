---
heroImage: "../../assets/template_images/auth-flow.png"
title: "Login and Auth Flow"
description: "Flutter login and authentication template that connects splash and session restore, sign in, sign up with password strength, email verification, forgot and reset password, a signed-in home, and account settings. Auth state drives routing. Flutter SDK only, ChangeNotifier state, with a repository you can swap for Supabase or Firebase."
summary: "Sign in, sign up, email verification, password reset and account settings."
type: full-app
path: /templates/auth_flow
code_dir: templates/auth_flow
tags: ["auth", "login", "sign up", "password reset", "email verification", "session", "supabase", "firebase", "changenotifier", "full app"]
---

A complete login flow you can run and copy, rather than a set of separate screens. Every screen navigates, and which screen you see comes from the auth state, so signing out or losing a session always lands in the right place.

The demo account is shown on the sign-in screen: `demo@example.com` with the password `Latchkey-2048`.

## What's included

- **Splash and session restore.** Shown until the stored session is checked. If the check fails, you can retry or continue to sign in. If the session stream itself reports an error later, a warning appears and nobody is signed out.
- **Sign in.** Wrong password and unknown email give the same message, so the form can't reveal who has an account. The email stays filled in and focus returns to the password.
- **Sign up.** A live strength meter drawn as a key that grows a tooth per level, with the level written out and each rule listed. A taken email offers "Sign in instead" and carries the address over.
- **Email verification.** Six boxes backed by one text field, so paste and autofill work. Wrong codes clear for retyping. Expired codes can be replaced at once, and otherwise resending has a 30 second cooldown. An unverified session can only reach this screen.
- **Forgot and reset password.** The confirmation reads the same whether or not the account exists. Reset links work once, and a newer link replaces an older one.
- **Signed-in home.** A session card and a marked place to start your own app.
- **Account settings.** Change password, theme preference (System, Light, Dark), sign out, and delete account with password confirmation.

Colors come from `Theme.of(context).colorScheme`, generated from one seed color, so the flow works in light and dark. "System" follows the theme of the surrounding `MaterialApp`. Forms use autofill hints and input actions that move between text fields. Layouts were tested at 320px wide with 200% text and at 1024x768.

## What's simulated

Nothing here talks to a server. `FakeAuthRepository` keeps everything in memory, and passwords are stored as plain text there.

- No emails are sent. The verification code and the reset link appear in dashed panels marked DEMO.
- A reset link isn't a real deep link. "Open reset link" acts as if one had been tapped.
- Latency, wrong passwords, taken emails, expired codes and expired sessions are all simulated. The DEMO panels can also fail the next request, expire a code, link or session, and relaunch the app.
- Nothing persists. Reloading the page clears new accounts and the session, and the theme preference is not saved.
- There is no rate limiting or lockout. Those belong on your server.
- Deleting the demo account removes it until you press "Restore demo account".

## Structure

```
auth_flow/
  app.dart      AuthFlowApp, the theme shell and the nested Navigator
  models/       AuthUser, AuthFailure, AuthEvent, PasswordStrength
  data/         AuthRepository, the swap point, FakeAuthRepository, AuthDemoControls
  state/        AuthController, AuthNavigation, AppearanceController, AuthScope, SubmitMixin
  screens/      One file per screen
  widgets/      Theme, form layout, fields, strength meter, code input, demo panels
```

All imports are relative, so you can copy the folder into any project. Place the widget anywhere below a `MaterialApp`:

```dart
MaterialApp(home: const AuthFlowApp());
```

### How routing works

`AuthRepository.events` is the only way session state reaches the app. A sign-in form doesn't navigate when it succeeds. `AuthController` hears the event and updates its status, and `AuthNavigation.stack` is worked out from that. The Navigator only renders the list, and nothing pushes routes imperatively.

- The first entry comes from the status: splash, sign in, verification or home. When it changes, everything opened above it is dropped. That is why sign-out or expiry on a nested screen lands on sign in.
- Password recovery is not one of those roots. It is kept apart from the status and always added last, so it opens above whatever is showing. If it were a root, swapping to it would put it underneath any route already open, and nobody would see it. It stays on top if the session ends underneath it, and cancelling returns to the previous screen.

If you add a dialog or sheet, pass `useRootNavigator: false`. On the host's root navigator it would stay open after sign-out and cover the recovery screen.

## Connecting Supabase or Firebase

The UI only talks to the `AuthRepository` interface in `data/auth_repository.dart`. Each method there has a comment marked `SWAP POINT` naming the calls to use, and `data/default_repository.dart` is the only file that names the fake.

1. Create a class that implements `AuthRepository`.
2. Translate provider errors into `AuthFailure`. The screens react to its codes.
3. Report session changes through `events`, not return values. An error on that stream shows a warning and changes nothing else, so add `SessionEnded` when a session really ends.
4. Implement `dispose`, and release your subscriptions there.
5. Return your repository from `data/default_repository.dart`, in place of the fake. The app creates it and disposes it:

```dart
import 'auth_repository.dart';
import 'supabase_auth_repository.dart';

AuthRepository createDefaultRepository() =>
    SupabaseAuthRepository(Supabase.instance.client);
```

6. Delete `data/fake_auth_repository.dart`.

`AuthFlowApp(repository: ...)` overrides the default for one app instance, which is useful in tests. A repository passed that way stays yours to dispose, and it doesn't replace step 5.

The demo panels only appear when the repository implements `AuthDemoControls`, so they disappear with a real one and the app compiles with them left in. To remove that code as well:

1. Delete `data/auth_demo_controls.dart` and `widgets/demo_panels.dart`.
2. In each of the screens `sign_in`, `verify_email`, `forgot_password`, `reset_password`, `change_password` and `home`, remove the `demo_panels.dart` import and the panel. In `home_screen.dart` that is the `demo` constant and the two places that show it, with the gaps before them.
3. In `sign_in_screen.dart`, also remove the `auth_demo_controls.dart` import and the `_fill` method. In `verify_email_screen.dart`, remove `_useCode`.
4. In `state/auth_scope.dart`, remove the import, the `demo` field and its constructor parameter.
5. In `app.dart`, remove the import, the `_demo` field, its assignment with the `repository` local above it, `?_demo` in the merged listenable, and `demo: _demo`.

These notes are a starting point. The adapters below have not been written or run as part of this template.

### Supabase

- Map `onAuthStateChange` to `events`. `passwordRecovery` becomes `PasswordRecoveryStarted`. A `signedOut` you didn't request becomes `SessionEnded(SessionEndReason.expired)`.
- For code based verification, add `{{ .Token }}` to the confirm signup email template, then use `verifyOTP(type: OtpType.signup, ...)` and `resend(type: OtpType.signup, ...)`.
- With email confirmation on, `signUp` returns no session and `signInWithPassword` fails with `email_not_confirmed`. Your repository has to remember the pending email and emit an unverified `AuthUser` so the verification screen opens.
- Set up deep links and pass `redirectTo` to `resetPasswordForEmail`. The recovery event signs the user in, so `completePasswordReset` is `updateUser` and the token can be ignored. Cancelling leaves that session in place, so sign out on cancel if you don't want it.
- Clients can't delete users. `deleteAccount` has to call an Edge Function that uses the service role key.
- There is no built-in check of the current password. Confirm it with `signInWithPassword` before `updateUser`.

### Firebase

- Map `authStateChanges()` to `events`, and `restoreSession` to its first value.
- There is no recovery event. Handle the reset deep link yourself, for example with the `app_links` package, and add `PasswordRecoveryStarted` with the link's `oobCode` as the token. `completePasswordReset` is then `confirmPasswordReset`. Firebase doesn't sign the user in after this, which the app already handles.
- Email verification is link based, not code based. Either replace the code input on `VerifyEmailScreen` with an "I've verified" button that calls `currentUser.reload()`, or send your own codes from a Cloud Function.
- `changePassword` and `deleteAccount` need `reauthenticateWithCredential` first.

### Also worth doing

- Persist the theme preference. `AppearanceController` marks the spot.
- Decide what signing out should do offline. The template keeps you signed in and shows a retry, but on a shared device you may prefer to clear the local session anyway.
- Enforce your password policy on the server. `PasswordStrength` is only feedback.
