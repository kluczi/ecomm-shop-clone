# ecomm-shop-clone

## Testy E2E

Uruchom sklep z zaimportowanym katalogiem. Przy pierwszym uruchomieniu
przygotuj środowisko testów i Chromium.

```sh
python3 -m venv tests/.venv
tests/.venv/bin/python -m pip install -r tests/requirements.txt
tests/.venv/bin/python -m playwright install chromium
```

Cały zestaw w trybie headless uruchamia `make e2e`. Domyślny adres sklepu
to `https://localhost`. Możesz go zmienić przez `BASE_URL`.

Test tworzy konto i zamówienie za pobraniem. Do zmiany statusu zamówienia
używa lokalnego panelu i danych z `.env`. Na innej instancji ustaw
`E2E_ADMIN_URL`, `E2E_ADMIN_EMAIL` i `E2E_ADMIN_PASSWORD`.

Raport HTML znajdziesz w `playwright-report/index.html`. Faktura PDF oraz
zrzuty ekranu nieudanych testów trafiają do `test-results/`.
