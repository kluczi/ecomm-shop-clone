# ecomm-shop-clone

## Promocje i warianty (D3)

Przy pierwszej konfiguracji uruchom `make up`, a po instalacji PrestaShop
wykonaj `make init && make import && make promotions`. Na istniejącym sklepie
z zaimportowanym katalogiem wystarczy `make up` i `make promotions`.

`make promotions` ustawia rabaty od 10% do 30% na 20 produktów z katalogu.
Moduł `omnibus` pokazuje przy tych promocjach na liście i karcie produktu
najniższą odnotowaną cenę brutto z okresu przed obniżką (do 30 dni).
`make init` instaluje moduł przed importem, żeby historia zaczynała się od
pierwszej ceny produktu. W istniejącym sklepie moduł rejestruje ceny od
momentu instalacji. Dane dotyczą pierwszych promocji na wybranych produktach.

Trzy modele worków mają wybór pojemności, a dwie serie doniczek wybór
rozmiaru. Opcje zachowują SKU i cenę z katalogu oraz mają osobny stan
magazynowy. Przy pierwszej konfiguracji łączny zapas modelu wynosi do 10 sztuk.
Starsze adresy scalonych produktów przekierowują na wspólną kartę. Ponowne
`make promotions` zachowuje stany istniejących wariantów. Zwiększenie rabatu
aktualizuje cenę referencyjną na podstawie zapisanej historii, w tym ceny
sprzed zmiany.
