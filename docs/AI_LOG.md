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

## Wpis 5: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 7.11.26, Bartek Kluska |
| **Narzędzie i model** | Claude Code Sonnet 5.5 |
| **Zadanie** | #5 Ignorowanie plików środowiskowych w .gitignore |
| **Co otrzymano** | Pliki przestały być śledzone przez gita |
| **Co było błędne** | N/A |
| **Weryfikacja** | Sprawdzenie pliku .gitignore |

---

## Wpis 6: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 7.11.26, Bartek Kluska |
| **Narzędzie i model** | Claude Code Sonnet 5.5 |
| **Zadanie** | #5 Zleciłem agentowi uzupełnienie scrapera i parsera do końca, ponieważ struktura HTML produktu była skomplikowana i zajęłaby sporo czasu |
| **Co otrzymano** | Claude uzupełnił kod scrapera i parsera, który scrapował produkty z wymienionych przeze mnie kategorii, a następnie zapisywał je do plików JSON |
| **Co było błędne** | Kod agenta wykorzystywał scrapowanie równoległe, co w tym przypadku jest overkillem. |
| **Weryfikacja** | Weryfikacja wygenerowanego kodu oraz odpalenie scrapera. |

---

## Wpis 7: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 7.11.26, Bartek Kluska |
| **Narzędzie i model** | Claude Code Sonnet 5.5 |
| **Zadanie** | #5 Zleciłem agentowi napisanie testów jednostkowych do scrapera używając pytest. |
| **Co otrzymano** | Claude stworzył testy jednostkowe. |
| **Co było błędne** | N/A |
| **Weryfikacja** | Sprawdzenie kodu testów oraz uruchomienie ich. Wszystkie testy przeszły. |

---

## Wpis 8: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 13.11.26, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.1-Sol |
| **Zadanie** | #5 Sprawdziłem wyrywkowo produkt, który okazał się być niedostępny. Następnie sprawdziłem jego cały rekord i okazało się, że zescrapowane informacje są niepoprawne (scraper pobierał dane polecanego wyżej produktu). Zleciłem agentowi przeanalizowanie tej sytuacji. |
| **Co otrzymano** | Mimo tego, że produkt był niedostępny nadal się wyświetlał a jego strona zwracała HTTP 200, dlatego scraper uznawał, że produkt jest dostępny. Produkt polecany, który znajdował się nad naszym docelowym, lecz niedostępnym produktem, posiadał taki sam selektor .product-description, przez co scraper zczytywał dane polecanego produktu. Agent zasugerował skorzystanie z dostępnego pola w danych produktu mówiącego o jego dostępności. |
| **Co było błędne** | N/A |
| **Weryfikacja** | Sprawdziłem strukturę HTML i polecany produkt posiadał taki sam selektor, a znajdował się wyżej w strukturze HTML, przez co był pobierany. |

---

## Wpis 9: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 13.11.26, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.1-Sol |
| **Zadanie** | #5 Na podstawie analizy z poprzedniego prompta zleciłem agentowi dodanie do parsera sprawdzania dostępności produktu przez dostępne w jego danych pole, lecz nie dodawanie samego pola do końcowego JSONa (chcemy scrapować tylko produkty dostępne). |
| **Co otrzymano** | Agent dodał sprawdzanie pola dostępności produktu przez co niedostępne produkty nie będą scrapowane oraz zaimplementował testy jednostkowe dotyczące dostępności. Samo pole nie trafia do wynikowego JSONa. |
| **Co było błędne** | Agent źle określił wartość statusu dostępności produktu. |
| **Weryfikacja** | Poprawa wartości statusu dostępności produktu, uruchomienie scrapera i wyrywkowa kontrola kilku produktów. |

---

## Wpis 10: Issue #5 – Scraper produktów i weryfikacja danych

| Pole | Opis |
| --- | --- |
| **Data i autor** | 13.11.26, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.1-Sol |
| **Zadanie** | #5 Zleciłem agentowi weryfikacje wyników, które otrzymaliśmy ze scrapera po poprawkach tzn. ilość i rozmiar zdjęć oraz ilość i poprawność zescrapowanych produktów. |
| **Co otrzymano** | Agent przeanalizował wynikowe pliki _.json oraz _.jpg z katalogu scraper-results. |
| **Co było błędne** | Dwa zdjęcia przekraczały dozwolony limit rozmiaru. W celu naprawy zleciłem agentowi narzucenie sztywnego limitu 300 KB. |
| **Weryfikacja** | Po zleconej poprawce oba pliki miały poprawny rozmiar. Sprawdziłem również ręcznie liczbę produktów, zdjęć, a także wyrywkowo poprawność niektórych rekordów. |

---

## Wpis 11: Issue #12 i #13 – Import katalogu produktów, stanów magazynowych i obsługa Webservice API

