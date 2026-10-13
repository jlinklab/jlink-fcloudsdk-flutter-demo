


class RemoteUnlockWait {
  final Future<bool> future;

  final void Function() startFallbackTimer;
  final void Function() cancel;

  RemoteUnlockWait({
    required this.future,
    required this.startFallbackTimer,
    required this.cancel,
  });
}
