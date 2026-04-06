import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Increments whenever a global session invalidation event occurs.
///
/// Consumers can watch this value to re-check authentication state.
final sessionInvalidationProvider =
    NotifierProvider<SessionInvalidationNotifier, int>(
  SessionInvalidationNotifier.new,
);

class SessionInvalidationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void invalidate() {
    state = state + 1;
  }
}
