## Pinger

# Pinger<T> is a lightweight state management utility for Flutter, designed to broadcast data updates across your app. It allows both widgets and non-widget classes to listen to data changes without depending on heavy state management solutions.

# Think of it as a simple pub-sub (publish/subscribe) system that integrates smoothly into your Flutter project.

## ✨ Features

# 🔄 Subscribe to real-time data updates from anywhere (widgets or services).

# 📡 Broadcast (ping) new values to all active listeners.

# 🧹 Simple subscription and unsubscription management.

# 🚀 Minimal, fast, and boilerplate-free.

# ❌ Disposables support (stop receiving updates once disposed).

## 🚀 Usage
# 1. Create a Pinger
#    final Pinger<int> counterPinger = Pinger<int>();

# 2. Subscribe to updates
#    counterPinger.subscribe((value) {
#    print("Counter updated: $value");
#    });

# 3. Send updates (ping values)
#    counterPinger.ping(1); // Prints: Counter updated: 1
#    counterPinger.ping(2); // Prints: Counter updated: 2

# 4. Unsubscribe when not needed
#    counterPinger.unsubscribe(listener);

# 5. Dispose when finished
#    counterPinger.dispose();
