part of '../builders.dart';

class PingSelector<T extends Pingora, S> extends StatefulWidget {
  final T Function(BuildContext) listenable;
  final S Function(T) selector;
  final Widget Function(BuildContext, S) builder;

  const PingSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
  });

  @override
  State<PingSelector<T, S>> createState() => _PingSelectorState<T, S>();
}

class _PingSelectorState<T extends Pingora, S>
    extends State<PingSelector<T, S>> {
  late S _value;
  late T _pingora;

  void _listener() {
    final newValue = widget.selector(_pingora);
    debugPrint('New Value $newValue');
    if (newValue != _value) {
      setState(() => _value = newValue);
    }
  }

  @override
  void initState() {
    super.initState();
    _pingora = widget.listenable(context);
    _value = widget.selector(_pingora);
    _pingora.subscribe(_listener);
  }

  @override
  void dispose() {
    _pingora.unsubscribe(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value);
  }
}
