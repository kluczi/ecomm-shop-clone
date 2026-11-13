/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.19-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: prestashop
-- ------------------------------------------------------
-- Server version	10.11.19-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ps_cms`
--

DROP TABLE IF EXISTS `ps_cms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_cms` (
  `id_cms` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_cms_category` int(10) unsigned NOT NULL,
  `position` int(10) unsigned NOT NULL DEFAULT 0,
  `active` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `indexation` tinyint(1) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_cms`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_cms`
--

LOCK TABLES `ps_cms` WRITE;
/*!40000 ALTER TABLE `ps_cms` DISABLE KEYS */;
INSERT INTO `ps_cms` VALUES
(1,1,0,1,0),
(2,1,1,1,0),
(3,1,2,1,0),
(4,1,3,1,0),
(5,1,4,1,0);
/*!40000 ALTER TABLE `ps_cms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_cms_lang`
--

DROP TABLE IF EXISTS `ps_cms_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_cms_lang` (
  `id_cms` int(10) unsigned NOT NULL,
  `id_lang` int(10) unsigned NOT NULL,
  `id_shop` int(10) unsigned NOT NULL DEFAULT 1,
  `meta_title` varchar(255) NOT NULL,
  `head_seo_title` varchar(255) DEFAULT NULL,
  `meta_description` varchar(512) DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `link_rewrite` varchar(128) NOT NULL,
  PRIMARY KEY (`id_cms`,`id_shop`,`id_lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_cms_lang`
--

LOCK TABLES `ps_cms_lang` WRITE;
/*!40000 ALTER TABLE `ps_cms_lang` DISABLE KEYS */;
INSERT INTO `ps_cms_lang` VALUES
(1,1,1,'Dostawa','Dostawa i koszty transportu - Domitek','Informacje o kosztach i czasie dostawy sprzętu AGD i RTV w sklepie Domitek. Sprawdź warunki darmowej dostawy.','conditions, delivery, delay, shipment, pack, dostawa','<h2>Zasady i koszty dostawy w sklepie Domitek</h2>\n<p>Wszystkie zamówienia złożone w sklepie <strong>Domitek</strong> realizujemy z najwyższą dbałością o bezpieczeństwo przesyłek. Sprzęt AGD i RTV wymaga specjalistycznego transportu, dlatego korzystamy wyłącznie z dedykowanych przewoźników drobnicowych i paletowych.</p>\n<h3>Darmowa dostawa</h3>\n<p>Dla zamówień o wartości powyżej <strong>2000 zł brutto</strong> dostawa na terenie całej Polski jest całkowicie <strong>DARMOWA</strong> (nie dotyczy przesyłek ponadgabarytowych przekraczających wagę 50 kg, dla których obowiązują specjalne warunki logistyczne).</p>\n<h3>Metody dostawy i cennik</h3>\n<ul>\n<li><strong>Przesyłka kurierska standardowa (do 30 kg):</strong> przeznaczona dla małego AGD i akcesoriów. Czas doręczenia: 24–48h od momentu nadania. Koszt: 19 zł brutto.</li>\n<li><strong>Przesyłka kurierska paletowa / gabarytowa (do 50 kg):</strong> przeznaczona dla pralek, zmywarek, lodówek i płyt grzewczych. Bezpieczny transport na palecie. Czas doręczenia: 2–3 dni robocze. Koszt: 79 zł brutto.</li>\n</ul>\n<h3>Ograniczenia wagowe</h3>\n<p>Zgodnie z naszym regulaminem logistycznym maksymalna dopuszczalna waga standardowego pojedynczego zamówienia realizowanego przez sklep wynosi <strong>50 kg</strong>. Zamówienia przekraczające tę wagę wymagają indywidualnego kontaktu z działem obsługi klienta.</p>\n<h3>Śledzenie przesyłki</h3>\n<p>W momencie przekazania paczki kurierowi otrzymasz wiadomość e-mail z numerem listu przewozowego oraz linkiem do monitorowania statusu doręczenia.</p>','dostawa'),
(1,2,1,'Delivery','','Our terms and conditions of delivery','conditions, delivery, delay, shipment, pack','<h2>Shipments and returns</h2>\n<h3>Your pack shipment</h3>\n<p>Packages are generally dispatched within 2 days after receipt of payment and are shipped via UPS with tracking and drop-off without signature. If you prefer delivery by UPS Extra with required signature, an additional cost will be applied, so please contact us before choosing this method. Whichever shipment choice you make, we will provide you with a link to track your package online.</p>\n<p>Shipping fees include handling and packing fees as well as postage costs. Handling fees are fixed, whereas transport fees vary according to total weight of the shipment. We advise you to group your items in one order. We cannot group two distinct orders placed separately, and shipping fees will apply to each of them. Your package will be dispatched at your own risk, but special care is taken to protect fragile objects.<br /><br />Boxes are amply sized and your items are well-protected.</p>','delivery'),
(2,1,1,'Polityka prywatności','Polityka prywatności i ochrona danych osobowych - Domitek','Dowiedz się, jak sklep Domitek chroni Twoje dane osobowe zgodnie z RODO.','notice, legal, credits, polityka prywatności, ochrona danych osobowych, rodo','<h2>Polityka prywatności i ochrona danych (RODO) - Domitek</h2>\n<p>Szanujemy Twoje prawo do prywatności. Poniższy dokument wyjaśnia, w jaki sposób zbieramy, przetwarzamy i zabezpieczamy Twoje dane osobowe w sklepie <strong>Domitek</strong>.</p>\n<h3>1. Administrator Danych Osobowych</h3>\n<p>Administratorem Twoich danych osobowych jest Domitek Sp. z o.o. z siedzibą w Warszawie. W sprawach związanych z ochroną danych możesz skontaktować się z nami pod adresem e-mail: kontakt@domitek.pl.</p>\n<h3>2. Cel i podstawa przetwarzania danych</h3>\n<p>Twoje dane przetwarzamy w następujących celach:</p>\n<ul>\n<li>Realizacja zamówień i zawartej umowy sprzedaży (art. 6 ust. 1 lit. b RODO).</li>\n<li>Wystawianie faktur i prowadzenie sprawozdawczości księgowo-podatkowej (art. 6 ust. 1 lit. c RODO).</li>\n<li>Obsługa zapytań, zgłoszeń reklamacyjnych i kontakt z klientem (art. 6 ust. 1 lit. f RODO).</li>\n</ul>\n<h3>3. Odbiorcy danych</h3>\n<p>Dane osobowe mogą być przekazywane wyłącznie zaufanym podmiotom współpracującym, takim jak firmy kurierskie (w celu doręczenia paczki) oraz operatorzy systemów księgowych.</p>\n<h3>4. Twoje prawa</h3>\n<p>Przysługuje Ci prawo dostępu do swoich danych, ich sprostowania, usunięcia (\"prawo do bycia zapomnianym\"), ograniczenia przetwarzania oraz wniesienia sprzeciwu.</p>','polityka-prywatnosci'),
(2,2,1,'Legal Notice','','Legal notice','notice, legal, credits','<h2>Legal</h2>\n<h3>Credits</h3>\n<p>Concept and production:</p>\n<p>This Online store was created using <a href=\"http://www.prestashop.com\">Prestashop Shopping Cart Software</a>,check out PrestaShop\'s <a href=\"http://www.prestashop.com/blog/en/\">ecommerce blog</a> for news and advices about selling online and running your ecommerce website.</p>','legal-notice'),
(3,1,1,'Regulamin','Regulamin sklepu internetowego - Domitek','Regulamin zakupów w sklepie internetowym Domitek. Zasady składania zamówień, płatności, dostawy oraz zwrotów.','conditions, terms, use, sell, Regulamin','<h2>Regulamin Sklepu Internetowego Domitek</h2>\n<h3>§ 1. Postanowienia ogólne</h3>\n<ol>\n<li>Niniejszy Regulamin określa zasady korzystania ze sklepu internetowego <strong>Domitek</strong>, dostępnego pod adresem domeny sklepu.</li>\n<li>Właścicielem i administratorem sklepu jest Domitek Sp. z o.o. z siedzibą w Warszawie.</li>\n<li>Warunkiem złożenia zamówienia w sklepie przez Kupującego jest zapoznanie się z niniejszym Regulaminem i akceptacja jego postanowień.</li>\n</ol>\n<h3>§ 2. Ceny i asortyment</h3>\n<ol>\n<li>Wszystkie ceny towarów zamieszczone w sklepie są cenami brutto (zawierają podatek VAT) i wyrażone są w złotych polskich (PLN).</li>\n<li>Ceny nie zawierają kosztów dostawy, które są doliczane podczas wyboru metody transportu w koszyku.</li>\n</ol>\n<h3>§ 3. Składanie i realizacja zamówień</h3>\n<ol>\n<li>Zamówienia można składać przez całą dobę za pośrednictwem strony internetowej.</li>\n<li>Po złożeniu zamówienia Klient otrzymuje automatyczne potwierdzenie drogą elektroniczną.</li>\n<li>Czas realizacji zamówienia wynosi zazwyczaj od 1 do 3 dni roboczych.</li>\n</ol>\n<h3>§ 4. Prawo odstąpienia od umowy (zwroty)</h3>\n<ol>\n<li>Zgodnie z ustawą o prawach konsumenta, Klient będący konsumentem ma prawo odstąpić od umowy bez podania przyczyny w terminie <strong>14 dni</strong> od dnia odebrania przesyłki.</li>\n<li>Zwracany sprzęt powinien być w stanie niezmienionym, w miarę możliwości w oryginalnym opakowaniu wraz z kompletem akcesoriów i dokumentacją.</li>\n</ol>\n<h3>§ 5. Reklamacje i gwarancja</h3>\n<ol>\n<li>Wszystkie produkty fabrycznie nowe są objęte gwarancją producenta.</li>\n<li>Reklamacje z tytułu rękojmi lub gwarancji można zgłaszać drogą elektroniczną lub pisemnie na adres siedziby sklepu.</li>\n</ol>','regulamin'),
(3,2,1,'Terms and conditions of use','','Our terms and conditions of use','conditions, terms, use, sell','<h1 class=\"page-heading\">Terms and conditions of use</h1>\n<h3 class=\"page-subheading\">Rule 1</h3>\n<p class=\"bottom-indent\">Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>\n<h3 class=\"page-subheading\">Rule 2</h3>\n<p class=\"bottom-indent\">Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniamю</p>\n<h3 class=\"page-subheading\">Rule 3</h3>\n<p class=\"bottom-indent\">Tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniamю</p>','terms-and-conditions-of-use'),
(4,1,1,'O sklepie','O sklepie - Domitek','Poznaj sklep internetowy Domitek - Twój zaufany dostawca sprzętu AGD, RTV i elektroniki domowej.','about us, informations, O nas, informacje','<h2>Witaj w Domitek – Twoim centrum nowoczesnego AGD i RTV</h2>\n<p>Sklep internetowy <strong>Domitek</strong> powstał z pasji do nowoczesnych technologii, które ułatwiają codzienne życie w domu. Wzorując się na najlepszych standardach rynkowych, dostarczamy najwyższej jakości sprzęt dużego i małego AGD, telewizory, sprzęt audio oraz akcesoria renomowanych światowych producentów.</p>\n<h3>Dlaczego warto wybrać Domitek?</h3>\n<ul>\n<li><strong>Szeroki asortyment:</strong> Od pralek, lodówek i piekarników do zabudowy, po drobne urządzenia kuchenne i elektronikę użytkową.</li>\n<li><strong>Bezpieczna dostawa:</strong> Wiemy, jak delikatny i cenny jest sprzęt wielkogabarytowy, dlatego współpracujemy wyłącznie ze sprawdzonymi firmami kurierskimi oferującymi profesjonalny transport oraz opcję wniesienia.</li>\n<li><strong>Gwarancja i doradztwo:</strong> Wszystkie oferowane przez nas produkty pochodzą z oficjalnej polskiej dystrybucji i są objęte pełną gwarancją producenta. Nasi doradcy z przyjemnością pomogą dobrać sprzęt idealnie dopasowany do Twojej kuchni czy salonu.</li>\n<li><strong>Konkurencyjne ceny:</strong> Regularnie przygotowujemy promocje i rabaty, dbając o to, by nowoczesny dom był dostępny na każdą kieszeń.</li>\n</ul>\n<p>Zapraszamy do udanych i bezpiecznych zakupów w sklepie <strong>Domitek</strong>!</p>','o-sklepie'),
(4,2,1,'About us','','Learn more about us','about us, informations','<h1 class=\"page-heading bottom-indent\">About us</h1>\n<div class=\"row\">\n<div class=\"col-xs-12 col-sm-4\">\n<div class=\"cms-block\">\n<h3 class=\"page-subheading\">Our company</h3>\n<p><strong class=\"dark\">Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididun.</strong></p>\n<p>Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam. Lorem ipsum dolor sit amet conse ctetur adipisicing elit.</p>\n<ul class=\"list-1\">\n<li><em class=\"icon-ok\"></em>Top quality products</li>\n<li><em class=\"icon-ok\"></em>Best customer service</li>\n<li><em class=\"icon-ok\"></em>30-days money back guarantee</li>\n</ul>\n</div>\n</div>\n<div class=\"col-xs-12 col-sm-4\">\n<div class=\"cms-box\">\n<h3 class=\"page-subheading\">Our team</h3>\n<p><strong class=\"dark\">Lorem set sint occaecat cupidatat non </strong></p>\n<p>Eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo.</p>\n</div>\n</div>\n<div class=\"col-xs-12 col-sm-4\">\n<div class=\"cms-box\">\n<h3 class=\"page-subheading\">Testimonials</h3>\n<div class=\"testimonials\">\n<div class=\"inner\"><span class=\"before\">“</span>Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim.<span class=\"after\">”</span></div>\n</div>\n<p><strong class=\"dark\">Lorem ipsum dolor sit</strong></p>\n<div class=\"testimonials\">\n<div class=\"inner\"><span class=\"before\">“</span>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet conse ctetur adipisicing elit. Lorem ipsum dolor sit amet conse ctetur adipisicing elit, sed do eiusmod.<span class=\"after\">”</span></div>\n</div>\n<p><strong class=\"dark\">Ipsum dolor sit</strong></p>\n</div>\n</div>\n</div>','about-us'),
(5,1,1,'Formy płatności','Formy płatności - Domitek','Sprawdź dostępne metody płatności w sklepie Domitek: przelew tradycyjny oraz płatność przy odbiorze.','secure payment, ssl, visa, mastercard, paypal, formy płatności','<h2>Bezpieczne formy płatności w Domitek</h2>\n<p>Dla wygody i bezpieczeństwa naszych Klientów sklep <strong>Domitek</strong> oferuje sprawdzone i przejrzyste formy rozliczeń stosowane w Polsce:</p>\n<h3>1. Płatność przy odbiorze (za pobraniem)</h3>\n<p>Najwygodniejszy wybór dla osób preferujących uregulowanie należności w momencie dostarczenia towaru. Zapłaty dokonujesz gotówką lub kartą płatniczą bezpośrednio u kuriera dostarczającego przesyłkę.</p>\n<h3>2. Przelew tradycyjny na konto bankowe</h3>\n<p>Po złożeniu zamówienia otrzymasz wiadomość e-mail z danymi do wpłaty oraz numerem rachunku bankowego. Towar wysyłamy niezwłocznie po zaksięgowaniu środków na naszym koncie.</p>\n<p><strong>Dane do wpłaty:</strong><br />Domitek Sp. z o.o.<br />Nr rachunku: <strong>88 1050 0000 0000 0000 1234 5678</strong> (Bank Millennium)<br />Tytuł przelewu: <em>Zamówienie nr [Twój numer zamówienia]</em></p>\n<h3>Faktury VAT</h3>\n<p>Do każdego zakupu wystawiamy fakturę VAT lub paragon fiskalny. Faktura VAT w formacie PDF jest dostępna do pobrania na koncie klienta zaraz po zrealizowaniu zamówienia.</p>','formy-platnosci'),
(5,2,1,'Secure payment','','Our secure payment method','secure payment, ssl, visa, mastercard, paypal','<h2>Secure payment</h2>\n<h3>Our secure payment</h3>\n<p>With SSL</p>\n<h3>Using Visa/Mastercard/Paypal</h3>\n<p>About this service</p>','secure-payment');
/*!40000 ALTER TABLE `ps_cms_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_cms_shop`
--

DROP TABLE IF EXISTS `ps_cms_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_cms_shop` (
  `id_cms` int(11) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_cms`,`id_shop`),
  KEY `id_shop` (`id_shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_cms_shop`
--

LOCK TABLES `ps_cms_shop` WRITE;
/*!40000 ALTER TABLE `ps_cms_shop` DISABLE KEYS */;
INSERT INTO `ps_cms_shop` VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,1);
/*!40000 ALTER TABLE `ps_cms_shop` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Translate footer link block headers for Polish (id_lang = 1)
UPDATE `ps_link_block_lang` SET `name` = 'Produkty' WHERE `id_link_block` = 1 AND `id_lang` = 1;
UPDATE `ps_link_block_lang` SET `name` = 'Informacje' WHERE `id_link_block` = 2 AND `id_lang` = 1;


-- Dump completed on 2026-11-11  0:28:49
