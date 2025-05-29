///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPl extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsPl _root = this; // ignore: unused_field

	@override 
	TranslationsPl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPl(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppPl app = _TranslationsAppPl._(_root);
	@override late final _TranslationsCommonPl common = _TranslationsCommonPl._(_root);
	@override late final _TranslationsLightningAddressPl lightningAddress = _TranslationsLightningAddressPl._(_root);
	@override late final _TranslationsOffersPl offers = _TranslationsOffersPl._(_root);
	@override late final _TranslationsReservationsPl reservations = _TranslationsReservationsPl._(_root);
	@override late final _TranslationsExchangePl exchange = _TranslationsExchangePl._(_root);
	@override late final _TranslationsMakerPl maker = _TranslationsMakerPl._(_root);
	@override late final _TranslationsTakerPl taker = _TranslationsTakerPl._(_root);
	@override late final _TranslationsHomePl home = _TranslationsHomePl._(_root);
	@override late final _TranslationsSystemPl system = _TranslationsSystemPl._(_root);
}

// Path: app
class _TranslationsAppPl extends TranslationsAppEn {
	_TranslationsAppPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'BitBlik';
	@override String get greeting => 'Cześć!';
}

// Path: common
class _TranslationsCommonPl extends TranslationsCommonEn {
	_TranslationsCommonPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCommonButtonsPl buttons = _TranslationsCommonButtonsPl._(_root);
	@override late final _TranslationsCommonLabelsPl labels = _TranslationsCommonLabelsPl._(_root);
	@override late final _TranslationsCommonRolesPl roles = _TranslationsCommonRolesPl._(_root);
	@override late final _TranslationsCommonNotificationsPl notifications = _TranslationsCommonNotificationsPl._(_root);
	@override late final _TranslationsCommonClipboardPl clipboard = _TranslationsCommonClipboardPl._(_root);
}

// Path: lightningAddress
class _TranslationsLightningAddressPl extends TranslationsLightningAddressEn {
	_TranslationsLightningAddressPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLightningAddressLabelsPl labels = _TranslationsLightningAddressLabelsPl._(_root);
	@override late final _TranslationsLightningAddressPromptsPl prompts = _TranslationsLightningAddressPromptsPl._(_root);
	@override late final _TranslationsLightningAddressFeedbackPl feedback = _TranslationsLightningAddressFeedbackPl._(_root);
	@override late final _TranslationsLightningAddressErrorsPl errors = _TranslationsLightningAddressErrorsPl._(_root);
}

// Path: offers
class _TranslationsOffersPl extends TranslationsOffersEn {
	_TranslationsOffersPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOffersDisplayPl display = _TranslationsOffersDisplayPl._(_root);
	@override late final _TranslationsOffersDetailsPl details = _TranslationsOffersDetailsPl._(_root);
	@override late final _TranslationsOffersActionsPl actions = _TranslationsOffersActionsPl._(_root);
	@override late final _TranslationsOffersStatusPl status = _TranslationsOffersStatusPl._(_root);
	@override late final _TranslationsOffersErrorsPl errors = _TranslationsOffersErrorsPl._(_root);
}

// Path: reservations
class _TranslationsReservationsPl extends TranslationsReservationsEn {
	_TranslationsReservationsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsReservationsActionsPl actions = _TranslationsReservationsActionsPl._(_root);
	@override late final _TranslationsReservationsFeedbackPl feedback = _TranslationsReservationsFeedbackPl._(_root);
	@override late final _TranslationsReservationsErrorsPl errors = _TranslationsReservationsErrorsPl._(_root);
}

// Path: exchange
class _TranslationsExchangePl extends TranslationsExchangeEn {
	_TranslationsExchangePl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsExchangeLabelsPl labels = _TranslationsExchangeLabelsPl._(_root);
	@override late final _TranslationsExchangeFeedbackPl feedback = _TranslationsExchangeFeedbackPl._(_root);
	@override late final _TranslationsExchangeErrorsPl errors = _TranslationsExchangeErrorsPl._(_root);
}

// Path: maker
class _TranslationsMakerPl extends TranslationsMakerEn {
	_TranslationsMakerPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMakerRoleSelectionPl roleSelection = _TranslationsMakerRoleSelectionPl._(_root);
	@override late final _TranslationsMakerAmountFormPl amountForm = _TranslationsMakerAmountFormPl._(_root);
	@override late final _TranslationsMakerPayInvoicePl payInvoice = _TranslationsMakerPayInvoicePl._(_root);
	@override late final _TranslationsMakerWaitTakerPl waitTaker = _TranslationsMakerWaitTakerPl._(_root);
	@override late final _TranslationsMakerWaitForBlikPl waitForBlik = _TranslationsMakerWaitForBlikPl._(_root);
	@override late final _TranslationsMakerConfirmPaymentPl confirmPayment = _TranslationsMakerConfirmPaymentPl._(_root);
	@override late final _TranslationsMakerInvalidBlikPl invalidBlik = _TranslationsMakerInvalidBlikPl._(_root);
	@override late final _TranslationsMakerConflictPl conflict = _TranslationsMakerConflictPl._(_root);
	@override late final _TranslationsMakerSuccessPl success = _TranslationsMakerSuccessPl._(_root);
}

// Path: taker
class _TranslationsTakerPl extends TranslationsTakerEn {
	_TranslationsTakerPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTakerRoleSelectionPl roleSelection = _TranslationsTakerRoleSelectionPl._(_root);
	@override late final _TranslationsTakerSubmitBlikPl submitBlik = _TranslationsTakerSubmitBlikPl._(_root);
	@override late final _TranslationsTakerWaitConfirmationPl waitConfirmation = _TranslationsTakerWaitConfirmationPl._(_root);
	@override late final _TranslationsTakerPaymentProcessPl paymentProcess = _TranslationsTakerPaymentProcessPl._(_root);
	@override late final _TranslationsTakerPaymentFailedPl paymentFailed = _TranslationsTakerPaymentFailedPl._(_root);
	@override late final _TranslationsTakerPaymentSuccessPl paymentSuccess = _TranslationsTakerPaymentSuccessPl._(_root);
	@override late final _TranslationsTakerInvalidBlikPl invalidBlik = _TranslationsTakerInvalidBlikPl._(_root);
	@override late final _TranslationsTakerConflictPl conflict = _TranslationsTakerConflictPl._(_root);
}

// Path: home
class _TranslationsHomePl extends TranslationsHomeEn {
	_TranslationsHomePl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsHomeNotificationsPl notifications = _TranslationsHomeNotificationsPl._(_root);
	@override late final _TranslationsHomeStatisticsPl statistics = _TranslationsHomeStatisticsPl._(_root);
}

// Path: system
class _TranslationsSystemPl extends TranslationsSystemEn {
	_TranslationsSystemPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSystemErrorsPl errors = _TranslationsSystemErrorsPl._(_root);
	@override late final _TranslationsSystemBlikPl blik = _TranslationsSystemBlikPl._(_root);
}

// Path: common.buttons
class _TranslationsCommonButtonsPl extends TranslationsCommonButtonsEn {
	_TranslationsCommonButtonsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Anuluj';
	@override String get save => 'Zapisz';
	@override String get done => 'Gotowe';
	@override String get retry => 'Ponów';
	@override String get goHome => 'Strona główna';
	@override String get saveAndContinue => 'Zapisz i kontynuuj';
}

// Path: common.labels
class _TranslationsCommonLabelsPl extends TranslationsCommonLabelsEn {
	_TranslationsCommonLabelsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get amount => 'Kwota (PLN)';
	@override String status({required Object status}) => 'Status: ${status}';
	@override String role({required Object role}) => 'Rola: ${role}';
}

// Path: common.roles
class _TranslationsCommonRolesPl extends TranslationsCommonRolesEn {
	_TranslationsCommonRolesPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get maker => 'Wystawiający';
	@override String get taker => 'Kupujący';
}

// Path: common.notifications
class _TranslationsCommonNotificationsPl extends TranslationsCommonNotificationsEn {
	_TranslationsCommonNotificationsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get success => 'Sukces';
	@override String get error => 'Błąd';
	@override String get loading => 'Ładowanie...';
}

// Path: common.clipboard
class _TranslationsCommonClipboardPl extends TranslationsCommonClipboardEn {
	_TranslationsCommonClipboardPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get copyToClipboard => 'Kopiuj do schowka';
	@override String get pasteFromClipboard => 'Wklej ze schowka';
	@override String get copied => 'Skopiowane do schowka!';
}

// Path: lightningAddress.labels
class _TranslationsLightningAddressLabelsPl extends TranslationsLightningAddressLabelsEn {
	_TranslationsLightningAddressLabelsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get address => 'Adres Lightning';
	@override String get hint => 'użytkownik@domena.com';
	@override String short({required Object address}) => 'Adres Lightning: ${address}';
}

