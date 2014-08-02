-- MySQL dump 10.10
--
-- Host: localhost    Database: tcm_db
-- ------------------------------------------------------
-- Server version	5.0.18-nt

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ad_business_assoc`
--

DROP TABLE IF EXISTS `ad_business_assoc`;
CREATE TABLE `ad_business_assoc` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ad_id` int(10) unsigned NOT NULL,
  `business_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_ad_business_assoc_1` (`ad_id`),
  KEY `FK_ad_business_assoc_2` (`business_id`),
  CONSTRAINT `FK_ad_business_assoc_1` FOREIGN KEY (`ad_id`) REFERENCES `ad_master` (`id`),
  CONSTRAINT `FK_ad_business_assoc_2` FOREIGN KEY (`business_id`) REFERENCES `business_master` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ad_business_assoc`
--


/*!40000 ALTER TABLE `ad_business_assoc` DISABLE KEYS */;
LOCK TABLES `ad_business_assoc` WRITE;
INSERT INTO `ad_business_assoc` VALUES (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6),(7,7,7),(8,8,8),(9,9,9),(10,10,10),(11,11,11),(12,12,12),(13,13,13),(14,15,14),(15,16,15),(16,17,16),(17,18,17),(18,22,17),(19,23,18),(20,24,19),(21,25,19),(22,26,4),(23,27,19),(24,28,18),(25,29,19);
UNLOCK TABLES;
/*!40000 ALTER TABLE `ad_business_assoc` ENABLE KEYS */;

--
-- Table structure for table `ad_master`
--

DROP TABLE IF EXISTS `ad_master`;
CREATE TABLE `ad_master` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ad_code` varchar(10) NOT NULL,
  `ad_type` enum('T','P','V','TA','PA','PT','PAT','VA','VT','VAT') NOT NULL COMMENT 'Valid Ad type combinations are - Text(T),Text and Audio(TA),Picture(P),Picture and Audio(PA), Picture and Text, Picture and Audio and Text(PAT),Video(V),Video and Audio(VA), Video and Text(VT), Video and Audio and Text(VAT)',
  `play_duration` tinyint(4) NOT NULL,
  `text_ad_file_name` varchar(50) NOT NULL,
  `audio_ad_file_name` varchar(50) NOT NULL,
  `picture_ad_file_name` varchar(50) NOT NULL,
  `video_ad_file_name` varchar(50) NOT NULL,
  `latest_timestamp` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='stores information about ads';

--
-- Dumping data for table `ad_master`
--


