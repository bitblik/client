import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/offer.dart';
import '../../../i18n/gen/strings.g.dart';
import '../../providers/providers.dart'; // For apiServiceProvider, publicKeyProvider, activeOfferProvider

class TakerExpiredSentBlikScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const TakerExpiredSentBlikScreen({Key? key, required this.offer})
    : super(key: key);

  @override
  ConsumerState<TakerExpiredSentBlikScreen> createState() =>
      _TakerExpiredSentBlikScreenState();
}

class _TakerExpiredSentBlikScreenState
    extends ConsumerState<TakerExpiredSentBlikScreen> {
  bool _isLoading = false;

  Future<void> _handleBlikCharged() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ref.read(apiServiceProvider);
    final takerPubkey = await ref.read(publicKeyProvider.future);

    if (takerPubkey == null || takerPubkey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.system.errors.noPublicKey,
            ), // Corrected translation key
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final result = await apiService.blikChargedByTaker(
        widget.offer.id,
        takerPubkey,
      );
      final message = result['message'] as String? ?? 'Success';
      final newStatusString = result['new_status'] as String?;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

        OfferStatus? newStatus;
        if (newStatusString != null) {
          try {
            newStatus = OfferStatus.values.byName(newStatusString);
          } catch (_) {
            print('Invalid new status received: $newStatusString');
          }
        }

        if (newStatus != null) {
          final updatedOffer = widget.offer.copyWith(status: newStatus.name);
          ref.read(activeOfferProvider.notifier).state = updatedOffer;

          if (newStatus == OfferStatus.conflict) {
            context.go('/taker-conflict', extra: widget.offer.id);
          } else if (newStatus == OfferStatus.takerConfirmed) {
            // UI should update based on the new offer state from activeOfferProvider.
            // No specific navigation here, as the main offer flow handler
            // should pick up the takerConfirmed state.
            print(
              "Offer ${widget.offer.id} moved to takerConfirmed. UI should update via provider.",
            );
          }
        }
        // If no new status or invalid, the activeOfferProvider already holds the offer
        // with its potentially updated status from the 'newStatus' block above.
        // If 'newStatus' was null, the offer in the provider remains as it was,
        // and the UI should reflect that. No explicit refresh call is needed here
        // as per the new instruction.
      }
    } catch (e) {
      print('Error calling blikChargedByTaker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.taker.expiredSentBlikScreen.errorOccurred(error: e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.taker.expiredSentBlikScreen.title),
        automaticallyImplyLeading: false, // To match TakerInvalidBlikScreen
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.timer_off_outlined, // Icon for expired state
                color: Colors.orange,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                t.taker.expiredSentBlikScreen.message,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                t.taker.expiredSentBlikScreen.question,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement re-take offer logic (similar to TakerInvalidBlikScreen if applicable)
                  // This might involve reserving the offer again and navigating to submit-blik.
                  // For now, keeping the placeholder.
                  print(
                    'Re-take offer button pressed for offer: ${widget.offer.id}',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.taker.expiredSentBlikScreen.retakeOfferNotImplemented,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Consistent styling
                  foregroundColor: Colors.white,
                ),
                child: Text(t.taker.expiredSentBlikScreen.retakeOfferButton),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleBlikCharged,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Positive action
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(t.taker.expiredSentBlikScreen.blikUsedButton),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ref.read(activeOfferProvider.notifier).state = null;
                  context.go('/offers');
                },
                child: Text(t.common.actions.cancelAndReturnToOffers),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
