# ⚡ Pinger

[![pub package](https://img.shields.io/pub/v/pinger.svg)](https://pub.dev/packages/pinger)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Pinger** is a lightweight state management toolkit for Flutter with three complementary patterns:

| Pattern | What it does |
|---------|-------------|
| **Pinger** — simple pub/sub | One source broadcasts typed data to many listeners |
| **Pingora** — ViewModel pattern | Scoped controller with auto-cleanup + fine-grained UI rebuilds |
| **Channeler** — global event bus | Decoupled cross-app communication via typed channels |

Each pattern is independent. Use one or all three — they are designed to work together.

---

## 📦 Installation

```yaml
dependencies:
  pinger: ^0.0.4
```

```sh
flutter pub get
```

---

## 📡 Flow 1: Pinger + PingBuilder

**Pinger** is a generic pub/sub class. You `subscribe` to receive updates, `ping` to broadcast new data, `unsubscribe` to stop listening, and `dispose` to shut it down permanently.

**PingBuilder** is a widget that wraps a `Pinger` and handles the `subscribe`/`unsubscribe` lifecycle automatically.

### Basic Pinger API

```dart
import 'package:pinger/pinger.dart';

final Pinger<int> counter = Pinger<int>();

void listener(int? value) => print('Got: $value');

counter.subscribe(listener);   // start listening
counter.ping(1);                // prints: Got: 1
counter.ping(2);                // prints: Got: 2
counter.unsubscribe(listener);  // stop listening
counter.dispose();              // permanently shut down
```

`Pinger` works in **any Dart class** — widgets, services, repositories, BLoCs:

```dart
class LoggerService {
  void start() => counterPinger.subscribe(_log);
  void _log(int? v) => print(v);
  void stop()  => counterPinger.unsubscribe(_log);
}
```

`forcePing` sends the update even when the value hasn't changed:

```dart
counterPinger.ping(42, forcePing: true);
```

### PingBuilder — automatic lifecycle

```dart
import 'package:pinger/builders.dart';

PingBuilder<int>(
  pinger: counterPinger,
  initialData: 0,
  builder: (context, value) => Text('$value'),
);
```

`PingBuilder` subscribes in `initState` and unsubscribes in `dispose` automatically. No manual lifecycle management needed.

### Putting it together

```dart
final Pinger<int> counterPinger = Pinger<int>();

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    counterPinger.subscribe(_onData);     // manual subscribe
  }

  void _onData(int? v) {
    if (v != null && mounted) setState(() => _value = v);
  }

  @override
  void dispose() {
    counterPinger.unsubscribe(_onData);   // manual unsubscribe
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('$_value'),                              // manual display
      PingBuilder<int>(                             // auto display
        pinger: counterPinger,
        builder: (ctx, v) => Text('$v'),
      ),
      ElevatedButton(
        onPressed: () => counterPinger.ping(_value + 1),
        child: const Text('+1'),
      ),
    ]);
  }
}
```

---

## 🧠 Flow 2: Pingora + PingoraScope + PingoraSelector

**Pingora** is the base class for ViewModels / Controllers. Extend it, add your own state and methods, and call `ping()` to notify listeners.

**PingoraScope** wraps a widget subtree — it creates the Pingora once and disposes it when the subtree is removed.

**PingoraSelector** subscribes to a Pingora and rebuilds only when a **selected portion** of the state changes.

`context.pingora<T>()` retrieves the scoped Pingora from the nearest `PingoraScope` ancestor.

### Step 1: Create a Pingora model

```dart
import 'package:pinger/pingora.dart';

class CounterModel extends Pingora {
  int count = 0;

  void increment() {
    count++;
    ping(); // notify all subscribers
  }
}
```

### Step 2: Scope with PingoraScope + listen with PingoraSelector

```dart
import 'package:pinger/pingora.dart';

PingoraScope<CounterModel>(
  create: () => CounterModel(),   // called once, disposed when removed
  child: Column(children: [
    PingoraSelector<CounterModel, int>(
      listenable: (ctx) => ctx.pingora<CounterModel>(),
      selector: (m) => m.count,                    // only this value is watched
      builder: (ctx, count) => Text('$count'),      // rebuilds only when count changes
    ),
    ElevatedButton(
      onPressed: () => context.pingora<CounterModel>().increment(),
      child: const Text('+1'),
    ),
  ]),
);
```

### context.pingora<T>() in detail

The extension on `BuildContext` finds the nearest `PingoraScope<T>` ancestor and returns its Pingora instance. Use it to `subscribe`, `unsubscribe`, or call any method on the model:

```dart
import 'package:pinger/pingora.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to call context.pingora<T>() after the first build
    context.pingora<CounterModel>().subscribe(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() { /* re-read model state */ });
  }

  @override
  void dispose() {
    // Must unsubscribe to prevent leaks
    try { context.pingora<CounterModel>().unsubscribe(_onUpdate); } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('${context.pingora<CounterModel>().count}');
  }
}
```

### Pingora API

| Method | Behaviour |
|--------|-----------|
| `subscribe(VoidCallback)` | Register a listener. Throws if already disposed. |
| `ping()` | Call all subscribed listeners. Throws if disposed. |
| `unsubscribe(VoidCallback)` | Remove a listener. Throws if disposed or listener never subscribed. |
| `dispose()` | Clear listeners and permanently disable. Further calls to subscribe/ping/unsubscribe throw. |

---

## 🌐 Flow 3: Channeler — Global Event Bus

**Channeler** is a singleton event bus. Define typed `Channel` constants, `initialize` them, then `subscribe`/`ping`/`unsubscribe` from anywhere — no direct references between sender and receiver.

### Define channels

```dart
import 'package:pinger/channeler/channeler.dart';

class MyChannels {
  static const snackbar = Channel<String>('snackbar');
  static const counter  = Channel<int>('counter');
}
```

### Initialize and subscribe

```dart
final Channeler bus = Channeler();      // singleton

bus.initialize(MyChannels.snackbar);
bus.initialize(MyChannels.counter);

bus.subscribe(MyChannels.snackbar, (msg) {
  if (msg != null) showSnackBar(msg);
});

bus.subscribe(MyChannels.counter, (v) {
  debugPrint('counter: $v');
});
```

### Ping from anywhere

```dart
Channeler().ping(MyChannels.snackbar, 'Hello!');
Channeler().ping(MyChannels.counter, 42);
```

### Clean up

```dart
bus.unsubscribe(MyChannels.snackbar, listener);
bus.disposeChannel(MyChannels.counter);   // removes channel + all listeners
```

### BuildContext extension

```dart
import 'package:pinger/channeler_extension.dart';

context.initChannel(MyChannels.snackbar);
context.subscribeChannel(MyChannels.snackbar, (msg) { });
context.pingChannel(MyChannels.snackbar, 'Hi');
context.unsubscribeChannel(MyChannels.snackbar, listener);
context.disposeChannel(MyChannels.snackbar);
```

---

## 🤔 Which flow should I use?

| Situation | Use |
|-----------|-----|
| A single value needs to update multiple widgets | **Pinger** + **PingBuilder** |
| A service/repository needs to push data into the UI | **Pinger** |
| A screen has complex state (form, multiple fields) | **Pingora** + **PingoraScope** + **PingoraSelector** |
| Two unrelated features need to communicate | **Channeler** |
| You want to show a snackbar from a repository | **Channeler** |
| You need fine-grained rebuild control for performance | **PingoraSelector** |

All three can be mixed freely in the same app:

```dart
Channeler().ping(MyChannels.userLoggedIn, 'alice');   // cross-cutting event
cartPinger.ping(cartItems);                            // localized state
PingoraScope<CheckoutModel>(                           // screen ViewModel
  create: () => CheckoutModel(),
  child: CheckoutScreen(),
);
```

---

## 📖 API Reference

### `Pinger<T>` — `package:pinger/pinger.dart`

| Member | Description |
|--------|-------------|
| `subscribe(PingerCallback<T?>)` | Register a listener. Throws if disposed. |
| `ping(T? data, {bool forcePing})` | Broadcast to all listeners. Skips if data unchanged unless `forcePing: true`. Throws if disposed. |
| `unsubscribe(PingerCallback<T?>)` | Remove a listener. Throws if disposed or listener never subscribed. |
| `dispose()` | Clear listeners and permanently disable. |
| `T? get data` | Current held value. |

### `PingBuilder<T>` — `package:pinger/builders.dart`

| Param | Type | Description |
|-------|------|-------------|
| `pinger` | `Pinger<T>` | The pinger to subscribe to. |
| `builder` | `Widget Function(BuildContext, T?)` | UI builder called with each new value. |
| `initialData` | `T?` | Default value shown before the first ping. |

### `Pingora` — `package:pinger/pingora.dart`

| Method | Description |
|--------|-------------|
| `subscribe(VoidCallback)` | Register a listener. Throws if disposed. |
| `ping()` | Call all listeners. Throws if disposed. |
| `unsubscribe(VoidCallback)` | Remove a listener. Throws if disposed or never subscribed. |
| `dispose()` | Clear listeners and permanently disable. |

### `PingoraScope<T>` — `package:pinger/pingora/pingora_scope.dart`

| Param | Description |
|-------|-------------|
| `create` | Factory called once to create the Pingora instance. |
| `child` | Widget subtree that receives the Pingora via `context.pingora<T>()`. |

### `PingoraSelector<T, S>` — `package:pinger/pingora/pingora_selector.dart`

| Param | Type | Description |
|-------|------|-------------|
| `listenable` | `T Function(BuildContext)` | Retrieves the Pingora from the widget tree. |
| `selector` | `S Function(T)` | Extracts the state slice to monitor. |
| `builder` | `Widget Function(BuildContext, S)` | UI builder, called only when the selected value changes. |

### `PingoraExtension` — `package:pinger/pingora.dart` (auto-exported)

| Method | Description |
|--------|-------------|
| `pingora<T>()` | Returns the nearest `Pingora` of type `T` from an ancestor `PingoraScope`. Throws if not found. Call `.subscribe()`, `.ping()`, `.unsubscribe()`, `.dispose()` on the result. |

### `Channel` — `package:pinger/channeler/channeler.dart`

| Constructor | Description |
|-------------|-------------|
| `Channel(String name)` | Creates a typed channel with a unique name. |

### `Channeler` — `package:pinger/channeler/channeler.dart`

| Method | Description |
|--------|-------------|
| `initialize<T>(Channel<T>)` | Register a channel (required before use). |
| `subscribe<T>(Channel<T>, ChannelerCallback<T>)` | Listen for events on a channel. |
| `ping<T>(Channel<T>, T?)` | Emit data to all channel subscribers. |
| `unsubscribe<T>(Channel<T>, ChannelerCallback<T>)` | Remove a listener from a channel. |
| `disposeChannel<T>(Channel<T>)` | Remove a channel and all its listeners. |

### `ChannelerExtension` — `package:pinger/channeler_extension.dart`

Shorthand methods on `BuildContext`: `context.channeler`, `context.initChannel()`, `context.subscribeChannel()`, `context.pingChannel()`, `context.unsubscribeChannel()`, `context.disposeChannel()`.

---

## ⚡ Performance notes

- **PingBuilder** unsubscribes automatically when removed from the tree — no leaks.
- **PingoraSelector** only rebuilds when the selected state slice changes — prevents large subtree rebuilds.
- **`forcePing: false`** (default) skips notifications when the value hasn't changed.
- **Always unsubscribe** in `dispose()` — failing to do so causes dead listeners that prevent garbage collection.
- **Channeler** is a singleton — the factory always returns the same instance.

---

## 🖥️ Running the examples

```sh
cd example
flutter run
```

Three self-contained screens show each flow in action.

---

## 📄 License

MIT License — see [LICENSE](LICENSE).

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/aviralkandpal007">aviralkandpal007</a></sub>
</div>
