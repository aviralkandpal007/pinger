Pinger

Pinger<T> is a lightweight state management utility for Flutter.
It broadcasts data updates across your app so that both widgets and non-widget classes can listen to changes without relying on heavy state management libraries.

Think of it as a simple pub-sub (publish/subscribe) mechanism that integrates seamlessly into your Flutter project.

✨ Features

🔄 Subscribe to real-time data updates from anywhere (widgets or services).

📡 Broadcast (ping) new values to all active listeners.

🧹 Simple subscription and unsubscription management.

🚀 Minimal, fast, and boilerplate-free.

❌ Disposables support (stop receiving updates once disposed).

🚀 Usage
1. Create a Pinger
   final Pinger<int> counterPinger = Pinger<int>();

2. Subscribe to updates
   counterPinger.subscribe((value) {
   print("Counter updated: $value");
   });

3. Send updates (ping values)
   counterPinger.ping(1); // Prints: Counter updated: 1
   counterPinger.ping(2); // Prints: Counter updated: 2

4. Unsubscribe when not needed
   counterPinger.unsubscribe(listener);

5. Dispose when finished
   counterPinger.dispose();

⚡ Example with Flutter Widget
class CounterWidget extends StatefulWidget {
const CounterWidget({super.key});

@override
State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
int _counter = 0;

@override
void initState() {
super.initState();
counterPinger.subscribe((value) {
if (value != null) {
setState(() => _counter = value);
}
});
}

@override
void dispose() {
counterPinger.unsubscribe((value) {}); // cleanup
super.dispose();
}

@override
Widget build(BuildContext context) {
return Column(
children: [
Text("Counter: $_counter"),
ElevatedButton(
onPressed: () => counterPinger.ping(_counter + 1),
child: const Text("Increment"),
),
],
);
}
}

📖 API Reference
subscribe(PingerCallback<T?> listener)

Registers a new listener for updates.

ping(T? data, {bool forcePing = false})

Broadcasts a new value to all active listeners.

forcePing allows sending even if the value hasn’t changed.

unsubscribe(PingerCallback<T?> listener)

Removes a previously subscribed listener.

dispose()

Clears all listeners and disables the Pinger.

🔮 When to use Pinger?

When you want lightweight state sharing between services and widgets.

When you need real-time updates without complex libraries like provider or bloc.

When performance and simplicity matter.

📜 License

This project is open-source under the MIT License.