| Pole | Opis |
| --- | --- |
| **Data i autor** | 19.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #12: Katalog produktów, Issue #13: Zarządzanie magazynem oraz Wymóg D2: Idempotentny import danych przez Webservice API |
| **Co otrzymano** | Architekturę komunikacji z Webservice API PrestaShopa, strukturę zapytań SQL aktywujących uprawnienia konta webservice bez konieczności konfiguracji przez UI przeglądarki, skrypt `shop/import_api.py` realizujący import kategorii, produktów i stanów magazynowych oraz automatyzację w `Makefile`. |
| **Co było błędne** | AI początkowo zahardkodowało klucz API w skrypcie Python oraz na sztywno ustawiło stawkę 23% VAT dla każdego produktu, ignorując fakt, że część produktów w `products.json` posiadała stawkę 8% lub 0%. Dodatkowo AI początkowo wgrywało tylko jedno zdjęcie okładki na produkt, pomijając wymóg posiadania co najmniej dwóch zdjęć dla 50 produktów. Błędy skorygowano poprzez usunięcie sekretu z kodu skryptu i przeniesienie go do pliku `.env`, dodanie dynamicznego mapowania stawek podatkowych oraz rozszerzenie logiki o wgrywanie pełnych galerii zdjęć. |
| **Weryfikacja** | Uruchomienie skryptu importu na żywym środowisku (1271 produktów, 157 kategorii, 1800 zdjęć), weryfikacja idempotencji (drugie uruchomienie zaktualizowało rekordy w 4 minuty dając dokładnie 0 duplikatów i 0 zduplikowanych zdjęć). Sprawdzenie metryk zapytaniami SQL w MariaDB: weryfikacja rozkładu stawek VAT (1256 prod. 23%, 6 prod. 8%, 9 prod. 0%), potwierdzenie stanów magazynowych 0–10 sztuk, obecności 10.8% produktów niedostępnych oraz 79 produktów z wieloma zdjęciami. Przetestowanie `gitleaks` potwierdzające 0 sekretów w kodzie. |

---

## Wpis 12: Issue #34 – Dystrybucja archiwum zdjęć w GitHub Releases i automatyzacja pobierania

| Pole | Opis |
| --- | --- |
| **Data i autor** | 21.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #34: Product Images Release – Dystrybucja archiwum zdjęć produktów poza repozytorium git i automatyzacja pobierania |
| **Co otrzymano** | Skrypt `scraper/download_release_images.py` realizujący automatyczne pobieranie archiwum `images.zip` z GitHub Releases (`v1.0.0-images`) z obsługą prywatnego repozytorium przez `gh` CLI, bezpośrednim REST API, rozpakowywaniem z weryfikacją sumy SHA-256 oraz fallbackiem do scrapera `scraper/images.py`. Dodano cel `images` do `Makefile` oraz powiązano go jako zależność `make import`. |
| **Co było błędne** | AI początkowo zaproponowało sztywny próg 1000 zdjęć oraz pobieranie bezpośrednim URL `curl` bez uwzględnienia prywatnego repozytorium. Skorygowano to poprzez weryfikację kompletności zdjęć per produkt na podstawie `products.json`, wdrożenie weryfikacji sumy kontrolnej SHA-256 z wbudowanym `hashlib.file_digest`, obsłużenie przekierowania 302 z GitHub API do AWS S3 dedykowanym `NoRedirectHandler` (zapobiegającym konfliktowi nagłówków autoryzacyjnych) oraz zaimplementowanie pełnego mechanizmu awaryjnego. |
| **Weryfikacja** | Opublikowanie wydania `v1.0.0-images` z plikiem `images.zip` na GitHubie. Przetestowanie wszystkich 5 metod pobierania w terminalu (cache lokalny, lokalny zip z SHA-256, GitHub CLI, bezpośrednie REST API oraz fallback scrapera) – każda zakończona sukcesem. Weryfikacja linterem `ruff` oraz `pyright`. |

---

## Wpis 13: Issue #32 – Backup i procedura Disaster Recovery

