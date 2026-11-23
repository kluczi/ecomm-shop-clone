# Dziennik korzystania z narzędzi AI

## Wpis 1: Issue #8 – Wdrożenie HTTPS i przekierowania 301

| Pole | Opis |
| --- | --- |
| **Data i autor** | 08.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #8 – Wdrożenie HTTPS i przekierowania 301 |
| **Co otrzymano** | Konsultację architektoniczną wzorca Reverse Proxy, dobór parametrów OpenSSL oraz reguły w `.gitignore` |
| **Co było błędne** | AI dodało niepotrzebny plik `.gitkeep` i zbędne reguły w `.gitignore` – usunięto po weryfikacji. |
| **Weryfikacja** | Uruchomienie docker compose, sprawdzenie w przeglądarce przekierowania z `http://` na `https://` oraz test nagłówków poleceniem `curl.exe` |

---

## Wpis 2: Issue #11 – Strony CMS i moduł informacji o plikach cookies

| Pole | Opis |
| --- | --- |
| **Data i autor** | 11.11.2026, Dominik Szwed |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #11: Strony CMS i moduł informacji o plikach cookies |
| **Co otrzymano** | Zaproponowane szablony treści CMS (O sklepie, Regulamin, Polityka prywatności, Dostawa, Płatności) dopasowane do branży AGD/RTV (Domitek) oraz szkielet autorskiego modułu PrestaShop `domitekcookies`. |
| **Co było błędne** | Propozycja pobierania zewnętrznego modułu przez `curl` z GitHub nie zadziałała z powodu błędnego linku/przekierowania. AI początkowo sugerowało użycie `psgdpr` do banera cookie, co nie pokrywało wymogu pełnego paska zgody. Skorygowałem to, zlecając stworzenie dedykowanego, lokalnego modułu w repozytorium. |
| **Weryfikacja** | Ręczne wprowadzenie i korekta tekstów w panelu CMS PrestaShop, instalacja i test modułu `domitekcookies` w przeglądarce (weryfikacja wyświetlania banera, zamykania i zapisu do localStorage), eksport tabel CMS do pliku SQL. |

---

## Wpis 3: Issue #14 i #15 – Metody płatności i konfiguracja dostaw

| Pole | Opis |
| --- | --- |
| **Data i autor** | 12.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #14: Metody płatności oraz Issue #15: Konfiguracja dostawców i reguł darmowej dostawy |
| **Co otrzymano** | Pomoc w przygotowaniu zrzutów tabel konfiguracyjnych SQL dla modułów płatności (`ps_wirepayment`, `ps_cashondelivery`) oraz wyliczenie stawek netto dla przewoźników InPost i DPD uwzględniających 23% VAT, a także integrację z `Makefile`. |
| **Co było błędne** | AI początkowo ustawiło w bazie ceny brutto jako netto, co skutkowało zawyżonymi kwotami w koszyku po doliczeniu podatku VAT (18.44 zł i 24.59 zł zamiast 14.99 zł i 19.99 zł). Ponadto AI zaproponowało zachowanie poza zakresem wagowym jako naliczenie najwyższej stawki zamiast zablokowania przewoźnika. Błędy skorygowano po teście w koszyku. |
| **Weryfikacja** | Przetestowanie ścieżki zamówienia w sklepie: weryfikacja dostępności obu metod płatności, sprawdzenie kwot 14.99 zł i 19.99 zł brutto w koszyku, test naliczenia darmowej dostawy powyżej 2000 zł oraz test blokady przewoźników dla koszyka o wadze powyżej 50 kg. |

---

## Wpis 4: Issue #10 – Storefront Setup (PLN, tożsamość sklepu, menu, filtry i koszyk)

