{**
 * TopMarket Child Theme - Footer Template
 * Domitek E-Commerce (Układ 6-kolumnowy 1:1 TopMarket.pl z danymi Domitek)
 *}
<footer id="footer" class="pb-lg-0 page-footer topmarket-footer">
  <div class="footer-container footer-style-1" id="footer-container-main">
    <div class="container">
      <div class="footer-main-row">
        <!-- 1. Kolumna: Ważne informacje -->
        <div class="footer-col footer-col-info">
          <h4 class="footer-block-title footer-heading"><span>Ważne informacje</span></h4>
          <div class="block-content">
            <ul class="footer-links-list">
              <li><a href="{$urls.base_url}content/3-regulamin" title="Regulamin sklepu"><span class="chevron">&rsaquo;</span> Regulamin</a></li>
              <li><a href="{$urls.base_url}content/1-dostawa" title="Dostawa i Zwroty"><span class="chevron">&rsaquo;</span> Dostawa i Zwroty</a></li>
              <li><a href="{$urls.pages.contact}" title="Reklamacje"><span class="chevron">&rsaquo;</span> Reklamacje</a></li>
              <li><a href="{$urls.base_url}content/2-polityka-prywatnosci" title="Polityka prywatności"><span class="chevron">&rsaquo;</span> Polityka Prywatności</a></li>
              <li><a href="{$urls.base_url}content/5-platnosci" title="Bezpieczne formy płatności"><span class="chevron">&rsaquo;</span> Płatności</a></li>
              <li><a href="{$urls.pages.my_account}" title="Moje konto"><span class="chevron">&rsaquo;</span> Moje konto</a></li>
              <li><a href="{$urls.pages.history}" title="Historia zamówień"><span class="chevron">&rsaquo;</span> Historia zamówień</a></li>
              <li><a href="{$urls.pages.contact}" title="Kontakt z nami"><span class="chevron">&rsaquo;</span> Kontakt z nami</a></li>
            </ul>
          </div>
        </div>

        <!-- 2. Kolumna: Poznaj Domitek -->
        <div class="footer-col footer-col-about">
          <h4 class="footer-block-title footer-heading"><span>Poznaj Domitek</span></h4>
          <div class="block-content">
            <ul class="footer-links-list">
              <li><a href="{$urls.base_url}content/4-o-sklepie" title="O nas"><span class="chevron">&rsaquo;</span> O nas</a></li>
              <li><a href="{$urls.base_url}" title="Facebook Domitek"><span class="chevron">&rsaquo;</span> Facebook</a></li>
              <li><a href="{$urls.base_url}" title="Instagram Domitek"><span class="chevron">&rsaquo;</span> Instagram</a></li>
              <li><a href="{$urls.pages.contact}" title="Newsletter"><span class="chevron">&rsaquo;</span> Newsletter</a></li>
            </ul>
          </div>
        </div>

        <!-- 3. Kolumna: Kontakt z nami -->
        <div class="footer-col footer-col-contact">
          <h4 class="footer-block-title footer-heading"><span>Kontakt z nami</span></h4>
          <div class="block-content footer-contact-content">
            <p class="footer-brand-title"><strong>Domitek.pl</strong></p>
            <hr class="footer-hr">
            <div class="footer-contact-part">
              <i class="material-icons contact-icon" aria-hidden="true">&#xE0B0;</i>
              <div class="contact-details">
                <a href="tel:+48221234567" class="phone-link" aria-label="Infolinia Domitek: +48 22 123 45 67">+48 22 123 45 67</a>
                <span class="work-hours">pn. - pt. 8:00 - 18:00</span>
              </div>
            </div>
            <hr class="footer-hr">
            <div class="footer-contact-part">
              <i class="material-icons contact-icon" aria-hidden="true">&#xE0BE;</i>
              <div class="contact-details">
                <a href="mailto:sklep@domitek.pl" class="email-link" aria-label="Adres e-mail: sklep@domitek.pl">sklep@domitek.pl</a>
              </div>
            </div>
            <hr class="footer-hr">
            <p class="contact-form-link-p">
              <a href="{$urls.pages.contact}" class="footer-contact-text-link" title="Przejdź do formularza kontaktowego">Formularz kontaktowy</a>
            </p>
          </div>
        </div>

        <!-- 4. Kolumna: Bezpieczne płatności -->
        <div class="footer-col footer-col-payments">
          <h4 class="footer-block-title footer-heading"><span>Bezpieczne płatności</span></h4>
          <div class="block-content">
            <img src="/themes/topmarket-child/assets/img/metody-platnosci.png" alt="Bezpieczne metody płatności: przelew tradycyjny, płatność przy odbiorze" class="img-fluid footer-payments-img" loading="lazy" width="366" height="80">
          </div>
        </div>

        <!-- 5. Kolumna: Dostawy -->
        <div class="footer-col footer-col-delivery">
          <h4 class="footer-block-title footer-heading"><span>Dostawy</span></h4>
          <div class="block-content">
            <img src="/themes/topmarket-child/assets/img/metody-dostaw.png" alt="Metody dostaw: InPost Paczkomaty, DPD, DHL" class="img-fluid footer-delivery-img" loading="lazy" width="366" height="80">
          </div>
        </div>

        <!-- 6. Kolumna: Obserwuj nas -->
        <div class="footer-col footer-col-social">
          <h4 class="footer-block-title footer-heading"><span>Obserwuj nas</span></h4>
          <div class="block-content footer-social-icons">
            <a href="{$urls.base_url}" class="footer-social-link" aria-label="Domitek na Facebooku" title="Facebook">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M14 13.5h2.5l1-4H14v-2c0-1.03 0-2 2-2h1.5V2.14c-.326-.043-1.557-.14-2.857-.14C11.928 2 10 3.657 10 6.7v2.8H7v4h3V22h4v-8.5z"/></svg>
            </a>
            <a href="{$urls.base_url}" class="footer-social-link" aria-label="Domitek na Instagramie" title="Instagram">
              <svg width="26" height="26" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Pasek praw autorskich na samym dole (.footer-after / #footer-copyrights) -->
  <div class="footer-after _footer-copyrights-1 dropup" id="footer-copyrights">
    <div class="container">
      <div class="row align-items-center">
        <div class="col-12 col-sm-6 text-sm-left copyright-txt">
          <p class="copyright-text">
            © 2026 <strong>Domitek</strong>. Wszelkie prawa zastrzeżone.
          </p>
        </div>
        <div class="col-12 col-sm-6 text-sm-right copyright-img">
          <div class="footer-copyright-right-wrap">
            <img src="/themes/topmarket-child/assets/img/logo-domitek.svg" alt="Domitek" class="img-fluid footer-brand-logo-img" loading="lazy" width="140" height="42">
            <a href="#header" class="btn-back-to-top" aria-label="Wróć na górę strony">
              <i class="material-icons" aria-hidden="true">&#xE5D8;</i>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</footer>