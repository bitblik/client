// RoleSelectionScreen: Allows users to choose Maker or Taker role, or resume an active offer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart'; // Import providers
import '../models/offer.dart'; // Import Offer model
import '../services/key_service.dart'; // Import KeyService
import '../services/api_service.dart'; // Explicitly import ApiService
// Import flow screens for navigation
import 'maker_flow/maker_amount_form.dart';
// import 'maker_flow/maker_pay_invoice_screen.dart'; // Not directly navigated to from here
import 'maker_flow/maker_wait_taker_screen.dart'; // Corrected import path (file still named this)
import 'maker_flow/maker_wait_for_blik_screen.dart';
import 'maker_flow/maker_confirm_payment_screen.dart';
// Removed import 'taker_flow_screen.dart';
import 'offer_list_screen.dart';
import 'taker_flow/taker_submit_blik_screen.dart'; // Import new screen
import 'taker_flow/taker_wait_confirmation_screen.dart'; // Import new screen
import 'taker_flow/taker_payment_failed_screen.dart'; // Import new screen

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  // Helper to navigate to the correct Maker step based on status
  void _navigateToMakerStep(BuildContext context, Offer offer) {
    final offerStatus = OfferStatus.values.byName(offer.status);
    Widget? targetScreen;

    switch (offerStatus) {
      case OfferStatus
          .created: // Should ideally not happen if polling works, but handle defensively
      case OfferStatus.funded:
      case OfferStatus.published:
        // Waiting for a taker to reserve
        targetScreen = const MakerWaitTakerScreen();
        context.go("/wait-taker", extra: offer);
        break;
      case OfferStatus.reserved:
        // Taker reserved, waiting for BLIK
        targetScreen = const MakerWaitForBlikScreen();
        break;
      // Removed blikReceived and blikSentToMaker cases here.
      // They are now handled exclusively within the onTap handler
      // where the BLIK code is fetched before navigation.
      default:
        print("Cannot resume Maker offer in state: $offerStatus");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot resume offer in state: $offerStatus")),
        );
        return; // Don't navigate
    }

    if (targetScreen!=null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => targetScreen!));
    }
  }

  // Helper to navigate to the correct Taker step based on offer status
  void _navigateToTakerStep(BuildContext context, Offer offer) {
    final offerStatus = OfferStatus.values.byName(offer.status);
    Widget? destinationScreen;

    if (offerStatus == OfferStatus.reserved) {
      // Pass the offer to the constructor using initialOffer
      destinationScreen = TakerSubmitBlikScreen(initialOffer: offer);
    } else if (offerStatus == OfferStatus.blikReceived ||
        offerStatus == OfferStatus.blikSentToMaker ||
        offerStatus == OfferStatus.makerConfirmed) {
      // Pass the offer to the constructor using offer
      context.go("/wait-confirmation", extra: offer);
    } else if (offerStatus == OfferStatus.takerPaymentFailed) {
      // Navigate to the new payment failed screen
      destinationScreen = TakerPaymentFailedScreen(offer: offer);
    } else {
      print(
        "[RoleSelectionScreen] Error: Resuming Taker offer in unexpected state: $offerStatus",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot resume Taker offer in state: $offerStatus"),
        ),
      );
      return; // Don't navigate
    }

    if (destinationScreen != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => destinationScreen!));
    }
  }

  // Helper to Prompt for Lightning Address
  static Future<String?> _promptForLightningAddress(
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
  Widget build(BuildContext context, WidgetRef ref) {
    final initialOfferAsync = ref.watch(initialActiveOfferProvider);
    final publicKeyAsync = ref.watch(publicKeyProvider);
    final lnAddressAsyncValue = ref.watch(lightningAddressProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // const Text(
            //   'Choose Your Role:',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 20),
            initialOfferAsync.when(
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              error:
                  (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Error checking active offers: $err',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              data: (activeOffer) {
                final currentPubKey = publicKeyAsync.value;
                bool hasActiveOffer =
                    activeOffer != null && currentPubKey != null;
                AppRole? activeRole;
                if (hasActiveOffer) {
                  if (activeOffer.makerPubkey == currentPubKey) {
                    activeRole = AppRole.maker;
                  } else if (activeOffer.takerPubkey == currentPubKey) {
                    activeRole = AppRole.taker;
                  } else {
                    hasActiveOffer = false;
                  }
                }

                // Exclude takerPaid from active offer, show in finished section
                final isTakerPaid =
                    hasActiveOffer &&
                    activeOffer!.status == OfferStatus.takerPaid.name;
                final hasRealActiveOffer = hasActiveOffer && !isTakerPaid;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed:
                          hasRealActiveOffer
                              ? null
                              : () {
                                ref.read(appRoleProvider.notifier).state =
                                    AppRole.maker;
                                context.push("/create");
                              },
                      child: const Text('PAY with Lightning'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          hasRealActiveOffer
                              ? null
                              : () {
                                ref.read(appRoleProvider.notifier).state =
                                    AppRole.taker;
                                context.push("/offers");
                              },
                      child: const Text('SELL BLIK code for sats'),
                    ),
                    const SizedBox(height: 30),
                    if (hasActiveOffer && !isTakerPaid) ...[
                      const Divider(),
                      const SizedBox(height: 15),
                      Text(
                        "You have an active offer:",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
                          title: Text(
                            "Role: ${activeRole == AppRole.maker ? 'Maker' : 'Taker'}",
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Status: ${activeOffer!.status}\nAmount: ${activeOffer.amountSats} sats",
                              ),
                              if (activeOffer.status ==
                                      OfferStatus.takerPaymentFailed.name &&
                                  activeOffer.takerLightningAddress != null &&
                                  activeOffer.takerLightningAddress!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    "Lightning address: ${activeOffer.takerLightningAddress}",
                                    style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing:
                              (activeOffer.status == OfferStatus.takerPaid.name)
                                  ? null
                                  : const Icon(Icons.arrow_forward_ios),
                          onTap:
                              (activeOffer.status == OfferStatus.takerPaid.name)
                                  ? null
                                  : () {
                                    ref
                                        .read(activeOfferProvider.notifier)
                                        .state = activeOffer;
                                    if (activeRole == AppRole.maker) {
                                      if (activeOffer.holdInvoicePaymentHash !=
                                          null) {
                                        ref
                                            .read(paymentHashProvider.notifier)
                                            .state = activeOffer
                                                .holdInvoicePaymentHash!;
                                      }
                                      final offerStatus = OfferStatus.values
                                          .byName(activeOffer.status);
                                      if (offerStatus ==
                                              OfferStatus.blikReceived ||
                                          offerStatus ==
                                              OfferStatus.blikSentToMaker) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder:
                                              (context) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                        );
                                        try {
                                          final apiService = ref.read(
                                            apiServiceProvider,
                                          );
                                          final makerId =
                                              ref.read(publicKeyProvider).value;
                                          if (makerId == null) {
                                            throw Exception(
                                              "Maker public key not found",
                                            );
                                          }
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const MakerConfirmPaymentScreen(),
                                            ),
                                          );
                                        } catch (e) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error resuming offer: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          ref
                                              .read(appRoleProvider.notifier)
                                              .state = AppRole.none;
                                          ref
                                              .read(
                                                activeOfferProvider.notifier,
                                              )
                                              .state = null;
                                        }
                                      } else {
                                        _navigateToMakerStep(
                                          context,
                                          activeOffer,
                                        );
                                      }
                                    } else {
                                      _navigateToTakerStep(
                                        context,
                                        activeOffer!,
                                      );
                                    }
                                  },
                        ),
                      ),
                    ],
                    Consumer(
                      builder: (context, ref, _) {
                        final finishedAsync = ref.watch(finishedOffersProvider);
                        return finishedAsync.when(
                          loading:
                              () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          error:
                              (err, stack) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  'Error loading finished offers: $err',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          data: (finishedOffers) {
                            if (finishedOffers.isEmpty) return const SizedBox();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Divider(),
                                const SizedBox(height: 15),
                                Text(
                                  "Finished Offers (last 24h):",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                ...finishedOffers.map(
                                  (offer) => Card(
                                    child: ListTile(
                                      title: Text(
                                        "Amount: ${offer.amountSats} sats",
                                      ),
                                      subtitle: Text(
                                        "Status: ${offer.status}\nPaid at: ${offer.takerPaidAt?.toLocal().toString().substring(0, 16) ?? '-'}",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
