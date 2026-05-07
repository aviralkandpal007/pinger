import 'package:flutter/material.dart';
import 'pingora.dart';

/// The [PingoraSelector] widget is a highly optimized reactive builder that
/// listens to a specific [Pingora] controller and rebuilds only when a
/// selected portion of the state changes. This helps avoid unnecessary UI
/// rebuilds and improves performance by isolating updates to only required
/// state slices instead of rebuilding the entire widget tree.
class PingoraSelector<T extends Pingora, S> extends StatefulWidget {
  /// A function that provides the instance of the [Pingora] controller
  /// from the current [BuildContext]. This allows the selector to access
  /// the correct scoped controller without relying on global instances.
  final T Function(BuildContext context) listenable;

  /// A selector function that extracts a specific piece of state from the
  /// [Pingora] controller. Only the returned value is monitored for changes,
  /// ensuring that the widget rebuilds only when this selected state changes.
  final S Function(T controller) selector;

  /// A builder function that constructs the UI based on the selected value.
  /// This function is only triggered when the selected state changes, which
  /// improves performance by preventing unnecessary rebuilds of unchanged UI.
  final Widget Function(BuildContext context, S value) builder;

  /// Creates a [PingoraSelector] widget that listens to a specific portion
  /// of a [Pingora] controller and rebuilds efficiently when the selected
  /// state changes based on the provided selector function logic.
  const PingoraSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
  });

  @override
  State<PingoraSelector<T, S>> createState() => _PingoraSelectorState<T, S>();
}

/// Internal state class responsible for managing subscription lifecycle,
/// tracking selected state values, and rebuilding the widget only when
/// the selected portion of the [Pingora] controller changes over time.
class _PingoraSelectorState<T extends Pingora, S>
    extends State<PingoraSelector<T, S>> {
  /// Stores the current instance of the [Pingora] controller that this
  /// selector is listening to. Initialised in [didChangeDependencies]
  /// rather than [initState] because [widget.listenable] typically calls
  /// `dependOnInheritedWidgetOfExactType`, which is only valid after the
  /// widget has been fully mounted into the element tree.
  late T _pingora;

  /// Holds the currently selected value extracted from the controller
  /// using the selector function. This value is compared on every update
  /// to determine whether the UI should rebuild or remain unchanged.
  late S _value;

  /// Tracks whether the initial subscription has been set up so that
  /// [didChangeDependencies] only performs it once.
  bool _initialized = false;

  /// Listener callback that gets triggered whenever the [Pingora] controller
  /// emits a new update. It recalculates the selected value and compares it
  /// with the previous value to decide whether a UI rebuild is required.
  void _listener() {
    final newValue = widget.selector(_pingora);

    /// Only rebuilds the widget if the selected value has changed. This
    /// prevents unnecessary UI updates and ensures efficient rendering
    /// by minimizing rebuild operations inside Flutter’s widget tree.
    if (newValue != _value) {
      setState(() => _value = newValue);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Intentionally empty — the inherited-widget lookup in
    /// [widget.listenable] must not run until the widget tree is
    /// fully mounted. See [didChangeDependencies].
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      /// Retrieves the controller instance using the provided listenable
      /// function. Safe now because the widget is fully mounted and
      /// inherited-widget dependencies can be resolved.
      _pingora = widget.listenable(context);

      /// Initializes the selected value immediately so the UI has an
      /// initial valid state before any updates or subscriptions occur.
      _value = widget.selector(_pingora);

      /// Subscribes to the Pingora updates so this widget can reactively
      /// respond to state changes and rebuild only when necessary changes
      /// are detected through the selector logic.
      _pingora.subscribe(_listener);
    }
  }

  @override
  void didUpdateWidget(PingoraSelector<T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// If the [listenable] function produces a different Pingora instance
    /// (e.g. because the widget was rebuilt with different parameters),
    /// unsubscribe from the old one and subscribe to the new one.
    final newPingora = widget.listenable(context);
    if (newPingora != _pingora) {
      _pingora.unsubscribe(_listener);
      _pingora = newPingora;
      _value = widget.selector(_pingora);
      _pingora.subscribe(_listener);
    }
  }

  @override
  void dispose() {
    /// Removes the listener from the [Pingora] controller to prevent
    /// memory leaks, dangling callbacks, or unwanted updates after
    /// the widget has been removed from the widget tree permanently.
    if (_initialized) {
      _pingora.unsubscribe(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Builds the UI using only the selected portion of state. This
    /// ensures minimal rebuild scope and allows highly optimized
    /// reactive UI updates based on fine-grained state selection logic.
    return widget.builder(context, _value);
  }
}