| Pole | Opis |
| --- | --- |
| **Data i autor** | 21.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #32: Backup and Disaster Recovery – Automatyzacja tworzenia kopii zapasowej i odtwarzania sklepu |
| **Co otrzymano** | Architekturę i wdrożenie procedury Disaster Recovery: skrypty `deploy/backup.py` i `deploy/restore.py`, bezstratną kompresję zrzutu MariaDB w locie do `database.sql.gz`, archiwizację zdjęć produktów w PrestaShop do `images.tar.gz`, eksport konfiguracji SQL, integrację poleceń `make backup` oraz `make restore` w `Makefile`, a także automatyczny benchmark czasu odzyskiwania z health checkiem. |
| **Co było błędne** | AI początkowo zaproponowało tworzenie pliku-znacznika `latest`, co było zbędną redundancją wobec naturalnego słownikowego i chronologicznego sortowania katalogów `backup_YYYYMMDD_HHMMSS`. W `restore.py` brakowało bezpośredniego importu `urllib.error`, co zgłaszał Pylance. Ponadto zrzut SQL pobierany przez PowerShell `>` generował kodowanie UTF-16 z bajtami `\0`, co naprawiono przez strumieniowanie w Pythonie. AI nie uwzględniło także faktu, że domyślny zrzut konfiguracji płatności nie zawierał definicji waluty PLN w tabelach `ps_currency*`, powodując błąd `LocalizationException` w panelu admina – skorygowano to dodając pełny eksport waluty PLN i czyszczenie cache `var/cache/prod` po odtworzeniu. |
| **Weryfikacja** | Wykonanie pełnego backupu bazy i zdjęć (1271 produktów, 1751 zdjęć) – czas wykonania 17 s, rozmiar 336 MB. Następnie przetestowanie Disaster Recovery (`make restore`): całkowite zresetowanie bazy, import dumpa gzip i rozpakowanie zdjęć zajęło 25 s, co z zapasem spełnia wymóg poniżej 10 minut. Weryfikacja spójności: 1271 odtworzonych produktów, status HTTP 200 OK na `https://localhost`, panel admina poprawnie zalogowany bez błędów waluty z aktywnym PLN. Weryfikacja jakości kodu linterem `ruff check deploy/`. |

---

## Wpis 14: Promocje i warianty produktów

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.2-Sol |
| **Zadanie** | #42 Znalezienie produktów występujących w różnych wariantach oraz przygotowanie odtwarzalnej konfiguracji promocji, cen zgodnie z dyrektywą Omnibus i wariantów produktów. |
| **Co otrzymano** | Polecenie `make promotions`, które ustawia rabaty od 10% do 30% na 20 produktów oraz grupuje różne pojemności trzech modeli worków na śmieci i rozmiary dwóch doniczek. Każdy wariant zachowuje swój SKU i cenę oraz ma osobny stan magazynowy. Warianty są osobnymi pozycjami w katalogu i linkują do wspólnej karty z właściwą opcją. W wyborze wariantu worków widać pojemność i liczbę sztuk. Moduł `omnibus` wyświetla najniższą cenę z okresu przed obniżką do 30 dni wstecz. Po `make up` jedno `make init` instaluje moduł Omnibus, importuje katalog ze zdjęciami i ustawia rabaty oraz warianty. |
| **Co było błędne** | Pierwsze odpalenie modułu nie podpięło go do sklepu. Po poprawce pierwszy zestaw wariantów rozróżniał liczbę opakowań np. worki na śmieci 60L można było wybrać 1 lub 2 opakowania (co było trochę trywialnym rozwiązaniem patrząc na to, że w naszej bazie produktów występują takie, które mają np. różną pojemność). Po weryfikacji zastąpiono go rzeczywistymi pojemnościami i rozmiarami. Agent również ustawił wszystkie promocję na 10%. Niby było to poprawne, ale nadal trochę nienaturalne, więc poprosiłem go o zmianę zakresu promocji na 10-30%. Agent również scalił dwa produkty o innych wariantach w jeden i dał na stronie produktu możliwość wyboru wariantu. Jest to niepopularna praktyka (produkty nadal powinny wyświetlać się oddzielnie, a na ich stronie powinno móc się zmienić wariant). |
| **Weryfikacja** | Odpaliłem `make promotions` i sprawdziłem 20 cen Omnibus wśród promocyjnych produktów. Sprawdziłem również produkty z różnymi wariantami, czy po dodaniu do koszyka dwóch wariantów występują jako dwa oddzielne oraz czy mają ich własne stany magazynowe (a nie wspólne). Sprawdzono też osobne wyniki dla dwóch wersji Magnum Flex, otwieranie właściwego wariantu i zmianę opcji na karcie. |

---

## Wpis 15: Testy E2E w Playwright

| Pole | Opis |
| --- | --- |
| **Data i autor** | 16.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.1-Sol |
| **Zadanie** | #16 Implementacja testów E2E w Playwright (Python) na wzorowanej stronie. Testy miały obejmować podstawowe operacje (jeszcze bez finalizacji zamówienie, która zostanie dodana podczas testowania na naszej stronie) |
| **Co otrzymano** | Cztery testy obejmujące koszyk, wyszukiwanie, usuwanie produktów, zmianę ilości i szczegóły produktu. Otrzymano również raport HTML, zrzuty ekranu przy błędzie oraz komendę make e2e do odpalania testów. Zgodnie z prośbą testy nie obejmują jeszcze rejestracji, zamówień i płatności. |
| **Co było błędne** | W pierwszej wersji testów problemy sprawiały błędne selektory i opóźnione pojawienie się banera cookies. Zbyt wczesne kliknięcie Dodaj do koszyka mogło otworzyć pusty koszyk. |
| **Weryfikacja** | Odpalenie testów i weryfikacja poprawności ich działania. Sprawdzenie raportu HTML. Testy przeszły poprawnie 4/4. |