/*!40000 ALTER TABLE `ad_master` DISABLE KEYS */;
LOCK TABLES `ad_master` WRITE;
INSERT INTO `ad_master` VALUES (1,'A000000001','V',41,'none','none','none','king.rpm','2006-10-25 13:08:55'),(2,'A000000002','V',29,'none','none','none','colgate.rpm','2006-10-25 13:08:55'),(3,'A000000003','V',21,'none','none','none','cafe.rpm','2006-10-25 13:08:55'),(4,'A000000004','V',16,'none','none','none','horlicks.rpm','2006-10-25 13:08:55'),(5,'A000000005','V',16,'none','none','none','mcdo.rpm','2006-10-25 13:08:55'),(6,'A000000006','V',12,'none','none','none','pizza.rpm','2006-10-25 13:08:55'),(7,'A000000007','V',11,'none','none','none','krack.rpm','2006-10-25 13:08:55'),(8,'A000000008','V',26,'none','none','none','melody.rpm','2006-10-25 13:08:55'),(9,'A000000009','V',36,'none','none','none','moto.rpm','2006-10-25 13:08:55'),(10,'A000000010','V',31,'none','none','none','ms.rpm','2006-10-25 13:08:55'),(11,'A000000011','V',21,'none','none','none','pure.rpm','2006-10-25 13:08:55'),(12,'A000000012','V',21,'none','none','none','titan.rpm','2006-11-06 16:28:13'),(13,'A00000013A','V',19,'none','none','none','facewash.rmvb','2006-10-25 13:08:55'),(14,'A00000013B','V',11,'none','none','none','facewash.rpm','2006-10-25 13:08:55'),(15,'A000000014','V',12,'none','none','none','dog.rpm','2006-10-25 13:08:55'),(16,'A000000015','V',25,'none','none','none','wakeup.rpm','2006-10-25 13:08:55'),(17,'A000000016','V',16,'none','none','none','cream.rpm','2006-10-25 13:08:55'),(18,'A000000020','TA',12,'Plylst1.wpl','Plylst2.wpl','none','none','2006-11-16 17:17:06'),(22,'A00000020D','P',7,'none','none','kashmir-winter-1.jpg','none','2006-11-18 12:07:05'),(23,'A000000021','T',13,'Plylst14.wpl','none','none','none','2006-10-29 12:38:31'),(24,'A000000029','P',30,'none','none','adbuslist.jpg','none','2006-11-18 13:11:12'),(25,'A000000030','P',12,'none','none','adbuslist.jpg','none','2006-11-02 14:50:01'),(26,'A000000039','P',18,'none','none','1.jpg','none','2006-11-09 12:13:51'),(27,'A000000059','P',45,'none','none','none','none','2006-11-18 13:22:46'),(28,'A00000021B','P',25,'none','none','21_2.gif','none','2006-11-18 11:28:52'),(29,'A00000059B','P',15,'none','none','21_3.gif','none','2006-11-18 12:09:44');
UNLOCK TABLES;
/*!40000 ALTER TABLE `ad_master` ENABLE KEYS */;

--
-- Table structure for table `ad_station_route_assoc`
--

