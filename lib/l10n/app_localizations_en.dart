// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BitBlik';

  @override
  String get greeting => 'Hello!';

  @override
  String get error => 'Error';

  @override
  String errorLoadingOffer(Object error) {
    return 'Error loading offer: $error';
  }

  @override
  String get errorOfferDetailsMissing => 'Error: Offer details missing or invalid.';

  @override
  String get errorOfferNotFound => 'Error: Offer not found.';

  @override
  String get waitingForBlik => 'Waiting for BLIK';

  @override
  String get offerReservedByTaker => 'Offer Reserved by Taker!';

  @override
  String get waitingForTakerBlik => 'Waiting for Taker to submit their BLIK code.';

  @override
  String get takerHas20Seconds => 'Taker has 20 seconds to provide the code.';

  @override
  String takerHasXSecondsToProvideBlik(int seconds) {
    return 'Taker has $seconds seconds to provide BLIK code.';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get errorActiveOfferDetailsLost => 'Error: Active offer details lost.';

  @override
  String get errorFailedToRetrieveBlik => 'Error: Failed to retrieve BLIK code.';

  @override
  String errorRetrievingBlik(Object details) {
    return 'Error retrieving BLIK code: $details';
  }

  @override
  String offerNoLongerAvailable(Object status) {
    return 'Offer is no longer available (Status: $status).';
  }

  @override
  String get yourOffer => 'Your Offer:';

  @override
  String amountSats(Object amount) {
    return 'Amount: $amount sats';
  }

  @override
  String makerFeeSats(Object fee) {
    return 'Maker Fee: $fee sats';
  }

  @override
  String get makerConfirmedPayment => 'Maker confirmed payment.';

  @override
  String takerFeeSats(Object fee) {
    return 'Taker Fee: $fee sats';
  }

  @override
  String status(Object status) {
    return 'Status: $status';
  }

  @override
  String get waitingForTaker => 'Waiting for a Taker to reserve your offer...';

  @override
  String get cancelOffer => 'Cancel Offer';

  @override
  String get errorCouldNotIdentifyOffer => 'Error: Could not identify offer to cancel.';

  @override
  String offerCannotBeCancelled(Object status) {
    return 'Offer cannot be cancelled in current state ($status).';
  }

  @override
  String get offerCancelledSuccessfully => 'Offer cancelled successfully.';

  @override
  String failedToCancelOffer(Object details) {
    return 'Failed to cancel offer: $details';
  }

  @override
  String get enterLightningAddress => 'Enter your Lightning Address to continue';

  @override
  String get lightningAddressHint => 'user@domain.com';

  @override
  String get lightningAddressLabel => 'Lightning Address';

  @override
  String get lightningAddressInvalid => 'Please enter a valid Lightning Address';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get editLightningAddress => 'Edit Lightning Address';

  @override
  String get cancel => 'Cancel';

  @override
  String get doneButton => 'Done';

  @override
  String get save => 'Save';

  @override
  String get lightningAddressSaved => 'Lightning Address saved!';

  @override
  String get lightningAddressUpdated => 'Lightning Address updated!';

  @override
  String get loadingOfferDetails => 'Loading offer details...';

  @override
  String errorSavingAddress(Object details) {
    return 'Error saving address: $details';
  }

  @override
  String get getNotifiedSimplex => 'Get notified of new orders with SimpleX';

  @override
  String get getNotifiedWithElement => 'Get notified of new orders with Element';

  @override
  String get noOffersAvailable => 'No offers available yet.';

  @override
  String get take => 'TAKE';

  @override
  String get resume => 'RESUME';

  @override
  String offerAmountSats(Object amount) {
    return 'Amount: $amount sats';
  }

  @override
  String offerFeeStatusId(Object fee, Object status) {
    return 'Taker Fee: $fee sats | Status: $status';
  }

  @override
  String get finishedOffers => 'Finished Offers';

  @override
  String errorLoadingOffers(Object details) {
    return 'Error loading offers: $details';
  }

  @override
  String get retry => 'Retry';

  @override
  String get errorOfferUnexpectedState => 'Error: Offer is in an unexpected state.';

  @override
  String get errorPublicKeyNotLoaded => 'Error: Public key not loaded yet.';

  @override
  String get errorInvalidNumberFormat => 'Invalid number format';

  @override
  String get errorAmountMustBePositive => 'Amount must be positive';

  @override
  String get errorInvalidFeePercentage => 'Invalid fee percentage';

  @override
  String errorInitiatingOffer(Object details) {
    return 'Error initiating offer: $details';
  }

  @override
  String get enterAmountToPay => 'Enter Amount (PLN) to Pay:';

  @override
  String get amountLabel => 'Amount (PLN)';

  @override
  String get fetchingExchangeRate => 'Fetching exchange rate...';

  @override
  String satsEquivalent(String sats) {
    return '≈ $sats sats';
  }

  @override
  String plnBtcRate(String rate) {
    return 'PLN/BTC rate ≈ $rate';
  }

  @override
  String get errorFetchingRate => 'Could not fetch exchange rate.';

  @override
  String get generateInvoice => 'Generate Invoice';

  @override
  String get payHoldInvoiceTitle => 'Pay this Hold Invoice:';

  @override
  String get errorCouldNotOpenLightningApp => 'Could not open Lightning app for invoice.';

  @override
  String errorOpeningLightningApp(Object details) {
    return 'Error opening Lightning app: $details';
  }

  @override
  String get copyInvoice => 'Copy Invoice';

  @override
  String get invoiceCopied => 'Invoice copied to clipboard!';

  @override
  String get waitingForPaymentConfirmation => 'Waiting for payment confirmation...';

  @override
  String get errorPublicKeyNotAvailable => 'Public key not available.';

  @override
  String get errorCouldNotFetchActiveOffer => 'Could not fetch active offer details. It might have expired.';

  @override
  String get errorMissingPaymentHashOrKey => 'Error: Missing payment hash or public key.';

  @override
  String errorOfferIncorrectStateConfirmation(Object status) {
    return 'Offer not in correct state for confirmation (Status: $status)';
  }

  @override
  String get paymentConfirmedTakerPaid => 'Payment Confirmed! Taker will be paid.';

  @override
  String get paymentProcessTitle => 'Payment Process';

  @override
  String errorConfirmingPayment(Object details) {
    return 'Error confirming payment: $details';
  }

  @override
  String get blikCopied => 'BLIK code copied to clipboard';

  @override
  String get retrievingBlikCode => 'Retrieving BLIK code...';

  @override
  String get blikCodeReceivedTitle => 'BLIK Code Received!';

  @override
  String get copyToClipboardTooltip => 'Copy to clipboard';

  @override
  String get blikInstructionsMaker => 'Enter this code into the payment terminal. Once the Taker confirms in their bank app and the payment succeeds, press Confirm below.';

  @override
  String get confirmPaymentSuccessButton => 'Confirm Payment Success';

  @override
  String get errorInvalidOfferStateReceived => 'Error: Invalid offer state received.';

  @override
  String get errorInternalOfferIncomplete => 'Internal error: Offer details incomplete.';

  @override
  String get errorOfferInvalidStatus => 'Offer has an invalid status.';

  @override
  String errorOfferNotAwaitingConfirmation(Object status) {
    return 'Offer is no longer awaiting confirmation (Status: $status).';
  }

  @override
  String get errorUnexpectedStatusFromServer => 'Received an unexpected offer status from the server.';

  @override
  String get offerCancelledOrExpired => 'Offer was cancelled or expired.';

  @override
  String get paymentSuccessfulTaker => 'Payment Successful! You should have now received the funds.';

  @override
  String get paymentReceived => 'Payment Received!';

  @override
  String get preparingToSendPayment => 'Preparing to send payment...';

  @override
  String get sendingPayment => 'Sending payment...';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String errorSendingPayment(Object details) {
    return 'Error sending payment: $details';
  }

  @override
  String get errorOfferNotConfirmed => 'Offer not confirmed by maker.';

  @override
  String get errorOfferExpired => 'Offer expired.';

  @override
  String get errorOfferCancelled => 'Offer cancelled.';

  @override
  String get errorOfferPaymentFailed => 'Offer payment failed.';

  @override
  String get errorOfferUnknown => 'Unknown offer error.';

  @override
  String errorOfferUnexpectedStateWithStatus(Object status) {
    return 'Offer is in an unexpected state ($status).';
  }

  @override
  String offerStatusLabel(Object status) {
    return 'Offer Status: $status';
  }

  @override
  String waitingMakerConfirmation(int seconds) {
    return 'Waiting for Maker confirmation: $seconds s';
  }

  @override
  String importantBlikAmountConfirmation(String amount, String currency) {
    return 'VERY IMPORTANT: Be sure to accept only BLIK confirmation for amount of $amount $currency';
  }

  @override
  String get blikInstructionsTaker => 'The offer maker has been sent your BLIK code and needs to enter it in the payment terminal. You then will need to accept the BLIK code in your bank app, be sure to only accept the correct amount. You will receive the Lightning payment automatically after confirmation.';

  @override
  String submitBlikWithinSeconds(int seconds) {
    return 'Submit BLIK within: $seconds s';
  }

  @override
  String errorFetchedOfferIdMismatch(Object fetchedId, Object initialId) {
    return 'Fetched active offer ID ($fetchedId) does not match initial offer ID ($initialId). State mismatch?';
  }

  @override
  String errorOfferNotReserved(Object status) {
    return 'Offer is no longer in reserved state ($status).';
  }

  @override
  String get errorOfferReservationTimestampMissing => 'Offer reservation timestamp is missing.';

  @override
  String get errorOfferPaymentHashMissing => 'Offer payment hash is missing after fetch.';

  @override
  String errorLoadingOfferDetails(Object details) {
    return 'Error loading offer details: $details';
  }

  @override
  String get blikInputTimeExpired => 'BLIK input time expired.';

  @override
  String get errorOfferStateChanged => 'Error: Offer state changed.';

  @override
  String get errorOfferStateNotValid => 'Error: Offer state is no longer valid.';

  @override
  String get errorInvalidBlikFormat => 'Please enter a valid 6-digit BLIK code.';

  @override
  String get errorLightningAddressRequired => 'Lightning Address is required.';

  @override
  String errorSubmittingBlik(Object details) {
    return 'Error submitting BLIK: $details';
  }

  @override
  String get blikPasted => 'Pasted BLIK code.';

  @override
  String get errorClipboardInvalidBlik => 'Clipboard does not contain a valid 6-digit BLIK code.';

  @override
  String get errorOfferDetailsNotLoaded => 'Offer details could not be loaded.';

  @override
  String get selectedOfferLabel => 'Selected Offer:';

  @override
  String offerDetailsSubtitle(int sats, int fee, String status) {
    return '$sats + $fee (fee) sats\nStatus: $status';
  }

  @override
  String get enterBlikCodeLabel => 'Enter 6-digit BLIK Code:';

  @override
  String get blikCodeLabel => 'BLIK Code';

  @override
  String get pasteFromClipboardTooltip => 'Paste from Clipboard';

  @override
  String get submitBlikButton => 'Submit BLIK';

  @override
  String errorCheckingActiveOffers(Object details) {
    return 'Error checking active offers: $details';
  }

  @override
  String get payWithLightningButton => 'PAY with Lightning';

  @override
  String get sellBlikButton => 'SELL BLIK code for sats';

  @override
  String get activeOfferTitle => 'You have an active offer:';

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String get roleMaker => 'Maker';

  @override
  String get roleTaker => 'Taker';

  @override
  String activeOfferSubtitle(String status, int amount) {
    return 'Status: $status\nAmount: $amount sats';
  }

  @override
  String lightningAddressLabelShort(String address) {
    return 'Lightning address: $address';
  }

  @override
  String get errorMakerPublicKeyNotFound => 'Maker public key not found';

  @override
  String errorResumingOffer(Object details) {
    return 'Error resuming offer: $details';
  }

  @override
  String errorLoadingFinishedOffers(Object details) {
    return 'Error loading finished offers: $details';
  }

  @override
  String get finishedOffersTitle => 'Finished Offers (last 24h):';

  @override
  String finishedOfferSubtitle(int sats, int fee, String status, String date) {
    return '$sats + $fee (fee) sats\nStatus: $status\nPaid at: $date';
  }

  @override
  String errorCannotResumeOfferState(Object status) {
    return 'Cannot resume offer in state: $status';
  }

  @override
  String errorCannotResumeTakerOfferState(Object status) {
    return 'Cannot resume Taker offer in state: $status';
  }

  @override
  String get paymentFailedTitle => 'Payment Failed';

  @override
  String paymentFailedInstructions(int netAmount) {
    return 'Please provide a new Lightning invoice for the amount of $netAmount sats.';
  }

  @override
  String get newLightningInvoiceLabel => 'New Lightning Invoice';

  @override
  String get newLightningInvoiceHint => 'Enter your BOLT11 invoice';

  @override
  String get errorEnterValidInvoice => 'Please enter a valid invoice';

  @override
  String errorUpdatingInvoice(Object details) {
    return 'Error updating invoice: $details';
  }

  @override
  String get submitNewInvoiceButton => 'Submit New Invoice';

  @override
  String get offerCompletedTitle => 'Offer Completed';

  @override
  String get paymentConfirmedHeadline => 'Payment Confirmed!';

  @override
  String get takerPaidSubtitle => 'The Taker has been paid.';

  @override
  String get offerDetailsTitle => 'Offer Details:';

  @override
  String offerIdLabel(String id) {
    return 'Offer ID: $id...';
  }

  @override
  String errorLoadingLightningAddress(Object details) {
    return 'Error loading Lightning Address: $details';
  }

  @override
  String get validLightningAddressTooltip => 'Valid Lightning Address';

  @override
  String get errorFailedToReserveOfferNoTimestamp => 'Failed to reserve offer (no timestamp returned).';

  @override
  String errorFailedToReserveOffer(Object details) {
    return 'Failed to reserve offer: $details';
  }

  @override
  String progressWaitingForTaker(String time) {
    return 'Waiting for taker: $time';
  }

  @override
  String progressReserved(int seconds) {
    return 'Reserved: $seconds s left';
  }

  @override
  String progressConfirming(int seconds) {
    return 'Confirming: $seconds s left';
  }

  @override
  String get errorNoPublicKey => 'Error: Could not retrieve your public key.';

  @override
  String get waitingForOfferUpdate => 'Waiting for offer update...';

  @override
  String get loadingPublicKey => 'Loading your details...';

  @override
  String get errorLoadingPublicKey => 'Error loading your details';

  @override
  String get errorMissingPaymentHash => 'Error: Payment details are missing.';

  @override
  String get taskMakerConfirmedBlik => 'Maker confirmed BLIK payment success';

  @override
  String get taskMakerInvoiceSettled => 'Maker hold invoice settled';

  @override
  String get taskPayingTakerInvoice => 'Generating & paying your invoice';

  @override
  String get taskTakerInvoicePaid => 'Your invoice paid successfully';

  @override
  String get taskTakerPaymentFailed => 'Payment to you failed';

  @override
  String get errorTakerPaymentFailed => 'Payment to your Lightning Address failed. Please check the details and provide a new invoice if necessary.';

  @override
  String get goToFailureDetails => 'Go to Failure Details';

  @override
  String get errorTakerPublicKeyNotFound => 'Taker public key not found.';

  @override
  String get paymentRetryFailedError => 'Payment retry failed. Please check the invoice or try again later.';

  @override
  String get paymentSuccessfulTitle => 'Payment Successful';

  @override
  String get paymentSuccessfulMessage => 'Your payment has been processed successfully.';

  @override
  String get goToHomeButton => 'Go to Home';

  @override
  String get makerInvalidBlikTitle => 'Invalid BLIK Code';

  @override
  String get makerInvalidBlikInfo => 'You marked the BLIK code as invalid. Waiting for the taker to provide a new code or initiate a dispute.';

  @override
  String get genericError => 'An unexpected error occurred. Please try again.';

  @override
  String get makerInvalidBlikButton => 'Invalid BLIK Code';

  @override
  String get invalidBlikTitle => 'Invalid BLIK Code';

  @override
  String get invalidBlikMessage => 'Maker Rejected BLIK Code';

  @override
  String get invalidBlikExplanation => 'The Maker has indicated that the BLIK code you provided was invalid or did not work. What would you like to do?';

  @override
  String get invalidBlikRetryButton => 'I DID NOT PAY, reserve Offer again and submit a new BLIK Code';

  @override
  String get invalidBlikConflictButton => 'I CONFIRMED THE BLIK CODE AND IT GOT CHARGED FROM MY BANK ACCOUNT, Report Conflict, will cause DISPUTE!';

  @override
  String get cancelAndReturnHome => 'Return Home';

  @override
  String get conflictReportedSuccess => 'Conflict reported. The coordinator will review the case.';

  @override
  String conflictReportError(Object details) {
    return 'Error reporting conflict: $details';
  }

  @override
  String get takerConflictTitle => 'Offer Conflict';

  @override
  String get takerConflictHeadline => 'Offer Conflict Reported';

  @override
  String get takerConflictBody => 'The Maker marked the BLIK code as invalid, but you have reported a conflict, indicating you believe the payment was successful.';

  @override
  String get takerConflictInstructions => 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';

  @override
  String get takerConflictBackButton => 'Return to Home';

  @override
  String get makerConflictTitle => 'Offer Conflict';

  @override
  String get makerConflictHeadline => 'Offer Conflict Reported';

  @override
  String get makerConflictBody => 'You marked the BLIK code as invalid, but the Taker has reported a conflict, indicating they believe the payment was successful.';

  @override
  String get makerConflictInstructions => 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';

  @override
  String get makerConflictBackButton => 'Return to Home';

  @override
  String get makerConflictConfirmPaymentButton => 'My mistake, confirm BLIK payment success';

  @override
  String get makerConflictOpenDisputeButton => 'Blik payment did NOT succeed, OPEN DISPUTE';

  @override
  String get makerConflictDisputeDialogTitle => 'Open Dispute?';

  @override
  String get makerConflictDisputeDialogContent => 'Opening a dispute requires manual review by the coordinator, which may take time. A dispute fee will be deducted if the dispute is resolved against you. The hold invoice will be settled to prevent expiry. If resolved in your favor, you will be refunded (minus fees) to your Lightning Address.';

  @override
  String get makerConflictDisputeDialogConfirm => 'Open Dispute';

  @override
  String get makerConflictDisputeDialogCancel => 'Cancel';

  @override
  String get makerConflictDisputeDialogContentDetailed => 'Opening a dispute will require manual intervention by the coordinator, which will take time and incur a dispute fee.\n\nThe hold invoice will be settled immediately to prevent expiry before the dispute is resolved.\n\nIf the dispute is resolved in your favor, the sats amount will be refunded to your Lightning Address (minus dispute fees). Please ensure you have a Lightning Address configured.';

  @override
  String get makerConflictSubmitDisputeButton => 'Submit Dispute';

  @override
  String errorOpenDispute(String error) {
    return 'Error opening dispute: $error';
  }

  @override
  String get successOpenDispute => 'Dispute opened successfully. The coordinator will review the case.';

  @override
  String get errorLoadingTimeoutConfiguration => 'Error loading timeout configuration.';

  @override
  String errorAmountTooLowFiat(String minAmount, String currency) {
    return 'Amount is too low. Minimum is $minAmount $currency.';
  }

  @override
  String errorAmountTooHighFiat(String maxAmount, String currency) {
    return 'Amount is too high. Maximum is $maxAmount $currency.';
  }

  @override
  String amountRangeHint(String minAmount, String maxAmount, String currency) {
    return 'Min: $minAmount $currency, Max: $maxAmount $currency';
  }

  @override
  String get errorLoadingCoordinatorConfig => 'Error loading coordinator configuration. Please try again.';
}