// Path: lightningAddress.prompts
class _TranslationsLightningAddressPromptsPl extends TranslationsLightningAddressPromptsEn {
	_TranslationsLightningAddressPromptsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get enter => 'Wprowadź swój adres Lightning, aby kontynuować';
	@override String get edit => 'Edytuj adres Lightning';
	@override String get invalid => 'Wprowadź prawidłowy adres Lightning';
	@override String get required => 'Adres Lightning jest wymagany.';
}

// Path: lightningAddress.feedback
class _TranslationsLightningAddressFeedbackPl extends TranslationsLightningAddressFeedbackEn {
	_TranslationsLightningAddressFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get saved => 'Adres Lightning zapisany!';
	@override String get updated => 'Adres Lightning zaktualizowany!';
	@override String get valid => 'Prawidłowy adres Lightning';
}

// Path: lightningAddress.errors
class _TranslationsLightningAddressErrorsPl extends TranslationsLightningAddressErrorsEn {
	_TranslationsLightningAddressErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String saving({required Object details}) => 'Błąd podczas zapisywania adresu: ${details}';
	@override String loading({required Object details}) => 'Błąd podczas ładowania adresu Lightning: ${details}';
}

// Path: offers.display
class _TranslationsOffersDisplayPl extends TranslationsOffersDisplayEn {
	_TranslationsOffersDisplayPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get yourOffer => 'Twoja oferta:';
	@override String get selectedOffer => 'Wybrana oferta:';
	@override String get activeOffer => 'Masz aktywną ofertę:';
	@override String get finishedOffers => 'Zakończone oferty';
	@override String get finishedOffersWithTime => 'Zakończone oferty (ostatnie 24h):';
	@override String get noAvailable => 'Brak dostępnych ofert.';
	@override String get noSuccessfulTrades => 'Brak udanych transakcji.';
}

