import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'BitBlik'**
  String get appTitle;

  /// A simple greeting
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get greeting;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error message when loading offer details fails
  ///
  /// In en, this message translates to:
  /// **'Error loading offer: {error}'**
  String errorLoadingOffer(Object error);

  /// Displayed when offer details are missing or invalid
  ///
  /// In en, this message translates to:
  /// **'Error: Offer details missing or invalid.'**
  String get errorOfferDetailsMissing;

  /// Error message when the specific offer cannot be found
  ///
  /// In en, this message translates to:
  /// **'Error: Offer not found.'**
  String get errorOfferNotFound;

  /// AppBar title when waiting for BLIK code
  ///
  /// In en, this message translates to:
  /// **'Waiting for BLIK'**
  String get waitingForBlik;

  /// Displayed when offer is reserved by taker
  ///
  /// In en, this message translates to:
  /// **'Offer Reserved by Taker!'**
  String get offerReservedByTaker;

  /// Displayed while waiting for taker to submit BLIK code
  ///
  /// In en, this message translates to:
  /// **'Waiting for Taker to submit their BLIK code.'**
  String get waitingForTakerBlik;

  /// Displayed to indicate taker has 20 seconds
  ///
  /// In en, this message translates to:
  /// **'Taker has 20 seconds to provide the code.'**
  String get takerHas20Seconds;

  /// No description provided for @takerHasXSecondsToProvideBlik.
  ///
  /// In en, this message translates to:
  /// **'Taker has {seconds} seconds to provide BLIK code.'**
  String takerHasXSecondsToProvideBlik(int seconds);

  /// Tooltip for home button
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Displayed when active offer details are lost
  ///
  /// In en, this message translates to:
  /// **'Error: Active offer details lost.'**
  String get errorActiveOfferDetailsLost;

  /// Displayed when BLIK code retrieval fails
  ///
  /// In en, this message translates to:
  /// **'Error: Failed to retrieve BLIK code.'**
  String get errorFailedToRetrieveBlik;

  /// Displayed when there is an error retrieving BLIK code
  ///
  /// In en, this message translates to:
  /// **'Error retrieving BLIK code: {details}'**
  String errorRetrievingBlik(Object details);

  /// Displayed when offer is no longer available
  ///
  /// In en, this message translates to:
  /// **'Offer is no longer available (Status: {status}).'**
  String offerNoLongerAvailable(Object status);

  /// Label for user's offer
  ///
  /// In en, this message translates to:
  /// **'Your Offer:'**
  String get yourOffer;

  /// Amount in sats
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} sats'**
  String amountSats(Object amount);

  /// Maker's fee in sats
  ///
  /// In en, this message translates to:
  /// **'Maker Fee: {fee} sats'**
  String makerFeeSats(Object fee);

  /// Status message indicating the maker has confirmed the fiat payment
  ///
  /// In en, this message translates to:
  /// **'Maker confirmed payment.'**
  String get makerConfirmedPayment;

  /// Taker's fee in sats
  ///
  /// In en, this message translates to:
  /// **'Taker Fee: {fee} sats'**
  String takerFeeSats(Object fee);

  /// Status of the offer
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String status(Object status);

  /// Displayed while waiting for a taker
  ///
  /// In en, this message translates to:
  /// **'Waiting for a Taker to reserve your offer...'**
  String get waitingForTaker;

  /// Button to cancel offer
  ///
  /// In en, this message translates to:
  /// **'Cancel Offer'**
  String get cancelOffer;

  /// Displayed when offer to cancel cannot be identified
  ///
  /// In en, this message translates to:
  /// **'Error: Could not identify offer to cancel.'**
  String get errorCouldNotIdentifyOffer;

  /// Displayed when offer cannot be cancelled in current state
  ///
  /// In en, this message translates to:
  /// **'Offer cannot be cancelled in current state ({status}).'**
  String offerCannotBeCancelled(Object status);

  /// Displayed when offer is cancelled successfully
  ///
  /// In en, this message translates to:
  /// **'Offer cancelled successfully.'**
  String get offerCancelledSuccessfully;

  /// Displayed when offer cancellation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel offer: {details}'**
  String failedToCancelOffer(Object details);

  /// Prompt to enter Lightning Address
  ///
  /// In en, this message translates to:
  /// **'Enter your Lightning Address to continue'**
  String get enterLightningAddress;

  /// Hint for Lightning Address input
  ///
  /// In en, this message translates to:
  /// **'user@domain.com'**
  String get lightningAddressHint;

  /// Label for Lightning Address input
  ///
  /// In en, this message translates to:
  /// **'Lightning Address'**
  String get lightningAddressLabel;

  /// Validation error for Lightning Address
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Lightning Address'**
  String get lightningAddressInvalid;

  /// Button to save and continue
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// Dialog title for editing Lightning Address
  ///
  /// In en, this message translates to:
  /// **'Edit Lightning Address'**
  String get editLightningAddress;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text for completing a process
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Snackbar message when Lightning Address is saved
  ///
  /// In en, this message translates to:
  /// **'Lightning Address saved!'**
  String get lightningAddressSaved;

  /// Snackbar message when Lightning Address is updated
  ///
  /// In en, this message translates to:
  /// **'Lightning Address updated!'**
  String get lightningAddressUpdated;

  /// Text shown while loading offer details
  ///
  /// In en, this message translates to:
  /// **'Loading offer details...'**
  String get loadingOfferDetails;

  /// Snackbar message when saving Lightning Address fails
  ///
  /// In en, this message translates to:
  /// **'Error saving address: {details}'**
  String errorSavingAddress(Object details);

  /// SimpleX notification prompt
  ///
  /// In en, this message translates to:
  /// **'Get notified of new orders with SimpleX'**
  String get getNotifiedSimplex;

  /// Text for the link to join the Element/Matrix notification channel
  ///
  /// In en, this message translates to:
  /// **'Get notified of new orders with Element'**
  String get getNotifiedWithElement;

  /// Displayed when there are no offers
  ///
  /// In en, this message translates to:
  /// **'No offers available yet.'**
  String get noOffersAvailable;

  /// Button to take an offer
  ///
  /// In en, this message translates to:
  /// **'TAKE'**
  String get take;

  /// Button to resume an offer
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// Offer amount in sats
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} sats'**
  String offerAmountSats(Object amount);

  /// Offer Taker fee, status, and ID
  ///
  /// In en, this message translates to:
  /// **'Taker Fee: {fee} sats | Status: {status}'**
  String offerFeeStatusId(Object fee, Object status);

  /// Section title for finished offers
  ///
  /// In en, this message translates to:
  /// **'Finished Offers'**
  String get finishedOffers;

  /// Error loading offers
  ///
  /// In en, this message translates to:
  /// **'Error loading offers: {details}'**
  String errorLoadingOffers(Object details);

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Displayed when offer is in an unexpected state
  ///
  /// In en, this message translates to:
  /// **'Error: Offer is in an unexpected state.'**
  String get errorOfferUnexpectedState;

  /// Error when public key is missing for offer creation
  ///
  /// In en, this message translates to:
  /// **'Error: Public key not loaded yet.'**
  String get errorPublicKeyNotLoaded;

  /// Validation error for number input
  ///
  /// In en, this message translates to:
  /// **'Invalid number format'**
  String get errorInvalidNumberFormat;

  /// Validation error for non-positive amount
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get errorAmountMustBePositive;

  /// Validation error for fee input
  ///
  /// In en, this message translates to:
  /// **'Invalid fee percentage'**
  String get errorInvalidFeePercentage;

  /// Error message when initiating an offer fails
  ///
  /// In en, this message translates to:
  /// **'Error initiating offer: {details}'**
  String errorInitiatingOffer(Object details);

  /// Label instructing user to enter PLN amount
  ///
  /// In en, this message translates to:
  /// **'Enter Amount (PLN) to Pay:'**
  String get enterAmountToPay;

  /// Label for the amount input field
  ///
  /// In en, this message translates to:
  /// **'Amount (PLN)'**
  String get amountLabel;

  /// Text shown while fetching exchange rate
  ///
  /// In en, this message translates to:
  /// **'Fetching exchange rate...'**
  String get fetchingExchangeRate;

  /// Displays the calculated sats equivalent
  ///
  /// In en, this message translates to:
  /// **'≈ {sats} sats'**
  String satsEquivalent(String sats);

  /// Displays the fetched PLN/BTC exchange rate
  ///
  /// In en, this message translates to:
  /// **'PLN/BTC rate ≈ {rate}'**
  String plnBtcRate(String rate);

  /// Error message when fetching exchange rate fails
  ///
  /// In en, this message translates to:
  /// **'Could not fetch exchange rate.'**
  String get errorFetchingRate;

  /// Button text to generate the invoice
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get generateInvoice;

  /// Title instructing the maker to pay the hold invoice
  ///
  /// In en, this message translates to:
  /// **'Pay this Hold Invoice:'**
  String get payHoldInvoiceTitle;

  /// Error shown when the Lightning app cannot be launched via URL
  ///
  /// In en, this message translates to:
  /// **'Could not open Lightning app for invoice.'**
  String get errorCouldNotOpenLightningApp;

  /// Error shown when launching the Lightning app fails
  ///
  /// In en, this message translates to:
  /// **'Error opening Lightning app: {details}'**
  String errorOpeningLightningApp(Object details);

  /// Button text to copy the invoice
  ///
  /// In en, this message translates to:
  /// **'Copy Invoice'**
  String get copyInvoice;

  /// Snackbar message confirming invoice copy
  ///
  /// In en, this message translates to:
  /// **'Invoice copied to clipboard!'**
  String get invoiceCopied;

  /// Status text while polling for invoice payment
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation...'**
  String get waitingForPaymentConfirmation;

  /// Error when public key is needed but not found after payment
  ///
  /// In en, this message translates to:
  /// **'Public key not available.'**
  String get errorPublicKeyNotAvailable;

  /// Error when fetching full offer details fails after payment
  ///
  /// In en, this message translates to:
  /// **'Could not fetch active offer details. It might have expired.'**
  String get errorCouldNotFetchActiveOffer;

  /// Error shown when payment hash or public key is missing during confirmation
  ///
  /// In en, this message translates to:
  /// **'Error: Missing payment hash or public key.'**
  String get errorMissingPaymentHashOrKey;

  /// Error shown when trying to confirm payment but offer is in wrong state
  ///
  /// In en, this message translates to:
  /// **'Offer not in correct state for confirmation (Status: {status})'**
  String errorOfferIncorrectStateConfirmation(Object status);

  /// Snackbar message after maker confirms payment
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed! Taker will be paid.'**
  String get paymentConfirmedTakerPaid;

  /// AppBar title for the payment process screen
  ///
  /// In en, this message translates to:
  /// **'Payment Process'**
  String get paymentProcessTitle;

  /// Error shown when confirming maker payment fails
  ///
  /// In en, this message translates to:
  /// **'Error confirming payment: {details}'**
  String errorConfirmingPayment(Object details);

  /// Snackbar message confirming BLIK code copy
  ///
  /// In en, this message translates to:
  /// **'BLIK code copied to clipboard'**
  String get blikCopied;

  /// Status text while waiting for BLIK code to be fetched
  ///
  /// In en, this message translates to:
  /// **'Retrieving BLIK code...'**
  String get retrievingBlikCode;

  /// Title indicating BLIK code has been received
  ///
  /// In en, this message translates to:
  /// **'BLIK Code Received!'**
  String get blikCodeReceivedTitle;

  /// Tooltip for the copy icon button
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboardTooltip;

  /// Instructions for the maker after receiving the BLIK code
  ///
  /// In en, this message translates to:
  /// **'Enter this code into the payment terminal. Once the Taker confirms in their bank app and the payment succeeds, press Confirm below.'**
  String get blikInstructionsMaker;

  /// Button text for maker to confirm successful payment
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment Success'**
  String get confirmPaymentSuccessButton;

  /// Error when the screen receives an offer in an unexpected initial state
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid offer state received.'**
  String get errorInvalidOfferStateReceived;

  /// Error when critical offer details (like payment hash) are missing
  ///
  /// In en, this message translates to:
  /// **'Internal error: Offer details incomplete.'**
  String get errorInternalOfferIncomplete;

  /// Error when the offer status string is not a valid enum value
  ///
  /// In en, this message translates to:
  /// **'Offer has an invalid status.'**
  String get errorOfferInvalidStatus;

  /// Message shown when polling reveals the offer is no longer in a waiting state
  ///
  /// In en, this message translates to:
  /// **'Offer is no longer awaiting confirmation (Status: {status}).'**
  String errorOfferNotAwaitingConfirmation(Object status);

  /// Error when the status string from the server is unknown
  ///
  /// In en, this message translates to:
  /// **'Received an unexpected offer status from the server.'**
  String get errorUnexpectedStatusFromServer;

  /// Message shown when polling reveals the offer was cancelled or expired
  ///
  /// In en, this message translates to:
  /// **'Offer was cancelled or expired.'**
  String get offerCancelledOrExpired;

  /// Snackbar message shown to the taker upon successful payment
  ///
  /// In en, this message translates to:
  /// **'Payment Successful! You should have now received the funds.'**
  String get paymentSuccessfulTaker;

  /// Status message indicating the Lightning payment has been received by the taker
  ///
  /// In en, this message translates to:
  /// **'Payment Received!'**
  String get paymentReceived;

  /// Status message shown before attempting to send the Lightning payment
  ///
  /// In en, this message translates to:
  /// **'Preparing to send payment...'**
  String get preparingToSendPayment;

  /// Status message shown while the Lightning payment is being sent
  ///
  /// In en, this message translates to:
  /// **'Sending payment...'**
  String get sendingPayment;

  /// Status message indicating the Lightning payment failed
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// Error message shown when sending the Lightning payment fails
  ///
  /// In en, this message translates to:
  /// **'Error sending payment: {details}'**
  String errorSendingPayment(Object details);

  /// Error message when the offer status is not 'Confirmed' when expected
  ///
  /// In en, this message translates to:
  /// **'Offer not confirmed by maker.'**
  String get errorOfferNotConfirmed;

  /// Error message when the offer has expired
  ///
  /// In en, this message translates to:
  /// **'Offer expired.'**
  String get errorOfferExpired;

  /// Error message when the offer has been cancelled
  ///
  /// In en, this message translates to:
  /// **'Offer cancelled.'**
  String get errorOfferCancelled;

  /// Error message when the offer status indicates payment failure
  ///
  /// In en, this message translates to:
  /// **'Offer payment failed.'**
  String get errorOfferPaymentFailed;

  /// Generic error message for unknown offer issues
  ///
  /// In en, this message translates to:
  /// **'Unknown offer error.'**
  String get errorOfferUnknown;

  /// Error shown when the offer is found in an unexpected state during build or processing
  ///
  /// In en, this message translates to:
  /// **'Offer is in an unexpected state ({status}).'**
  String errorOfferUnexpectedStateWithStatus(Object status);

  /// Label displaying the current offer status
  ///
  /// In en, this message translates to:
  /// **'Offer Status: {status}'**
  String offerStatusLabel(Object status);

  /// Countdown timer showing time left for maker confirmation
  ///
  /// In en, this message translates to:
  /// **'Waiting for Maker confirmation: {seconds} s'**
  String waitingMakerConfirmation(int seconds);

  /// Important instruction for the taker about confirming the correct BLIK amount
  ///
  /// In en, this message translates to:
  /// **'VERY IMPORTANT: Be sure to accept only BLIK confirmation for amount of {amount} {currency}'**
  String importantBlikAmountConfirmation(String amount, String currency);

  /// Detailed instructions for the taker while waiting for confirmation
  ///
  /// In en, this message translates to:
  /// **'The offer maker has been sent your BLIK code and needs to enter it in the payment terminal. You then will need to accept the BLIK code in your bank app, be sure to only accept the correct amount. You will receive the Lightning payment automatically after confirmation.'**
  String get blikInstructionsTaker;

  /// Countdown timer text in the progress bar for submitting BLIK
  ///
  /// In en, this message translates to:
  /// **'Submit BLIK within: {seconds} s'**
  String submitBlikWithinSeconds(int seconds);

  /// Error when the fetched offer ID doesn't match the expected one
  ///
  /// In en, this message translates to:
  /// **'Fetched active offer ID ({fetchedId}) does not match initial offer ID ({initialId}). State mismatch?'**
  String errorFetchedOfferIdMismatch(Object fetchedId, Object initialId);

  /// Error when trying to submit BLIK but the offer is not reserved
  ///
  /// In en, this message translates to:
  /// **'Offer is no longer in reserved state ({status}).'**
  String errorOfferNotReserved(Object status);

  /// Error when the reservedAt field is unexpectedly null
  ///
  /// In en, this message translates to:
  /// **'Offer reservation timestamp is missing.'**
  String get errorOfferReservationTimestampMissing;

  /// Error when the payment hash is missing after fetching full offer details
  ///
  /// In en, this message translates to:
  /// **'Offer payment hash is missing after fetch.'**
  String get errorOfferPaymentHashMissing;

  /// Generic error message when fetching full offer details fails
  ///
  /// In en, this message translates to:
  /// **'Error loading offer details: {details}'**
  String errorLoadingOfferDetails(Object details);

  /// Message shown when the 20-second timer for BLIK input runs out
  ///
  /// In en, this message translates to:
  /// **'BLIK input time expired.'**
  String get blikInputTimeExpired;

  /// Error shown when the offer state changes unexpectedly during BLIK submission
  ///
  /// In en, this message translates to:
  /// **'Error: Offer state changed.'**
  String get errorOfferStateChanged;

  /// Error shown when trying to submit BLIK but the offer state is invalid
  ///
  /// In en, this message translates to:
  /// **'Error: Offer state is no longer valid.'**
  String get errorOfferStateNotValid;

  /// Validation error for the BLIK code input field
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit BLIK code.'**
  String get errorInvalidBlikFormat;

  /// Error shown if the user cancels the LN Address prompt
  ///
  /// In en, this message translates to:
  /// **'Lightning Address is required.'**
  String get errorLightningAddressRequired;

  /// Error shown when the API call to submit BLIK fails
  ///
  /// In en, this message translates to:
  /// **'Error submitting BLIK: {details}'**
  String errorSubmittingBlik(Object details);

  /// Snackbar message confirming successful paste of BLIK code
  ///
  /// In en, this message translates to:
  /// **'Pasted BLIK code.'**
  String get blikPasted;

  /// Snackbar message when pasted content is not a valid BLIK code
  ///
  /// In en, this message translates to:
  /// **'Clipboard does not contain a valid 6-digit BLIK code.'**
  String get errorClipboardInvalidBlik;

  /// Fallback text shown if offer details fail to load for the screen
  ///
  /// In en, this message translates to:
  /// **'Offer details could not be loaded.'**
  String get errorOfferDetailsNotLoaded;

  /// Label above the selected offer details card
  ///
  /// In en, this message translates to:
  /// **'Selected Offer:'**
  String get selectedOfferLabel;

  /// Subtitle for the offer card showing sats, fee, and status
  ///
  /// In en, this message translates to:
  /// **'{sats} + {fee} (fee) sats\nStatus: {status}'**
  String offerDetailsSubtitle(int sats, int fee, String status);

  /// Label instructing the user to enter the BLIK code
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit BLIK Code:'**
  String get enterBlikCodeLabel;

  /// Label for the BLIK code input field
  ///
  /// In en, this message translates to:
  /// **'BLIK Code'**
  String get blikCodeLabel;

  /// Tooltip for the paste button next to the BLIK input
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboardTooltip;

  /// Text for the button to submit the BLIK code
  ///
  /// In en, this message translates to:
  /// **'Submit BLIK'**
  String get submitBlikButton;

  /// Error message shown when fetching initial active offers fails
  ///
  /// In en, this message translates to:
  /// **'Error checking active offers: {details}'**
  String errorCheckingActiveOffers(Object details);

  /// Button text for the Maker role (paying with LN)
  ///
  /// In en, this message translates to:
  /// **'PAY with Lightning'**
  String get payWithLightningButton;

  /// Button text for the Taker role (selling BLIK for sats)
  ///
  /// In en, this message translates to:
  /// **'SELL BLIK code for sats'**
  String get sellBlikButton;

  /// Title indicating the user has an active offer
  ///
  /// In en, this message translates to:
  /// **'You have an active offer:'**
  String get activeOfferTitle;

  /// Label showing the user's role in the active offer
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// The Maker role name
  ///
  /// In en, this message translates to:
  /// **'Maker'**
  String get roleMaker;

  /// The Taker role name
  ///
  /// In en, this message translates to:
  /// **'Taker'**
  String get roleTaker;

  /// Subtitle for the active offer card showing status and amount
  ///
  /// In en, this message translates to:
  /// **'Status: {status}\nAmount: {amount} sats'**
  String activeOfferSubtitle(String status, int amount);

  /// Label showing the taker's LN address in the active offer card (e.g., for failed payments)
  ///
  /// In en, this message translates to:
  /// **'Lightning address: {address}'**
  String lightningAddressLabelShort(String address);

  /// Error when trying to resume a maker offer but the public key is missing
  ///
  /// In en, this message translates to:
  /// **'Maker public key not found'**
  String get errorMakerPublicKeyNotFound;

  /// Snackbar message when resuming an active offer fails
  ///
  /// In en, this message translates to:
  /// **'Error resuming offer: {details}'**
  String errorResumingOffer(Object details);

  /// Error message shown when fetching finished offers fails
  ///
  /// In en, this message translates to:
  /// **'Error loading finished offers: {details}'**
  String errorLoadingFinishedOffers(Object details);

  /// Title for the section showing recently finished offers
  ///
  /// In en, this message translates to:
  /// **'Finished Offers (last 24h):'**
  String get finishedOffersTitle;

  /// Subtitle for a finished offer card showing details and payment time
  ///
  /// In en, this message translates to:
  /// **'{sats} + {fee} (fee) sats\nStatus: {status}\nPaid at: {date}'**
  String finishedOfferSubtitle(int sats, int fee, String status, String date);

  /// Snackbar message when trying to resume an offer in an unsupported state
  ///
  /// In en, this message translates to:
  /// **'Cannot resume offer in state: {status}'**
  String errorCannotResumeOfferState(Object status);

  /// Snackbar message when trying to resume a Taker offer in an unsupported state
  ///
  /// In en, this message translates to:
  /// **'Cannot resume Taker offer in state: {status}'**
  String errorCannotResumeTakerOfferState(Object status);

  /// Title for the payment failed screen (AppBar and Headline)
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailedTitle;

  /// Instructions on the payment failed screen explaining the situation and asking for a new invoice
  ///
  /// In en, this message translates to:
  /// **'Please provide a new Lightning invoice for the amount of {netAmount} sats.'**
  String paymentFailedInstructions(int netAmount);

  /// Label for the text field where the user enters a new invoice
  ///
  /// In en, this message translates to:
  /// **'New Lightning Invoice'**
  String get newLightningInvoiceLabel;

  /// Hint text for the new invoice text field
  ///
  /// In en, this message translates to:
  /// **'Enter your BOLT11 invoice'**
  String get newLightningInvoiceHint;

  /// Snackbar validation error when the new invoice field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid invoice'**
  String get errorEnterValidInvoice;

  /// Snackbar error message when submitting the new invoice fails
  ///
  /// In en, this message translates to:
  /// **'Error updating invoice: {details}'**
  String errorUpdatingInvoice(Object details);

  /// Button text to submit the newly entered invoice
  ///
  /// In en, this message translates to:
  /// **'Submit New Invoice'**
  String get submitNewInvoiceButton;

  /// AppBar title for the success screen
  ///
  /// In en, this message translates to:
  /// **'Offer Completed'**
  String get offerCompletedTitle;

  /// Headline text on the success screen
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed!'**
  String get paymentConfirmedHeadline;

  /// Subtitle text on the success screen confirming taker payment
  ///
  /// In en, this message translates to:
  /// **'The Taker has been paid.'**
  String get takerPaidSubtitle;

  /// Title for the card showing completed offer details
  ///
  /// In en, this message translates to:
  /// **'Offer Details:'**
  String get offerDetailsTitle;

  /// Label showing the truncated Offer ID in the details card
  ///
  /// In en, this message translates to:
  /// **'Offer ID: {id}...'**
  String offerIdLabel(String id);

  /// Error message when fetching the saved Lightning Address fails
  ///
  /// In en, this message translates to:
  /// **'Error loading Lightning Address: {details}'**
  String errorLoadingLightningAddress(Object details);

  /// Tooltip for the green checkmark indicating a valid LN Address
  ///
  /// In en, this message translates to:
  /// **'Valid Lightning Address'**
  String get validLightningAddressTooltip;

  /// Error message when reserving an offer succeeds but doesn't return a timestamp
  ///
  /// In en, this message translates to:
  /// **'Failed to reserve offer (no timestamp returned).'**
  String get errorFailedToReserveOfferNoTimestamp;

  /// Generic error message when reserving an offer fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reserve offer: {details}'**
  String errorFailedToReserveOffer(Object details);

  /// Text inside the progress bar when an offer is funded and waiting for a taker
  ///
  /// In en, this message translates to:
  /// **'Waiting for taker: {time}'**
  String progressWaitingForTaker(String time);

  /// Text inside the progress bar when an offer is reserved by a taker
  ///
  /// In en, this message translates to:
  /// **'Reserved: {seconds} s left'**
  String progressReserved(int seconds);

  /// Text inside the progress bar when waiting for the maker to confirm payment after BLIK is received
  ///
  /// In en, this message translates to:
  /// **'Confirming: {seconds} s left'**
  String progressConfirming(int seconds);

  /// Error message when the public key cannot be retrieved
  ///
  /// In en, this message translates to:
  /// **'Error: Could not retrieve your public key.'**
  String get errorNoPublicKey;

  /// Status message when polling for offer updates but no offer is currently found or in expected state
  ///
  /// In en, this message translates to:
  /// **'Waiting for offer update...'**
  String get waitingForOfferUpdate;

  /// Status message while waiting for the public key to load
  ///
  /// In en, this message translates to:
  /// **'Loading your details...'**
  String get loadingPublicKey;

  /// Error message when loading the public key fails
  ///
  /// In en, this message translates to:
  /// **'Error loading your details'**
  String get errorLoadingPublicKey;

  /// Error shown when the payment hash is missing for the payment process screen
  ///
  /// In en, this message translates to:
  /// **'Error: Payment details are missing.'**
  String get errorMissingPaymentHash;

  /// Checklist item: Maker confirmed BLIK payment
  ///
  /// In en, this message translates to:
  /// **'Maker confirmed BLIK payment success'**
  String get taskMakerConfirmedBlik;

  /// Checklist item: Maker's hold invoice is settled
  ///
  /// In en, this message translates to:
  /// **'Maker hold invoice settled'**
  String get taskMakerInvoiceSettled;

  /// Checklist item: System is paying the taker's invoice
  ///
  /// In en, this message translates to:
  /// **'Generating & paying your invoice'**
  String get taskPayingTakerInvoice;

  /// Checklist item: Taker's invoice has been paid
  ///
  /// In en, this message translates to:
  /// **'Your invoice paid successfully'**
  String get taskTakerInvoicePaid;

  /// Checklist item: Payment to the taker failed (used primarily for state mapping)
  ///
  /// In en, this message translates to:
  /// **'Payment to you failed'**
  String get taskTakerPaymentFailed;

  /// Error message shown below the failed checklist item
  ///
  /// In en, this message translates to:
  /// **'Payment to your Lightning Address failed. Please check the details and provide a new invoice if necessary.'**
  String get errorTakerPaymentFailed;

  /// Button text to navigate to the payment failure screen
  ///
  /// In en, this message translates to:
  /// **'Go to Failure Details'**
  String get goToFailureDetails;

  /// Error when the taker's public key is missing during payment retry.
  ///
  /// In en, this message translates to:
  /// **'Taker public key not found.'**
  String get errorTakerPublicKeyNotFound;

  /// Error message shown when the payment retry attempt still results in failure.
  ///
  /// In en, this message translates to:
  /// **'Payment retry failed. Please check the invoice or try again later.'**
  String get paymentRetryFailedError;

  /// Title for the screen when the taker payment succeeds after a retry.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessfulTitle;

  /// Message confirming successful payment after a retry.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully.'**
  String get paymentSuccessfulMessage;

  /// Button text to navigate back to the home screen after successful payment retry.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHomeButton;

  /// Title for the screen when the maker marks the BLIK code as invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid BLIK Code'**
  String get makerInvalidBlikTitle;

  /// Informational text shown to the maker after marking the BLIK code as invalid
  ///
  /// In en, this message translates to:
  /// **'You marked the BLIK code as invalid. Waiting for the taker to provide a new code or initiate a dispute.'**
  String get makerInvalidBlikInfo;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get genericError;

  /// Button text for the maker to mark the received BLIK code as invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid BLIK Code'**
  String get makerInvalidBlikButton;

  /// Title for the screen shown to the Taker when the Maker marks the BLIK as invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid BLIK Code'**
  String get invalidBlikTitle;

  /// Headline message shown to the Taker when the Maker marks the BLIK as invalid
  ///
  /// In en, this message translates to:
  /// **'Maker Rejected BLIK Code'**
  String get invalidBlikMessage;

  /// Explanation shown to the Taker about why they are seeing this screen
  ///
  /// In en, this message translates to:
  /// **'The Maker has indicated that the BLIK code you provided was invalid or did not work. What would you like to do?'**
  String get invalidBlikExplanation;

  /// Button text for the Taker to try submitting a new BLIK code
  ///
  /// In en, this message translates to:
  /// **'I DID NOT PAY, reserve Offer again and submit a new BLIK Code'**
  String get invalidBlikRetryButton;

  /// Button text for the Taker to report a conflict if they believe they paid successfully
  ///
  /// In en, this message translates to:
  /// **'I CONFIRMED THE BLIK CODE AND IT GOT CHARGED FROM MY BANK ACCOUNT, Report Conflict, will cause DISPUTE!'**
  String get invalidBlikConflictButton;

  /// Button text to cancel the current flow and return to the home/offer list screen
  ///
  /// In en, this message translates to:
  /// **'Return Home'**
  String get cancelAndReturnHome;

  /// Snackbar message shown to the Taker after successfully reporting a conflict
  ///
  /// In en, this message translates to:
  /// **'Conflict reported. The coordinator will review the case.'**
  String get conflictReportedSuccess;

  /// Snackbar message shown to the Taker when reporting a conflict fails
  ///
  /// In en, this message translates to:
  /// **'Error reporting conflict: {details}'**
  String conflictReportError(Object details);

  /// AppBar title for the Taker conflict screen
  ///
  /// In en, this message translates to:
  /// **'Offer Conflict'**
  String get takerConflictTitle;

  /// Headline text on the Taker conflict screen
  ///
  /// In en, this message translates to:
  /// **'Offer Conflict Reported'**
  String get takerConflictHeadline;

  /// Main informational text on the Taker conflict screen
  ///
  /// In en, this message translates to:
  /// **'The Maker marked the BLIK code as invalid, but you have reported a conflict, indicating you believe the payment was successful.'**
  String get takerConflictBody;

  /// Instructions for the Taker on the conflict screen
  ///
  /// In en, this message translates to:
  /// **'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.'**
  String get takerConflictInstructions;

  /// Button text on the Taker conflict screen to go back to the main screen
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get takerConflictBackButton;

  /// AppBar title for the Maker conflict screen
  ///
  /// In en, this message translates to:
  /// **'Offer Conflict'**
  String get makerConflictTitle;

  /// Headline text on the Maker conflict screen
  ///
  /// In en, this message translates to:
  /// **'Offer Conflict Reported'**
  String get makerConflictHeadline;

  /// Main informational text on the Maker conflict screen
  ///
  /// In en, this message translates to:
  /// **'You marked the BLIK code as invalid, but the Taker has reported a conflict, indicating they believe the payment was successful.'**
  String get makerConflictBody;

  /// Instructions for the Maker on the conflict screen
  ///
  /// In en, this message translates to:
  /// **'Please wait for the coordinator to review the situation. You may be contacted for more details. Check back later or contact support if needed.'**
  String get makerConflictInstructions;

  /// Button text on the Maker conflict screen to go back to the main screen
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get makerConflictBackButton;

  /// Button on Maker conflict screen to admit mistake and confirm payment
  ///
  /// In en, this message translates to:
  /// **'My mistake, confirm BLIK payment success'**
  String get makerConflictConfirmPaymentButton;

  /// Button on Maker conflict screen to open a dispute
  ///
  /// In en, this message translates to:
  /// **'Blik payment did NOT succeed, OPEN DISPUTE'**
  String get makerConflictOpenDisputeButton;

  /// Title for the dispute confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Open Dispute?'**
  String get makerConflictDisputeDialogTitle;

  /// Content explaining the consequences of opening a dispute
  ///
  /// In en, this message translates to:
  /// **'Opening a dispute requires manual review by the coordinator, which may take time. A dispute fee will be deducted if the dispute is resolved against you. The hold invoice will be settled to prevent expiry. If resolved in your favor, you will be refunded (minus fees) to your Lightning Address.'**
  String get makerConflictDisputeDialogContent;

  /// Confirm button text for the dispute dialog
  ///
  /// In en, this message translates to:
  /// **'Open Dispute'**
  String get makerConflictDisputeDialogConfirm;

  /// Cancel button text for the dispute dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get makerConflictDisputeDialogCancel;

  /// Detailed content explaining the consequences of opening a dispute in the Maker Conflict screen
  ///
  /// In en, this message translates to:
  /// **'Opening a dispute will require manual intervention by the coordinator, which will take time and incur a dispute fee.\n\nThe hold invoice will be settled immediately to prevent expiry before the dispute is resolved.\n\nIf the dispute is resolved in your favor, the sats amount will be refunded to your Lightning Address (minus dispute fees). Please ensure you have a Lightning Address configured.'**
  String get makerConflictDisputeDialogContentDetailed;

  /// Button text in the Lightning Address dialog when submitting a dispute
  ///
  /// In en, this message translates to:
  /// **'Submit Dispute'**
  String get makerConflictSubmitDisputeButton;

  /// Error message when opening a dispute fails
  ///
  /// In en, this message translates to:
  /// **'Error opening dispute: {error}'**
  String errorOpenDispute(String error);

  /// Success message after opening a dispute
  ///
  /// In en, this message translates to:
  /// **'Dispute opened successfully. The coordinator will review the case.'**
  String get successOpenDispute;

  /// Error message when the coordinator's timeout configuration cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading timeout configuration.'**
  String get errorLoadingTimeoutConfiguration;

  /// Validation error when the entered fiat amount is below the minimum allowed
  ///
  /// In en, this message translates to:
  /// **'Amount is too low. Minimum is {minAmount} {currency}.'**
  String errorAmountTooLowFiat(String minAmount, String currency);

  /// Validation error when the entered fiat amount is above the maximum allowed
  ///
  /// In en, this message translates to:
  /// **'Amount is too high. Maximum is {maxAmount} {currency}.'**
  String errorAmountTooHighFiat(String maxAmount, String currency);

  /// Hint text displaying the allowed fiat amount range under an input field
  ///
  /// In en, this message translates to:
  /// **'Min/Max: {minAmount}-{maxAmount} {currency}'**
  String amountRangeHint(String minAmount, String maxAmount, String currency);

  /// Error message when fetching coordinator configuration fails
  ///
  /// In en, this message translates to:
  /// **'Error loading coordinator configuration. Please try again.'**
  String get errorLoadingCoordinatorConfig;

  /// No description provided for @successfulTradeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Finished recent trades'**
  String get successfulTradeStatistics;

  /// No description provided for @offerCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created: {dateTime}'**
  String offerCreatedAt(Object dateTime);

  /// No description provided for @offerTakenAfter.
  ///
  /// In en, this message translates to:
  /// **'Taken after: {duration}'**
  String offerTakenAfter(Object duration);

  /// No description provided for @offerPaidAfter.
  ///
  /// In en, this message translates to:
  /// **'Paid after: {duration}'**
  String offerPaidAfter(Object duration);

  /// No description provided for @offerFiatAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency}'**
  String offerFiatAmount(Object amount, Object currency);

  /// No description provided for @noSuccessfulTradesYet.
  ///
  /// In en, this message translates to:
  /// **'No successful trades yet.'**
  String get noSuccessfulTradesYet;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String errorLoadingStats(Object error);

  /// Compact lifetime statistics line
  ///
  /// In en, this message translates to:
  /// **'All: {count} trades\nWaited in avg {avgBlikTime} to receive BLIK code\nFull transaction avg time {avgPaidTime}'**
  String statsLifetimeCompact(
    String count,
    String avgBlikTime,
    String avgPaidTime,
  );

  /// Compact 7-day statistics line
  ///
  /// In en, this message translates to:
  /// **'Last 7d: {count}  trades\nWaited in avg {avgBlikTime} to receive BLIK code\nFull transaction avg time {avgPaidTime}'**
  String statsLast7DaysCompact(
    String count,
    String avgBlikTime,
    String avgPaidTime,
  );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
