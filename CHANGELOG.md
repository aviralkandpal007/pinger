## 0.0.4

### ✨ New

- **PingoraExtension** — `context.pingora<T>()` extension on `BuildContext` for clean, type-safe access to scoped Pingora controllers from any descendant widget. Works automatically with `PingoraScope`.
- **PingoraInherited** — made public (was `_PingoraInherited`) so the context extension and external code can reference it.
- **Lifecycle logging** — both `Pinger` and `Pingora` now log all lifecycle events (`initialized`, `subscribed`, `pinged`, `unsubscribed`, `disposed`) via `dart:developer`'s `log()`. View output with `flutter logs` or your IDE's debug console.

### 🔧 Fixed

- **Pingora disposed assertions** — `subscribe()`, `unsubscribe()`, and `ping()` now assert `!_disposed` before executing (matching `Pinger`'s behaviour). `unsubscribe()` also asserts the listener was actually subscribed.
- **PingoraSelector initState crash** — moved `widget.listenable(context)` from `initState` to `didChangeDependencies`, fixing the "dependOnInheritedWidgetOfExactType called before initState completed" crash when `listenable` uses `context.pingora<T>()`. Also added `didUpdateWidget` handling for Pingora changes and proper dispose guard.
- **Duplicate ChannelerExtension** — removed the broken duplicate `ChannelerExtension` from `channel.dart` that conflicted with the real one in `channeler_extension.dart`.
- **Barrel file** — created `lib/pingora.dart` (was missing) so `package:pinger/pingora.dart` works as a single import for all Pingora classes.

### 📚 Docs & Examples

- **Examples consolidated** — merged from 5 separate screens into 3 focused flows:
  - Flow 1: Pinger + PingBuilder (manual + auto lifecycle side by side)
  - Flow 2: PingoraScope + PingoraSelector + context.pingora() (ViewModel pattern end to end)
  - Flow 3: Channeler (global event bus)
- **Example bug fixes** — `PingoraExample` now wraps the screen with `PingoraScope` and uses a separate `_CounterBody` widget so `didChangeDependencies` runs after the scope is mounted.
- **README rewritten** — each flow has a single cohesive section with code snippets that match the actual API. Added API reference tables for all classes. Added "Which flow should I use?" decision table.
