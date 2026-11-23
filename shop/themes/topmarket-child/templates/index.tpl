{**
 * TopMarket Child Theme - Index Template
 * Domitek E-Commerce (Issue #30 - D1: Storefront Appearance and Accessibility)
 * 1:1 Reproduction of TopMarket.pl Homepage Layout & Ergonomics
 *}
{extends file='page.tpl'}

{block name='page_content_container'}
  <h1 class="sr-only">Domitek - Sklep internetowy: dom, ogród i narzędzia</h1>
  <section id="content" class="page-home">
    {block name='page_content_top'}{/block}

    {block name='page_content'}
      <!-- 1. Panoramiczny Hero Banner / Karuzela (2560x720 desktop, 1080x1080 mobile) -->
      <div class="topmarket-home-hero-section" aria-label="Główne banery promocyjne">
        <div id="carousel" data-ride="carousel" class="carousel slide topmarket-carousel" data-interval="5000" data-wrap="true" data-pause="hover">
          <ol class="carousel-indicators">
            <li data-target="#carousel" data-slide-to="0" class="active" aria-label="Przejdź do slajdu 1: Roboty koszące NAC ZEN AI"></li>
            <li data-target="#carousel" data-slide-to="1" aria-label="Przejdź do slajdu 2: Szklarnie ogrodowe"></li>
            <li data-target="#carousel" data-slide-to="2" aria-label="Przejdź do slajdu 3: Narzędzia akumulatorowe NAC SMART"></li>
            <li data-target="#carousel" data-slide-to="3" aria-label="Przejdź do slajdu 4: Wyprzedaż noworoczna"></li>
          </ol>
          <ul class="carousel-inner" role="listbox">
            <li class="carousel-item active" role="option" aria-hidden="false">
              <a href="{$urls.base_url}11-ogrod" title="NAC ZEN AI Robot koszący - Przejdź do kategorii Ogród">
                <figure>
                  <picture>
                    <source media="(max-width: 767px)" srcset="/themes/topmarket-child/assets/img/banner_01_zen_ai_mobile.webp">
                    <source media="(min-width: 768px)" srcset="/themes/topmarket-child/assets/img/banner_01_zen_ai_desktop.webp">
                    <img src="/themes/topmarket-child/assets/img/banner_01_zen_ai_desktop.webp" alt="NAC ZEN AI ROBOT, KTÓRY WIDZI WIĘCEJ - DOWIEDZ SIĘ WIĘCEJ" loading="eager" class="d-block w-100 img-fluid hero-banner-img" width="2560" height="720">
                  </picture>
                </figure>
              </a>
            </li>
            <li class="carousel-item" role="option" aria-hidden="true">
              <a href="{$urls.base_url}11-ogrod" title="Szklarnie ogrodowe TopMarket - Przejdź do kategorii Ogród">
                <figure>
                  <picture>
                    <source media="(max-width: 767px)" srcset="/themes/topmarket-child/assets/img/banner_01_zen_ai_mobile.webp">
                    <source media="(min-width: 768px)" srcset="/themes/topmarket-child/assets/img/banner_02_szklarnie_desktop.jpeg">
                    <img src="/themes/topmarket-child/assets/img/banner_02_szklarnie_desktop.jpeg" alt="Szklarnie ogrodowe TopMarket - Sprawdź ofertę w Domitek" loading="lazy" class="d-block w-100 img-fluid hero-banner-img" width="2560" height="720">
                  </picture>
                </figure>
              </a>
            </li>
            <li class="carousel-item" role="option" aria-hidden="true">
              <a href="{$urls.base_url}13-narzedzia" title="Narzędzia NAC SMART - Przejdź do kategorii Narzędzia">
                <figure>
                  <picture>
                    <source media="(max-width: 767px)" srcset="/themes/topmarket-child/assets/img/banner_01_zen_ai_mobile.webp">
                    <source media="(min-width: 768px)" srcset="/themes/topmarket-child/assets/img/banner_03_nac_smart_desktop.webp">
                    <img src="/themes/topmarket-child/assets/img/banner_03_nac_smart_desktop.webp" alt="Elektronarzędzia NAC SMART - Jeden akumulator wiele narzędzi" loading="lazy" class="d-block w-100 img-fluid hero-banner-img" width="2560" height="720">
                  </picture>
                </figure>
              </a>
            </li>
            <li class="carousel-item" role="option" aria-hidden="true">
              <a href="{$urls.base_url}10-dom" title="Wyprzedaż noworoczna - Przejdź do kategorii Dom">
                <figure>
                  <picture>
                    <source media="(max-width: 767px)" srcset="/themes/topmarket-child/assets/img/banner_01_zen_ai_mobile.webp">
                    <source media="(min-width: 768px)" srcset="/themes/topmarket-child/assets/img/banner_04_nowy_rok_desktop.webp">
                    <img src="/themes/topmarket-child/assets/img/banner_04_nowy_rok_desktop.webp" alt="Nowy Rok, nowe porządki - Domitek wielka wyprzedaż" loading="lazy" class="d-block w-100 img-fluid hero-banner-img" width="2560" height="720">
                  </picture>
                </figure>
              </a>
            </li>
          </ul>
          <div class="direction" aria-label="Sterowanie karuzelą">
            <a class="left carousel-control" href="#carousel" role="button" data-slide="prev" aria-label="Poprzedni slajd">
              <span class="icon-prev" aria-hidden="true">
                <i class="material-icons">&#xE5CB;</i>
              </span>
            </a>
            <a class="right carousel-control" href="#carousel" role="button" data-slide="next" aria-label="Następny slajd">
              <span class="icon-next" aria-hidden="true">
                <i class="material-icons">&#xE5CC;</i>
              </span>
            </a>
          </div>
        </div>
      </div>

      <!-- 2. Belka Korzyści USP (Reassurance Bar) - 1:1 TopMarket.pl (4 równe kafelki flex) -->
      <section class="tm-usp-section" aria-label="Korzyści i gwarancje zakupów w Domitek">
        <div class="container">
          <div class="tm-usp-bar">
            <div class="tm-usp-item">
              <img src="/themes/topmarket-child/assets/img/usp-ikona-1.png" alt="" aria-hidden="true" width="44" height="44" loading="lazy" class="tm-usp-icon">
              <span class="tm-usp-text">30 DNI NA ZWROT</span>
            </div>
            <div class="tm-usp-item">
              <img src="/themes/topmarket-child/assets/img/usp-ikona-2.png" alt="" aria-hidden="true" width="44" height="44" loading="lazy" class="tm-usp-icon">
              <span class="tm-usp-text">DARMOWA DOSTAWA OD 2000 ZŁ*</span>
            </div>
            <div class="tm-usp-item">
              <img src="/themes/topmarket-child/assets/img/usp-ikona-3.png" alt="" aria-hidden="true" width="44" height="44" loading="lazy" class="tm-usp-icon">
              <span class="tm-usp-text">ZAMÓW DO 18:00 - WYSYŁKA DZISIAJ</span>
            </div>
            <div class="tm-usp-item">
              <img src="/themes/topmarket-child/assets/img/usp-ikona-4.png" alt="" aria-hidden="true" width="44" height="44" loading="lazy" class="tm-usp-icon">
              <span class="tm-usp-text">OPINIE KLIENTÓW: 4.9/5</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Pomarańczowy Baner TOP CUT z 1. strony PDF -->
      <div class="topmarket-home-promo-banner-wrap">
        <div class="container">
          <a href="{$urls.base_url}13-narzedzia" class="topmarket-promo-card-banner banner-orange" title="Ogromny wybór urządzeń TOP CUT">
            <img src="/themes/topmarket-child/assets/img/banner-top-cut.webp" alt="Ogromny wybór URZĄDZEŃ TOP CUT - Wybieram TOP CUT" class="img-fluid w-100" loading="lazy" width="1600" height="180">
            <div class="tm-banner-overlay">
              <span class="tm-banner-subtitle">Ogromny wybór</span>
              <strong class="tm-banner-title">URZĄDZEŃ TOP CUT</strong>
              <span class="tm-banner-cta">Wybieram TOP CUT</span>
            </div>
          </a>
        </div>
      </div>

      <!-- Hook Home (np. ps_featuredproducts - Nowe produkty / Bestsellery) -->
      {block name='hook_home'}
        {$HOOK_HOME nofilter}
      {/block}

      <!-- Żółty Baner MEBLE OGRODOWE (z 1. strony PDF) -->
      <div class="topmarket-home-promo-banner-wrap">
        <div class="container">
          <a href="{$urls.base_url}11-ogrod" class="topmarket-promo-card-banner banner-yellow" title="Totalna wyprzedaż mebli ogrodowych">
            <img src="/themes/topmarket-child/assets/img/banner-meble-ogrodowe.webp" alt="Totalna wyprzedaż MEBLI OGRODOWYCH - KUPUJĘ" class="img-fluid w-100" loading="lazy" width="1600" height="180">
            <div class="tm-banner-overlay tm-banner-overlay-dark">
              <span class="tm-banner-subtitle">Totalna wyprzedaż</span>
              <strong class="tm-banner-title">MEBLI OGRODOWYCH</strong>
              <span class="tm-banner-cta-dark">KUPUJĘ</span>
            </div>
          </a>
        </div>
      </div>

      <!-- Baner ŚRODKI CZYSTOŚCI (ze 2. strony PDF) -->
      <div class="topmarket-home-promo-banner-wrap">
        <div class="container">
          <a href="{$urls.base_url}10-dom" class="topmarket-promo-card-banner banner-czystosc" title="Najlepszy wybór środków czystości">
            <img src="/themes/topmarket-child/assets/img/banner-czystosc.webp" alt="Najlepszy wybór ŚRODKÓW CZYSTOŚCI - KUPUJĘ" class="img-fluid w-100" loading="lazy" width="1600" height="180">
            <div class="tm-banner-overlay tm-banner-overlay-dark">
              <span class="tm-banner-subtitle">Najlepszy wybór</span>
              <strong class="tm-banner-title">ŚRODKÓW CZYSTOŚCI</strong>
              <span class="tm-banner-cta-dark">KUPUJĘ</span>
            </div>
          </a>
        </div>
      </div>

      <!-- 3. Sekcja TOP KATEGORIE (ze 2. strony PDF) -->
      <section class="topmarket-home-section topmarket-top-categories" aria-label="Najpopularniejsze kategorie">
        <div class="container">
          <h2 class="section-title-divider"><span>TOP KATEGORIE</span></h2>
          <div class="top-categories-grid">
            <a href="{$urls.base_url}11-ogrod" class="top-cat-card" title="Odśnieżarki i zamiatarki">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-odsniezarki.webp" alt="Odśnieżarki i zamiatarki" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">ODŚNIEŻARKI I<br>ZAMIATARKI</span>
            </a>
            <a href="{$urls.base_url}13-narzedzia" class="top-cat-card" title="Narzędzia">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-narzedzia.webp" alt="Narzędzia" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">NARZĘDZIA</span>
            </a>
            <a href="{$urls.base_url}11-ogrod" class="top-cat-card" title="Meble ogrodowe">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-meble-ogrod.webp" alt="Meble ogrodowe" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">MEBLE OGRODOWE</span>
            </a>
            <a href="{$urls.base_url}10-dom" class="top-cat-card" title="Meble do domu">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-meble-dom.webp" alt="Meble do domu" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">MEBLE DO DOMU</span>
            </a>
            <a href="{$urls.base_url}10-dom" class="top-cat-card" title="Środki czystości">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-czystosc.webp" alt="Środki czystości" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">ŚRODKI CZYSTOŚCI</span>
            </a>
            <a href="{$urls.base_url}13-narzedzia" class="top-cat-card" title="Produkty NAC">
              <div class="top-cat-img-box"><img src="/themes/topmarket-child/assets/img/cat-nac.webp" alt="Produkty NAC" loading="lazy" width="140" height="140"></div>
              <span class="top-cat-label">PRODUKTY NAC</span>
            </a>
          </div>
        </div>
      </section>

      <!-- Sekcja NARZĘDZIA (pionowy portret po lewej + 3 produkty po prawej jak w TopMarket) -->
      <section class="tm-tools-showcase-section" aria-label="Polecane narzędzia">
        <div class="container">
          <div class="tm-tools-showcase-grid">
            <a href="{$urls.base_url}13-narzedzia" class="tm-tools-portrait-card" title="Duży wybór narzędzi">
              <img src="/themes/topmarket-child/assets/img/banner-narzedzia.webp" alt="Duży wybór NARZĘDZI - Kupuję" loading="lazy" width="295" height="456">
              <div class="tm-tools-portrait-overlay">
                <span class="tm-banner-subtitle">Duży wybór</span>
                <strong class="tm-banner-title">NARZĘDZI</strong>
                <span class="tm-tools-portrait-cta">Kupuję</span>
              </div>
            </a>

            <article class="product-miniature js-product-miniature">
              <div class="thumbnail-container">
                <div class="thumbnail-top">
                  <div class="tm-card-badges"><span class="topmarket-badge-shipping">WYSYŁKA DZIŚ</span></div>
                  <a href="{$urls.base_url}ogrod/37-wszechstronny-akumulator-nac-b18-60-s-18v-6ah.html" class="thumbnail product-thumbnail" aria-label="Wszechstronny Akumulator NAC B18-60-S 18V, 6Ah">
                    <img src="{$urls.base_url}77-home_default/wszechstronny-akumulator-nac-b18-60-s-18v-6ah.jpg" alt="Wszechstronny Akumulator NAC B18-60-S 18V, 6Ah" loading="lazy" width="250" height="250">
                  </a>
                </div>
                <div class="product-description">
                  <h3 class="h3 product-title"><a href="{$urls.base_url}ogrod/37-wszechstronny-akumulator-nac-b18-60-s-18v-6ah.html">Wszechstronny Akumulator NAC B18-60-S 18V, 6Ah</a></h3>
                  <div class="product-price-and-shipping">
                    <span class="price product-price"><span class="price-int">293</span><sup class="price-dec">90zł</sup></span>
                  </div>
                </div>
              </div>
            </article>

            <article class="product-miniature js-product-miniature">
              <div class="thumbnail-container">
                <div class="thumbnail-top">
                  <div class="tm-card-badges"><span class="topmarket-badge-shipping">WYSYŁKA DZIŚ</span></div>
                  <a href="{$urls.base_url}ogrod/38-wysokiej-jakosci-olej-do-sprezarek-nac-ldaa-100-0-6l.html" class="thumbnail product-thumbnail" aria-label="Wysokiej Jakości Olej Do Sprężarek NAC LDAA-100 0,6L">
                    <img src="{$urls.base_url}80-home_default/wysokiej-jakosci-olej-do-sprezarek-nac-ldaa-100-0-6l.jpg" alt="Wysokiej Jakości Olej Do Sprężarek NAC LDAA-100 0,6L" loading="lazy" width="250" height="250">
                  </a>
                </div>
                <div class="product-description">
                  <h3 class="h3 product-title"><a href="{$urls.base_url}ogrod/38-wysokiej-jakosci-olej-do-sprezarek-nac-ldaa-100-0-6l.html">Wysokiej Jakości Olej Do Sprężarek NAC LDAA-100 0,6L</a></h3>
                  <div class="product-price-and-shipping">
                    <span class="price product-price"><span class="price-int">29</span><sup class="price-dec">99zł</sup></span>
                  </div>
                </div>
              </div>
            </article>

            <article class="product-miniature js-product-miniature">
              <div class="thumbnail-container">
                <div class="thumbnail-top">
                  <div class="tm-card-badges"><span class="topmarket-badge-shipping">WYSYŁKA DZIŚ</span></div>
                  <a href="{$urls.base_url}ogrod/39-toporek-siekiera-rozlupujaca-z-jednego-kawalka-stali-uchwyt-antywibracyjny-6g-nac-ht-0620-fs-620g.html" class="thumbnail product-thumbnail" aria-label="Toporek Siekiera Rozłupująca NAC HT-0620-FS 620g">
                    <img src="{$urls.base_url}82-home_default/toporek-siekiera-rozlupujaca-z-jednego-kawalka-stali-uchwyt-antywibracyjny-6g-nac-ht-0620-fs-620g.jpg" alt="Toporek Siekiera Rozłupująca NAC HT-0620-FS 620g" loading="lazy" width="250" height="250">
                  </a>
                </div>
                <div class="product-description">
                  <h3 class="h3 product-title"><a href="{$urls.base_url}ogrod/39-toporek-siekiera-rozlupujaca-z-jednego-kawalka-stali-uchwyt-antywibracyjny-6g-nac-ht-0620-fs-620g.html">Toporek Siekiera Rozłupująca Z Jednego Kawałka Stali NAC HT-0620-FS 620g</a></h3>
                  <div class="product-price-and-shipping">
                    <span class="price product-price"><span class="price-int">69</span><sup class="price-dec">00zł</sup></span>
                  </div>
                </div>
              </div>
            </article>
          </div>
        </div>
      </section>

      <!-- 4. Granatowy Pasek Odbierz 20 zł na zakupy (z 3. strony PDF) -->
      <div class="topmarket-blue-promo-strip">
        <div class="container text-center">
          <span class="blue-strip-text">Odbierz 20 złotych na zakupy!</span>
        </div>
      </div>

      <!-- 5. Sekcja MARKI (z logotypami i odnośnikami do filtrowania produktów danej marki) -->
      <section class="topmarket-home-section topmarket-brands-section" aria-label="Zaufane marki">
        <div class="container">
          <h2 class="section-title-divider"><span>MARKI</span></h2>
          <div class="topmarket-brands-carousel">
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=NAC" class="brand-logo-card" title="Produkty marki NAC"><img src="/themes/topmarket-child/assets/img/brands/nac.jpg" alt="NAC" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Meven" class="brand-logo-card" title="Produkty marki Meven"><img src="/themes/topmarket-child/assets/img/brands/meven.jpg" alt="Meven" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Curver" class="brand-logo-card" title="Produkty marki Curver"><img src="/themes/topmarket-child/assets/img/brands/curver.jpg" alt="Curver" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Keter" class="brand-logo-card" title="Produkty marki Keter"><img src="/themes/topmarket-child/assets/img/brands/keter.jpg" alt="Keter" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Cellfast" class="brand-logo-card" title="Produkty marki Cellfast"><img src="/themes/topmarket-child/assets/img/brands/cellfast.jpg" alt="Cellfast" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Glade" class="brand-logo-card" title="Produkty marki Glade"><img src="/themes/topmarket-child/assets/img/brands/glade.jpg" alt="Glade" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Vileda" class="brand-logo-card" title="Produkty marki Vileda"><img src="/themes/topmarket-child/assets/img/brands/vileda.jpg" alt="Vileda" loading="lazy" width="98" height="127"></a>
            <a href="{$urls.base_url}szukaj?controller=search&amp;s=Russell+Hobbs" class="brand-logo-card" title="Produkty marki Russell Hobbs"><img src="/themes/topmarket-child/assets/img/brands/russell-hobbs.jpg" alt="Russell Hobbs" loading="lazy" width="98" height="127"></a>
          </div>
        </div>
      </section>

      <!-- Notka o darmowej dostawie (ze 4. strony PDF) -->
      <div class="topmarket-disclaimer-wrapper">
        <div class="container">
          <p class="topmarket-disclaimer-text">* Darmowa dostawa obowiązuje dla zamówień powyżej 2000 zł brutto. Maksymalna waga zamówienia wynosi 50 kg.</p>
        </div>
      </div>
    {/block}
  </section>
{/block}
