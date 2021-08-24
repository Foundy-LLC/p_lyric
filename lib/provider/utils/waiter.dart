import 'dart:async';

import 'package:get/get.dart';

/// 초기 실행 혹은 타이머가 작동중이지 않을 때는 바로 [callback]을 실행하며 그 후로 [delay] 동안의
/// 명령이 끝나야 다음 명령이 실행된다.
Worker wait<T>(
  RxInterface<T> listener,
  WorkerCallback<T> callback, {
  Duration? time,
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) {
  final _waiter = _Waiter(delay: time ?? const Duration(milliseconds: 800));
  StreamSubscription sub = listener.listen(
    (event) {
      _waiter(() {
        callback(event);
      });
    },
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  return Worker(sub.cancel, '[wait]');
}

class _Waiter {
  final Duration delay;
  Timer? _timer;

  _Waiter({required this.delay});

  void call(void Function() action) {
    if (_timer == null || !_timer!.isActive) {
      action();
      _timer = Timer(delay, () {});
    } else {
      _timer?.cancel();
      _timer = Timer(delay, action);
    }
  }

  /// Notifies if the delayed call is active.
  bool get isRunning => _timer?.isActive ?? false;

  /// Cancel the current delayed call.
  void cancel() => _timer?.cancel();
}
