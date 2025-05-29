///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsLightningAddressEn lightningAddress = TranslationsLightningAddressEn.internal(_root);
	late final TranslationsOffersEn offers = TranslationsOffersEn.internal(_root);
	late final TranslationsReservationsEn reservations = TranslationsReservationsEn.internal(_root);
	late final TranslationsExchangeEn exchange = TranslationsExchangeEn.internal(_root);
	late final TranslationsMakerEn maker = TranslationsMakerEn.internal(_root);
	late final TranslationsTakerEn taker = TranslationsTakerEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsSystemEn system = TranslationsSystemEn.internal(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'BitBlik';
	String get greeting => 'Hello!';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCommonButtonsEn buttons = TranslationsCommonButtonsEn.internal(_root);
	late final TranslationsCommonLabelsEn labels = TranslationsCommonLabelsEn.internal(_root);
	late final TranslationsCommonRolesEn roles = TranslationsCommonRolesEn.internal(_root);
	late final TranslationsCommonNotificationsEn notifications = TranslationsCommonNotificationsEn.internal(_root);
	late final TranslationsCommonClipboardEn clipboard = TranslationsCommonClipboardEn.internal(_root);
}

// Path: lightningAddress
class TranslationsLightningAddressEn {
	TranslationsLightningAddressEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsLightningAddressLabelsEn labels = TranslationsLightningAddressLabelsEn.internal(_root);
	late final TranslationsLightningAddressPromptsEn prompts = TranslationsLightningAddressPromptsEn.internal(_root);
	late final TranslationsLightningAddressFeedbackEn feedback = TranslationsLightningAddressFeedbackEn.internal(_root);
	late final TranslationsLightningAddressErrorsEn errors = TranslationsLightningAddressErrorsEn.internal(_root);
}

// Path: offers
class TranslationsOffersEn {
	TranslationsOffersEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOffersDisplayEn display = TranslationsOffersDisplayEn.internal(_root);
	late final TranslationsOffersDetailsEn details = TranslationsOffersDetailsEn.internal(_root);
	late final TranslationsOffersActionsEn actions = TranslationsOffersActionsEn.internal(_root);
	late final TranslationsOffersStatusEn status = TranslationsOffersStatusEn.internal(_root);
	late final TranslationsOffersErrorsEn errors = TranslationsOffersErrorsEn.internal(_root);
}

// Path: reservations
class TranslationsReservationsEn {
	TranslationsReservationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsReservationsActionsEn actions = TranslationsReservationsActionsEn.internal(_root);
	late final TranslationsReservationsFeedbackEn feedback = TranslationsReservationsFeedbackEn.internal(_root);
	late final TranslationsReservationsErrorsEn errors = TranslationsReservationsErrorsEn.internal(_root);
}

// Path: exchange
class TranslationsExchangeEn {
	TranslationsExchangeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsExchangeLabelsEn labels = TranslationsExchangeLabelsEn.internal(_root);
	late final TranslationsExchangeFeedbackEn feedback = TranslationsExchangeFeedbackEn.internal(_root);
	late final TranslationsExchangeErrorsEn errors = TranslationsExchangeErrorsEn.internal(_root);
}

// Path: maker
class TranslationsMakerEn {
	TranslationsMakerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMakerRoleSelectionEn roleSelection = TranslationsMakerRoleSelectionEn.internal(_root);
	late final TranslationsMakerAmountFormEn amountForm = TranslationsMakerAmountFormEn.internal(_root);
	late final TranslationsMakerPayInvoiceEn payInvoice = TranslationsMakerPayInvoiceEn.internal(_root);
	late final TranslationsMakerWaitTakerEn waitTaker = TranslationsMakerWaitTakerEn.internal(_root);
	late final TranslationsMakerWaitForBlikEn waitForBlik = TranslationsMakerWaitForBlikEn.internal(_root);
	late final TranslationsMakerConfirmPaymentEn confirmPayment = TranslationsMakerConfirmPaymentEn.internal(_root);
	late final TranslationsMakerInvalidBlikEn invalidBlik = TranslationsMakerInvalidBlikEn.internal(_root);
	late final TranslationsMakerConflictEn conflict = TranslationsMakerConflictEn.internal(_root);
	late final TranslationsMakerSuccessEn success = TranslationsMakerSuccessEn.internal(_root);
}

// Path: taker
class TranslationsTakerEn {
	TranslationsTakerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTakerRoleSelectionEn roleSelection = TranslationsTakerRoleSelectionEn.internal(_root);
	late final TranslationsTakerSubmitBlikEn submitBlik = TranslationsTakerSubmitBlikEn.internal(_root);
	late final TranslationsTakerWaitConfirmationEn waitConfirmation = TranslationsTakerWaitConfirmationEn.internal(_root);
	late final TranslationsTakerPaymentProcessEn paymentProcess = TranslationsTakerPaymentProcessEn.internal(_root);
	late final TranslationsTakerPaymentFailedEn paymentFailed = TranslationsTakerPaymentFailedEn.internal(_root);
	late final TranslationsTakerPaymentSuccessEn paymentSuccess = TranslationsTakerPaymentSuccessEn.internal(_root);
	late final TranslationsTakerInvalidBlikEn invalidBlik = TranslationsTakerInvalidBlikEn.internal(_root);
	late final TranslationsTakerConflictEn conflict = TranslationsTakerConflictEn.internal(_root);
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsHomeNotificationsEn notifications = TranslationsHomeNotificationsEn.internal(_root);
	late final TranslationsHomeStatisticsEn statistics = TranslationsHomeStatisticsEn.internal(_root);
}

// Path: system
class TranslationsSystemEn {
	TranslationsSystemEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSystemErrorsEn errors = TranslationsSystemErrorsEn.internal(_root);
	late final TranslationsSystemBlikEn blik = TranslationsSystemBlikEn.internal(_root);
}

// Path: common.buttons
class TranslationsCommonButtonsEn {
	TranslationsCommonButtonsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancel => 'Cancel';
	String get save => 'Save';
	String get done => 'Done';
	String get retry => 'Retry';
	String get goHome => 'Go Home';
	String get saveAndContinue => 'Save & Continue';
}

// Path: common.labels
class TranslationsCommonLabelsEn {
	TranslationsCommonLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get amount => 'Amount (PLN)';
	String status({required Object status}) => 'Status: ${status}';
	String role({required Object role}) => 'Role: ${role}';
}

// Path: common.roles
class TranslationsCommonRolesEn {
	TranslationsCommonRolesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get maker => 'Maker';
	String get taker => 'Taker';
}

// Path: common.notifications
class TranslationsCommonNotificationsEn {
	TranslationsCommonNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get success => 'Success';
	String get error => 'Error';
	String get loading => 'Loading...';
}

// Path: common.clipboard
class TranslationsCommonClipboardEn {
	TranslationsCommonClipboardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get copyToClipboard => 'Copy to clipboard';
	String get pasteFromClipboard => 'Paste from Clipboard';
	String get copied => 'Copied to clipboard!';
}

// Path: lightningAddress.labels
class TranslationsLightningAddressLabelsEn {
	TranslationsLightningAddressLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get address => 'Lightning Address';
	String get hint => 'user@domain.com';
	String short({required Object address}) => 'Lightning address: ${address}';
}

