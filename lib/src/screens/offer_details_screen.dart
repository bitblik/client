import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../i18n/gen/strings.g.dart';
import '../models/coordinator_info.dart';
import '../models/offer.dart';
import '../providers/providers.dart';
import '../widgets/lightning_address_widget.dart';
import '../widgets/progress_indicators.dart';

class OfferDetailsScreen extends ConsumerStatefulWidget {
  final String offerId;

  const OfferDetailsScreen({super.key, required this.offerId});

  @override
  ConsumerState<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends ConsumerState<OfferDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final offerAsyncValue = ref.watch(offerDetailsProvider(widget.offerId));
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);
    final lightningAddressAsync = ref.watch(lightningAddressProvider);
    final keyService = ref.read(keyServiceProvider);
    final myActiveOffer = ref.watch(activeOfferProvider);
    final t = Translations.of(context);
    final router = GoRouter.of(context);

    final hasLightningAddress = lightningAddressAsync.maybeWhen(
      data: (address) => address != null && address.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.offers.display.selectedOffer)),
      body: offerAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (offer) {
          if (offer == null) {
            return Center(child: Text(t.offers.errors.notFound));
          }

          // Use the enhanced coordinator info provider
          final coordinatorInfoAsync = ref.watch(coordinatorInfoByPubkeyProvider(offer.coordinatorPubkey));
          // Use the helper provider for reservation duration
          final reservationDuration = ref.watch(coordinatorReservationDurationProvider(offer.coordinatorPubkey));

          final bool isFunded = offer.status == OfferStatus.funded.name;
          final bool isReserved = offer.status == OfferStatus.reserved.name;
          final bool isBlikReceived =
              offer.status == OfferStatus.blikReceived.name;

          Widget? trailingWidget;

          if (isFunded) {
            trailingWidget = ElevatedButton(
              onPressed: publicKeyAsyncValue.maybeWhen(
                data:
                    (publicKey) => () {
                      if (publicKey == null) return;

                      // Check if lightning address is set
                      if (!hasLightningAddress) {
                        LightningAddressWidget.showLightningAddressRequiredDialog(
                          context,
                          ref,
                          keyService,
                          t,
                        );
                        return;
                      }

                      final takerId = publicKey;
                      final apiService = ref.read(apiServiceProvider);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      apiService
                          .reserveOffer(
                            offer.id,
                            takerId,
                            offer.coordinatorPubkey,
                          )
                          .then((reservationTimestamp) {
                            if (reservationTimestamp != null) {
                              final updatedOffer = offer.copyWith(
                                status: OfferStatus.reserved.name,
                                takerPubkey: takerId,
                                reservedAt: reservationTimestamp,
                              );

                              ref
                                  .read(activeOfferProvider.notifier)
                                  .setActiveOffer(updatedOffer);

                              router.go("/submit-blik", extra: updatedOffer);
                            } else {
                              Navigator.of(context).pop();
                              ref.read(errorProvider.notifier).state =
                                  t.reservations.errors.failedNoTimestamp;
                              if (scaffoldMessenger.mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t.reservations.errors.failedNoTimestamp,
                                    ),
                                  ),
                                );
                              }
                              ref.invalidate(availableOffersProvider);
                            }
                          })
                          .catchError((e) {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                            final errorMsg = t.reservations.errors
                                .failedToReserve(details: e.toString());
                            ref.read(errorProvider.notifier).state = errorMsg;
                            if (scaffoldMessenger.mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(errorMsg)),
                              );
                            }
                            ref.invalidate(availableOffersProvider);
                          });
                    },
                orElse: () => null,
              ),
              child: Text(t.offers.actions.take),
            );
          } else if (isReserved || isBlikReceived) {
            if (myActiveOffer != null && offer.id == myActiveOffer.id) {
              trailingWidget = ElevatedButton(
                child: Text(t.offers.actions.resume),
                onPressed: () {
                  ref
                      .read(activeOfferProvider.notifier)
                      .setActiveOffer(myActiveOffer);

                  if (myActiveOffer.status == OfferStatus.reserved.name) {
                    router.go("/submit-blik", extra: myActiveOffer);
                  } else {
                    router.go("/wait-confirmation", extra: myActiveOffer);
                  }
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
          } else {
            trailingWidget = Text(
              offer.status.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDetailRow(
                            t.offers.details.amount(
                              amount: offer.amountSats.toString(),
                            ),
                            '',
                          ),
                          _buildDetailRow(
                            t.offers.details.amountWithCurrency(
                              amount: offer.fiatAmount.toString(),
                              currency: offer.fiatCurrency,
                            ),
                            '',
                          ),
                          _buildDetailRow(
                            t.common.labels.status(status: offer.status),
                            '',
                          ),
                          _buildDetailRow('Maker:', offer.makerPubkey),
                          if (offer.takerPubkey != null)
                            _buildDetailRow('Taker:', offer.takerPubkey!),
                          const Divider(height: 32),
                          // Use AsyncValue.when to handle the coordinator info loading states
                          coordinatorInfoAsync.when(
                            loading: () =>
                            const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Loading coordinator info...'),
                              ],
                            ),
                            error: (error, stack) =>
                                Row(
                                  children: [
                                    const Icon(Icons.account_circle, size: 40),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Unknown Coordinator',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Error: ${error.toString()}',
                                            style: const TextStyle(fontSize: 12, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/nostr.png',
                                        width: 32,
                                        height: 32,
                                      ),
                                      onPressed: () async {
                                        final url = Uri.parse(
                                          'https://njump.me/${Nip19.encodePubKey(offer.coordinatorPubkey)}',
                                        );
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                ),
                            data: (coordinatorInfo) {
                              if (coordinatorInfo != null) {
                                return Row(
                                  children: [
                                    if (coordinatorInfo.icon != null &&
                                        coordinatorInfo.icon!.isNotEmpty)
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          coordinatorInfo.icon!,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            coordinatorInfo.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${coordinatorInfo.version ?? 'Unknown'} | Taker Fee: ${coordinatorInfo
                                                .takerFee}%',
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/nostr.png',
                                        width: 32,
                                        height: 32,
                                      ),
                                      onPressed: () async {
                                        final url = Uri.parse(
                                          'https://njump.me/${Nip19.encodePubKey(offer.coordinatorPubkey)}',
                                        );
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                );
                              } else {
                                // Fallback: show basic coordinator info from pubkey
                                return Row(
                                  children: [
                                    const Icon(Icons.account_circle, size: 40),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Unknown Coordinator',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Pubkey: ${offer.coordinatorPubkey.substring(0, 16)}...',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/nostr.png',
                                        width: 32,
                                        height: 32,
                                      ),
                                      onPressed: () async {
                                        final url = Uri.parse(
                                          'https://njump.me/${Nip19.encodePubKey(offer.coordinatorPubkey)}',
                                        );
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      },
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          if (isFunded) ...[
                            const Divider(height: 32),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: LightningAddressWidget(),
                            ),
                          ],
                          if (trailingWidget != null) ...[
                            const SizedBox(height: 16),
                            Center(child: trailingWidget),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (isFunded)
                    FundedOfferProgressIndicator(
                      key: ValueKey('progress_funded_${offer.id}'),
                      createdAt: offer.createdAt,
                    ),
                  if (isReserved &&
                      offer.reservedAt != null &&
                      reservationDuration != null)
                    ReservationProgressIndicator(
                      key: ValueKey(
                        'progress_res_${offer.id}_${reservationDuration.inSeconds}',
                      ),
                      reservedAt: offer.reservedAt!,
                      maxDuration: reservationDuration,
                    ),
                  if (isBlikReceived && offer.blikReceivedAt != null)
                    BlikConfirmationProgressIndicator(
                      key: ValueKey('progress_blik_${offer.id}'),
                      blikReceivedAt: offer.blikReceivedAt!,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (value.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
          ],
        ],
      ),
    );
  }
}

extension OfferCopyWith on Offer {
  Offer copyWith({
    String? id,
    int? amountSats,
    int? takerFees,
    int? makerFees,
    String? fiatCurrency,
    double? fiatAmount,
    String? status,
    String? coordinatorPubkey,
    DateTime? createdAt,
    String? makerPubkey,
    String? takerPubkey,
    DateTime? reservedAt,
    DateTime? blikReceivedAt,
    String? blikCode,
    String? holdInvoicePaymentHash,
  }) {
    return Offer(
      id: id ?? this.id,
      amountSats: amountSats ?? this.amountSats,
      takerFees: takerFees ?? this.takerFees,
      makerFees: makerFees ?? this.makerFees,
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      fiatAmount: fiatAmount ?? this.fiatAmount,
      status: status ?? this.status,
      coordinatorPubkey: coordinatorPubkey ?? this.coordinatorPubkey,
      createdAt: createdAt ?? this.createdAt,
      makerPubkey: makerPubkey ?? this.makerPubkey,
      takerPubkey: takerPubkey ?? this.takerPubkey,
      reservedAt: reservedAt ?? this.reservedAt,
      blikReceivedAt: blikReceivedAt ?? this.blikReceivedAt,
      blikCode: blikCode ?? this.blikCode,
      holdInvoicePaymentHash:
          holdInvoicePaymentHash ?? this.holdInvoicePaymentHash,
    );
  }
}
