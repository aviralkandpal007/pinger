import 'package:flutter/material.dart';
import 'package:pinger/pingora/pingora_selector.dart';
import 'pingora_model_example.dart';

/// Global instance of our Pingora model so widgets can access it.
final PingoraModelExample counterViewmodel = PingoraModelExample();

/// Demonstrates [PingoraSelector] — a widget that rebuilds only when the
/// selected portion of state changes. This avoids unnecessary rebuilds and
/// keeps the UI performant.
///
/// [PingoraSelector] takes three required parameters:
/// - [listen]: A function that retrieves the [Pingora] controller from context
/// - [selector]: A function that extracts only the state slice you care about
/// - [builder]: The UI builder that receives the selected value
class PingoraSelectorExample extends StatelessWidget {
  const PingoraSelectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('PingoraSelector Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            // Only the selected `count` value is monitored.
            // When count changes -> widget rebuilds.
            // Other state changes in the model are IGNORED.
            PingoraSelector<PingoraModelExample, int>(
              listenable: (_) => counterViewmodel,
              selector: (pingora) => pingora.count,
              builder: (context, value) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counterViewmodel.increaseCounter(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
