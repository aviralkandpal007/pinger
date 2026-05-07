import 'package:flutter/widgets.dart';
import 'pingora.dart';

/// Internal inherited widget used for exposing the [Pingora]
/// instance down the widget tree while allowing widgets to
/// access the controller using Flutter context extensions.
class _PingoraInherited<T extends Pingora> extends InheritedWidget {
  /// Current scoped controller instance associated with the
  /// active widget subtree wrapped by the [PingoraScope].
  final T pingora;

  const _PingoraInherited({required this.pingora, required super.child});

  @override
  bool updateShouldNotify(_) => false;
}

/// Widget responsible for automatically creating and disposing
/// a [Pingora] controller together with the widget lifecycle.
/// This allows developers to scope controllers to a screen,
/// component, or any subtree without manual memory management.
class PingoraScope<T extends Pingora> extends StatefulWidget {
  /// Factory callback responsible for creating the controller
  /// instance when the widget gets inserted into the widget
  /// tree during the initialization lifecycle execution phase.
  final T Function() create;

  /// Child subtree that will receive access to the scoped
  /// [Pingora] controller instance through inherited context
  /// lookup methods and extension helper utilities.
  final Widget child;

  const PingoraScope({super.key, required this.create, required this.child});

  @override
  State<PingoraScope<T>> createState() => _PingoraScopeState<T>();
}

class _PingoraScopeState<T extends Pingora> extends State<PingoraScope<T>> {
  /// Controller instance scoped to this widget subtree and
  /// automatically disposed once this scope widget gets
  /// permanently removed from the active widget hierarchy.
  late final T pingora;

  @override
  void initState() {
    super.initState();

    pingora = widget.create();
  }

  @override
  void dispose() {
    pingora.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PingoraInherited<T>(pingora: pingora, child: widget.child);
  }
}
