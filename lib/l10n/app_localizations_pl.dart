// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get cancelReservationButton => 'Anuluj rezerwację';

  @override
  String get reservationCancelled => 'Rezerwacja została anulowana.';

  @override
  String errorCancellingReservation(Object error) {
    return 'Nie udało się anulować rezerwacji: $error';
  }

  @override
  String get appTitle => 'BitBlik';

  @override
  String get greeting => 'Cześć!';

  @override
  String get error => 'Błąd';

  @override
  String errorLoadingOffer(Object error) {
    return 'Błąd podczas ładowania oferty: $error';
  }

  @override
  String get errorOfferDetailsMissing =>
      'Błąd: Brak szczegółów oferty lub są nieprawidłowe.';

  @override
  String get errorOfferNotFound => 'Błąd: Oferta nie znaleziona.';

  @override
  String get waitingForBlik => 'Oczekiwanie na BLIK';

  @override
  String get offerReservedByTaker => 'Oferta zarezerwowana przez Kupującego!';

  @override
  String get waitingForTakerBlik =>
      'Oczekiwanie na wprowadzenie kodu BLIK przez Kupującego.';

  @override
  String get takerHas20Seconds => 'Kupujący ma 20 sekund na podanie kodu.';

  @override
  String takerHasXSecondsToProvideBlik(int seconds) {
    return 'Przyjmujący ma $seconds sekund na podanie kodu BLIK.';
  }

  @override
  String get goHome => 'Strona główna';

  @override
  String get errorActiveOfferDetailsLost =>
      'Błąd: Utracono szczegóły aktywnej oferty.';

  @override
  String get errorFailedToRetrieveBlik =>
      'Błąd: Nie udało się pobrać kodu BLIK.';

  @override
  String errorRetrievingBlik(Object details) {
    return 'Błąd podczas pobierania kodu BLIK: $details';
  }

  @override
  String offerNoLongerAvailable(Object status) {
    return 'Oferta nie jest już dostępna (Status: $status).';
  }

  @override
  String get yourOffer => 'Twoja oferta:';

  @override
  String amountSats(Object amount) {
    return 'Kwota: $amount satoshi';
  }

  @override
  String makerFeeSats(Object fee) {
    return 'Opłata wystawiającego: $fee satoshi';
  }

  @override
  String get makerConfirmedPayment => 'Wystawiający potwierdził płatność.';

  @override
  String takerFeeSats(Object fee) {
    return 'Opłata kupującego: $fee satoshi';
  }

  @override
  String status(Object status) {
    return 'Status: $status';
  }

  @override
  String get waitingForTaker =>
      'Oczekiwanie na Kupującego, który zarezerwuje Twoją ofertę...';

  @override
  String get cancelOffer => 'Anuluj ofertę';

  @override
  String get errorCouldNotIdentifyOffer =>
      'Błąd: Nie można zidentyfikować oferty do anulowania.';

  @override
  String offerCannotBeCancelled(Object status) {
    return 'Oferta nie może zostać anulowana w bieżącym stanie ($status).';
  }

  @override
  String get offerCancelledSuccessfully => 'Oferta anulowana pomyślnie.';

  @override
  String failedToCancelOffer(Object details) {
    return 'Nie udało się anulować oferty: $details';
  }

  @override
  String get enterLightningAddress =>
      'Wprowadź swój adres Lightning, aby kontynuować';

  @override
  String get lightningAddressHint => 'użytkownik@domena.com';

  @override
  String get lightningAddressLabel => 'Adres Lightning';

  @override
  String get lightningAddressInvalid => 'Wprowadź prawidłowy adres Lightning';

  @override
  String get saveAndContinue => 'Zapisz i kontynuuj';

  @override
  String get editLightningAddress => 'Edytuj adres Lightning';

  @override
  String get cancel => 'Anuluj';

  @override
  String get doneButton => 'Gotowe';

  @override
  String get save => 'Zapisz';

  @override
  String get lightningAddressSaved => 'Adres Lightning zapisany!';

  @override
  String get lightningAddressUpdated => 'Adres Lightning zaktualizowany!';

  @override
  String get loadingOfferDetails => 'Ładowanie szczegółów oferty...';

  @override
  String errorSavingAddress(Object details) {
    return 'Błąd podczas zapisywania adresu: $details';
  }

  @override
  String get getNotifiedSimplex =>
      'Otrzymuj powiadomienia o nowych zamówieniach przez SimpleX';

  @override
  String get getNotifiedWithElement =>
      'Otrzymuj powiadomienia o nowych zamówieniach przez Element';

  @override
  String get noOffersAvailable => 'Brak dostępnych ofert.';

  @override
  String get take => 'PRZYJMIJ';

  @override
  String get resume => 'WZNÓW';

  @override
  String offerAmountSats(Object amount) {
    return 'Kwota: $amount satoshi';
  }

  @override
  String offerFeeStatusId(Object fee, Object status) {
    return 'Opłata wystawiającego: $fee satoshi | Status: $status';
  }

  @override
  String get finishedOffers => 'Zakończone oferty';

  @override
  String errorLoadingOffers(Object details) {
    return 'Błąd podczas ładowania ofert: $details';
  }

  @override
  String get retry => 'Ponów';

  @override
  String get errorOfferUnexpectedState =>
      'Błąd: Oferta jest w nieoczekiwanym stanie.';

  @override
  String get errorPublicKeyNotLoaded =>
      'Błąd: Klucz publiczny nie został jeszcze załadowany.';

  @override
  String get errorInvalidNumberFormat => 'Nieprawidłowy format liczby';

  @override
  String get errorAmountMustBePositive => 'Kwota musi być dodatnia';

  @override
  String get errorInvalidFeePercentage => 'Nieprawidłowy procent opłaty';

  @override
  String errorInitiatingOffer(Object details) {
    return 'Błąd podczas inicjowania oferty: $details';
  }

  @override
  String get enterAmountToPay => 'Wprowadź kwotę (PLN) do zapłaty:';

  @override
  String get amountLabel => 'Kwota (PLN)';

  @override
  String get fetchingExchangeRate => 'Pobieranie kursu wymiany...';

  @override
  String satsEquivalent(String sats) {
    return '≈ $sats satoshi';
  }

  @override
  String plnBtcRate(String rate) {
    return 'Kurs PLN/BTC ≈ $rate';
  }

  @override
  String get errorFetchingRate => 'Nie udało się pobrać kursu wymiany.';

  @override
  String get generateInvoice => 'Wygeneruj fakturę';

  @override
  String get payHoldInvoiceTitle => 'Zapłać tę fakturę Hold:';

  @override
  String get errorCouldNotOpenLightningApp =>
      'Nie można otworzyć aplikacji Lightning dla faktury.';

  @override
  String errorOpeningLightningApp(Object details) {
    return 'Błąd podczas otwierania aplikacji Lightning: $details';
  }

  @override
  String get copyInvoice => 'Kopiuj fakturę';

  @override
  String get invoiceCopied => 'Faktura skopiowana do schowka!';

  @override
  String get waitingForPaymentConfirmation =>
      'Oczekiwanie na potwierdzenie płatności...';

  @override
  String get errorPublicKeyNotAvailable => 'Klucz publiczny nie jest dostępny.';

  @override
  String get errorCouldNotFetchActiveOffer =>
      'Nie można pobrać szczegółów aktywnej oferty. Mogła wygasnąć.';

  @override
  String get errorMissingPaymentHashOrKey =>
      'Błąd: Brak hasha płatności lub klucza publicznego.';

  @override
  String errorOfferIncorrectStateConfirmation(Object status) {
    return 'Oferta nie jest w prawidłowym stanie do potwierdzenia (Status: $status)';
  }

  @override
  String get paymentConfirmedTakerPaid =>
      'Płatność potwierdzona! Kupujący otrzyma środki.';

  @override
  String get paymentProcessTitle => 'Proces płatności';

  @override
  String errorConfirmingPayment(Object details) {
    return 'Błąd podczas potwierdzania płatności: $details';
  }

  @override
  String get blikCopied => 'Kod BLIK skopiowany do schowka';

  @override
  String get retrievingBlikCode => 'Pobieranie kodu BLIK...';

  @override
  String get blikCodeReceivedTitle => 'Otrzymano kod BLIK!';

  @override
  String get copyToClipboardTooltip => 'Kopiuj do schowka';

  @override
  String get blikInstructionsMaker =>
      'Wprowadź ten kod w terminalu płatniczym. Gdy Kupujący potwierdzi w swojej aplikacji bankowej i płatność zostanie zrealizowana, naciśnij Potwierdź poniżej.';

  @override
  String get confirmPaymentSuccessButton => 'Potwierdź udaną płatność';

  @override
  String get errorInvalidOfferStateReceived =>
      'Błąd: Otrzymano nieprawidłowy stan oferty.';

  @override
  String get errorInternalOfferIncomplete =>
      'Błąd wewnętrzny: Niekompletne szczegóły oferty.';

  @override
  String get errorOfferInvalidStatus => 'Oferta ma nieprawidłowy status.';

  @override
  String errorOfferNotAwaitingConfirmation(Object status) {
    return 'Oferta nie oczekuje już na potwierdzenie (Status: $status).';
  }

  @override
  String get errorUnexpectedStatusFromServer =>
      'Otrzymano nieoczekiwany status oferty z serwera.';

  @override
  String get offerCancelledOrExpired => 'Oferta została anulowana lub wygasła.';

  @override
  String get paymentSuccessfulTaker =>
      'Płatność udana! Wkrótce otrzymasz środki.';

  @override
  String get paymentReceived => 'Otrzymano płatność!';

  @override
  String get preparingToSendPayment =>
      'Przygotowywanie do wysłania płatności...';

  @override
  String get sendingPayment => 'Wysyłanie płatności...';

  @override
  String get paymentFailed => 'Płatność nie powiodła się';

  @override
  String errorSendingPayment(Object details) {
    return 'Błąd podczas wysyłania płatności: $details';
  }

  @override
  String get errorOfferNotConfirmed =>
      'Oferta niepotwierdzona przez Wystawiającego.';

  @override
  String get errorOfferExpired => 'Oferta wygasła.';

  @override
  String get errorOfferCancelled => 'Oferta anulowana.';

  @override
  String get errorOfferPaymentFailed => 'Płatność oferty nie powiodła się.';

  @override
  String get errorOfferUnknown => 'Nieznany błąd oferty.';

  @override
  String errorOfferUnexpectedStateWithStatus(Object status) {
    return 'Oferta jest w nieoczekiwanym stanie ($status).';
  }

  @override
  String offerStatusLabel(Object status) {
    return 'Status oferty: $status';
  }

  @override
  String waitingMakerConfirmation(int seconds) {
    return 'Oczekiwanie na potwierdzenie Wystawiającego: $seconds s';
  }

  @override
  String importantBlikAmountConfirmation(String amount, String currency) {
    return 'BARDZO WAŻNE: Upewnij się, że akceptujesz tylko potwierdzenie BLIK na kwotę $amount $currency';
  }

  @override
  String get blikInstructionsTaker =>
      'Wystawiający ofertę otrzymał Twój kod BLIK i musi wprowadzić go w terminalu płatniczym. Następnie musisz zaakceptować kod BLIK w swojej aplikacji bankowej, upewnij się, że akceptujesz tylko właściwą kwotę. Otrzymasz płatność Lightning automatycznie po potwierdzeniu.';

  @override
  String submitBlikWithinSeconds(int seconds) {
    return 'Wprowadź BLIK w ciągu: $seconds s';
  }

  @override
  String errorFetchedOfferIdMismatch(Object fetchedId, Object initialId) {
    return 'Pobrane ID aktywnej oferty ($fetchedId) nie odpowiada początkowemu ID oferty ($initialId). Niezgodność stanu?';
  }

  @override
  String errorOfferNotReserved(Object status) {
    return 'Oferta nie jest już w stanie zarezerwowanym ($status).';
  }

  @override
  String get errorOfferReservationTimestampMissing =>
      'Brak znacznika czasu rezerwacji oferty.';

  @override
  String get errorOfferPaymentHashMissing =>
      'Brak hasha płatności oferty po pobraniu.';

  @override
  String errorLoadingOfferDetails(Object details) {
    return 'Błąd podczas ładowania szczegółów oferty: $details';
  }

  @override
  String get blikInputTimeExpired => 'Czas na wprowadzenie kodu BLIK upłynął.';

  @override
  String get errorOfferStateChanged => 'Błąd: Stan oferty uległ zmianie.';

  @override
  String get errorOfferStateNotValid =>
      'Błąd: Stan oferty nie jest już prawidłowy.';

  @override
  String get errorInvalidBlikFormat =>
      'Wprowadź prawidłowy 6-cyfrowy kod BLIK.';

  @override
  String get errorLightningAddressRequired => 'Adres Lightning jest wymagany.';

  @override
  String errorSubmittingBlik(Object details) {
    return 'Błąd podczas przesyłania kodu BLIK: $details';
  }

  @override
  String get blikPasted => 'Wklejony kod BLIK.';

  @override
  String get errorClipboardInvalidBlik =>
      'Schowek nie zawiera prawidłowego 6-cyfrowego kodu BLIK.';

  @override
  String get errorOfferDetailsNotLoaded =>
      'Nie można załadować szczegółów oferty.';

  @override
  String get selectedOfferLabel => 'Wybrana oferta:';

  @override
  String offerDetailsSubtitle(int sats, int fee, String status) {
    return '$sats + $fee (opłata) satoshi\nStatus: $status';
  }

  @override
  String get enterBlikCodeLabel => 'Wprowadź 6-cyfrowy kod BLIK:';

  @override
  String get blikCodeLabel => 'Kod BLIK';

  @override
  String get pasteFromClipboardTooltip => 'Wklej ze schowka';

  @override
  String get submitBlikButton => 'Wyślij BLIK';

  @override
  String errorCheckingActiveOffers(Object details) {
    return 'Błąd podczas sprawdzania aktywnych ofert: $details';
  }

  @override
  String get payWithLightningButton => 'ZAPŁAĆ z Lightning';

  @override
  String get sellBlikButton => 'SPRZEDAJ kod BLIK za satoshi';

  @override
  String get activeOfferTitle => 'Masz aktywną ofertę:';

  @override
  String roleLabel(String role) {
    return 'Rola: $role';
  }

  @override
  String get roleMaker => 'Wystawiający';

  @override
  String get roleTaker => 'Kupujący';

  @override
  String activeOfferSubtitle(String status, int amount) {
    return 'Status: $status\nKwota: $amount satoshi';
  }

  @override
  String lightningAddressLabelShort(String address) {
    return 'Adres Lightning: $address';
  }

  @override
  String get errorMakerPublicKeyNotFound =>
      'Nie znaleziono klucza publicznego Wystawiającego';

  @override
  String errorResumingOffer(Object details) {
    return 'Błąd podczas wznawiania oferty: $details';
  }

  @override
  String errorLoadingFinishedOffers(Object details) {
    return 'Błąd podczas ładowania zakończonych ofert: $details';
  }

  @override
  String get finishedOffersTitle => 'Zakończone oferty (ostatnie 24h):';

  @override
  String finishedOfferSubtitle(int sats, int fee, String status, String date) {
    return '$sats + $fee (opłata) satoshi\nStatus: $status\nOpłacone: $date';
  }

  @override
  String errorCannotResumeOfferState(Object status) {
    return 'Nie można wznowić oferty w stanie: $status';
  }

  @override
  String errorCannotResumeTakerOfferState(Object status) {
    return 'Nie można wznowić oferty Kupującego w stanie: $status';
  }

  @override
  String get paymentFailedTitle => 'Płatność nie powiodła się';

  @override
  String paymentFailedInstructions(int netAmount) {
    return 'Proszę podać nową fakturę Lightning na kwotę $netAmount satoshi';
  }

  @override
  String get newLightningInvoiceLabel => 'Nowa faktura Lightning';

  @override
  String get newLightningInvoiceHint => 'Wprowadź swoją fakturę BOLT11';

  @override
  String get errorEnterValidInvoice => 'Proszę wprowadzić prawidłową fakturę';

  @override
  String errorUpdatingInvoice(Object details) {
    return 'Błąd podczas aktualizacji faktury: $details';
  }

  @override
  String get submitNewInvoiceButton => 'Wyślij nową fakturę';

  @override
  String get offerCompletedTitle => 'Oferta zakończona';

  @override
  String get paymentConfirmedHeadline => 'Płatność potwierdzona!';

  @override
  String get takerPaidSubtitle => 'Kupujący otrzymał zapłatę.';

  @override
  String get offerDetailsTitle => 'Szczegóły oferty:';

  @override
  String offerIdLabel(String id) {
    return 'ID Oferty: $id...';
  }

  @override
  String errorLoadingLightningAddress(Object details) {
    return 'Błąd podczas ładowania adresu Lightning: $details';
  }

  @override
  String get validLightningAddressTooltip => 'Prawidłowy adres Lightning';

  @override
  String get errorFailedToReserveOfferNoTimestamp =>
      'Nie udało się zarezerwować oferty (brak znacznika czasu).';

  @override
  String errorFailedToReserveOffer(Object details) {
    return 'Nie udało się zarezerwować oferty: $details';
  }

  @override
  String progressWaitingForTaker(String time) {
    return 'Oczekiwanie na kupującego: $time';
  }

  @override
  String progressReserved(int seconds) {
    return 'Zarezerwowano: pozostało $seconds s';
  }

  @override
  String progressConfirming(int seconds) {
    return 'Potwierdzanie: pozostało $seconds s';
  }

  @override
  String get errorNoPublicKey =>
      'Błąd: Nie można pobrać Twojego klucza publicznego.';

  @override
  String get waitingForOfferUpdate => 'Oczekiwanie na aktualizację oferty...';

  @override
  String get loadingPublicKey => 'Ładowanie Twoich danych...';

  @override
  String get errorLoadingPublicKey => 'Błąd podczas ładowania Twoich danych';

  @override
  String get errorMissingPaymentHash => 'Błąd: Brak szczegółów płatności.';

  @override
  String get taskMakerConfirmedBlik => 'Wystawiający potwierdził płatność BLIK';

  @override
  String get taskMakerInvoiceSettled =>
      'Faktura Hold wystawiającego rozliczona';

  @override
  String get taskPayingTakerInvoice => 'Generowanie i opłacanie Twojej faktury';

  @override
  String get taskTakerInvoicePaid => 'Twoja faktura opłacona pomyślnie';

  @override
  String get taskTakerPaymentFailed => 'Płatność do Ciebie nie powiodła się';

  @override
  String get errorTakerPaymentFailed =>
      'Płatność na Twój adres Lightning nie powiodła się. Sprawdź szczegóły i w razie potrzeby podaj nową fakturę.';

  @override
  String get goToFailureDetails => 'Przejdź do szczegółów błędu';

  @override
  String get errorTakerPublicKeyNotFound =>
      'Nie znaleziono klucza publicznego Kupującego.';

  @override
  String get paymentRetryFailedError =>
      'Ponowna próba płatności nie powiodła się. Sprawdź fakturę lub spróbuj ponownie później.';

  @override
  String get paymentSuccessfulTitle => 'Płatność udana';

  @override
  String get paymentSuccessfulMessage =>
      'Twoja płatność została przetworzona pomyślnie.';

  @override
  String get goToHomeButton => 'Przejdź do strony głównej';

  @override
  String get makerInvalidBlikTitle => 'Nieprawidłowy Kod BLIK';

  @override
  String get makerInvalidBlikInfo =>
      'Oznaczyłeś kod BLIK jako nieprawidłowy. Oczekiwanie na podanie nowego kodu przez takera lub rozpoczęcie sporu.';

  @override
  String get genericError => 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';

  @override
  String get makerInvalidBlikButton => 'Nieprawidłowy Kod BLIK';

  @override
  String get invalidBlikTitle => 'Nieprawidłowy Kod BLIK';

  @override
  String get invalidBlikMessage => 'Twórca Odrzucił Kod BLIK';

  @override
  String get invalidBlikExplanation =>
      'Twórca oferty wskazał, że podany przez Ciebie kod BLIK był nieprawidłowy lub nie zadziałał. Co chcesz zrobić?';

  @override
  String get invalidBlikRetryButton => 'Spróbuj ponownie z nowym kodem BLIK';

  @override
  String get invalidBlikConflictButton => 'Zgłoś konflikt (Zapłaciłem!)';

  @override
  String get cancelAndReturnHome => 'Anuluj i wróć do strony głównej';

  @override
  String get conflictReportedSuccess =>
      'Konflikt zgłoszony. Koordynator rozpatrzy sprawę.';

  @override
  String conflictReportError(Object details) {
    return 'Błąd zgłaszania konfliktu: $details';
  }

  @override
  String get takerConflictTitle => 'Konflikt Oferty';

  @override
  String get takerConflictHeadline => 'Zgłoszono Konflikt Oferty';

  @override
  String get takerConflictBody =>
      'Wystawiający oznaczył kod BLIK jako nieprawidłowy, ale zgłosiłeś/aś konflikt, wskazując, że uważasz płatność za udaną.';

  @override
  String get takerConflictInstructions =>
      'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';

  @override
  String get takerConflictBackButton => 'Wróć do Strony Głównej';

  @override
  String get makerConflictTitle => 'Konflikt Oferty';

  @override
  String get makerConflictHeadline => 'Zgłoszono Konflikt Oferty';

  @override
  String get makerConflictBody =>
      'Oznaczyłeś/aś kod BLIK jako nieprawidłowy, ale Kupujący zgłosił/a konflikt, wskazując, że uważa płatność za udaną.';

  @override
  String get makerConflictInstructions =>
      'Poczekaj, aż koordynator rozpatrzy sytuację. Możesz zostać poproszony/a o więcej szczegółów. Sprawdź ponownie później lub skontaktuj się z pomocą techniczną w razie potrzeby.';

  @override
  String get makerConflictBackButton => 'Wróć do Strony Głównej';

  @override
  String get makerConflictConfirmPaymentButton =>
      'Mój błąd, potwierdź sukces płatności BLIK';

  @override
  String get makerConflictOpenDisputeButton =>
      'Płatność Blik NIE powiodła się, OTWÓRZ SPÓR';

  @override
  String get makerConflictDisputeDialogTitle => 'Otworzyć spór?';

  @override
  String get makerConflictDisputeDialogContent =>
      'Otwarcie sporu wymaga ręcznej weryfikacji przez koordynatora, co może zająć czas. Opłata za spór zostanie potrącona, jeśli spór zostanie rozstrzygnięty na Twoją niekorzyść. Faktura blokująca (hold invoice) zostanie rozliczona, aby zapobiec jej wygaśnięciu. Jeśli spór zostanie rozstrzygnięty na Twoją korzyść, otrzymasz zwrot środków (pomniejszony o opłaty) na Twój adres Lightning.';

  @override
  String get makerConflictDisputeDialogConfirm => 'Otwórz Spór';

  @override
  String get makerConflictDisputeDialogCancel => 'Anuluj';

  @override
  String get makerConflictDisputeDialogContentDetailed =>
      'Otwarcie sporu będzie wymagało ręcznej interwencji koordynatora, co zajmie czas i wiąże się z opłatą za spór.\\n\\nFaktura blokująca (hold invoice) zostanie natychmiast rozliczona, aby zapobiec jej wygaśnięciu przed rozstrzygnięciem sporu.\\n\\nJeśli spór zostanie rozstrzygnięty na Twoją korzyść, kwota w satoshi zostanie zwrócona na Twój adres Lightning (pomniejszona o opłaty za spór). Upewnij się, że masz skonfigurowany adres Lightning.';

  @override
  String get makerConflictSubmitDisputeButton => 'Zgłoś Spór';

  @override
  String errorOpenDispute(String error) {
    return 'Błąd podczas otwierania sporu: $error';
  }

  @override
  String get successOpenDispute =>
      'Spór został pomyślnie otwarty. Koordynator rozpatrzy sprawę.';

  @override
  String get errorLoadingTimeoutConfiguration =>
      'Błąd ładowania konfiguracji limitu czasu.';

  @override
  String errorAmountTooLowFiat(String minAmount, String currency) {
    return 'Kwota jest za niska. Minimum to $minAmount $currency.';
  }

  @override
  String errorAmountTooHighFiat(String maxAmount, String currency) {
    return 'Kwota jest za wysoka. Maksimum to $maxAmount $currency.';
  }

  @override
  String amountRangeHint(String minAmount, String maxAmount, String currency) {
    return 'Min/Max: $minAmount-$maxAmount $currency';
  }

  @override
  String get errorLoadingCoordinatorConfig =>
      'Błąd ładowania konfiguracji koordynatora. Spróbuj ponownie.';

  @override
  String get successfulTradeStatistics => 'Ostatnie transakcje';

  @override
  String offerCreatedAt(Object dateTime) {
    return 'Utworzono: $dateTime';
  }

  @override
  String offerTakenAfter(Object duration) {
    return 'Przyjęto po: $duration';
  }

  @override
  String offerPaidAfter(Object duration) {
    return 'Wypłacono po: $duration';
  }

  @override
  String offerFiatAmount(Object amount, Object currency) {
    return '$amount $currency';
  }

  @override
  String get noSuccessfulTradesYet => 'Brak udanych transakcji.';

  @override
  String errorLoadingStats(Object error) {
    return 'Błąd ładowania statystyk: $error';
  }

  @override
  String statsLifetimeCompact(
    String count,
    String avgBlikTime,
    String avgPaidTime,
  ) {
    return 'Wszystkie: $count transakcji\nŚr. czas oczekiwania na BLIK: $avgBlikTime\nŚr. czas zakończenia: $avgPaidTime';
  }

  @override
  String statsLast7DaysCompact(
    String count,
    String avgBlikTime,
    String avgPaidTime,
  ) {
    return 'Ost. 7d: $count transakcji\nŚr. czas oczekiwania na BLIK: $avgBlikTime\nŚr. czas zakończenia: $avgPaidTime';
  }
}
