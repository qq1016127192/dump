-- MySQL dump 10.13  Distrib 5.7.44, for Linux (x86_64)
--
-- Host: localhost    Database: 112233
-- ------------------------------------------------------
-- Server version	5.7.44-log

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
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL COMMENT '公告标题',
  `content` text NOT NULL COMMENT '公告内容',
  `type` varchar(50) DEFAULT 'info' COMMENT '公告类型：info, warning, error, success',
  `priority` int(11) DEFAULT '0' COMMENT '优先级，数字越大优先级越高',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0=禁用，1=启用',
  `publish_at` datetime DEFAULT NULL COMMENT '发布时间',
  `expires_at` datetime DEFAULT NULL COMMENT '过期时间',
  `created_by` int(11) DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_publish_at` (`publish_at`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coin_packages`
--

DROP TABLE IF EXISTS `coin_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coin_packages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '套餐名称',
  `coins` decimal(10,2) NOT NULL COMMENT '金币数量',
  `price` decimal(10,2) NOT NULL COMMENT '价格（人民币）',
  `bonus_coins` decimal(10,2) DEFAULT '0.00' COMMENT '赠送金币',
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '套餐描述',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='金币充值套餐表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coin_packages`
--

LOCK TABLES `coin_packages` WRITE;
/*!40000 ALTER TABLE `coin_packages` DISABLE KEYS */;
INSERT INTO `coin_packages` VALUES (6,'10金币',10.00,1.00,0.00,'新手首充',1,1,'2025-11-03 00:15:24','2025-11-03 00:15:24'),(12,'50金币',50.00,5.00,5.00,'赠送5金币',1,2,'2025-11-03 00:16:13','2025-11-03 00:16:13'),(13,'100金币',100.00,10.00,15.00,'赠送15金币',1,3,'2025-11-03 00:16:13','2025-11-03 00:16:13');
/*!40000 ALTER TABLE `coin_packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coin_size_config`
--

DROP TABLE IF EXISTS `coin_size_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coin_size_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型：download=下载，dump=砸壳',
  `min_size_mb` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '最小大小（MB）',
  `max_size_mb` decimal(10,2) DEFAULT NULL COMMENT '最大大小（MB），NULL表示无上限',
  `coin_cost` decimal(10,2) NOT NULL COMMENT '金币消耗',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序顺序',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_size_range` (`min_size_mb`,`max_size_mb`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='应用大小范围金币配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coin_size_config`
--

LOCK TABLES `coin_size_config` WRITE;
/*!40000 ALTER TABLE `coin_size_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `coin_size_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coin_transactions`
--

DROP TABLE IF EXISTS `coin_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `coin_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `type` enum('charge','consume','refund','reward') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交易类型',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  `balance_before` decimal(10,2) NOT NULL COMMENT '交易前余额',
  `balance_after` decimal(10,2) NOT NULL COMMENT '交易后余额',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交易描述',
  `related_id` int(11) DEFAULT NULL COMMENT '关联ID(任务ID等)',
  `related_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '关联类型',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='金币交易记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coin_transactions`
--

LOCK TABLES `coin_transactions` WRITE;
/*!40000 ALTER TABLE `coin_transactions` DISABLE KEYS */;
INSERT INTO `coin_transactions` VALUES (1,2,'consume',-0.05,1000.00,999.95,'下载: 菜鸟—快递物流轻松查寄取 876590545',NULL,NULL,'2025-11-03 05:45:37'),(2,2,'consume',-0.01,999.95,999.94,'砸壳: 测速网 875927288',NULL,NULL,'2025-11-03 05:46:02'),(3,2,'consume',-0.10,999.94,999.84,'下载: 微信 876419863',NULL,NULL,'2025-11-03 19:50:58'),(4,2,'consume',-0.01,999.84,999.83,'下载: 测速网 878978682',NULL,NULL,'2025-11-03 20:06:16'),(5,2,'consume',-0.01,999.83,999.82,'砸壳: 测速网 869808360',NULL,NULL,'2025-11-03 22:40:04'),(6,2,'consume',-0.01,999.82,999.81,'砸壳: 测速网 872456233',NULL,NULL,'2025-11-03 22:40:51'),(7,2,'consume',-0.01,999.81,999.80,'砸壳: 测速网 870774661',NULL,NULL,'2025-11-03 22:47:29'),(8,2,'consume',-0.01,999.80,999.79,'砸壳: 测速网 872456233',NULL,NULL,'2025-11-03 22:48:57'),(9,2,'consume',-0.01,999.79,999.78,'砸壳: 测速网 867229662',NULL,NULL,'2025-11-03 22:50:13'),(10,2,'consume',-0.01,999.78,999.77,'砸壳: 测速网 864724405',NULL,NULL,'2025-11-03 23:03:41'),(11,3,'reward',10.00,0.00,10.00,'新用户注册奖励',NULL,NULL,'2025-11-03 23:04:23'),(12,2,'consume',-0.20,999.77,999.57,'砸壳: 微信 9734445',NULL,NULL,'2025-11-03 23:34:55'),(13,2,'consume',-0.05,999.57,999.52,'砸壳: 菜鸟—快递物流轻松查寄取 876823952',NULL,NULL,'2025-11-03 23:46:33'),(14,2,'consume',-0.20,999.52,999.32,'砸壳: 微信 9734445',NULL,NULL,'2025-11-03 23:49:59'),(15,2,'consume',-0.20,999.32,999.12,'砸壳: 微信 9734445',NULL,NULL,'2025-11-03 23:59:55'),(16,2,'consume',-0.20,999.12,998.92,'砸壳: 微信 9734445',NULL,NULL,'2025-11-04 00:02:32'),(17,2,'consume',-0.20,998.92,998.72,'砸壳: 微信 9734445',NULL,NULL,'2025-11-04 00:05:39'),(18,2,'consume',-0.20,998.72,998.52,'砸壳: 微信 877587326',NULL,NULL,'2025-11-04 00:06:07'),(19,2,'consume',-0.20,998.52,998.32,'砸壳: 微信 9734445',NULL,NULL,'2025-11-04 00:09:35'),(20,2,'consume',-0.05,998.32,998.27,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:06:10'),(21,2,'consume',-0.05,998.27,998.22,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:06:18'),(22,2,'consume',-0.05,998.22,998.17,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:10:03'),(23,2,'consume',-0.05,998.17,998.12,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:10:09'),(24,2,'consume',-0.05,998.12,998.07,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:12:06'),(25,2,'consume',-0.05,998.07,998.02,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-06 09:14:41'),(26,2,'consume',-0.01,998.02,998.01,'下载: Deliveries: a package tracker 877264149',NULL,NULL,'2025-11-06 09:15:42'),(27,2,'consume',-0.01,998.01,998.00,'下载: 网易云音乐-数千万歌曲畅听 876287846',NULL,NULL,'2025-11-07 02:15:13'),(28,2,'consume',-0.01,998.00,997.99,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-07 02:17:28'),(29,3,'consume',-0.01,10.00,9.99,'下载: 网速测试大师 - speedtest 测网速，wifi测速 854749606',NULL,NULL,'2025-11-07 02:18:08'),(30,3,'consume',-0.01,9.99,9.98,'下载: 网速测试大师 - speedtest 测网速，wifi测速 854749606',NULL,NULL,'2025-11-07 02:18:11'),(31,3,'consume',-0.01,9.98,9.97,'下载: Deliveries: a package tracker 877264149',NULL,NULL,'2025-11-07 02:18:18'),(32,2,'consume',-0.01,997.99,997.98,'下载: 全球网测 869888523',NULL,NULL,'2025-11-07 02:28:43'),(33,2,'consume',-0.01,997.98,997.97,'下载: 全球网测 869888523',NULL,NULL,'2025-11-07 02:46:02'),(34,2,'consume',-0.01,997.97,997.96,'砸壳: 飞牛 879261847',NULL,NULL,'2025-11-07 10:38:22'),(35,2,'consume',-0.01,997.96,997.95,'下载: 全球网测 869888523',NULL,NULL,'2025-11-07 11:00:27'),(36,2,'consume',-0.01,997.95,997.94,'下载: 全球网测 869888523',NULL,NULL,'2025-11-07 11:41:15'),(37,2,'consume',-0.01,997.94,997.93,'下载: 全球网测 869888523',NULL,NULL,'2025-11-07 11:41:26'),(38,2,'consume',-0.01,997.93,997.92,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-08 02:07:26'),(39,2,'consume',-0.01,997.92,997.91,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-08 02:07:59'),(40,2,'consume',-0.01,997.91,997.90,'下载: McDonald\'s 878242137',NULL,NULL,'2025-11-08 02:10:28');
/*!40000 ALTER TABLE `coin_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_usage`
--

DROP TABLE IF EXISTS `daily_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_usage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `action_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型：download, dump',
  `usage_date` date NOT NULL COMMENT '使用日期',
  `usage_count` int(11) NOT NULL DEFAULT '0' COMMENT '使用次数',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_action_date` (`user_id`,`action_type`,`usage_date`),
  KEY `idx_usage_date` (`usage_date`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='每日使用记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_usage`
--

LOCK TABLES `daily_usage` WRITE;
/*!40000 ALTER TABLE `daily_usage` DISABLE KEYS */;
INSERT INTO `daily_usage` VALUES (1,2,'download','2025-11-03',13,'2025-11-03 01:38:58','2025-11-03 05:45:37'),(2,2,'dump','2025-11-03',20,'2025-11-03 01:39:29','2025-11-03 05:46:02'),(34,2,'download','2025-11-04',5,'2025-11-03 17:34:34','2025-11-03 20:06:16'),(38,2,'dump','2025-11-04',17,'2025-11-03 20:05:59','2025-11-04 00:09:35'),(48,3,'dump','2025-11-04',1,'2025-11-03 23:04:44','2025-11-03 23:04:44'),(57,2,'download','2025-11-05',1,'2025-11-04 16:14:39','2025-11-04 16:14:39'),(58,2,'download','2025-11-06',11,'2025-11-06 09:03:15','2025-11-06 09:19:22'),(63,2,'dump','2025-11-06',1,'2025-11-06 09:07:47','2025-11-06 09:07:47'),(70,2,'download','2025-11-07',10,'2025-11-07 01:05:35','2025-11-07 11:41:26'),(75,3,'download','2025-11-07',6,'2025-11-07 02:18:01','2025-11-07 02:18:18'),(81,4,'download','2025-11-07',3,'2025-11-07 02:28:00','2025-11-07 02:28:07'),(86,2,'dump','2025-11-07',1,'2025-11-07 10:38:22','2025-11-07 10:38:22'),(90,2,'download','2025-11-08',6,'2025-11-07 22:10:41','2025-11-08 02:10:28'),(96,2,'download','2025-11-09',2,'2025-11-08 23:24:57','2025-11-08 23:27:40');
/*!40000 ALTER TABLE `daily_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号',
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `product_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '产品类型：coin_package, vip_package',
  `product_id` int(11) NOT NULL COMMENT '产品ID',
  `amount` decimal(10,2) NOT NULL COMMENT '订单金额',
  `final_price_source` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trade_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '支付平台交易号',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '订单状态',
  `cert_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '证书ID',
  `udid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `payment_method_id` int(11) DEFAULT NULL COMMENT '支付方式ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'COIN1762132965357DNLSQSIN3',2,'coin_package',13,10.00,NULL,NULL,'pending',NULL,NULL,NULL,1,'2025-11-03 01:22:45','2025-11-03 01:22:45'),(2,'COIN1762133144667JP4SC3MS0',2,'coin_package',6,1.00,NULL,NULL,'pending',NULL,NULL,NULL,1,'2025-11-03 01:25:44','2025-11-03 01:25:44'),(3,'COIN1762567912176K4OJZHOMZ',2,'coin_package',6,1.00,NULL,NULL,'pending',NULL,NULL,NULL,1,'2025-11-08 02:11:52','2025-11-08 02:11:52');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_configs`
--

DROP TABLE IF EXISTS `payment_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_method_id` int(11) NOT NULL COMMENT '支付方式ID',
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text COLLATE utf8mb4_unicode_ci COMMENT '配置值',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_payment_method_key` (`payment_method_id`,`config_key`),
  KEY `idx_payment_method_id` (`payment_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_configs`
--

LOCK TABLES `payment_configs` WRITE;
/*!40000 ALTER TABLE `payment_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式名称',
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '支付方式代码：alipay, wechat等',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '支付方式描述',
  `type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付类型：alipay, wechat, bank等',
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '图标URL',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `config` text COLLATE utf8mb4_unicode_ci COMMENT '配置信息，JSON格式',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付方式表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,'支付宝','alipay','安全快捷的在线支付','alipay',NULL,1,0,NULL,'2025-11-03 01:19:25','2025-11-03 01:19:25');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_config`
--

DROP TABLE IF EXISTS `site_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_value` text COLLATE utf8mb4_unicode_ci,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_config`
--

LOCK TABLES `site_config` WRITE;
/*!40000 ALTER TABLE `site_config` DISABLE KEYS */;
INSERT INTO `site_config` VALUES (1,'main_site_token','api_623bf02d88bb55d56572050d28f23815ffbe867443c65b85bd133deeebfa996d','主站API Token，用于与主站对接','2025-11-03 00:32:08','2025-11-08 23:27:31');
/*!40000 ALTER TABLE `site_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_config`
--

DROP TABLE IF EXISTS `system_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键名',
  `config_value` text COLLATE utf8mb4_unicode_ci COMMENT '配置值',
  `config_group` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'general' COMMENT '配置分组',
  `config_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '配置描述',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_config`
--

LOCK TABLES `system_config` WRITE;
/*!40000 ALTER TABLE `system_config` DISABLE KEYS */;
INSERT INTO `system_config` VALUES (1,'coin_download_cost','0.01','coin','普通用户下载消耗金币数','2025-11-03 07:56:20','2025-11-03 07:56:20'),(2,'coin_dump_cost','0.01','coin','普通用户砸壳消耗金币数','2025-11-03 07:56:20','2025-11-03 07:56:20'),(3,'free_download_daily','3','limit','普通用户每天免费下载次数','2025-11-03 07:56:20','2025-11-03 07:56:20'),(4,'free_dump_daily','0','limit','普通用户每天免费砸壳次数','2025-11-03 07:56:20','2025-11-07 18:37:58'),(5,'vip_download_free','1','vip','会员下载是否免费（1=是，0=否）','2025-11-03 07:56:20','2025-11-03 07:56:20'),(6,'vip_dump_free','1','vip','会员砸壳是否免费（1=是，0=否）','2025-11-03 07:56:20','2025-11-03 07:56:20'),(7,'vip_free_download_daily','20','vip','会员每天免费下载次数','2025-11-03 07:56:20','2025-11-03 07:56:20'),(8,'vip_free_dump_daily','20','vip','会员每天免费砸壳次数','2025-11-03 07:56:20','2025-11-03 07:56:20'),(9,'default_user_coins','10','coin','新用户注册默认金币','2025-11-03 07:56:20','2025-11-07 18:37:58'),(20,'seo.site_title','测试1','seo','SEO设置: site_title','2025-11-04 12:24:23','2025-11-04 12:34:38'),(21,'seo.site_subtitle','','seo','SEO设置: site_subtitle','2025-11-04 12:24:23','2025-11-04 12:34:38'),(22,'seo.site_description','','seo','SEO设置: site_description','2025-11-04 12:24:23','2025-11-04 12:34:38'),(23,'seo.site_keywords','','seo','SEO设置: site_keywords','2025-11-04 12:24:23','2025-11-04 12:34:38'),(24,'site_free_mode','0','limit',NULL,'2025-11-06 17:19:14','2025-11-07 10:15:00');
/*!40000 ALTER TABLE `system_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tasks`
--

DROP TABLE IF EXISTS `user_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '分站用户ID',
  `main_task_id` int(11) NOT NULL COMMENT '主站任务ID',
  `bundle_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用Bundle ID',
  `app_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用名称',
  `version` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'App Store发行号',
  `real_version` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '真实版本号',
  `country` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'cn' COMMENT '国家/地区',
  `icon_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '应用图标URL',
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'queued' COMMENT '任务状态：queued, running, done, error',
  `progress` int(11) DEFAULT '0' COMMENT '进度（0-100）',
  `error` text COLLATE utf8mb4_unicode_ci COMMENT '错误信息',
  `download_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '下载链接',
  `alist_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Alist链接',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_main_task_id` (`main_task_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tasks`
--

LOCK TABLES `user_tasks` WRITE;
/*!40000 ALTER TABLE `user_tasks` DISABLE KEYS */;
INSERT INTO `user_tasks` VALUES (1,2,2337,'com.JuQing.NetworkManager','测速网','869360160','1.3.4','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.4_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.4_decrypted.ipa','2025-11-03 22:34:17','2025-11-08 00:35:14'),(2,2,2338,'com.JuQing.NetworkManager','测速网','869808360','1.3.5','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.5_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.5_decrypted.ipa','2025-11-03 22:40:04','2025-11-08 00:35:14'),(3,2,2339,'com.JuQing.NetworkManager','测速网','872456233','1.4.0','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','running',60,NULL,NULL,NULL,'2025-11-03 22:40:51','2025-11-03 23:05:21'),(4,2,2340,'com.JuQing.NetworkManager','测速网','870774661','1.3.6','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.6_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.6_decrypted.ipa','2025-11-03 22:47:29','2025-11-08 00:35:14'),(5,2,2341,'com.JuQing.NetworkManager','测速网','872456233','1.4.0','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.4.0_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.4.0_decrypted.ipa','2025-11-03 22:48:57','2025-11-08 00:35:14'),(6,2,2342,'com.JuQing.NetworkManager','测速网','867229662','1.3.2','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.2_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.3.2_decrypted.ipa','2025-11-03 22:50:13','2025-11-08 00:35:14'),(7,2,2343,'com.JuQing.NetworkManager','测速网','864724405','1.2.7','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.2.7_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.JuQing.NetworkManager/测速网_1.2.7_decrypted.ipa','2025-11-03 23:03:41','2025-11-08 00:35:14'),(8,3,2344,'com.JuQing.NetworkManager','测速网','865787307','1.2.8','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/100x100bb.jpg','running',10,NULL,NULL,NULL,'2025-11-03 23:04:44','2025-11-03 23:04:51'),(9,2,2345,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','running',60,NULL,NULL,NULL,'2025-11-03 23:34:55','2025-11-03 23:46:41'),(10,2,2346,'com.cainiao.cnwireless','菜鸟—快递物流轻松查寄取','876823952','8.10.805','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/3e/05/8f/3e058fd3-f8b6-06e3-9256-a11031be61b8/AppIcon-0-1x_U007epad-0-1-0-85-220-0.png/100x100bb.jpg','done',100,NULL,'https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.cainiao.cnwireless/菜鸟—快递物流轻松查寄取_8.10.805_decrypted.ipa','https://pan.363210.com/d/tianyi/ipa11/2025-11-04/com.cainiao.cnwireless/菜鸟—快递物流轻松查寄取_8.10.805_decrypted.ipa','2025-11-03 23:46:33','2025-11-08 00:35:14'),(11,2,2347,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','running',60,NULL,NULL,NULL,'2025-11-03 23:49:59','2025-11-03 23:53:54'),(12,2,2348,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-03 23:59:55','2025-11-03 23:59:55'),(13,2,2349,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-04 00:02:32','2025-11-04 00:02:32'),(14,2,2350,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-04 00:05:39','2025-11-04 00:05:39'),(15,2,2351,'com.tencent.xin','微信','877587326','8.0.63','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-04 00:06:07','2025-11-04 00:06:07'),(16,2,2352,'com.tencent.xin','微信','9734445','8.0.64','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/80/ad/eb/80adeb0e-5580-f51e-d0d0-64564029fb46/AppIcon-0-0-1x_U007epad-0-6-0-sRGB-0-85-220.png/100x100bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-04 00:09:35','2025-11-04 00:09:35'),(17,2,2378,'com.JuQing.NetworkManager','测速网','874064948','1.4.3','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/bb/19/06/bb1906ad-3e5e-43c6-9366-2529101aaa76/AppIcon-common-0-0-1x_U007epad-0-1-0-85-220.png/512x512bb.jpg','running',10,NULL,NULL,NULL,'2025-11-06 09:07:47','2025-11-06 09:07:51'),(18,2,2393,'com.trim.app.ios','飞牛','879261847','1.24.2','cn','https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/2d/0c/4a/2d0c4ae6-ecb9-5708-fa73-3fba327df5cd/AppIcon-0-0-1x_U007emarketing-0-8-0-85-220.png/512x512bb.jpg','queued',0,NULL,NULL,NULL,'2025-11-07 10:38:22','2025-11-07 10:38:22');
/*!40000 ALTER TABLE `user_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invite_code` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inviter_id` int(11) DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `device_udid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否管理员',
  `remark` text COLLATE utf8mb4_unicode_ci COMMENT '备注信息',
  `last_login` datetime DEFAULT NULL COMMENT '最后登录时间',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `registration_ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '注册IP地址',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `balance` decimal(10,2) DEFAULT '0.00' COMMENT '金币余额',
  `agent_level` int(11) NOT NULL DEFAULT '0' COMMENT '代理级别',
  `agent_discount` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '代理折扣百分比',
  `is_agent` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否为代理: 0=否, 1=是',
  `is_vip` tinyint(1) DEFAULT '0' COMMENT '是否为VIP用户',
  `vip_level` int(11) DEFAULT '0' COMMENT '会员等级',
  `vip_expires_at` datetime DEFAULT NULL COMMENT 'VIP过期时间',
  `auto_login` tinyint(1) NOT NULL DEFAULT '0' COMMENT '自动登录：1启用，0禁用',
  `email_notifications` tinyint(1) NOT NULL DEFAULT '1' COMMENT '邮箱通知：1启用，0禁用',
  `push_notifications` tinyint(1) NOT NULL DEFAULT '1' COMMENT '推送通知：1启用，0禁用',
  `theme` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'light' COMMENT '主题：light,dark,auto',
  `language` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'zh-CN' COMMENT '语言设置',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_is_admin` (`is_admin`),
  KEY `idx_is_vip` (`is_vip`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,NULL,NULL,'admin','$2b$10$DZCP/cPcFp2XhNKQlQJVGeFPZxb9kmTUvMf3ui1nqbW8c6ZAFnKPe',NULL,'admin@example.com',NULL,1,1,NULL,'2025-11-13 00:17:19','2025-11-02 23:58:53','127.0.0.1','2025-11-12 16:17:19',997.90,0,0.00,0,0,0,NULL,0,1,1,'light','zh-CN'),(3,NULL,NULL,'112233','$2b$10$HtehBW7o76uMegyxvqMP2.y7CLurhNH1FCjUg1TCebjkEBzlUfvHi',NULL,'112233',NULL,1,0,NULL,'2025-11-07 10:17:58','2025-11-03 23:04:23','127.0.0.1','2025-11-07 02:18:18',9.97,0,0.00,0,0,0,NULL,0,1,1,'light','zh-CN'),(4,NULL,NULL,'11223344','$2b$10$RCroWSRJGoKqeq.KTUF9y.K3o/l1wW2ayc2lXodb.eZwEirtxb4Aa',NULL,'11223344@qq.com',NULL,1,0,NULL,'2025-11-07 10:27:57','2025-11-07 02:27:54','127.0.0.1','2025-11-07 02:27:57',0.00,0,0.00,0,0,0,NULL,0,1,1,'light','zh-CN');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vip_orders`
--

DROP TABLE IF EXISTS `vip_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vip_orders` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户ID',
  `package_id` int(11) NOT NULL COMMENT '套餐ID',
  `order_no` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单号',
  `package_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '套餐名称',
  `amount` decimal(10,2) NOT NULL COMMENT '支付金额',
  `duration` int(11) DEFAULT NULL COMMENT '有效期天数',
  `pay_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付方式：coin(金币), alipay(支付宝), wechat(微信)',
  `payment_method_id` int(11) DEFAULT NULL COMMENT '支付方式ID',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT '订单状态：pending(待支付), paid(已支付), expired(已过期), cancelled(已取消)',
  `paid_at` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  `expire_time` datetime DEFAULT NULL COMMENT '会员到期时间',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='会员订单记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vip_orders`
--

LOCK TABLES `vip_orders` WRITE;
/*!40000 ALTER TABLE `vip_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `vip_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vip_packages`
--

DROP TABLE IF EXISTS `vip_packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vip_packages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '套餐名称',
  `vip_level` int(11) DEFAULT '0' COMMENT '会员等级',
  `price` decimal(10,2) NOT NULL COMMENT '价格（人民币）',
  `duration` int(11) NOT NULL COMMENT '有效期天数',
  `coin_price` decimal(10,2) DEFAULT NULL COMMENT '金币价格',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '套餐描述',
  `features` text COLLATE utf8mb4_unicode_ci COMMENT '特权功能，JSON格式',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `is_popular` tinyint(1) DEFAULT '0' COMMENT '是否热门',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='VIP套餐表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vip_packages`
--

LOCK TABLES `vip_packages` WRITE;
/*!40000 ALTER TABLE `vip_packages` DISABLE KEYS */;
INSERT INTO `vip_packages` VALUES (7,'月度会员',1,9.90,30,100.00,'享受1个月会员特权，免费下载砸壳',NULL,1,0,1,1,'2025-11-03 00:16:13','2025-11-03 00:16:13'),(8,'季度会员',2,24.90,90,250.00,'享受3个月会员特权，更优惠',NULL,2,0,1,1,'2025-11-03 00:16:13','2025-11-03 00:16:13'),(9,'年度会员',3,88.00,365,900.00,'享受12个月会员特权，最超值',NULL,3,0,1,1,'2025-11-03 00:16:13','2025-11-03 00:16:13');
/*!40000 ALTER TABLE `vip_packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database '112233'
--

--
-- Dumping routines for database '112233'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-13  0:18:53