| Pole | Opis |
| --- | --- |
| **Data i autor** | 22.11.2026, Dominik Szwed |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #10: Storefront Setup |
| **Co otrzymano** | Pomoc w konfiguracji tożsamości sklepu (Domitek), domyślnej waluty PLN (zł), menu górnego z kategoriami TopMarket, szablonu filtrów fasetowych (`ps_facetedsearch`), ukrycia kafelków podkategorii na listingu (`shop/custom.css`), diagnozy i poprawki ścieżek ikon SVG w `blockreassurance` oraz aktualizacji celu `storefront:` w `Makefile`. |
| **Co było błędne** | AI początkowo proponowało nadmiarowe modyfikacje motywu graficznego (slider, banery należące do zadania D1) oraz ustawienie waluty przed jej rejestracją w tabelach walutowych. Dodatkowo w module `blockreassurance` ścieżki ikon zawierały podwójny slash `//modules/...`, wywołując błędy sieciowe `ERR_NAME_NOT_RESOLVED` w konsoli, co skorygowano zapytaniem SQL zamieniającym ścieżki na `/modules/...`. |
| **Weryfikacja** | Przejście pełnej ścieżki użytkownika na sklepie (menu górne, wyszukiwarka z polskimi frazami, listing z filtrami fasetowymi, karta produktu z cenami PLN i polskimi znakami, dodawanie do koszyka, widok koszyka oraz checkout), sprawdzenie konsoli przeglądarki (F12) oraz weryfikacja automatycznego wdrożenia poleceniem `make storefront`. |

---

## Issue #5 – Scraper produktów i weryfikacja danych

| Pole              | Opis                                              |
| ----------------- | ------------------------------------------------- |
| Data i autor      | 7.11.26, Bartek Kluska                            |
| Narzędzie i model | Claude Code Sonnet 5.5                            |
| Zadanie           | #5 Ignorowanie plików środowiskowych w .gitignore |
| Co otrzymano      | Pliki przestały być śledzone przez gita           |
| Co było błędne    | N/A                                               |
| Weryfikacja       | Sprawdzenie pliku .gitignore                      |

| Pole              | Opis                                                                                                                                            |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 7.11.26, Bartek Kluska                                                                                                                          |
| Narzędzie i model | Claude Code Sonnet 5.5                                                                                                                          |
| Zadanie           | #5 Zleciłem agentowi uzupełnienie scrapera i parsera do końca, ponieważ struktura HTML produktu była skomplikowana i zajęłaby sporo czasu       |
| Co otrzymano      | Claude uzupełnił kod scrapera i parsera, który scrapował produkty z wymienionych przeze mnie kategorii, a następnie zapisywał je do plików JSON |
| Co było błędne    | Kod agenta wykorzystywał scrapowanie równoległe, co w tym przypadku jest overkillem.                                                            |
| Weryfikacja       | Weryfikacja wygenerowanego kodu oraz odpalenie scrapera.                                                                                        |

| Pole              | Opis                                                                             |
| ----------------- | -------------------------------------------------------------------------------- |
| Data i autor      | 7.11.26, Bartek Kluska                                                           |
| Narzędzie i model | Claude Code Sonnet 5.5                                                           |
| Zadanie           | #5 Zleciłem agentowi napisanie testów jednostkowych do scrapera używając pytest. |
| Co otrzymano      | Claude stworzył testy jednostkowe.                                               |
| Co było błędne    | N/A                                                                              |
| Weryfikacja       | Sprawdzenie kodu testów oraz uruchomienie ich. Wszystkie testy przeszły.         |

| Pole              | Opis                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 13.11.26, Bartek Kluska                                                                                                                                                                                                                                                                                                                                                                                                                        |
| Narzędzie i model | Codex GPT-6.1-Sol                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Zadanie           | #5 Sprawdziłem wyrywkowo produkt, który okazał się być niedostępny. Następnie sprawdziłem jego cały rekord i okazało się, że zescrapowane informacje są niepoprawne (scraper pobierał dane polecanego wyżej produktu). Zleciłem agentowi przeanalizowanie tej sytuacji.                                                                                                                                                                        |
| Co otrzymano      | Mimo tego, że produkt był niedostępny nadal się wyświetlał a jego strona zwracała HTTP 200, dlatego scraper uznawał, że produkt jest dostępny. Produkt polecany, który znajdował się nad naszym docelowym, lecz niedostępnym produktem, posiadał taki sam selektor .product-description, przez co scraper zczytywał dane polecanego produktu. Agent zasugerował skorzystanie z dostępnego pola w danych produktu mówiącego o jego dostępności. |
| Co było błędne    | N/A                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Weryfikacja       | Sprawdziłem strukturę HTML i polecany produkt posiadał taki sam selektor, a znajdował się wyżej w strukturze HTML, przez co był pobierany.                                                                                                                                                                                                                                                                                                     |

