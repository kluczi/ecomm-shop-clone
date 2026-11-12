# Dziennik korzystania z narzędzi AI

## Wpis 1: Issue #8 – Wdrożenie HTTPS i przekierowania 301

| Pole | Opis |
| --- | --- |
| **Data i autor** | 08.11.2026, Michał Łysiak |
| **Narzędzie i model** | Gemini Flash 3.8 |
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
| **Narzędzie i model** | Gemini Flash 3.8 |
| **Zadanie** | Issue #14: Metody płatności oraz Issue #15: Konfiguracja dostawców i reguł darmowej dostawy |
| **Co otrzymano** | Pomoc w przygotowaniu zrzutów tabel konfiguracyjnych SQL dla modułów płatności (`ps_wirepayment`, `ps_cashondelivery`) oraz wyliczenie stawek netto dla przewoźników InPost i DPD uwzględniających 23% VAT, a także integrację z `Makefile`. |
| **Co było błędne** | AI początkowo ustawiło w bazie ceny brutto jako netto, co skutkowało zawyżonymi kwotami w koszyku po doliczeniu podatku VAT (18.44 zł i 24.59 zł zamiast 14.99 zł i 19.99 zł). Ponadto AI zaproponowało zachowanie poza zakresem wagowym jako naliczenie najwyższej stawki zamiast zablokowania przewoźnika. Błędy skorygowano po teście w koszyku. |
| **Weryfikacja** | Przetestowanie ścieżki zamówienia w sklepie: weryfikacja dostępności obu metod płatności, sprawdzenie kwot 14.99 zł i 19.99 zł brutto w koszyku, test naliczenia darmowej dostawy powyżej 2000 zł oraz test blokady przewoźników dla koszyka o wadze powyżej 50 kg. |

---

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