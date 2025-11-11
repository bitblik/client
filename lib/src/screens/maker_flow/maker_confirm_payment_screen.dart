import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../i18n/gen/strings.g.dart';
import '../../providers/providers.dart';
import 'maker_amount_form.dart'; // For MakerProgressIndicator

class MakerConfirmPaymentScreen extends ConsumerStatefulWidget {
  const MakerConfirmPaymentScreen({super.key});

  @override
  ConsumerState<MakerConfirmPaymentScreen> createState() =>
      _MakerConfirmPaymentScreenState();
}

class _MakerConfirmPaymentScreenState
    extends ConsumerState<MakerConfirmPaymentScreen> {
  bool _fetchAttempted = false;
  @override
  void initState() {
    super.initState();
    // Immediately reset any lingering loading state
    ref.read(isLoadingProvider.notifier).state = false;
    // Also reset in post frame to catch any async state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    });
    // Attempt immediately if key is already available
    final pkNow = ref.read(publicKeyProvider).value;
    if (pkNow != null) {
      _fetchBlikCode();
    }
  }

  Future<void> _fetchBlikCode() async {
    if (_fetchAttempted) return;
    _fetchAttempted = true;
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;
    if (offer == null || makerId == null) return;
    final apiService = ref.read(apiServiceProvider);
    final blikCode = await apiService.getBlikCodeForMaker(
      offer.id,
      makerId,
      offer.coordinatorPubkey,
    );
    if (blikCode != null) {
      ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
    }
  }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final paymentHash = ref.read(paymentHashProvider);
    final makerId = ref.read(publicKeyProvider).value; // Read current value

    if (paymentHash == null || makerId == null) {
      ref.read(errorProvider.notifier).state =
          t.maker.confirmPayment.errors.missingHashOrKey; // Use Slang t
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    final offer = ref.read(activeOfferProvider);
    if (offer == null) {
      ref.read(errorProvider.notifier).state =
          t.offers.errors.detailsMissing; // Use Slang t
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    final offerId = offer.id;

    try {
      final apiService = ref.read(apiServiceProvider);
      // final offerStatus = await apiService.getOfferStatus(paymentHash, offer.coordinatorPubkey);
      // if (offerStatus == null ||
      //     (offerStatus != OfferStatus.blikReceived.name &&
      //         offerStatus != OfferStatus.blikSentToMaker.name)) {
      //   throw Exception(
      //     t.maker.confirmPayment.errors.incorrectState(
      //       status: offerStatus ?? 'null',
      //     ), // Use Slang t
      //   );
      // }

      print(
        "[MakerConfirmPaymentScreen] Confirming payment for offer $offerId by maker $makerId",
      );
      await apiService.confirmMakerPayment(
        offerId,
        makerId,
        offer.coordinatorPubkey,
      );

      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(t.maker.confirmPayment.feedback.confirmedTakerPaid),
          ), // Use Slang t
        );
      }
      if (context.mounted) {
        context.go('/maker-success', extra: offer);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = t.maker.confirmPayment.errors
          .confirming(details: e.toString()); // Use Slang t
    } finally {
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _markBlikInvalid(BuildContext context, WidgetRef ref) async {
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;

    if (offer == null || makerId == null) {
      ref.read(errorProvider.notifier).state =
          t.offers.errors.detailsMissing; // Use Slang t
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      print(
        "[MakerConfirmPaymentScreen] Marking BLIK invalid for offer ${offer.id} by maker $makerId",
      );
      await apiService.markBlikInvalid(
        offer.id,
        makerId,
        offer.coordinatorPubkey,
      );

      if (context.mounted) {
        context.go('/maker-invalid-blik', extra: offer);
      }
    } catch (e) {
      // TODO: Add specific localization for this error in YAML and use it here
      ref.read(errorProvider.notifier).state =
          '${t.system.errors.generic}: $e'; // Use Slang t
    } finally {
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.system.blik.copied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatBlikCode(String code) {
    // Format BLIK code with space: "987085" -> "987 085"
    if (code.length == 6) {
      return '${code.substring(0, 3)} ${code.substring(3)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    // final strings = AppLocalizations.of(context)!; // REMOVE THIS
    final ref =
        this.ref; // 'ref' is already available in ConsumerStatefulWidget's state
    // Hard reset any lingering global loader to avoid blocking UI
    final currentLoading = ref.read(isLoadingProvider);
    if (currentLoading == true) {
      ref.read(isLoadingProvider.notifier).state = false;
    }
    // Listen for public key availability (must be done during build)
    ref.listen(publicKeyProvider, (previous, next) {
      if (!_fetchAttempted && next.value != null) {
        _fetchBlikCode();
      }
    });
    final errorMessage = ref.watch(errorProvider);
    final receivedBlikCode = ref.watch(receivedBlikCodeProvider);

    final bool isFetchingBlik = receivedBlikCode == null;
    final formattedBlikCode = _formatBlikCode(receivedBlikCode ?? '··· ···');
    const TextStyle blikStyle = TextStyle(
      fontSize: 68,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      letterSpacing: 6,
    );
    final TextPainter tp = TextPainter(
      text: const TextSpan(text: ''), // will set below to avoid const issue
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(text: formattedBlikCode, style: blikStyle);
    tp.layout();
    // Add some padding budget for icon and inner paddings
    final double copyButtonWidth = tp.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Progress indicator (Step 3: Use BLIK)
              const MakerProgressIndicator(activeStep: 3),
              const SizedBox(height: 20),

              // Expanded section with evenly spaced title, code, and button
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final upperContent = Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // BLIK code received text
                        Text(
                          t.maker.confirmPayment.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Large BLIK code (with loading hint if needed)
                        Column(
                          children: [
                            Text(
                              formattedBlikCode,
                              style: blikStyle,
                              textAlign: TextAlign.center,
                            ),
                            if (isFetchingBlik) ...[
                              const SizedBox(height: 8),
                              Text(
                                t.maker.confirmPayment.retrieving,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Copy BLIK button with gradient
                        Center(
                          child: SizedBox(
                            width: copyButtonWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFF0000),
                                    Color(0xFFFF007F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    receivedBlikCode == null
                                        ? null
                                        : () =>
                                            _copyToClipboard(receivedBlikCode),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.copy,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      t.maker.confirmPayment.actions.copyBlik,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                    // Make upper content scrollable only when needed
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: upperContent,
                      ),
                    );
                  },
                ),
              ),

              // Bottom section: Instructions and buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  _buildInstructionItem(
                    '1',
                    t.maker.confirmPayment.instruction1,
                  ),
                  const SizedBox(height: 6),
                  _buildInstructionItem(
                    '2',
                    t.maker.confirmPayment.instruction2,
                  ),
                  const SizedBox(height: 6),
                  _buildInstructionItem(
                    '3',
                    t.maker.confirmPayment.instruction3,
                  ),
                  const SizedBox(height: 12),

                  // Error message
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Confirm Successful Payment button (green)
                  ElevatedButton(
                    onPressed: () => _confirmPayment(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          t.maker.confirmPayment.actions.confirm,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Invalid BLIK code button (red outlined)
                  OutlinedButton(
                    onPressed: () => _markBlikInvalid(context, ref),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.close_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.maker.confirmPayment.actions.markInvalid,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