| Pole              | Opis                                                                                                                                                                                                                                                  |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 13.11.26, Bartek Kluska                                                                                                                                                                                                                               |
| Narzędzie i model | Codex GPT-6.1-Sol                                                                                                                                                                                                                                     |
| Zadanie           | #5 Na podstawie analizy z poprzedniego prompta zleciłem agentowi dodanie do parsera sprawdzania dostępności produktu przez dostępne w jego danych pole, lecz nie dodawanie samego pola do końcowego JSONa (chcemy scrapować tylko produkty dostępne). |
| Co otrzymano      | Agent dodał sprawdzanie pola dostępności produktu przez co niedostępne produkty nie będą scrapowane oraz zaimplementował testy jednostkowe dotyczące dostępności. Samo pole nie trafia do wynikowego JSONa.                                           |
| Co było błędne    | Agent źle określił wartość statusu dostępności produktu.                                                                                                                                                                                              |
| Weryfikacja       | Poprawa wartości statusu dostępności produktu, uruchomienie scrapera i wyrywkowa kontrola kilku produktów.                                                                                                                                            |

| Pole              | Opis                                                                                                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 13.11.26, Bartek Kluska                                                                                                                                             |
| Narzędzie i model | Codex GPT-6.1-Sol                                                                                                                                                   |
| Zadanie           | #5 Zleciłem agentowi weryfikacje wyników, które otrzymaliśmy ze scrapera po poprawkach tzn. ilość i rozmiar zdjęć oraz ilość i poprawność zescrapowanych produktów. |
| Co otrzymano      | Agent przeanalizował wynikowe pliki _.json oraz _.jpg z katalogu scraper-results.                                                                                   |
| Co było błędne    | Dwa zdjęcia przekraczały dozwolony limit rozmiaru. W celu naprawy zleciłem agentowi narzucenie sztywnego limitu 300 KB.                                             |
| Weryfikacja       | Po zleconej poprawce oba pliki miały poprawny rozmiar. Sprawdziłem również ręcznie liczbę produktów, zdjęć, a także wyrywkowo poprawność niektórych rekordów.       |

---

## Wpis 6: Issue #12 i #13 – Import katalogu produktów, stanów magazynowych i obsługa Webservice API

| Pole | Opis |
| --- | --- |
| **Data i autor** | 19.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #12: Katalog produktów, Issue #13: Zarządzanie magazynem oraz Wymóg D2: Idempotentny import danych przez Webservice API |
| **Co otrzymano** | Architekturę komunikacji z Webservice API PrestaShopa, strukturę zapytań SQL aktywujących uprawnienia konta webservice bez konieczności konfiguracji przez UI przeglądarki, skrypt `shop/import_api.py` realizujący import kategorii, produktów i stanów magazynowych oraz automatyzację w `Makefile`. |
| **Co było błędne** | AI początkowo zahardkodowało klucz API w skrypcie Python oraz na sztywno ustawiło stawkę 23% VAT dla każdego produktu, ignorując fakt, że część produktów w `products.json` posiadała stawkę 8% lub 0%. Dodatkowo AI początkowo wgrywało tylko jedno zdjęcie okładki na produkt, pomijając wymóg posiadania co najmniej dwóch zdjęć dla 50 produktów. Błędy skorygowano poprzez usunięcie sekretu z kodu skryptu i przeniesienie go do pliku `.env`, dodanie dynamicznego mapowania stawek podatkowych oraz rozszerzenie logiki o wgrywanie pełnych galerii zdjęć. |
| **Weryfikacja** | Uruchomienie skryptu importu na żywym środowisku (1271 produktów, 157 kategorii, 1800 zdjęć), weryfikacja idempotencji (drugie uruchomienie zaktualizowało rekordy w 4 minuty dając dokładnie 0 duplikatów i 0 zduplikowanych zdjęć). Sprawdzenie metryk zapytaniami SQL w MariaDB: weryfikacja rozkładu stawek VAT (1256 prod. 23%, 6 prod. 8%, 9 prod. 0%), potwierdzenie stanów magazynowych 0–10 sztuk, obecności 10.8% produktów niedostępnych oraz 79 produktów z wieloma zdjęciami. Przetestowanie `gitleaks` potwierdzające 0 sekretów w kodzie. |

