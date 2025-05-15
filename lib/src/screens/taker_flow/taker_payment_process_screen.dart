import 'package:bitblik/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart'; // Import Offer which contains OfferStatus
import '../../providers/providers.dart';

// Define the checklist steps and their corresponding statuses
enum PaymentStep {
  makerConfirmed,
  makerSettled,
  payingTaker,
  takerPaid,
  takerPaymentFailed, // Add failed state
}

final Map<PaymentStep, OfferStatus> stepToStatusMapping = {
  PaymentStep.makerConfirmed: OfferStatus.makerConfirmed,
  PaymentStep.makerSettled: OfferStatus.settled,
  PaymentStep.payingTaker: OfferStatus.payingTaker,
  PaymentStep.takerPaid: OfferStatus.takerPaid,
  PaymentStep.takerPaymentFailed: OfferStatus.takerPaymentFailed,
};

// Define the order of successful steps
const List<PaymentStep> successfulStepsOrder = [
  PaymentStep.makerConfirmed,
  PaymentStep.makerSettled,
  PaymentStep.payingTaker,
  PaymentStep.takerPaid,
];

class TakerPaymentProcessScreen extends ConsumerWidget {
  const TakerPaymentProcessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final paymentHash = ref.watch(paymentHashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentProcessTitle),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        // Add padding around the checklist
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:
              paymentHash == null
                  ? _buildErrorContent(
                    context,
                    l10n.errorMissingPaymentHash, // Use localization
                  )
                  : _buildPollingContent(context, ref, paymentHash),
        ),
      ),
    );
  }

  Widget _buildPollingContent(
    BuildContext context,
    WidgetRef ref,
    String paymentHash,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final statusAsyncValue = ref.watch(pollingOfferStatusProvider(paymentHash));

    return statusAsyncValue.when(
      data: (status) {
        if (status == null) {
          // Still waiting for the first status update
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.waitingForOfferUpdate),
            ],
          );
        }

        // Build the checklist UI based on the current status
        return _PaymentChecklist(
          currentStatus: status,
          paymentHash: paymentHash, // Pass paymentHash
        );
      },
      loading:
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loadingOfferDetails),
            ],
          ),
      error:
          (error, stack) => _buildErrorContent(
            context,
            l10n.errorLoadingOffer(error.toString()),
          ),
    );
  }

  // Helper for displaying general errors (like missing hash or polling failure)
  Widget _buildErrorContent(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        const SizedBox(height: 20),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.red),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => context.go('/'), // Go home on error
          child: Text(l10n.goHome),
        ),
      ],
    );
  }
}

// --- Checklist Widgets ---

class _PaymentChecklist extends ConsumerWidget {
  // Make ConsumerWidget
  final OfferStatus currentStatus;
  final String paymentHash; // Add paymentHash field

  const _PaymentChecklist({
    required this.currentStatus,
    required this.paymentHash, // Add paymentHash to constructor
  });

  String _getStepText(BuildContext context, PaymentStep step) {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case PaymentStep.makerConfirmed:
        return l10n.taskMakerConfirmedBlik;
      case PaymentStep.makerSettled:
        return l10n.taskMakerInvoiceSettled;
      case PaymentStep.payingTaker:
        return l10n.taskPayingTakerInvoice;
      case PaymentStep.takerPaid:
        return l10n.taskTakerInvoicePaid;
      case PaymentStep.takerPaymentFailed:
        return l10n.taskTakerPaymentFailed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    final l10n = AppLocalizations.of(context)!;
    bool isFailed = currentStatus == OfferStatus.takerPaymentFailed;

    // Find the index corresponding to the current status in the successful flow
    int currentStatusOrderIndex = successfulStepsOrder.indexWhere(
      (s) => stepToStatusMapping[s] == currentStatus,
    );

    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(successfulStepsOrder.length, (index) {
            final step = successfulStepsOrder[index];
            ChecklistItemStatus itemStatus;
            int stepOrderIndex = index;

            // --- Refactored Status Logic ---
            if (isFailed) {
              if (stepOrderIndex == successfulStepsOrder.length - 1) {
                itemStatus = ChecklistItemStatus.error;
              } else {
                itemStatus = ChecklistItemStatus.completed;
              }
            } else {
              // Normal flow (not failed)
              if (currentStatusOrderIndex >= stepOrderIndex) {
                itemStatus = ChecklistItemStatus.completed;
              } else if (currentStatusOrderIndex == stepOrderIndex - 1) {
                itemStatus = ChecklistItemStatus.active;
              } else {
                itemStatus = ChecklistItemStatus.pending;
              }
            }
            // --- End Refactored Status Logic ---

            // Determine the correct text based on failure state for the last item
            String itemText;
            if (isFailed && stepOrderIndex == successfulStepsOrder.length - 1) {
              itemText = _getStepText(context, PaymentStep.takerPaymentFailed);
            } else {
              itemText = _getStepText(context, step);
            }

            return _ChecklistItem(
              text: itemText,
              status: itemStatus,
              paymentHash: paymentHash, // Pass paymentHash down
              isLastError:
                  isFailed && stepOrderIndex == successfulStepsOrder.length - 1,
            );
          }),
          // Show Done button only when the final step (takerPaid) is completed
          if (currentStatus == OfferStatus.takerPaid) ...[
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go("/");
                },
                child: Text(l10n.doneButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum ChecklistItemStatus { pending, active, completed, error }

class _ChecklistItem extends ConsumerWidget {
  // Make ConsumerWidget
  final String text;
  final ChecklistItemStatus status;
  final String paymentHash; // Add paymentHash field
  final bool isLastError;

  const _ChecklistItem({
    required this.text,
    required this.status,
    required this.paymentHash, // Add paymentHash to constructor
    this.isLastError = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    final l10n = AppLocalizations.of(context)!;
    Widget leadingIcon;
    Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    TextStyle textStyle =
        Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    switch (status) {
      case ChecklistItemStatus.pending:
        leadingIcon = const Icon(
          Icons.circle_outlined,
          size: 24,
          color: Colors.grey,
        );
        textColor = Colors.grey;
        textStyle = textStyle.copyWith(color: textColor);
        break;
      case ChecklistItemStatus.active:
        leadingIcon = const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        );
        textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
        break;
      case ChecklistItemStatus.completed:
        leadingIcon = const Icon(
          Icons.check_circle,
          size: 24,
          color: Colors.green,
        );
        break;
      case ChecklistItemStatus.error:
        leadingIcon = const Icon(Icons.error, size: 24, color: Colors.red);
        textColor = Colors.red;
        textStyle = textStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leadingIcon,
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: textStyle)),
            ],
          ),
          if (isLastError) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Text(
                l10n.errorTakerPaymentFailed,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.goToFailureDetails),
                onPressed: () {
                  // No longer async
                  // Read the offer directly from the provider state
                  final offer = ref.read(
                    activeOfferProvider,
                  ); // Read state directly

                  if (offer != null) {
                    // Navigate with the offer object if it exists
                    context.go('/taker-failed', extra: offer);
                  } else {
                    // Handle case where offer is unexpectedly null (e.g., show error)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.errorOfferNotFound,
                        ), // Add localization key if needed
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
