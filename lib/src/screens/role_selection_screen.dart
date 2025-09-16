// RoleSelectionScreen: Allows users to choose Maker or Taker role, or resume an active offer.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../i18n/gen/strings.g.dart';
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
      case OfferStatus.created:
        // Offer created but not yet funded - go to pay invoice screen
        context.go("/pay", extra: offer);
        break;
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
      case OfferStatus.invalidBlik:
        context.go("/maker-invalid-blik", extra: offer);
        break;
      default:
        print("Cannot resume Maker offer in state: $offerStatus");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.offers.errors.cannotResume(status: offerStatus.name),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.offers.errors.cannotResumeTaker(status: offerStatus.name),
          ),
        ),
      );
      return; // Don't navigate
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOffer = ref.watch(activeOfferProvider);
    final publicKeyAsync = ref.watch(publicKeyProvider);
    ref.watch(lightningAddressProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final currentPubKey = publicKeyAsync.value;
                bool hasActiveOffer = activeOffer != null &&
                    currentPubKey != null;


                final isTakerPaid = hasActiveOffer &&
                    activeOffer.status == OfferStatus.takerPaid.name;
                final hasRealActiveOffer = !kDebugMode && hasActiveOffer && !isTakerPaid;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: hasRealActiveOffer ? null : () {
                        context.push("/create");
                      },
                      child: Text(t.maker.roleSelection.button),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: hasRealActiveOffer ? null : () {
                        context.push("/offers");
                      },
                      child: Text(t.taker.roleSelection.button),
                    ),
                    const SizedBox(height: 30),
                    if (hasActiveOffer && !isTakerPaid) ...[
                      const Divider(),
                      const SizedBox(height: 15),
                      Text(
                        t.offers.display.activeOffer,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${formatDouble(activeOffer!.fiatAmount)} ${activeOffer.fiatCurrency}",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.common.labels.status(
                                    status: activeOffer.status),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (activeOffer.status ==
                                      OfferStatus.takerPaymentFailed.name &&
                                  activeOffer.takerLightningAddress != null &&
                                  activeOffer.takerLightningAddress!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    t.lightningAddress.labels.short(
                                      address: activeOffer
                                          .takerLightningAddress!,
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
                                // ref
                                //     .read(activeOfferProvider.notifier)
                                //     .setActiveOffer(activeOffer);
                                      if (activeOffer.holdInvoicePaymentHash !=
                                          null) {
                                        ref
                                            .read(paymentHashProvider.notifier)
                                            .state =
                                        activeOffer.holdInvoicePaymentHash!;
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
                                          builder: (context) =>
                                          const Center(
                                              child: CircularProgressIndicator()),
                                        );
                                        try {
                                          ref.read(apiServiceProvider);
                                          if (currentPubKey == activeOffer.makerPubkey) {
                                            context.go('/confirm-blik');
                                          } else if (currentPubKey == activeOffer.takerPubkey) {
                                            context.go('/wait-confirmation', extra: activeOffer);
                                          }
                                        } catch (e) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger
                                              .of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  t.offers.errors.resuming(
                                                      details: e.toString())),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          ref
                                              .read(activeOfferProvider.notifier)
                                              .setActiveOffer(null);
                                        }
                                      } else {
                                        if (currentPubKey == activeOffer.makerPubkey) {
                                          _navigateToMakerStep(
                                              context, activeOffer);
                                          } else if (currentPubKey == activeOffer.takerPubkey) {
                                          _navigateToTakerStep(
                                              context, activeOffer);
                                          }
                                      }
                                  },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            Consumer(
              builder: (context, ref, _) {
                final finishedAsync = ref.watch(finishedOffersProvider);
                return finishedAsync.when(
                  loading:
                      () =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error:
                      (err, stack) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: Text(
                          t.offers.errors.loadingFinished(
                            details: err.toString(),
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
                        Text(
                          t.offers.display.finishedOffersWithTime,
                          style:
                          Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ...finishedOffers.map(
                              (offer) =>
                              Card(
                                child: ListTile(
                                  title: Text(
                                    "${formatDouble(offer.fiatAmount)} ${offer
                                        .fiatCurrency}",
                              ),
                              subtitle: Text(
                                t.offers.details.subtitleWithDate(
                                  sats: offer.amountSats,
                                  fee: offer.makerFees,
                                  status: offer.status,
                                  date:
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