---

## Wpis 7: Issue #34 – Dystrybucja archiwum zdjęć w GitHub Releases i automatyzacja pobierania

| Pole | Opis |
| --- | --- |
| **Data i autor** | 21.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #34: Product Images Release – Dystrybucja archiwum zdjęć produktów poza repozytorium git i automatyzacja pobierania |
| **Co otrzymano** | Skrypt `scraper/download_release_images.py` realizujący automatyczne pobieranie archiwum `images.zip` z GitHub Releases (`v1.0.0-images`) z obsługą prywatnego repozytorium przez `gh` CLI, bezpośrednim REST API, rozpakowywaniem z weryfikacją sumy SHA-256 oraz fallbackiem do scrapera `scraper/images.py`. Dodano cel `images` do `Makefile` oraz powiązano go jako zależność `make import`. |
| **Co było błędne** | AI początkowo zaproponowało sztywny próg 1000 zdjęć oraz pobieranie bezpośrednim URL `curl` bez uwzględnienia prywatnego repozytorium. Skorygowano to poprzez weryfikację kompletności zdjęć per produkt na podstawie `products.json`, wdrożenie weryfikacji sumy kontrolnej SHA-256 z wbudowanym `hashlib.file_digest`, obsłużenie przekierowania 302 z GitHub API do AWS S3 dedykowanym `NoRedirectHandler` (zapobiegającym konfliktowi nagłówków autoryzacyjnych) oraz zaimplementowanie pełnego mechanizmu awaryjnego. |
| **Weryfikacja** | Opublikowanie wydania `v1.0.0-images` z plikiem `images.zip` na GitHubie. Przetestowanie wszystkich 5 metod pobierania w terminalu (cache lokalny, lokalny zip z SHA-256, GitHub CLI, bezpośrednie REST API oraz fallback scrapera) – każda zakończona sukcesem. Weryfikacja linterem `ruff` oraz `pyright`. |

---

## Wpis 8: Issue #32 – Backup i procedura Disaster Recovery

| Pole | Opis |
| --- | --- |
| **Data i autor** | 21.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #32: Backup and Disaster Recovery – Automatyzacja tworzenia kopii zapasowej i odtwarzania sklepu |
| **Co otrzymano** | Architekturę i wdrożenie procedury Disaster Recovery: skrypty `deploy/backup.py` i `deploy/restore.py`, bezstratną kompresję zrzutu MariaDB w locie do `database.sql.gz`, archiwizację zdjęć produktów w PrestaShop do `images.tar.gz`, eksport konfiguracji SQL, integrację poleceń `make backup` oraz `make restore` w `Makefile`, a także automatyczny benchmark czasu odzyskiwania z health checkiem. |
| **Co było błędne** | AI początkowo zaproponowało tworzenie pliku-znacznika `latest`, co było zbędną redundancją wobec naturalnego słownikowego i chronologicznego sortowania katalogów `backup_YYYYMMDD_HHMMSS`. W `restore.py` brakowało bezpośredniego importu `urllib.error`, co zgłaszał Pylance. Ponadto zrzut SQL pobierany przez PowerShell `>` generował kodowanie UTF-16 z bajtami `\0`, co naprawiono przez strumieniowanie w Pythonie. AI nie uwzględniło także faktu, że domyślny zrzut konfiguracji płatności nie zawierał definicji waluty PLN w tabelach `ps_currency*`, powodując błąd `LocalizationException` w panelu admina – skorygowano to dodając pełny eksport waluty PLN i czyszczenie cache `var/cache/prod` po odtworzeniu. |
| **Weryfikacja** | Wykonanie pełnego backupu bazy i zdjęć (1271 produktów, 1751 zdjęć) – czas wykonania 17 s, rozmiar 336 MB. Następnie przetestowanie Disaster Recovery (`make restore`): całkowite zresetowanie bazy, import dumpa gzip i rozpakowanie zdjęć zajęło 25 s, co z zapasem spełnia wymóg poniżej 10 minut. Weryfikacja spójności: 1271 odtworzonych produktów, status HTTP 200 OK na `https://localhost`, panel admina poprawnie zalogowany bez błędów waluty z aktywnym PLN. Weryfikacja jakości kodu linterem `ruff check deploy/`. |