DROP TABLE IF EXISTS `ad_station_route_assoc`;
CREATE TABLE `ad_station_route_assoc` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `station_route_id` int(10) unsigned NOT NULL,
  `ad_id` int(10) unsigned NOT NULL,
  `ad_category` enum('ER','PS') NOT NULL COMMENT 'valid values are EnRoute (ER) and PrimeSlot(PS)',
  `repeat_times` tinyint(3) unsigned NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `priority` int(10) unsigned NOT NULL,
  `is_active` char(1) NOT NULL default 'T',
  PRIMARY KEY  (`id`),
  KEY `FK_ad_station_route_assoc_2` (`ad_id`),
  KEY `station_route_id` (`station_route_id`),
  CONSTRAINT `ad_station_route_assoc_ibfk_1` FOREIGN KEY (`station_route_id`) REFERENCES `station_route_assoc` (`id`),
  CONSTRAINT `ad_station_route_assoc_ibfk_2` FOREIGN KEY (`ad_id`) REFERENCES `ad_master` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ad_station_route_assoc`
--


/*!40000 ALTER TABLE `ad_station_route_assoc` DISABLE KEYS */;
LOCK TABLES `ad_station_route_assoc` WRITE;
INSERT INTO `ad_station_route_assoc` VALUES (1,1,1,'PS',3,'2006-10-22 18:03:26','2006-11-12 18:03:31',1,'T'),(2,1,2,'PS',4,'2006-10-22 18:04:11','2006-11-12 18:04:14',4,'T'),(3,1,3,'PS',5,'2006-10-22 18:03:26','2006-11-12 18:03:31',3,'T'),(4,1,4,'PS',6,'2006-10-22 18:04:11','2006-11-12 18:04:14',2,'T'),(5,1,5,'PS',7,'2006-10-22 18:04:11','2006-11-12 18:04:14',1,'T'),(6,2,6,'ER',6,'2006-10-22 18:03:26','2006-11-12 18:03:31',1,'T'),(7,2,7,'ER',4,'2006-10-22 18:04:11','2006-11-12 18:04:14',5,'T'),(8,2,8,'ER',5,'2006-10-22 18:04:11','2006-11-12 18:04:14',4,'T'),(9,2,9,'ER',6,'2006-10-22 18:04:11','2006-11-12 18:04:14',3,'T'),(10,2,10,'ER',7,'2006-10-22 18:04:11','2006-11-12 18:04:14',2,'T'),(11,2,11,'ER',8,'2006-10-22 18:04:11','2006-11-12 18:04:14',1,'T'),(12,3,12,'ER',3,'2006-10-22 18:04:11','2006-11-12 18:04:14',1,'T'),(13,3,13,'ER',5,'2006-10-22 18:04:11','2006-11-12 18:04:14',4,'T'),(14,3,15,'ER',6,'2006-10-22 18:04:11','2006-11-12 18:04:14',3,'T'),(15,3,16,'ER',7,'2006-10-22 18:04:11','2006-11-12 18:04:14',2,'T'),(16,3,17,'ER',8,'2006-10-22 18:04:11','2006-11-12 18:04:14',1,'T'),(17,2,18,'PS',2,'2006-10-28 22:54:11','2006-11-04 22:54:14',0,'T'),(18,3,18,'ER',3,'2006-10-31 23:09:47','2006-11-07 23:09:49',5,'F'),(19,1,22,'PS',2,'2006-10-19 19:50:00','2006-10-26 19:50:38',8,'F'),(20,3,22,'ER',3,'2006-10-30 18:12:23','2007-01-31 18:12:00',5,''),(40,1,24,'PS',3,'2006-11-08 14:27:51','2006-11-20 14:27:55',2,'T'),(41,1,25,'PS',12,'2006-11-09 14:31:09','2006-10-30 14:31:13',5,'T'),(42,4,26,'PS',2,'2006-11-14 11:55:00','2006-11-15 11:55:00',3,'T'),(43,3,27,'ER',8,'2006-11-15 16:57:06','2006-11-18 16:57:00',3,'T'),(44,1,27,'PS',7,'2006-11-15 16:58:27','2006-11-17 16:58:29',5,'T'),(45,4,22,'PS',2,'2006-11-12 15:24:52','2006-11-22 15:24:54',3,'T'),(47,4,18,'PS',2,'2006-11-28 15:56:35','2006-12-06 15:56:36',2,'T'),(48,1,28,'PS',3,'2006-11-14 10:48:16','2006-11-30 10:48:18',4,'T'),(49,3,28,'ER',5,'2006-10-23 10:48:44','2006-12-22 10:48:48',3,'F'),(50,4,28,'PS',2,'2006-11-21 11:28:10','2006-11-29 11:28:21',3,'T'),(52,2,22,'ER',1,'2006-11-28 11:34:42','2006-12-21 11:34:44',3,'F'),(54,4,24,'PS',5,'2006-11-06 11:39:07','2006-11-23 11:39:08',3,'T'),(55,3,24,'ER',2,'2006-11-13 11:41:41','2006-11-29 11:41:43',5,'F'),(56,1,29,'PS',3,'2006-10-31 12:08:21','2006-12-13 12:08:24',5,'T'),(57,4,29,'PS',3,'2006-11-14 12:09:08','2006-11-29 12:09:09',3,'F'),(58,3,29,'PS',2,'2006-11-05 12:09:27','2007-01-11 12:09:29',4,'T');
UNLOCK TABLES;
/*!40000 ALTER TABLE `ad_station_route_assoc` ENABLE KEYS */;

--
-- Table structure for table `business_master`
--

DROP TABLE IF EXISTS `business_master`;
CREATE TABLE `business_master` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `business_code` varchar(10) NOT NULL,
  `business_name` varchar(20) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `is_active` char(1) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(30) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `business_code` (`business_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='stores information regarding various businesses';

--
-- Dumping data for table `business_master`
--