---

## Wpis 16: Testy E2E w Playwright - migracja na nasz sklep oraz dodanie brakującego procesu składania zamówienia

| Pole | Opis |
| --- | --- |
| **Data i autor** | 22.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.2-Sol |
| **Zadanie** | #16 Dostosowanie testów Playwright do naszego lokalnego sklepu i pokrycie testami całego procesu zakupowego i rejestracji klienta, który nie był wykonany podczas zrobienia testów na stronie oryginalnej. |
| **Co otrzymano** | Scenariusz obejmujący koszyk, rejestrację, dostawę, płatność za pobraniem, status zamówienia i pobranie faktury PDF. |
| **Co było błędne** | Pierwszy koszyk przekraczał limit wagi przewoźników (50kg). Po zmniejszeniu przedmiotów w koszyku (a co za tym idzie wagi koszyku) brakowało metod płatności. Import konfiguracji zmienił identyfikatory modułów, a sklep nadal szukał ich pod starymi numerami. Obie metody przywrócono tylko w lokalnej bazie testowej, a opis poprawki przekazano odpowiedzialnemu za to zadanie koledze z zespołu do osobnego PR. Nie był to stricte błąd AI, ale błąd podczas pracy z AI, które AI wskazało i lokalnie poprawiło. |
| **Weryfikacja** | Uruchomiłem sklep na naszym lokalnym sklepie i testy przeszły 4/4. W pełnym scenariuszu test złożył zamówienie za pobraniem, zmienił jego status w panelu na Płatność zaakceptowana i zapisał fakturę PDF. Sprawdziłem również admin panel i pojawił się tam klient (Test Playwright) oraz jego zamówienia odpowiadające założeniom instrukcji projektowej. |

---

## Wpis 17: Karty produktów z wariantami

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.2-Sol |
| **Zadanie** | Przywrócenie osobnych kart dla tych samych produktów o innej liczbie sztuk/pojemności/rozmiarze. |
| **Co otrzymano** | Każdy wariant ma własną kartę z nazwą, opisem i zdjęciem ze scrapera. Wybranie innej opcji otwiera jej kartę. W katalogu obok ceny widać rozmiar albo pojemność i liczbę sztuk. make promotions przenosi też produkty ze starych koszyków na właściwe warianty. |
| **Co było błędne** | Wcześniej np. worki 35 l i 60 l prowadziły do jednej karty „Worki na śmieci”, więc obie wersje miały ten sam opis i zdjęcie, mimo że w danych ze scrapera były osobnymi produktami. |
| **Weryfikacja** | Sprawdziłem 11 produktów z pięciu modeli produktów. Każdy miał własny adres, nazwę, opis i stan magazynowy. Pozycje wskazywały właściwe warianty, a po dodaniu do koszyka były rozróżnialne. |

---

## Wpis 18: Trafność wyszukiwania produktów

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.2-Sol |
| **Zadanie** | Poprawa wyszukiwania nazw produktów zawierających pojemności, rozmiary i liczbę sztuk. |
| **Co otrzymano** | Wyszukiwarka PrestaShop uwzględnia dwuznakowe hasła i rozpoznaje liczby z jednostkami niezależnie od spacji. `make search` przebudowuje indeks, a `make init` wywołuje ten target po imporcie katalogu i ustawieniu promocji. |
| **Co było błędne** | PrestaShop pomijał liczby `60` i `40` w zapytaniu o worki ze względu na minimalną długość hasła. Obniżenie progu nadal zwracało dwie ścierki, bo te liczby występowały w ich opisach jako procenty składu. Powiązano liczby z jednostkami, żeby `60 L` było szukane jako `60l`. |
| **Weryfikacja** | Zapytanie np. `Jan Niezbędny 60 L, 40 szt.` spadło z 90 wyników do 3 pasujących produktów. Zapis bez polskich znaków i zapis `60l 40szt` zwróciły te same produkty. Sprawdzono też zapytanie ogólne i wyszukiwanie po SKU. Po review sprawdzono 11 jednostek technicznych, m.in. `2200 W`, `144 Hz` i `128 GB`, w zapytaniach ze spacją i bez niej. Gdy wyszukujemy worki marki np. `Jan Niezbędny` to faktycznie wyświetlają się same worki, a nie także inne produkty tak jak to było wcześniej. |