---

## Promocje i warianty produktów

| Pole              | Opis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 23.11.2026, Bartek Kluska                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| Narzędzie i model | Codex GPT-6.2-Sol                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Zadanie           | #42 Znalezienie produktów występujących w różnych wariantach oraz przygotowanie odtwarzalnej konfiguracji promocji, cen zgodnie z dyrektywą Omnibus i wariantów produktów.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Co otrzymano      | Polecenie `make promotions`, które ustawia rabaty od 10% do 30% na 20 produktów oraz grupuje różne pojemności trzech modeli worków na śmieci i rozmiary dwóch doniczek. Każdy wariant zachowuje swój SKU i cenę oraz ma osobny stan magazynowy. Warianty są osobnymi pozycjami w katalogu i linkują do wspólnej karty z właściwą opcją. W wyborze wariantu worków widać pojemność i liczbę sztuk. Moduł `omnibus` wyświetla najniższą cenę z okresu przed obniżką do 30 dni wstecz. Po `make up` jedno `make init` instaluje moduł Omnibus, importuje katalog ze zdjęciami i ustawia rabaty oraz warianty. |
| Co było błędne    | Pierwsze odpalenie modułu nie podpięło go do sklepu. Po poprawce pierwszy zestaw wariantów rozróżniał liczbę opakowań np. worki na śmieci 60L można było wybrać 1 lub 2 opakowania (co było trochę trywialnym rozwiązaniem patrząc na to, że w naszej bazie produktów występują takie, które mają np. różną pojemność). Po weryfikacji zastąpiono go rzeczywistymi pojemnościami i rozmiarami. Agent również ustawił wszystkie promocję na 10%. Niby było to poprawne, ale nadal trochę nienaturalne, więc poprosiłem go o zmianę zakresu promocji na 10-30%. Agent również scalił dwa produkty o innych wariantach w jeden i dał na stronie produktu możliwość wyboru wariantu. Jest to niepopularna praktyka (produkty nadal powinny wyświetlać się oddzielnie, a na ich stronie powinno móc się zmienić wariant). |
| Weryfikacja       | Odpaliłem `make promotions` i sprawdziłem 20 cen Omnibus wśród promocyjnych produktów. Sprawdziłem również produkty z różnymi wariantami, czy po dodaniu do koszyka dwóch wariantów występują jako dwa oddzielne oraz czy mają ich własne stany magazynowe (a nie wspólne). Sprawdzono też osobne wyniki dla dwóch wersji Magnum Flex, otwieranie właściwego wariantu i zmianę opcji na karcie.                                                                                                                                                                                                                                                                                                                                                                                                                      |

---

## Testy E2E w Playwright

