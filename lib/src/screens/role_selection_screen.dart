// RoleSelectionScreen: Allows users to choose Maker or Taker role, or resume an active offer.
import 'package:flutter/material.dart';
import 'package:bitblik/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/offer.dart'; // Import Offer model
import '../providers/providers.dart'; // Import providers

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  // Helper to navigate to the correct Maker step based on status
  void _navigateToMakerStep(BuildContext context, Offer offer) {
    final offerStatus = OfferStatus.values.byName(offer.status);

    switch (offerStatus) {
      case OfferStatus
          .created: // Should ideally not happen if polling works, but handle defensively
      case OfferStatus.funded:
        // Waiting for a taker to reserve
        context.go("/wait-taker", extra: offer);
        break;
      case OfferStatus.reserved:
        // Taker reserved, waiting for BLIK
        context.go("/wait-blik", extra: offer);
        break;
      // Removed blikReceived and blikSentToMaker cases here.
      // They are now handled exclusively within the onTap handler
      // where the BLIK code is fetched before navigation.
      case OfferStatus.conflict:
        // Navigate to the maker conflict screen
        context.go("/maker-conflict", extra: offer);
        break;
      default:
        print("Cannot resume Maker offer in state: $offerStatus");
        // Use localized string with placeholder
        final strings = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.errorCannotResumeOfferState(offerStatus.name),
            ),
          ),
        );
        return; // Don't navigate
    }
  }

  // Helper to navigate to the correct Taker step based on offer status
  void _navigateToTakerStep(BuildContext context, Offer offer) {
    final offerStatus = OfferStatus.values.byName(offer.status);

    if (offerStatus == OfferStatus.reserved) {
      // Pass the offer to the constructor using initialOffer
      context.go('/submit-blik', extra: offer);
    } else if (offerStatus == OfferStatus.blikReceived ||
        offerStatus == OfferStatus.blikSentToMaker ||
        offerStatus == OfferStatus.makerConfirmed) {
      // Pass the offer to the constructor using offer
      context.go("/wait-confirmation", extra: offer);
    } else if (offerStatus == OfferStatus.takerPaymentFailed) {
      // Navigate to the new payment failed screen

      context.go('/taker-failed', extra: offer);
    } else if (offerStatus == OfferStatus.invalidBlik) {
      context.go('/taker-invalid-blik', extra: offer);
    } else if (offerStatus == OfferStatus.conflict) {
      // Navigate to the taker conflict screen
      context.go('/taker-conflict', extra: offer.id);
    } else {
      print(
        "[RoleSelectionScreen] Error: Resuming Taker offer in unexpected state: $offerStatus",
      );
      // Use localized string with placeholder
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.errorCannotResumeTakerOfferState(offerStatus.name),
          ),
        ),
      );
      return; // Don't navigate
    }
  }

  // // Helper to Prompt for Lightning Address
  // static Future<String?> _promptForLightningAddress(
  //   BuildContext context,
  //   KeyService keyService,
  // ) async {
  //   final controller = TextEditingController();
  //   final formKey = GlobalKey<FormState>();
  //
  //   return showDialog<String>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       final strings = AppLocalizations.of(context)!; // Get strings
  //       return AlertDialog(
  //         // Reuse existing key
  //         title: Text(strings.enterLightningAddress),
  //         content: Form(
  //           key: formKey,
  //           child: TextFormField(
  //             controller: controller,
  //             keyboardType: TextInputType.emailAddress,
  //             decoration: InputDecoration(
  //               // Reuse existing key
  //               hintText: strings.lightningAddressHint,
  //               // Reuse existing key
  //               labelText: strings.lightningAddressLabel,
  //             ),
  //             validator: (value) {
  //               if (value == null || value.isEmpty || !value.contains('@')) {
  //                 // Reuse existing key
  //                 return strings.lightningAddressInvalid;
  //               }
  //               return null;
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             // Reuse existing key
  //             child: Text(strings.cancel),
  //             onPressed: () {
  //               Navigator.of(dialogContext).pop(null);
  //             },
  //           ),
  //           TextButton(
  //             // Reuse existing key
  //             child: Text(strings.saveAndContinue),
  //             onPressed: () async {
  //               if (formKey.currentState!.validate()) {
  //                 final address = controller.text;
  //                 showDialog(
  //                   context: dialogContext,
  //                   barrierDismissible: false,
  //                   builder:
  //                       (context) =>
  //                           const Center(child: CircularProgressIndicator()),
  //                 );
  //                 try {
  //                   await keyService.saveLightningAddress(address);
  //                   Navigator.of(dialogContext).pop(); // Pop loading
  //                   Navigator.of(dialogContext).pop(address); // Return saved
  //                 } catch (e) {
  //                   Navigator.of(dialogContext).pop(); // Pop loading
  //                   // Reuse existing key with placeholder
  //                   ScaffoldMessenger.maybeOf(context)?.showSnackBar(
  //                     SnackBar(
  //                       content: Text(strings.errorSavingAddress(e.toString())),
  //                     ),
  //                   );
  //                 }
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialOfferAsync = ref.watch(initialActiveOfferProvider);
    final publicKeyAsync = ref.watch(publicKeyProvider);
    ref.watch(lightningAddressProvider);
    final strings = AppLocalizations.of(context)!; // Get strings

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
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
                      // Use localized string with placeholder
                      child: Text(
                        strings.errorCheckingActiveOffers(err.toString()),
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
                      // Use localized string
                      child: Text(strings.payWithLightningButton),
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
                      // Use localized string
                      child: Text(strings.sellBlikButton),
                    ),
                    const SizedBox(height: 30),
                    if (hasActiveOffer && !isTakerPaid) ...[
                      const Divider(),
                      const SizedBox(height: 15),
                      // Use localized string
                      Text(
                        strings.activeOfferTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
                          // Removed title showing Role as requested
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Display Fiat Amount and Currency
                                "${formatDouble(activeOffer!.fiatAmount)} ${activeOffer.fiatCurrency}",
                                style:
                                    Theme.of(context)
                                        .textTheme
                                        .titleMedium, // Make it stand out a bit more
                              ),
                              const SizedBox(height: 4), // Add some spacing
                              Text(
                                // Keep status info, but maybe smaller
                                strings.offerStatusLabel(activeOffer.status),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (activeOffer.status ==
                                      OfferStatus.takerPaymentFailed.name &&
                                  activeOffer.takerLightningAddress != null &&
                                  activeOffer.takerLightningAddress!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    // Use localized string with placeholder
                                    strings.lightningAddressLabelShort(
                                      activeOffer.takerLightningAddress!,
                                    ),
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
                                          ref.read(apiServiceProvider);
                                          final makerId =
                                              ref.read(publicKeyProvider).value;
                                          if (makerId == null) {
                                            // Use localized string
                                            throw Exception(
                                              strings
                                                  .errorMakerPublicKeyNotFound,
                                            );
                                          }
                                          context.go('/confirm-blik');
                                        } catch (e) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              // Use localized string with placeholder
                                              content: Text(
                                                strings.errorResumingOffer(
                                                  e.toString(),
                                                ),
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
                                        activeOffer,
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
                                // Use localized string with placeholder
                                child: Text(
                                  strings.errorLoadingFinishedOffers(
                                    err.toString(),
                                  ),
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
                                // Use localized string
                                Text(
                                  strings.finishedOffersTitle,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                ...finishedOffers.map(
                                  (offer) => Card(
                                    child: ListTile(
                                      title: Text(
                                        "${formatDouble(offer.fiatAmount)} ${offer.fiatCurrency}",
                                      ),
                                      subtitle: Text(
                                        // Use localized string with placeholders
                                        strings.finishedOfferSubtitle(
                                          offer.amountSats,
                                          offer.makerFees,
                                          offer.status,
                                          offer.takerPaidAt
                                                  ?.toLocal()
                                                  .toString()
                                                  .substring(0, 16) ??
                                              '-',
                                        ),
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

String formatDouble(double value) {
  // Check if the value is effectively a whole number
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    // Format with up to 2 decimal places, removing trailing zeros
    String asString = value.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      // Remove decimal point if it's the last character
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}
