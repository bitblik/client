// RoleSelectionScreen: Modern landing page with centralized design matching the provided layout
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../i18n/gen/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/logger/logger.dart';

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
        Logger.log.w("Cannot resume Maker offer in state: $offerStatus");
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
      Logger.log.e(
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
    final t = Translations.of(context);

    final currentPubKey = publicKeyAsync.value;
    bool hasActiveOffer = activeOffer != null && currentPubKey != null;
    final isTakerPaid = hasActiveOffer && activeOffer.status == OfferStatus.takerPaid.name;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Main content area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: hasActiveOffer? 40:80),

                // Main title
                Text(
                  t.landing.mainTitle,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .width > 600 ? 48 : 32,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Subtitle
                Text(
                  t.landing.subtitle,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: hasActiveOffer? 40:100),

                // Action cards
                Builder(
                  builder: (context) {
                    final hasRealActiveOffer = !kDebugMode && hasActiveOffer && !isTakerPaid;
                    final screenWidth = MediaQuery
                        .of(context)
                        .size
                        .width;
                    final cardHeight = 220.0;//screenWidth > 600 ? 200.0 : 180.0; // Responsive height

                    return Row(
                      children: [
                        // Pay BLIK card (gradient)
                        Expanded(
                          child: Container(
                            height: cardHeight,
                            child: _buildActionCard(
                              context: context,
                              title: t.landing.actions.payBlik,
                              subtitle: t.landing.actions.payBlikSubtitle,
                              icon: Icons.flash_on,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF0000), // Bright red/pink
                                  Color(0xFFFF007F), // Bright magenta/pink
                                ],
                              ),
                              textColor: Colors.white,
                              isEnabled: !hasRealActiveOffer,
                              onTap: () {
                                if (kIsWeb) {
                                  context.go("/create");
                                } else {
                                  context.push("/create");
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Sell BLIK card (white)
                        Expanded(
                          child: Container(
                            height: cardHeight,
                            child: _buildActionCard(
                              context: context,
                              title: t.landing.actions.sellBlik,
                              subtitle: t.landing.actions.sellBlikSubtitle,
                              iconImage: 'assets/sell-blik.png',
                              backgroundColor: Colors.white,
                              textColor: const Color(0xFF000000),
                              borderColor: Colors.grey[300],
                              isEnabled: !hasRealActiveOffer,
                              onTap: () {
                                if (kIsWeb) {
                                  context.go("/offers");
                                } else {
                                  context.push("/offers");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // FAQ link
                TextButton(
                  onPressed: () {
                    if (kIsWeb) {
                      context.go("/faq");
                    } else {
                      context.push("/faq");
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.landing.actions.howItWorks,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Active offer section (if exists)
                if (hasActiveOffer && !isTakerPaid) ...[
                  const Divider(),
                  const SizedBox(height: 30),
                  _buildActiveOfferSection(context, ref, activeOffer, currentPubKey, t),
                ],

                // Finished offers section
                _buildFinishedOffersSection(context, ref, t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    IconData? icon,
    String? iconImage,
    Color? backgroundColor,
    Gradient? gradient,
    required Color textColor,
    Color? borderColor,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: gradient == null ? backgroundColor : null,
            gradient: gradient,
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
          padding: const EdgeInsets.all(16), // Reduced from 24 to 16
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Added to prevent overflow
            children: [
              if (iconImage != null)
                Image.asset(
                  iconImage,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isEnabled ? 1.0 : 0.5),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 44, // Reduced from 48 to 40
                  color: textColor.withOpacity(isEnabled ? 1.0 : 0.5),
                ),
              const SizedBox(height: 14), // Reduced from 16 to 12
              Flexible( // Wrapped title in Flexible
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22, // Reduced from 24 to 20
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(isEnabled ? 1.0 : 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Added max lines to prevent overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Flexible( // Wrapped subtitle in Flexible
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14, // Reduced from 16 to 14
                    color: textColor.withOpacity(isEnabled ? 0.8 : 0.4),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Added max lines to prevent overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOfferSection(BuildContext context,
      WidgetRef ref,
      Offer activeOffer,
      String? currentPubKey,
      Translations t,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.offers.details.activeOffer,
          style: Theme
              .of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,

          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${formatDouble(activeOffer.fiatAmount)} ${activeOffer.fiatCurrency}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.common.labels.status(status: activeOffer.status),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                if (activeOffer.status == OfferStatus.takerPaymentFailed.name &&
                    activeOffer.takerLightningAddress != null &&
                    activeOffer.takerLightningAddress!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      t.lightningAddress.labels.short(
                        address: activeOffer.takerLightningAddress!,
                      ),
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: (activeOffer.status == OfferStatus.takerPaid.name)
                ? null
                : const Icon(Icons.arrow_forward_ios),
            onTap: (activeOffer.status == OfferStatus.takerPaid.name)
                ? null
                : () {
              _handleActiveOfferTap(context, ref, activeOffer, currentPubKey, t);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedOffersSection(BuildContext context, WidgetRef ref, Translations t) {
    return Consumer(
      builder: (context, ref, _) {
        final coordinatorsAsync = ref.watch(discoveredCoordinatorsProvider);
        final finishedAsync = ref.watch(finishedOffersProvider);

        return coordinatorsAsync.when(
          loading: () =>
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Discovering coordinators...'),
                ],
              ),
            ),
          ),
          error: (err, stack) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'Error discovering coordinators: ${err.toString()}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          data: (coordinators) {
            // If no coordinators found, don't show anything
            if (coordinators.isEmpty) {
              return const SizedBox();
            }

            // Now check finished offers
            return finishedAsync.when(
              loading: () =>
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading finished offers...'),
                    ],
                  ),
                ),
              ),
              error: (err, stack) =>
                  Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  t.offers.errors.loadingFinished(details: err.toString()),
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (finishedOffers) {
                if (finishedOffers.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      t.offers.details.finishedOffersWithTime,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ...finishedOffers.map(
                          (offer) =>
                          InkWell(
                            onTap: () {
                              if (kIsWeb) {
                                context.go('/offers/${offer.id}');
                              } else {
                                context.push('/offers/${offer.id}');
                              }
                            },
                            child: Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  "${formatDouble(offer.fiatAmount)} ${offer.fiatCurrency}",
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  t.offers.details.subtitleWithDate(
                                    sats: offer.amountSats,
                                    fee: offer.makerFees,
                                    status: offer.status,
                                    date: offer.takerPaidAt?.toLocal().toString().substring(0, 16) ?? '-',
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                            ),
                          ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleActiveOfferTap(BuildContext context,
      WidgetRef ref,
      Offer activeOffer,
      String? currentPubKey,
      Translations t,) {
    if (activeOffer.holdInvoicePaymentHash != null) {
      ref
          .read(paymentHashProvider.notifier)
          .state = activeOffer.holdInvoicePaymentHash!;
    }

    final offerStatus = OfferStatus.values.byName(activeOffer.status);

    if (offerStatus == OfferStatus.blikReceived || offerStatus == OfferStatus.blikSentToMaker) {
      try {
        ref.read(apiServiceProvider);
        if (currentPubKey == activeOffer.makerPubkey) {
          if (kIsWeb) {
            context.go('/confirm-blik');
          } else {
            context.push('/confirm-blik');
          }
        } else if (currentPubKey == activeOffer.takerPubkey) {
          if (kIsWeb) {
            context.go('/wait-confirmation', extra: activeOffer);
          } else {
            context.push('/wait-confirmation', extra: activeOffer);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.offers.errors.resuming(details: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(activeOfferProvider.notifier).setActiveOffer(null);
      }
    } else {
      if (currentPubKey == activeOffer.makerPubkey) {
        _navigateToMakerStep(context, activeOffer);
      } else if (currentPubKey == activeOffer.takerPubkey) {
        _navigateToTakerStep(context, activeOffer);
      }
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
}