| Pole              | Opis                                                                                                                                                                                                                                                                                      |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 16.11.2026, Bartek Kluska                                                                                                                                                                                                                                                                 |
| Narzędzie i model | Codex GPT-6.1-Sol                                                                                                                                                                                                                                                                         |
| Zadanie           | #16 Implementacja testów E2E w Playwright (Python) na wzorowanej stronie. Testy miały obejmować podstawowe operacje (jeszcze bez finalizacji zamówienie, która zostanie dodana podczas testowania na naszej stronie)                                                                      |
| Co otrzymano      | Cztery testy obejmujące koszyk, wyszukiwanie, usuwanie produktów, zmianę ilości i szczegóły produktu. Otrzymano również raport HTML, zrzuty ekranu przy błędzie oraz komendę make e2e do odpalania testów. Zgodnie z prośbą testy nie obejmują jeszcze rejestracji, zamówień i płatności. |
| Co było błędne    | W pierwszej wersji testów problemy sprawiały błędne selektory i opóźnione pojawienie się banera cookies. Zbyt wczesne kliknięcie Dodaj do koszyka mogło otworzyć pusty koszyk.                                                                                                            |
| Weryfikacja       | Odpalenie testów i weryfikacja poprawności ich działania. Sprawdzenie raportu HTML. Testy przeszły poprawnie 4/4.                                                                                                                                                                         |

---

---

## Testy E2E w Playwright - migracja na nasz sklep oraz dodanie brakującego procesu składania zamówienia

| Pole              | Opis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 22.11.2026, Bartek Kluska                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Narzędzie i model | Codex GPT-6.2-Sol                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| Zadanie           | #16 Dostosowanie testów Playwright do naszego lokalnego sklepu i pokrycie testami całego procesu zakupowego i rejestracji klienta, który nie był wykonany podczas zrobienia testów na stronie oryginalnej.                                                                                                                                                                                                                                                                                                             |
| Co otrzymano      | Scenariusz obejmujący koszyk, rejestrację, dostawę, płatność za pobraniem, status zamówienia i pobranie faktury PDF.                                                                                                                                                                                                                                                                                                                                                                                                   |
| Co było błędne    | Pierwszy koszyk przekraczał limit wagi przewoźników (50kg). Po zmniejszeniu przedmiotów w koszyku (a co za tym idzie wagi koszyku) brakowało metod płatności. Import konfiguracji zmienił identyfikatory modułów, a sklep nadal szukał ich pod starymi numerami. Obie metody przywrócono tylko w lokalnej bazie testowej, a opis poprawki przekazano odpowiedzialnemu za to zadanie koledze z zespołu do osobnego PR. Nie był to stricte błąd AI, ale błąd podczas pracy z AI, które AI wskazało i lokalnie poprawiło. |
| Weryfikacja       | Uruchomiłem sklep na naszym lokalnym sklepie i testy przeszły 4/4. W pełnym scenariuszu test złożył zamówienie za pobraniem, zmienił jego status w panelu na Płatność zaakceptowana i zapisał fakturę PDF. Sprawdziłem również admin panel i pojawił się tam klient (Test Playwright) oraz jego zamówienia odpowiadające założeniom instrukcji projektowej.                                                                                                                                                            |

---

---

## Karty produktów z wariantami

| Pole | Opis |
| --- | --- |
| Data i autor | 23.11.2026, Bartek Kluska |
| Narzędzie i model | Codex, GPT-6 |
| Zadanie | Przywrócenie osobnych kart dla produktów z tej samej serii, które różnią się pojemnością, liczbą sztuk lub wymiarem. |
| Co otrzymano | Każdy SKU korzysta ze swojej karty, a wybór opcji prowadzi do odpowiadającej karty. W katalogu przy cenie widać pojemność i liczbę sztuk albo rozmiar. `make promotions` przywraca dane scrapera w sklepie skonfigurowanym w poprzedni sposób i przenosi ilości z koszyków na właściwe SKU. |
| Co było błędne | Poprzedni skrypt zastępował nazwę i opis pierwszego produktu opisem całej grupy. Inne produkty z grupy przekierowywały na tę samą kartę, chociaż każdy miał osobny rekord w danych scrapera. |
| Weryfikacja | Sprawdzono 11 kart z pięciu serii oraz obie opcje Magnum Flex na sklepie. Potwierdzono osobne adresy, nazwy, opisy i ilości z poprzednich wariantów. Test migracji przeniósł pozycje w koszyku, a ponowne `make promotions` zachowało dane. Po review sprawdzono seed bez pliku JSON na świeżym sklepie oraz migrację zamówienia ze starymi wariantami. Pozycje zamówienia wskazują właściwe SKU, a przywrócenie sztuki do magazynu zmienia stan wyłącznie tego produktu. |

