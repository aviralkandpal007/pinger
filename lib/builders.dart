import 'package:flutter/material.dart';
import 'package:pinger/pinger.dart';

/// The [Builder] works on the UI updates parts to fetch and update the UI
/// directly via the [Pinger] this will help update a clean maintainable
/// state for the Builders and will achieve a greater performance.
part 'widgets/ping_builder.dart';
part 'widgets/ping_consumer.dart';

/// The [PingBuilder] will fetch the data state from the [Pinger] and
/// with the help of these notifiers this will update the result in UI
class PingBuilder<T> extends StatelessWidget {
  const PingBuilder({
    super.key,
    required this.pinger,
    required this.builder,
    this.initialData,
  });

  /// [Pinger] for the current builder
  final Pinger<T> pinger;

  /// [builder] for UI creation area
  final Widget Function(BuildContext context, T? value) builder;

  /// [initialData] for showing the current data value until a value shows up
  final T? initialData;

  @override
  Widget build(BuildContext context) {
    /// The main builder class where all the required updates take place in the
    /// UI this will notify the builder method to update the UI when the new
    /// data pops in
    return _PingBuilderStateful<T>(
      pinger: pinger,
      builder: builder,
      initialData: initialData,
    );
  }
}
