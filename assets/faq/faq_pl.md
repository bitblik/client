## Często Zadawane Pytania dotyczące Usługi Escrow BitBlik

### Pytania Ogólne

#### Czym jest Usługa Escrow BitBlik?

BitBlik to peer-to-peer usługa escrow zaprojektowana w celu ułatwienia wymiany aktywów, koncentrująca się głównie na Bitcoin (poprzez Lightning Network) za walutę fiat (szczególnie przy użyciu BLIK, polskiego systemu płatności). Wykorzystuje faktury wstrzymane Lightning Network jako główny mechanizm zabezpieczania transakcji, zapewniając, że Bitcoin jest zwalniane tylko po potwierdzeniu płatności fiat.


#### Dla kogo jest ta usługa?

Ta usługa jest dla osób, które chcą kupować lub sprzedawać Bitcoin przy użyciu BLIK w bezpieczniejszy sposób niż bezpośrednie transakcje peer-to-peer bez pośrednika.
*   **Twórcy ofert (Makers)** to użytkownicy chcący sprzedać Bitcoin.
*   **Przyjmujący oferty (Takers)** to użytkownicy chcący kupić Bitcoin.

####Jak działa proces escrow?

Proces generalnie przebiega według następujących kroków:
1.  **Utworzenie Oferty (Twórca oferty):** Twórca oferty tworzy ofertę, określając ilość Bitcoin (satoshi) którą chce sprzedać oraz równoważną kwotę fiat.
2.  **Finansowanie Escrow (Twórca oferty):** Twórca oferty finansuje "fakturę wstrzymaną" Lightning Network na określoną ilość Bitcoin. To blokuje Bitcoin u koordynatora, ale jeszcze go nie przekazuje. Koordynator przechowuje hash płatności i tajny preimage.
3.  **Akceptacja Oferty (Przyjmujący ofertę):** Przyjmujący ofertę znajduje ofertę, która mu się podoba i ją akceptuje.
4.  **Płatność Fiat (Przyjmujący ofertę):** Przyjmujący ofertę dostarcza swój kod BLIK Twórcy oferty (za pośrednictwem systemu) i dokonuje płatności fiat bezpośrednio do Twórcy oferty.
5.  **Potwierdzenie Płatności (Twórca oferty):** Twórca oferty potwierdza w systemie BitBlik, że otrzymał płatność BLIK.
6.  **Zwolnienie Bitcoin (Koordynator):** Po potwierdzeniu przez Twórcę oferty, koordynator używa tajnego preimage do "rozliczenia" faktury wstrzymanej. Ta akcja zwalnia zablokowany Bitcoin na podany przez Przyjmującego ofertę adres Lightning lub fakturę.
7.  **Zakończenie:** Transakcja jest zakończona.

####Czym jest Lightning Network (LN)?

Lightning Network to protokół płatności "Layer 2" zbudowany na Bitcoin. Umożliwia szybkie, niskokosztowe transakcje. BitBlik używa LN po stronie Bitcoin w handlu, szczególnie wykorzystując "faktury wstrzymane".

####Czym są "faktury wstrzymane" Lightning Network?

Faktury wstrzymane to specjalny typ faktury Lightning. Gdy faktura wstrzymana jest opłacona przez Twórcę oferty (sprzedawcę Bitcoin), środki nie są natychmiast rozliczane. Zamiast tego są "wstrzymywane" przez węzeł LND Twórcy oferty (lub węzeł LND koordynatora działający w jego imieniu). Środki są naprawdę zwalniane (rozliczane) do odbiorcy (Przyjmującego ofertę) tylko wtedy, gdy ujawniony zostanie tajny "preimage". Jeśli preimage nie zostanie ujawniony w określonym czasie, lub jeśli faktura zostanie wyraźnie anulowana, środki są zwracane płatnikowi (Twórcy oferty). To jest sedno mechanizmu escrow BitBlik.

### Bezpieczeństwo i Ryzyka

