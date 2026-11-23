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
-- Table structure for table `ps_carrier`
--

DROP TABLE IF EXISTS `ps_carrier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier` (
  `id_carrier` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_reference` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `active` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `shipping_handling` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `range_behavior` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `is_module` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `is_free` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `shipping_external` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `need_range` tinyint(1) unsigned NOT NULL DEFAULT 0,
  `external_module_name` varchar(64) DEFAULT NULL,
  `shipping_method` int(2) NOT NULL DEFAULT 0,
  `position` int(10) unsigned NOT NULL DEFAULT 0,
  `max_width` int(10) DEFAULT 0,
  `max_height` int(10) DEFAULT 0,
  `max_depth` int(10) DEFAULT 0,
  `max_weight` decimal(20,6) DEFAULT 0.000000,
  `grade` int(10) DEFAULT 0,
  PRIMARY KEY (`id_carrier`),
  KEY `deleted` (`deleted`,`active`),
  KEY `reference` (`id_reference`,`deleted`,`active`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier`
--

LOCK TABLES `ps_carrier` WRITE;
/*!40000 ALTER TABLE `ps_carrier` DISABLE KEYS */;
INSERT INTO `ps_carrier` VALUES
(1,1,'Click and collect','',1,1,0,0,0,1,0,0,'',1,0,0,0,0,0.000000,0),
(2,2,'My carrier','',1,1,1,0,0,0,0,0,'',1,0,0,0,0,0.000000,0),
(3,3,'My cheap carrier','',0,1,1,0,0,0,0,0,'',2,0,0,0,0,0.000000,0),
(4,4,'My light carrier','',0,1,1,0,0,0,0,0,'',1,0,0,0,0,0.000000,0),
(5,5,'InPost Paczkomat 24/7','',1,1,0,1,0,0,0,0,'',1,0,0,0,0,50.000000,8),
(6,6,'DPD Kurier','',1,1,0,1,0,0,0,0,'',1,1,0,0,0,50.000000,5),
(7,5,'InPost Paczkomat 24/7','',1,1,0,1,0,0,0,0,'',1,0,0,0,0,50.000000,8),
(8,6,'DPD Kurier','',1,1,0,1,0,0,0,0,'',1,1,0,0,0,50.000000,5),
(9,6,'DPD Kurier','',1,0,0,1,0,0,0,0,'',1,1,0,0,0,50.000000,5),
(10,5,'InPost Paczkomat 24/7','',1,0,0,1,0,0,0,0,'',1,0,0,0,0,50.000000,8);
/*!40000 ALTER TABLE `ps_carrier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_carrier_lang`
--

DROP TABLE IF EXISTS `ps_carrier_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier_lang` (
  `id_carrier` int(10) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL DEFAULT 1,
  `id_lang` int(10) unsigned NOT NULL,
  `delay` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id_lang`,`id_shop`,`id_carrier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier_lang`
--

LOCK TABLES `ps_carrier_lang` WRITE;
/*!40000 ALTER TABLE `ps_carrier_lang` DISABLE KEYS */;
INSERT INTO `ps_carrier_lang` VALUES
(1,1,1,'Odbi├│r w sklepie'),
(2,1,1,'Dostawa nast─Öpnego dnia!'),
(3,1,1,'Buy more to pay less!'),
(4,1,1,'The lighter the cheaper!'),
(5,1,1,'1-2 dni robocze'),
(6,1,1,'1-2 dni robocze'),
(7,1,1,'1-2 dni robocze'),
(8,1,1,'1-2 dni robocze'),
(9,1,1,'1-2 dni robocze'),
(10,1,1,'1-2 dni robocze'),
(1,1,2,'Pick up in-store'),
(2,1,2,'Delivery next day!'),
(3,1,2,'Buy more to pay less!'),
(4,1,2,'The lighter the cheaper!'),
(5,1,2,'1-2 dni robocze'),
(6,1,2,'1-2 dni robocze'),
(7,1,2,'1-2 dni robocze'),
(8,1,2,'1-2 dni robocze'),
(9,1,2,'1-2 dni robocze'),
(10,1,2,'1-2 dni robocze');
/*!40000 ALTER TABLE `ps_carrier_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_carrier_shop`
--

DROP TABLE IF EXISTS `ps_carrier_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier_shop` (
  `id_carrier` int(11) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_carrier`,`id_shop`),
  KEY `id_shop` (`id_shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier_shop`
--

LOCK TABLES `ps_carrier_shop` WRITE;
/*!40000 ALTER TABLE `ps_carrier_shop` DISABLE KEYS */;
INSERT INTO `ps_carrier_shop` VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,1),
(6,1),
(7,1),
(8,1),
(9,1),
(10,1);
/*!40000 ALTER TABLE `ps_carrier_shop` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_carrier_zone`
--

DROP TABLE IF EXISTS `ps_carrier_zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier_zone` (
  `id_carrier` int(10) unsigned NOT NULL,
  `id_zone` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_carrier`,`id_zone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier_zone`
--

LOCK TABLES `ps_carrier_zone` WRITE;
/*!40000 ALTER TABLE `ps_carrier_zone` DISABLE KEYS */;
INSERT INTO `ps_carrier_zone` VALUES
(1,1),
(2,1),
(2,2),
(3,1),
(3,2),
(4,1),
(4,2),
(5,1),
(6,1),
(7,1),
(8,1),
(9,1),
(10,1);
/*!40000 ALTER TABLE `ps_carrier_zone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_carrier_group`
--

DROP TABLE IF EXISTS `ps_carrier_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier_group` (
  `id_carrier` int(10) unsigned NOT NULL,
  `id_group` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_carrier`,`id_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier_group`
--

LOCK TABLES `ps_carrier_group` WRITE;
/*!40000 ALTER TABLE `ps_carrier_group` DISABLE KEYS */;
INSERT INTO `ps_carrier_group` VALUES
(1,1),
(1,2),
(1,3),
(2,1),
(2,2),
(2,3),
(3,1),
(3,2),
(3,3),
(4,1),
(4,2),
(4,3),
(5,1),
(5,2),
(5,3),
(6,1),
(6,2),
(6,3),
(7,1),
(7,2),
(7,3),
(8,1),
(8,2),
(8,3),
(9,1),
(9,2),
(9,3),
(10,1),
(10,2),
(10,3);
/*!40000 ALTER TABLE `ps_carrier_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_delivery`
--

DROP TABLE IF EXISTS `ps_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_delivery` (
  `id_delivery` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_shop` int(10) unsigned DEFAULT NULL,
  `id_shop_group` int(10) unsigned DEFAULT NULL,
  `id_carrier` int(10) unsigned NOT NULL,
  `id_range_price` int(10) unsigned DEFAULT NULL,
  `id_range_weight` int(10) unsigned DEFAULT NULL,
  `id_zone` int(10) unsigned NOT NULL,
  `price` decimal(20,6) NOT NULL,
  PRIMARY KEY (`id_delivery`),
  KEY `id_zone` (`id_zone`),
  KEY `id_carrier` (`id_carrier`,`id_zone`),
  KEY `id_range_price` (`id_range_price`),
  KEY `id_range_weight` (`id_range_weight`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_delivery`
--

LOCK TABLES `ps_delivery` WRITE;
/*!40000 ALTER TABLE `ps_delivery` DISABLE KEYS */;
INSERT INTO `ps_delivery` VALUES
(1,NULL,NULL,2,0,1,1,5.000000),
(2,NULL,NULL,2,0,1,2,5.000000),
(3,NULL,NULL,2,1,0,1,5.000000),
(4,NULL,NULL,2,1,0,2,5.000000),
(5,NULL,NULL,3,2,0,1,3.000000),
(6,NULL,NULL,3,2,0,2,4.000000),
(7,NULL,NULL,3,3,0,1,1.000000),
(8,NULL,NULL,3,3,0,2,2.000000),
(9,NULL,NULL,3,4,0,1,0.000000),
(10,NULL,NULL,3,4,0,2,0.000000),
(11,NULL,NULL,4,0,2,1,0.000000),
(12,NULL,NULL,4,0,2,2,0.000000),
(13,NULL,NULL,4,0,3,1,2.000000),
(14,NULL,NULL,4,0,3,2,3.000000),
(15,NULL,NULL,4,0,4,1,5.000000),
(16,NULL,NULL,4,0,4,2,6.000000),
(18,NULL,NULL,5,NULL,5,1,12.190000),
(20,NULL,NULL,6,NULL,6,4,0.000000),
(21,NULL,NULL,6,NULL,6,3,0.000000),
(22,NULL,NULL,6,NULL,6,8,0.000000),
(23,NULL,NULL,6,NULL,6,1,16.250000),
(24,NULL,NULL,6,NULL,6,7,0.000000),
(25,NULL,NULL,6,NULL,6,2,0.000000),
(26,NULL,NULL,6,NULL,6,5,0.000000),
(27,NULL,NULL,6,NULL,6,6,0.000000),
(29,NULL,NULL,7,NULL,7,1,12.190000),
(31,NULL,NULL,8,NULL,8,1,16.250000),
(33,NULL,NULL,9,NULL,9,4,0.000000),
(34,NULL,NULL,9,NULL,9,3,0.000000),
(35,NULL,NULL,9,NULL,9,8,0.000000),
(36,NULL,NULL,9,NULL,9,1,16.250000),
(37,NULL,NULL,9,NULL,9,7,0.000000),
(38,NULL,NULL,9,NULL,9,2,0.000000),
(39,NULL,NULL,9,NULL,9,5,0.000000),
(40,NULL,NULL,9,NULL,9,6,0.000000),
(42,NULL,NULL,10,NULL,10,1,12.190000);
/*!40000 ALTER TABLE `ps_delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_range_weight`
--

DROP TABLE IF EXISTS `ps_range_weight`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_range_weight` (
  `id_range_weight` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_carrier` int(10) unsigned NOT NULL,
  `delimiter1` decimal(20,6) NOT NULL,
  `delimiter2` decimal(20,6) NOT NULL,
  PRIMARY KEY (`id_range_weight`),
  UNIQUE KEY `id_carrier` (`id_carrier`,`delimiter1`,`delimiter2`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_range_weight`
--

LOCK TABLES `ps_range_weight` WRITE;
/*!40000 ALTER TABLE `ps_range_weight` DISABLE KEYS */;
INSERT INTO `ps_range_weight` VALUES
(1,2,0.000000,10000.000000),
(2,4,0.000000,1.000000),
(3,4,1.000000,3.000000),
(4,4,3.000000,10000.000000),
(5,5,0.000000,50.000000),
(6,6,0.000000,50.000000),
(7,7,0.000000,50.000000),
(8,8,0.000000,50.000000),
(9,9,0.000000,50.000000),
(10,10,0.000000,50.000000);
/*!40000 ALTER TABLE `ps_range_weight` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_range_price`
--

DROP TABLE IF EXISTS `ps_range_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_range_price` (
  `id_range_price` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_carrier` int(10) unsigned NOT NULL,
  `delimiter1` decimal(20,6) NOT NULL,
  `delimiter2` decimal(20,6) NOT NULL,
  PRIMARY KEY (`id_range_price`),
  UNIQUE KEY `id_carrier` (`id_carrier`,`delimiter1`,`delimiter2`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_range_price`
--

LOCK TABLES `ps_range_price` WRITE;
/*!40000 ALTER TABLE `ps_range_price` DISABLE KEYS */;
INSERT INTO `ps_range_price` VALUES
(1,2,0.000000,10000.000000),
(2,3,0.000000,50.000000),
(3,3,50.000000,100.000000),
(4,3,100.000000,200.000000);
/*!40000 ALTER TABLE `ps_range_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_carrier_tax_rules_group_shop`
--

DROP TABLE IF EXISTS `ps_carrier_tax_rules_group_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_carrier_tax_rules_group_shop` (
  `id_carrier` int(11) unsigned NOT NULL,
  `id_tax_rules_group` int(11) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_carrier`,`id_tax_rules_group`,`id_shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_carrier_tax_rules_group_shop`
--

LOCK TABLES `ps_carrier_tax_rules_group_shop` WRITE;
/*!40000 ALTER TABLE `ps_carrier_tax_rules_group_shop` DISABLE KEYS */;
INSERT INTO `ps_carrier_tax_rules_group_shop` VALUES
(1,1,1),
(2,1,1),
(3,1,1),
(4,1,1),
(7,1,1),
(9,1,1),
(10,1,1);
/*!40000 ALTER TABLE `ps_carrier_tax_rules_group_shop` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_tax`
--

DROP TABLE IF EXISTS `ps_tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_tax` (
  `id_tax` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rate` decimal(10,3) NOT NULL,
  `active` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_tax`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_tax`
--

LOCK TABLES `ps_tax` WRITE;
/*!40000 ALTER TABLE `ps_tax` DISABLE KEYS */;
INSERT INTO `ps_tax` VALUES
(1,23.000,1,0),
(2,8.000,1,0),
(3,5.000,1,0),
(4,0.000,1,0),
(5,20.000,1,0),
(6,21.000,1,0),
(7,20.000,1,0),
(8,19.000,1,0),
(9,21.000,1,0),
(10,19.000,1,0),
(11,25.000,1,0),
(12,24.000,1,0),
(13,21.000,1,0),
(14,25.500,1,0),
(15,20.000,1,0),
(16,20.000,1,0),
(17,24.000,1,0),
(18,25.000,1,0),
(19,27.000,1,0),
(20,23.000,1,0),
(21,22.000,1,0),
(22,21.000,1,0),
(23,17.000,1,0),
(24,21.000,1,0),
(25,20.000,1,0),
(26,18.000,1,0),
(27,21.000,1,0),
(28,23.000,1,0),
(29,21.000,1,0),
(30,25.000,1,0),
(31,22.000,1,0),
(32,23.000,1,0);
/*!40000 ALTER TABLE `ps_tax` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_tax_lang`
--

DROP TABLE IF EXISTS `ps_tax_lang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_tax_lang` (
  `id_tax` int(10) unsigned NOT NULL,
  `id_lang` int(10) unsigned NOT NULL,
  `name` varchar(32) NOT NULL,
  PRIMARY KEY (`id_tax`,`id_lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_tax_lang`
--

LOCK TABLES `ps_tax_lang` WRITE;
/*!40000 ALTER TABLE `ps_tax_lang` DISABLE KEYS */;
INSERT INTO `ps_tax_lang` VALUES
(1,1,'PTU PL 23%'),
(1,2,'PTU PL 23%'),
(2,1,'PTU PL 8%'),
(2,2,'PTU PL 8%'),
(3,1,'PTU PL 5%'),
(3,2,'PTU PL 5%'),
(4,1,'PTU PL 0'),
(4,2,'PTU PL 0'),
(5,1,'USt. AT 20%'),
(5,2,'USt. AT 20%'),
(6,1,'TVA BE 21%'),
(6,2,'TVA BE 21%'),
(7,1,'ДДС BG 20%'),
(7,2,'ДДС BG 20%'),
(8,1,'ΦΠΑ CY 19%'),
(8,2,'ΦΠΑ CY 19%'),
(9,1,'DPH CZ 21%'),
(9,2,'DPH CZ 21%'),
(10,1,'MwSt. DE 19%'),
(10,2,'MwSt. DE 19%'),
(11,1,'moms DK 25%'),
(11,2,'moms DK 25%'),
(12,1,'km EE 24%'),
(12,2,'km EE 24%'),
(13,1,'IVA ES 21%'),
(13,2,'IVA ES 21%'),
(14,1,'ALV FI 25.5%'),
(14,2,'ALV FI 25.5%'),
(15,1,'TVA FR 20%'),
(15,2,'TVA FR 20%'),
(16,1,'VAT UK 20%'),
(16,2,'VAT UK 20%'),
(17,1,'ΦΠΑ GR 24%'),
(17,2,'ΦΠΑ GR 24%'),
(18,1,'Croatia PDV 25%'),
(18,2,'Croatia PDV 25%'),
(19,1,'ÁFA HU 27%'),
(19,2,'ÁFA HU 27%'),
(20,1,'VAT IE 23%'),
(20,2,'VAT IE 23%'),
(21,1,'IVA IT 22%'),
(21,2,'IVA IT 22%'),
(22,1,'PVM LT 21%'),
(22,2,'PVM LT 21%'),
(23,1,'TVA LU 17%'),
(23,2,'TVA LU 17%'),
(24,1,'PVN LV 21%'),
(24,2,'PVN LV 21%'),
(25,1,'TVA MC 20%'),
(25,2,'TVA MC 20%'),
(26,1,'VAT MT 18%'),
(26,2,'VAT MT 18%'),
(27,1,'BTW NL 21%'),
(27,2,'BTW NL 21%'),
(28,1,'IVA PT 23%'),
(28,2,'IVA PT 23%'),
(29,1,'TVA RO 21%'),
(29,2,'TVA RO 21%'),
(30,1,'Moms SE 25%'),
(30,2,'Moms SE 25%'),
(31,1,'DDV SI 22%'),
(31,2,'DDV SI 22%'),
(32,1,'DPH SK 23%'),
(32,2,'DPH SK 23%');
/*!40000 ALTER TABLE `ps_tax_lang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_tax_rule`
--

DROP TABLE IF EXISTS `ps_tax_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_tax_rule` (
  `id_tax_rule` int(11) NOT NULL AUTO_INCREMENT,
  `id_tax_rules_group` int(11) NOT NULL,
  `id_country` int(11) NOT NULL,
  `id_state` int(11) NOT NULL,
  `zipcode_from` varchar(12) NOT NULL,
  `zipcode_to` varchar(12) NOT NULL,
  `id_tax` int(11) NOT NULL,
  `behavior` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  PRIMARY KEY (`id_tax_rule`),
  KEY `id_tax_rules_group` (`id_tax_rules_group`),
  KEY `id_tax` (`id_tax`),
  KEY `category_getproducts` (`id_tax_rules_group`,`id_country`,`id_state`,`zipcode_from`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_tax_rule`
--

LOCK TABLES `ps_tax_rule` WRITE;
/*!40000 ALTER TABLE `ps_tax_rule` DISABLE KEYS */;
INSERT INTO `ps_tax_rule` VALUES
(1,1,3,0,'0','0',1,0,''),
(2,1,233,0,'0','0',1,0,''),
(3,1,16,0,'0','0',1,0,''),
(4,1,20,0,'0','0',1,0,''),
(5,1,1,0,'0','0',1,0,''),
(6,1,86,0,'0','0',1,0,''),
(7,1,9,0,'0','0',1,0,''),
(8,1,74,0,'0','0',1,0,''),
(9,1,6,0,'0','0',1,0,''),
(10,1,8,0,'0','0',1,0,''),
(11,1,147,0,'0','0',1,0,''),
(12,1,26,0,'0','0',1,0,''),
(13,1,10,0,'0','0',1,0,''),
(14,1,76,0,'0','0',1,0,''),
(15,1,124,0,'0','0',1,0,''),
(16,1,130,0,'0','0',1,0,''),
(17,1,12,0,'0','0',1,0,''),
(18,1,142,0,'0','0',1,0,''),
(19,1,138,0,'0','0',1,0,''),
(20,1,13,0,'0','0',1,0,''),
(21,1,2,0,'0','0',1,0,''),
(22,1,14,0,'0','0',1,0,''),
(23,1,15,0,'0','0',1,0,''),
(24,1,36,0,'0','0',1,0,''),
(25,1,191,0,'0','0',1,0,''),
(26,1,37,0,'0','0',1,0,''),
(27,1,7,0,'0','0',1,0,''),
(28,1,18,0,'0','0',1,0,''),
(29,1,17,0,'0','0',1,0,''),
(30,2,3,0,'0','0',2,0,''),
(31,2,233,0,'0','0',2,0,''),
(32,2,16,0,'0','0',2,0,''),
(33,2,20,0,'0','0',2,0,''),
(34,2,1,0,'0','0',2,0,''),
(35,2,86,0,'0','0',2,0,''),
(36,2,9,0,'0','0',2,0,''),
(37,2,74,0,'0','0',2,0,''),
(38,2,6,0,'0','0',2,0,''),
(39,2,8,0,'0','0',2,0,''),
(40,2,147,0,'0','0',2,0,''),
(41,2,26,0,'0','0',2,0,''),
(42,2,10,0,'0','0',2,0,''),
(43,2,76,0,'0','0',2,0,''),
(44,2,124,0,'0','0',2,0,''),
(45,2,130,0,'0','0',2,0,''),
(46,2,12,0,'0','0',2,0,''),
(47,2,142,0,'0','0',2,0,''),
(48,2,138,0,'0','0',2,0,''),
(49,2,13,0,'0','0',2,0,''),
(50,2,2,0,'0','0',2,0,''),
(51,2,14,0,'0','0',2,0,''),
(52,2,15,0,'0','0',2,0,''),
(53,2,36,0,'0','0',2,0,''),
(54,2,191,0,'0','0',2,0,''),
(55,2,37,0,'0','0',2,0,''),
(56,2,7,0,'0','0',2,0,''),
(57,2,18,0,'0','0',2,0,''),
(58,2,17,0,'0','0',2,0,''),
(59,3,3,0,'0','0',3,0,''),
(60,3,233,0,'0','0',3,0,''),
(61,3,16,0,'0','0',3,0,''),
(62,3,20,0,'0','0',3,0,''),
(63,3,1,0,'0','0',3,0,''),
(64,3,86,0,'0','0',3,0,''),
(65,3,9,0,'0','0',3,0,''),
(66,3,74,0,'0','0',3,0,''),
(67,3,6,0,'0','0',3,0,''),
(68,3,8,0,'0','0',3,0,''),
(69,3,147,0,'0','0',3,0,''),
(70,3,10,0,'0','0',3,0,''),
(71,3,76,0,'0','0',3,0,''),
(72,3,124,0,'0','0',3,0,''),
(73,3,130,0,'0','0',3,0,''),
(74,3,12,0,'0','0',3,0,''),
(75,3,142,0,'0','0',3,0,''),
(76,3,138,0,'0','0',3,0,''),
(77,3,13,0,'0','0',3,0,''),
(78,3,2,0,'0','0',3,0,''),
(79,3,14,0,'0','0',3,0,''),
(80,3,15,0,'0','0',3,0,''),
(81,3,36,0,'0','0',3,0,''),
(82,3,191,0,'0','0',3,0,''),
(83,3,37,0,'0','0',3,0,''),
(84,3,7,0,'0','0',3,0,''),
(85,3,18,0,'0','0',3,0,''),
(86,3,17,0,'0','0',3,0,''),
(87,4,3,0,'0','0',4,0,''),
(88,4,233,0,'0','0',4,0,''),
(89,4,16,0,'0','0',4,0,''),
(90,4,20,0,'0','0',4,0,''),
(91,4,1,0,'0','0',4,0,''),
(92,4,86,0,'0','0',4,0,''),
(93,4,9,0,'0','0',4,0,''),
(94,4,74,0,'0','0',4,0,''),
(95,4,6,0,'0','0',4,0,''),
(96,4,8,0,'0','0',4,0,''),
(97,4,147,0,'0','0',4,0,''),
(98,4,10,0,'0','0',4,0,''),
(99,4,76,0,'0','0',4,0,''),
(100,4,124,0,'0','0',4,0,''),
(101,4,130,0,'0','0',4,0,''),
(102,4,12,0,'0','0',4,0,''),
(103,4,142,0,'0','0',4,0,''),
(104,4,138,0,'0','0',4,0,''),
(105,4,13,0,'0','0',4,0,''),
(106,4,2,0,'0','0',4,0,''),
(107,4,14,0,'0','0',4,0,''),
(108,4,15,0,'0','0',4,0,''),
(109,4,36,0,'0','0',4,0,''),
(110,4,191,0,'0','0',4,0,''),
(111,4,37,0,'0','0',4,0,''),
(112,4,7,0,'0','0',4,0,''),
(113,4,18,0,'0','0',4,0,''),
(114,4,17,0,'0','0',4,0,''),
(115,5,14,0,'0','0',1,0,''),
(116,5,2,0,'0','0',5,0,''),
(117,5,3,0,'0','0',6,0,''),
(118,5,233,0,'0','0',7,0,''),
(119,5,76,0,'0','0',8,0,''),
(120,5,16,0,'0','0',9,0,''),
(121,5,1,0,'0','0',10,0,''),
(122,5,20,0,'0','0',11,0,''),
(123,5,86,0,'0','0',12,0,''),
(124,5,6,0,'0','0',13,0,''),
(125,5,7,0,'0','0',14,0,''),
(126,5,8,0,'0','0',15,0,''),
(127,5,17,0,'0','0',16,0,''),
(128,5,9,0,'0','0',17,0,''),
(129,5,74,0,'0','0',18,0,''),
(130,5,142,0,'0','0',19,0,''),
(131,5,26,0,'0','0',20,0,''),
(132,5,10,0,'0','0',21,0,''),
(133,5,130,0,'0','0',22,0,''),
(134,5,12,0,'0','0',23,0,''),
(135,5,124,0,'0','0',24,0,''),
(136,5,147,0,'0','0',25,0,''),
(137,5,138,0,'0','0',26,0,''),
(138,5,13,0,'0','0',27,0,''),
(139,5,15,0,'0','0',28,0,''),
(140,5,36,0,'0','0',29,0,''),
(141,5,18,0,'0','0',30,0,''),
(142,5,191,0,'0','0',31,0,''),
(143,5,37,0,'0','0',32,0,'');
/*!40000 ALTER TABLE `ps_tax_rule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_tax_rules_group`
--

DROP TABLE IF EXISTS `ps_tax_rules_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_tax_rules_group` (
  `id_tax_rules_group` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `active` int(11) NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL,
  `date_add` datetime NOT NULL,
  `date_upd` datetime NOT NULL,
  PRIMARY KEY (`id_tax_rules_group`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_tax_rules_group`
--

LOCK TABLES `ps_tax_rules_group` WRITE;
/*!40000 ALTER TABLE `ps_tax_rules_group` DISABLE KEYS */;
INSERT INTO `ps_tax_rules_group` VALUES
(1,'PL Standard Rate (23%)',1,0,'2026-11-22 18:59:45','2026-11-22 18:59:45'),
(2,'PL Reduced Rate (8%)',1,0,'2026-11-22 18:59:46','2026-11-22 18:59:46'),
(3,'PL Reduced Rate (5%)',1,0,'2026-11-22 18:59:46','2026-11-22 18:59:46'),
(4,'PL Exempted Rate (0%)',1,0,'2026-11-22 18:59:46','2026-11-22 18:59:46'),
(5,'EU VAT For Virtual Products',1,0,'2026-11-22 18:59:46','2026-11-22 18:59:46');
/*!40000 ALTER TABLE `ps_tax_rules_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ps_tax_rules_group_shop`
--

DROP TABLE IF EXISTS `ps_tax_rules_group_shop`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ps_tax_rules_group_shop` (
  `id_tax_rules_group` int(11) unsigned NOT NULL,
  `id_shop` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_tax_rules_group`,`id_shop`),
  KEY `id_shop` (`id_shop`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ps_tax_rules_group_shop`
--

LOCK TABLES `ps_tax_rules_group_shop` WRITE;
/*!40000 ALTER TABLE `ps_tax_rules_group_shop` DISABLE KEYS */;
INSERT INTO `ps_tax_rules_group_shop` VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,1);
/*!40000 ALTER TABLE `ps_tax_rules_group_shop` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Ensure storefront language defaults strictly to Polish (disable English)
UPDATE ps_lang SET active = 0 WHERE iso_code = 'en';
UPDATE ps_lang SET active = 1 WHERE iso_code = 'pl';

-- Free shipping threshold: 2000 PLN gross and disable default handling fee
DELETE FROM ps_configuration WHERE name IN ('PS_SHIPPING_FREE_PRICE', 'PS_SHIPPING_HANDLING');
INSERT INTO ps_configuration (name, id_shop_group, id_shop, value, date_add, date_upd)
VALUES
('PS_SHIPPING_FREE_PRICE', NULL, NULL, '2000', NOW(), NOW()),
('PS_SHIPPING_HANDLING', NULL, NULL, '0', NOW(), NOW());

-- Dump completed on 2026-11-22 18:12:38
