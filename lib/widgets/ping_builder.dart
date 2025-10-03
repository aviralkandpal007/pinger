part of '../builders.dart';

/// The [_PingBuilderStateful] is the real implementation behind the
/// [PingBuilder] class, as that class points to this one so that actual
/// implementation of the pinger works in this end by subscribing to the
/// [Pinger] and then when disposing it will automatically dispose the [Pinger]
class _PingBuilderStateful<T> extends StatefulWidget {
  const _PingBuilderStateful({
    required this.pinger,
    required this.builder,
    this.initialData,
  });

  /// The [pinger] listens to the value of the [Pinger] it has been provided
  /// and while it will listen, it will update the UI as soon as new value will
  /// triggered
  final Pinger<T> pinger;

  /// The [builder] function give back a space to create a UI that will be updated
  /// when the pinger will update any new value
  final Widget Function(BuildContext context, T? value) builder;

  /// The [initialData] is to insert any data that the user want to be shown as
  /// a default value until a new value comes in
  final T? initialData;

  @override
  _PingBuilderState<T> createState() => _PingBuilderState<T>();
}

class _PingBuilderState<T> extends State<_PingBuilderStateful<T>> {
  /// For maintaining the current value in the [_PingBuilderState] so that
  /// when the updates comes we can update the UI according to the new UI
  T? _currentValue;

  @override
  void initState() {
    super.initState();

    /// Providing the initial data to the widget until any new value is returned
    /// to in the UI
    _currentValue = widget.initialData ?? widget.pinger.data;

    /// This is current pinger subscription for the current widget
    widget.pinger.subscribe(_onData);
  }

  /// This will update the data when the new notification pops through the
  /// provider pinger in the widget
  void _onData(T? value) {
    // check if the widget is mounted if yes update the current value of
    // the data
    if (mounted) {
      setState(() {
        _currentValue = value;
      });
    }
  }

  @override
  void didUpdateWidget(_PingBuilderStateful<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // when the did update widget is called we will update the notifiers as
    // required
    if (oldWidget.pinger != widget.pinger) {
      // first we will remove the old pinger subscription
      oldWidget.pinger.unsubscribe(_onData);
      // then we will update the new value of the data if coming otherwise
      // we will simply set the old value of the pinger that will be available
      _currentValue = widget.initialData ?? widget.pinger.data;
      // we will update the newer pinger to get the value of the data in case
      // still new values will be required
      widget.pinger.subscribe(_onData);
    }
  }

  @override
  void dispose() {
    // removing the subscription data when we will want to remove the widget
    // from the widget tree
    widget.pinger.unsubscribe(_onData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // this is the builder function that will update the builder method
    return widget.builder(context, _currentValue);
  }
}