// Path: lightningAddress.prompts
class TranslationsLightningAddressPromptsEn {
	TranslationsLightningAddressPromptsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get enter => 'Enter your Lightning Address to continue';
	String get edit => 'Edit Lightning Address';
	String get invalid => 'Please enter a valid Lightning Address';
	String get required => 'Lightning Address is required.';
}

// Path: lightningAddress.feedback
class TranslationsLightningAddressFeedbackEn {
	TranslationsLightningAddressFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get saved => 'Lightning Address saved!';
	String get updated => 'Lightning Address updated!';
	String get valid => 'Valid Lightning Address';
}

// Path: lightningAddress.errors
class TranslationsLightningAddressErrorsEn {
	TranslationsLightningAddressErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String saving({required Object details}) => 'Error saving address: ${details}';
	String loading({required Object details}) => 'Error loading Lightning Address: ${details}';
}

// Path: offers.display
class TranslationsOffersDisplayEn {
	TranslationsOffersDisplayEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get yourOffer => 'Your Offer:';
	String get selectedOffer => 'Selected Offer:';
	String get activeOffer => 'You have an active offer:';
	String get finishedOffers => 'Finished Offers';
	String get finishedOffersWithTime => 'Finished Offers (last 24h):';
	String get noAvailable => 'No offers available yet.';
	String get noSuccessfulTrades => 'No successful trades yet.';
}

