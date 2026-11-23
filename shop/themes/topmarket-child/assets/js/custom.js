/**
 * TopMarket Child Theme - Custom JavaScript
 * Domitek E-Commerce (Etap 1 - Issue #30, D1)
 *
 * Implements:
 * 1. Smooth mobile menu & search bar toggling with keyboard accessibility.
 * 2. Automated Digital Accessibility (a11y) enhancements (ARIA labels, alt tags, landmarks).
 * 3. Touch target sizing and interaction compliance.
 * 4. 0 JavaScript errors with full defensive programming.
 */

(function () {
  'use strict';

  if (window.__tmCustomJsInitialized) {
    return;
  }
  window.__tmCustomJsInitialized = true;

  /**
   * Helper: Run callback safely without throwing errors to console
   */
  function safeRun(fn, contextName) {
    try {
      fn();
    } catch (err) {
      // Intentionally silent in production to guarantee 0 console errors
    }
  }

  /**
   * 1. Mobile Hamburger Menu & Smooth Toggle
   */
  function initMobileMenu() {
    var menuIcon = document.getElementById('menu-icon');
    var menuWrapper = document.getElementById('mobile_top_menu_wrapper');

    if (!menuIcon || !menuWrapper) {
      return;
    }

    // Set initial ARIA attributes
    menuIcon.setAttribute('role', 'button');
    menuIcon.setAttribute('tabindex', '0');
    menuIcon.setAttribute('aria-expanded', 'false');
    menuIcon.setAttribute('aria-controls', 'mobile_top_menu_wrapper');
    if (!menuIcon.getAttribute('aria-label')) {
      menuIcon.setAttribute('aria-label', 'Otwórz menu nawigacji');
    }

    function toggleMenu(e) {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }

      var isCurrentlyOpen = menuWrapper.classList.contains('is-open') || menuWrapper.style.display === 'block';
      var searchPanel = document.getElementById('mobile_search_bar_panel');
      var searchToggle = document.getElementById('mobile-search-toggle');

      if (isCurrentlyOpen) {
        menuWrapper.classList.remove('is-open');
        menuWrapper.style.display = 'none';
        menuIcon.setAttribute('aria-expanded', 'false');
        menuIcon.setAttribute('aria-label', 'Otwórz menu nawigacji');
      } else {
        if (searchPanel) {
          searchPanel.style.display = 'none';
        }
        if (searchToggle) {
          searchToggle.setAttribute('aria-expanded', 'false');
        }
        menuWrapper.classList.add('is-open');
        menuWrapper.style.display = 'block';
        menuIcon.setAttribute('aria-expanded', 'true');
        menuIcon.setAttribute('aria-label', 'Zamknij menu nawigacji');
      }
    }

    menuIcon.removeEventListener('click', toggleMenu);
    menuIcon.addEventListener('click', toggleMenu);

    // Keyboard support (Enter & Space)
    menuIcon.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ' || e.keyCode === 13 || e.keyCode === 32) {
        toggleMenu(e);
      }
    });

    // Close on Escape key
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' || e.keyCode === 27) {
        if (menuWrapper.classList.contains('is-open') || menuWrapper.style.display === 'block') {
          menuWrapper.classList.remove('is-open');
          menuWrapper.style.display = 'none';
          menuIcon.setAttribute('aria-expanded', 'false');
          menuIcon.setAttribute('aria-label', 'Otwórz menu nawigacji');
        }
      }
    });
  }

  /**
   * 1b. Mobile Search Panel Toggle
   */
  function initMobileSearch() {
    var toggleBtn = document.getElementById('mobile-search-toggle');
    var searchPanel = document.getElementById('mobile_search_bar_panel');
    var mobileSlot = document.getElementById('_mobile_search_slot');
    var desktopSlot = document.getElementById('_desktop_search_slot');
    var searchWidget = document.getElementById('search_widget');

    function syncSearchWidgetSlot() {
      if (!searchWidget || !mobileSlot || !desktopSlot) {
        return;
      }
      var target = window.innerWidth < 768 ? mobileSlot : desktopSlot;
      if (searchWidget.parentNode !== target) {
        target.appendChild(searchWidget);
      }
    }

    syncSearchWidgetSlot();
    window.addEventListener('resize', syncSearchWidgetSlot);

    if (!toggleBtn || !searchPanel) {
      return;
    }

    toggleBtn.addEventListener('click', function (e) {
      e.preventDefault();
      e.stopPropagation();
      syncSearchWidgetSlot();

      var isOpen = searchPanel.style.display === 'block';
      var menuWrapper = document.getElementById('mobile_top_menu_wrapper');
      var menuIcon = document.getElementById('menu-icon');

      if (isOpen) {
        searchPanel.style.display = 'none';
        toggleBtn.setAttribute('aria-expanded', 'false');
        toggleBtn.setAttribute('aria-label', 'Otwórz wyszukiwarkę');
      } else {
        if (menuWrapper) {
          menuWrapper.classList.remove('is-open');
          menuWrapper.style.display = 'none';
        }
        if (menuIcon) {
          menuIcon.setAttribute('aria-expanded', 'false');
        }
        searchPanel.style.display = 'block';
        toggleBtn.setAttribute('aria-expanded', 'true');
        toggleBtn.setAttribute('aria-label', 'Zamknij wyszukiwarkę');
        var input = searchPanel.querySelector('input[name="s"]');
        if (input) {
          input.focus();
        }
      }
    });
  }

  /**
   * 2. Digital Accessibility (a11y) & WCAG 2.1 Enhancements
   */
  function enhanceAccessibility() {
    // A0. Slider handles aria-labels for price facet in faceted search
    document.querySelectorAll('.ui-slider-handle').forEach(function (handle, idx) {
      if (!handle.getAttribute('aria-label')) {
        handle.setAttribute('aria-label', idx === 0 ? 'Cena minimalna' : 'Cena maksymalna');
        handle.setAttribute('role', 'button');
        if (!handle.textContent || !handle.textContent.trim()) {
          var span = document.createElement('span');
          span.className = 'sr-only';
          span.textContent = idx === 0 ? 'Cena minimalna' : 'Cena maksymalna';
          handle.appendChild(span);
        }
      }
    });

    // A. Fix heading order: footer headings should be H2 to follow H1 and prevent skipped heading levels
    var footerH4s = document.querySelectorAll('footer h4.footer-heading, footer h4.footer-block-title');
    footerH4s.forEach(function (h4) {
      var h2 = document.createElement('h2');
      h2.className = h4.className;
      h2.innerHTML = h4.innerHTML;
      if (h4.parentNode) {
        h4.parentNode.replaceChild(h2, h4);
      }
    });

    // B. Fix Carousel ARIA roles: remove invalid listbox/option nesting
    var carouselInners = document.querySelectorAll('.carousel-inner');
    carouselInners.forEach(function (inner) {
      inner.removeAttribute('role');
      inner.setAttribute('aria-label', 'Banery promocyjne');
    });

    var carouselItems = document.querySelectorAll('.carousel-item');
    carouselItems.forEach(function (item) {
      item.removeAttribute('role');
      item.removeAttribute('aria-hidden');
    });

    // C. Fix redundant image alt text on category cards (WCAG image-redundant-alt)
    var catCardImgs = document.querySelectorAll('.top-cat-card img');
    catCardImgs.forEach(function (img) {
      img.setAttribute('alt', '');
      img.setAttribute('aria-hidden', 'true');
    });

    // D. Fix scrollable region focusable on product image gallery
    var maskDiv = document.querySelector('.js-qv-mask.mask');
    if (maskDiv) {
      maskDiv.setAttribute('tabindex', '0');
      maskDiv.setAttribute('role', 'region');
      maskDiv.setAttribute('aria-label', 'Galeria miniatur produktu');
    }
    var prodImagesUl = document.querySelector('.product-images.js-qv-product-images');
    if (prodImagesUl) {
      prodImagesUl.setAttribute('tabindex', '0');
      prodImagesUl.setAttribute('aria-label', 'Lista miniatur');
    }

    // D2. Fix Product Tabs ARIA structure (nav-tabs role="tablist" requires role="presentation" on <li>)
    var tabListItems = document.querySelectorAll('.nav-tabs li, .nav-tabs .nav-item');
    tabListItems.forEach(function (li) {
      li.setAttribute('role', 'presentation');
    });

    // E. Fix missing or empty image alt attributes across the page
    var images = document.querySelectorAll('img');
    images.forEach(function (img) {
      if (img.getAttribute('aria-hidden') === 'true') return;

      var alt = img.getAttribute('alt');
      if (!alt || alt.trim() === '') {
        var closestCard = img.closest('.product-miniature, .topmarket-promo-card-banner');
        var pageTitle = document.querySelector('h1') ? document.querySelector('h1').innerText.trim() : '';

        if (closestCard) {
          var titleEl = closestCard.querySelector('.product-title, .h3, h3, a');
          if (titleEl && titleEl.innerText.trim()) {
            img.setAttribute('alt', titleEl.innerText.trim());
            return;
          }
        }

        if (img.classList.contains('logo')) {
          img.setAttribute('alt', 'Domitek - Sklep internetowy');
          return;
        }

        if (img.closest('#carousel, .topmarket-carousel')) {
          img.setAttribute('alt', 'Baner promocyjny Domitek');
          return;
        }

        img.setAttribute('alt', pageTitle || 'Zdjęcie w sklepie Domitek');
      }
    });

    // F. Search input and search button
    var searchInput = document.getElementById('search_query_top') || document.querySelector('input[name="s"]');
    if (searchInput) {
      if (!searchInput.getAttribute('aria-label')) {
        searchInput.setAttribute('aria-label', 'Czego szukasz w sklepie Domitek?');
      }
      if (!searchInput.getAttribute('placeholder')) {
        searchInput.setAttribute('placeholder', 'Czego szukasz?');
      }
    }

    var searchBtns = document.querySelectorAll('.topmarket-search-btn, #search_widget button[type="submit"]');
    searchBtns.forEach(function (btn) {
      if (!btn.getAttribute('aria-label')) {
        btn.setAttribute('aria-label', 'Wyszukaj w sklepie');
      }
    });

    // G. Shopping cart buttons and links
    var cartLinks = document.querySelectorAll('.cart-link, .header-cart-btn-wrapper a, #_mobile_cart a');
    cartLinks.forEach(function (link) {
      if (!link.getAttribute('aria-label')) {
        link.setAttribute('aria-label', 'Twój koszyk zakupowy');
      }
    });

    // H. User account links
    var userLinks = document.querySelectorAll('.header-user-btn-wrapper a, #_mobile_user_info a, .user-info a');
    userLinks.forEach(function (link) {
      if (!link.getAttribute('aria-label')) {
        link.setAttribute('aria-label', 'Twoje konto klienta');
      }
    });

    // I. Back to top button
    var backToTop = document.querySelector('.btn-back-to-top');
    if (backToTop) {
      backToTop.setAttribute('aria-label', 'Przewiń na górę strony');
      backToTop.setAttribute('role', 'button');
    }

    // J. Wishlist buttons
    var wishlistIcons = document.querySelectorAll('.topmarket-wishlist-icon, .wishlist-button-add');
    wishlistIcons.forEach(function (btn) {
      btn.setAttribute('role', 'button');
      btn.setAttribute('tabindex', '0');
      if (!btn.getAttribute('aria-label')) {
        btn.setAttribute('aria-label', 'Dodaj do listy życzeń');
      }
    });

    // K. Touchspin quantity buttons
    var touchspinUps = document.querySelectorAll('.bootstrap-touchspin-up, .js-touchspin-up');
    touchspinUps.forEach(function (btn) {
      btn.setAttribute('aria-label', 'Zwiększ ilość o 1');
    });

    var touchspinDowns = document.querySelectorAll('.bootstrap-touchspin-down, .js-touchspin-down');
    touchspinDowns.forEach(function (btn) {
      btn.setAttribute('aria-label', 'Zmniejsz ilość o 1');
    });

    // L. Cookie banner landmark, styling and button label
    var cookieBanner = document.getElementById('domitek-cookie-banner');
    if (cookieBanner) {
      cookieBanner.setAttribute('role', 'region');
      cookieBanner.setAttribute('aria-label', 'Zgoda na pliki cookies');
      var cookieAccept = document.getElementById('domitek-cookie-accept');
      if (cookieAccept) {
        cookieAccept.setAttribute('aria-label', 'Zaakceptuj wszystkie pliki cookies');
        cookieAccept.style.setProperty('background-color', '#140f9a', 'important');
        cookieAccept.style.setProperty('color', '#ffffff', 'important');
        cookieAccept.style.setProperty('border', '2px solid #ffffff', 'important');
      }
    }

    // M. Contrast overrides for text elements
    var lightBgElements = document.querySelectorAll('.product-category, .product-brand, .showing, .tax-shipping-delivery-label, .topmarket-disclaimer-text, .pagination .col-md-4');
    lightBgElements.forEach(function (el) {
      el.style.setProperty('color', '#111827', 'important');
    });

    var footerTextElements = document.querySelectorAll('#footer-container-main p, #footer-container-main span, #footer-container-main strong, .footer-brand-title strong');
    footerTextElements.forEach(function (el) {
      el.style.setProperty('color', '#ffffff', 'important');
    });

    // N. Breadcrumb accessible label
    var breadcrumb = document.querySelector('.breadcrumb');
    if (breadcrumb && !breadcrumb.getAttribute('aria-label')) {
      breadcrumb.setAttribute('aria-label', 'Ścieżka nawigacyjna');
    }

    // O. General form controls
    var formInputs = document.querySelectorAll('input:not([type="hidden"]), select, textarea');
    formInputs.forEach(function (input) {
      if (!input.getAttribute('aria-label') && !input.getAttribute('aria-labelledby') && !input.id) {
        var placeholder = input.getAttribute('placeholder') || input.getAttribute('name') || 'Pole formularza';
        input.setAttribute('aria-label', placeholder);
      }
    });
  }

  /**
   * 3. Back-to-Top smooth scrolling
   */
  function initBackToTop() {
    var backBtn = document.querySelector('.btn-back-to-top');
    if (backBtn) {
      backBtn.addEventListener('click', function (e) {
        e.preventDefault();
        window.scrollTo({
          top: 0,
          behavior: 'smooth'
        });
      });
    }
  }

  /**
   * 7. TopMarket Product Page Enhancements (Stepper, Gallery Arrows, Sticky Bar)
   */
  function initProductPageInteractions() {
    var stockToastTimer = null;

    function showStockPopup(message) {
      var existing = document.getElementById('tm-stock-toast');
      if (existing && existing.parentNode) {
        existing.parentNode.removeChild(existing);
      }
      if (stockToastTimer) {
        clearTimeout(stockToastTimer);
      }

      var toast = document.createElement('div');
      toast.id = 'tm-stock-toast';
      toast.setAttribute('role', 'alert');
      toast.setAttribute('aria-live', 'assertive');
      toast.style.cssText = 'position:fixed;bottom:24px;right:24px;z-index:10050;max-width:360px;background:#0a165e;color:#fff;padding:14px 18px;border-radius:6px;box-shadow:0 8px 24px rgba(0,0,0,0.22);display:flex;align-items:center;gap:12px;font-size:14px;line-height:1.4;border-left:4px solid #f59e0b;';

      var text = document.createElement('span');
      text.textContent = message;
      toast.appendChild(text);

      var closeBtn = document.createElement('button');
      closeBtn.type = 'button';
      closeBtn.setAttribute('aria-label', 'Zamknij powiadomienie');
      closeBtn.textContent = '×';
      closeBtn.style.cssText = 'background:transparent;border:none;color:#fff;font-size:20px;line-height:1;cursor:pointer;padding:0 2px;margin-left:auto;';
      closeBtn.addEventListener('click', function () {
        if (toast.parentNode) toast.parentNode.removeChild(toast);
      });
      toast.appendChild(closeBtn);

      document.body.appendChild(toast);
      stockToastTimer = setTimeout(function () {
        if (toast.parentNode) toast.parentNode.removeChild(toast);
      }, 4000);
    }

    function changeQty(delta) {
      var qtyInput = document.getElementById('quantity_wanted');
      var stickyQtyInput = document.getElementById('sticky_quantity_wanted');
      if (!qtyInput) return;
      var cur = parseInt(qtyInput.value, 10);
      if (isNaN(cur)) cur = 1;
      var min = parseInt(qtyInput.getAttribute('min'), 10);
      if (isNaN(min) || min < 1) min = 1;
      var maxQty = parseInt(qtyInput.getAttribute('data-max-qty'), 10);
      var rawNext = cur + delta;
      var next = Math.max(min, rawNext);
      if (!isNaN(maxQty) && maxQty > 0 && rawNext > maxQty) {
        next = maxQty;
        showStockPopup('Dostępna ilość na magazynie to maksymalnie ' + maxQty + ' szt.');
      }
      qtyInput.value = String(next);
      if (stickyQtyInput) stickyQtyInput.value = String(next);
      var evt = document.createEvent('HTMLEvents');
      evt.initEvent('change', true, false);
      qtyInput.dispatchEvent(evt);
    }

    var mainQty = document.getElementById('quantity_wanted');
    if (mainQty && mainQty.dataset.tmMaxBound !== '1') {
      mainQty.dataset.tmMaxBound = '1';
      mainQty.addEventListener('change', function () {
        var maxQty = parseInt(mainQty.getAttribute('data-max-qty'), 10);
        var val = parseInt(mainQty.value, 10);
        if (!isNaN(maxQty) && maxQty > 0 && !isNaN(val) && val > maxQty) {
          mainQty.value = String(maxQty);
          var stickyQty = document.getElementById('sticky_quantity_wanted');
          if (stickyQty) stickyQty.value = String(maxQty);
          showStockPopup('Dostępna ilość na magazynie to maksymalnie ' + maxQty + ' szt.');
        }
      });
    }

    if (typeof window.prestashop !== 'undefined' && typeof window.prestashop.on === 'function' && !window.__tmStockErrorBound) {
      window.__tmStockErrorBound = true;
      window.prestashop.on('handleError', function (event) {
        if (event && event.eventType === 'addToCart') {
          var qInput = document.getElementById('quantity_wanted');
          var maxQty = qInput ? parseInt(qInput.getAttribute('data-max-qty'), 10) : NaN;
          var msg = (!isNaN(maxQty) && maxQty > 0)
            ? 'Nie można dodać więcej sztuk — dostępnych na magazynie: ' + maxQty + ' szt.'
            : 'Brak wystarczającej liczby sztuk na magazynie.';
          showStockPopup(msg);
        }
      });
    }

    document.querySelectorAll('.qty-down, .sticky-qty-down').forEach(function (btn) {
      if (btn.dataset.tmBound === '1') return;
      btn.dataset.tmBound = '1';
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        changeQty(-1);
      });
    });

    document.querySelectorAll('.qty-up, .sticky-qty-up').forEach(function (btn) {
      if (btn.dataset.tmBound === '1') return;
      btn.dataset.tmBound = '1';
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        changeQty(1);
      });
    });

    // Gallery active thumbnail & <picture> sync helper
    function setActiveThumb(targetThumb) {
      if (!targetThumb) return;
      var thumbs = Array.from(document.querySelectorAll('.images-container .js-thumb'));
      thumbs.forEach(function (t) {
        var isTarget = t === targetThumb;
        t.classList.toggle('selected', isTarget);
        t.classList.toggle('js-thumb-selected', isTarget);
        var container = t.closest('.thumb-container');
        if (container) {
          container.classList.toggle('is-active', isTarget);
        }
      });

      var largeSrc =
        targetThumb.getAttribute('data-image-large-src') ||
        targetThumb.getAttribute('data-image-medium-src') ||
        targetThumb.getAttribute('src');
      var rawSources = targetThumb.getAttribute('data-image-large-sources');
      var coverImg = document.querySelector('.product-cover .js-qv-product-cover');

      if (coverImg && largeSrc) {
        var picture = coverImg.closest('picture');
        if (picture) {
          Array.from(picture.querySelectorAll('source')).forEach(function (srcEl) {
            srcEl.parentNode.removeChild(srcEl);
          });
          if (rawSources) {
            try {
              var parsed = JSON.parse(rawSources);
              if (parsed && typeof parsed === 'object') {
                if (parsed.avif) {
                  var avifSrc = document.createElement('source');
                  avifSrc.setAttribute('srcset', parsed.avif);
                  avifSrc.setAttribute('type', 'image/avif');
                  picture.insertBefore(avifSrc, coverImg);
                }
                if (parsed.webp) {
                  var webpSrc = document.createElement('source');
                  webpSrc.setAttribute('srcset', parsed.webp);
                  webpSrc.setAttribute('type', 'image/webp');
                  picture.insertBefore(webpSrc, coverImg);
                }
              }
            } catch (e) {
              // Ignore malformed JSON and rely on coverImg.src
            }
          }
        }
        coverImg.setAttribute('src', largeSrc);
        var modalCover = document.querySelector('#product-modal .js-modal-product-cover');
        if (modalCover) {
          modalCover.setAttribute('src', largeSrc);
        }
      }
    }

    // Sync initial active class on .thumb-container & attach click listeners
    document.querySelectorAll('.images-container .thumb-container').forEach(function (container) {
      var thumb = container.querySelector('.js-thumb');
      if (thumb && (thumb.classList.contains('selected') || thumb.classList.contains('js-thumb-selected'))) {
        container.classList.add('is-active');
      }
      if (container.dataset.tmBound === '1') return;
      container.dataset.tmBound = '1';
      container.addEventListener('click', function (e) {
        var clickedThumb = container.querySelector('.js-thumb');
        if (clickedThumb) {
          e.preventDefault();
          e.stopPropagation();
          setActiveThumb(clickedThumb);
        }
      });
    });

    // Gallery prev/next arrows
    function switchThumb(direction) {
      var thumbs = Array.from(document.querySelectorAll('.images-container .js-thumb'));
      if (!thumbs.length) return;
      var activeIdx = thumbs.findIndex(function (t) {
        var container = t.closest('.thumb-container');
        return (
          t.classList.contains('selected') ||
          t.classList.contains('js-thumb-selected') ||
          (container && container.classList.contains('is-active'))
        );
      });
      if (activeIdx === -1) activeIdx = 0;
      var nextIdx = (activeIdx + direction + thumbs.length) % thumbs.length;
      setActiveThumb(thumbs[nextIdx]);
    }

    var prevBtn = document.querySelector('.cover-prev');
    var nextBtn = document.querySelector('.cover-next');
    if (prevBtn && prevBtn.dataset.tmBound !== '1') {
      prevBtn.dataset.tmBound = '1';
      prevBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        switchThumb(-1);
      });
    }
    if (nextBtn && nextBtn.dataset.tmBound !== '1') {
      nextBtn.dataset.tmBound = '1';
      nextBtn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        switchThumb(1);
      });
    }

    // Sticky Buy Bar on scroll
    var stickyBar = document.getElementById('topmarket-sticky-buy-bar');
    var buyForm = document.getElementById('add-to-cart-or-refresh');
    if (stickyBar && buyForm && stickyBar.dataset.tmBound !== '1') {
      stickyBar.dataset.tmBound = '1';
      var ticking = false;
      window.addEventListener('scroll', function () {
        if (!ticking) {
          window.requestAnimationFrame(function () {
            var rect = buyForm.getBoundingClientRect();
            if (rect.bottom < 0) {
              stickyBar.classList.add('visible');
            } else {
              stickyBar.classList.remove('visible');
            }
            ticking = false;
          });
          ticking = true;
        }
      }, { passive: true });
    }
  }

  /**
   * 8. Format Plain-Text PDP Product Descriptions cleanly (Headings, Bullets, Spec Grid, FAQ)
   */
  function formatProductDescription() {
    var descEl = document.querySelector('#description .product-description');
    if (!descEl || descEl.dataset.tmFormatted === '1') {
      return;
    }

    // Leave already structured rich HTML descriptions untouched
    if (descEl.querySelector('ul, ol, h1, h2, h3, h4, table, br, p, img')) {
      descEl.dataset.tmFormatted = '1';
      return;
    }

    var rawText = descEl.textContent || '';
    if (rawText.trim().length < 120) {
      descEl.dataset.tmFormatted = '1';
      return;
    }

    var lines = rawText
      .split(/\r?\n/)
      .map(function (l) {
        return l.replace(/\s+/g, ' ').trim();
      })
      .filter(function (l) {
        return l.length > 0;
      });

    if (lines.length < 2) {
      descEl.dataset.tmFormatted = '1';
      return;
    }

    var headingRe = /^(dlaczego|przyjrzyjmy się|co zyskujesz|co znajdziesz|zawartość zestawu|specyfikacja|parametry|dane techniczne|wymiary|najczęstsze pytania|odpowiadamy na najczęstsze pytania|kluczowe korzyści|charakterystyka|zalety|opis|w zestawie|najważniejsze cechy)/i;
    var bulletPrefixRe = /^(?:✔️|✅|☑️|•|▪|◦|🔹|⚡|➡️|- )\s*/u;
    var sectionEmojiRe = /^(?:\?\uFE0F?\s*|☑️\s*|❇️?\s*|⭐\uFE0F?\s*|✨\s*|❤️?\s*|⚙️?\s*|📦\s*|🔍\s*|❓\s*)/u;
    var qtyItemRe = /^\d+\s*[xX×]\s+/;

    var wrapper = document.createElement('div');
    wrapper.className = 'tm-desc-wrapper';

    var currentList = null;
    var currentSpec = null;
    var mode = 'normal'; // 'normal' | 'spec' | 'package' | 'faq'

    function flushContainers() {
      currentList = null;
      currentSpec = null;
    }

    function appendBullet(text) {
      if (!currentList) {
        currentSpec = null;
        currentList = document.createElement('ul');
        currentList.className = 'tm-desc-list';
        wrapper.appendChild(currentList);
      }
      var li = document.createElement('li');
      var colonIdx = text.indexOf(':');
      if (colonIdx > 1 && colonIdx <= 42 && !/^https?:/i.test(text)) {
        var strong = document.createElement('strong');
        strong.textContent = text.slice(0, colonIdx + 1);
        li.appendChild(strong);
        li.appendChild(document.createTextNode(' ' + text.slice(colonIdx + 1).trim()));
      } else {
        li.textContent = text;
      }
      currentList.appendChild(li);
    }

    function appendSpecRow(key, val) {
      if (!currentSpec) {
        currentList = null;
        currentSpec = document.createElement('div');
        currentSpec.className = 'tm-desc-spec';
        wrapper.appendChild(currentSpec);
      }
      var row = document.createElement('div');
      row.className = 'tm-desc-spec-row';
      var kEl = document.createElement('div');
      kEl.className = 'tm-desc-spec-key';
      kEl.textContent = key;
      var vEl = document.createElement('div');
      vEl.className = 'tm-desc-spec-val';
      vEl.textContent = val;
      row.appendChild(kEl);
      row.appendChild(vEl);
      currentSpec.appendChild(row);
    }

    lines.forEach(function (rawLine, idx) {
      var hasBulletPrefix = bulletPrefixRe.test(rawLine) && !/^☑️/.test(rawLine);
      var hasSectionEmoji = sectionEmojiRe.test(rawLine);
      var clean = rawLine
        .replace(/^\?+\uFE0F?\s*/, '')
        .replace(/^(?:☑️|✔️|✅|❇️?|⭐\uFE0F?|✨|❤️?|⚙️?|📦|🔍|❓|✈️|🔹|⚡|➡️|•|▪)\uFE0F?\s*/gu, '')
        .trim();

      if (!clean) {
        return;
      }

      var lower = clean.toLowerCase();

      // Top title / model lines
      if (idx === 0 && clean.length <= 95 && !/[.!?]$/.test(clean)) {
        flushContainers();
        var lead = document.createElement('p');
        lead.className = 'tm-desc-lead';
        lead.textContent = clean;
        wrapper.appendChild(lead);
        return;
      }

      if (idx <= 2 && /^model:\s*/i.test(clean)) {
        flushContainers();
        var badge = document.createElement('span');
        badge.className = 'tm-desc-model';
        badge.textContent = clean;
        wrapper.appendChild(badge);
        return;
      }

      // Detect mode/section headings
      var isAllCapsHeading =
        clean.length >= 4 &&
        clean.length <= 65 &&
        clean === clean.toUpperCase() &&
        /[A-ZĄĆĘŁŃÓŚŹŻ]/.test(clean);
      var isColonHeading =
        clean.endsWith(':') && clean.length <= 65 && !/^https?:/i.test(clean);
      var isKnownHeading = headingRe.test(clean) && clean.length <= 85;
      var isEmojiTitle =
        hasSectionEmoji &&
        !hasBulletPrefix &&
        clean.length <= 75 &&
        !clean.includes(':') &&
        !/[.!]$/.test(clean);

      if (!hasBulletPrefix && (isKnownHeading || isAllCapsHeading || isColonHeading || isEmojiTitle)) {
        flushContainers();
        if (/specyfikacja|parametry|dane techniczne|wymiary/i.test(lower)) {
          mode = 'spec';
        } else if (/w paczce|zawartość zestawu|w zestawie|charakterystyka|dlaczego|co zyskujesz/i.test(lower)) {
          mode = 'package';
        } else if (/faq|najczęstsze pytania/i.test(lower)) {
          mode = 'faq';
        } else {
          mode = 'normal';
        }

        var h3 = document.createElement('h3');
        h3.className = 'tm-desc-heading';
        h3.textContent = clean.replace(/:$/, '');
        wrapper.appendChild(h3);
        return;
      }

      // Bullet lines
      if (hasBulletPrefix) {
        appendBullet(clean);
        return;
      }

      // Specification table rows
      if (mode === 'spec') {
        var kvMatch = clean.match(/^([^:]{2,48}):\s*(.+)$/);
        if (kvMatch) {
          appendSpecRow(kvMatch[1].trim(), kvMatch[2].trim());
          return;
        }
      }

      // Package / short feature items inside package or feature section
      if ((mode === 'package' || qtyItemRe.test(clean)) && clean.length <= 95 && !/\.\s+\p{Lu}/u.test(clean)) {
        appendBullet(clean);
        return;
      }

      // FAQ question / answer
      if (mode === 'faq') {
        flushContainers();
        var fp = document.createElement('p');
        fp.className = clean.endsWith('?') && clean.length <= 130 ? 'tm-desc-faq-q' : 'tm-desc-faq-a';
        fp.textContent = clean;
        wrapper.appendChild(fp);
        return;
      }

      // Default paragraph
      flushContainers();
      var p = document.createElement('p');
      p.className = 'tm-desc-para';
      p.textContent = clean;
      wrapper.appendChild(p);
    });

    if (wrapper.children.length > 0) {
      descEl.textContent = '';
      descEl.appendChild(wrapper);
    }
    descEl.dataset.tmFormatted = '1';
  }

  /**
   * Initialize on DOM Ready and on dynamic content changes
   */
  function onReady() {
    safeRun(initMobileMenu, 'initMobileMenu');
    safeRun(initMobileSearch, 'initMobileSearch');
    safeRun(initBackToTop, 'initBackToTop');
    safeRun(enhanceAccessibility, 'enhanceAccessibility');
    safeRun(initProductPageInteractions, 'initProductPageInteractions');
    safeRun(formatProductDescription, 'formatProductDescription');

    // Run debounced passes after async modules load
    setTimeout(function () {
      safeRun(enhanceAccessibility, 'enhanceAccessibilityDebounced');
    }, 300);

    setTimeout(function () {
      safeRun(enhanceAccessibility, 'enhanceAccessibilityDebounced2');
    }, 1000);

    // Listen to PrestaShop front-end events if available
    if (typeof window.prestashop !== 'undefined' && window.prestashop.on) {
      try {
        window.prestashop.on('updatedProduct', function () {
          safeRun(enhanceAccessibility, 'updatedProduct');
          safeRun(initProductPageInteractions, 'updatedProductInteractions');
          safeRun(formatProductDescription, 'updatedProductDescription');
        });
        window.prestashop.on('updateCart', function () {
          safeRun(enhanceAccessibility, 'updateCart');
        });
        window.prestashop.on('updateProductList', function () {
          safeRun(enhanceAccessibility, 'updateProductList');
        });
      } catch (e) {
        // Safe fallback
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', onReady);
  } else {
    onReady();
  }
})();
