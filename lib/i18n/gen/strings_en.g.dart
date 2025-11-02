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
	late final TranslationsCoordinatorEn coordinator = TranslationsCoordinatorEn.internal(_root);
	late final TranslationsMakerEn maker = TranslationsMakerEn.internal(_root);
	late final TranslationsTakerEn taker = TranslationsTakerEn.internal(_root);
	late final TranslationsBlikEn blik = TranslationsBlikEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsNekoInfoEn nekoInfo = TranslationsNekoInfoEn.internal(_root);
	late final TranslationsGenerateNewKeyEn generateNewKey = TranslationsGenerateNewKeyEn.internal(_root);
	late final TranslationsBackupEn backup = TranslationsBackupEn.internal(_root);
	late final TranslationsRestoreEn restore = TranslationsRestoreEn.internal(_root);
	late final TranslationsSystemEn system = TranslationsSystemEn.internal(_root);
	late final TranslationsLandingEn landing = TranslationsLandingEn.internal(_root);
	late final TranslationsFaqEn faq = TranslationsFaqEn.internal(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'BitBlik'
	String get title => 'BitBlik';

	/// en: 'Hello!'
	String get greeting => 'Hello!';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCommonButtonsEn buttons = TranslationsCommonButtonsEn.internal(_root);
	late final TranslationsCommonLabelsEn labels = TranslationsCommonLabelsEn.internal(_root);
	late final TranslationsCommonNotificationsEn notifications = TranslationsCommonNotificationsEn.internal(_root);
	late final TranslationsCommonClipboardEn clipboard = TranslationsCommonClipboardEn.internal(_root);
	late final TranslationsCommonActionsEn actions = TranslationsCommonActionsEn.internal(_root);
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
	late final TranslationsOffersDetailsEn details = TranslationsOffersDetailsEn.internal(_root);
	late final TranslationsOffersActionsEn actions = TranslationsOffersActionsEn.internal(_root);
	late final TranslationsOffersStatusEn status = TranslationsOffersStatusEn.internal(_root);
	late final TranslationsOffersStatusMessagesEn statusMessages = TranslationsOffersStatusMessagesEn.internal(_root);
	late final TranslationsOffersProgressEn progress = TranslationsOffersProgressEn.internal(_root);
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

// Path: coordinator
class TranslationsCoordinatorEn {
	TranslationsCoordinatorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCoordinatorInfoEn info = TranslationsCoordinatorInfoEn.internal(_root);
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

// Path: blik
class TranslationsBlikEn {
	TranslationsBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsBlikInstructionsEn instructions = TranslationsBlikInstructionsEn.internal(_root);
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsHomeNotificationsEn notifications = TranslationsHomeNotificationsEn.internal(_root);
	late final TranslationsHomeStatisticsEn statistics = TranslationsHomeStatisticsEn.internal(_root);
}

// Path: nekoInfo
class TranslationsNekoInfoEn {
	TranslationsNekoInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What is a Neko?'
	String get title => 'What is a Neko?';

	/// en: 'Your Neko is your identity for using BitBlik. It's composed of a private and public key to ensure cryptographically secure communication with the coordinator. To ensure greater anonymity, it is recommended to use a new, fresh Neko for each offer.'
	String get description => 'Your Neko is your identity for using BitBlik. It\'s composed of a private and public key to ensure cryptographically secure communication with the coordinator.\n\nTo ensure greater anonymity, it is recommended to use a new, fresh Neko for each offer.';
}

// Path: generateNewKey
class TranslationsGenerateNewKeyEn {
	TranslationsGenerateNewKeyEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Generate New Neko'
	String get title => 'Generate New Neko';

	/// en: 'Are you sure you want to generate a new Neko? Your current one will be lost forever if you haven't backed it up.'
	String get description => 'Are you sure you want to generate a new Neko? Your current one will be lost forever if you haven\'t backed it up.';

	late final TranslationsGenerateNewKeyButtonsEn buttons = TranslationsGenerateNewKeyButtonsEn.internal(_root);
	late final TranslationsGenerateNewKeyErrorsEn errors = TranslationsGenerateNewKeyErrorsEn.internal(_root);
	late final TranslationsGenerateNewKeyFeedbackEn feedback = TranslationsGenerateNewKeyFeedbackEn.internal(_root);
	late final TranslationsGenerateNewKeyTooltipsEn tooltips = TranslationsGenerateNewKeyTooltipsEn.internal(_root);
}

// Path: backup
class TranslationsBackupEn {
	TranslationsBackupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Backup Neko'
	String get title => 'Backup Neko';

	/// en: 'This is your private key. It secures communication with the coordinator. Never reveal it to anyone. Back it up in a secure place to prevent issues during disputes.'
	String get description => 'This is your private key. It secures communication with the coordinator. Never reveal it to anyone. Back it up in a secure place to prevent issues during disputes.';

	late final TranslationsBackupFeedbackEn feedback = TranslationsBackupFeedbackEn.internal(_root);
	late final TranslationsBackupTooltipsEn tooltips = TranslationsBackupTooltipsEn.internal(_root);
}

// Path: restore
class TranslationsRestoreEn {
	TranslationsRestoreEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore Neko'
	String get title => 'Restore Neko';

	late final TranslationsRestoreLabelsEn labels = TranslationsRestoreLabelsEn.internal(_root);
	late final TranslationsRestoreButtonsEn buttons = TranslationsRestoreButtonsEn.internal(_root);
	late final TranslationsRestoreErrorsEn errors = TranslationsRestoreErrorsEn.internal(_root);
	late final TranslationsRestoreFeedbackEn feedback = TranslationsRestoreFeedbackEn.internal(_root);
	late final TranslationsRestoreTooltipsEn tooltips = TranslationsRestoreTooltipsEn.internal(_root);
}

// Path: system
class TranslationsSystemEn {
	TranslationsSystemEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading your public key...'
	String get loadingPublicKey => 'Loading your public key...';

	late final TranslationsSystemErrorsEn errors = TranslationsSystemErrorsEn.internal(_root);
	late final TranslationsSystemBlikEn blik = TranslationsSystemBlikEn.internal(_root);
}

// Path: landing
class TranslationsLandingEn {
	TranslationsLandingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your BLIK ⇄ bitcoin Bridge'
	String get mainTitle => 'Your BLIK ⇄ bitcoin Bridge';

	/// en: 'Pay for or sell your BLIK code with bitcoin'
	String get subtitle => 'Pay for or sell your BLIK code with bitcoin';

	late final TranslationsLandingActionsEn actions = TranslationsLandingActionsEn.internal(_root);
}

// Path: faq
class TranslationsFaqEn {
	TranslationsFaqEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'FAQ'
	String get screenTitle => 'FAQ';

	/// en: 'FAQ'
	String get tooltip => 'FAQ';
}

// Path: common.buttons
class TranslationsCommonButtonsEn {
	TranslationsCommonButtonsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Go Home'
	String get goHome => 'Go Home';

	/// en: 'Save and Continue'
	String get saveAndContinue => 'Save and Continue';

	/// en: 'Reveal'
	String get reveal => 'Reveal';

	/// en: 'Hide'
	String get hide => 'Hide';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Restore'
	String get restore => 'Restore';

	/// en: 'FAQ'
	String get faq => 'FAQ';
}

// Path: common.labels
class TranslationsCommonLabelsEn {
	TranslationsCommonLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Amount (PLN)'
	String get amount => 'Amount (PLN)';

	/// en: 'Status: ${status}'
	String status({required Object status}) => 'Status: ${status}';

	/// en: 'Role: ${role}'
	String role({required Object role}) => 'Role: ${role}';
}

// Path: common.notifications
class TranslationsCommonNotificationsEn {
	TranslationsCommonNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: common.clipboard
class TranslationsCommonClipboardEn {
	TranslationsCommonClipboardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Copy to clipboard'
	String get copyToClipboard => 'Copy to clipboard';

	/// en: 'Paste from clipboard'
	String get pasteFromClipboard => 'Paste from clipboard';

	/// en: 'Copied to clipboard!'
	String get copied => 'Copied to clipboard!';
}

// Path: common.actions
class TranslationsCommonActionsEn {
	TranslationsCommonActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel and return to offers'
	String get cancelAndReturnToOffers => 'Cancel and return to offers';

	/// en: 'Cancel and return home'
	String get cancelAndReturnHome => 'Cancel and return home';
}

// Path: lightningAddress.labels
class TranslationsLightningAddressLabelsEn {
	TranslationsLightningAddressLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lightning Address'
	String get address => 'Lightning Address';

	/// en: 'user@domain.com'
	String get hint => 'user@domain.com';

	/// en: 'Lightning Address: ${address}'
	String short({required Object address}) => 'Lightning Address: ${address}';

	/// en: 'Your receiving address:'
	String get receivingAddress => 'Your receiving address:';
}

// Path: lightningAddress.prompts
class TranslationsLightningAddressPromptsEn {
	TranslationsLightningAddressPromptsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter your Lightning address to continue'
	String get enter => 'Enter your Lightning address to continue';

	/// en: 'Edit Lightning address'
	String get edit => 'Edit Lightning address';

	/// en: 'Enter a valid Lightning address'
	String get invalid => 'Enter a valid Lightning address';

	/// en: 'Lightning address is required.'
	String get required => 'Lightning address is required.';

	/// en: 'You must set a Lightning address to take an offer.'
	String get enterToTakeOffer => 'You must set a Lightning address to take an offer.';

	/// en: 'Lightning address is missing. Please add one to be able to take offers.'
	String get missing => 'Lightning address is missing. Please add one to be able to take offers.';

	/// en: 'Add Lightning Address'
	String get add => 'Add Lightning Address';

	/// en: 'Delete Lightning Address'
	String get delete => 'Delete Lightning Address';

	/// en: 'Are you sure you want to delete your Lightning address?'
	String get confirmDelete => 'Are you sure you want to delete your Lightning address?';
}

// Path: lightningAddress.feedback
class TranslationsLightningAddressFeedbackEn {
	TranslationsLightningAddressFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lightning address saved!'
	String get saved => 'Lightning address saved!';

	/// en: 'Lightning address updated!'
	String get updated => 'Lightning address updated!';

	/// en: 'Valid Lightning address'
	String get valid => 'Valid Lightning address';
}

// Path: lightningAddress.errors
class TranslationsLightningAddressErrorsEn {
	TranslationsLightningAddressErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error saving address: ${details}'
	String saving({required Object details}) => 'Error saving address: ${details}';

	/// en: 'Error loading Lightning address: ${details}'
	String loading({required Object details}) => 'Error loading Lightning address: ${details}';
}

// Path: offers.details
class TranslationsOffersDetailsEn {
	TranslationsOffersDetailsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your offer:'
	String get yourOffer => 'Your offer:';

	/// en: 'Offer:'
	String get selectedOffer => 'Offer:';

	/// en: 'You have an active offer:'
	String get activeOffer => 'You have an active offer:';

	/// en: 'Finished offers'
	String get finishedOffers => 'Finished offers';

	/// en: 'Finished offers (last 24h):'
	String get finishedOffersWithTime => 'Finished offers (last 24h):';

	/// en: 'No available offers.'
	String get noAvailable => 'No available offers.';

	/// en: 'No successful trades.'
	String get noSuccessfulTrades => 'No successful trades.';

	/// en: 'Loading offer details...'
	String get loadingDetails => 'Loading offer details...';

	/// en: 'Amount: ${amount} satoshi'
	String amount({required Object amount}) => 'Amount: ${amount} satoshi';

	/// en: '${amount} ${currency}'
	String amountWithCurrency({required Object amount, required Object currency}) => '${amount} ${currency}';

	/// en: 'Maker fee: ${fee} satoshi'
	String makerFee({required Object fee}) => 'Maker fee: ${fee} satoshi';

	/// en: 'Taker fee: ${fee} satoshi'
	String takerFee({required Object fee}) => 'Taker fee: ${fee} satoshi';

	/// en: 'Taker fee: ${fee} satoshi | Status: ${status}'
	String takerFeeWithStatus({required Object fee, required Object status}) => 'Taker fee: ${fee} satoshi | Status: ${status}';

	/// en: '${sats} + ${fee} (fee) satoshi Status: ${status}'
	String subtitle({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (fee) satoshi\nStatus: ${status}';

	/// en: '${sats} + ${fee} (fee) satoshi Status: ${status} Paid: ${date}'
	String subtitleWithDate({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (fee) satoshi\nStatus: ${status}\nPaid: ${date}';

	/// en: 'Status: ${status} Amount: ${amount} satoshi'
	String activeSubtitle({required Object status, required Object amount}) => 'Status: ${status}\nAmount: ${amount} satoshi';

	/// en: 'Offer ID: ${id}...'
	String id({required Object id}) => 'Offer ID: ${id}...';

	/// en: 'Created: ${dateTime}'
	String created({required Object dateTime}) => 'Created: ${dateTime}';

	/// en: 'Taken after: ${duration}'
	String takenAfter({required Object duration}) => 'Taken after: ${duration}';

	/// en: 'Paid after: ${duration}'
	String paidAfter({required Object duration}) => 'Paid after: ${duration}';

	/// en: 'Exchange Rate'
	String get exchangeRate => 'Exchange Rate';

	/// en: 'Taker fee'
	String get takerFeeLabel => 'Taker fee';

	/// en: 'Status'
	String get statusLabel => 'Status';

	/// en: 'You'll receive'
	String get youllReceive => 'You\'ll receive';

	/// en: 'Coordinator'
	String get coordinator => 'Coordinator';
}

// Path: offers.actions
class TranslationsOffersActionsEn {
	TranslationsOffersActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'TAKE'
	String get take => 'TAKE';

	/// en: 'Take Offer'
	String get takeOffer => 'Take Offer';

	/// en: 'RESUME'
	String get resume => 'RESUME';

	/// en: 'Cancel offer'
	String get cancel => 'Cancel offer';
}

// Path: offers.status
class TranslationsOffersStatusEn {
	TranslationsOffersStatusEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Created'
	String get created => 'Created';

	/// en: 'Funded'
	String get funded => 'Funded';

	/// en: 'Expired'
	String get expired => 'Expired';

	/// en: 'Cancelled'
	String get cancelled => 'Cancelled';

	/// en: 'Reserved'
	String get reserved => 'Reserved';

	/// en: 'BLIK Sent'
	String get blikReceived => 'BLIK Sent';

	/// en: 'BLIK Received'
	String get blikSentToMaker => 'BLIK Received';

	/// en: 'Invalid BLIK'
	String get invalidBlik => 'Invalid BLIK';

	/// en: 'Conflict'
	String get conflict => 'Conflict';

	/// en: 'Dispute'
	String get dispute => 'Dispute';

	/// en: 'Confirmed'
	String get makerConfirmed => 'Confirmed';

	/// en: 'Settled'
	String get settled => 'Settled';

	/// en: 'Paying Taker'
	String get payingTaker => 'Paying Taker';

	/// en: 'Payment Failed'
	String get takerPaymentFailed => 'Payment Failed';

	/// en: 'Taker Paid'
	String get takerPaid => 'Taker Paid';
}

// Path: offers.statusMessages
class TranslationsOffersStatusMessagesEn {
	TranslationsOffersStatusMessagesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Offer reserved by Taker!'
	String get reserved => 'Offer reserved by Taker!';

	/// en: 'Offer cancelled successfully.'
	String get cancelled => 'Offer cancelled successfully.';

	/// en: 'Offer has been cancelled or expired.'
	String get cancelledOrExpired => 'Offer has been cancelled or expired.';

	/// en: 'Offer is no longer available (Status: ${status}).'
	String noLongerAvailable({required Object status}) => 'Offer is no longer available (Status: ${status}).';
}

// Path: offers.progress
class TranslationsOffersProgressEn {
	TranslationsOffersProgressEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Waiting for taker: ${time}'
	String waitingForTaker({required Object time}) => 'Waiting for taker: ${time}';

	/// en: 'Reserved: ${seconds} s left'
	String reserved({required Object seconds}) => 'Reserved: ${seconds} s left';

	/// en: 'Confirming: ${seconds} s left'
	String confirming({required Object seconds}) => 'Confirming: ${seconds} s left';
}

// Path: offers.errors
class TranslationsOffersErrorsEn {
	TranslationsOffersErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error loading offers: ${details}'
	String loading({required Object details}) => 'Error loading offers: ${details}';

	/// en: 'Error loading offer details: ${details}'
	String loadingDetails({required Object details}) => 'Error loading offer details: ${details}';

	/// en: 'Error: Offer details missing or invalid.'
	String get detailsMissing => 'Error: Offer details missing or invalid.';

	/// en: 'Unable to load offer details.'
	String get detailsNotLoaded => 'Unable to load offer details.';

	/// en: 'Error: Offer not found.'
	String get notFound => 'Error: Offer not found.';

	/// en: 'Error: Offer is in an unexpected state.'
	String get unexpectedState => 'Error: Offer is in an unexpected state.';

	/// en: 'Offer is in an unexpected state (${status}). Please try again or contact support.'
	String unexpectedStateWithStatus({required Object status}) => 'Offer is in an unexpected state (${status}). Please try again or contact support.';

	/// en: 'Offer has invalid status.'
	String get invalidStatus => 'Offer has invalid status.';

	/// en: 'Error: Could not identify offer to cancel.'
	String get couldNotIdentify => 'Error: Could not identify offer to cancel.';

	/// en: 'Offer cannot be cancelled in current state (${status}).'
	String cannotBeCancelled({required Object status}) => 'Offer cannot be cancelled in current state (${status}).';

	/// en: 'Failed to cancel offer: ${details}'
	String failedToCancel({required Object details}) => 'Failed to cancel offer: ${details}';

	/// en: 'Error: Lost active offer details.'
	String get activeDetailsLost => 'Error: Lost active offer details.';

	/// en: 'Error checking active offers: ${details}'
	String checkingActive({required Object details}) => 'Error checking active offers: ${details}';

	/// en: 'Error loading finished offers: ${details}'
	String loadingFinished({required Object details}) => 'Error loading finished offers: ${details}';

	/// en: 'Cannot resume offer in state: ${status}'
	String cannotResume({required Object status}) => 'Cannot resume offer in state: ${status}';

	/// en: 'Cannot resume taker offer in state: ${status}'
	String cannotResumeTaker({required Object status}) => 'Cannot resume taker offer in state: ${status}';

	/// en: 'Error resuming offer: ${details}'
	String resuming({required Object details}) => 'Error resuming offer: ${details}';

	/// en: 'Maker public key not found'
	String get makerPublicKeyNotFound => 'Maker public key not found';

	/// en: 'Taker public key not found.'
	String get takerPublicKeyNotFound => 'Taker public key not found.';
}

// Path: reservations.actions
class TranslationsReservationsActionsEn {
	TranslationsReservationsActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel reservation'
	String get cancel => 'Cancel reservation';
}

// Path: reservations.feedback
class TranslationsReservationsFeedbackEn {
	TranslationsReservationsFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reservation cancelled.'
	String get cancelled => 'Reservation cancelled.';
}

// Path: reservations.errors
class TranslationsReservationsErrorsEn {
	TranslationsReservationsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to cancel reservation: ${error}'
	String cancelling({required Object error}) => 'Failed to cancel reservation: ${error}';

	/// en: 'Failed to reserve offer: ${details}'
	String failedToReserve({required Object details}) => 'Failed to reserve offer: ${details}';

	/// en: 'Failed to reserve offer (no timestamp).'
	String get failedNoTimestamp => 'Failed to reserve offer (no timestamp).';

	/// en: 'Offer reservation timestamp missing.'
	String get timestampMissing => 'Offer reservation timestamp missing.';

	/// en: 'Offer is no longer in reserved state (${status}).'
	String notReserved({required Object status}) => 'Offer is no longer in reserved state (${status}).';
}

// Path: exchange.labels
class TranslationsExchangeLabelsEn {
	TranslationsExchangeLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter amount (PLN) to pay:'
	String get enterAmount => 'Enter amount (PLN) to pay:';

	/// en: '≈ ${sats} satoshi'
	String equivalent({required Object sats}) => '≈ ${sats} satoshi';

	/// en: 'Exchange rate ≈ ${rate} PLN/BTC'
	String rate({required Object rate}) => 'Exchange rate ≈ ${rate} PLN/BTC';
}

// Path: exchange.feedback
class TranslationsExchangeFeedbackEn {
	TranslationsExchangeFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Fetching exchange rate...'
	String get fetching => 'Fetching exchange rate...';
}

// Path: exchange.errors
class TranslationsExchangeErrorsEn {
	TranslationsExchangeErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to fetch exchange rate.'
	String get fetchingRate => 'Failed to fetch exchange rate.';

	/// en: 'Invalid number format'
	String get invalidFormat => 'Invalid number format';

	/// en: 'Amount must be positive'
	String get mustBePositive => 'Amount must be positive';

	/// en: 'Invalid fee percentage'
	String get invalidFeePercentage => 'Invalid fee percentage';

	/// en: 'Amount is too low. Minimum is ${minAmount} ${currency}.'
	String tooLowFiat({required Object minAmount, required Object currency}) => 'Amount is too low. Minimum is ${minAmount} ${currency}.';

	/// en: 'Amount is too high. Maximum is ${maxAmount} ${currency}.'
	String tooHighFiat({required Object maxAmount, required Object currency}) => 'Amount is too high. Maximum is ${maxAmount} ${currency}.';
}

// Path: coordinator.info
class TranslationsCoordinatorInfoEn {
	TranslationsCoordinatorInfoEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'fee'
	String get fee => 'fee';

	/// en: 'Amount: ${minAmount}-${maxAmount} ${currency}'
	String rangeDisplay({required Object minAmount, required Object maxAmount, required Object currency}) => 'Amount: ${minAmount}-${maxAmount} ${currency}';

	/// en: '${fee}% fee'
	String feeDisplay({required Object fee}) => '${fee}% fee';
}

// Path: maker.roleSelection
class TranslationsMakerRoleSelectionEn {
	TranslationsMakerRoleSelectionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PAY with Lightning'
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

	/// en: 'Pay this Hold invoice:'
	String get title => 'Pay this Hold invoice:';

	late final TranslationsMakerPayInvoiceActionsEn actions = TranslationsMakerPayInvoiceActionsEn.internal(_root);
	late final TranslationsMakerPayInvoiceFeedbackEn feedback = TranslationsMakerPayInvoiceFeedbackEn.internal(_root);
	late final TranslationsMakerPayInvoiceErrorsEn errors = TranslationsMakerPayInvoiceErrorsEn.internal(_root);
}

// Path: maker.waitTaker
class TranslationsMakerWaitTakerEn {
	TranslationsMakerWaitTakerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Waiting for a Taker to reserve your offer...'
	String get message => 'Waiting for a Taker to reserve your offer...';

	/// en: 'Waiting for taker: ${time}'
	String progressLabel({required Object time}) => 'Waiting for taker: ${time}';

	/// en: 'Error: Lost active offer details.'
	String get errorActiveOfferDetailsLost => 'Error: Lost active offer details.';

	/// en: 'Error: Failed to retrieve BLIK code.'
	String get errorFailedToRetrieveBlik => 'Error: Failed to retrieve BLIK code.';

	/// en: 'Error retrieving BLIK code: ${details}'
	String errorRetrievingBlik({required Object details}) => 'Error retrieving BLIK code: ${details}';

	/// en: 'Offer is no longer available (Status: ${status}).'
	String offerNoLongerAvailable({required Object status}) => 'Offer is no longer available (Status: ${status}).';

	/// en: 'Error: Could not identify offer to cancel.'
	String get errorCouldNotIdentifyOffer => 'Error: Could not identify offer to cancel.';

	/// en: 'Offer cannot be cancelled in current state (${status}).'
	String offerCannotBeCancelled({required Object status}) => 'Offer cannot be cancelled in current state (${status}).';

	/// en: 'Offer cancelled successfully.'
	String get offerCancelledSuccessfully => 'Offer cancelled successfully.';

	/// en: 'Failed to cancel offer: ${details}'
	String failedToCancelOffer({required Object details}) => 'Failed to cancel offer: ${details}';
}

// Path: maker.waitForBlik
class TranslationsMakerWaitForBlikEn {
	TranslationsMakerWaitForBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Waiting for BLIK'
	String get title => 'Waiting for BLIK';

	/// en: 'Waiting for Taker to provide BLIK code.'
	String get message => 'Waiting for Taker to provide BLIK code.';

	/// en: 'Taker has ${seconds} seconds to provide BLIK code.'
	String timeLimitWithSeconds({required Object seconds}) => 'Taker has ${seconds} seconds to provide BLIK code.';

	/// en: 'Reserved: ${seconds} s left'
	String progressLabel({required Object seconds}) => 'Reserved: ${seconds} s left';
}

// Path: maker.confirmPayment
class TranslationsMakerConfirmPaymentEn {
	TranslationsMakerConfirmPaymentEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'BLIK code received!'
	String get title => 'BLIK code received!';

	/// en: 'Retrieving BLIK code...'
	String get retrieving => 'Retrieving BLIK code...';

	/// en: 'Enter this code into the payment terminal. When Taker confirms in their banking app and payment is successful, press Confirm below.'
	String get instructions => 'Enter this code into the payment terminal. When Taker confirms in their banking app and payment is successful, press Confirm below.';

	late final TranslationsMakerConfirmPaymentActionsEn actions = TranslationsMakerConfirmPaymentActionsEn.internal(_root);
	late final TranslationsMakerConfirmPaymentFeedbackEn feedback = TranslationsMakerConfirmPaymentFeedbackEn.internal(_root);
	late final TranslationsMakerConfirmPaymentErrorsEn errors = TranslationsMakerConfirmPaymentErrorsEn.internal(_root);
}

// Path: maker.invalidBlik
class TranslationsMakerInvalidBlikEn {
	TranslationsMakerInvalidBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid BLIK Code'
	String get title => 'Invalid BLIK Code';

	/// en: 'You marked the BLIK code as invalid. Waiting for taker to provide new code or start dispute.'
	String get info => 'You marked the BLIK code as invalid. Waiting for taker to provide new code or start dispute.';
}

// Path: maker.conflict
class TranslationsMakerConflictEn {
	TranslationsMakerConflictEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Offer Conflict'
	String get title => 'Offer Conflict';

	/// en: 'Offer Conflict Reported'
	String get headline => 'Offer Conflict Reported';

	/// en: 'You marked the BLIK code as invalid, but the Taker reported a conflict, indicating they believe the payment was successful.'
	String get body => 'You marked the BLIK code as invalid, but the Taker reported a conflict, indicating they believe the payment was successful.';

	/// en: 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.'
	String get instructions => 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.';

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

	/// en: 'Offer completed'
	String get title => 'Offer completed';

	/// en: 'Payment confirmed!'
	String get headline => 'Payment confirmed!';

	/// en: 'Taker has been paid.'
	String get subtitle => 'Taker has been paid.';

	/// en: 'Offer details:'
	String get detailsTitle => 'Offer details:';
}

// Path: taker.roleSelection
class TranslationsTakerRoleSelectionEn {
	TranslationsTakerRoleSelectionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'SELL BLIK code for satoshi'
	String get button => 'SELL BLIK code for satoshi';
}

// Path: taker.submitBlik
class TranslationsTakerSubmitBlikEn {
	TranslationsTakerSubmitBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter 6-digit BLIK code:'
	String get title => 'Enter 6-digit BLIK code:';

	/// en: 'BLIK Code'
	String get label => 'BLIK Code';

	/// en: 'Enter BLIK within: ${seconds} s'
	String timeLimit({required Object seconds}) => 'Enter BLIK within: ${seconds} s';

	/// en: 'Time to enter BLIK code has expired.'
	String get timeExpired => 'Time to enter BLIK code has expired.';

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

	/// en: 'Waiting for Maker'
	String get title => 'Waiting for Maker';

	/// en: 'Offer status: ${status}'
	String statusLabel({required Object status}) => 'Offer status: ${status}';

	/// en: 'Waiting for Maker confirmation: ${seconds} s'
	String waitingMaker({required Object seconds}) => 'Waiting for Maker confirmation: ${seconds} s';

	/// en: 'Waiting for Maker to confirm BLIK is correct. Time remaining: ${seconds}s'
	String waitingMakerConfirmation({required Object seconds}) => 'Waiting for Maker to confirm BLIK is correct. Time remaining: ${seconds}s';

	/// en: 'VERY IMPORTANT: Make sure you only accept BLIK confirmation for ${amount} ${currency}'
	String importantNotice({required Object amount, required Object currency}) => 'VERY IMPORTANT: Make sure you only accept BLIK confirmation for ${amount} ${currency}';

	/// en: 'VERY IMPORTANT: In your banking app, ensure you are confirming a BLIK payment for exactly ${amount} ${currency}.'
	String importantBlikAmountConfirmation({required Object amount, required Object currency}) => 'VERY IMPORTANT: In your banking app, ensure you are confirming a BLIK payment for exactly ${amount} ${currency}.';

	/// en: 'The offer maker has received your BLIK code and must enter it into the payment terminal. You then must accept the BLIK code in your banking app, make sure you only accept the correct amount. You will receive Lightning payment automatically after confirmation.'
	String get instructions => 'The offer maker has received your BLIK code and must enter it into the payment terminal. You then must accept the BLIK code in your banking app, make sure you only accept the correct amount. You will receive Lightning payment automatically after confirmation.';

	/// en: 'Navigated home.'
	String get navigatedHome => 'Navigated home.';

	late final TranslationsTakerWaitConfirmationFeedbackEn feedback = TranslationsTakerWaitConfirmationFeedbackEn.internal(_root);
	late final TranslationsTakerWaitConfirmationErrorsEn errors = TranslationsTakerWaitConfirmationErrorsEn.internal(_root);
}

// Path: taker.paymentProcess
class TranslationsTakerPaymentProcessEn {
	TranslationsTakerPaymentProcessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Payment Process'
	String get title => 'Payment Process';

	/// en: 'Waiting for offer status update...'
	String get waitingForOfferUpdate => 'Waiting for offer status update...';

	late final TranslationsTakerPaymentProcessStatesEn states = TranslationsTakerPaymentProcessStatesEn.internal(_root);
	late final TranslationsTakerPaymentProcessStepsEn steps = TranslationsTakerPaymentProcessStepsEn.internal(_root);
	late final TranslationsTakerPaymentProcessErrorsEn errors = TranslationsTakerPaymentProcessErrorsEn.internal(_root);
	late final TranslationsTakerPaymentProcessLoadingEn loading = TranslationsTakerPaymentProcessLoadingEn.internal(_root);
	late final TranslationsTakerPaymentProcessActionsEn actions = TranslationsTakerPaymentProcessActionsEn.internal(_root);
}

// Path: taker.paymentFailed
class TranslationsTakerPaymentFailedEn {
	TranslationsTakerPaymentFailedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Payment Failed'
	String get title => 'Payment Failed';

	/// en: 'Please provide a new Lightning invoice for ${netAmount} satoshi'
	String instructions({required Object netAmount}) => 'Please provide a new Lightning invoice for ${netAmount} satoshi';

	late final TranslationsTakerPaymentFailedFormEn form = TranslationsTakerPaymentFailedFormEn.internal(_root);
	late final TranslationsTakerPaymentFailedActionsEn actions = TranslationsTakerPaymentFailedActionsEn.internal(_root);
	late final TranslationsTakerPaymentFailedErrorsEn errors = TranslationsTakerPaymentFailedErrorsEn.internal(_root);
	late final TranslationsTakerPaymentFailedLoadingEn loading = TranslationsTakerPaymentFailedLoadingEn.internal(_root);
	late final TranslationsTakerPaymentFailedSuccessEn success = TranslationsTakerPaymentFailedSuccessEn.internal(_root);
}

// Path: taker.paymentSuccess
class TranslationsTakerPaymentSuccessEn {
	TranslationsTakerPaymentSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Payment Successful'
	String get title => 'Payment Successful';

	/// en: 'Your payment has been processed successfully.'
	String get message => 'Your payment has been processed successfully.';

	late final TranslationsTakerPaymentSuccessActionsEn actions = TranslationsTakerPaymentSuccessActionsEn.internal(_root);
}

// Path: taker.invalidBlik
class TranslationsTakerInvalidBlikEn {
	TranslationsTakerInvalidBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid BLIK Code'
	String get title => 'Invalid BLIK Code';

	/// en: 'Maker Rejected BLIK Code'
	String get message => 'Maker Rejected BLIK Code';

	/// en: 'The offer maker indicated that the BLIK code you provided was invalid or didn't work. What would you like to do?'
	String get explanation => 'The offer maker indicated that the BLIK code you provided was invalid or didn\'t work. What would you like to do?';

	late final TranslationsTakerInvalidBlikActionsEn actions = TranslationsTakerInvalidBlikActionsEn.internal(_root);
	late final TranslationsTakerInvalidBlikFeedbackEn feedback = TranslationsTakerInvalidBlikFeedbackEn.internal(_root);
	late final TranslationsTakerInvalidBlikErrorsEn errors = TranslationsTakerInvalidBlikErrorsEn.internal(_root);
}

// Path: taker.conflict
class TranslationsTakerConflictEn {
	TranslationsTakerConflictEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Offer Conflict'
	String get title => 'Offer Conflict';

	/// en: 'Offer Conflict Reported'
	String get headline => 'Offer Conflict Reported';

	/// en: 'The Maker marked the BLIK code as invalid, but you reported a conflict, indicating you believe the payment was successful.'
	String get body => 'The Maker marked the BLIK code as invalid, but you reported a conflict, indicating you believe the payment was successful.';

	/// en: 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.'
	String get instructions => 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.';

	late final TranslationsTakerConflictActionsEn actions = TranslationsTakerConflictActionsEn.internal(_root);
	late final TranslationsTakerConflictFeedbackEn feedback = TranslationsTakerConflictFeedbackEn.internal(_root);
	late final TranslationsTakerConflictErrorsEn errors = TranslationsTakerConflictErrorsEn.internal(_root);
}

// Path: blik.instructions
class TranslationsBlikInstructionsEn {
	TranslationsBlikInstructionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Once the Maker enters the BLIK code, you will need to confirm the payment in your banking app. Ensure the amount is correct before confirming.'
	String get taker => 'Once the Maker enters the BLIK code, you will need to confirm the payment in your banking app. Ensure the amount is correct before confirming.';
}

// Path: home.notifications
class TranslationsHomeNotificationsEn {
	TranslationsHomeNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Get notified about new offers via:'
	String get title => 'Get notified about new offers via:';

	/// en: 'Telegram'
	String get telegram => 'Telegram';

	/// en: 'SimpleX'
	String get simplex => 'SimpleX';

	/// en: 'Element'
	String get element => 'Element';

	/// en: 'Signal'
	String get signal => 'Signal';
}

// Path: home.statistics
class TranslationsHomeStatisticsEn {
	TranslationsHomeStatisticsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Finished Offers'
	String get title => 'Finished Offers';

	/// en: 'All: ${count} transactions Avg wait for BLIK: ${avgBlikTime} Avg completion time: ${avgPaidTime}'
	String lifetimeCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'All: ${count} transactions\nAvg wait for BLIK: ${avgBlikTime}\nAvg completion time: ${avgPaidTime}';

	/// en: 'Last 7d: ${count} transactions Avg wait for BLIK: ${avgBlikTime} Avg completion time: ${avgPaidTime}'
	String last7DaysCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Last 7d: ${count} transactions\nAvg wait for BLIK: ${avgBlikTime}\nAvg completion time: ${avgPaidTime}';

	late final TranslationsHomeStatisticsErrorsEn errors = TranslationsHomeStatisticsErrorsEn.internal(_root);
}

// Path: generateNewKey.buttons
class TranslationsGenerateNewKeyButtonsEn {
	TranslationsGenerateNewKeyButtonsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Generate'
	String get generate => 'Generate';
}

// Path: generateNewKey.errors
class TranslationsGenerateNewKeyErrorsEn {
	TranslationsGenerateNewKeyErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You cannot generate a new Neko while you have an active offer.'
	String get activeOffer => 'You cannot generate a new Neko while you have an active offer.';

	/// en: 'Failed to generate new Neko'
	String get failed => 'Failed to generate new Neko';
}

// Path: generateNewKey.feedback
class TranslationsGenerateNewKeyFeedbackEn {
	TranslationsGenerateNewKeyFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Neko generated successfully!'
	String get success => 'New Neko generated successfully!';
}

// Path: generateNewKey.tooltips
class TranslationsGenerateNewKeyTooltipsEn {
	TranslationsGenerateNewKeyTooltipsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Generate New Neko'
	String get generate => 'Generate New Neko';
}

// Path: backup.feedback
class TranslationsBackupFeedbackEn {
	TranslationsBackupFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Private key copied to clipboard!'
	String get copied => 'Private key copied to clipboard!';
}

// Path: backup.tooltips
class TranslationsBackupTooltipsEn {
	TranslationsBackupTooltipsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Backup Neko'
	String get backup => 'Backup Neko';
}

// Path: restore.labels
class TranslationsRestoreLabelsEn {
	TranslationsRestoreLabelsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Private Key'
	String get privateKey => 'Private Key';
}

// Path: restore.buttons
class TranslationsRestoreButtonsEn {
	TranslationsRestoreButtonsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore'
	String get restore => 'Restore';
}

// Path: restore.errors
class TranslationsRestoreErrorsEn {
	TranslationsRestoreErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Must be a 64-character hex string.'
	String get invalidKey => 'Must be a 64-character hex string.';

	/// en: 'Restore failed'
	String get failed => 'Restore failed';
}

// Path: restore.feedback
class TranslationsRestoreFeedbackEn {
	TranslationsRestoreFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Neko restored successfully! App will restart.'
	String get success => 'Neko restored successfully! App will restart.';
}

// Path: restore.tooltips
class TranslationsRestoreTooltipsEn {
	TranslationsRestoreTooltipsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Restore Neko'
	String get restore => 'Restore Neko';
}

// Path: system.errors
class TranslationsSystemErrorsEn {
	TranslationsSystemErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'An unexpected error occurred. Please try again.'
	String get generic => 'An unexpected error occurred. Please try again.';

	/// en: 'Error loading timeout configuration.'
	String get loadingTimeoutConfig => 'Error loading timeout configuration.';

	/// en: 'Error loading coordinator configuration. Please try again.'
	String get loadingCoordinatorConfig => 'Error loading coordinator configuration. Please try again.';

	/// en: 'Your public key is not available. Cannot proceed.'
	String get noPublicKey => 'Your public key is not available. Cannot proceed.';

	/// en: 'Internal error: Offer details are incomplete. Please try again.'
	String get internalOfferIncomplete => 'Internal error: Offer details are incomplete. Please try again.';

	/// en: 'Error loading your public key. Please restart the app.'
	String get loadingPublicKey => 'Error loading your public key. Please restart the app.';
}

// Path: system.blik
class TranslationsSystemBlikEn {
	TranslationsSystemBlikEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'BLIK code copied to clipboard'
	String get copied => 'BLIK code copied to clipboard';
}

// Path: landing.actions
class TranslationsLandingActionsEn {
	TranslationsLandingActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pay BLIK'
	String get payBlik => 'Pay BLIK';

	/// en: 'with bitcoin'
	String get payBlikSubtitle => 'with bitcoin';

	/// en: 'Buy bitcoin'
	String get sellBlik => 'Buy bitcoin';

	/// en: 'with BLIK'
	String get sellBlikSubtitle => 'with BLIK';

	/// en: 'How it works?'
	String get howItWorks => 'How it works?';
}

// Path: maker.amountForm.actions
class TranslationsMakerAmountFormActionsEn {
	TranslationsMakerAmountFormActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Generate Invoice'
	String get generateInvoice => 'Generate Invoice';
}

// Path: maker.amountForm.errors
class TranslationsMakerAmountFormErrorsEn {
	TranslationsMakerAmountFormErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error initiating offer: ${details}'
	String initiating({required Object details}) => 'Error initiating offer: ${details}';

	/// en: 'Error: Public key not yet loaded.'
	String get publicKeyNotLoaded => 'Error: Public key not yet loaded.';
}

// Path: maker.payInvoice.actions
class TranslationsMakerPayInvoiceActionsEn {
	TranslationsMakerPayInvoiceActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Copy Invoice'
	String get copy => 'Copy Invoice';

	/// en: 'Pay in Wallet'
	String get payInWallet => 'Pay in Wallet';
}

// Path: maker.payInvoice.feedback
class TranslationsMakerPayInvoiceFeedbackEn {
	TranslationsMakerPayInvoiceFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invoice copied to clipboard!'
	String get copied => 'Invoice copied to clipboard!';

	/// en: 'Waiting for payment confirmation...'
	String get waitingConfirmation => 'Waiting for payment confirmation...';
}

// Path: maker.payInvoice.errors
class TranslationsMakerPayInvoiceErrorsEn {
	TranslationsMakerPayInvoiceErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Could not open Lightning app for invoice.'
	String get couldNotOpenApp => 'Could not open Lightning app for invoice.';

	/// en: 'Error opening Lightning app: ${details}'
	String openingApp({required Object details}) => 'Error opening Lightning app: ${details}';

	/// en: 'Public key is not available.'
	String get publicKeyNotAvailable => 'Public key is not available.';

	/// en: 'Could not fetch active offer details. It may have expired.'
	String get couldNotFetchActive => 'Could not fetch active offer details. It may have expired.';
}

// Path: maker.confirmPayment.actions
class TranslationsMakerConfirmPaymentActionsEn {
	TranslationsMakerConfirmPaymentActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm successful payment'
	String get confirm => 'Confirm successful payment';

	/// en: 'Invalid BLIK Code'
	String get markInvalid => 'Invalid BLIK Code';
}

// Path: maker.confirmPayment.feedback
class TranslationsMakerConfirmPaymentFeedbackEn {
	TranslationsMakerConfirmPaymentFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Maker confirmed payment.'
	String get confirmed => 'Maker confirmed payment.';

	/// en: 'Payment confirmed! Taker will receive funds.'
	String get confirmedTakerPaid => 'Payment confirmed! Taker will receive funds.';

	/// en: 'Confirming: ${seconds} s left'
	String progressLabel({required Object seconds}) => 'Confirming: ${seconds} s left';
}

// Path: maker.confirmPayment.errors
class TranslationsMakerConfirmPaymentErrorsEn {
	TranslationsMakerConfirmPaymentErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error: Failed to retrieve BLIK code.'
	String get failedToRetrieve => 'Error: Failed to retrieve BLIK code.';

	/// en: 'Error retrieving BLIK code: ${details}'
	String retrieving({required Object details}) => 'Error retrieving BLIK code: ${details}';

	/// en: 'Error: Missing payment hash or public key.'
	String get missingHashOrKey => 'Error: Missing payment hash or public key.';

	/// en: 'Offer is not in correct state for confirmation (Status: ${status})'
	String incorrectState({required Object status}) => 'Offer is not in correct state for confirmation (Status: ${status})';

	/// en: 'Error confirming payment: ${details}'
	String confirming({required Object details}) => 'Error confirming payment: ${details}';

	/// en: 'Error: Received invalid offer state.'
	String get invalidState => 'Error: Received invalid offer state.';

	/// en: 'Internal error: Incomplete offer details.'
	String get internalIncomplete => 'Internal error: Incomplete offer details.';

	/// en: 'Offer is no longer awaiting confirmation (Status: ${status}).'
	String notAwaitingConfirmation({required Object status}) => 'Offer is no longer awaiting confirmation (Status: ${status}).';

	/// en: 'Received unexpected offer status from server.'
	String get unexpectedStatus => 'Received unexpected offer status from server.';
}

// Path: maker.conflict.actions
class TranslationsMakerConflictActionsEn {
	TranslationsMakerConflictActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Back to Home'
	String get back => 'Back to Home';

	/// en: 'My mistake, confirm BLIK payment success'
	String get confirmPayment => 'My mistake, confirm BLIK payment success';

	/// en: 'Blik payment did NOT succeed, OPEN DISPUTE'
	String get openDispute => 'Blik payment did NOT succeed, OPEN DISPUTE';

	/// en: 'Submit Dispute'
	String get submitDispute => 'Submit Dispute';
}

// Path: maker.conflict.disputeDialog
class TranslationsMakerConflictDisputeDialogEn {
	TranslationsMakerConflictDisputeDialogEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Open dispute?'
	String get title => 'Open dispute?';

	/// en: 'Opening a dispute requires manual verification by the coordinator, which will take time. A dispute fee will be deducted if the dispute is ruled against you. The hold invoice will be settled to prevent it from expiring. If the dispute is ruled in your favor, you will receive a refund (minus fees) to your Lightning address.'
	String get content => 'Opening a dispute requires manual verification by the coordinator, which will take time. A dispute fee will be deducted if the dispute is ruled against you. The hold invoice will be settled to prevent it from expiring. If the dispute is ruled in your favor, you will receive a refund (minus fees) to your Lightning address.';

	/// en: 'Opening a dispute will require manual coordinator intervention, which takes time and incurs a dispute fee. The hold invoice will be immediately settled to prevent it from expiring before the dispute is resolved. If the dispute is ruled in your favor, the satoshi amount will be refunded to your Lightning address (minus fees). Make sure you have a Lightning address configured.'
	String get contentDetailed => 'Opening a dispute will require manual coordinator intervention, which takes time and incurs a dispute fee.\n\nThe hold invoice will be immediately settled to prevent it from expiring before the dispute is resolved.\n\nIf the dispute is ruled in your favor, the satoshi amount will be refunded to your Lightning address (minus fees). Make sure you have a Lightning address configured.';

	late final TranslationsMakerConflictDisputeDialogActionsEn actions = TranslationsMakerConflictDisputeDialogActionsEn.internal(_root);
}

// Path: maker.conflict.feedback
class TranslationsMakerConflictFeedbackEn {
	TranslationsMakerConflictFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dispute successfully opened. Coordinator will review.'
	String get disputeOpenedSuccess => 'Dispute successfully opened. Coordinator will review.';
}

// Path: maker.conflict.errors
class TranslationsMakerConflictErrorsEn {
	TranslationsMakerConflictErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error opening dispute: ${error}'
	String openingDispute({required Object error}) => 'Error opening dispute: ${error}';
}

// Path: taker.submitBlik.actions
class TranslationsTakerSubmitBlikActionsEn {
	TranslationsTakerSubmitBlikActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Submit BLIK'
	String get submit => 'Submit BLIK';
}

// Path: taker.submitBlik.feedback
class TranslationsTakerSubmitBlikFeedbackEn {
	TranslationsTakerSubmitBlikFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pasted BLIK code.'
	String get pasted => 'Pasted BLIK code.';
}

// Path: taker.submitBlik.validation
class TranslationsTakerSubmitBlikValidationEn {
	TranslationsTakerSubmitBlikValidationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter a valid 6-digit BLIK code.'
	String get invalidFormat => 'Enter a valid 6-digit BLIK code.';
}

// Path: taker.submitBlik.errors
class TranslationsTakerSubmitBlikErrorsEn {
	TranslationsTakerSubmitBlikErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error submitting BLIK code: ${details}'
	String submitting({required Object details}) => 'Error submitting BLIK code: ${details}';

	/// en: 'Clipboard does not contain a valid 6-digit BLIK code.'
	String get clipboardInvalid => 'Clipboard does not contain a valid 6-digit BLIK code.';

	/// en: 'Error: Offer state has changed.'
	String get stateChanged => 'Error: Offer state has changed.';

	/// en: 'Error: Offer state is no longer valid.'
	String get stateNotValid => 'Error: Offer state is no longer valid.';

	/// en: 'Fetched active offer ID (${fetchedId}) does not match initial offer ID (${initialId}). State mismatch?'
	String fetchedIdMismatch({required Object fetchedId, required Object initialId}) => 'Fetched active offer ID (${fetchedId}) does not match initial offer ID (${initialId}). State mismatch?';

	/// en: 'Offer payment hash missing after fetch.'
	String get paymentHashMissing => 'Offer payment hash missing after fetch.';
}

// Path: taker.waitConfirmation.feedback
class TranslationsTakerWaitConfirmationFeedbackEn {
	TranslationsTakerWaitConfirmationFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Maker confirmed payment.'
	String get makerConfirmed => 'Maker confirmed payment.';

	/// en: 'Payment successful! You will receive funds shortly.'
	String get paymentSuccessful => 'Payment successful! You will receive funds shortly.';
}

// Path: taker.waitConfirmation.errors
class TranslationsTakerWaitConfirmationErrorsEn {
	TranslationsTakerWaitConfirmationErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Received an offer with an invalid state for this screen. Resetting.'
	String get invalidOfferStateReceived => 'Received an offer with an invalid state for this screen. Resetting.';
}

// Path: taker.paymentProcess.states
class TranslationsTakerPaymentProcessStatesEn {
	TranslationsTakerPaymentProcessStatesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preparing to send payment...'
	String get preparing => 'Preparing to send payment...';

	/// en: 'Sending payment...'
	String get sending => 'Sending payment...';

	/// en: 'Payment received!'
	String get received => 'Payment received!';

	/// en: 'Payment failed'
	String get failed => 'Payment failed';

	/// en: 'Waiting for offer update...'
	String get waitingUpdate => 'Waiting for offer update...';
}

// Path: taker.paymentProcess.steps
class TranslationsTakerPaymentProcessStepsEn {
	TranslationsTakerPaymentProcessStepsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Maker confirmed BLIK payment'
	String get makerConfirmedBlik => 'Maker confirmed BLIK payment';

	/// en: 'Maker's hold invoice settled'
	String get makerInvoiceSettled => 'Maker\'s hold invoice settled';

	/// en: 'Paying your Lightning invoice'
	String get payingTakerInvoice => 'Paying your Lightning invoice';

	/// en: 'Your Lightning invoice paid'
	String get takerInvoicePaid => 'Your Lightning invoice paid';

	/// en: 'Payment to your invoice failed'
	String get takerPaymentFailed => 'Payment to your invoice failed';
}

// Path: taker.paymentProcess.errors
class TranslationsTakerPaymentProcessErrorsEn {
	TranslationsTakerPaymentProcessErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error sending payment: ${details}'
	String sending({required Object details}) => 'Error sending payment: ${details}';

	/// en: 'Offer not confirmed by Maker.'
	String get notConfirmed => 'Offer not confirmed by Maker.';

	/// en: 'Offer expired.'
	String get expired => 'Offer expired.';

	/// en: 'Offer cancelled.'
	String get cancelled => 'Offer cancelled.';

	/// en: 'Offer payment failed.'
	String get paymentFailed => 'Offer payment failed.';

	/// en: 'Unknown offer error.'
	String get unknown => 'Unknown offer error.';

	/// en: 'The payment to your Lightning invoice failed. Please go to the failure details screen to provide a new invoice or investigate.'
	String get takerPaymentFailed => 'The payment to your Lightning invoice failed. Please go to the failure details screen to provide a new invoice or investigate.';

	/// en: 'Error: Cannot fetch your public key.'
	String get noPublicKey => 'Error: Cannot fetch your public key.';

	/// en: 'Error loading your data'
	String get loadingPublicKey => 'Error loading your data';

	/// en: 'Error: Missing payment details.'
	String get missingPaymentHash => 'Error: Missing payment details.';
}

// Path: taker.paymentProcess.loading
class TranslationsTakerPaymentProcessLoadingEn {
	TranslationsTakerPaymentProcessLoadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Loading your data...'
	String get publicKey => 'Loading your data...';
}

// Path: taker.paymentProcess.actions
class TranslationsTakerPaymentProcessActionsEn {
	TranslationsTakerPaymentProcessActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Go to Failure Details'
	String get goToFailureDetails => 'Go to Failure Details';
}

// Path: taker.paymentFailed.form
class TranslationsTakerPaymentFailedFormEn {
	TranslationsTakerPaymentFailedFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Lightning invoice'
	String get newInvoiceLabel => 'New Lightning invoice';

	/// en: 'Enter your BOLT11 invoice'
	String get newInvoiceHint => 'Enter your BOLT11 invoice';
}

// Path: taker.paymentFailed.actions
class TranslationsTakerPaymentFailedActionsEn {
	TranslationsTakerPaymentFailedActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Submit New Invoice'
	String get retryPayment => 'Submit New Invoice';
}

// Path: taker.paymentFailed.errors
class TranslationsTakerPaymentFailedErrorsEn {
	TranslationsTakerPaymentFailedErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please enter a valid invoice'
	String get enterValidInvoice => 'Please enter a valid invoice';

	/// en: 'Error updating invoice: ${details}'
	String updatingInvoice({required Object details}) => 'Error updating invoice: ${details}';

	/// en: 'Payment retry failed. Please check the invoice or try again later.'
	String get paymentRetryFailed => 'Payment retry failed. Please check the invoice or try again later.';

	/// en: 'Taker public key not found.'
	String get takerPublicKeyNotFound => 'Taker public key not found.';
}

// Path: taker.paymentFailed.loading
class TranslationsTakerPaymentFailedLoadingEn {
	TranslationsTakerPaymentFailedLoadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Processing your payment retry...'
	String get processingPayment => 'Processing your payment retry...';
}

// Path: taker.paymentFailed.success
class TranslationsTakerPaymentFailedSuccessEn {
	TranslationsTakerPaymentFailedSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Payment Successful'
	String get title => 'Payment Successful';

	/// en: 'Your payment has been processed successfully.'
	String get message => 'Your payment has been processed successfully.';
}

// Path: taker.paymentSuccess.actions
class TranslationsTakerPaymentSuccessActionsEn {
	TranslationsTakerPaymentSuccessActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Go to home'
	String get goHome => 'Go to home';
}

// Path: taker.invalidBlik.actions
class TranslationsTakerInvalidBlikActionsEn {
	TranslationsTakerInvalidBlikActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I DID NOT PAY, reserve offer again and send new BLIK code'
	String get retry => 'I DID NOT PAY, reserve offer again and send new BLIK code';

	/// en: 'I CONFIRMED BLIK CODE AND IT WAS CHARGED FROM MY BANK ACCOUNT, Report conflict, will cause DISPUTE!'
	String get reportConflict => 'I CONFIRMED BLIK CODE AND IT WAS CHARGED FROM MY BANK ACCOUNT, Report conflict, will cause DISPUTE!';

	/// en: 'Return to home'
	String get returnHome => 'Return to home';
}

// Path: taker.invalidBlik.feedback
class TranslationsTakerInvalidBlikFeedbackEn {
	TranslationsTakerInvalidBlikFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Conflict reported. Coordinator will review.'
	String get conflictReportedSuccess => 'Conflict reported. Coordinator will review.';
}

// Path: taker.invalidBlik.errors
class TranslationsTakerInvalidBlikErrorsEn {
	TranslationsTakerInvalidBlikErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to reserve offer again'
	String get reservationFailed => 'Failed to reserve offer again';

	/// en: 'Error reporting conflict: ${details}'
	String conflictReport({required Object details}) => 'Error reporting conflict: ${details}';
}

// Path: taker.conflict.actions
class TranslationsTakerConflictActionsEn {
	TranslationsTakerConflictActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Back to Home'
	String get back => 'Back to Home';
}

// Path: taker.conflict.feedback
class TranslationsTakerConflictFeedbackEn {
	TranslationsTakerConflictFeedbackEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Conflict reported. Coordinator will review.'
	String get reported => 'Conflict reported. Coordinator will review.';
}

// Path: taker.conflict.errors
class TranslationsTakerConflictErrorsEn {
	TranslationsTakerConflictErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error reporting conflict: ${details}'
	String reporting({required Object details}) => 'Error reporting conflict: ${details}';
}

// Path: home.statistics.errors
class TranslationsHomeStatisticsErrorsEn {
	TranslationsHomeStatisticsErrorsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error loading statistics: ${error}'
	String loading({required Object error}) => 'Error loading statistics: ${error}';
}

// Path: maker.conflict.disputeDialog.actions
class TranslationsMakerConflictDisputeDialogActionsEn {
	TranslationsMakerConflictDisputeDialogActionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Open Dispute'
	String get confirm => 'Open Dispute';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
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
			case 'common.buttons.saveAndContinue': return 'Save and Continue';
			case 'common.buttons.reveal': return 'Reveal';
			case 'common.buttons.hide': return 'Hide';
			case 'common.buttons.copy': return 'Copy';
			case 'common.buttons.close': return 'Close';
			case 'common.buttons.restore': return 'Restore';
			case 'common.buttons.faq': return 'FAQ';
			case 'common.labels.amount': return 'Amount (PLN)';
			case 'common.labels.status': return ({required Object status}) => 'Status: ${status}';
			case 'common.labels.role': return ({required Object role}) => 'Role: ${role}';
			case 'common.notifications.success': return 'Success';
			case 'common.notifications.error': return 'Error';
			case 'common.notifications.loading': return 'Loading...';
			case 'common.clipboard.copyToClipboard': return 'Copy to clipboard';
			case 'common.clipboard.pasteFromClipboard': return 'Paste from clipboard';
			case 'common.clipboard.copied': return 'Copied to clipboard!';
			case 'common.actions.cancelAndReturnToOffers': return 'Cancel and return to offers';
			case 'common.actions.cancelAndReturnHome': return 'Cancel and return home';
			case 'lightningAddress.labels.address': return 'Lightning Address';
			case 'lightningAddress.labels.hint': return 'user@domain.com';
			case 'lightningAddress.labels.short': return ({required Object address}) => 'Lightning Address: ${address}';
			case 'lightningAddress.labels.receivingAddress': return 'Your receiving address:';
			case 'lightningAddress.prompts.enter': return 'Enter your Lightning address to continue';
			case 'lightningAddress.prompts.edit': return 'Edit Lightning address';
			case 'lightningAddress.prompts.invalid': return 'Enter a valid Lightning address';
			case 'lightningAddress.prompts.required': return 'Lightning address is required.';
			case 'lightningAddress.prompts.enterToTakeOffer': return 'You must set a Lightning address to take an offer.';
			case 'lightningAddress.prompts.missing': return 'Lightning address is missing. Please add one to be able to take offers.';
			case 'lightningAddress.prompts.add': return 'Add Lightning Address';
			case 'lightningAddress.prompts.delete': return 'Delete Lightning Address';
			case 'lightningAddress.prompts.confirmDelete': return 'Are you sure you want to delete your Lightning address?';
			case 'lightningAddress.feedback.saved': return 'Lightning address saved!';
			case 'lightningAddress.feedback.updated': return 'Lightning address updated!';
			case 'lightningAddress.feedback.valid': return 'Valid Lightning address';
			case 'lightningAddress.errors.saving': return ({required Object details}) => 'Error saving address: ${details}';
			case 'lightningAddress.errors.loading': return ({required Object details}) => 'Error loading Lightning address: ${details}';
			case 'offers.details.yourOffer': return 'Your offer:';
			case 'offers.details.selectedOffer': return 'Offer:';
			case 'offers.details.activeOffer': return 'You have an active offer:';
			case 'offers.details.finishedOffers': return 'Finished offers';
			case 'offers.details.finishedOffersWithTime': return 'Finished offers (last 24h):';
			case 'offers.details.noAvailable': return 'No available offers.';
			case 'offers.details.noSuccessfulTrades': return 'No successful trades.';
			case 'offers.details.loadingDetails': return 'Loading offer details...';
			case 'offers.details.amount': return ({required Object amount}) => 'Amount: ${amount} satoshi';
			case 'offers.details.amountWithCurrency': return ({required Object amount, required Object currency}) => '${amount} ${currency}';
			case 'offers.details.makerFee': return ({required Object fee}) => 'Maker fee: ${fee} satoshi';
			case 'offers.details.takerFee': return ({required Object fee}) => 'Taker fee: ${fee} satoshi';
			case 'offers.details.takerFeeWithStatus': return ({required Object fee, required Object status}) => 'Taker fee: ${fee} satoshi | Status: ${status}';
			case 'offers.details.subtitle': return ({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (fee) satoshi\nStatus: ${status}';
			case 'offers.details.subtitleWithDate': return ({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (fee) satoshi\nStatus: ${status}\nPaid: ${date}';
			case 'offers.details.activeSubtitle': return ({required Object status, required Object amount}) => 'Status: ${status}\nAmount: ${amount} satoshi';
			case 'offers.details.id': return ({required Object id}) => 'Offer ID: ${id}...';
			case 'offers.details.created': return ({required Object dateTime}) => 'Created: ${dateTime}';
			case 'offers.details.takenAfter': return ({required Object duration}) => 'Taken after: ${duration}';
			case 'offers.details.paidAfter': return ({required Object duration}) => 'Paid after: ${duration}';
			case 'offers.details.exchangeRate': return 'Exchange Rate';
			case 'offers.details.takerFeeLabel': return 'Taker fee';
			case 'offers.details.statusLabel': return 'Status';
			case 'offers.details.youllReceive': return 'You\'ll receive';
			case 'offers.details.coordinator': return 'Coordinator';
			case 'offers.actions.take': return 'TAKE';
			case 'offers.actions.takeOffer': return 'Take Offer';
			case 'offers.actions.resume': return 'RESUME';
			case 'offers.actions.cancel': return 'Cancel offer';
			case 'offers.status.created': return 'Created';
			case 'offers.status.funded': return 'Funded';
			case 'offers.status.expired': return 'Expired';
			case 'offers.status.cancelled': return 'Cancelled';
			case 'offers.status.reserved': return 'Reserved';
			case 'offers.status.blikReceived': return 'BLIK Sent';
			case 'offers.status.blikSentToMaker': return 'BLIK Received';
			case 'offers.status.invalidBlik': return 'Invalid BLIK';
			case 'offers.status.conflict': return 'Conflict';
			case 'offers.status.dispute': return 'Dispute';
			case 'offers.status.makerConfirmed': return 'Confirmed';
			case 'offers.status.settled': return 'Settled';
			case 'offers.status.payingTaker': return 'Paying Taker';
			case 'offers.status.takerPaymentFailed': return 'Payment Failed';
			case 'offers.status.takerPaid': return 'Taker Paid';
			case 'offers.statusMessages.reserved': return 'Offer reserved by Taker!';
			case 'offers.statusMessages.cancelled': return 'Offer cancelled successfully.';
			case 'offers.statusMessages.cancelledOrExpired': return 'Offer has been cancelled or expired.';
			case 'offers.statusMessages.noLongerAvailable': return ({required Object status}) => 'Offer is no longer available (Status: ${status}).';
			case 'offers.progress.waitingForTaker': return ({required Object time}) => 'Waiting for taker: ${time}';
			case 'offers.progress.reserved': return ({required Object seconds}) => 'Reserved: ${seconds} s left';
			case 'offers.progress.confirming': return ({required Object seconds}) => 'Confirming: ${seconds} s left';
			case 'offers.errors.loading': return ({required Object details}) => 'Error loading offers: ${details}';
			case 'offers.errors.loadingDetails': return ({required Object details}) => 'Error loading offer details: ${details}';
			case 'offers.errors.detailsMissing': return 'Error: Offer details missing or invalid.';
			case 'offers.errors.detailsNotLoaded': return 'Unable to load offer details.';
			case 'offers.errors.notFound': return 'Error: Offer not found.';
			case 'offers.errors.unexpectedState': return 'Error: Offer is in an unexpected state.';
			case 'offers.errors.unexpectedStateWithStatus': return ({required Object status}) => 'Offer is in an unexpected state (${status}). Please try again or contact support.';
			case 'offers.errors.invalidStatus': return 'Offer has invalid status.';
			case 'offers.errors.couldNotIdentify': return 'Error: Could not identify offer to cancel.';
			case 'offers.errors.cannotBeCancelled': return ({required Object status}) => 'Offer cannot be cancelled in current state (${status}).';
			case 'offers.errors.failedToCancel': return ({required Object details}) => 'Failed to cancel offer: ${details}';
			case 'offers.errors.activeDetailsLost': return 'Error: Lost active offer details.';
			case 'offers.errors.checkingActive': return ({required Object details}) => 'Error checking active offers: ${details}';
			case 'offers.errors.loadingFinished': return ({required Object details}) => 'Error loading finished offers: ${details}';
			case 'offers.errors.cannotResume': return ({required Object status}) => 'Cannot resume offer in state: ${status}';
			case 'offers.errors.cannotResumeTaker': return ({required Object status}) => 'Cannot resume taker offer in state: ${status}';
			case 'offers.errors.resuming': return ({required Object details}) => 'Error resuming offer: ${details}';
			case 'offers.errors.makerPublicKeyNotFound': return 'Maker public key not found';
			case 'offers.errors.takerPublicKeyNotFound': return 'Taker public key not found.';
			case 'reservations.actions.cancel': return 'Cancel reservation';
			case 'reservations.feedback.cancelled': return 'Reservation cancelled.';
			case 'reservations.errors.cancelling': return ({required Object error}) => 'Failed to cancel reservation: ${error}';
			case 'reservations.errors.failedToReserve': return ({required Object details}) => 'Failed to reserve offer: ${details}';
			case 'reservations.errors.failedNoTimestamp': return 'Failed to reserve offer (no timestamp).';
			case 'reservations.errors.timestampMissing': return 'Offer reservation timestamp missing.';
			case 'reservations.errors.notReserved': return ({required Object status}) => 'Offer is no longer in reserved state (${status}).';
			case 'exchange.labels.enterAmount': return 'Enter amount (PLN) to pay:';
			case 'exchange.labels.equivalent': return ({required Object sats}) => '≈ ${sats} satoshi';
			case 'exchange.labels.rate': return ({required Object rate}) => 'Exchange rate ≈ ${rate} PLN/BTC';
			case 'exchange.feedback.fetching': return 'Fetching exchange rate...';
			case 'exchange.errors.fetchingRate': return 'Failed to fetch exchange rate.';
			case 'exchange.errors.invalidFormat': return 'Invalid number format';
			case 'exchange.errors.mustBePositive': return 'Amount must be positive';
			case 'exchange.errors.invalidFeePercentage': return 'Invalid fee percentage';
			case 'exchange.errors.tooLowFiat': return ({required Object minAmount, required Object currency}) => 'Amount is too low. Minimum is ${minAmount} ${currency}.';
			case 'exchange.errors.tooHighFiat': return ({required Object maxAmount, required Object currency}) => 'Amount is too high. Maximum is ${maxAmount} ${currency}.';
			case 'coordinator.info.fee': return 'fee';
			case 'coordinator.info.rangeDisplay': return ({required Object minAmount, required Object maxAmount, required Object currency}) => 'Amount: ${minAmount}-${maxAmount} ${currency}';
			case 'coordinator.info.feeDisplay': return ({required Object fee}) => '${fee}% fee';
			case 'maker.roleSelection.button': return 'PAY with Lightning';
			case 'maker.amountForm.actions.generateInvoice': return 'Generate Invoice';
			case 'maker.amountForm.errors.initiating': return ({required Object details}) => 'Error initiating offer: ${details}';
			case 'maker.amountForm.errors.publicKeyNotLoaded': return 'Error: Public key not yet loaded.';
			case 'maker.payInvoice.title': return 'Pay this Hold invoice:';
			case 'maker.payInvoice.actions.copy': return 'Copy Invoice';
			case 'maker.payInvoice.actions.payInWallet': return 'Pay in Wallet';
			case 'maker.payInvoice.feedback.copied': return 'Invoice copied to clipboard!';
			case 'maker.payInvoice.feedback.waitingConfirmation': return 'Waiting for payment confirmation...';
			case 'maker.payInvoice.errors.couldNotOpenApp': return 'Could not open Lightning app for invoice.';
			case 'maker.payInvoice.errors.openingApp': return ({required Object details}) => 'Error opening Lightning app: ${details}';
			case 'maker.payInvoice.errors.publicKeyNotAvailable': return 'Public key is not available.';
			case 'maker.payInvoice.errors.couldNotFetchActive': return 'Could not fetch active offer details. It may have expired.';
			case 'maker.waitTaker.message': return 'Waiting for a Taker to reserve your offer...';
			case 'maker.waitTaker.progressLabel': return ({required Object time}) => 'Waiting for taker: ${time}';
			case 'maker.waitTaker.errorActiveOfferDetailsLost': return 'Error: Lost active offer details.';
			case 'maker.waitTaker.errorFailedToRetrieveBlik': return 'Error: Failed to retrieve BLIK code.';
			case 'maker.waitTaker.errorRetrievingBlik': return ({required Object details}) => 'Error retrieving BLIK code: ${details}';
			case 'maker.waitTaker.offerNoLongerAvailable': return ({required Object status}) => 'Offer is no longer available (Status: ${status}).';
			case 'maker.waitTaker.errorCouldNotIdentifyOffer': return 'Error: Could not identify offer to cancel.';
			case 'maker.waitTaker.offerCannotBeCancelled': return ({required Object status}) => 'Offer cannot be cancelled in current state (${status}).';
			case 'maker.waitTaker.offerCancelledSuccessfully': return 'Offer cancelled successfully.';
			case 'maker.waitTaker.failedToCancelOffer': return ({required Object details}) => 'Failed to cancel offer: ${details}';
			case 'maker.waitForBlik.title': return 'Waiting for BLIK';
			case 'maker.waitForBlik.message': return 'Waiting for Taker to provide BLIK code.';
			case 'maker.waitForBlik.timeLimitWithSeconds': return ({required Object seconds}) => 'Taker has ${seconds} seconds to provide BLIK code.';
			case 'maker.waitForBlik.progressLabel': return ({required Object seconds}) => 'Reserved: ${seconds} s left';
			case 'maker.confirmPayment.title': return 'BLIK code received!';
			case 'maker.confirmPayment.retrieving': return 'Retrieving BLIK code...';
			case 'maker.confirmPayment.instructions': return 'Enter this code into the payment terminal. When Taker confirms in their banking app and payment is successful, press Confirm below.';
			case 'maker.confirmPayment.actions.confirm': return 'Confirm successful payment';
			case 'maker.confirmPayment.actions.markInvalid': return 'Invalid BLIK Code';
			case 'maker.confirmPayment.feedback.confirmed': return 'Maker confirmed payment.';
			case 'maker.confirmPayment.feedback.confirmedTakerPaid': return 'Payment confirmed! Taker will receive funds.';
			case 'maker.confirmPayment.feedback.progressLabel': return ({required Object seconds}) => 'Confirming: ${seconds} s left';
			case 'maker.confirmPayment.errors.failedToRetrieve': return 'Error: Failed to retrieve BLIK code.';
			case 'maker.confirmPayment.errors.retrieving': return ({required Object details}) => 'Error retrieving BLIK code: ${details}';
			case 'maker.confirmPayment.errors.missingHashOrKey': return 'Error: Missing payment hash or public key.';
			case 'maker.confirmPayment.errors.incorrectState': return ({required Object status}) => 'Offer is not in correct state for confirmation (Status: ${status})';
			case 'maker.confirmPayment.errors.confirming': return ({required Object details}) => 'Error confirming payment: ${details}';
			case 'maker.confirmPayment.errors.invalidState': return 'Error: Received invalid offer state.';
			case 'maker.confirmPayment.errors.internalIncomplete': return 'Internal error: Incomplete offer details.';
			case 'maker.confirmPayment.errors.notAwaitingConfirmation': return ({required Object status}) => 'Offer is no longer awaiting confirmation (Status: ${status}).';
			case 'maker.confirmPayment.errors.unexpectedStatus': return 'Received unexpected offer status from server.';
			case 'maker.invalidBlik.title': return 'Invalid BLIK Code';
			case 'maker.invalidBlik.info': return 'You marked the BLIK code as invalid. Waiting for taker to provide new code or start dispute.';
			case 'maker.conflict.title': return 'Offer Conflict';
			case 'maker.conflict.headline': return 'Offer Conflict Reported';
			case 'maker.conflict.body': return 'You marked the BLIK code as invalid, but the Taker reported a conflict, indicating they believe the payment was successful.';
			case 'maker.conflict.instructions': return 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.';
			case 'maker.conflict.actions.back': return 'Back to Home';
			case 'maker.conflict.actions.confirmPayment': return 'My mistake, confirm BLIK payment success';
			case 'maker.conflict.actions.openDispute': return 'Blik payment did NOT succeed, OPEN DISPUTE';
			case 'maker.conflict.actions.submitDispute': return 'Submit Dispute';
			case 'maker.conflict.disputeDialog.title': return 'Open dispute?';
			case 'maker.conflict.disputeDialog.content': return 'Opening a dispute requires manual verification by the coordinator, which will take time. A dispute fee will be deducted if the dispute is ruled against you. The hold invoice will be settled to prevent it from expiring. If the dispute is ruled in your favor, you will receive a refund (minus fees) to your Lightning address.';
			case 'maker.conflict.disputeDialog.contentDetailed': return 'Opening a dispute will require manual coordinator intervention, which takes time and incurs a dispute fee.\n\nThe hold invoice will be immediately settled to prevent it from expiring before the dispute is resolved.\n\nIf the dispute is ruled in your favor, the satoshi amount will be refunded to your Lightning address (minus fees). Make sure you have a Lightning address configured.';
			case 'maker.conflict.disputeDialog.actions.confirm': return 'Open Dispute';
			case 'maker.conflict.disputeDialog.actions.cancel': return 'Cancel';
			case 'maker.conflict.feedback.disputeOpenedSuccess': return 'Dispute successfully opened. Coordinator will review.';
			case 'maker.conflict.errors.openingDispute': return ({required Object error}) => 'Error opening dispute: ${error}';
			case 'maker.success.title': return 'Offer completed';
			case 'maker.success.headline': return 'Payment confirmed!';
			case 'maker.success.subtitle': return 'Taker has been paid.';
			case 'maker.success.detailsTitle': return 'Offer details:';
			case 'taker.roleSelection.button': return 'SELL BLIK code for satoshi';
			case 'taker.submitBlik.title': return 'Enter 6-digit BLIK code:';
			case 'taker.submitBlik.label': return 'BLIK Code';
			case 'taker.submitBlik.timeLimit': return ({required Object seconds}) => 'Enter BLIK within: ${seconds} s';
			case 'taker.submitBlik.timeExpired': return 'Time to enter BLIK code has expired.';
			case 'taker.submitBlik.actions.submit': return 'Submit BLIK';
			case 'taker.submitBlik.feedback.pasted': return 'Pasted BLIK code.';
			case 'taker.submitBlik.validation.invalidFormat': return 'Enter a valid 6-digit BLIK code.';
			case 'taker.submitBlik.errors.submitting': return ({required Object details}) => 'Error submitting BLIK code: ${details}';
			case 'taker.submitBlik.errors.clipboardInvalid': return 'Clipboard does not contain a valid 6-digit BLIK code.';
			case 'taker.submitBlik.errors.stateChanged': return 'Error: Offer state has changed.';
			case 'taker.submitBlik.errors.stateNotValid': return 'Error: Offer state is no longer valid.';
			case 'taker.submitBlik.errors.fetchedIdMismatch': return ({required Object fetchedId, required Object initialId}) => 'Fetched active offer ID (${fetchedId}) does not match initial offer ID (${initialId}). State mismatch?';
			case 'taker.submitBlik.errors.paymentHashMissing': return 'Offer payment hash missing after fetch.';
			case 'taker.waitConfirmation.title': return 'Waiting for Maker';
			case 'taker.waitConfirmation.statusLabel': return ({required Object status}) => 'Offer status: ${status}';
			case 'taker.waitConfirmation.waitingMaker': return ({required Object seconds}) => 'Waiting for Maker confirmation: ${seconds} s';
			case 'taker.waitConfirmation.waitingMakerConfirmation': return ({required Object seconds}) => 'Waiting for Maker to confirm BLIK is correct. Time remaining: ${seconds}s';
			case 'taker.waitConfirmation.importantNotice': return ({required Object amount, required Object currency}) => 'VERY IMPORTANT: Make sure you only accept BLIK confirmation for ${amount} ${currency}';
			case 'taker.waitConfirmation.importantBlikAmountConfirmation': return ({required Object amount, required Object currency}) => 'VERY IMPORTANT: In your banking app, ensure you are confirming a BLIK payment for exactly ${amount} ${currency}.';
			case 'taker.waitConfirmation.instructions': return 'The offer maker has received your BLIK code and must enter it into the payment terminal. You then must accept the BLIK code in your banking app, make sure you only accept the correct amount. You will receive Lightning payment automatically after confirmation.';
			case 'taker.waitConfirmation.navigatedHome': return 'Navigated home.';
			case 'taker.waitConfirmation.feedback.makerConfirmed': return 'Maker confirmed payment.';
			case 'taker.waitConfirmation.feedback.paymentSuccessful': return 'Payment successful! You will receive funds shortly.';
			case 'taker.waitConfirmation.errors.invalidOfferStateReceived': return 'Received an offer with an invalid state for this screen. Resetting.';
			case 'taker.paymentProcess.title': return 'Payment Process';
			case 'taker.paymentProcess.waitingForOfferUpdate': return 'Waiting for offer status update...';
			case 'taker.paymentProcess.states.preparing': return 'Preparing to send payment...';
			case 'taker.paymentProcess.states.sending': return 'Sending payment...';
			case 'taker.paymentProcess.states.received': return 'Payment received!';
			case 'taker.paymentProcess.states.failed': return 'Payment failed';
			case 'taker.paymentProcess.states.waitingUpdate': return 'Waiting for offer update...';
			case 'taker.paymentProcess.steps.makerConfirmedBlik': return 'Maker confirmed BLIK payment';
			case 'taker.paymentProcess.steps.makerInvoiceSettled': return 'Maker\'s hold invoice settled';
			case 'taker.paymentProcess.steps.payingTakerInvoice': return 'Paying your Lightning invoice';
			case 'taker.paymentProcess.steps.takerInvoicePaid': return 'Your Lightning invoice paid';
			case 'taker.paymentProcess.steps.takerPaymentFailed': return 'Payment to your invoice failed';
			case 'taker.paymentProcess.errors.sending': return ({required Object details}) => 'Error sending payment: ${details}';
			case 'taker.paymentProcess.errors.notConfirmed': return 'Offer not confirmed by Maker.';
			case 'taker.paymentProcess.errors.expired': return 'Offer expired.';
			case 'taker.paymentProcess.errors.cancelled': return 'Offer cancelled.';
			case 'taker.paymentProcess.errors.paymentFailed': return 'Offer payment failed.';
			case 'taker.paymentProcess.errors.unknown': return 'Unknown offer error.';
			case 'taker.paymentProcess.errors.takerPaymentFailed': return 'The payment to your Lightning invoice failed. Please go to the failure details screen to provide a new invoice or investigate.';
			case 'taker.paymentProcess.errors.noPublicKey': return 'Error: Cannot fetch your public key.';
			case 'taker.paymentProcess.errors.loadingPublicKey': return 'Error loading your data';
			case 'taker.paymentProcess.errors.missingPaymentHash': return 'Error: Missing payment details.';
			case 'taker.paymentProcess.loading.publicKey': return 'Loading your data...';
			case 'taker.paymentProcess.actions.goToFailureDetails': return 'Go to Failure Details';
			case 'taker.paymentFailed.title': return 'Payment Failed';
			case 'taker.paymentFailed.instructions': return ({required Object netAmount}) => 'Please provide a new Lightning invoice for ${netAmount} satoshi';
			case 'taker.paymentFailed.form.newInvoiceLabel': return 'New Lightning invoice';
			case 'taker.paymentFailed.form.newInvoiceHint': return 'Enter your BOLT11 invoice';
			case 'taker.paymentFailed.actions.retryPayment': return 'Submit New Invoice';
			case 'taker.paymentFailed.errors.enterValidInvoice': return 'Please enter a valid invoice';
			case 'taker.paymentFailed.errors.updatingInvoice': return ({required Object details}) => 'Error updating invoice: ${details}';
			case 'taker.paymentFailed.errors.paymentRetryFailed': return 'Payment retry failed. Please check the invoice or try again later.';
			case 'taker.paymentFailed.errors.takerPublicKeyNotFound': return 'Taker public key not found.';
			case 'taker.paymentFailed.loading.processingPayment': return 'Processing your payment retry...';
			case 'taker.paymentFailed.success.title': return 'Payment Successful';
			case 'taker.paymentFailed.success.message': return 'Your payment has been processed successfully.';
			case 'taker.paymentSuccess.title': return 'Payment Successful';
			case 'taker.paymentSuccess.message': return 'Your payment has been processed successfully.';
			case 'taker.paymentSuccess.actions.goHome': return 'Go to home';
			case 'taker.invalidBlik.title': return 'Invalid BLIK Code';
			case 'taker.invalidBlik.message': return 'Maker Rejected BLIK Code';
			case 'taker.invalidBlik.explanation': return 'The offer maker indicated that the BLIK code you provided was invalid or didn\'t work. What would you like to do?';
			case 'taker.invalidBlik.actions.retry': return 'I DID NOT PAY, reserve offer again and send new BLIK code';
			case 'taker.invalidBlik.actions.reportConflict': return 'I CONFIRMED BLIK CODE AND IT WAS CHARGED FROM MY BANK ACCOUNT, Report conflict, will cause DISPUTE!';
			case 'taker.invalidBlik.actions.returnHome': return 'Return to home';
			case 'taker.invalidBlik.feedback.conflictReportedSuccess': return 'Conflict reported. Coordinator will review.';
			case 'taker.invalidBlik.errors.reservationFailed': return 'Failed to reserve offer again';
			case 'taker.invalidBlik.errors.conflictReport': return ({required Object details}) => 'Error reporting conflict: ${details}';
			case 'taker.conflict.title': return 'Offer Conflict';
			case 'taker.conflict.headline': return 'Offer Conflict Reported';
			case 'taker.conflict.body': return 'The Maker marked the BLIK code as invalid, but you reported a conflict, indicating you believe the payment was successful.';
			case 'taker.conflict.instructions': return 'Wait for the coordinator to review the situation. You may be asked for more details. Check back later or contact support if needed.';
			case 'taker.conflict.actions.back': return 'Back to Home';
			case 'taker.conflict.feedback.reported': return 'Conflict reported. Coordinator will review.';
			case 'taker.conflict.errors.reporting': return ({required Object details}) => 'Error reporting conflict: ${details}';
			case 'blik.instructions.taker': return 'Once the Maker enters the BLIK code, you will need to confirm the payment in your banking app. Ensure the amount is correct before confirming.';
			case 'home.notifications.title': return 'Get notified about new offers via:';
			case 'home.notifications.telegram': return 'Telegram';
			case 'home.notifications.simplex': return 'SimpleX';
			case 'home.notifications.element': return 'Element';
			case 'home.notifications.signal': return 'Signal';
			case 'home.statistics.title': return 'Finished Offers';
			case 'home.statistics.lifetimeCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'All: ${count} transactions\nAvg wait for BLIK: ${avgBlikTime}\nAvg completion time: ${avgPaidTime}';
			case 'home.statistics.last7DaysCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Last 7d: ${count} transactions\nAvg wait for BLIK: ${avgBlikTime}\nAvg completion time: ${avgPaidTime}';
			case 'home.statistics.errors.loading': return ({required Object error}) => 'Error loading statistics: ${error}';
			case 'nekoInfo.title': return 'What is a Neko?';
			case 'nekoInfo.description': return 'Your Neko is your identity for using BitBlik. It\'s composed of a private and public key to ensure cryptographically secure communication with the coordinator.\n\nTo ensure greater anonymity, it is recommended to use a new, fresh Neko for each offer.';
			case 'generateNewKey.title': return 'Generate New Neko';
			case 'generateNewKey.description': return 'Are you sure you want to generate a new Neko? Your current one will be lost forever if you haven\'t backed it up.';
			case 'generateNewKey.buttons.generate': return 'Generate';
			case 'generateNewKey.errors.activeOffer': return 'You cannot generate a new Neko while you have an active offer.';
			case 'generateNewKey.errors.failed': return 'Failed to generate new Neko';
			case 'generateNewKey.feedback.success': return 'New Neko generated successfully!';
			case 'generateNewKey.tooltips.generate': return 'Generate New Neko';
			case 'backup.title': return 'Backup Neko';
			case 'backup.description': return 'This is your private key. It secures communication with the coordinator. Never reveal it to anyone. Back it up in a secure place to prevent issues during disputes.';
			case 'backup.feedback.copied': return 'Private key copied to clipboard!';
			case 'backup.tooltips.backup': return 'Backup Neko';
			case 'restore.title': return 'Restore Neko';
			case 'restore.labels.privateKey': return 'Private Key';
			case 'restore.buttons.restore': return 'Restore';
			case 'restore.errors.invalidKey': return 'Must be a 64-character hex string.';
			case 'restore.errors.failed': return 'Restore failed';
			case 'restore.feedback.success': return 'Neko restored successfully! App will restart.';
			case 'restore.tooltips.restore': return 'Restore Neko';
			case 'system.loadingPublicKey': return 'Loading your public key...';
			case 'system.errors.generic': return 'An unexpected error occurred. Please try again.';
			case 'system.errors.loadingTimeoutConfig': return 'Error loading timeout configuration.';
			case 'system.errors.loadingCoordinatorConfig': return 'Error loading coordinator configuration. Please try again.';
			case 'system.errors.noPublicKey': return 'Your public key is not available. Cannot proceed.';
			case 'system.errors.internalOfferIncomplete': return 'Internal error: Offer details are incomplete. Please try again.';
			case 'system.errors.loadingPublicKey': return 'Error loading your public key. Please restart the app.';
			case 'system.blik.copied': return 'BLIK code copied to clipboard';
			case 'landing.mainTitle': return 'Your BLIK ⇄ bitcoin Bridge';
			case 'landing.subtitle': return 'Pay for or sell your BLIK code with bitcoin';
			case 'landing.actions.payBlik': return 'Pay BLIK';
			case 'landing.actions.payBlikSubtitle': return 'with bitcoin';
			case 'landing.actions.sellBlik': return 'Buy bitcoin';
			case 'landing.actions.sellBlikSubtitle': return 'with BLIK';
			case 'landing.actions.howItWorks': return 'How it works?';
			case 'faq.screenTitle': return 'FAQ';
			case 'faq.tooltip': return 'FAQ';
			default: return null;
		}
	}
}

