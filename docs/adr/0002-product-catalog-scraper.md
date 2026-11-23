# ADR 0002: Scraper katalogu produktów

* **Status:** Zaakceptowany
* **Data:** 23.11.2026
* **Autor:** Bartek Kluska

---

## 1. Kontekst i problem

W ramach #5 potrzebowaliśmy pobrać produkty, kategorie i zdjęcia z Topmarketu do importu w PrestaShop. Przy co najmniej 1000 unikalnych produktach ważna była możliwość wznowienia pobierania po przerwaniu.

---

## 2. Rozważane opcje

* **Pobieranie równoległe** skróciłoby zbieranie katalogu, ale wymagałoby koordynacji żądań i wspólnego zapisu wyników.
* **Pobieranie sekwencyjne (wybrane)** pozwala łatwo kontrolować odstępy między żądaniami. Przy katalogu zbieranym na potrzeby projektu czas pierwszego uruchomienia był akceptowalny.

---

## 3. Decyzja

Wybrałem Pythona oraz biblioteki, z którymi już pracowałem. `httpx` pobiera strony, `selectolax` odczytuje HTML i osadzone w nim dane produktu, Pydantic sprawdza poprawność rekordów, a Pillow przygotowuje zdjęcia w wymaganym rozmiarze.

Scraper respektuje `robots.txt` i robi przerwy między żądaniami. Dostępność produktu bierze z danych na jego karcie, bo strona niedostępnego produktu też może zwrócić HTTP 200. Każdy poprawny rekord zapisuje od razu do `products.jsonl`, co pozwala wznowić pracę po przerwaniu.

Import do PrestaShop jest osobnym krokiem. Korzysta z gotowych plików `products.json` i `categories.json`, które zapisujemy w repozytorium. Zdjęcia można pobrać osobno na podstawie adresów w katalogu.

---

## 4. Konsekwencje

* Katalog można importować wielokrotnie z tego samego zestawu danych. Odświeżenie danych wymaga ponownego pobrania katalogu źródłowego.
* Zmiana HTML lub osadzonych danych Topmarketu może wymagać poprawienia parsera. Jego testy można uruchomić lokalnie bez odpytywania sklepu źródłowego.