####Jak moje środki Bitcoin są zabezpieczone jako Twórca oferty (sprzedawca)?

Jako Twórca oferty, twój Bitcoin jest zablokowany poprzez fakturę wstrzymaną. Koordynator ma preimage wymagany do rozliczenia tej faktury. System jest zaprojektowany tak, aby rozliczać (zwalniać twój Bitcoin do Przyjmującego ofertę) *tylko* po tym, jak potwierdzisz, że otrzymałeś płatność fiat (BLIK) od Przyjmującego ofertę. Jeśli Przyjmujący ofertę nie zapłaci, lub jeśli będzie problem, faktura wstrzymana może zostać anulowana, a Bitcoin powinien zostać zwrócony pod kontrolę twojego węzła LN.

####Jak jestem chroniony jako Przyjmujący ofertę (kupujący) jeśli wyślę płatność BLIK?

Jako Przyjmujący ofertę, twoją główną ochroną jest to, że Twórca oferty już zablokował swój Bitcoin w fakturze wstrzymanej u koordynatora *zanim* zostaniesz poproszony o wysłanie płatności BLIK. Jeśli Twórca oferty potwierdzi otrzymanie twojego BLIK, system jest zaprojektowany tak, aby automatycznie zwolnić Bitcoin do ciebie. Ryzyko polega na tym, że Twórca oferty fałszywie zaprzeczy otrzymaniu twojego BLIK. (Zobacz "[Spory](#spory)").

####Co się dzieje, jeśli Twórca oferty nie potwierdzi mojej płatności BLIK mimo że ją wysłałem?

To jest scenariusz konfliktu. System rejestruje różne etapy transakcji, włącznie z tym kiedy kod BLIK został dostarczony i kiedy oferta została oznaczona jako `blikReceived`. Jeśli Twórca oferty nie potwierdzi, oferta może wejść w status `conflict`. Dokładny mechanizm rozwiązywania sporów nie jest w pełni opisany w obecnej analizie kodu, ale to jest krytyczny punkt zaufania lub potencjalnej ręcznej interwencji przez operatora usługi.

####Co się dzieje, jeśli Przyjmujący ofertę podaje kod BLIK ale faktycznie nie dokonuje płatności?

Jako Twórca oferty, nie powinieneś potwierdzać otrzymania płatności dopóki środki fiat faktycznie nie są na twoim koncie. Jeśli Przyjmujący ofertę nie zapłaci po podaniu kodu BLIK, nie potwierdziłbyś, a oferta prawdopodobnie wygaśnie lub będzie można ją anulować. Faktura wstrzymana zabezpieczająca twój Bitcoin w końcu zostanie anulowana, zwracając ci środki.

####Co jeśli kod BLIK podany przez Przyjmującego ofertę jest nieprawidłowy lub wygasa?

System pozwala na status `invalidBlik`. Jeśli Twórca oferty próbuje użyć kodu BLIK i to się nie udaje, transakcja nie może być kontynuowana. Przyjmujący ofertę może potrzebować podać nowy kod, lub oferta może zostać anulowana.

####Jakie są ryzyka korzystania z tej usługi?

- **Ryzyko Kontrahenta:** Głównym ryzykiem jest to, że druga strona nie będzie działać uczciwie (np. Przyjmujący ofertę nie płaci po tym jak Twórca oferty zablokuje BTC, lub Twórca oferty nie potwierdzi płatności po tym jak Przyjmujący ofertę zapłaci). Mechanizm faktury wstrzymanej zmniejsza to ryzyko, ale go nie eliminuje, szczególnie wokół części płatności fiat.
- **Zaufanie do Koordynatora:** Ufasz oprogramowaniu koordynatora BitBlik i jego operatorom w:
    *   Bezpiecznym zarządzaniu preimage faktur wstrzymanych.
    *   Prawidłowym wyzwalaniu rozliczeń lub anulacji w oparciu o przepływ procesu.
    *   Niezawodnym działaniu usługi.
