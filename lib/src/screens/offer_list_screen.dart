import 'dart:async'; // Import async for Timer
import 'dart:async'; // Import async for Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
// import 'taker_flow_screen.dart'; // No longer needed directly
import '../models/offer.dart'; // Import Offer model
import '../services/key_service.dart'; // Import KeyService (still needed for prompt method)
import '../widgets/progress_indicators.dart'; // Import the progress indicators
import 'taker_flow/taker_submit_blik_screen.dart'; // Import new screen
import 'taker_flow/taker_wait_confirmation_screen.dart'; // Import new screen
import 'package:url_launcher/url_launcher.dart';

// --- OfferListScreen ---

class OfferListScreen extends ConsumerStatefulWidget {
  const OfferListScreen({super.key});

  @override
  ConsumerState<OfferListScreen> createState() => _OfferListScreenState();
}

class _OfferListScreenState extends ConsumerState<OfferListScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(availableOffersProvider);
        ref.invalidate(initialActiveOfferProvider);
      }
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        print("[OfferListScreen] Periodic refresh.");
        ref.invalidate(availableOffersProvider);
        ref.invalidate(initialActiveOfferProvider);
      } else {
        timer.cancel();
      }
    });
  }

  void _resetToRoleSelection(String message) {
    _refreshTimer?.cancel();
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (scaffoldMessenger != null && message.isNotEmpty) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    }
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  // --- Helper to Prompt for Lightning Address (Kept here in case needed elsewhere later) ---
  Future<String?> _promptForLightningAddress(
    BuildContext context,
    KeyService keyService,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Lightning Address'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'user@domain.com',
                labelText: 'Lightning Address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid Lightning Address';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: const Text('Save & Continue'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final address = controller.text;
                  showDialog(
                    context: dialogContext,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    await keyService.saveLightningAddress(address);
                    Navigator.of(dialogContext).pop(); // Pop loading
                    Navigator.of(dialogContext).pop(address); // Return saved
                  } catch (e) {
                    Navigator.of(dialogContext).pop(); // Pop loading
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(content: Text('Error saving address: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final offersAsyncValue = ref.watch(availableOffersProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);
    final myActiveOfferAsyncValue = ref.watch(initialActiveOfferProvider);
    // Removed lnAddressAsyncValue watch as check is moved

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Offers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Role Selection',
          onPressed: () => _resetToRoleSelection(""),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://simplex.chat/contact#/?v=2-7&smp=smp%3A%2F%2Fu2dS9sG8nMNURyZwqASV4yROM28Er0luVTx5X1CsMrU%3D%40smp4.simplex.im%2FjwS8YtivATVUtHogkN2QdhVkw2H6XmfX%23%2F%3Fv%3D1-3%26dh%3DMCowBQYDK2VuAyEAsNpGcPiALZKbKfIXTQdJAuFxOmvsuuxMLR9rwMIBUWY%253D%26srv%3Do5vmywmrnaxalvz6wi3zicyftgio6psuvyniis6gco6bp6ekl4cqj4id.onion&data=%7B%22groupLinkId%22%3A%22hCkt5Ph057tSeJdyEI0uug%3D%3D%22%7D',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://play-lh.googleusercontent.com/Em1xX7Zh3WtNeXC0TQdRr0oSE_2gMxainzWzqp_ec-Bair5XVIQ23GTRTDIe35aRog',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Get notified of new orders with SimpleX',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Add some spacing
            Expanded(
              child: offersAsyncValue.when(
                data: (offers) {
                  if (offers.isEmpty) {
                    return const Center(
                      child: Text('No offers available yet.'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      print("[OfferListScreen] Manual refresh triggered.");
                      ref.invalidate(availableOffersProvider);
                      ref.invalidate(initialActiveOfferProvider);
                      await ref.read(availableOffersProvider.future);
                    },
                    child: ListView.builder(
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        final bool isFunded =
                            offer.status == OfferStatus.funded.name;
                        final bool isReserved =
                            offer.status == OfferStatus.reserved.name;
                        final bool isBlikReceived =
                            offer.status == OfferStatus.blikReceived.name;

                        Widget? trailingWidget;

                        if (isFunded) {
                          trailingWidget = ElevatedButton(
                            child: const Text('TAKE'),
                            // Simplified onPressed: Only check public key
                            onPressed: publicKeyAsyncValue.maybeWhen(
                              data:
                                  (publicKey) => () async {
                                    if (publicKey == null)
                                      return; // Still need pubkey

                                    final takerId = publicKey;
                                    final apiService = ref.read(
                                      apiServiceProvider,
                                    );
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );
                                    try {
                                      final DateTime? reservationTimestamp =
                                          await apiService.reserveOffer(
                                            offer.id,
                                            takerId,
                                          );

                                      if (reservationTimestamp != null) {
                                        final Offer updatedOffer = Offer(
                                          id: offer.id,
                                          amountSats: offer.amountSats,
                                          feeSats: offer.feeSats,
                                          status: OfferStatus.reserved.name,
                                          createdAt: offer.createdAt,
                                          makerPubkey: offer.makerPubkey,
                                          takerPubkey: takerId,
                                          reservedAt: reservationTimestamp,
                                          blikReceivedAt: offer.blikReceivedAt,
                                          blikCode: offer.blikCode,
                                          holdInvoicePaymentHash:
                                              offer.holdInvoicePaymentHash,
                                        );

                                        ref
                                            .read(activeOfferProvider.notifier)
                                            .state = updatedOffer;
                                        ref
                                            .read(appRoleProvider.notifier)
                                            .state = AppRole.taker;

                                        Navigator.of(
                                          context,
                                        ).pop(); // Pop loading
                                        // Navigate to the new Submit BLIK screen
                                        Navigator.of(
                                          context,
                                        ).pop(); // Pop loading
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    TakerSubmitBlikScreen(
                                                      initialOffer:
                                                          updatedOffer,
                                                    ), // Pass offer
                                          ),
                                        );
                                      } else {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Pop loading
                                        ref.read(errorProvider.notifier).state =
                                            'Failed to reserve offer (no timestamp returned).';
                                        if (scaffoldMessenger.mounted)
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: ${ref.read(errorProvider)}',
                                              ),
                                            ),
                                          );
                                        ref.invalidate(availableOffersProvider);
                                      }
                                    } catch (e) {
                                      if (Navigator.of(context).canPop())
                                        Navigator.of(context).pop();
                                      ref.read(errorProvider.notifier).state =
                                          'Failed to reserve offer: $e';
                                      if (scaffoldMessenger.mounted)
                                        scaffoldMessenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error: ${ref.read(errorProvider)}',
                                            ),
                                          ),
                                        );
                                      ref.invalidate(availableOffersProvider);
                                    }
                                  },
                              orElse:
                                  () =>
                                      null, // Disable if public key loading/error
                            ),
                          );
                        } else if (isReserved || isBlikReceived) {
                          trailingWidget = myActiveOfferAsyncValue.when(
                            data: (myOffer) {
                              if (myOffer != null && offer.id == myOffer.id) {
                                return ElevatedButton(
                                  child: const Text('RESUME'),
                                  onPressed: () {
                                    ref
                                        .read(activeOfferProvider.notifier)
                                        .state = myOffer;
                                    ref.read(appRoleProvider.notifier).state =
                                        AppRole.taker;

                                    // Determine which screen to navigate to based on status
                                    Widget destinationScreen;
                                    if (myOffer.status ==
                                        OfferStatus.reserved.name) {
                                      destinationScreen = TakerSubmitBlikScreen(
                                        initialOffer: myOffer,
                                      ); // Pass offer
                                    } else if (myOffer.status ==
                                            OfferStatus.blikReceived.name ||
                                        myOffer.status ==
                                            OfferStatus.blikSentToMaker.name ||
                                        myOffer.status ==
                                            OfferStatus.makerConfirmed.name) {
                                      destinationScreen =
                                          TakerWaitConfirmationScreen(
                                            offer: myOffer,
                                          ); // Pass offer
                                    } else {
                                      // Should not happen for a resumable offer, but handle defensively
                                      print(
                                        "[OfferListScreen] Error: Resuming offer in unexpected state: ${myOffer.status}",
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Error: Offer is in an unexpected state.",
                                          ),
                                        ),
                                      );
                                      return; // Don't navigate
                                    }

                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push(
                                      MaterialPageRoute(
                                        builder: (context) => destinationScreen,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Text(
                                  offer.status.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            },
                            loading:
                                () => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            error: (e, s) {
                              print("Error loading myActiveOffer: $e");
                              return Text(
                                offer.status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          );
                        } else {
                          trailingWidget = Text(
                            offer.status.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        trailingWidget ??= const SizedBox.shrink();

                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                title: Text(
                                  'Amount: ${offer.amountSats} sats',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Fee: ${offer.feeSats} sats | Status: ${offer.status}\nID: ${offer.id.substring(0, 8)}...',
                                ),
                                isThreeLine: true,
                                trailing: trailingWidget,
                              ),
                            ),
                            if (isReserved && offer.reservedAt != null)
                              ReservationProgressIndicator(
                                key: ValueKey('progress_res_${offer.id}'),
                                reservedAt: offer.reservedAt!,
                              ),
                            if (isBlikReceived && offer.blikReceivedAt != null)
                              BlikConfirmationProgressIndicator(
                                key: ValueKey('progress_blik_${offer.id}'),
                                blikReceivedAt: offer.blikReceivedAt!,
                              ),
                          ],
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error loading offers: $error'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed:
                                () => ref.invalidate(availableOffersProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