// Path: offers.details
class _TranslationsOffersDetailsPl extends TranslationsOffersDetailsEn {
	_TranslationsOffersDetailsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String amount({required Object amount}) => 'Kwota: ${amount} satoshi';
	@override String amountWithCurrency({required Object amount, required Object currency}) => '${amount} ${currency}';
	@override String makerFee({required Object fee}) => 'Opłata wystawiającego: ${fee} satoshi';
	@override String takerFee({required Object fee}) => 'Opłata kupującego: ${fee} satoshi';
	@override String takerFeeWithStatus({required Object fee, required Object status}) => 'Opłata wystawiającego: ${fee} satoshi | Status: ${status}';
	@override String subtitle({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (opłata) satoshi\nStatus: ${status}';
	@override String subtitleWithDate({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (opłata) satoshi\nStatus: ${status}\nOpłacone: ${date}';
	@override String activeSubtitle({required Object status, required Object amount}) => 'Status: ${status}\nKwota: ${amount} satoshi';
	@override String id({required Object id}) => 'ID Oferty: ${id}...';
	@override String created({required Object dateTime}) => 'Utworzono: ${dateTime}';
	@override String takenAfter({required Object duration}) => 'Przyjęto po: ${duration}';
	@override String paidAfter({required Object duration}) => 'Wypłacono po: ${duration}';
}

// Path: offers.actions
class _TranslationsOffersActionsPl extends TranslationsOffersActionsEn {
	_TranslationsOffersActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get take => 'PRZYJMIJ';
	@override String get resume => 'WZNÓW';
	@override String get cancel => 'Anuluj ofertę';
}

// Path: offers.status
class _TranslationsOffersStatusPl extends TranslationsOffersStatusEn {
	_TranslationsOffersStatusPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get reserved => 'Oferta zarezerwowana przez Kupującego!';
	@override String get cancelled => 'Oferta anulowana pomyślnie.';
	@override String get cancelledOrExpired => 'Oferta została anulowana lub wygasła.';
	@override String noLongerAvailable({required Object status}) => 'Oferta nie jest już dostępna (Status: ${status}).';
}

// Path: offers.errors
class _TranslationsOffersErrorsPl extends TranslationsOffersErrorsEn {
	_TranslationsOffersErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String loading({required Object details}) => 'Błąd podczas ładowania ofert: ${details}';
	@override String loadingDetails({required Object details}) => 'Błąd podczas ładowania szczegółów oferty: ${details}';
	@override String get detailsMissing => 'Błąd: Brak szczegółów oferty lub są nieprawidłowe.';
	@override String get detailsNotLoaded => 'Nie można załadować szczegółów oferty.';
	@override String get notFound => 'Błąd: Oferta nie znaleziona.';
	@override String get unexpectedState => 'Błąd: Oferta jest w nieoczekiwanym stanie.';
	@override String get unexpectedStateWithStatus => 'Oferta jest w nieoczekiwanym stanie ({status}).';
	@override String get invalidStatus => 'Oferta ma nieprawidłowy status.';
	@override String get couldNotIdentify => 'Błąd: Nie można zidentyfikować oferty do anulowania.';
	@override String get cannotBeCancelled => 'Oferta nie może zostać anulowana w bieżącym stanie ({status}).';
	@override String failedToCancel({required Object details}) => 'Nie udało się anulować oferty: ${details}';
	@override String get activeDetailsLost => 'Błąd: Utracono szczegóły aktywnej oferty.';
	@override String checkingActive({required Object details}) => 'Błąd podczas sprawdzania aktywnych ofert: ${details}';
	@override String loadingFinished({required Object details}) => 'Błąd podczas ładowania zakończonych ofert: ${details}';
	@override String cannotResume({required Object status}) => 'Nie można wznowić oferty w stanie: ${status}';
	@override String cannotResumeTaker({required Object status}) => 'Nie można wznowić oferty Kupującego w stanie: ${status}';
	@override String resuming({required Object details}) => 'Błąd podczas wznawiania oferty: ${details}';
	@override String get makerPublicKeyNotFound => 'Nie znaleziono klucza publicznego Wystawiającego';
	@override String get takerPublicKeyNotFound => 'Nie znaleziono klucza publicznego Kupującego.';
}

// Path: reservations.actions
class _TranslationsReservationsActionsPl extends TranslationsReservationsActionsEn {
	_TranslationsReservationsActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Anuluj rezerwację';
}

// Path: reservations.feedback
class _TranslationsReservationsFeedbackPl extends TranslationsReservationsFeedbackEn {
	_TranslationsReservationsFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get cancelled => 'Rezerwacja została anulowana.';
}

// Path: reservations.errors
class _TranslationsReservationsErrorsPl extends TranslationsReservationsErrorsEn {
	_TranslationsReservationsErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String cancelling({required Object error}) => 'Nie udało się anulować rezerwacji: ${error}';
	@override String failedToReserve({required Object details}) => 'Nie udało się zarezerwować oferty: ${details}';
	@override String get failedNoTimestamp => 'Nie udało się zarezerwować oferty (brak znacznika czasu).';
	@override String get timestampMissing => 'Brak znacznika czasu rezerwacji oferty.';
	@override String get notReserved => 'Oferta nie jest już w stanie zarezerwowanym ({status}).';
}

// Path: exchange.labels
class _TranslationsExchangeLabelsPl extends TranslationsExchangeLabelsEn {
	_TranslationsExchangeLabelsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get enterAmount => 'Wprowadź kwotę (PLN) do zapłaty:';
	@override String equivalent({required Object sats}) => '≈ ${sats} satoshi';
	@override String rate({required Object rate}) => 'Kurs PLN/BTC ≈ ${rate}';
	@override String rangeHint({required Object minAmount, required Object maxAmount, required Object currency}) => 'Min/Max: ${minAmount}-${maxAmount} ${currency}';
}

// Path: exchange.feedback
class _TranslationsExchangeFeedbackPl extends TranslationsExchangeFeedbackEn {
	_TranslationsExchangeFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get fetching => 'Pobieranie kursu wymiany...';
}

// Path: exchange.errors
class _TranslationsExchangeErrorsPl extends TranslationsExchangeErrorsEn {
	_TranslationsExchangeErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get fetchingRate => 'Nie udało się pobrać kursu wymiany.';
	@override String get invalidFormat => 'Nieprawidłowy format liczby';
	@override String get mustBePositive => 'Kwota musi być dodatnia';
	@override String get invalidFeePercentage => 'Nieprawidłowy procent opłaty';
	@override String tooLowFiat({required Object minAmount, required Object currency}) => 'Kwota jest za niska. Minimum to ${minAmount} ${currency}.';
	@override String tooHighFiat({required Object maxAmount, required Object currency}) => 'Kwota jest za wysoka. Maksimum to ${maxAmount} ${currency}.';
}

// Path: maker.roleSelection
class _TranslationsMakerRoleSelectionPl extends TranslationsMakerRoleSelectionEn {
	_TranslationsMakerRoleSelectionPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get button => 'ZAPŁAĆ z Lightning';
}

// Path: maker.amountForm
class _TranslationsMakerAmountFormPl extends TranslationsMakerAmountFormEn {
	_TranslationsMakerAmountFormPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMakerAmountFormActionsPl actions = _TranslationsMakerAmountFormActionsPl._(_root);
	@override late final _TranslationsMakerAmountFormErrorsPl errors = _TranslationsMakerAmountFormErrorsPl._(_root);
}

// Path: maker.payInvoice
class _TranslationsMakerPayInvoicePl extends TranslationsMakerPayInvoiceEn {
	_TranslationsMakerPayInvoicePl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Zapłać tę fakturę Hold:';
	@override late final _TranslationsMakerPayInvoiceActionsPl actions = _TranslationsMakerPayInvoiceActionsPl._(_root);
	@override late final _TranslationsMakerPayInvoiceFeedbackPl feedback = _TranslationsMakerPayInvoiceFeedbackPl._(_root);
	@override late final _TranslationsMakerPayInvoiceErrorsPl errors = _TranslationsMakerPayInvoiceErrorsPl._(_root);
}

// Path: maker.waitTaker
class _TranslationsMakerWaitTakerPl extends TranslationsMakerWaitTakerEn {
	_TranslationsMakerWaitTakerPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get message => 'Oczekiwanie na Kupującego, który zarezerwuje Twoją ofertę...';
	@override String progressLabel({required Object time}) => 'Oczekiwanie na kupującego: ${time}';
}

// Path: maker.waitForBlik
class _TranslationsMakerWaitForBlikPl extends TranslationsMakerWaitForBlikEn {
	_TranslationsMakerWaitForBlikPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Oczekiwanie na BLIK';
	@override String get message => 'Oczekiwanie na wprowadzenie kodu BLIK przez Kupującego.';
	@override String get timeLimit => 'Kupujący ma 20 sekund na podanie kodu.';
	@override String timeLimitWithSeconds({required Object seconds}) => 'Przyjmujący ma ${seconds} sekund na podanie kodu BLIK.';
	@override String progressLabel({required Object seconds}) => 'Zarezerwowano: pozostało ${seconds} s';
}

// Path: maker.confirmPayment
class _TranslationsMakerConfirmPaymentPl extends TranslationsMakerConfirmPaymentEn {
	_TranslationsMakerConfirmPaymentPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Otrzymano kod BLIK!';
	@override String get retrieving => 'Pobieranie kodu BLIK...';
	@override String get instructions => 'Wprowadź ten kod w terminalu płatniczym. Gdy Kupujący potwierdzi w swojej aplikacji bankowej i płatność zostanie zrealizowana, naciśnij Potwierdź poniżej.';
	@override late final _TranslationsMakerConfirmPaymentActionsPl actions = _TranslationsMakerConfirmPaymentActionsPl._(_root);
	@override late final _TranslationsMakerConfirmPaymentFeedbackPl feedback = _TranslationsMakerConfirmPaymentFeedbackPl._(_root);
	@override late final _TranslationsMakerConfirmPaymentErrorsPl errors = _TranslationsMakerConfirmPaymentErrorsPl._(_root);
}

// Path: maker.invalidBlik
class _TranslationsMakerInvalidBlikPl extends TranslationsMakerInvalidBlikEn {
	_TranslationsMakerInvalidBlikPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nieprawidłowy Kod BLIK';
	@override String get info => 'Oznaczyłeś kod BLIK jako nieprawidłowy. Oczekiwanie na podanie nowego kodu przez takera lub rozpoczęcie sporu.';
}

// Path: maker.conflict
class _TranslationsMakerConflictPl extends TranslationsMakerConflictEn {
	_TranslationsMakerConflictPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Konflikt Oferty';
	@override String get headline => 'Zgłoszono Konflikt Oferty';
	@override String get body => 'Oznaczyłeś/aś kod BLIK jako nieprawidłowy, ale Kupujący zgłosił/a konflikt, wskazując, że uważa płatność za udaną.';
	@override String get instructions => 'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';
	@override late final _TranslationsMakerConflictActionsPl actions = _TranslationsMakerConflictActionsPl._(_root);
	@override late final _TranslationsMakerConflictDisputeDialogPl disputeDialog = _TranslationsMakerConflictDisputeDialogPl._(_root);
	@override late final _TranslationsMakerConflictFeedbackPl feedback = _TranslationsMakerConflictFeedbackPl._(_root);
	@override late final _TranslationsMakerConflictErrorsPl errors = _TranslationsMakerConflictErrorsPl._(_root);
}

// Path: maker.success
class _TranslationsMakerSuccessPl extends TranslationsMakerSuccessEn {
	_TranslationsMakerSuccessPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Oferta zakończona';
	@override String get headline => 'Płatność potwierdzona!';
	@override String get subtitle => 'Kupujący otrzymał zapłatę.';
	@override String get detailsTitle => 'Szczegóły oferty:';
}

// Path: taker.roleSelection
class _TranslationsTakerRoleSelectionPl extends TranslationsTakerRoleSelectionEn {
	_TranslationsTakerRoleSelectionPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get button => 'SPRZEDAJ kod BLIK za satoshi';
}

// Path: taker.submitBlik
class _TranslationsTakerSubmitBlikPl extends TranslationsTakerSubmitBlikEn {
	_TranslationsTakerSubmitBlikPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Wprowadź 6-cyfrowy kod BLIK:';
	@override String get label => 'Kod BLIK';
	@override String timeLimit({required Object seconds}) => 'Wprowadź BLIK w ciągu: ${seconds} s';
	@override String get timeExpired => 'Czas na wprowadzenie kodu BLIK upłynął.';
	@override late final _TranslationsTakerSubmitBlikActionsPl actions = _TranslationsTakerSubmitBlikActionsPl._(_root);
	@override late final _TranslationsTakerSubmitBlikFeedbackPl feedback = _TranslationsTakerSubmitBlikFeedbackPl._(_root);
	@override late final _TranslationsTakerSubmitBlikValidationPl validation = _TranslationsTakerSubmitBlikValidationPl._(_root);
	@override late final _TranslationsTakerSubmitBlikErrorsPl errors = _TranslationsTakerSubmitBlikErrorsPl._(_root);
}

// Path: taker.waitConfirmation
class _TranslationsTakerWaitConfirmationPl extends TranslationsTakerWaitConfirmationEn {
	_TranslationsTakerWaitConfirmationPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String statusLabel({required Object status}) => 'Status oferty: ${status}';
	@override String waitingMaker({required Object seconds}) => 'Oczekiwanie na potwierdzenie Wystawiającego: ${seconds} s';
	@override String importantNotice({required Object amount, required Object currency}) => 'BARDZO WAŻNE: Upewnij się, że akceptujesz tylko potwierdzenie BLIK na kwotę ${amount} ${currency}';
	@override String get instructions => 'Wystawiający ofertę otrzymał Twój kod BLIK i musi wprowadzić go w terminalu płatniczym. Następnie musisz zaakceptować kod BLIK w swojej aplikacji bankowej, upewnij się, że akceptujesz tylko właściwą kwotę. Otrzymasz płatność Lightning automatycznie po potwierdzeniu.';
	@override late final _TranslationsTakerWaitConfirmationFeedbackPl feedback = _TranslationsTakerWaitConfirmationFeedbackPl._(_root);
}

// Path: taker.paymentProcess
class _TranslationsTakerPaymentProcessPl extends TranslationsTakerPaymentProcessEn {
	_TranslationsTakerPaymentProcessPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Proces płatności';
	@override late final _TranslationsTakerPaymentProcessStatesPl states = _TranslationsTakerPaymentProcessStatesPl._(_root);
	@override late final _TranslationsTakerPaymentProcessTasksPl tasks = _TranslationsTakerPaymentProcessTasksPl._(_root);
	@override late final _TranslationsTakerPaymentProcessErrorsPl errors = _TranslationsTakerPaymentProcessErrorsPl._(_root);
	@override late final _TranslationsTakerPaymentProcessLoadingPl loading = _TranslationsTakerPaymentProcessLoadingPl._(_root);
	@override late final _TranslationsTakerPaymentProcessActionsPl actions = _TranslationsTakerPaymentProcessActionsPl._(_root);
}

// Path: taker.paymentFailed
class _TranslationsTakerPaymentFailedPl extends TranslationsTakerPaymentFailedEn {
	_TranslationsTakerPaymentFailedPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Płatność nie powiodła się';
	@override String instructions({required Object netAmount}) => 'Proszę podać nową fakturę Lightning na kwotę ${netAmount} satoshi';
	@override late final _TranslationsTakerPaymentFailedFormPl form = _TranslationsTakerPaymentFailedFormPl._(_root);
	@override late final _TranslationsTakerPaymentFailedActionsPl actions = _TranslationsTakerPaymentFailedActionsPl._(_root);
	@override late final _TranslationsTakerPaymentFailedErrorsPl errors = _TranslationsTakerPaymentFailedErrorsPl._(_root);
}

// Path: taker.paymentSuccess
class _TranslationsTakerPaymentSuccessPl extends TranslationsTakerPaymentSuccessEn {
	_TranslationsTakerPaymentSuccessPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Płatność udana';
	@override String get message => 'Twoja płatność została przetworzona pomyślnie.';
	@override late final _TranslationsTakerPaymentSuccessActionsPl actions = _TranslationsTakerPaymentSuccessActionsPl._(_root);
}

// Path: taker.invalidBlik
class _TranslationsTakerInvalidBlikPl extends TranslationsTakerInvalidBlikEn {
	_TranslationsTakerInvalidBlikPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nieprawidłowy Kod BLIK';
	@override String get message => 'Twórca Odrzucił Kod BLIK';
	@override String get explanation => 'Twórca oferty wskazał, że podany przez Ciebie kod BLIK był nieprawidłowy lub nie zadziałał. Co chcesz zrobić?';
	@override late final _TranslationsTakerInvalidBlikErrorsPl errors = _TranslationsTakerInvalidBlikErrorsPl._(_root);
	@override late final _TranslationsTakerInvalidBlikActionsPl actions = _TranslationsTakerInvalidBlikActionsPl._(_root);
}

// Path: taker.conflict
class _TranslationsTakerConflictPl extends TranslationsTakerConflictEn {
	_TranslationsTakerConflictPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Konflikt Oferty';
	@override String get headline => 'Zgłoszono Konflikt Oferty';
	@override String get body => 'Wystawiający oznaczył kod BLIK jako nieprawidłowy, ale zgłosiłeś/aś konflikt, wskazując, że uważasz płatność za udaną.';
	@override String get instructions => 'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';
	@override late final _TranslationsTakerConflictActionsPl actions = _TranslationsTakerConflictActionsPl._(_root);
	@override late final _TranslationsTakerConflictFeedbackPl feedback = _TranslationsTakerConflictFeedbackPl._(_root);
	@override late final _TranslationsTakerConflictErrorsPl errors = _TranslationsTakerConflictErrorsPl._(_root);
}

// Path: home.notifications
class _TranslationsHomeNotificationsPl extends TranslationsHomeNotificationsEn {
	_TranslationsHomeNotificationsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get simplex => 'Otrzymuj powiadomienia o nowych zamówieniach przez SimpleX';
	@override String get element => 'Otrzymuj powiadomienia o nowych zamówieniach przez Element';
}

// Path: home.statistics
class _TranslationsHomeStatisticsPl extends TranslationsHomeStatisticsEn {
	_TranslationsHomeStatisticsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ostatnie transakcje';
	@override String lifetimeCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Wszystkie: ${count} transakcji\nŚr. czas oczekiwania na BLIK: ${avgBlikTime}\nŚr. czas zakończenia: ${avgPaidTime}';
	@override String last7DaysCompact({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Ost. 7d: ${count} transakcji\nŚr. czas oczekiwania na BLIK: ${avgBlikTime}\nŚr. czas zakończenia: ${avgPaidTime}';
	@override late final _TranslationsHomeStatisticsErrorsPl errors = _TranslationsHomeStatisticsErrorsPl._(_root);
}

// Path: system.errors
class _TranslationsSystemErrorsPl extends TranslationsSystemErrorsEn {
	_TranslationsSystemErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get generic => 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';
	@override String get loadingTimeoutConfig => 'Błąd ładowania konfiguracji limitu czasu.';
	@override String get loadingCoordinatorConfig => 'Błąd ładowania konfiguracji koordynatora. Spróbuj ponownie.';
}

// Path: system.blik
class _TranslationsSystemBlikPl extends TranslationsSystemBlikEn {
	_TranslationsSystemBlikPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get copied => 'Kod BLIK skopiowany do schowka';
}

// Path: maker.amountForm.actions
class _TranslationsMakerAmountFormActionsPl extends TranslationsMakerAmountFormActionsEn {
	_TranslationsMakerAmountFormActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get generateInvoice => 'Wygeneruj fakturę';
}

// Path: maker.amountForm.errors
class _TranslationsMakerAmountFormErrorsPl extends TranslationsMakerAmountFormErrorsEn {
	_TranslationsMakerAmountFormErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String initiating({required Object details}) => 'Błąd podczas inicjowania oferty: ${details}';
	@override String get publicKeyNotLoaded => 'Błąd: Klucz publiczny nie został jeszcze załadowany.';
}

// Path: maker.payInvoice.actions
class _TranslationsMakerPayInvoiceActionsPl extends TranslationsMakerPayInvoiceActionsEn {
	_TranslationsMakerPayInvoiceActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get copy => 'Kopiuj fakturę';
}

// Path: maker.payInvoice.feedback
class _TranslationsMakerPayInvoiceFeedbackPl extends TranslationsMakerPayInvoiceFeedbackEn {
	_TranslationsMakerPayInvoiceFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get copied => 'Faktura skopiowana do schowka!';
	@override String get waitingConfirmation => 'Oczekiwanie na potwierdzenie płatności...';
}

// Path: maker.payInvoice.errors
class _TranslationsMakerPayInvoiceErrorsPl extends TranslationsMakerPayInvoiceErrorsEn {
	_TranslationsMakerPayInvoiceErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get couldNotOpenApp => 'Nie można otworzyć aplikacji Lightning dla faktury.';
	@override String openingApp({required Object details}) => 'Błąd podczas otwierania aplikacji Lightning: ${details}';
	@override String get publicKeyNotAvailable => 'Klucz publiczny nie jest dostępny.';
	@override String get couldNotFetchActive => 'Nie można pobrać szczegółów aktywnej oferty. Mogła wygasnąć.';
}

// Path: maker.confirmPayment.actions
class _TranslationsMakerConfirmPaymentActionsPl extends TranslationsMakerConfirmPaymentActionsEn {
	_TranslationsMakerConfirmPaymentActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Potwierdź udaną płatność';
	@override String get markInvalid => 'Nieprawidłowy Kod BLIK';
}

// Path: maker.confirmPayment.feedback
class _TranslationsMakerConfirmPaymentFeedbackPl extends TranslationsMakerConfirmPaymentFeedbackEn {
	_TranslationsMakerConfirmPaymentFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get confirmed => 'Wystawiający potwierdził płatność.';
	@override String get confirmedTakerPaid => 'Płatność potwierdzona! Kupujący otrzyma środki.';
	@override String progressLabel({required Object seconds}) => 'Potwierdzanie: pozostało ${seconds} s';
}

// Path: maker.confirmPayment.errors
class _TranslationsMakerConfirmPaymentErrorsPl extends TranslationsMakerConfirmPaymentErrorsEn {
	_TranslationsMakerConfirmPaymentErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get failedToRetrieve => 'Błąd: Nie udało się pobrać kodu BLIK.';
	@override String retrieving({required Object details}) => 'Błąd podczas pobierania kodu BLIK: ${details}';
	@override String get missingHashOrKey => 'Błąd: Brak hasha płatności lub klucza publicznego.';
	@override String incorrectState({required Object status}) => 'Oferta nie jest w prawidłowym stanie do potwierdzenia (Status: ${status})';
	@override String confirming({required Object details}) => 'Błąd podczas potwierdzania płatności: ${details}';
	@override String get invalidState => 'Błąd: Otrzymano nieprawidłowy stan oferty.';
	@override String get internalIncomplete => 'Błąd wewnętrzny: Niekompletne szczegóły oferty.';
	@override String notAwaitingConfirmation({required Object status}) => 'Oferta nie oczekuje już na potwierdzenie (Status: ${status}).';
	@override String get unexpectedStatus => 'Otrzymano nieoczekiwany status oferty z serwera.';
}

// Path: maker.conflict.actions
class _TranslationsMakerConflictActionsPl extends TranslationsMakerConflictActionsEn {
	_TranslationsMakerConflictActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get back => 'Wróć do Strony Głównej';
	@override String get confirmPayment => 'Mój błąd, potwierdź sukces płatności BLIK';
	@override String get openDispute => 'Płatność Blik NIE powiodła się, OTWÓRZ SPÓR';
	@override String get submitDispute => 'Zgłoś Spór';
}

// Path: maker.conflict.disputeDialog
class _TranslationsMakerConflictDisputeDialogPl extends TranslationsMakerConflictDisputeDialogEn {
	_TranslationsMakerConflictDisputeDialogPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Otworzyć spór?';
	@override String get content => 'Otwarcie sporu wymaga ręcznej weryfikacji przez koordynatora, co może zająć czas. Opłata za spór zostanie potrącona, jeśli spór zostanie rozstrzygnięty na Twoją niekorzyść. Faktura blokująca (hold invoice) zostanie rozliczona, aby zapobiec jej wygaśnięciu. Jeśli spór zostanie rozstrzygnięty na Twoją korzyść, otrzymasz zwrot środków (pomniejszony o opłaty) na Twój adres Lightning.';
	@override String get contentDetailed => 'Otwarcie sporu będzie wymagało ręcznej interwencji koordynatora, co zajmie czas i wiąże się z opłatą za spór.\n\nFaktura blokująca (hold invoice) zostanie natychmiast rozliczona, aby zapobiec jej wygaśnięciu przed rozstrzygnięciem sporu.\n\nJeśli spór zostanie rozstrzygnięty na Twoją korzyść, kwota w satoshi zostanie zwrócona na Twój adres Lightning (pomniejszona o opłaty za spór). Upewnij się, że masz skonfigurowany adres Lightning.';
	@override String get confirm => 'Otwórz Spór';
	@override String get cancel => 'Anuluj';
}

// Path: maker.conflict.feedback
class _TranslationsMakerConflictFeedbackPl extends TranslationsMakerConflictFeedbackEn {
	_TranslationsMakerConflictFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get disputeSuccess => 'Spór został pomyślnie otwarty. Koordynator rozpatrzy sprawę.';
}

// Path: maker.conflict.errors
class _TranslationsMakerConflictErrorsPl extends TranslationsMakerConflictErrorsEn {
	_TranslationsMakerConflictErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String openingDispute({required Object error}) => 'Błąd podczas otwierania sporu: ${error}';
}

// Path: taker.submitBlik.actions
class _TranslationsTakerSubmitBlikActionsPl extends TranslationsTakerSubmitBlikActionsEn {
	_TranslationsTakerSubmitBlikActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get submit => 'Wyślij BLIK';
}

// Path: taker.submitBlik.feedback
class _TranslationsTakerSubmitBlikFeedbackPl extends TranslationsTakerSubmitBlikFeedbackEn {
	_TranslationsTakerSubmitBlikFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get pasted => 'Wklejony kod BLIK.';
}

// Path: taker.submitBlik.validation
class _TranslationsTakerSubmitBlikValidationPl extends TranslationsTakerSubmitBlikValidationEn {
	_TranslationsTakerSubmitBlikValidationPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get invalidFormat => 'Wprowadź prawidłowy 6-cyfrowy kod BLIK.';
}

// Path: taker.submitBlik.errors
class _TranslationsTakerSubmitBlikErrorsPl extends TranslationsTakerSubmitBlikErrorsEn {
	_TranslationsTakerSubmitBlikErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String submitting({required Object details}) => 'Błąd podczas przesyłania kodu BLIK: ${details}';
	@override String get clipboardInvalid => 'Schowek nie zawiera prawidłowego 6-cyfrowego kodu BLIK.';
	@override String get stateChanged => 'Błąd: Stan oferty uległ zmianie.';
	@override String get stateNotValid => 'Błąd: Stan oferty nie jest już prawidłowy.';
	@override String get fetchedIdMismatch => 'Pobrane ID aktywnej oferty ({fetchedId}) nie odpowiada początkowemu ID oferty ({initialId}). Niezgodność stanu?';
	@override String get paymentHashMissing => 'Brak hasha płatności oferty po pobraniu.';
}

// Path: taker.waitConfirmation.feedback
class _TranslationsTakerWaitConfirmationFeedbackPl extends TranslationsTakerWaitConfirmationFeedbackEn {
	_TranslationsTakerWaitConfirmationFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get makerConfirmed => 'Wystawiający potwierdził płatność.';
	@override String get paymentSuccessful => 'Płatność udana! Wkrótce otrzymasz środki.';
}

// Path: taker.paymentProcess.states
class _TranslationsTakerPaymentProcessStatesPl extends TranslationsTakerPaymentProcessStatesEn {
	_TranslationsTakerPaymentProcessStatesPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get preparing => 'Przygotowywanie do wysłania płatności...';
	@override String get sending => 'Wysyłanie płatności...';
	@override String get received => 'Otrzymano płatność!';
	@override String get failed => 'Płatność nie powiodła się';
	@override String get waitingUpdate => 'Oczekiwanie na aktualizację oferty...';
}

// Path: taker.paymentProcess.tasks
class _TranslationsTakerPaymentProcessTasksPl extends TranslationsTakerPaymentProcessTasksEn {
	_TranslationsTakerPaymentProcessTasksPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get makerConfirmedBlik => 'Wystawiający potwierdził płatność BLIK';
	@override String get makerInvoiceSettled => 'Faktura Hold wystawiającego rozliczona';
	@override String get payingInvoice => 'Generowanie i opłacanie Twojej faktury';
	@override String get invoicePaid => 'Twoja faktura opłacona pomyślnie';
	@override String get paymentFailed => 'Płatność do Ciebie nie powiodła się';
}

// Path: taker.paymentProcess.errors
class _TranslationsTakerPaymentProcessErrorsPl extends TranslationsTakerPaymentProcessErrorsEn {
	_TranslationsTakerPaymentProcessErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String sending({required Object details}) => 'Błąd podczas wysyłania płatności: ${details}';
	@override String get notConfirmed => 'Oferta niepotwierdzona przez Wystawiającego.';
	@override String get expired => 'Oferta wygasła.';
	@override String get cancelled => 'Oferta anulowana.';
	@override String get paymentFailed => 'Płatność oferty nie powiodła się.';
	@override String get unknown => 'Nieznany błąd oferty.';
	@override String get takerPaymentFailed => 'Płatność na Twój adres Lightning nie powiodła się. Sprawdź szczegóły i w razie potrzeby podaj nową fakturę.';
	@override String get noPublicKey => 'Błąd: Nie można pobrać Twojego klucza publicznego.';
	@override String get loadingPublicKey => 'Błąd podczas ładowania Twoich danych';
	@override String get missingPaymentHash => 'Błąd: Brak szczegółów płatności.';
}

// Path: taker.paymentProcess.loading
class _TranslationsTakerPaymentProcessLoadingPl extends TranslationsTakerPaymentProcessLoadingEn {
	_TranslationsTakerPaymentProcessLoadingPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get publicKey => 'Ładowanie Twoich danych...';
}

// Path: taker.paymentProcess.actions
class _TranslationsTakerPaymentProcessActionsPl extends TranslationsTakerPaymentProcessActionsEn {
	_TranslationsTakerPaymentProcessActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get goToFailureDetails => 'Przejdź do szczegółów błędu';
}

// Path: taker.paymentFailed.form
class _TranslationsTakerPaymentFailedFormPl extends TranslationsTakerPaymentFailedFormEn {
	_TranslationsTakerPaymentFailedFormPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get label => 'Nowa faktura Lightning';
	@override String get hint => 'Wprowadź swoją fakturę BOLT11';
}

// Path: taker.paymentFailed.actions
class _TranslationsTakerPaymentFailedActionsPl extends TranslationsTakerPaymentFailedActionsEn {
	_TranslationsTakerPaymentFailedActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get submit => 'Wyślij nową fakturę';
}

// Path: taker.paymentFailed.errors
class _TranslationsTakerPaymentFailedErrorsPl extends TranslationsTakerPaymentFailedErrorsEn {
	_TranslationsTakerPaymentFailedErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get enterValid => 'Proszę wprowadzić prawidłową fakturę';
	@override String updating({required Object details}) => 'Błąd podczas aktualizacji faktury: ${details}';
	@override String get retryFailed => 'Ponowna próba płatności nie powiodła się. Sprawdź fakturę lub spróbuj ponownie później.';
}

// Path: taker.paymentSuccess.actions
class _TranslationsTakerPaymentSuccessActionsPl extends TranslationsTakerPaymentSuccessActionsEn {
	_TranslationsTakerPaymentSuccessActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get goHome => 'Przejdź do strony głównej';
}

// Path: taker.invalidBlik.errors
class _TranslationsTakerInvalidBlikErrorsPl extends TranslationsTakerInvalidBlikErrorsEn {
	_TranslationsTakerInvalidBlikErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get reservationFailed => 'TODO';
}

// Path: taker.invalidBlik.actions
class _TranslationsTakerInvalidBlikActionsPl extends TranslationsTakerInvalidBlikActionsEn {
	_TranslationsTakerInvalidBlikActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get retry => 'NIE ZAPŁACIŁEM, zarezerwuj ofertę ponownie i wyślij nowy kod BLIK';
	@override String get reportConflict => 'POTWIERDZIŁEM KOD BLIK I ZOSTAŁO TO OBCIĄŻONE Z MOJEGO KONTA BANKOWEGO, Zgłoś konflikt, spowoduje SPÓR!';
	@override String get returnHome => 'Wróć do strony głównej';
}

// Path: taker.conflict.actions
class _TranslationsTakerConflictActionsPl extends TranslationsTakerConflictActionsEn {
	_TranslationsTakerConflictActionsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get back => 'Wróć do Strony Głównej';
}

// Path: taker.conflict.feedback
class _TranslationsTakerConflictFeedbackPl extends TranslationsTakerConflictFeedbackEn {
	_TranslationsTakerConflictFeedbackPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get reported => 'Konflikt zgłoszony. Koordynator rozpatrzy sprawę.';
}

// Path: taker.conflict.errors
class _TranslationsTakerConflictErrorsPl extends TranslationsTakerConflictErrorsEn {
	_TranslationsTakerConflictErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String reporting({required Object details}) => 'Błąd zgłaszania konfliktu: ${details}';
}

// Path: home.statistics.errors
class _TranslationsHomeStatisticsErrorsPl extends TranslationsHomeStatisticsErrorsEn {
	_TranslationsHomeStatisticsErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String loading({required Object error}) => 'Błąd ładowania statystyk: ${error}';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsPl {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'BitBlik';
			case 'app.greeting': return 'Cześć!';
			case 'common.buttons.cancel': return 'Anuluj';
			case 'common.buttons.save': return 'Zapisz';
			case 'common.buttons.done': return 'Gotowe';
			case 'common.buttons.retry': return 'Ponów';
			case 'common.buttons.goHome': return 'Strona główna';
			case 'common.buttons.saveAndContinue': return 'Zapisz i kontynuuj';
			case 'common.labels.amount': return 'Kwota (PLN)';
			case 'common.labels.status': return ({required Object status}) => 'Status: ${status}';
			case 'common.labels.role': return ({required Object role}) => 'Rola: ${role}';
			case 'common.roles.maker': return 'Wystawiający';
			case 'common.roles.taker': return 'Kupujący';
			case 'common.notifications.success': return 'Sukces';
			case 'common.notifications.error': return 'Błąd';
			case 'common.notifications.loading': return 'Ładowanie...';
			case 'common.clipboard.copyToClipboard': return 'Kopiuj do schowka';
			case 'common.clipboard.pasteFromClipboard': return 'Wklej ze schowka';
			case 'common.clipboard.copied': return 'Skopiowane do schowka!';
			case 'lightningAddress.labels.address': return 'Adres Lightning';
			case 'lightningAddress.labels.hint': return 'użytkownik@domena.com';
			case 'lightningAddress.labels.short': return ({required Object address}) => 'Adres Lightning: ${address}';
			case 'lightningAddress.prompts.enter': return 'Wprowadź swój adres Lightning, aby kontynuować';
			case 'lightningAddress.prompts.edit': return 'Edytuj adres Lightning';
			case 'lightningAddress.prompts.invalid': return 'Wprowadź prawidłowy adres Lightning';
			case 'lightningAddress.prompts.required': return 'Adres Lightning jest wymagany.';
			case 'lightningAddress.feedback.saved': return 'Adres Lightning zapisany!';
			case 'lightningAddress.feedback.updated': return 'Adres Lightning zaktualizowany!';
			case 'lightningAddress.feedback.valid': return 'Prawidłowy adres Lightning';
			case 'lightningAddress.errors.saving': return ({required Object details}) => 'Błąd podczas zapisywania adresu: ${details}';
			case 'lightningAddress.errors.loading': return ({required Object details}) => 'Błąd podczas ładowania adresu Lightning: ${details}';
			case 'offers.display.yourOffer': return 'Twoja oferta:';
			case 'offers.display.selectedOffer': return 'Wybrana oferta:';
			case 'offers.display.activeOffer': return 'Masz aktywną ofertę:';
			case 'offers.display.finishedOffers': return 'Zakończone oferty';
			case 'offers.display.finishedOffersWithTime': return 'Zakończone oferty (ostatnie 24h):';
			case 'offers.display.noAvailable': return 'Brak dostępnych ofert.';
			case 'offers.display.noSuccessfulTrades': return 'Brak udanych transakcji.';
			case 'offers.details.amount': return ({required Object amount}) => 'Kwota: ${amount} satoshi';
			case 'offers.details.amountWithCurrency': return ({required Object amount, required Object currency}) => '${amount} ${currency}';
			case 'offers.details.makerFee': return ({required Object fee}) => 'Opłata wystawiającego: ${fee} satoshi';
			case 'offers.details.takerFee': return ({required Object fee}) => 'Opłata kupującego: ${fee} satoshi';
			case 'offers.details.takerFeeWithStatus': return ({required Object fee, required Object status}) => 'Opłata wystawiającego: ${fee} satoshi | Status: ${status}';
			case 'offers.details.subtitle': return ({required Object sats, required Object fee, required Object status}) => '${sats} + ${fee} (opłata) satoshi\nStatus: ${status}';
			case 'offers.details.subtitleWithDate': return ({required Object sats, required Object fee, required Object status, required Object date}) => '${sats} + ${fee} (opłata) satoshi\nStatus: ${status}\nOpłacone: ${date}';
			case 'offers.details.activeSubtitle': return ({required Object status, required Object amount}) => 'Status: ${status}\nKwota: ${amount} satoshi';
			case 'offers.details.id': return ({required Object id}) => 'ID Oferty: ${id}...';
			case 'offers.details.created': return ({required Object dateTime}) => 'Utworzono: ${dateTime}';
			case 'offers.details.takenAfter': return ({required Object duration}) => 'Przyjęto po: ${duration}';
			case 'offers.details.paidAfter': return ({required Object duration}) => 'Wypłacono po: ${duration}';
			case 'offers.actions.take': return 'PRZYJMIJ';
			case 'offers.actions.resume': return 'WZNÓW';
			case 'offers.actions.cancel': return 'Anuluj ofertę';
			case 'offers.status.reserved': return 'Oferta zarezerwowana przez Kupującego!';
			case 'offers.status.cancelled': return 'Oferta anulowana pomyślnie.';
			case 'offers.status.cancelledOrExpired': return 'Oferta została anulowana lub wygasła.';
			case 'offers.status.noLongerAvailable': return ({required Object status}) => 'Oferta nie jest już dostępna (Status: ${status}).';
			case 'offers.errors.loading': return ({required Object details}) => 'Błąd podczas ładowania ofert: ${details}';
			case 'offers.errors.loadingDetails': return ({required Object details}) => 'Błąd podczas ładowania szczegółów oferty: ${details}';
			case 'offers.errors.detailsMissing': return 'Błąd: Brak szczegółów oferty lub są nieprawidłowe.';
			case 'offers.errors.detailsNotLoaded': return 'Nie można załadować szczegółów oferty.';
			case 'offers.errors.notFound': return 'Błąd: Oferta nie znaleziona.';
			case 'offers.errors.unexpectedState': return 'Błąd: Oferta jest w nieoczekiwanym stanie.';
			case 'offers.errors.unexpectedStateWithStatus': return 'Oferta jest w nieoczekiwanym stanie ({status}).';
			case 'offers.errors.invalidStatus': return 'Oferta ma nieprawidłowy status.';
			case 'offers.errors.couldNotIdentify': return 'Błąd: Nie można zidentyfikować oferty do anulowania.';
			case 'offers.errors.cannotBeCancelled': return 'Oferta nie może zostać anulowana w bieżącym stanie ({status}).';
			case 'offers.errors.failedToCancel': return ({required Object details}) => 'Nie udało się anulować oferty: ${details}';
			case 'offers.errors.activeDetailsLost': return 'Błąd: Utracono szczegóły aktywnej oferty.';
			case 'offers.errors.checkingActive': return ({required Object details}) => 'Błąd podczas sprawdzania aktywnych ofert: ${details}';
			case 'offers.errors.loadingFinished': return ({required Object details}) => 'Błąd podczas ładowania zakończonych ofert: ${details}';
			case 'offers.errors.cannotResume': return ({required Object status}) => 'Nie można wznowić oferty w stanie: ${status}';
			case 'offers.errors.cannotResumeTaker': return ({required Object status}) => 'Nie można wznowić oferty Kupującego w stanie: ${status}';
			case 'offers.errors.resuming': return ({required Object details}) => 'Błąd podczas wznawiania oferty: ${details}';
			case 'offers.errors.makerPublicKeyNotFound': return 'Nie znaleziono klucza publicznego Wystawiającego';
			case 'offers.errors.takerPublicKeyNotFound': return 'Nie znaleziono klucza publicznego Kupującego.';
			case 'reservations.actions.cancel': return 'Anuluj rezerwację';
			case 'reservations.feedback.cancelled': return 'Rezerwacja została anulowana.';
			case 'reservations.errors.cancelling': return ({required Object error}) => 'Nie udało się anulować rezerwacji: ${error}';
			case 'reservations.errors.failedToReserve': return ({required Object details}) => 'Nie udało się zarezerwować oferty: ${details}';
			case 'reservations.errors.failedNoTimestamp': return 'Nie udało się zarezerwować oferty (brak znacznika czasu).';
			case 'reservations.errors.timestampMissing': return 'Brak znacznika czasu rezerwacji oferty.';
			case 'reservations.errors.notReserved': return 'Oferta nie jest już w stanie zarezerwowanym ({status}).';
			case 'exchange.labels.enterAmount': return 'Wprowadź kwotę (PLN) do zapłaty:';
			case 'exchange.labels.equivalent': return ({required Object sats}) => '≈ ${sats} satoshi';
			case 'exchange.labels.rate': return ({required Object rate}) => 'Kurs PLN/BTC ≈ ${rate}';
			case 'exchange.labels.rangeHint': return ({required Object minAmount, required Object maxAmount, required Object currency}) => 'Min/Max: ${minAmount}-${maxAmount} ${currency}';
			case 'exchange.feedback.fetching': return 'Pobieranie kursu wymiany...';
			case 'exchange.errors.fetchingRate': return 'Nie udało się pobrać kursu wymiany.';
			case 'exchange.errors.invalidFormat': return 'Nieprawidłowy format liczby';
			case 'exchange.errors.mustBePositive': return 'Kwota musi być dodatnia';
			case 'exchange.errors.invalidFeePercentage': return 'Nieprawidłowy procent opłaty';
			case 'exchange.errors.tooLowFiat': return ({required Object minAmount, required Object currency}) => 'Kwota jest za niska. Minimum to ${minAmount} ${currency}.';
			case 'exchange.errors.tooHighFiat': return ({required Object maxAmount, required Object currency}) => 'Kwota jest za wysoka. Maksimum to ${maxAmount} ${currency}.';
			case 'maker.roleSelection.button': return 'ZAPŁAĆ z Lightning';
			case 'maker.amountForm.actions.generateInvoice': return 'Wygeneruj fakturę';
			case 'maker.amountForm.errors.initiating': return ({required Object details}) => 'Błąd podczas inicjowania oferty: ${details}';
			case 'maker.amountForm.errors.publicKeyNotLoaded': return 'Błąd: Klucz publiczny nie został jeszcze załadowany.';
			case 'maker.payInvoice.title': return 'Zapłać tę fakturę Hold:';
			case 'maker.payInvoice.actions.copy': return 'Kopiuj fakturę';
			case 'maker.payInvoice.feedback.copied': return 'Faktura skopiowana do schowka!';
			case 'maker.payInvoice.feedback.waitingConfirmation': return 'Oczekiwanie na potwierdzenie płatności...';
			case 'maker.payInvoice.errors.couldNotOpenApp': return 'Nie można otworzyć aplikacji Lightning dla faktury.';
			case 'maker.payInvoice.errors.openingApp': return ({required Object details}) => 'Błąd podczas otwierania aplikacji Lightning: ${details}';
			case 'maker.payInvoice.errors.publicKeyNotAvailable': return 'Klucz publiczny nie jest dostępny.';
			case 'maker.payInvoice.errors.couldNotFetchActive': return 'Nie można pobrać szczegółów aktywnej oferty. Mogła wygasnąć.';
			case 'maker.waitTaker.message': return 'Oczekiwanie na Kupującego, który zarezerwuje Twoją ofertę...';
			case 'maker.waitTaker.progressLabel': return ({required Object time}) => 'Oczekiwanie na kupującego: ${time}';
			case 'maker.waitForBlik.title': return 'Oczekiwanie na BLIK';
			case 'maker.waitForBlik.message': return 'Oczekiwanie na wprowadzenie kodu BLIK przez Kupującego.';
			case 'maker.waitForBlik.timeLimit': return 'Kupujący ma 20 sekund na podanie kodu.';
			case 'maker.waitForBlik.timeLimitWithSeconds': return ({required Object seconds}) => 'Przyjmujący ma ${seconds} sekund na podanie kodu BLIK.';
			case 'maker.waitForBlik.progressLabel': return ({required Object seconds}) => 'Zarezerwowano: pozostało ${seconds} s';
			case 'maker.confirmPayment.title': return 'Otrzymano kod BLIK!';
			case 'maker.confirmPayment.retrieving': return 'Pobieranie kodu BLIK...';
			case 'maker.confirmPayment.instructions': return 'Wprowadź ten kod w terminalu płatniczym. Gdy Kupujący potwierdzi w swojej aplikacji bankowej i płatność zostanie zrealizowana, naciśnij Potwierdź poniżej.';
			case 'maker.confirmPayment.actions.confirm': return 'Potwierdź udaną płatność';
			case 'maker.confirmPayment.actions.markInvalid': return 'Nieprawidłowy Kod BLIK';
			case 'maker.confirmPayment.feedback.confirmed': return 'Wystawiający potwierdził płatność.';
			case 'maker.confirmPayment.feedback.confirmedTakerPaid': return 'Płatność potwierdzona! Kupujący otrzyma środki.';
			case 'maker.confirmPayment.feedback.progressLabel': return ({required Object seconds}) => 'Potwierdzanie: pozostało ${seconds} s';
			case 'maker.confirmPayment.errors.failedToRetrieve': return 'Błąd: Nie udało się pobrać kodu BLIK.';
			case 'maker.confirmPayment.errors.retrieving': return ({required Object details}) => 'Błąd podczas pobierania kodu BLIK: ${details}';
			case 'maker.confirmPayment.errors.missingHashOrKey': return 'Błąd: Brak hasha płatności lub klucza publicznego.';
			case 'maker.confirmPayment.errors.incorrectState': return ({required Object status}) => 'Oferta nie jest w prawidłowym stanie do potwierdzenia (Status: ${status})';
			case 'maker.confirmPayment.errors.confirming': return ({required Object details}) => 'Błąd podczas potwierdzania płatności: ${details}';
			case 'maker.confirmPayment.errors.invalidState': return 'Błąd: Otrzymano nieprawidłowy stan oferty.';
			case 'maker.confirmPayment.errors.internalIncomplete': return 'Błąd wewnętrzny: Niekompletne szczegóły oferty.';
			case 'maker.confirmPayment.errors.notAwaitingConfirmation': return ({required Object status}) => 'Oferta nie oczekuje już na potwierdzenie (Status: ${status}).';
			case 'maker.confirmPayment.errors.unexpectedStatus': return 'Otrzymano nieoczekiwany status oferty z serwera.';
			case 'maker.invalidBlik.title': return 'Nieprawidłowy Kod BLIK';
			case 'maker.invalidBlik.info': return 'Oznaczyłeś kod BLIK jako nieprawidłowy. Oczekiwanie na podanie nowego kodu przez takera lub rozpoczęcie sporu.';
			case 'maker.conflict.title': return 'Konflikt Oferty';
			case 'maker.conflict.headline': return 'Zgłoszono Konflikt Oferty';
			case 'maker.conflict.body': return 'Oznaczyłeś/aś kod BLIK jako nieprawidłowy, ale Kupujący zgłosił/a konflikt, wskazując, że uważa płatność za udaną.';
			case 'maker.conflict.instructions': return 'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';
			case 'maker.conflict.actions.back': return 'Wróć do Strony Głównej';
			case 'maker.conflict.actions.confirmPayment': return 'Mój błąd, potwierdź sukces płatności BLIK';
			case 'maker.conflict.actions.openDispute': return 'Płatność Blik NIE powiodła się, OTWÓRZ SPÓR';
			case 'maker.conflict.actions.submitDispute': return 'Zgłoś Spór';
			case 'maker.conflict.disputeDialog.title': return 'Otworzyć spór?';
			case 'maker.conflict.disputeDialog.content': return 'Otwarcie sporu wymaga ręcznej weryfikacji przez koordynatora, co może zająć czas. Opłata za spór zostanie potrącona, jeśli spór zostanie rozstrzygnięty na Twoją niekorzyść. Faktura blokująca (hold invoice) zostanie rozliczona, aby zapobiec jej wygaśnięciu. Jeśli spór zostanie rozstrzygnięty na Twoją korzyść, otrzymasz zwrot środków (pomniejszony o opłaty) na Twój adres Lightning.';
			case 'maker.conflict.disputeDialog.contentDetailed': return 'Otwarcie sporu będzie wymagało ręcznej interwencji koordynatora, co zajmie czas i wiąże się z opłatą za spór.\n\nFaktura blokująca (hold invoice) zostanie natychmiast rozliczona, aby zapobiec jej wygaśnięciu przed rozstrzygnięciem sporu.\n\nJeśli spór zostanie rozstrzygnięty na Twoją korzyść, kwota w satoshi zostanie zwrócona na Twój adres Lightning (pomniejszona o opłaty za spór). Upewnij się, że masz skonfigurowany adres Lightning.';
			case 'maker.conflict.disputeDialog.confirm': return 'Otwórz Spór';
			case 'maker.conflict.disputeDialog.cancel': return 'Anuluj';
			case 'maker.conflict.feedback.disputeSuccess': return 'Spór został pomyślnie otwarty. Koordynator rozpatrzy sprawę.';
			case 'maker.conflict.errors.openingDispute': return ({required Object error}) => 'Błąd podczas otwierania sporu: ${error}';
			case 'maker.success.title': return 'Oferta zakończona';
			case 'maker.success.headline': return 'Płatność potwierdzona!';
			case 'maker.success.subtitle': return 'Kupujący otrzymał zapłatę.';
			case 'maker.success.detailsTitle': return 'Szczegóły oferty:';
			case 'taker.roleSelection.button': return 'SPRZEDAJ kod BLIK za satoshi';
			case 'taker.submitBlik.title': return 'Wprowadź 6-cyfrowy kod BLIK:';
			case 'taker.submitBlik.label': return 'Kod BLIK';
			case 'taker.submitBlik.timeLimit': return ({required Object seconds}) => 'Wprowadź BLIK w ciągu: ${seconds} s';
			case 'taker.submitBlik.timeExpired': return 'Czas na wprowadzenie kodu BLIK upłynął.';
			case 'taker.submitBlik.actions.submit': return 'Wyślij BLIK';
			case 'taker.submitBlik.feedback.pasted': return 'Wklejony kod BLIK.';
			case 'taker.submitBlik.validation.invalidFormat': return 'Wprowadź prawidłowy 6-cyfrowy kod BLIK.';
			case 'taker.submitBlik.errors.submitting': return ({required Object details}) => 'Błąd podczas przesyłania kodu BLIK: ${details}';
			case 'taker.submitBlik.errors.clipboardInvalid': return 'Schowek nie zawiera prawidłowego 6-cyfrowego kodu BLIK.';
			case 'taker.submitBlik.errors.stateChanged': return 'Błąd: Stan oferty uległ zmianie.';
			case 'taker.submitBlik.errors.stateNotValid': return 'Błąd: Stan oferty nie jest już prawidłowy.';
			case 'taker.submitBlik.errors.fetchedIdMismatch': return 'Pobrane ID aktywnej oferty ({fetchedId}) nie odpowiada początkowemu ID oferty ({initialId}). Niezgodność stanu?';
			case 'taker.submitBlik.errors.paymentHashMissing': return 'Brak hasha płatności oferty po pobraniu.';
			case 'taker.waitConfirmation.statusLabel': return ({required Object status}) => 'Status oferty: ${status}';
			case 'taker.waitConfirmation.waitingMaker': return ({required Object seconds}) => 'Oczekiwanie na potwierdzenie Wystawiającego: ${seconds} s';
			case 'taker.waitConfirmation.importantNotice': return ({required Object amount, required Object currency}) => 'BARDZO WAŻNE: Upewnij się, że akceptujesz tylko potwierdzenie BLIK na kwotę ${amount} ${currency}';
			case 'taker.waitConfirmation.instructions': return 'Wystawiający ofertę otrzymał Twój kod BLIK i musi wprowadzić go w terminalu płatniczym. Następnie musisz zaakceptować kod BLIK w swojej aplikacji bankowej, upewnij się, że akceptujesz tylko właściwą kwotę. Otrzymasz płatność Lightning automatycznie po potwierdzeniu.';
			case 'taker.waitConfirmation.feedback.makerConfirmed': return 'Wystawiający potwierdził płatność.';
			case 'taker.waitConfirmation.feedback.paymentSuccessful': return 'Płatność udana! Wkrótce otrzymasz środki.';
			case 'taker.paymentProcess.title': return 'Proces płatności';
			case 'taker.paymentProcess.states.preparing': return 'Przygotowywanie do wysłania płatności...';
			case 'taker.paymentProcess.states.sending': return 'Wysyłanie płatności...';
			case 'taker.paymentProcess.states.received': return 'Otrzymano płatność!';
			case 'taker.paymentProcess.states.failed': return 'Płatność nie powiodła się';
			case 'taker.paymentProcess.states.waitingUpdate': return 'Oczekiwanie na aktualizację oferty...';
			case 'taker.paymentProcess.tasks.makerConfirmedBlik': return 'Wystawiający potwierdził płatność BLIK';
			case 'taker.paymentProcess.tasks.makerInvoiceSettled': return 'Faktura Hold wystawiającego rozliczona';
			case 'taker.paymentProcess.tasks.payingInvoice': return 'Generowanie i opłacanie Twojej faktury';
			case 'taker.paymentProcess.tasks.invoicePaid': return 'Twoja faktura opłacona pomyślnie';
			case 'taker.paymentProcess.tasks.paymentFailed': return 'Płatność do Ciebie nie powiodła się';
			case 'taker.paymentProcess.errors.sending': return ({required Object details}) => 'Błąd podczas wysyłania płatności: ${details}';
			case 'taker.paymentProcess.errors.notConfirmed': return 'Oferta niepotwierdzona przez Wystawiającego.';
			case 'taker.paymentProcess.errors.expired': return 'Oferta wygasła.';
			case 'taker.paymentProcess.errors.cancelled': return 'Oferta anulowana.';
			case 'taker.paymentProcess.errors.paymentFailed': return 'Płatność oferty nie powiodła się.';
			case 'taker.paymentProcess.errors.unknown': return 'Nieznany błąd oferty.';
			case 'taker.paymentProcess.errors.takerPaymentFailed': return 'Płatność na Twój adres Lightning nie powiodła się. Sprawdź szczegóły i w razie potrzeby podaj nową fakturę.';
			case 'taker.paymentProcess.errors.noPublicKey': return 'Błąd: Nie można pobrać Twojego klucza publicznego.';
			case 'taker.paymentProcess.errors.loadingPublicKey': return 'Błąd podczas ładowania Twoich danych';
			case 'taker.paymentProcess.errors.missingPaymentHash': return 'Błąd: Brak szczegółów płatności.';
			case 'taker.paymentProcess.loading.publicKey': return 'Ładowanie Twoich danych...';
			case 'taker.paymentProcess.actions.goToFailureDetails': return 'Przejdź do szczegółów błędu';
			case 'taker.paymentFailed.title': return 'Płatność nie powiodła się';
			case 'taker.paymentFailed.instructions': return ({required Object netAmount}) => 'Proszę podać nową fakturę Lightning na kwotę ${netAmount} satoshi';
			case 'taker.paymentFailed.form.label': return 'Nowa faktura Lightning';
			case 'taker.paymentFailed.form.hint': return 'Wprowadź swoją fakturę BOLT11';
			case 'taker.paymentFailed.actions.submit': return 'Wyślij nową fakturę';
			case 'taker.paymentFailed.errors.enterValid': return 'Proszę wprowadzić prawidłową fakturę';
			case 'taker.paymentFailed.errors.updating': return ({required Object details}) => 'Błąd podczas aktualizacji faktury: ${details}';
			case 'taker.paymentFailed.errors.retryFailed': return 'Ponowna próba płatności nie powiodła się. Sprawdź fakturę lub spróbuj ponownie później.';
			case 'taker.paymentSuccess.title': return 'Płatność udana';
			case 'taker.paymentSuccess.message': return 'Twoja płatność została przetworzona pomyślnie.';
			case 'taker.paymentSuccess.actions.goHome': return 'Przejdź do strony głównej';
			case 'taker.invalidBlik.title': return 'Nieprawidłowy Kod BLIK';
			case 'taker.invalidBlik.message': return 'Twórca Odrzucił Kod BLIK';
			case 'taker.invalidBlik.explanation': return 'Twórca oferty wskazał, że podany przez Ciebie kod BLIK był nieprawidłowy lub nie zadziałał. Co chcesz zrobić?';
			case 'taker.invalidBlik.errors.reservationFailed': return 'TODO';
			case 'taker.invalidBlik.actions.retry': return 'NIE ZAPŁACIŁEM, zarezerwuj ofertę ponownie i wyślij nowy kod BLIK';
			case 'taker.invalidBlik.actions.reportConflict': return 'POTWIERDZIŁEM KOD BLIK I ZOSTAŁO TO OBCIĄŻONE Z MOJEGO KONTA BANKOWEGO, Zgłoś konflikt, spowoduje SPÓR!';
			case 'taker.invalidBlik.actions.returnHome': return 'Wróć do strony głównej';
			case 'taker.conflict.title': return 'Konflikt Oferty';
			case 'taker.conflict.headline': return 'Zgłoszono Konflikt Oferty';
			case 'taker.conflict.body': return 'Wystawiający oznaczył kod BLIK jako nieprawidłowy, ale zgłosiłeś/aś konflikt, wskazując, że uważasz płatność za udaną.';
			case 'taker.conflict.instructions': return 'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';
			case 'taker.conflict.actions.back': return 'Wróć do Strony Głównej';
			case 'taker.conflict.feedback.reported': return 'Konflikt zgłoszony. Koordynator rozpatrzy sprawę.';
			case 'taker.conflict.errors.reporting': return ({required Object details}) => 'Błąd zgłaszania konfliktu: ${details}';
			case 'home.notifications.simplex': return 'Otrzymuj powiadomienia o nowych zamówieniach przez SimpleX';
			case 'home.notifications.element': return 'Otrzymuj powiadomienia o nowych zamówieniach przez Element';
			case 'home.statistics.title': return 'Ostatnie transakcje';
			case 'home.statistics.lifetimeCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Wszystkie: ${count} transakcji\nŚr. czas oczekiwania na BLIK: ${avgBlikTime}\nŚr. czas zakończenia: ${avgPaidTime}';
			case 'home.statistics.last7DaysCompact': return ({required Object count, required Object avgBlikTime, required Object avgPaidTime}) => 'Ost. 7d: ${count} transakcji\nŚr. czas oczekiwania na BLIK: ${avgBlikTime}\nŚr. czas zakończenia: ${avgPaidTime}';
			case 'home.statistics.errors.loading': return ({required Object error}) => 'Błąd ładowania statystyk: ${error}';
			case 'system.errors.generic': return 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';
			case 'system.errors.loadingTimeoutConfig': return 'Błąd ładowania konfiguracji limitu czasu.';
			case 'system.errors.loadingCoordinatorConfig': return 'Błąd ładowania konfiguracji koordynatora. Spróbuj ponownie.';
			case 'system.blik.copied': return 'Kod BLIK skopiowany do schowka';
			default: return null;
		}
	}
}