// Path: offers.details
class TranslationsOffersDetailsEn {
	TranslationsOffersDetailsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String amount({required Object amount}) => 'Amount: ${amount} sats';
	String amountWithCurrency({required Object amount, required Object currency}) => '${amount} ${currency}';
	String makerFee({required Object fee}) => 'Maker Fee: ${fee} sats';
	String takerFee({required Object fee}) => 'Taker Fee: ${fee} sats';
	String takerFeeWithStatus({required Object fee, required Object status}) => 'Taker Fee: ${fee} sats | Status: ${status}';
	String subtitle({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (fee) sats\nStatus: ${status}';
	String subtitleWithDate({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (fee) sats\nStatus: ${status}\nPaid at: ${date}';
	String activeSubtitle({required Object status, required Object amount}) => 'Status: ${status}\nAmount: ${amount} sats';
	String id({required Object id}) => 'Offer ID: ${id}...';
	String created({required Object dateTime}) => 'Created: ${dateTime}';
	String takenAfter({required Object duration}) => 'Taken after: ${duration}';
	String paidAfter({required Object duration}) => 'Paid after: ${duration}';
}

// Path: offers.actions
class TranslationsOffersActionsEn {
	TranslationsOffersActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get take => 'TAKE';
	String get resume => 'RESUME';
	String get cancel => 'Cancel Offer';
}

// Path: offers.status
class TranslationsOffersStatusEn {
	TranslationsOffersStatusEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get reserved => 'Offer Reserved by Taker!';
	String get cancelled => 'Offer cancelled successfully.';
	String get cancelledOrExpired => 'Offer was cancelled or expired.';
	String noLongerAvailable({required Object status}) => 'Offer is no longer available (Status: ${status}).';
}

// Path: offers.errors
class TranslationsOffersErrorsEn {
	TranslationsOffersErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String loading({required Object details}) => 'Error loading offers: ${details}';
	String loadingDetails({required Object details}) => 'Error loading offer details: ${details}';
	String get detailsMissing => 'Error: Offer details missing or invalid.';
	String get detailsNotLoaded => 'Offer details could not be loaded.';
	String get notFound => 'Error: Offer not found.';
	String get unexpectedState => 'Error: Offer is in an unexpected state.';
	String get unexpectedStateWithStatus => 'Offer is in an unexpected state ({status}).';
	String get invalidStatus => 'Offer has an invalid status.';
	String get couldNotIdentify => 'Error: Could not identify offer to cancel.';
	String get cannotBeCancelled => 'Offer cannot be cancelled in current state ({status}).';
	String failedToCancel({required Object details}) => 'Failed to cancel offer: ${details}';
	String get activeDetailsLost => 'Error: Active offer details lost.';
	String checkingActive({required Object details}) => 'Error checking active offers: ${details}';
	String loadingFinished({required Object details}) => 'Error loading finished offers: ${details}';
	String cannotResume({required Object status}) => 'Cannot resume offer in state: ${status}';
	String cannotResumeTaker({required Object status}) => 'Cannot resume Taker offer in state: ${status}';
	String resuming({required Object details}) => 'Error resuming offer: ${details}';
	String get makerPublicKeyNotFound => 'Maker public key not found';
	String get takerPublicKeyNotFound => 'Taker public key not found.';
}

// Path: reservations.actions
class TranslationsReservationsActionsEn {
	TranslationsReservationsActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancel => 'Cancel Reservation';
}

// Path: reservations.feedback
class TranslationsReservationsFeedbackEn {
	TranslationsReservationsFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get cancelled => 'Reservation cancelled.';
}

// Path: reservations.errors
class TranslationsReservationsErrorsEn {
	TranslationsReservationsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String cancelling({required Object error}) => 'Failed to cancel reservation: ${error}';
	String failedToReserve({required Object details}) => 'Failed to reserve offer: ${details}';
	String get failedNoTimestamp => 'Failed to reserve offer (no timestamp returned).';
	String get timestampMissing => 'Offer reservation timestamp is missing.';
	String get notReserved => 'Offer is no longer in reserved state ({status}).';
}

// Path: exchange.labels
class TranslationsExchangeLabelsEn {
	TranslationsExchangeLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get enterAmount => 'Enter Amount (PLN) to Pay:';
	String equivalent({required Object sats}) => '≈ ${sats} sats';
	String rate({required Object rate}) => 'PLN/BTC rate ≈ ${rate}';
	String rangeHint({required Object minAmount, required Object maxAmount, required Object currency}) => 'Min/Max: ${minAmount}-${maxAmount} ${currency}';
}

// Path: exchange.feedback
class TranslationsExchangeFeedbackEn {
	TranslationsExchangeFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get fetching => 'Fetching exchange rate...';
}

// Path: exchange.errors
class TranslationsExchangeErrorsEn {
	TranslationsExchangeErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get fetchingRate => 'Could not fetch exchange rate.';
	String get invalidFormat => 'Invalid number format';
	String get mustBePositive => 'Amount must be positive';
	String get invalidFeePercentage => 'Invalid fee percentage';
	String tooLowFiat({required Object minAmount, required Object currency}) => 'Amount is too low. Minimum is ${minAmount} ${currency}.';
	String tooHighFiat({required Object maxAmount, required Object currency}) => 'Amount is too high. Maximum is ${maxAmount} ${currency}.';
}

// Path: maker.roleSelection
class TranslationsMakerRoleSelectionEn {
	TranslationsMakerRoleSelectionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get button => 'PAY with Lightning';
}

// Path: maker.amountForm
class TranslationsMakerAmountFormEn {
	TranslationsMakerAmountFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMakerAmountFormActionsEn actions = TranslationsMakerAmountFormActionsEn.internal(_root);
	late final TranslationsMakerAmountFormErrorsEn errors = TranslationsMakerAmountFormErrorsEn.internal(_root);
}

// Path: maker.payInvoice
class TranslationsMakerPayInvoiceEn {
	TranslationsMakerPayInvoiceEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Pay this Hold Invoice:';
	late final TranslationsMakerPayInvoiceActionsEn actions = TranslationsMakerPayInvoiceActionsEn.internal(_root);
	late final TranslationsMakerPayInvoiceFeedbackEn feedback = TranslationsMakerPayInvoiceFeedbackEn.internal(_root);
	late final TranslationsMakerPayInvoiceErrorsEn errors = TranslationsMakerPayInvoiceErrorsEn.internal(_root);
}

// Path: maker.waitTaker
class TranslationsMakerWaitTakerEn {
	TranslationsMakerWaitTakerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get message => 'Waiting for a Taker to reserve your offer...';
	String progressLabel({required Object time}) => 'Waiting for taker: ${time}';
}

// Path: maker.waitForBlik
class TranslationsMakerWaitForBlikEn {
	TranslationsMakerWaitForBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Waiting for BLIK';
	String get message => 'Waiting for Taker to submit their BLIK code.';
	String get timeLimit => 'Taker has 20 seconds to provide the code.';
	String timeLimitWithSeconds({required Object seconds}) => 'Taker has ${seconds} seconds to provide BLIK code.';
	String progressLabel({required Object seconds}) => 'Reserved: ${seconds} s left';
}

// Path: maker.confirmPayment
class TranslationsMakerConfirmPaymentEn {
	TranslationsMakerConfirmPaymentEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'BLIK Code Received!';
	String get retrieving => 'Retrieving BLIK code...';
	String get instructions => 'Enter this code into the payment terminal. Once the Taker confirms in their bank app and the payment succeeds, press Confirm below.';
	late final TranslationsMakerConfirmPaymentActionsEn actions = TranslationsMakerConfirmPaymentActionsEn.internal(_root);
	late final TranslationsMakerConfirmPaymentFeedbackEn feedback = TranslationsMakerConfirmPaymentFeedbackEn.internal(_root);
	late final TranslationsMakerConfirmPaymentErrorsEn errors = TranslationsMakerConfirmPaymentErrorsEn.internal(_root);
}

// Path: maker.invalidBlik
class TranslationsMakerInvalidBlikEn {
	TranslationsMakerInvalidBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Invalid BLIK Code';
	String get info => 'You marked the BLIK code as invalid. Waiting for the taker to provide a new code or initiate a dispute.';
}

// Path: maker.conflict
class TranslationsMakerConflictEn {
	TranslationsMakerConflictEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Offer Conflict';
	String get headline => 'Offer Conflict Reported';
	String get body => 'You marked the BLIK code as invalid, but the Taker has reported a conflict, indicating they believe the payment was successful.';
	String get instructions => 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';
	late final TranslationsMakerConflictActionsEn actions = TranslationsMakerConflictActionsEn.internal(_root);
	late final TranslationsMakerConflictDisputeDialogEn disputeDialog = TranslationsMakerConflictDisputeDialogEn.internal(_root);
	late final TranslationsMakerConflictFeedbackEn feedback = TranslationsMakerConflictFeedbackEn.internal(_root);
	late final TranslationsMakerConflictErrorsEn errors = TranslationsMakerConflictErrorsEn.internal(_root);
}

// Path: maker.success
class TranslationsMakerSuccessEn {
	TranslationsMakerSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Offer Completed';
	String get headline => 'Payment Confirmed!';
	String get subtitle => 'The Taker has been paid.';
	String get detailsTitle => 'Offer Details:';
}

// Path: taker.roleSelection
class TranslationsTakerRoleSelectionEn {
	TranslationsTakerRoleSelectionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get button => 'SELL BLIK code for sats';
}

// Path: taker.submitBlik
class TranslationsTakerSubmitBlikEn {
	TranslationsTakerSubmitBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Enter 6-digit BLIK Code:';
	String get label => 'BLIK Code';
	String timeLimit({required Object seconds}) => 'Submit BLIK within: ${seconds} s';
	String get timeExpired => 'BLIK input time expired.';
	late final TranslationsTakerSubmitBlikActionsEn actions = TranslationsTakerSubmitBlikActionsEn.internal(_root);
	late final TranslationsTakerSubmitBlikFeedbackEn feedback = TranslationsTakerSubmitBlikFeedbackEn.internal(_root);
	late final TranslationsTakerSubmitBlikValidationEn validation = TranslationsTakerSubmitBlikValidationEn.internal(_root);
	late final TranslationsTakerSubmitBlikErrorsEn errors = TranslationsTakerSubmitBlikErrorsEn.internal(_root);
}

// Path: taker.waitConfirmation
class TranslationsTakerWaitConfirmationEn {
	TranslationsTakerWaitConfirmationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String statusLabel({required Object status}) => 'Offer Status: ${status}';
	String waitingMaker({required Object seconds}) => 'Waiting for Maker confirmation: ${seconds} s';
	String importantNotice({required Object amount, required Object currency}) => 'VERY IMPORTANT: Be sure to accept only BLIK confirmation for amount of ${amount} ${currency}';
	String get instructions => 'The offer maker has been sent your BLIK code and needs to enter it in the payment terminal. You then will need to accept the BLIK code in your bank app, be sure to only accept the correct amount. You will receive the Lightning payment automatically after confirmation.';
	late final TranslationsTakerWaitConfirmationFeedbackEn feedback = TranslationsTakerWaitConfirmationFeedbackEn.internal(_root);
}

// Path: taker.paymentProcess
class TranslationsTakerPaymentProcessEn {
	TranslationsTakerPaymentProcessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Payment Process';
	late final TranslationsTakerPaymentProcessStatesEn states = TranslationsTakerPaymentProcessStatesEn.internal(_root);
	late final TranslationsTakerPaymentProcessTasksEn tasks = TranslationsTakerPaymentProcessTasksEn.internal(_root);
	late final TranslationsTakerPaymentProcessErrorsEn errors = TranslationsTakerPaymentProcessErrorsEn.internal(_root);
	late final TranslationsTakerPaymentProcessLoadingEn loading = TranslationsTakerPaymentProcessLoadingEn.internal(_root);
	late final TranslationsTakerPaymentProcessActionsEn actions = TranslationsTakerPaymentProcessActionsEn.internal(_root);
}

// Path: taker.paymentFailed
class TranslationsTakerPaymentFailedEn {
	TranslationsTakerPaymentFailedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Payment Failed';
	String instructions({required Object netAmount}) => 'Please provide a new Lightning invoice for the amount of ${netAmount} sats.';
	late final TranslationsTakerPaymentFailedFormEn form = TranslationsTakerPaymentFailedFormEn.internal(_root);
	late final TranslationsTakerPaymentFailedActionsEn actions = TranslationsTakerPaymentFailedActionsEn.internal(_root);
	late final TranslationsTakerPaymentFailedErrorsEn errors = TranslationsTakerPaymentFailedErrorsEn.internal(_root);
}

// Path: taker.paymentSuccess
class TranslationsTakerPaymentSuccessEn {
	TranslationsTakerPaymentSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Payment Successful';
	String get message => 'Your payment has been processed successfully.';
	late final TranslationsTakerPaymentSuccessActionsEn actions = TranslationsTakerPaymentSuccessActionsEn.internal(_root);
}

// Path: taker.invalidBlik
class TranslationsTakerInvalidBlikEn {
	TranslationsTakerInvalidBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Invalid BLIK Code';
	String get message => 'Maker Rejected BLIK Code';
	String get explanation => 'The Maker has indicated that the BLIK code you provided was invalid or did not work. What would you like to do?';
	late final TranslationsTakerInvalidBlikActionsEn actions = TranslationsTakerInvalidBlikActionsEn.internal(_root);
	late final TranslationsTakerInvalidBlikErrorsEn errors = TranslationsTakerInvalidBlikErrorsEn.internal(_root);
}

// Path: taker.conflict
class TranslationsTakerConflictEn {
	TranslationsTakerConflictEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Offer Conflict';
	String get headline => 'Offer Conflict Reported';
	String get body => 'The Maker marked the BLIK code as invalid, but you have reported a conflict, indicating you believe the payment was successful.';
	String get instructions => 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';
	late final TranslationsTakerConflictActionsEn actions = TranslationsTakerConflictActionsEn.internal(_root);
	late final TranslationsTakerConflictFeedbackEn feedback = TranslationsTakerConflictFeedbackEn.internal(_root);
	late final TranslationsTakerConflictErrorsEn errors = TranslationsTakerConflictErrorsEn.internal(_root);
}

// Path: home.notifications
class TranslationsHomeNotificationsEn {
	TranslationsHomeNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get simplex => 'Get notified of new orders with SimpleX';
	String get element => 'Get notified of new orders with Element';
}

// Path: home.statistics
class TranslationsHomeStatisticsEn {
	TranslationsHomeStatisticsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Finished recent trades';
	String lifetimeCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'All: ${count} trades\nWaited in avg ${avgBlikTime} to receive BLIK code\nFull transaction avg time ${avgPaidTime}';
	String last7DaysCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Last 7d: ${count} trades\nWaited in avg ${avgBlikTime} to receive BLIK code\nFull transaction avg time ${avgPaidTime}';
	late final TranslationsHomeStatisticsErrorsEn errors = TranslationsHomeStatisticsErrorsEn.internal(_root);
}

// Path: system.errors
class TranslationsSystemErrorsEn {
	TranslationsSystemErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get generic => 'An unexpected error occurred. Please try again.';
	String get loadingTimeoutConfig => 'Error loading timeout configuration.';
	String get loadingCoordinatorConfig => 'Error loading coordinator configuration. Please try again.';
}

// Path: system.blik
class TranslationsSystemBlikEn {
	TranslationsSystemBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get copied => 'BLIK code copied to clipboard';
}

// Path: maker.amountForm.actions
class TranslationsMakerAmountFormActionsEn {
	TranslationsMakerAmountFormActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get generateInvoice => 'Generate Invoice';
}

// Path: maker.amountForm.errors
class TranslationsMakerAmountFormErrorsEn {
	TranslationsMakerAmountFormErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String initiating({required Object details}) => 'Error initiating offer: ${details}';
	String get publicKeyNotLoaded => 'Error: Public key not loaded yet.';
}

// Path: maker.payInvoice.actions
class TranslationsMakerPayInvoiceActionsEn {
	TranslationsMakerPayInvoiceActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get copy => 'Copy Invoice';
}

// Path: maker.payInvoice.feedback
class TranslationsMakerPayInvoiceFeedbackEn {
	TranslationsMakerPayInvoiceFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get copied => 'Invoice copied to clipboard!';
	String get waitingConfirmation => 'Waiting for payment confirmation...';
}

// Path: maker.payInvoice.errors
class TranslationsMakerPayInvoiceErrorsEn {
	TranslationsMakerPayInvoiceErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get couldNotOpenApp => 'Could not open Lightning app for invoice.';
	String openingApp({required Object details}) => 'Error opening Lightning app: ${details}';
	String get publicKeyNotAvailable => 'Public key not available.';
	String get couldNotFetchActive => 'Could not fetch active offer details. It might have expired.';
}

// Path: maker.confirmPayment.actions
class TranslationsMakerConfirmPaymentActionsEn {
	TranslationsMakerConfirmPaymentActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get confirm => 'Confirm Payment Success';
	String get markInvalid => 'Invalid BLIK Code';
}

// Path: maker.confirmPayment.feedback
class TranslationsMakerConfirmPaymentFeedbackEn {
	TranslationsMakerConfirmPaymentFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get confirmed => 'Maker confirmed payment.';
	String get confirmedTakerPaid => 'Payment Confirmed! Taker will be paid.';
	String progressLabel({required Object seconds}) => 'Confirming: ${seconds} s left';
}

// Path: maker.confirmPayment.errors
class TranslationsMakerConfirmPaymentErrorsEn {
	TranslationsMakerConfirmPaymentErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get failedToRetrieve => 'Error: Failed to retrieve BLIK code.';
	String retrieving({required Object details}) => 'Error retrieving BLIK code: ${details}';
	String get missingHashOrKey => 'Error: Missing payment hash or public key.';
	String incorrectState({required Object status}) => 'Offer not in correct state for confirmation (Status: ${status})';
	String confirming({required Object details}) => 'Error confirming payment: ${details}';
	String get invalidState => 'Error: Invalid offer state received.';
	String get internalIncomplete => 'Internal error: Offer details incomplete.';
	String notAwaitingConfirmation({required Object status}) => 'Offer is no longer awaiting confirmation (Status: ${status}).';
	String get unexpectedStatus => 'Received an unexpected offer status from the server.';
}

// Path: maker.conflict.actions
class TranslationsMakerConflictActionsEn {
	TranslationsMakerConflictActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get back => 'Return to Home';
	String get confirmPayment => 'My mistake, confirm BLIK payment success';
	String get openDispute => 'Blik payment did NOT succeed, OPEN DISPUTE';
	String get submitDispute => 'Submit Dispute';
}

// Path: maker.conflict.disputeDialog
class TranslationsMakerConflictDisputeDialogEn {
	TranslationsMakerConflictDisputeDialogEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Open Dispute?';
	String get content => 'Opening a dispute requires manual review by the coordinator, which may take time. A dispute fee will be deducted if the dispute is resolved against you. The hold invoice will be settled to prevent expiry. If resolved in your favor, you will be refunded (minus fees) to your Lightning Address.';
	String get contentDetailed => 'Opening a dispute will require manual intervention by the coordinator, which will take time and incur a dispute fee.\n\nThe hold invoice will be settled immediately to prevent expiry before the dispute is resolved.\n\nIf the dispute is resolved in your favor, the sats amount will be refunded to your Lightning Address (minus dispute fees). Please ensure you have a Lightning Address configured.';
	String get confirm => 'Open Dispute';
	String get cancel => 'Cancel';
}

// Path: maker.conflict.feedback
class TranslationsMakerConflictFeedbackEn {
	TranslationsMakerConflictFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get disputeSuccess => 'Dispute opened successfully. The coordinator will review the case.';
}

// Path: maker.conflict.errors
class TranslationsMakerConflictErrorsEn {
	TranslationsMakerConflictErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String openingDispute({required Object error}) => 'Error opening dispute: ${error}';
}

// Path: taker.submitBlik.actions
class TranslationsTakerSubmitBlikActionsEn {
	TranslationsTakerSubmitBlikActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get submit => 'Submit BLIK';
}

// Path: taker.submitBlik.feedback
class TranslationsTakerSubmitBlikFeedbackEn {
	TranslationsTakerSubmitBlikFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pasted => 'Pasted BLIK code.';
}

// Path: taker.submitBlik.validation
class TranslationsTakerSubmitBlikValidationEn {
	TranslationsTakerSubmitBlikValidationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get invalidFormat => 'Please enter a valid 6-digit BLIK code.';
}

// Path: taker.submitBlik.errors
class TranslationsTakerSubmitBlikErrorsEn {
	TranslationsTakerSubmitBlikErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String submitting({required Object details}) => 'Error submitting BLIK: ${details}';
	String get clipboardInvalid => 'Clipboard does not contain a valid 6-digit BLIK code.';
	String get stateChanged => 'Error: Offer state changed.';
	String get stateNotValid => 'Error: Offer state is no longer valid.';
	String get fetchedIdMismatch => 'Fetched active offer ID ({fetchedId}) does not match initial offer ID ({initialId}). State mismatch?';
	String get paymentHashMissing => 'Offer payment hash is missing after fetch.';
}

// Path: taker.waitConfirmation.feedback
class TranslationsTakerWaitConfirmationFeedbackEn {
	TranslationsTakerWaitConfirmationFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get makerConfirmed => 'Maker confirmed payment.';
	String get paymentSuccessful => 'Payment Successful! You should have now received the funds.';
}

// Path: taker.paymentProcess.states
class TranslationsTakerPaymentProcessStatesEn {
	TranslationsTakerPaymentProcessStatesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get preparing => 'Preparing to send payment...';
	String get sending => 'Sending payment...';
	String get received => 'Payment Received!';
	String get failed => 'Payment Failed';
	String get waitingUpdate => 'Waiting for offer update...';
}

// Path: taker.paymentProcess.tasks
class TranslationsTakerPaymentProcessTasksEn {
	TranslationsTakerPaymentProcessTasksEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get makerConfirmedBlik => 'Maker confirmed BLIK payment success';
	String get makerInvoiceSettled => 'Maker hold invoice settled';
	String get payingInvoice => 'Generating & paying your invoice';
	String get invoicePaid => 'Your invoice paid successfully';
	String get paymentFailed => 'Payment to you failed';
}

// Path: taker.paymentProcess.errors
class TranslationsTakerPaymentProcessErrorsEn {
	TranslationsTakerPaymentProcessErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String sending({required Object details}) => 'Error sending payment: ${details}';
	String get notConfirmed => 'Offer not confirmed by maker.';
	String get expired => 'Offer expired.';
	String get cancelled => 'Offer cancelled.';
	String get paymentFailed => 'Offer payment failed.';
	String get unknown => 'Unknown offer error.';
	String get takerPaymentFailed => 'Payment to your Lightning Address failed. Please check the details and provide a new invoice if necessary.';
	String get noPublicKey => 'Error: Could not retrieve your public key.';
	String get loadingPublicKey => 'Error loading your details';
	String get missingPaymentHash => 'Error: Payment details are missing.';
}

// Path: taker.paymentProcess.loading
class TranslationsTakerPaymentProcessLoadingEn {
	TranslationsTakerPaymentProcessLoadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get publicKey => 'Loading your details...';
}

// Path: taker.paymentProcess.actions
class TranslationsTakerPaymentProcessActionsEn {
	TranslationsTakerPaymentProcessActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get goToFailureDetails => 'Go to Failure Details';
}

// Path: taker.paymentFailed.form
class TranslationsTakerPaymentFailedFormEn {
	TranslationsTakerPaymentFailedFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'New Lightning Invoice';
	String get hint => 'Enter your BOLT11 invoice';
}

// Path: taker.paymentFailed.actions
class TranslationsTakerPaymentFailedActionsEn {
	TranslationsTakerPaymentFailedActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get submit => 'Submit New Invoice';
}

// Path: taker.paymentFailed.errors
class TranslationsTakerPaymentFailedErrorsEn {
	TranslationsTakerPaymentFailedErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get enterValid => 'Please enter a valid invoice';
	String updating({required Object details}) => 'Error updating invoice: ${details}';
	String get retryFailed => 'Payment retry failed. Please check the invoice or try again later.';
}

// Path: taker.paymentSuccess.actions
class TranslationsTakerPaymentSuccessActionsEn {
	TranslationsTakerPaymentSuccessActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get goHome => 'Go to Home';
}

// Path: taker.invalidBlik.actions
class TranslationsTakerInvalidBlikActionsEn {
	TranslationsTakerInvalidBlikActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get retry => 'I DID NOT PAY, reserve Offer again and submit a new BLIK Code';
	String get reportConflict => 'I CONFIRMED THE BLIK CODE AND IT GOT CHARGED FROM MY BANK ACCOUNT, Report Conflict, will cause DISPUTE!';
	String get returnHome => 'Return Home';
}

// Path: taker.invalidBlik.errors
class TranslationsTakerInvalidBlikErrorsEn {
	TranslationsTakerInvalidBlikErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get reservationFailed => 'dupa dupa';
}

// Path: taker.conflict.actions
class TranslationsTakerConflictActionsEn {
	TranslationsTakerConflictActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get back => 'Return to Home';
}

// Path: taker.conflict.feedback
class TranslationsTakerConflictFeedbackEn {
	TranslationsTakerConflictFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get reported => 'Conflict reported. The coordinator will review the case.';
}

// Path: taker.conflict.errors
class TranslationsTakerConflictErrorsEn {
	TranslationsTakerConflictErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String reporting({required Object details}) => 'Error reporting conflict: ${details}';
}

// Path: home.statistics.errors
class TranslationsHomeStatisticsErrorsEn {
	TranslationsHomeStatisticsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String loading({required Object error}) => 'Error loading statistics: ${error}';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'BitBlik';
			case 'app.greeting': return 'Hello!';
			case 'common.buttons.cancel': return 'Cancel';
			case 'common.buttons.save': return 'Save';
			case 'common.buttons.done': return 'Done';
			case 'common.buttons.retry': return 'Retry';
			case 'common.buttons.goHome': return 'Go Home';
			case 'common.buttons.saveAndContinue': return 'Save & Continue';
			case 'common.labels.amount': return 'Amount (PLN)';
			case 'common.labels.status': return ({required Object status}) => 'Status: ${status}';
			case 'common.labels.role': return ({required Object role}) => 'Role: ${role}';
			case 'common.roles.maker': return 'Maker';
			case 'common.roles.taker': return 'Taker';
			case 'common.notifications.success': return 'Success';
			case 'common.notifications.error': return 'Error';
			case 'common.notifications.loading': return 'Loading...';
			case 'common.clipboard.copyToClipboard': return 'Copy to clipboard';
			case 'common.clipboard.pasteFromClipboard': return 'Paste from Clipboard';
			case 'common.clipboard.copied': return 'Copied to clipboard!';
			case 'lightningAddress.labels.address': return 'Lightning Address';
			case 'lightningAddress.labels.hint': return 'user@domain.com';
			case 'lightningAddress.labels.short': return ({required Object address}) => 'Lightning address: ${address}';
			case 'lightningAddress.prompts.enter': return 'Enter your Lightning Address to continue';
			case 'lightningAddress.prompts.edit': return 'Edit Lightning Address';
			case 'lightningAddress.prompts.invalid': return 'Please enter a valid Lightning Address';
			case 'lightningAddress.prompts.required': return 'Lightning Address is required.';
			case 'lightningAddress.feedback.saved': return 'Lightning Address saved!';
			case 'lightningAddress.feedback.updated': return 'Lightning Address updated!';
			case 'lightningAddress.feedback.valid': return 'Valid Lightning Address';
			case 'lightningAddress.errors.saving': return ({required Object details}) => 'Error saving address: ${details}';
			case 'lightningAddress.errors.loading': return ({required Object details}) => 'Error loading Lightning Address: ${details}';
			case 'offers.display.yourOffer': return 'Your Offer:';
			case 'offers.display.selectedOffer': return 'Selected Offer:';
			case 'offers.display.activeOffer': return 'You have an active offer:';
			case 'offers.display.finishedOffers': return 'Finished Offers';
			case 'offers.display.finishedOffersWithTime': return 'Finished Offers (last 24h):';
			case 'offers.display.noAvailable': return 'No offers available yet.';
			case 'offers.display.noSuccessfulTrades': return 'No successful trades yet.';
			case 'offers.details.amount': return ({required Object amount}) => 'Amount: ${amount} sats';
			case 'offers.details.amountWithCurrency': return ({required Object amount, required Object currency}) => '${amount} ${currency}';
			case 'offers.details.makerFee': return ({required Object fee}) => 'Maker Fee: ${fee} sats';
			case 'offers.details.takerFee': return ({required Object fee}) => 'Taker Fee: ${fee} sats';
			case 'offers.details.takerFeeWithStatus': return ({required Object fee, required Object status}) => 'Taker Fee: ${fee} sats | Status: ${status}';
			case 'offers.details.subtitle': return ({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (fee) sats\nStatus: ${status}';
			case 'offers.details.subtitleWithDate': return ({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (fee) sats\nStatus: ${status}\nPaid at: ${date}';
			case 'offers.details.activeSubtitle': return ({required Object status, required Object amount}) => 'Status: ${status}\nAmount: ${amount} sats';
			case 'offers.details.id': return ({required Object id}) => 'Offer ID: ${id}...';
			case 'offers.details.created': return ({required Object dateTime}) => 'Created: ${dateTime}';
			case 'offers.details.takenAfter': return ({required Object duration}) => 'Taken after: ${duration}';
			case 'offers.details.paidAfter': return ({required Object duration}) => 'Paid after: ${duration}';
			case 'offers.actions.take': return 'TAKE';
			case 'offers.actions.resume': return 'RESUME';
			case 'offers.actions.cancel': return 'Cancel Offer';
			case 'offers.status.reserved': return 'Offer Reserved by Taker!';
			case 'offers.status.cancelled': return 'Offer cancelled successfully.';
			case 'offers.status.cancelledOrExpired': return 'Offer was cancelled or expired.';
			case 'offers.status.noLongerAvailable': return ({required Object status}) => 'Offer is no longer available (Status: ${status}).';
			case 'offers.errors.loading': return ({required Object details}) => 'Error loading offers: ${details}';
			case 'offers.errors.loadingDetails': return ({required Object details}) => 'Error loading offer details: ${details}';
			case 'offers.errors.detailsMissing': return 'Error: Offer details missing or invalid.';
			case 'offers.errors.detailsNotLoaded': return 'Offer details could not be loaded.';
			case 'offers.errors.notFound': return 'Error: Offer not found.';
			case 'offers.errors.unexpectedState': return 'Error: Offer is in an unexpected state.';
			case 'offers.errors.unexpectedStateWithStatus': return 'Offer is in an unexpected state ({status}).';
			case 'offers.errors.invalidStatus': return 'Offer has an invalid status.';
			case 'offers.errors.couldNotIdentify': return 'Error: Could not identify offer to cancel.';
			case 'offers.errors.cannotBeCancelled': return 'Offer cannot be cancelled in current state ({status}).';
			case 'offers.errors.failedToCancel': return ({required Object details}) => 'Failed to cancel offer: ${details}';
			case 'offers.errors.activeDetailsLost': return 'Error: Active offer details lost.';
			case 'offers.errors.checkingActive': return ({required Object details}) => 'Error checking active offers: ${details}';
			case 'offers.errors.loadingFinished': return ({required Object details}) => 'Error loading finished offers: ${details}';
			case 'offers.errors.cannotResume': return ({required Object status}) => 'Cannot resume offer in state: ${status}';
			case 'offers.errors.cannotResumeTaker': return ({required Object status}) => 'Cannot resume Taker offer in state: ${status}';
			case 'offers.errors.resuming': return ({required Object details}) => 'Error resuming offer: ${details}';
			case 'offers.errors.makerPublicKeyNotFound': return 'Maker public key not found';
			case 'offers.errors.takerPublicKeyNotFound': return 'Taker public key not found.';
			case 'reservations.actions.cancel': return 'Cancel Reservation';
			case 'reservations.feedback.cancelled': return 'Reservation cancelled.';
			case 'reservations.errors.cancelling': return ({required Object error}) => 'Failed to cancel reservation: ${error}';
			case 'reservations.errors.failedToReserve': return ({required Object details}) => 'Failed to reserve offer: ${details}';
			case 'reservations.errors.failedNoTimestamp': return 'Failed to reserve offer (no timestamp returned).';
			case 'reservations.errors.timestampMissing': return 'Offer reservation timestamp is missing.';
			case 'reservations.errors.notReserved': return 'Offer is no longer in reserved state ({status}).';
			case 'exchange.labels.enterAmount': return 'Enter Amount (PLN) to Pay:';
			case 'exchange.labels.equivalent': return ({required Object sats}) => '≈ ${sats} sats';
			case 'exchange.labels.rate': return ({required Object rate}) => 'PLN/BTC rate ≈ ${rate}';
			case 'exchange.labels.rangeHint': return ({required Object minAmount, required Object maxAmount, required Object currency}) => 'Min/Max: ${minAmount}-${maxAmount} ${currency}';
			case 'exchange.feedback.fetching': return 'Fetching exchange rate...';
			case 'exchange.errors.fetchingRate': return 'Could not fetch exchange rate.';
			case 'exchange.errors.invalidFormat': return 'Invalid number format';
			case 'exchange.errors.mustBePositive': return 'Amount must be positive';
			case 'exchange.errors.invalidFeePercentage': return 'Invalid fee percentage';
			case 'exchange.errors.tooLowFiat': return ({required Object minAmount, required Object currency}) => 'Amount is too low. Minimum is ${minAmount} ${currency}.';
			case 'exchange.errors.tooHighFiat': return ({required Object maxAmount, required Object currency}) => 'Amount is too high. Maximum is ${maxAmount} ${currency}.';
			case 'maker.roleSelection.button': return 'PAY with Lightning';
			case 'maker.amountForm.actions.generateInvoice': return 'Generate Invoice';
			case 'maker.amountForm.errors.initiating': return ({required Object details}) => 'Error initiating offer: ${details}';
			case 'maker.amountForm.errors.publicKeyNotLoaded': return 'Error: Public key not loaded yet.';
			case 'maker.payInvoice.title': return 'Pay this Hold Invoice:';
			case 'maker.payInvoice.actions.copy': return 'Copy Invoice';
			case 'maker.payInvoice.feedback.copied': return 'Invoice copied to clipboard!';
			case 'maker.payInvoice.feedback.waitingConfirmation': return 'Waiting for payment confirmation...';
			case 'maker.payInvoice.errors.couldNotOpenApp': return 'Could not open Lightning app for invoice.';
			case 'maker.payInvoice.errors.openingApp': return ({required Object details}) => 'Error opening Lightning app: ${details}';
			case 'maker.payInvoice.errors.publicKeyNotAvailable': return 'Public key not available.';
			case 'maker.payInvoice.errors.couldNotFetchActive': return 'Could not fetch active offer details. It might have expired.';
			case 'maker.waitTaker.message': return 'Waiting for a Taker to reserve your offer...';
			case 'maker.waitTaker.progressLabel': return ({required Object time}) => 'Waiting for taker: ${time}';
			case 'maker.waitForBlik.title': return 'Waiting for BLIK';
			case 'maker.waitForBlik.message': return 'Waiting for Taker to submit their BLIK code.';
			case 'maker.waitForBlik.timeLimit': return 'Taker has 20 seconds to provide the code.';
			case 'maker.waitForBlik.timeLimitWithSeconds': return ({required Object seconds}) => 'Taker has ${seconds} seconds to provide BLIK code.';
			case 'maker.waitForBlik.progressLabel': return ({required Object seconds}) => 'Reserved: ${seconds} s left';
			case 'maker.confirmPayment.title': return 'BLIK Code Received!';
			case 'maker.confirmPayment.retrieving': return 'Retrieving BLIK code...';
			case 'maker.confirmPayment.instructions': return 'Enter this code into the payment terminal. Once the Taker confirms in their bank app and the payment succeeds, press Confirm below.';
			case 'maker.confirmPayment.actions.confirm': return 'Confirm Payment Success';
			case 'maker.confirmPayment.actions.markInvalid': return 'Invalid BLIK Code';
			case 'maker.confirmPayment.feedback.confirmed': return 'Maker confirmed payment.';
			case 'maker.confirmPayment.feedback.confirmedTakerPaid': return 'Payment Confirmed! Taker will be paid.';
			case 'maker.confirmPayment.feedback.progressLabel': return ({required Object seconds}) => 'Confirming: ${seconds} s left';
			case 'maker.confirmPayment.errors.failedToRetrieve': return 'Error: Failed to retrieve BLIK code.';
			case 'maker.confirmPayment.errors.retrieving': return ({required Object details}) => 'Error retrieving BLIK code: ${details}';
			case 'maker.confirmPayment.errors.missingHashOrKey': return 'Error: Missing payment hash or public key.';
			case 'maker.confirmPayment.errors.incorrectState': return ({required Object status}) => 'Offer not in correct state for confirmation (Status: ${status})';
			case 'maker.confirmPayment.errors.confirming': return ({required Object details}) => 'Error confirming payment: ${details}';
			case 'maker.confirmPayment.errors.invalidState': return 'Error: Invalid offer state received.';
			case 'maker.confirmPayment.errors.internalIncomplete': return 'Internal error: Offer details incomplete.';
			case 'maker.confirmPayment.errors.notAwaitingConfirmation': return ({required Object status}) => 'Offer is no longer awaiting confirmation (Status: ${status}).';
			case 'maker.confirmPayment.errors.unexpectedStatus': return 'Received an unexpected offer status from the server.';
			case 'maker.invalidBlik.title': return 'Invalid BLIK Code';
			case 'maker.invalidBlik.info': return 'You marked the BLIK code as invalid. Waiting for the taker to provide a new code or initiate a dispute.';
			case 'maker.conflict.title': return 'Offer Conflict';
			case 'maker.conflict.headline': return 'Offer Conflict Reported';
			case 'maker.conflict.body': return 'You marked the BLIK code as invalid, but the Taker has reported a conflict, indicating they believe the payment was successful.';
			case 'maker.conflict.instructions': return 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';
			case 'maker.conflict.actions.back': return 'Return to Home';
			case 'maker.conflict.actions.confirmPayment': return 'My mistake, confirm BLIK payment success';
			case 'maker.conflict.actions.openDispute': return 'Blik payment did NOT succeed, OPEN DISPUTE';
			case 'maker.conflict.actions.submitDispute': return 'Submit Dispute';
			case 'maker.conflict.disputeDialog.title': return 'Open Dispute?';
			case 'maker.conflict.disputeDialog.content': return 'Opening a dispute requires manual review by the coordinator, which may take time. A dispute fee will be deducted if the dispute is resolved against you. The hold invoice will be settled to prevent expiry. If resolved in your favor, you will be refunded (minus fees) to your Lightning Address.';
			case 'maker.conflict.disputeDialog.contentDetailed': return 'Opening a dispute will require manual intervention by the coordinator, which will take time and incur a dispute fee.\n\nThe hold invoice will be settled immediately to prevent expiry before the dispute is resolved.\n\nIf the dispute is resolved in your favor, the sats amount will be refunded to your Lightning Address (minus dispute fees). Please ensure you have a Lightning Address configured.';
			case 'maker.conflict.disputeDialog.confirm': return 'Open Dispute';
			case 'maker.conflict.disputeDialog.cancel': return 'Cancel';
			case 'maker.conflict.feedback.disputeSuccess': return 'Dispute opened successfully. The coordinator will review the case.';
			case 'maker.conflict.errors.openingDispute': return ({required Object error}) => 'Error opening dispute: ${error}';
			case 'maker.success.title': return 'Offer Completed';
			case 'maker.success.headline': return 'Payment Confirmed!';
			case 'maker.success.subtitle': return 'The Taker has been paid.';
			case 'maker.success.detailsTitle': return 'Offer Details:';
			case 'taker.roleSelection.button': return 'SELL BLIK code for sats';
			case 'taker.submitBlik.title': return 'Enter 6-digit BLIK Code:';
			case 'taker.submitBlik.label': return 'BLIK Code';
			case 'taker.submitBlik.timeLimit': return ({required Object seconds}) => 'Submit BLIK within: ${seconds} s';
			case 'taker.submitBlik.timeExpired': return 'BLIK input time expired.';
			case 'taker.submitBlik.actions.submit': return 'Submit BLIK';
			case 'taker.submitBlik.feedback.pasted': return 'Pasted BLIK code.';
			case 'taker.submitBlik.validation.invalidFormat': return 'Please enter a valid 6-digit BLIK code.';
			case 'taker.submitBlik.errors.submitting': return ({required Object details}) => 'Error submitting BLIK: ${details}';
			case 'taker.submitBlik.errors.clipboardInvalid': return 'Clipboard does not contain a valid 6-digit BLIK code.';
			case 'taker.submitBlik.errors.stateChanged': return 'Error: Offer state changed.';
			case 'taker.submitBlik.errors.stateNotValid': return 'Error: Offer state is no longer valid.';
			case 'taker.submitBlik.errors.fetchedIdMismatch': return 'Fetched active offer ID ({fetchedId}) does not match initial offer ID ({initialId}). State mismatch?';
			case 'taker.submitBlik.errors.paymentHashMissing': return 'Offer payment hash is missing after fetch.';
			case 'taker.waitConfirmation.statusLabel': return ({required Object status}) => 'Offer Status: ${status}';
			case 'taker.waitConfirmation.waitingMaker': return ({required Object seconds}) => 'Waiting for Maker confirmation: ${seconds} s';
			case 'taker.waitConfirmation.importantNotice': return ({required Object amount, required Object currency}) => 'VERY IMPORTANT: Be sure to accept only BLIK confirmation for amount of ${amount} ${currency}';
			case 'taker.waitConfirmation.instructions': return 'The offer maker has been sent your BLIK code and needs to enter it in the payment terminal. You then will need to accept the BLIK code in your bank app, be sure to only accept the correct amount. You will receive the Lightning payment automatically after confirmation.';
			case 'taker.waitConfirmation.feedback.makerConfirmed': return 'Maker confirmed payment.';
			case 'taker.waitConfirmation.feedback.paymentSuccessful': return 'Payment Successful! You should have now received the funds.';
			case 'taker.paymentProcess.title': return 'Payment Process';
			case 'taker.paymentProcess.states.preparing': return 'Preparing to send payment...';
			case 'taker.paymentProcess.states.sending': return 'Sending payment...';
			case 'taker.paymentProcess.states.received': return 'Payment Received!';
			case 'taker.paymentProcess.states.failed': return 'Payment Failed';
			case 'taker.paymentProcess.states.waitingUpdate': return 'Waiting for offer update...';
			case 'taker.paymentProcess.tasks.makerConfirmedBlik': return 'Maker confirmed BLIK payment success';
			case 'taker.paymentProcess.tasks.makerInvoiceSettled': return 'Maker hold invoice settled';
			case 'taker.paymentProcess.tasks.payingInvoice': return 'Generating & paying your invoice';
			case 'taker.paymentProcess.tasks.invoicePaid': return 'Your invoice paid successfully';
			case 'taker.paymentProcess.tasks.paymentFailed': return 'Payment to you failed';
			case 'taker.paymentProcess.errors.sending': return ({required Object details}) => 'Error sending payment: ${details}';
			case 'taker.paymentProcess.errors.notConfirmed': return 'Offer not confirmed by maker.';
			case 'taker.paymentProcess.errors.expired': return 'Offer expired.';
			case 'taker.paymentProcess.errors.cancelled': return 'Offer cancelled.';
			case 'taker.paymentProcess.errors.paymentFailed': return 'Offer payment failed.';
			case 'taker.paymentProcess.errors.unknown': return 'Unknown offer error.';
			case 'taker.paymentProcess.errors.takerPaymentFailed': return 'Payment to your Lightning Address failed. Please check the details and provide a new invoice if necessary.';
			case 'taker.paymentProcess.errors.noPublicKey': return 'Error: Could not retrieve your public key.';
			case 'taker.paymentProcess.errors.loadingPublicKey': return 'Error loading your details';
			case 'taker.paymentProcess.errors.missingPaymentHash': return 'Error: Payment details are missing.';
			case 'taker.paymentProcess.loading.publicKey': return 'Loading your details...';
			case 'taker.paymentProcess.actions.goToFailureDetails': return 'Go to Failure Details';
			case 'taker.paymentFailed.title': return 'Payment Failed';
			case 'taker.paymentFailed.instructions': return ({required Object netAmount}) => 'Please provide a new Lightning invoice for the amount of ${netAmount} sats.';
			case 'taker.paymentFailed.form.label': return 'New Lightning Invoice';
			case 'taker.paymentFailed.form.hint': return 'Enter your BOLT11 invoice';
			case 'taker.paymentFailed.actions.submit': return 'Submit New Invoice';
			case 'taker.paymentFailed.errors.enterValid': return 'Please enter a valid invoice';
			case 'taker.paymentFailed.errors.updating': return ({required Object details}) => 'Error updating invoice: ${details}';
			case 'taker.paymentFailed.errors.retryFailed': return 'Payment retry failed. Please check the invoice or try again later.';
			case 'taker.paymentSuccess.title': return 'Payment Successful';
			case 'taker.paymentSuccess.message': return 'Your payment has been processed successfully.';
			case 'taker.paymentSuccess.actions.goHome': return 'Go to Home';
			case 'taker.invalidBlik.title': return 'Invalid BLIK Code';
			case 'taker.invalidBlik.message': return 'Maker Rejected BLIK Code';
			case 'taker.invalidBlik.explanation': return 'The Maker has indicated that the BLIK code you provided was invalid or did not work. What would you like to do?';
			case 'taker.invalidBlik.actions.retry': return 'I DID NOT PAY, reserve Offer again and submit a new BLIK Code';
			case 'taker.invalidBlik.actions.reportConflict': return 'I CONFIRMED THE BLIK CODE AND IT GOT CHARGED FROM MY BANK ACCOUNT, Report Conflict, will cause DISPUTE!';
			case 'taker.invalidBlik.actions.returnHome': return 'Return Home';
			case 'taker.invalidBlik.errors.reservationFailed': return 'dupa dupa';
			case 'taker.conflict.title': return 'Offer Conflict';
			case 'taker.conflict.headline': return 'Offer Conflict Reported';
			case 'taker.conflict.body': return 'The Maker marked the BLIK code as invalid, but you have reported a conflict, indicating you believe the payment was successful.';
			case 'taker.conflict.instructions': return 'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.';
			case 'taker.conflict.actions.back': return 'Return to Home';
			case 'taker.conflict.feedback.reported': return 'Conflict reported. The coordinator will review the case.';
			case 'taker.conflict.errors.reporting': return ({required Object details}) => 'Error reporting conflict: ${details}';
			case 'home.notifications.simplex': return 'Get notified of new orders with SimpleX';
			case 'home.notifications.element': return 'Get notified of new orders with Element';
			case 'home.statistics.title': return 'Finished recent trades';
			case 'home.statistics.lifetimeCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'All: ${count} trades\nWaited in avg ${avgBlikTime} to receive BLIK code\nFull transaction avg time ${avgPaidTime}';
			case 'home.statistics.last7DaysCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Last 7d: ${count} trades\nWaited in avg ${avgBlikTime} to receive BLIK code\nFull transaction avg time ${avgPaidTime}';
			case 'home.statistics.errors.loading': return ({required Object error}) => 'Error loading statistics: ${error}';
			case 'system.errors.generic': return 'An unexpected error occurred. Please try again.';
			case 'system.errors.loadingTimeoutConfig': return 'Error loading timeout configuration.';
			case 'system.errors.loadingCoordinatorConfig': return 'Error loading coordinator configuration. Please try again.';
			case 'system.blik.copied': return 'BLIK code copied to clipboard';
			default: return null;
		}
	}
}