---

## Trafność wyszukiwania produktów

| Pole              | Opis                                                                                                                                                                                                                                                                                                                                                                      |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Data i autor      | 23.11.2026, Bartek Kluska                                                                                                                                                                                                                                                                                                                                                 |
| Narzędzie i model | Codex GPT-6.2-Sol                                                                                                                                                                                                                                                                                                                                                         |
| Zadanie           | Poprawa wyszukiwania nazw produktów zawierających pojemności, rozmiary i liczbę sztuk.                                                                                                                                                                                                                                                                                    |
| Co otrzymano      | Wyszukiwarka PrestaShop uwzględnia dwuznakowe hasła i rozpoznaje liczby z jednostkami niezależnie od spacji. `make search` przebudowuje indeks, a `make init` wywołuje ten target po imporcie katalogu i ustawieniu promocji.                                                                                                                                        |
| Co było błędne    | PrestaShop pomijał liczby `60` i `40` w zapytaniu o worki ze względu na minimalną długość hasła. Obniżenie progu nadal zwracało dwie ścierki, bo te liczby występowały w ich opisach jako procenty składu. Powiązano liczby z jednostkami, żeby `60 L` było szukane jako `60l`.                                                                                           |
| Weryfikacja       | Zapytanie np. `Jan Niezbędny 60 L, 40 szt.` spadło z 90 wyników do 3 pasujących produktów. Zapis bez polskich znaków i zapis `60l 40szt` zwróciły te same produkty. Sprawdzono też zapytanie ogólne i wyszukiwanie po SKU. Po review sprawdzono 11 jednostek technicznych, m.in. `2200 W`, `144 Hz` i `128 GB`, w zapytaniach ze spacją i bez niej. Gdy wyszukujemy worki marki np. `Jan Niezbędny` to faktycznie wyświetlają się same worki, a nie także inne produkty tak jak to było wcześniej. |

---

## Wpis 9: Issue #44 – Kompleksowa dokumentacja README, automatyzacja inicjalizacji sklepu i stabilizacja środowiska

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #44: Dokumentacja README, pełna automatyzacja procesu uruchomienia sklepu (one-command init), spójność bazodanowa płatności/dostawców oraz utwardzenie Disaster Recovery |
| **Co otrzymano** | Pełną dokumentację `README.md` (instalacja 2 komendami, architektura, linki, testy Playwright E2E, polityka zero sekretów w git, DR), stały adres panelu admina (`PS_FOLDER_ADMIN: admin-dev` w `deploy/compose.yaml`), idempotentny i niedestrukcyjny skrypt `deploy/payment_config.sql` wiążący płatności (przelew i pobranie) z PLN, Polską, grupami klientów i kurierami DPD/InPost, automatyczną konfigurację SMTP dla Mailpit (`PS_MAIL_METHOD=2`, port 1025), synchronizację danych bankowych ze stroną CMS, wdrożenie zasady najmniejszych uprawnień (PoLP - D2) w `deploy/init-webservice.sql`, krok przywracania konfiguracji SQL i `.env.example` w `deploy/restore.py` (D4) oraz automatyczne wykrywanie `docker.exe` na Windows w `Makefile`. |
| **Co było błędne** | AI w zapytaniu SQL użyło słowa kluczowego `precision` bez ucieczki w backticki, co wywołało błąd składniowy MariaDB. Ponadto AI początkowo nie wykryło, że wywołanie `docker` z Git Bash/MSYS na Windows uruchamiało skrypt-wrapper psujący flagi poleceń (np. `-f`), co naprawiono wykrywaniem `docker.exe`. W kontenerze PrestaShop generował się błąd HTTP 500 z powodu braku uprawnień procesu Apache (`www-data`) do katalogu `var/cache/prod` utworzonego przez proces roota CLI – skorygowano to wymuszeniem `chown -R www-data:www-data` i `chmod -R 777` w `Makefile` i `restore.py`. Ponadto wysyłka testowego maila w back-office rzucała błędem z powodu braku sendmaila w kontenerze, co rozwiązano automatyczną konfiguracją SMTP Mailpit w bazie. |
| **Weryfikacja** | Przetestowanie pełnej ścieżki clean-slate od zera (`docker compose down -v` i `make init`): czas instalacji wyniósł 14.30 min (poniżej limitu 15 min z kryterium W3 [K]), poprawny import 1271 produktów i kategorii. Weryfikacja w przeglądarce: widoczny baner cookies Dominika, obie metody płatności (przelew i pobranie) widoczne i wybieralne w checkout dla DPD i InPost, złożenie zamówienia zakończone sukcesem i mail transakcyjny odebrany w Mailpit (`http://localhost:8025`). Przetestowanie Disaster Recovery (`make restore`): pełne odtworzenie bazy, zdjęć i konfiguracji w 24.40 s (limit 10 min z D4) z bezbłędnym dostępem do panelu admina bez HTTP 500. |

