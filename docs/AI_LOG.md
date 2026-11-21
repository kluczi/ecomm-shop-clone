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
| **Co otrzymano** | Skrypt `scraper/download_release_images.py` realizujący automatyczne pobieranie archiwum `images.zip` z GitHub Releases (`v1.0.0-images`) z obsługą prywatnego repozytorium przez `gh` CLI, bezpośrednim REST API, rozpakowywaniem z weryfikacją sumy SHA-256 oraz fallbackiem do scrapera `scraper/images.py`. Dodano cel `images` do `Makefile` i wpięto go do `make init` oraz `make import`. |
| **Co było błędne** | AI początkowo zaproponowało sztywny próg 1000 zdjęć oraz pobieranie bezpośrednim URL `curl` bez uwzględnienia prywatnego repozytorium. Skorygowano to poprzez dynamiczne wyliczanie wymaganych zdjęć na podstawie `products.json`, wdrożenie weryfikacji sumy kontrolnej SHA-256 z wbudowanym `hashlib.file_digest`, usunięcie zbędnego handlera przekierowań oraz zaimplementowanie pełnego mechanizmu awaryjnego. |
| **Weryfikacja** | Opublikowanie wydania `v1.0.0-images` z plikiem `images.zip` na GitHubie. Przetestowanie wszystkich 5 metod pobierania w terminalu (cache lokalny, lokalny zip z SHA-256, GitHub CLI, bezpośrednie REST API oraz fallback scrapera) – każda zakończona sukcesem. Weryfikacja linterem `ruff` oraz `pyright`. |

---

## Wpis 8: Issue #32 – Backup i procedura Disaster Recovery (Wymóg D4)

| Pole | Opis |
| --- | --- |
| **Data i autor** | 21.11.2026, Michał Łysiak |
| **Narzędzie i model** | Antigravity (Gemini 3.8 Flash) |
| **Zadanie** | Issue #32: Backup and Disaster Recovery – Automatyzacja tworzenia kopii zapasowej i odtwarzania sklepu (Wymóg D4) |
| **Co otrzymano** | Architekturę procedury Disaster Recovery: skrypty `deploy/backup.py` i `deploy/restore.py` (wraz z uniksowymi wrapperami `.sh`), kompresję zrzutu MariaDB do `database.sql.gz`, archiwizację zdjęć wolumenu PrestaShop (`/var/www/html/img/p`) do `images.tar.gz`, eksport konfiguracji SQL, integrację celów `make backup` oraz `make restore` w `Makefile` oraz automatyczny benchmark czasu odzyskiwania. |
| **Co było błędne** | AI początkowo nie uwzględniło obsługi strumieniowej dekompresji w `subprocess` oraz bezpiecznego zamykania potoków, co mogło prowadzić do blokowania procesu na dużych archiwach. Dodatkowo brakowało automatycznego sprawdzania zdrowia sklepu po odtworzeniu. Skorygowano to dodając strumieniowanie chunków 1 MB, czyszczenie cache produkcyjnego `var/cache/prod`, weryfikację `HTTP 200 OK` na `https://localhost` oraz sprawdzanie liczby produktów w bazie. |
| **Weryfikacja** | Wykonanie pełnego backupu żywego sklepu (1271 produktów, 1777 zdjęć) – czas wykonania 16.75 s, rozmiar archiwum 336.35 MB. Następnie przeprowadzenie procedury Disaster Recovery (`make restore`): całkowite zresetowanie bazy danych, import zrzutu i odtworzenie zdjęć zajęło 26.49 s (0.44 min), co z olbrzymim zapasem spełnia wymóg SLA <= 10 minut. Sprawdzenie stanu sklepu wykazało dokładnie 1271 odtworzonych produktów i status HTTP 200 OK. Weryfikacja jakości kodu linterem `ruff check deploy/` (0 błędów). |

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