---

## Wpis 19: Issue #44 – Kompleksowa dokumentacja README, automatyzacja inicjalizacji sklepu i stabilizacja środowiska

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #44: Dokumentacja README, pełna automatyzacja procesu uruchomienia sklepu (one-command init), spójność bazodanowa płatności/dostawców oraz utwardzenie Disaster Recovery |
| **Co otrzymano** | Pełną dokumentację `README.md` (instalacja 2 komendami, architektura, linki, testy Playwright E2E, polityka zero sekretów w git, DR), stały adres panelu admina (`PS_FOLDER_ADMIN: admin-dev` w `deploy/compose.yaml`), idempotentny i niedestrukcyjny skrypt `deploy/payment_config.sql` wiążący płatności (przelew i pobranie) z PLN, Polską, grupami klientów i kurierami DPD/InPost, automatyczną konfigurację SMTP dla Mailpit (`PS_MAIL_METHOD=2`, port 1025), synchronizację danych bankowych ze stroną CMS, wdrożenie zasady najmniejszych uprawnień (PoLP - D2) w `deploy/init-webservice.sql`, krok przywracania konfiguracji SQL i `.env.example` w `deploy/restore.py` (D4) oraz automatyczne wykrywanie `docker.exe` na Windows w `Makefile`. |
| **Co było błędne** | AI w zapytaniu SQL użyło słowa kluczowego `precision` bez ucieczki w backticki, co wywołało błąd składniowy MariaDB. Ponadto AI początkowo nie wykryło, że wywołanie `docker` z Git Bash/MSYS na Windows uruchamiało skrypt-wrapper psujący flagi poleceń (np. `-f`), co naprawiono wykrywaniem `docker.exe`. W kontenerze PrestaShop generował się błąd HTTP 500 z powodu braku uprawnień procesu Apache (`www-data`) do katalogu `var/cache/prod` utworzonego przez proces roota CLI – skorygowano to wymuszeniem `chown -R www-data:www-data` i `chmod -R 777` w `Makefile` i `restore.py`. Ponadto wysyłka testowego maila w back-office rzucała błędem z powodu braku sendmaila w kontenerze, co rozwiązano automatyczną konfiguracją SMTP Mailpit w bazie. |
| **Weryfikacja** | Przetestowanie pełnej ścieżki clean-slate od zera (`docker compose down -v` i `make init`): czas instalacji wyniósł 14.30 min (poniżej limitu 15 min z kryterium W3 [K]), poprawny import 1271 produktów i kategorii. Weryfikacja w przeglądarce: widoczny baner cookies Dominika, obie metody płatności (przelew i pobranie) widoczne i wybieralne w checkout dla DPD i InPost, złożenie zamówienia zakończone sukcesem i mail transakcyjny odebrany w Mailpit (`http://localhost:8025`). Przetestowanie Disaster Recovery (`make restore`): pełne odtworzenie bazy, zdjęć i konfiguracji w 24.40 s (limit 10 min z D4) z bezbłędnym dostępem do panelu admina bez HTTP 500. |

---

## Wpis 20: Issue #44 – Optymalizacja wydajności importu (wielowątkowość), konfiguracja Gitleaks i automatyzacja weryfikacji metryk

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #44: Optymalizacja czasu importu katalogu, wdrożenie reguł skanowania sekretów oraz automatyzacja weryfikacji metryk projektowych |
| **Co otrzymano** | Architekturę równoległego wgrywania zdjęć z użyciem puli 4 wątków roboczych (`concurrent.futures.ThreadPoolExecutor`) i blokadą wątkową statystyk w `shop/import_api.py`, konfigurację reguł `.gitleaks.toml` ignorującą tokeny analityczne w testowych plikach HTML scrapera, a także skrypt `deploy/verify_metrics.py` i cel `make verify` (zintegrowany automatycznie z `make init`), weryfikujący zapytaniami SQL w MariaDB wszystkie progi z kolumny „Sposób pomiaru” z oficjalnych wymagań. |
| **Co było błędne** | AI początkowo zaproponowało użycie `getattr(sys.stdout, "reconfigure")`, co zgłaszał linter Ruff (reguła `B009`), natomiast bezpośrednie wywołanie powodowało błąd typowania Pylance (`TextIO` nie deklaruje metody `reconfigure`). Skorygowano to poprzez zawężenie typu `isinstance(sys.stdout, io.TextIOWrapper)`. Ponadto w zapytaniu SQL weryfikującym przewoźników AI użyło sztywnego warunku `IN ('DPD', 'InPost')`, co dało wynik 0 z powodu pełnych nazw w bazie (`DPD Kurier`, `InPost Paczkomat 24/7`) – skorygowano to dopasowaniem wzorcem `LIKE`. |
| **Weryfikacja** | Przeprowadzenie pełnego importu katalogu na czystym sklepie: czas wgrywania 1271 produktów i 1776 zdjęć spadł z ok. 12 minut do **7.06 min (423 s)**, redukując łączny czas inicjalizacji do ~8.5 minuty (bezpieczny margines poniżej 15 min z W3 [K]). Test idempotencji (drugie uruchomienie `make import`): 1272 produkty zaktualizowane, 0 utworzonych duplikatów i 0 wgranych powtórnie zdjęć w czasie 4.24 min (spełnienie D2). Uruchomienie skanera `gitleaks` na całej historii: `no leaks found` (0 znalezisk, kod wyjścia 0). Uruchomienie `make verify`: potwierdzenie statusu `[PASS]` dla wszystkich 7 metryk z tabeli wymagań. |

