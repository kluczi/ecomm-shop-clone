# Domitek (ecomm-shop-clone)

Klon sklepu internetowego [topmarket.pl](https://topmarket.pl) zrealizowany na platformie **PrestaShop 8.2.8** w ramach przedmiotu **Biznes Elektroniczny (eBiz) 2026/2027**, Politechnika Gdańska.

---

## Skład Zespołu

| Imię i nazwisko | GitHub | Główne obszary odpowiedzialności |
| :--- | :--- | :--- |
| **Michał Łysiak** | [@Mihulski](https://github.com/Mihulski) | Import katalogu przez Webservice API, Dystrybucja zdjęć w GitHub Releases, Procedura Disaster Recovery backup/restore, Zabezpieczenia i certyfikaty SSL |
| **Bartek Kluska** | [@kluczi](https://github.com/kluczi) | Inicjalizacja projektu, Scraper danych i walidacja schematów Pydantic, Pipeline CI/CD GitHub Actions, Testy E2E Playwright |
| **Dominik Szwed** | [@Japapuj](https://github.com/Japapuj) | Środowisko Docker Compose i Nginx Reverse Proxy, Strony CMS i moduł cookies, Metody płatności i dostawy, Identyfikacja i personalizacja storefrontu |

---

## Architektura i Wersje Technologii

* **Platforma E-Commerce:** PrestaShop **8.2.8** (`linux/amd64`, PHP 8.1 FPM / Apache)
* **Baza danych:** MariaDB **10.11** (dostępna na porcie `3000` na hoście)
* **Reverse Proxy & SSL:** Nginx z certyfikatem SSL i wymuszonym przekierowaniem **301** z HTTP (port 80) na HTTPS (port 443)
* **Serwer poczty testowej:** Mailpit **v1.33.0** (Web UI na porcie `8025`, serwer SMTP na porcie `1025`)
* **Narzędzia i testy:** Python **3.13**, Playwright, Pytest, Ruff linter

---

## Szybki Start (Uruchomienie z Czystego Klona)

Zgodnie z wymaganiem, sklep uruchamia się z czystego klona repozytorium **jedną komendą startową i jedną komendą inicjalizacji danych** w czasie poniżej 15 minut.

### 1. Klonowanie i przygotowanie środowiska
```bash
git clone https://github.com/kluczi/ecomm-shop-clone.git
cd ecomm-shop-clone
cp .env.example .env
```

Zgodnie z kryterium, plik `.env.example` zawiera wyłącznie nazwy zmiennych bez haseł. Przed uruchomieniem należy uzupełnić w pliku `.env` lokalne poświadczenia bazy MariaDB (`DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_ROOT_PASSWORD`), dane administratora (`ADMIN_MAIL`, `ADMIN_PASSWORD`) oraz 32-znakowy klucz `PRESTASHOP_WEBSERVICE_KEY`.

### 2. Komenda Startowa (Krok 1/2)
Pobranie i uruchomienie kontenerów w tle:
```bash
make up
```

### 3. Komenda Inicjalizująca (Krok 2/2)
Jednoetapowa konfiguracja platformy oraz import danych:
```bash
make init
```
**Co automatycznie wykonuje `make init`:**
1. Sprawdza obecność wymaganych zmiennych konfiguracyjnych (`check-env`) oraz przy pierwszym uruchomieniu tworzy lokalne `.venv` i instaluje zależności z `scraper/requirements.txt` (`venv`).
2. Wgrywa strony CMS (Regulamin, Polityka, Dostawa itp.) i instaluje autorski moduł ciasteczek `domitekcookies` (`cms`).
3. Rejestruje przewoźników DPD Kurier i InPost Paczkomat 24/7 z progami darmowej dostawy > 2000 zł i limitem wagi 50 kg (`shipping`).
4. Aktywuje polskie metody płatności: Przelew bankowy oraz Płatność przy odbiorze, powiązane z walutą PLN i stawką 23% VAT (`payments`).
5. Tworzy klucz API Webservice z wymaganymi uprawnieniami (`webservice`).
6. Ustawia tożsamość sklepu Domitek, domyślną walutę PLN oraz szablon filtrów (`storefront-config`).
7. Instaluje moduł `omnibus` przed importem katalogu (`promotion-module`).
8. Weryfikuje lokalną pamięć podręczną lub pobiera z GitHub Releases oficjalne archiwum zdjęć `images.zip` (`images`) i importuje przez Webservice API 1271 produktów, strukturę kategorii, stany magazynowe oraz galerie zdjęć (`import`).
9. Konfiguruje rabaty Omnibus na 20 produktach oraz 5 grup wariantów z osobnymi stanami magazynowymi (`promotions`), przebudowuje indeks wyszukiwarki (`search`), aktywuje motyw potomny `topmarket-child` z menu kategorii (`theme`) oraz weryfikuje metryki projektowe (`verify`).

---

## Dostęp do Usług

| Usługa | Adres URL | Poświadczenia i dostęp |
| :--- | :--- | :--- |
| **Sklep (Storefront)** | `https://localhost` | Dostęp publiczny (akceptacja certyfikatu SSL) |
| **Panel Administracyjny** | `https://localhost/admin-dev/` | Login: zdefiniowany w `ADMIN_MAIL` w `.env`<br>Hasło: zdefiniowane w `ADMIN_PASSWORD` w `.env` |
| **Poczta testowa (Mailpit)** | `http://localhost:8025` | Web UI poczty testowej (dostęp lokalny) |
| **Baza danych (MariaDB)** | `localhost:3000` | Poświadczenia zgodne z `DATABASE_USER` i `DATABASE_PASSWORD` w `.env` |

---

## Testy E2E

Uruchom sklep z zaimportowanym katalogiem. Przy pierwszym uruchomieniu `make e2e` automatycznie tworzy środowisko `tests/.venv`, instaluje zależności z `tests/requirements.txt` oraz pobiera przeglądarkę Chromium.

Cały zestaw w trybie headless uruchamia `make e2e`. Domyślny adres sklepu to `https://localhost` (możesz go zmienić przez `BASE_URL`, a własny interpreter wskazać przez `E2E_PYTHON`).

Test tworzy konto i zamówienie za pobraniem. Do zmiany statusu zamówienia używa lokalnego panelu i danych z `.env`. Na innej instancji należy ustawić `E2E_ADMIN_URL`, `E2E_ADMIN_EMAIL` i `E2E_ADMIN_PASSWORD`.

Raport HTML znajduje się w `playwright-report/index.html`. Faktura PDF oraz zrzuty ekranu nieudanych testów trafiają do `test-results/`.

---

## Kopia Zapasowa i Odtwarzanie (Disaster Recovery)

Projekt zawiera skrypty tworzenia i przywracania pełnej kopii zapasowej:

* **Wykonanie kopii zapasowej:**
  ```bash
  make backup
  ```
  Tworzy w katalogu `deploy/backups/backup_YYYYMMDD_HHMMSS/` skompresowany zrzut bazy `database.sql.gz`, archiwum zdjęć `images.tar.gz` oraz metadane `metadata.json`.

* **Przywrócenie z kopii:**
  ```bash
  make restore
  ```
  Automatycznie weryfikuje integralność strumienia gzip i sygnatury SQL przed usunięciem bazy, odtwarza bazę danych, rozpakowuje zdjęcia i czyści cache produkcyjny PrestaShop.

---

## Zestawienie Poleceń Makefile

| Polecenie | Opis |
| :--- | :--- |
| `make up` | Zbudowanie i uruchomienie kontenerów Docker Compose w tle |
| `make down` | Zatrzymanie kontenerów aplikacji |
| `make init` | **Pełna inicjalizacja sklepu** (CMS, płatności, dostawa, API, storefront, zdjęcia i katalog produktów) |
| `make import` | Uruchomienie idempotentnego importu produktów przez Webservice API |
| `make images` | Weryfikacja cache / pobranie archiwum zdjęć z GitHub Release |
| `make backup` | Wykonanie pełnej kopii zapasowej sklepu (baza danych + zdjęcia) |
| `make restore` | Odtworzenie sklepu z najświeższej kopii zapasowej |
| `make e2e` | Uruchomienie zestawu testów Playwright w trybie headless |
| `make cms` | Inicjalizacja stron CMS i instalacja modułu ciasteczek |
| `make payments` | Inicjalizacja metod płatności i powiązań z walutą PLN |
| `make shipping` | Inicjalizacja metod dostawy (DPD, InPost) i stawek |
| `make webservice` | Konfiguracja klucza i uprawnień Webservice API w bazie |
| `make storefront` | Konfiguracja motywu, menu, filtrów i stylów storefrontu |
| `make promotions` | Konfiguracja promocji Omnibus (20 produktów) oraz wariantów produktów |

---

## Struktura Repozytorium

```text
├── deploy/                 # Konfiguracja środowiska (Compose, Nginx SSL, skrypty backup/restore, SQL)
│   ├── backups/            # Katalog zrzutów Disaster Recovery (ignorowany w git)
│   ├── backup.py / .sh     # Automatyzacja tworzenia kopii zapasowej
│   ├── restore.py / .sh    # Procedura odtwarzania sklepu po awarii
│   └── compose.yaml        # Definicja usług Docker Compose v2
├── docs/                   # Dokumentacja projektowa
│   ├── adr/                # Architecture Decision Records (ADR 0001, ...)
│   └── AI_LOG.md           # Dziennik wykorzystania narzędzi AI
├── scraper/                # Kod scrapera TopMarket w Pythonie (Selectolax, HTTPX, Pydantic)
│   ├── tests/              # Testy jednostkowe scrapera na lokalnych próbkach HTML
│   └── download_release_images.py # Wielopoziomowe pobieranie archiwum zdjęć z Releases
├── scraper-results/        # Wyniki scrapowania: products.json, categories.json (UTF-8)
├── shop/                   # Skrypty aplikacyjne sklepu
│   ├── import_api.py       # Idempotentny import katalogu i stanów magazynowych przez Webservice API
│   ├── custom.css          # Style storefrontu Domitek
│   └── modules/            # Autorskie moduły PrestaShop (domitekcookies)
└── tests/                  # Testy E2E w Playwright i Pytest
    ├── conftest.py         # Fixtury, konfiguracja przeglądarki, SSL i logowania
    ├── shop.py             # Akcje przeglądarkowe w katalogu i koszyku
    ├── checkout.py         # Ścieżka zakupowa, zamówienie, panel admina i pobranie faktury
    └── test_shop.py        # 10-krokowy scenariusz testowy E2E
```
