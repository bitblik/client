import 'dart:async'; // For Timer
import 'dart:io'; // For Platform check
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart'; // For QR code display
import 'package:url_launcher/url_launcher.dart'; // For launching URLs/Intents
import 'package:android_intent_plus/android_intent.dart'; // For Android Intents
import 'package:android_intent_plus/flag.dart'; // Import for flags enum
import '../../providers/providers.dart'; // Import providers
import '../../models/offer.dart'; // Import Offer model for status enum comparison
// Import ApiService
import 'package:go_router/go_router.dart';
import 'package:bitblik/l10n/app_localizations.dart';
import 'webln_stub.dart' if (dart.library.js) 'webln_web.dart';

class MakerPayInvoiceScreen extends ConsumerStatefulWidget {
  const MakerPayInvoiceScreen({super.key});

  @override
  ConsumerState<MakerPayInvoiceScreen> createState() =>
      _MakerPayInvoiceScreenState();
}

class _MakerPayInvoiceScreenState extends ConsumerState<MakerPayInvoiceScreen> {
  Timer? _statusPollTimer;
  bool isWallet = false;
  bool _sentWeblnPayment = false;

  @override
  void initState() {
    super.initState();
    checkWeblnSupport((supported) {
      setState(() {
        print("!!!!!!!!!!!!!!!! isWallet supported: $supported");
        isWallet = supported;
      });
    });
    // Start polling immediately when this screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startPollingInvoiceStatus();
      }
    });
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  // --- Polling Logic ---
  void _startPollingInvoiceStatus() {
    _statusPollTimer?.cancel(); // Cancel existing timer
    final paymentHash = ref.read(
      paymentHashProvider,
    ); // Read, don't watch in timer callback
    if (paymentHash == null || !mounted) return;

    print(
      '[MakerPayInvoiceScreen] Starting polling for payment hash: $paymentHash',
    );
    _statusPollTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      // Check mounted at the beginning of the callback
      if (!mounted) {
        timer.cancel();
        return;
      }
      final apiService = ref.read(apiServiceProvider); // Use read inside timer
      try {
        final status = await apiService.getOfferStatus(paymentHash);
        // print('[MakerPayInvoiceScreen] Poll result for $paymentHash: $status');
        if (status != null && status != 'pending_creation') {
          final offerStatus = OfferStatus.values.byName(status);
          if (offerStatus.index >= OfferStatus.funded.index) {
            print(
              '[MakerPayInvoiceScreen] Invoice paid! Offer status: $status. Moving to next step.',
            );
            _statusPollTimer?.cancel(); // Stop polling
            final strings =
                AppLocalizations.of(context)!; // Get strings instance
            final publicKey = ref.read(publicKeyProvider).value;
            if (publicKey == null) {
              // Use localized string
              throw Exception(strings.errorPublicKeyNotAvailable);
            }

            final fullOfferData = await apiService.getMyActiveOffer(publicKey);

            if (fullOfferData == null) {
              // Use localized string
              throw Exception(strings.errorCouldNotFetchActiveOffer);
            }

            final fullOffer = Offer.fromJson(fullOfferData);

            ref.read(activeOfferProvider.notifier).state = fullOffer;

            if (mounted) {
              context.go("/wait-taker");
            }
          } else {
            if (mounted) {
              setState(() {});
            }
          }
        } else {
          if (mounted) {
            setState(() {});
          }
        }
      } catch (e) {
        print('[MakerPayInvoiceScreen] Error polling offer status: $e');
        // Optionally set error state via provider if needed
        // ref.read(errorProvider.notifier).state = 'Polling failed: $e';
      }
    });
  }

  // --- Intent/URL Launching ---
  Future<void> _launchLightningUrl(String invoice) async {
    print("!!!!!!! kIsWeb:$kIsWeb");
    if (kIsWeb) {
      await sendWeblnPayment(invoice).then((_) {}).catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('WebLN payment failed: $e')));
        }
      });
      return;
    }

    final strings = AppLocalizations.of(context)!; // Get strings instance
    final link = 'lightning:$invoice';
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'action_view',
          data: link,
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
      } else {
        final url = Uri.parse(link);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (kDebugMode) {
            print('Could not launch $link');
          }
          if (mounted) {
            // Use localized string
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.errorCouldNotOpenLightningApp)),
            );
          }
        }
      }
    } catch (e) {
      print('Error launching lightning URL: $e');
      if (mounted) {
        // Use localized string with placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.errorOpeningLightningApp(e.toString())),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!; // Get strings instance
    final holdInvoice = ref.watch(
      holdInvoiceProvider,
    ); // Watch the invoice state

    // WebLN auto-pay logic
    print(
      "!!!!!!!!!!!!!!!! isWallet: $isWallet, holdInvoice: $holdInvoice, sent:$_sentWeblnPayment",
    );

    if (isWallet && holdInvoice != null /*&& !_sentWeblnPayment*/ ) {
      sendWeblnPayment(holdInvoice)
          .then((_) {
            _sentWeblnPayment = true;
          })
          .catchError((e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('WebLN payment failed: $e')),
              );
            }
          });
    }

    // Add Scaffold wrapper
    return Builder(
      // Use Builder to get context below Scaffold if needed for SnackBar
      builder: (context) {
        if (holdInvoice == null) {
          // Should not happen if navigation is correct, but handle defensively
          // Use localized string (errorOfferDetailsMissing seems appropriate)
          return Center(child: Text(strings.errorOfferDetailsMissing));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Use localized string
                Text(
                  strings.payHoldInvoiceTitle,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                // Amount info: sats, fiat, fee
                Builder(
                  builder: (context) {
                    final offer = ref.watch(activeOfferProvider);
                    if (offer == null) return const SizedBox.shrink();
                    final sats = offer.amountSats;
                    final fiat = offer.fiatAmount ?? 0.0;
                    final coordinatorInfoAsync = ref.watch(
                      coordinatorInfoProvider,
                    );
                    String formatFiat(double value) => value.toStringAsFixed(
                      value.truncateToDouble() == value ? 0 : 2,
                    );
                    return coordinatorInfoAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                      data: (coordinatorInfo) {
                        final feePct = coordinatorInfo.makerFee;
                        final feeFiat = fiat * feePct / 100;
                        final totalFiat = fiat + feeFiat;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "$sats sats",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${formatFiat(fiat)} + ${formatFiat(feeFiat)} fee = ${formatFiat(totalFiat)} PLN",
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),
                // Display QR Code (tappable)
                Center(
                  child: GestureDetector(
                    onTap: () => _launchLightningUrl(holdInvoice),
                    child: QrImageView(
                      data: holdInvoice.toUpperCase(),
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white, // Ensure QR is visible
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Display Invoice String (selectable and tappable)
                InkWell(
                  onTap: () => _launchLightningUrl(holdInvoice),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SelectableText(
                      holdInvoice,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  // Use localized string
                  label: Text(strings.copyInvoice),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: holdInvoice));
                    // Use localized string
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.invoiceCopied)),
                    );
                  },
                ),
                SizedBox(height: 25),
                const SizedBox(height: 25),
                // Polling status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    // Use localized string
                    Text(strings.waitingForPaymentConfirmation),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
