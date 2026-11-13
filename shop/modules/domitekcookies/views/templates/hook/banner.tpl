<div id="domitek-cookie-banner" style="position: fixed; bottom: 0; left: 0; right: 0; background: rgba(34, 34, 34, 0.96); color: #fff; padding: 16px 24px; z-index: 999999; display: flex; align-items: center; justify-content: space-between; font-size: 14px; box-shadow: 0 -4px 15px rgba(0,0,0,0.25); font-family: sans-serif;">
    <div style="margin-right: 20px; line-height: 1.5;">
        Sklep internetowy <strong>Domitek</strong> wykorzystuje pliki cookies (ciasteczka) w celach statystycznych, funkcjonalnych oraz w celu poprawnego działania serwisu. Możesz określić warunki przechowywania cookies w Twojej przeglądarce. Więcej informacji znajdziesz w naszej <a href="{$domitek_privacy_link|escape:'html':'UTF-8'}" style="color: #2fb5d2; text-decoration: underline; font-weight: 500;">Polityce prywatności</a>.
    </div>
    <button id="domitek-cookie-accept" type="button" style="background: #2fb5d2; color: #fff; border: none; padding: 10px 22px; border-radius: 4px; font-weight: bold; cursor: pointer; white-space: nowrap; font-size: 14px;">Rozumiem i akceptuję</button>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    var banner = document.getElementById("domitek-cookie-banner");
    if (!banner) return;

    if (localStorage.getItem("domitek_cookie_consent") === "accepted") {
        banner.style.display = "none";
    }

    var btn = document.getElementById("domitek-cookie-accept");
    if (btn) {
        btn.addEventListener("click", function() {
            localStorage.setItem("domitek_cookie_consent", "accepted");
            banner.style.display = "none";
        });
    }
});
</script>