/*!40000 ALTER TABLE `business_master` DISABLE KEYS */;
LOCK TABLES `business_master` WRITE;
INSERT INTO `business_master` VALUES (1,'B000000001','Kingfisher Airlines','2006-10-22 15:03:38','2006-11-12 15:03:41','T','',''),(2,'B000000002','Colgate','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(3,'B000000003','Nescafe','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(4,'B000000004','Horlicks','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(5,'B000000005','Mc Donalds','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(6,'B000000006','Dominos','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(7,'B000000007','Krackjack','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(8,'B000000008','Melody','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(9,'B000000009','Motorola','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(10,'B000000010','Microsoft','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(11,'B000000011','Pure','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(12,'B000000012','Titan','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(13,'B000000013','Garnier','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(14,'B000000014','Pedigree','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(15,'B000000015','Grahak wakeup','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(16,'B000000016','Fair & Handsome','2006-10-22 15:05:41','2006-11-12 15:05:44','T','',''),(17,'B000000020','New Business','2006-10-27 22:13:25','2006-11-28 22:13:30','F','+91 0000 000 000','name@domain.com'),(18,'B000000021','Smart Biz','2006-10-01 17:19:24','2006-10-31 17:19:28','T','+91 1111 111 111','someone@biz.com'),(19,'B000000120','TestBusy','2006-11-07 14:18:20','2006-11-11 14:18:00','F','32423423433423','abc@xyz.org'),(20,'zAb','werwer','2006-11-05 17:03:03','2006-11-30 17:03:05','F','34234324324','rwerwer@wer.com');
UNLOCK TABLES;
/*!40000 ALTER TABLE `business_master` ENABLE KEYS */;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
CREATE TABLE `routes` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `route_code` varchar(5) NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `route_code` (`route_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `routes`
--


/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
LOCK TABLES `routes` WRITE;
INSERT INTO `routes` VALUES (0,'RRRRR','undefined route'),(1,'R0001','Route 1'),(2,'R0002','Route 2');
UNLOCK TABLES;
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;

--
-- Table structure for table `station_route_assoc`
--

DROP TABLE IF EXISTS `station_route_assoc`;
CREATE TABLE `station_route_assoc` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `station_id` int(10) unsigned NOT NULL,
  `route_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `FK_station_route_assoc_1` (`station_id`),
  KEY `FK_station_route_assoc_2` (`route_id`),
  CONSTRAINT `FK_station_route_assoc_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`),
  CONSTRAINT `FK_station_route_assoc_2` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `station_route_assoc`
--


/*!40000 ALTER TABLE `station_route_assoc` DISABLE KEYS */;
LOCK TABLES `station_route_assoc` WRITE;
INSERT INTO `station_route_assoc` VALUES (1,1,0),(2,2,0),(3,3,0),(4,3,1);
UNLOCK TABLES;
/*!40000 ALTER TABLE `station_route_assoc` ENABLE KEYS */;

--
-- Table structure for table `stations`
--

DROP TABLE IF EXISTS `stations`;
CREATE TABLE `stations` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `station_code` varchar(4) NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `station_code` (`station_code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stations`
--


/*!40000 ALTER TABLE `stations` DISABLE KEYS */;
LOCK TABLES `stations` WRITE;
INSERT INTO `stations` VALUES (1,'T001','Station 1'),(2,'T002','Station 2'),(3,'T003','Station 3'),(4,'T004','Station 4');
UNLOCK TABLES;
/*!40000 ALTER TABLE `stations` ENABLE KEYS */;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
CREATE TABLE `test` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `x` char(1) NOT NULL,
  `n` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `test`
--


/*!40000 ALTER TABLE `test` DISABLE KEYS */;
LOCK TABLES `test` WRITE;
INSERT INTO `test` VALUES (1,'A',1),(2,'A',2),(3,'A',3),(4,'A',4),(5,'A',5),(6,'A',6),(7,'A',7),(8,'B',1),(9,'B',2),(10,'B',3),(11,'B',4),(12,'B',5),(13,'C',1),(14,'C',2),(15,'C',3),(16,'D',1),(17,'D',2);
UNLOCK TABLES;
/*!40000 ALTER TABLE `test` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

