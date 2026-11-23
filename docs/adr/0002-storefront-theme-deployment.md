# ADR 0002: Sposób wdrażania i konfiguracji motywu potomnego w kontenerach

**Status:** Zaakceptowano  
**Data:** 2026-11-23  
**Powiązane zadanie:** Issue #30 (D1. Wygląd sklepu i dostępność cyfrowa)

## Kontekst

Wymagania projektowe (W3, D1) zakładają uruchomienie sklepu PrestaShop 8.2.8 z czystego klona repozytorium jedną komendą startową i jedną komendą inicjalizującą (`make init`), przy jednoczesnym zachowaniu zmian wyglądu w motywie potomnym `topmarket-child`. W etapie 2 sklep zostanie wdrożony na klaster Docker Swarm, dlatego sposób dostarczania plików motywu i jego konfiguracji musi być powtarzalny i niezależny od ręcznych kliknięć w panelu administracyjnym.

## Rozważane opcje

1. **Ręczne wgrywanie paczki `.zip` motywu w panelu administracyjnym PrestaShop**
   - *Zalety:* brak konieczności konfiguracji `compose.yaml` i skryptów SQL.
   - *Wady:* brak powtarzalności po `docker compose down -v`, wymaga ręcznej ingerencji prowadzącego przy odbiorze.

2. **Budowanie własnego obrazu `Dockerfile` dla PrestaShop z wbudowanym motywem**
   - *Zalety:* gotowy obraz samowystarczalny na potrzeby Etapu 2 (Docker Swarm).
   - *Wady:* wydłużony czas iteracji podczas prac nad CSS/JS/TPL w Etapie 1 (konieczność przebudowy obrazu po każdej zmianie).

3. **Bind-mount motywu w `deploy/compose.yaml` + idempotentna aktywacja w `Makefile` i SQL**
   - *Zalety:* natychmiastowe odzwierciedlenie zmian w trakcie developmentu, pełna odtwarzalność z czystego klona (`make theme` / `make init`), brak konieczności ręcznej konfiguracji w Back-Office.
   - *Wady:* w Etapie 2 (Docker Swarm) bind-mount lokalnego katalogu będzie musiał zostać zastąpiony skopiowaniem motywu do własnego obrazu `Dockerfile`.

## Decyzja

Wybrano **opcję 3**:
- Katalog `shop/themes/topmarket-child` jest montowany bezpośrednio w kontenerze `prestashop` przez `deploy/compose.yaml`.
- Konfiguracja bazy danych (układ bloków, banery, linki menu, ustawienia modułów) jest zapisywana w idempotentnym skrypcie `deploy/storefront_appearance.sql`.
- Cel `theme:` (oraz alias `storefront:`) w `Makefile` wgrywa SQL, aktywuje motyw komendą `php bin/console prestashop:theme:enable topmarket-child`, czyści cache i ustawia uprawnienia `www-data`.

## Konsekwencje

- **Pozytywne:** Każdy członek zespołu i prowadzący może odtworzyć identyczny wygląd sklepu jedną komendą (`make init` lub `make theme`). Zmiany w kodzie motywu są od razu widoczne bez przebudowywania obrazów.
- **Negatywne / do zaadresowania w Etapie 2:** Przed wdrożeniem na klaster Docker Swarm należy dodać krok `COPY shop/themes/topmarket-child ...` do obrazu PrestaShop, aby kontenery na węzłach klastra nie polegały na lokalnym systemie plików.
