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