---

## Wpis 21: Architektura scrapera katalogu produktów

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Bartek Kluska |
| **Narzędzie i model** | Codex GPT-6.2-Sol |
| **Zadanie** | Opisałem agentowi, jak działa scraper i dlaczego wybrałem Pythona oraz biblioteki, z którymi już pracowałem. Poprosiłem go o ułożenie tego opisu według naszego wzorca ADR. |
| **Co otrzymano** | Agent uporządkował mój opis i zapisał go w `docs/adr/0002-product-catalog-scraper.md`, wzorując się na ADR o Nginx, który zrobił Michał. |
| **Co było błędne** | Pierwsza nazwa pliku była po polsku. Po mojej uwadze agent zmienił ją na angielską, zachowując polską treść, by nazewnictwo było spójne. |
| **Weryfikacja** | Agent porównał opis z kodem scrapera i importera oraz sprawdził układ dokumentu względem ADR o Nginx. |

---

## Wpis 22: Issue #30 – D1. Wygląd sklepu i dostępność cyfrowa (Child Theme TopMarket.pl dla Domitek)

| Pole | Opis |
| --- | --- |
| **Data i autor** | 23.11.2026, Dominik Szwed |
| **Narzędzie i model** | Antigravity (Gemini 4 Hydrogen) |
| **Zadanie** | Issue #30: Implementacja motywu potomnego `shop/themes/topmarket-child/` (Wariant A – TopMarket.pl), responsywność 360 px, dostępność Lighthouse >= 85, automatyzacja wdrożenia oraz ADR 0002. |
| **Co otrzymano** | Utworzono motyw potomny `topmarket-child` (`parent: classic`) ze stylami `custom.css`, skryptem `custom.js` i nadpisaniami szablonów (header z jednym `#search_widget`, 4-kolumnowe mega-menu, strona główna z banerami < 300 KB, karta produktu z hookami `omnibus`, koszyk i CMS). Dodano też `deploy/storefront_appearance.sql`, bind-mount w `deploy/compose.yaml`, cel `theme:`/`storefront:` w `Makefile` oraz `docs/adr/0002-storefront-theme-deployment.md`. |
| **Co było błędne** | AI początkowo użyło progów darmowej dostawy `149 zł`, duplikowało `#search_widget` i prefiksy `/pl/`, pominęło hooki modułu `omnibus` w `product.tpl` oraz klasę `.account` i `{$customerName}` w `ps_customersignin.tpl`. Dodatkowo `storefront_appearance.sql` dopisywał duplikaty w `ps_linksmenutop_lang` z linkiem `BESTSELLERY` (404 przy braku zamówień), a przekierowanie SQL przez stdin w PowerShellu psuło kodowanie `zł` na `zĹ,`. Wszystkie te problemy skorygowano po review i testach E2E (podmieniono też link na `NOWOŚCI` → `/nowe-produkty`, przeniesiono SQL po `theme:enable` i usunięto atrapy PayPo/wishlist). |
| **Weryfikacja** | Audyt Google Lighthouse: Desktop — **Performance 90**, **Accessibility 96**, **Best Practices 100**, **SEO 92**; Mobile — **Accessibility 93**, **CLS 0**. Sprawdzono też Axe-Core (95.9%–100%), widok 360 px i 1440 px (0 błędów JS, brak przewijania poziomego), poprawne UTF-8 (`zł`), pojedynczy `#search_widget` w DOM oraz przejście kroków wyszukiwania i rejestracji w `make e2e`. |

---

## Refleksja końcowa (Michał Łysiak)

