import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart'; // Needed for ref.invalidate
import '../../i18n/gen/strings.g.dart';

// Widget for 10min Funded Offer Progress Bar
class FundedOfferProgressIndicator extends ConsumerStatefulWidget {
  final DateTime createdAt;

  const FundedOfferProgressIndicator({super.key, required this.createdAt});

  @override
  ConsumerState<FundedOfferProgressIndicator> createState() =>
      _FundedOfferProgressIndicatorState();
}

class _FundedOfferProgressIndicatorState
    extends ConsumerState<FundedOfferProgressIndicator> {
  Timer? _timer;
  double _progress = 1.0;
  int _remainingSeconds = 600; // 10 minutes
  final Duration _maxFundedTime = const Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    if (_progress <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());
    } else {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant FundedOfferProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.createdAt != oldWidget.createdAt) {
      _timer?.cancel();
      _calculateProgress();
      if (_progress > 0) {
        _startTimer();
      } else {
        _triggerRefresh();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final expiresAt = widget.createdAt.add(_maxFundedTime);
    final totalDuration = _maxFundedTime.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;
    if (!mounted) return;
    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        _remainingSeconds = (remainingDuration / 1000).ceil().clamp(0, 600);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_progress <= 0) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _calculateProgress();
      if (_progress <= 0) {
        timer.cancel();
        _triggerRefresh();
      }
    });
  }

  Future<void> _triggerRefresh() async {
    if (mounted) {
      ref.invalidate(availableOffersProvider);
    }
  }

  String _formatMMSS(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_progress <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 8.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[500],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            t.offers.progress.waitingForTaker(time: _formatMMSS(_remainingSeconds)),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for Reservation Progress Bar (dynamic duration)
class ReservationProgressIndicator extends ConsumerStatefulWidget {
  final DateTime reservedAt;
  final Duration maxDuration; // Added maxDuration

  const ReservationProgressIndicator({
    super.key,
    required this.reservedAt,
    required this.maxDuration, // Added maxDuration
  });

  @override
  ConsumerState<ReservationProgressIndicator> createState() =>
      _ReservationProgressIndicatorState();
}

class _ReservationProgressIndicatorState
    extends ConsumerState<ReservationProgressIndicator> {
  Timer? _timer;
  double _progress = 1.0;
  late int _remainingSeconds; // Will be initialized in initState

  @override
  void initState() {
    super.initState();
    _remainingSeconds =
        widget.maxDuration.inSeconds; // Initialize with widget.maxDuration
    _calculateProgress();
    if (_progress <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());
    } else {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant ReservationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if either reservedAt or maxDuration changed
    if (widget.reservedAt != oldWidget.reservedAt ||
        widget.maxDuration != oldWidget.maxDuration) {
      print(
        "[ReservationProgress] reservedAt or maxDuration changed. Recalculating.",
      );
      _timer?.cancel();
      _remainingSeconds =
          widget.maxDuration.inSeconds; // Re-initialize with new maxDuration
      _calculateProgress();
      if (_progress > 0) {
        _startTimer();
      } else {
        // If progress is already 0 (e.g. new maxDuration is very short or in the past)
        _triggerRefresh();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    // Use widget.maxDuration
    final expiresAt = widget.reservedAt.add(widget.maxDuration);
    final totalDuration = widget.maxDuration.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;

    if (!mounted) return;

    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        // Ensure remainingSeconds doesn't exceed maxDuration.inSeconds, useful if timer fires slightly late
        _remainingSeconds = (remainingDuration / 1000).ceil().clamp(
          0,
          widget.maxDuration.inSeconds,
        );
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_progress <= 0) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _calculateProgress();
      if (_progress <= 0) {
        timer.cancel();
        _triggerRefresh();
      }
    });
  }

  Future<void> _triggerRefresh() async {
    print("[ReservationProgress] Timer expired. Refreshing providers.");
    if (mounted) {
      ref.invalidate(availableOffersProvider);
    } else {
      print("[ReservationProgress] Widget disposed before refresh.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progress <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 8.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[500],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            t.offers.progress.reserved(seconds: _remainingSeconds),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for 120s BLIK Confirmation Progress Bar
class BlikConfirmationProgressIndicator extends ConsumerStatefulWidget {
  final DateTime blikReceivedAt;

  const BlikConfirmationProgressIndicator({
    super.key,
    required this.blikReceivedAt,
  });

  @override
  ConsumerState<BlikConfirmationProgressIndicator> createState() =>
      _BlikConfirmationProgressIndicatorState();
}

class _BlikConfirmationProgressIndicatorState
    extends ConsumerState<BlikConfirmationProgressIndicator> {
  Timer? _timer;
  double _progress = 1.0;
  int _remainingSeconds = 120;
  final Duration _maxConfirmationTime = const Duration(
    seconds: 120,
  ); // Define the constant

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    if (_progress <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());
    } else {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant BlikConfirmationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blikReceivedAt != oldWidget.blikReceivedAt) {
      print("[BlikConfirmProgress] blikReceivedAt changed. Recalculating.");
      _timer?.cancel();
      _calculateProgress();
      if (_progress > 0) {
        _startTimer();
      } else {
        _triggerRefresh();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final expiresAt = widget.blikReceivedAt.add(_maxConfirmationTime);
    final totalDuration = _maxConfirmationTime.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;
    if (!mounted) return;
    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        _remainingSeconds = (remainingDuration / 1000).ceil().clamp(
          0,
          120, // Clamp to 120 seconds
        );
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_progress <= 0) return;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _calculateProgress();
      if (_progress <= 0) {
        timer.cancel();
        _triggerRefresh();
      }
    });
  }

  Future<void> _triggerRefresh() async {
    print("[BlikConfirmProgress] Timer expired. Refreshing providers.");
    if (mounted) {
      ref.invalidate(availableOffersProvider);
    } else {
      print("[BlikConfirmProgress] Widget disposed before refresh.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progress <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 8.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 20,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[500],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            t.offers.progress.confirming(seconds: _remainingSeconds),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Circular Countdown Timer Widget - reusable for multiple screens
class CircularCountdownTimer extends StatefulWidget {
  final DateTime startTime;
  final Duration maxDuration;
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final double fontSize;

  const CircularCountdownTimer({
    super.key,
    required this.startTime,
    required this.maxDuration,
    this.size = 120,
    this.strokeWidth = 8,
    this.progressColor = Colors.green,
    this.backgroundColor = Colors.grey,
    this.fontSize = 32,
  });

  @override
  State<CircularCountdownTimer> createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer> {
  Timer? _timer;
  double _progress = 1.0;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateProgress();
    if (_progress > 0) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant CircularCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime ||
        widget.maxDuration != oldWidget.maxDuration) {
      _timer?.cancel();
      _calculateProgress();
      if (_progress > 0) _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final expiresAt = widget.startTime.add(widget.maxDuration);
    final totalDuration = widget.maxDuration.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;

    if (!mounted) return;

    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        _remainingSeconds = (remainingDuration / 1000).ceil().clamp(
          0,
          widget.maxDuration.inSeconds,
        );
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_progress <= 0) return;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _calculateProgress();
      if (_progress <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatMMSS(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString();
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_progress <= 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor.withOpacity(0.2),
            ),
          ),
          // Circular progress indicator
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: _progress,
              backgroundColor: widget.backgroundColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor),
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Time display
          Text(
            _formatMMSS(_remainingSeconds),
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