- **Problemy z Węzłem LND:** Zarówno węzeł LND koordynatora jak i potencjalnie węzły LND użytkowników (jeśli są samodzielnie hostowane i bezpośrednio współdziałają) muszą być online i operacyjne. Problemy z węzłami LND mogą opóźnić lub skomplikować transakcje.
- **Problemy z Systemem BLIK:** Problemy z samym systemem płatności BLIK są poza kontrolą BitBlik.
- **Błędy Oprogramowania:** Jak z każdym oprogramowaniem, istnieje ryzyko błędów w kliencie BitBlik lub koordynatorze, które mogą prowadzić do błędów lub utraty środków.
- **Prywatność:** Twoje klucze publiczne (pubkey węzłów Lightning) są przechowywane przez koordynatora. Szczegóły transakcji są również przechowywane w bazie danych.

####Czy koordynator jest powierniczy?

Koordynator nie jest powierniczy w tradycyjnym sensie dla *ostatecznego* rozliczenia Bitcoin dla Przyjmującego ofertę, ponieważ wypłaca na fakturę Przyjmującego ofertę. Jednak podczas okresu escrow, środki Twórcy oferty są zablokowane w fakturze wstrzymanej, którą koordynator ma moc rozliczyć (używając preimage) lub zlecić anulację. Więc istnieje element tymczasowej kontroli przez koordynatora nad zablokowanymi środkami. Twórca oferty ufa koordynatorowi w zwolnieniu tych środków zgodnie z protokołem.

### Opłaty i Kwestie Techniczne

####Czy są jakieś opłaty za korzystanie z BitBlik?

Dokładne kwoty opłat lub sposób ich obliczania są określony przez każdy koordynator i wyświetlany w aplikacji klienckiej.

####Co się dzieje, jeśli płatność Lightning (wypłata do Przyjmującego ofertę) się nie uda?

Jeśli koordynator próbuje zapłacić fakturę Lightning Przyjmującego ofertę i to się nie uda (np. węzeł Przyjmującego oferty offline, brak trasy), transakcja może wejść w ten stan. Przyjmujący ofertę może potrzebować podać nową fakturę lub rozwiązać problemy ze swoją konfiguracją Lightning.

####Co jeśli ja, jako Twórca oferty, chcę anulować moją ofertę po jej sfinansowaniu, ale przed tym jak Przyjmujący ofertę ją zaakceptuje?

System wydaje się obsługiwać funkcję `cancelOffer`. To anulowałoby fakturę wstrzymaną, a Bitcoin powinien zostać zwrócony do twojego portfela LND (minus ewentualne opłaty LND). To jest zazwyczaj możliwe, jeśli oferta jest nadal w stanie `funded` a nie jeszcze `reserved` lub dalej w procesie.

####Dlaczego aplikacje mobilne nie są dystrybuowane w Google Play Store i Apple App Store?

Te platformy to nie tylko zwykłe rynki do aplikacji; to zamknięte ogrody rządzone przez korporacyjnych strażników, którzy sprawują absolutną władzę nad tym, jakie oprogramowanie użytkownicy mogą instalować. Ten scentralizowany model tworzy pojedynczy punkt awarii i wąskie gardło dla censury. Aplikacje promujące technologie zwiększające prywatność, kontrowersyjne wypowiedzi polityczne lub alternatywne modele ekonomiczne mogą być i często są usuwane z list wyłącznie według uznania właścicieli platform, co hamuje innowacje i swobodną wymianę idei.

### Spory
Jeśli zarówno twórca, jak i przyjmujący nie zgadzają się co do statusu płatności lub jeśli występują problemy z transakcją, oferta przechodzi w stan konfliktu, w którym każda strona musi dostarczyć dowody koordynatorowi w celu rozstrzygnięcia sporu.

####Jakiego rodzaju dowody będą wymagane ode mnie jako Twórcy?
TODO

####Jakiego rodzaju dowody będą wymagane ode mnie jako Przyjmującego?
TODO