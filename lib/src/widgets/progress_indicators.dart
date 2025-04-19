import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart'; // Needed for ref.invalidate

// Widget for 20s Reservation Progress Bar
class ReservationProgressIndicator extends ConsumerStatefulWidget {
  final DateTime reservedAt;

  const ReservationProgressIndicator({super.key, required this.reservedAt});

  @override
  ConsumerState<ReservationProgressIndicator> createState() =>
      _ReservationProgressIndicatorState();
}

class _ReservationProgressIndicatorState
    extends ConsumerState<ReservationProgressIndicator> {
  Timer? _timer;
  double _progress = 1.0;
  int _remainingSeconds = 20; // Default to 20
  final Duration _maxReservationTime = const Duration(
    seconds: 20,
  ); // UPDATED to 20s

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
  void didUpdateWidget(covariant ReservationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reservedAt != oldWidget.reservedAt) {
      print("[ReservationProgress] reservedAt changed. Recalculating.");
      _timer?.cancel();
      _calculateProgress();
      if (_progress > 0)
        _startTimer();
      else
        _triggerRefresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final expiresAt = widget.reservedAt.add(_maxReservationTime);
    final totalDuration = _maxReservationTime.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;
    if (!mounted) return;
    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        _remainingSeconds = (remainingDuration / 1000).ceil();
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
      ref.invalidate(initialActiveOfferProvider);
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
        left: 16.0,
        right: 16.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[500], // Darker background
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 20,
          ),
          Text(
            'Reserved: $_remainingSeconds s left',
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
      if (_progress > 0)
        _startTimer();
      else
        _triggerRefresh();
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
      ref.invalidate(initialActiveOfferProvider);
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
        left: 16.0,
        right: 16.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 20,
          ),
          Text(
            'Confirming: $_remainingSeconds s left',
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
