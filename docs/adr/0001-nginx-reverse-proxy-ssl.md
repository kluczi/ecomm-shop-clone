# ADR 0001: Nginx jako Reverse Proxy

* **Status:** Zaakceptowany
* **Data:** 18.11.2026
* **Autor:** Michał Łysiak

---

## 1. Kontekst i problem

Zgodnie ze specyfikacją wymagań projektowych:
1. Sklep musi obsługiwać ruch **wyłącznie przez szyfrowany protokół HTTPS** z samodzielnie wygenerowanym certyfikatem SSL.
2. Wszelkie zapytania nieszyfrowane (HTTP) muszą być **automatycznie przekierowywane kodem 301 na HTTPS**.
3. Prowadzący uruchamia sklep z czystego klona repozytorium jedną komendą (`docker compose up -d`), bez konieczności wcześniejszego instalowania zewnętrznych narzędzi (np. `openssl`) na maszynie hosta.

Oficjalny obraz `prestashop/prestashop:8.2.8` bazuje na serwerze Apache nasłuchującym domyślnie na nieszyfrowanym porcie 80. Bezpośrednie wystawienie kontenera PrestaShop nie zapewniało mechanizmu przekierowania 301 ani wbudowanej obsługi certyfikatu SSL.

---

## 2. Rozważane opcje

### Opcja 1: Konfiguracja Apache i SSL wewnątrz kontenera PrestaShop
* **Opis:** Przebudowa oficjalnego obrazu PrestaShop przez własny `Dockerfile` (włączenie `mod_ssl`, `mod_rewrite`, instalacja pakietu `openssl`, modyfikacja wirtualnego hosta w `/etc/apache2/sites-available/`).
* **Wady:**
  * Łamie zasadę pojedynczej odpowiedzialności kontenerów (aplikacja PHP + terminacja SSL).
  * Modyfikacja oficjalnego obrazu utrudnia aktualizacje PrestaShop.
  * Generowanie certyfikatu przy każdym restarcie kontenera aplikacji spowalnia uruchamianie.

### Opcja 2: Dedykowany Nginx jako Reverse Proxy (Wybrana)
* **Opis:** Uruchomienie lekkiego kontenera `nginx:1.27.4-alpine` jako jedynego punktu wejścia dla portów 80 i 443 na hoście. Nginx terminujący SSL i przekierowujący 301, a kontener `prestashop` nasłuchuje wyłącznie w wewnętrznej sieci Dockera.
* **Zalety:**
  * Pełna separacja odpowiedzialności – PrestaShop pozostaje czystym oficjalnym obrazem.
  * Skrypt `entrypoint.sh` w Nginx sprawdza obecność certyfikatu w wolumenie i w razie braku generuje go automatycznie przy starcie kontenera za pomocą OpenSSL z Alpine.
  * Przekierowanie 301 realizowane natywnie przez dyrektywę `return 301 https://$host$request_uri;` w konfiguracji serwera Nginx.
  * Przekazywanie właściwych nagłówków proxy (`X-Forwarded-Proto https`, `X-Forwarded-Port 443`, `Host $host`), co zapobiega pętlom przekierowań w silniku PrestaShop.

### Opcja 3: Zaawansowany router brzegowy (Traefik / Envoy)
* **Opis:** Użycie Traefika do automatycznego wykrywania serwisów przez etykiety Dockera.
* **Wady:**
  * Zbyt duży narzut konfiguracyjny i złożoność w stosunku do prostego środowiska Docker Compose dla jednego sklepu.
  * Trudniejsze zarządzanie niestandardowymi certyfikatami samopodpisanymi w środowisku deweloperskim na `localhost`.

---

## 3. Decyzja

Zdecydowano o wdrożeniu **Opcji 2 (Nginx Reverse Proxy)** w architekturze:
* Kontener `shop-nginx` publikuje porty `80:80` oraz `443:443`.
* Kontener `shop-prestashop` wystawia port 80 wyłącznie do sieci wewnętrznej (`expose: - "80"`), bez mapowania na porty hosta.
* Nginx terminuje sesję TLS na porcie 443 i przesyła ruch po HTTP do serwisu `prestashop:80` wewnątrz sieci Dockera.
* Certyfikat SSL generuje się automatycznie przy starcie w katalogu `/etc/nginx/ssl` i jest ignorowany w `.gitignore`.

---

## 4. Konsekwencje

### Pozytywne:
* **Spełnienie kryteriów W3:** Wymuszony HTTPS, stały redirect 301 z HTTP na HTTPS.
* **Zero zależności na maszynie hosta:** Sklep działa z czystego klona na każdym systemie bez konieczności instalowania `openssl`.
* **Czystość kodu:** Brak ingerencji w pliki konfiguracyjne serwera Apache w obrazie PrestaShop.

### Negatywne / Narzut:
* Wprowadzenie dodatkowej usługi `nginx` w pliku `deploy/compose.yaml` (chociaż zarówno narzut pamięciowy, jak i opóźnienie sieciowe są w praktyce całkowicie pomijalne).
