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
import '../../../i18n/gen/strings.g.dart'; // Correct Slang import
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

    try {
      checkWeblnSupport((supported) {
        print("!!!!!!!!!!!!!!! isWallet: $isWallet, supported: $supported");
        if (mounted) {
          setState(() {
            isWallet = supported;
          });
        }
      });
    } catch (e) {
      print("!!!!catch $e");
    }
    // No longer need to start polling - will use subscription instead
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- Status Update Handler ---
  void _handleStatusUpdate(OfferStatus? status) async {
    if (status == null) return;

    print('[MakerPayInvoiceScreen] Status update received: $status');

    if (status.index >= OfferStatus.funded.index) {
      print(
        '[MakerPayInvoiceScreen] Invoice paid! Offer status: $status. Moving to next step.',
      );

      final publicKey = ref.read(publicKeyProvider).value;
      if (publicKey == null) {
        throw Exception(t.maker.payInvoice.errors.publicKeyNotAvailable);
      }

      final apiService = ref.read(apiServiceProvider);
      final fullOfferData = await apiService.getMyActiveOffer(publicKey);

      if (fullOfferData == null) {
        throw Exception(t.maker.payInvoice.errors.couldNotFetchActive);
      }

      final fullOffer = Offer.fromJson(fullOfferData);
      ref.read(activeOfferProvider.notifier).state = fullOffer;

      if (mounted) {
        context.go("/wait-taker");
      }
    }
  }

  // --- Intent/URL Launching ---
  Future<void> _launchLightningUrl(String invoice) async {
    if (kIsWeb) {
      print("!! launch lightning URL -> sending invoice");

      await sendWeblnPayment(invoice).then((_) {}).catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('WebLN payment failed: $e')),
          ); // Can be localized if needed
        }
      });
      return;
    }

    final link = 'lightning:$invoice';
    try {
      if (!kIsWeb && Platform.isAndroid) {
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.maker.payInvoice.errors.couldNotOpenApp),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error launching lightning URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.maker.payInvoice.errors.openingApp(details: e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final holdInvoice = ref.watch(holdInvoiceProvider);
    final offer = ref.watch(activeOfferProvider);
    final publicKeyAsync = ref.watch(publicKeyProvider);

    // Set up status subscription
    if (offer != null &&
        offer.holdInvoicePaymentHash != null &&
        offer.coordinatorPubkey != null) {
      publicKeyAsync.whenData((publicKey) {
        if (publicKey != null) {
          ref.listen<AsyncValue<OfferStatus?>>(
            offerStatusSubscriptionProvider((
              paymentHash: offer.holdInvoicePaymentHash!,
              coordinatorPubKey: offer.coordinatorPubkey,
              userPubkey: publicKey,
            )),
            (previous, next) {
              next.whenData((status) {
                _handleStatusUpdate(status);
              });
            },
          );
        }
      });
    }
    // WebLN auto-pay logic
    if (isWallet && holdInvoice != null && !_sentWeblnPayment) {
      print("isWallet: $isWallet, _sentWeblnPayment: $_sentWeblnPayment");
      sendWeblnPayment(holdInvoice)
          .then((_) {
            if (mounted) {
              setState(() {
                _sentWeblnPayment = true;
              });
            }
          })
          .catchError((e) {
            // if (mounted) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text('WebLN payment failed: $e'),
            //     ), // Can be localized if needed
            //   );
            // }
          });
    }

    // Add Scaffold wrapper
    return Builder(
      // Use Builder to get context below Scaffold if needed for SnackBar
      builder: (context) {
        if (holdInvoice == null) {
          // Should not happen if navigation is correct, but handle defensively
          return Center(child: Text(t.offers.errors.detailsMissing));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  t.maker.payInvoice.title,
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
                    final apiService = ref.watch(apiServiceProvider);
                    final coordinatorInfo =
                        offer.coordinatorPubkey != null
                            ? apiService.getCoordinatorInfoByPubkey(
                              offer.coordinatorPubkey!,
                            )
                            : null;
                    String formatFiat(double value) => value.toStringAsFixed(
                      value.truncateToDouble() == value ? 0 : 2,
                    );
                    if (coordinatorInfo == null) return const SizedBox.shrink();
                    final feePct = coordinatorInfo.makerFee;
                    final feeFiat = fiat * feePct / 100;
                    final totalFiat = fiat + feeFiat;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$sats sats", // This can be localized if needed: t.offers.details.amount(amount: sats.toString())
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          // This complex string can be localized if needed
                          "${formatFiat(fiat)} + ${formatFiat(feeFiat)} fee = ${formatFiat(totalFiat)} PLN",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                      size: 300.0,
                      backgroundColor: Colors.white, // Ensure QR is visible
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.account_balance_wallet,
                      ), // Or another appropriate icon
                      label: Text(t.maker.payInvoice.actions.payInWallet),
                      onPressed: () => _launchLightningUrl(holdInvoice),
                    ),
                    const SizedBox(width: 8), // Spacing between buttons
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: Text(t.maker.payInvoice.actions.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: holdInvoice));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.maker.payInvoice.feedback.copied),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
                    Text(t.maker.payInvoice.feedback.waitingConfirmation),
                  ],
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
              ],
            ),
          ),
        );
      },
    );
  }
}