---

## Wpis 10: Issue #44 – Optymalizacja wydajności importu (wielowątkowość), konfiguracja Gitleaks i automatyzacja weryfikacji metryk

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #44: Optymalizacja czasu importu katalogu, wdrożenie reguł skanowania sekretów oraz automatyzacja weryfikacji metryk projektowych |
| **Co otrzymano** | Architekturę równoległego wgrywania zdjęć z użyciem puli 4 wątków roboczych (`concurrent.futures.ThreadPoolExecutor`) i blokadą wątkową statystyk w `shop/import_api.py`, konfigurację reguł `.gitleaks.toml` ignorującą tokeny analityczne w testowych plikach HTML scrapera, a także skrypt `deploy/verify_metrics.py` i cel `make verify` (zintegrowany automatycznie z `make init`), weryfikujący zapytaniami SQL w MariaDB wszystkie progi z kolumny „Sposób pomiaru” z oficjalnych wymagań. |
| **Co było błędne** | AI początkowo zaproponowało użycie `getattr(sys.stdout, "reconfigure")`, co zgłaszał linter Ruff (reguła `B009`), natomiast bezpośrednie wywołanie powodowało błąd typowania Pylance (`TextIO` nie deklaruje metody `reconfigure`). Skorygowano to poprzez zawężenie typu `isinstance(sys.stdout, io.TextIOWrapper)`. Ponadto w zapytaniu SQL weryfikującym przewoźników AI użyło sztywnego warunku `IN ('DPD', 'InPost')`, co dało wynik 0 z powodu pełnych nazw w bazie (`DPD Kurier`, `InPost Paczkomat 24/7`) – skorygowano to dopasowaniem wzorcem `LIKE`. |
| **Weryfikacja** | Przeprowadzenie pełnego importu katalogu na czystym sklepie: czas wgrywania 1271 produktów i 1776 zdjęć spadł z ok. 12 minut do **7.06 min (423 s)**, redukując łączny czas inicjalizacji do ~8.5 minuty (bezpieczny margines poniżej 15 min z W3 [K]). Test idempotencji (drugie uruchomienie `make import`): 1272 produkty zaktualizowane, 0 utworzonych duplikatów i 0 wgranych powtórnie zdjęć w czasie 4.24 min (spełnienie D2). Uruchomienie skanera `gitleaks` na całej historii: `no leaks found` (0 znalezisk, kod wyjścia 0). Uruchomienie `make verify`: potwierdzenie statusu `[PASS]` dla wszystkich 7 metryk z tabeli wymagań. |

<!--
## Wpis X:

| Pole | Opis |
| --- | --- |
| **Data i autor** |  |
| **Narzędzie i model** |  |
| **Zadanie** |  |
| **Co otrzymano** |  |
| **Co było błędne** |  |
| **Weryfikacja** |  |

---
-->
