import 'package:flutter/material.dart';
import 'package:pinger/builders.dart';
import 'package:pinger/pinger.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // counter
  final Pinger<int> _counterPinger = Pinger();
  //
  int _count = 0;

  // this is for listening to the data of the notifier without any value
  void _listenToData(int? value){
    debugPrint('Notifier Updates $value');
  }

  @override
  void initState() {
    super.initState();
    _counterPinger.subscribe(_listenToData);
  }

  void _notifyCounter() {
    _count++;
    _counterPinger.ping(_count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            PingBuilder<int>(
              initialData: _count,
              pinger: _counterPinger,
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
        onPressed: _notifyCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }


  @override
  void dispose() {
    _counterPinger.dispose(_listenToData);
    super.dispose();
  }
}