### 1. Gdzie AI realnie przyspieszyło pracę
* **Szybkie prototypowanie i kod powtarzalny:** AI znacząco przyspieszyło mi pisanie skryptów integracyjnych (`shop/import_api.py`, `deploy/backup.py`, `deploy/restore.py`, `scraper/download_release_images.py`, `deploy/verify_metrics.py`) oraz automatyzację w `Makefile` i konfiguracjach SQL.
* **Praca z repozytorium i code review:** Poza samym pisaniem kodu AI bardzo pomogło mi w redagowaniu opisów Pull Requestów, komunikatów commitów oraz merytorycznych komentarzy podczas code review innych członków zespołu (w tym w szybkim wyłapywaniu edge case'ów i rozwiązywaniu konfliktów przy mergu).
* **Diagnostyka problemów środowiskowych:** Narzędzia AI sprawnie pomagały namierzyć przyczyny nietypowych błędów na styku kontenerów i hosta (np. konwersja ścieżek MSYS2 na Windows, kodowanie UTF-16 przy przekierowaniu w PowerShellu, brak `PS_MAIL_METHOD`, przekierowania 302 z GitHub API do AWS S3).

### 2. Gdzie AI wprowadziło w błąd
* **Założenia niezgodne z wymaganiami:** AI początkowo zahardkodowało klucz API w kodzie Python, przyjęło stawkę 23% VAT dla wszystkich produktów (ignorując 8% i 0%), wpisało ceny brutto przewoźników jako netto w bazie i nie wykluczało zamówień powyżej 50 kg.
* **Błędy techniczne i brakujące konteksty:** W wygenerowanych fragmentach pojawiały się m.in. słowo kluczowe `precision` bez backticków w SQL, brak bezpośredniego importu `urllib.error` czy użycie `getattr(sys.stdout, "reconfigure")` niezgodne z linterem Ruff. W kodzie innych osób trzeba było też wyłapywać np. zduplikowany `#search_widget`, pominięte hooki modułu `omnibus` czy progi `149 zł` zamiast `2000 zł`.

### 3. Czego musiałem się nauczyć sam
* **Wewnętrzna architektura PrestaShop 8.2:** Musiałem samodzielnie zrozumieć działanie Webservice API, tabel walut (`ps_currency*`) i stawek podatkowych, hooków modułów, budowania cache (`var/cache/prod`) oraz uprawnień `www-data` w kontenerze.
* **Pełna weryfikacja na czystym środowisku:** Przekonałem się, że każdą zmianę wygenerowaną przez AI trzeba traktować jak kod młodszego kolegi — zawsze weryfikować ją od zera (`docker compose down -v`, `make init`, `make verify`, `make e2e`, `make backup`/`restore`, `gitleaks`).

---

## Refleksja końcowa (Dominik Szwed)

### 1. Gdzie AI realnie przyspieszyło pracę
* **Budowa całego frontendu i „orkiestra” podagentów:** AI pozwoliło w bardzo krótkim czasie postawić kompletny motyw potomny `topmarket-child` (~4 tys. linii CSS, własny JS, nadpisania szablonów Smarty), stworzyć od zera moduł `domitekcookies` i strony CMS. Przy większych zadaniach świetnie sprawdziło się delegowanie pracy osobnym agentom (osobny od strony głównej, listingu, karty produktu, dostępności i audytów).
* **Audyty i testy na zawołanie:** Agenty w kilka chwil odpalały bezgłowe testy Playwrighta, Axe-Core oraz Google Lighthouse, od razu wskazując konkretne problemy z kontrastem, brakującymi atrybutami `aria-label` czy przelewającym się kontenerem na szerokości `360 px`.
* **Praca z repozytorium:** AI pomagało przy dopracowaniu treści review do PR-ów kolegów, rozplątywaniu konfliktów w `Makefile` i `AI_LOG.md`, pilnowaniu konwencji commitów oraz porządkowaniu ADR-ów.

### 2. Gdzie AI wprowadziło w błąd
* **Zbyt wierna miłość do TopMarket.pl:** AI tak bardzo wczuło się w odwzorowanie pierwowzoru, że wszędzie (od banerów po drawer koszyka) powpisywało darmową dostawę od `149 zł` i baner `PayPo`, zamiast naszych wymagań (`2000 zł / 50 kg`, brak zewnętrznych operatorów płatności).
* **Kreatywne duplikaty i pułapki w kodzie:** Raz dopisało `<script src=".../custom.js">` mimo rejestracji w `theme.yml` (przez co przycisk `+` dodawał po 3 sztuki naraz), innym razem wyrenderowało 3 paski wyszukiwania `#search_widget` w nagłówku (wysypując testy E2E na strict mode), zahardkodowało prefiksy `/pl/` i ID produktów `37–39` oraz wstawiło puste przyciski listy życzeń.
* **Sabotaż samego siebie w CSS i SQL:** Gdy w `product.tpl` wreszcie przywróciliśmy hook `displayProductAdditionalInfo` dla wariantów z modułu `omnibus`, okazało się, że sam motyw w `custom.css` nadal ukrywał `.product-additional-info` przez `display: none !important`. Z kolei w SQL brak `DELETE` w `ps_linksmenutop_lang` zostawiał w menu stare `BESTSELLERY` (404), a `mariadb -e "SOURCE ...;"` ze średnikiem kulturalnie nie wykonywał skryptu.
* **Wielka afera o zdjęcie 60L na workach 35L:** Przez chwilę podejrzewaliśmy AI i importera o pomieszanie zdjęć wariantów, po czym wyszło na jaw, że po prostu Bartek jest tylko trochę głuptaskiem, a winowajcą był sam sklep źródłowy (`topmarket.pl`), który wrzucił identyczne zdjęcie `60L` pod oba produkty.

### 3. Czego musiałem się nauczyć sam
* **Jak PrestaShop 8.2 działa „pod maską”:** Że `cache:clear` bez odpowiednich flag potrafi wyczyścić `dev` zamiast `var/cache/prod`, włączenie motywu potrafi po cichu przepiąć moduły na stare hooki, a checkout używa osobnego szablonu nagłówka (`checkout/_partials/header.tpl`, przez co straszyło tam domyślne logo `my store`).
* **Pułapki Windowsa i Dockera:** Że przekierowanie pliku SQL przez potok w PowerShellu zamienia nasze piękne `zł` w `zĹ,` (dopiero `docker cp` + `<` w kontenerze rozwiązuje temat), a `MinGW make` i `cmd.exe` nie przepadają za apostrofami.
* **Zasada ograniczonego zaufania:** Agent AI pisze kod szybciej, niż człowiek zdąży mrugnąć, ale bez ręcznego kliknięcia `Ctrl+F5`, przejrzenia konsoli i puszczenia czystego `make e2e` potrafi schować własną zmianę pod `display: none` i z pełnym przekonaniem zaraportować sukces.

## Refleksja końcowa (Bartek Kluska)

### 1. Gdzie AI realnie przyspieszyło pracę

- **Git i code review** — Przy większych PR-ach agent pomagał mi przejrzeć zmiany i wskazywał, na co zwrócić uwagę. Sam sprawdzałem ważniejsze rzeczy, np. czy klucz API trafił do repozytorium. Agent pomagał też przy commitach i konfliktach. Przed pushem sprawdzałem, co jest w commitach, i decydowałem, kiedy je wypchnąć.
- **Scraper** — Najpierw sam przejrzałem HTML strony i podpowiedziałem AI, skąd brać dane produktów. Wybrałem Pythona i biblioteki, których już używałem, bo dzięki temu łatwiej było mi sprawdzać i poprawiać kod. Agent pomógł uzupełnić parser, dopisać testy, a później ułożyć mój opis według wzorca ADR.
- **Testy** — Testy Playwright też są w Pythonie, bo znam ten język i łatwo mi prześledzić, na którym kroku test się zatrzymał. AI pomogło mi przygotować testy na stronie wzorcowej, przenieść je na nasz sklep i dodać brakujące kroki, od rejestracji po pobranie faktury.

### 2. Gdzie AI wprowadziło w błąd

- **Dostępność produktów** — Pierwsza wersja scrapera brała odpowiedź HTTP 200 za oznakę dostępności. Na stronie niedostępnego produktu parser potrafił pobrać opis polecanej oferty. Wyszło to, gdy porównaliśmy zapisany rekord z kartą produktu.
- **Warianty** — Agent początkowo połączył osobne produkty w jedną kartę. Po sprawdzeniu danych ze scrapera ustaliliśmy, że każda wersja ma zachować własną nazwę, opis i zdjęcie, a wybór opcji ma prowadzić do jej karty.
- **Wyszukiwarka** — Przy wpisaniu `Jan Niezbędny worki na śmieci` sklep pokazywał też inne produkty tej marki, np. ścierki. Trzeba było poprawić wyszukiwanie tak, żeby brało pod uwagę również to, że szukamy worków.

### 3. Czego musiałem się nauczyć sam

- **Struktura HTML** — Przy scraperze nauczyłem się sprawdzać dostępność w danych konkretnego produktu. Na stronie niedostępnego produktu blok z polecaną ofertą mógł pojawić się w HTML wcześniej niż właściwy opis.
- **Stany magazynowe w testach** — Każde zamówienie zmienia stan magazynowy. Kolejne uruchomienia pokazały, że test szukał produktów na zbyt małej liczbie stron. Po poprawce sprawdziłem cały zakup trzy razy z rzędu.
- **Faktury w PrestaShop** — Sprawdziłem, kiedy sklep wystawia fakturę za zamówienie za pobraniem. W naszym teście pojawiała się po zmianie statusu zamówienia w panelu admina na „Płatność zaakceptowana”.
