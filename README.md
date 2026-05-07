# ⚡ Pinger

[![pub package](https://img.shields.io/pub/v/pinger.svg)](https://pub.dev/packages/pinger)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Pinger** is a lightweight, high-performance state management toolkit for Flutter. It provides three complementary state communication patterns — **Pinger**, **Pingora**, and **Channeler** — that work together to handle everything from simple widget-to-widget updates to cross-application event broadcasting.

> **Think of Pinger as a toolbox for state reactivity.**  
> Each tool has a specific job. Pick the right one for the task.

---

## 📋 Table of Contents

- [Why Pinger?](#-why-pinger)
- [Installation](#-installation)
- [The Three Flows](#-the-three-flows)
  - [Flow 1: Pinger — Simple Pub/Sub](#-flow-1-pinger--simple-pubsub)
  - [Flow 2: Pingora — ViewModel / Controller Pattern](#-flow-2-pingora--viewmodel--controller-pattern)
  - [Flow 3: Channeler — Global Event Bus](#-flow-3-channeler--global-event-bus)
- [Which Flow Should I Use?](#-which-flow-should-i-use)
- [API Reference](#-api-reference)
- [Performance Considerations](#-performance-considerations)
- [Examples](#-examples)
- [License](#-license)

---

## 🎯 Why Pinger?

| Concern | Typical Solution | Pinger Approach |
|---------|-----------------|-----------------|
| Sharing state between widgets | Provider, Riverpod, BLoC | `Pinger<T>` + `PingBuilder<T>` |
| ViewModel / Controller lifecycle | GetX, MobX | `Pingora` + `PingoraScope` |
| Cross-app event broadcasting | EventBus, signals | `Channeler` + `Channel<T>` |
| Bundle size / complexity | Large frameworks | **Minimal** — ~400 lines total |

**Pinger is NOT a replacement for Provider or BLoC on large apps.**  
It IS a fast, minimal alternative when you need reactivity without ceremony.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  pinger: ^0.0.3
```

Then run:

```sh
flutter pub get
```

---

## 🔧 The Three Flows

---

### 📡 Flow 1: Pinger — Simple Pub/Sub

**Purpose:** Broadcast data from one source to multiple listeners (widgets, services, etc.).

**Best for:**
- Sharing a single value across multiple widgets
- Updating UI from background services / repositories
- Simple counter, toggle, or text field state

#### How it works

```
┌─────────────┐     ping(42)     ┌──────────────────┐
│  Any Sender  │ ───────────────► │   Pinger<int>    │
└─────────────┘                   │  (radio station) │
                                  └────────┬─────────┘
                                           │
                          ┌────────────────┼────────────────┐
                          ▼                ▼                ▼
                     ┌──────────┐   ┌──────────┐   ┌──────────┐
                     │ Widget A │   │ Widget B │   │ Service  │
                     │(subscribe)│  │(subscribe)│  │(subscribe)│
                     └──────────┘   └──────────┘   └──────────┘
```

#### Basic usage

```dart
import 'package:pinger/pinger.dart';

// 1. Create a pinger (generic over any type)
final Pinger<int> counter = Pinger<int>();

// 2. Subscribe to updates
void listener(int? value) => print('Got: $value');
counter.subscribe(listener);

// 3. Ping new data — all subscribers are notified
counter.ping(1); // prints: Got: 1
counter.ping(2); // prints: Got: 2

// 4. Unsubscribe when done (critical for memory safety!)
counter.unsubscribe(listener);

// 5. Dispose when the pinger is no longer needed
counter.dispose();
```

#### Using PingBuilder (no manual lifecycle)

```dart
import 'package:pinger/pinger.dart';
import 'package:pinger/builders.dart';

final Pinger<String> messagePinger = Pinger<String>();

// PingBuilder auto-subscribes and auto-unsubscribes — no StatefulWidget needed!
PingBuilder<String>(
  pinger: messagePinger,
  initialData: 'Waiting...',               // shown until first ping
  builder: (context, value) {
    return Text(value ?? 'No data');
  },
);

// Later, anywhere in your app:
messagePinger.ping('Hello from service!');  // UI updates automatically
```

> **💡 Key point:** `Pinger` works in **any Dart class** — not just widgets.  
> Services, repositories, BLoCs, and plain Dart objects can all subscribe.

#### `forcePing` — when you need to notify even if the value hasn't changed

```dart
counterPinger.ping(42, forcePing: true);
```

---

### 🧠 Flow 2: Pingora — ViewModel / Controller Pattern

**Purpose:** Encapsulate business logic + state into a disposable controller, then selectively rebuild parts of the UI that depend on specific state slices.

**Best for:**
- Screen-level ViewModels / Controllers
- Forms with multiple fields
- Complex pages where you want fine-grained rebuild control

#### How it works

```
┌──────────────────────────────────────────────────┐
│                  PingoraScope                     │
│  ┌────────────────────────────────────────────┐  │
│  │             PingoraModel (extends Pingora)  │  │
│  │  ┌─────────┐  ┌─────────┐  ┌───────────┐  │  │
│  │  │ count   │  │ loading │  │ userName  │  │  │
│  │  └─────────┘  └─────────┘  └───────────┘  │  │
│  └────────────────────────────────────────────┘  │
│         │           │                             │
│         ▼           ▼                             │
│  ┌──────────┐ ┌──────────┐                        │
│  │Selector A│ │Selector B│  (rebuild only when    │
│  │ (count)  │ │(userName)│   the selected value   │
│  └──────────┘ └──────────┘   changes!)            │
└──────────────────────────────────────────────────┘
```

#### Step 1: Create a Pingora model

```dart
import 'package:pinger/pingora.dart';

class CounterModel extends Pingora {
  int count = 0;

  void increment() {
    count++;
    ping(); // ⚡ notify all subscribed listeners
  }

  void reset() {
    count = 0;
    ping();
  }
}
```

#### Step 2: Scope the model lifecycle with PingoraScope

```dart
import 'package:pinger/pingora/pingora_scope.dart';
import 'package:pinger/pingora/pingora_selector.dart';

PingoraScope<CounterModel>(
  create: () => CounterModel(),    // called once on init
  child: Column(
    children: [
      // Only rebuilds when `count` changes!
      PingoraSelector<CounterModel, int>(
        listenable: (ctx) => /* get your model */,
        selector: (model) => model.count,
        builder: (ctx, count) => Text('$count'),
      ),
      ElevatedButton(
        onPressed: () => /* model.increment() */,
        child: const Text('Increment'),
      ),
    ],
  ),
);
// CounterModel.dispose() is called automatically when PingoraScope leaves the tree
```

> **💡 Why PingoraSelector?**  
> With `setState`, the entire widget rebuilds. With `PingoraSelector`, only the
> widget that depends on `count` rebuilds. This gives you **opt-in granularity**
> without manually managing `StreamSubscription` or `ChangeNotifier` lists.

---

### 🌐 Flow 3: Channeler — Global Event Bus

**Purpose:** Send events between completely decoupled parts of your app without direct references.

**Best for:**
- Cross-screen communication (e.g., "user logged in", "settings changed")
- Global theming / locale changes
- Showing snackbars or dialogs from anywhere
- Feature-to-feature communication without imports

#### How it works

```
┌──────────┐  ping("theme")   ┌──────────────────┐  subscribe   ┌──────────┐
│Screen A   │ ───────────────► │    Channeler     │ ◄────────── │Screen B  │
│(settings) │                  │   (event bus)    │             │(listener)│
└──────────┘                   │                  │             └──────────┘
                               │  ┌────────────┐  │
┌──────────┐  ping("logout")   │  │ theme_chan │  │ subscribe   ┌──────────┐
│Auth Service│ ──────────────► │  │ notif_chan │  │ ◄────────── │Any Widget│
└──────────┘                   │  │ counter_chn│  │             └──────────┘
                               │  └────────────┘  │
┌──────────┐  ping("notify")   └──────────────────┘ subscribe   ┌──────────┐
│Repository│ ───────────────►                   ◄────────────── │Snackbar  │
└──────────┘                                                        UI     │
                                                                    └──────────┘
```

#### Step 1: Define your channels

```dart
import 'package:pinger/channeler/channeler.dart';

class AppChannels {
  static const themeChanged = Channel<String>('theme_changed');
  static const showSnackbar = Channel<String>('show_snackbar');
  static const userLoggedIn = Channel<String>('user_logged_in');
  static const counter = Channel<int>('counter');
}
```

#### Step 2: Initialize and subscribe

```dart
final Channeler bus = Channeler(); // singleton — always returns the same instance

// Initialize channels (required before use)
bus.initialize(AppChannels.showSnackbar);
bus.initialize(AppChannels.counter);

// Subscribe
void onSnackbar(String? msg) {
  if (msg != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
bus.subscribe(AppChannels.showSnackbar, onSnackbar);

void onCounter(int? value) {
  debugPrint('Counter updated: $value');
}
bus.subscribe(AppChannels.counter, onCounter);
```

#### Step 3: Ping from anywhere

```dart
// In a repository, service, or any widget:
Channeler().ping(AppChannels.showSnackbar, 'Data saved!');
Channeler().ping(AppChannels.counter, 42);
```

#### Step 4: Clean up

```dart
bus.unsubscribe(AppChannels.showSnackbar, onSnackbar);
bus.disposeChannel(AppChannels.counter); // removes channel + all listeners
```

#### Using the BuildContext Extension

```dart
import 'package:pinger/channeler_extension.dart';

// Inside any widget build method:
context.initChannel(AppChannels.themeChanged);
context.subscribeChannel(AppChannels.themeChanged, (theme) { /* ... */ });
context.pingChannel(AppChannels.themeChanged, 'dark');
context.unsubscribeChannel(AppChannels.themeChanged, listener);
context.disposeChannel(AppChannels.themeChanged);
```

> **💡 Key point:** The sender and receiver never import each other.  
> They only share the `Channel` constant. This eliminates circular dependencies
> and keeps your architecture clean.

---

## 🤔 Which Flow Should I Use?

| Scenario | Use This |
|----------|----------|
| A single value needs to update multiple widgets | **Pinger** + **PingBuilder** |
| A service needs to push data into the UI | **Pinger** (subscribe in service) |
| A screen has complex state (form, multiple fields) | **Pingora** + **PingoraScope** + **PingoraSelector** |
| You need fine-grained rebuild control for performance | **PingoraSelector** |
| Two unrelated widgets / features need to talk | **Channeler** |
| You want to show a snackbar from a repository | **Channeler** |
| You're already using Provider/BLOC but need a lightweight event bus | **Channeler** |

You can **mix all three** in the same app — they are designed to complement each other:

```dart
// Channeler for cross-cutting events
Channeler().ping(AppChannels.userLoggedIn, 'user_123');

// Pinger for localized state
shoppingCartPinger.ping(cartItems);

// Pingora for screen-level ViewModel
PingoraScope<CheckoutModel>(
  create: () => CheckoutModel(),
  child: CheckoutScreen(),
);
```

---

## 📖 API Reference

### `Pinger<T>` (package:pinger/pinger.dart)

| Method | Signature | Description |
|--------|-----------|-------------|
| `subscribe` | `void Function(PingerCallback<T?> listener)` | Register a listener for updates |
| `ping` | `void Function(T? data, {bool forcePing = false})` | Broadcast data to all listeners. Skips if data unchanged unless `forcePing: true` |
| `unsubscribe` | `void Function(PingerCallback<T?> listener)` | Remove a specific listener. Throws if listener was never subscribed |
| `dispose` | `void Function()` | Clear all listeners and disable the pinger permanently |
| `data` | `T? get` | Read the current held value without subscribing |

### `PingBuilder<T>` (package:pinger/builders.dart)

| Parameter | Type | Description |
|-----------|------|-------------|
| `pinger` | `Pinger<T>` | The pinger to subscribe to |
| `builder` | `Widget Function(BuildContext, T?)` | UI builder receiving the latest value |
| `initialData` | `T?` | Default value shown before the first ping |

### `Pingora` (package:pinger/pingora.dart)

| Method | Description |
|--------|-------------|
| `subscribe(VoidCallback)` | Register a listener |
| `unsubscribe(VoidCallback)` | Remove a listener |
| `ping()` | Notify all listeners |
| `dispose()` | Clear all listeners and disable |

### `PingoraScope<T>` (package:pinger/pingora/pingora_scope.dart)

| Parameter | Description |
|-----------|-------------|
| `create` | Factory that creates the Pingora instance (called once) |
| `child` | Widget subtree that can access the Pingora |

### `PingoraSelector<T, S>` (package:pinger/pingora/pingora_selector.dart)

| Parameter | Type | Description |
|-----------|------|-------------|
| `listenable` | `T Function(BuildContext)` | Function to retrieve the Pingora from context |
| `selector` | `S Function(T)` | Extract the specific state slice to monitor |
| `builder` | `Widget Function(BuildContext, S)` | UI builder, called only when the selected value changes |

### `Channel` (package:pinger/channeler/channeler.dart)

| Constructor | Description |
|-------------|-------------|
| `Channel(String name)` | Create a typed channel with a unique name |

### `Channeler` (package:pinger/channeler/channeler.dart)

| Method | Description |
|--------|-------------|
| `initialize<T>(Channel<T>)` | Register a channel (must be called before use) |
| `subscribe<T>(Channel<T>, ChannelerCallback<T>)` | Listen for events on a channel |
| `ping<T>(Channel<T>, T?)` | Emit data to all subscribers of a channel |
| `unsubscribe<T>(Channel<T>, ChannelerCallback<T>)` | Remove a listener from a channel |
| `disposeChannel<T>(Channel<T>)` | Remove the channel and all its listeners |

### `ChannelerExtension` (package:pinger/channeler_extension.dart)

All `Channeler` methods are available as `BuildContext` extensions:
`context.channeler`, `context.initChannel()`, `context.subscribeChannel()`,
`context.pingChannel()`, `context.unsubscribeChannel()`, `context.disposeChannel()`.

---

## ⚡ Performance Considerations

1. **PingBuilder vs manual subscribe:** `PingBuilder` is optimized — it unsubscribes automatically when removed from the tree, preventing memory leaks.

2. **PingoraSelector granularity:** By selecting only the state slice you need, you prevent large subtrees from rebuilding. Use this when you have complex screens with many independent state values.

3. **forcePing:** Defaults to `false`. The `ping()` method checks whether the new value differs from the current value before notifying listeners. Set `forcePing: true` only when you need to guarantee a notification (e.g., refresh triggers).

4. **Dispose discipline:** Always call `unsubscribe` or `dispose` when a listener or pinger is no longer needed. Failing to do so causes **dead listeners** that still hold references, preventing garbage collection.

5. **Channeler singleton:** The `Channeler` is a single global instance. Do not create multiple instances — the factory constructor always returns the same singleton.

---

## 🖥️ Examples

Run the example app to see all three flows in action:

```sh
cd example
flutter run
```

The example app includes:
- **Flow 1a:** Manual `Pinger` subscribe/ping/unsubscribe with a logging service
- **Flow 1b:** `PingBuilder` auto-management (no `StatefulWidget` needed)
- **Flow 2a:** `PingoraSelector` — optimized rebuilds with selected state
- **Flow 2b:** `PingoraScope` — auto-created and auto-disposed ViewModel lifecycle
- **Flow 3:** `Channeler` — decoupled event bus with typed channels

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/aviralkandpal007">aviralkandpal007</a></sub>
</div>
