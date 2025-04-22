// RoleSelectionScreen: Allows users to choose Maker or Taker role, or resume an active offer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    Widget targetScreen;

    switch (offerStatus) {
      case OfferStatus
          .created: // Should ideally not happen if polling works, but handle defensively
      case OfferStatus.funded:
      case OfferStatus.published:
        // Waiting for a taker to reserve
        targetScreen = const MakerWaitTakerScreen();
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

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => targetScreen));
  }

  // Helper to navigate to the correct Taker step based on offer status
  void _navigateToTakerStep(BuildContext context, Offer offer) {
    final offerStatus = OfferStatus.values.byName(offer.status);
    Widget destinationScreen;

    if (offerStatus == OfferStatus.reserved) {
      // Pass the offer to the constructor using initialOffer
      destinationScreen = TakerSubmitBlikScreen(initialOffer: offer);
    } else if (offerStatus == OfferStatus.blikReceived ||
        offerStatus == OfferStatus.blikSentToMaker ||
        offerStatus == OfferStatus.makerConfirmed) {
      // Pass the offer to the constructor using offer
      destinationScreen = TakerWaitConfirmationScreen(offer: offer);
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

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => destinationScreen));
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed:
                        hasActiveOffer
                            ? null
                            : () {
                              ref.read(appRoleProvider.notifier).state =
                                  AppRole.maker;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MakerAmountForm(),
                                ),
                              );
                            },
                    child: const Text('PAY with Lightning'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed:
                        hasActiveOffer
                            ? null
                            : () async {
                              final keyService = ref.read(keyServiceProvider);
                              String? currentLnAddress =
                                  lnAddressAsyncValue.value;

                              if (currentLnAddress == null ||
                                  currentLnAddress.isEmpty) {
                                if (lnAddressAsyncValue.isLoading) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Loading address... Try again.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                currentLnAddress =
                                    await _promptForLightningAddress(
                                      context,
                                      keyService,
                                    );
                                if (currentLnAddress == null ||
                                    currentLnAddress.isEmpty) {
                                  return;
                                }
                                ref.invalidate(lightningAddressProvider);
                              }

                              ref.read(appRoleProvider.notifier).state =
                                  AppRole.taker;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const OfferListScreen(),
                                ),
                              );
                            },
                    child: const Text('SELL BLIK code for sats'),
                  ),
                  const SizedBox(height: 30),

                  if (hasActiveOffer) ...[
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
                        subtitle: Text(
                          "Status: ${activeOffer!.status}\nAmount: ${activeOffer.amountSats} sats",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Make onTap async
                          // Set base providers immediately
                          ref.read(activeOfferProvider.notifier).state =
                              activeOffer;
                          ref.read(appRoleProvider.notifier).state =
                              activeRole!;

                          if (activeRole == AppRole.maker) {
                            // Set payment hash if available
                            if (activeOffer.holdInvoicePaymentHash != null) {
                              ref.read(paymentHashProvider.notifier).state =
                                  activeOffer.holdInvoicePaymentHash!;
                            }

                            final offerStatus = OfferStatus.values.byName(
                              activeOffer.status,
                            );

                            // Check if we need to fetch BLIK before navigating to confirm screen
                            if (offerStatus == OfferStatus.blikReceived ||
                                offerStatus == OfferStatus.blikSentToMaker) {
                              // Show loading indicator while fetching
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );
                              try {
                                final apiService = ref.read(apiServiceProvider);
                                final makerId =
                                    ref.read(publicKeyProvider).value;
                                if (makerId == null) {
                                  throw Exception("Maker public key not found");
                                }
                                apiService
                                    .getBlikCodeForMaker(
                                      activeOffer.id,
                                      makerId,
                                    )
                                    .then((blikCode) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Pop loading dialog

                                      if (blikCode != null) {
                                        ref
                                            .read(
                                              receivedBlikCodeProvider.notifier,
                                            )
                                            .state = blikCode;
                                        // Now navigate to the confirm screen
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const MakerConfirmPaymentScreen(),
                                          ),
                                        );
                                      } else {
                                        throw Exception(
                                          "Could not retrieve BLIK code for this offer.",
                                        );
                                      }
                                    });
                              } catch (e) {
                                Navigator.of(
                                  context,
                                ).pop(); // Pop loading dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error resuming offer: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                // Reset state as we couldn't resume properly
                                ref.read(appRoleProvider.notifier).state =
                                    AppRole.none;
                                ref.read(activeOfferProvider.notifier).state =
                                    null;
                              }
                            } else {
                              // For other maker states, use the existing navigation logic
                              _navigateToMakerStep(context, activeOffer);
                            }
                          } else {
                            // Taker role
                            // Use updated navigation logic for Taker, passing the offer
                            _navigateToTakerStep(
                              context,
                              activeOffer!, // Pass the non-null activeOffer
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
