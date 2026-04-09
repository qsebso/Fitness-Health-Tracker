CREATE DATABASE  IF NOT EXISTS `fitness_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `fitness_db`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: fitness_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievement_definitions`
--

DROP TABLE IF EXISTS `achievement_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement_definitions` (
  `achievement_def_id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`achievement_def_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievement_definitions`
--

LOCK TABLES `achievement_definitions` WRITE;
/*!40000 ALTER TABLE `achievement_definitions` DISABLE KEYS */;
INSERT INTO `achievement_definitions` VALUES (1,'steps_streak_5','10K Steps Streak','Hit at least 10,000 steps for 5 consecutive days.'),(2,'meal_prep_14','Meal Prep Master','Logged all meals for 14 straight days.'),(3,'yoga_20','Mobility Milestone','Completed 20 yoga sessions.'),(4,'hydration_god','Hydration Hero','Met daily water goal for 2 weeks.');
/*!40000 ALTER TABLE `achievement_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_checkins`
--

DROP TABLE IF EXISTS `daily_checkins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_checkins` (
  `checkin_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `record_date` date NOT NULL,
  `eating_quality` enum('poor','average','good') NOT NULL,
  `energy_level` enum('low','medium','high') NOT NULL,
  `adherence_to_plan` enum('poor','average','good') NOT NULL,
  `notes` text,
  PRIMARY KEY (`checkin_id`),
  UNIQUE KEY `unique_checkin_per_day` (`user_id`,`record_date`),
  CONSTRAINT `daily_checkins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_checkins`
--

LOCK TABLES `daily_checkins` WRITE;
/*!40000 ALTER TABLE `daily_checkins` DISABLE KEYS */;
INSERT INTO `daily_checkins` VALUES (1,1,'2026-03-14','good','high','good','Great workout consistency this week.'),(2,2,'2026-03-14','average','medium','good','Missed one snack but stayed on plan.'),(3,3,'2026-03-14','good','low','average','Low energy day, focused on mobility.'),(4,4,'2026-03-14','poor','medium','poor','Work stress affected meals and workout.'),(5,5,'2026-03-14','good','high','good','Hydration and sleep improved.'),(6,6,'2026-03-27','good','high','good','Solid week.'),(7,6,'2026-03-28','average','medium','good',NULL),(8,6,'2026-03-29','good','high','good','Hit step goal again.');
/*!40000 ALTER TABLE `daily_checkins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_metrics`
--

DROP TABLE IF EXISTS `daily_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_metrics` (
  `metric_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `record_date` date NOT NULL,
  `weight_lbs` decimal(5,2) NOT NULL,
  `steps` int NOT NULL,
  `sleep_hours` decimal(5,2) NOT NULL,
  `water_intake_cups` decimal(5,2) NOT NULL,
  PRIMARY KEY (`metric_id`),
  UNIQUE KEY `unique_metric_per_day` (`user_id`,`record_date`),
  CONSTRAINT `daily_metrics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `daily_metrics_chk_1` CHECK (((`weight_lbs` > 0) and (`weight_lbs` < 1000))),
  CONSTRAINT `daily_metrics_chk_2` CHECK (((`steps` >= 0) and (`steps` < 100000))),
  CONSTRAINT `daily_metrics_chk_3` CHECK (((`sleep_hours` >= 0) and (`sleep_hours` <= 24))),
  CONSTRAINT `daily_metrics_chk_4` CHECK (((`water_intake_cups` >= 0) and (`water_intake_cups` < 100)))
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_metrics`
--

LOCK TABLES `daily_metrics` WRITE;
/*!40000 ALTER TABLE `daily_metrics` DISABLE KEYS */;
INSERT INTO `daily_metrics` VALUES (1,1,'2026-03-14',182.40,9200,7.50,10.00),(2,1,'2026-03-15',182.00,10400,8.00,11.50),(3,2,'2026-03-14',140.20,13200,7.00,9.00),(4,2,'2026-03-15',139.80,11850,6.50,8.50),(5,3,'2026-03-14',168.70,7600,8.50,12.00),(6,4,'2026-03-14',175.10,15000,6.00,7.50),(7,5,'2026-03-14',128.50,8900,7.80,10.00),(8,6,'2026-03-16',172.40,9300,7.50,10.00),(9,6,'2026-03-17',172.20,9100,7.25,9.50),(10,6,'2026-03-18',172.00,9400,7.00,10.00),(11,6,'2026-03-19',171.90,9200,7.50,9.00),(12,6,'2026-03-20',171.80,9500,6.75,10.00),(13,6,'2026-03-21',171.70,8800,8.00,10.00),(14,6,'2026-03-22',171.60,9100,7.50,9.50),(15,6,'2026-03-23',171.50,9000,7.25,10.00),(16,6,'2026-03-24',171.40,8900,7.50,9.00),(17,6,'2026-03-25',171.30,10400,7.50,10.00),(18,6,'2026-03-26',171.20,10600,7.00,10.00),(19,6,'2026-03-27',171.10,10800,7.50,10.00),(20,6,'2026-03-28',171.00,11000,7.25,10.00),(21,6,'2026-03-29',170.90,11200,7.50,10.00);
/*!40000 ALTER TABLE `daily_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_types`
--

DROP TABLE IF EXISTS `exercise_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exercise_types` (
  `exercise_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `muscle_group` varchar(255) NOT NULL,
  `calories_per_hour` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`exercise_id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `exercise_types_chk_1` CHECK ((`calories_per_hour` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_types`
--

LOCK TABLES `exercise_types` WRITE;
/*!40000 ALTER TABLE `exercise_types` DISABLE KEYS */;
INSERT INTO `exercise_types` VALUES (1,'Push-ups','Strength','Chest',420.00),(2,'Pull-ups','Strength','Back',500.00),(3,'Squats','Strength','Legs',450.00),(4,'Running','Cardio','Full Body',700.00),(5,'Cycling','Cardio','Legs',600.00),(6,'Yoga','Mobility','Core',260.00),(7,'Plank','Strength','Core',300.00);
/*!40000 ALTER TABLE `exercise_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goals`
--

DROP TABLE IF EXISTS `goals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `goals` (
  `goal_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `goal_type` enum('weight_loss','weight_gain','muscle_gain','endurance') NOT NULL,
  `target_value` decimal(6,2) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','completed','paused') NOT NULL,
  PRIMARY KEY (`goal_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `goals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `goals_chk_1` CHECK (((`end_date` is null) or (`end_date` > `start_date`)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goals`
--

LOCK TABLES `goals` WRITE;
/*!40000 ALTER TABLE `goals` DISABLE KEYS */;
INSERT INTO `goals` VALUES (1,1,'weight_loss',175.00,'2026-03-01','2026-06-01','active'),(2,2,'endurance',10.00,'2026-02-15','2026-05-15','active'),(3,3,'muscle_gain',8.00,'2026-01-10',NULL,'paused'),(4,4,'weight_gain',182.00,'2025-12-01','2026-03-01','completed'),(5,5,'endurance',5.00,'2026-03-10','2026-04-30','active'),(6,6,'weight_loss',165.00,'2026-03-01','2026-06-30','active');
/*!40000 ALTER TABLE `goals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_memberships`
--

DROP TABLE IF EXISTS `group_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_memberships` (
  `membership_id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `user_id` int NOT NULL,
  `role` enum('owner','member') NOT NULL DEFAULT 'member',
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`membership_id`),
  UNIQUE KEY `unique_group_membership` (`group_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `group_memberships_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `support_groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `group_memberships_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_memberships`
--

LOCK TABLES `group_memberships` WRITE;
/*!40000 ALTER TABLE `group_memberships` DISABLE KEYS */;
INSERT INTO `group_memberships` VALUES (1,1,6,'owner','2026-04-03 21:37:04'),(2,1,1,'member','2026-04-03 21:37:04'),(3,1,2,'member','2026-04-03 21:37:04'),(4,1,3,'member','2026-04-03 21:37:04'),(5,2,2,'owner','2026-04-03 21:37:04'),(6,2,6,'member','2026-04-03 21:37:04'),(7,2,5,'member','2026-04-03 21:37:04'),(8,3,3,'owner','2026-04-03 21:37:04'),(9,3,1,'member','2026-04-03 21:37:04'),(10,3,4,'member','2026-04-03 21:37:04');
/*!40000 ALTER TABLE `group_memberships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_posts`
--

DROP TABLE IF EXISTS `group_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_posts` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `group_id` (`group_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `group_posts_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `support_groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `group_posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_posts`
--

LOCK TABLES `group_posts` WRITE;
/*!40000 ALTER TABLE `group_posts` DISABLE KEYS */;
INSERT INTO `group_posts` VALUES (1,1,6,'Just lost 5 lbs this month. Small steps, big wins!','2026-03-15 12:10:00'),(2,1,1,'Huge congrats Test! Keep it going.','2026-03-15 12:20:00'),(3,1,2,'Nice work! I finally hit 12k steps today too.','2026-03-15 13:05:00');
/*!40000 ALTER TABLE `group_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nutrition_logs`
--

DROP TABLE IF EXISTS `nutrition_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nutrition_logs` (
  `nutrition_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `log_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `meal_type` enum('breakfast','lunch','dinner','snack') NOT NULL,
  `food_item` varchar(255) NOT NULL,
  `calories` int NOT NULL,
  `protein_g` decimal(6,2) NOT NULL,
  `carbs_g` decimal(6,2) DEFAULT NULL,
  `fat_g` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`nutrition_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `nutrition_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nutrition_logs_chk_1` CHECK (((`calories` >= 0) and (`calories` < 10000))),
  CONSTRAINT `nutrition_logs_chk_2` CHECK (((`protein_g` >= 0) and (`protein_g` < 1000))),
  CONSTRAINT `nutrition_logs_chk_3` CHECK (((`carbs_g` >= 0) and (`carbs_g` < 1000))),
  CONSTRAINT `nutrition_logs_chk_4` CHECK (((`fat_g` >= 0) and (`fat_g` < 1000)))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nutrition_logs`
--

LOCK TABLES `nutrition_logs` WRITE;
/*!40000 ALTER TABLE `nutrition_logs` DISABLE KEYS */;
INSERT INTO `nutrition_logs` VALUES (1,1,'2026-03-14 12:15:00','breakfast','Greek yogurt with berries',320,24.00,35.00,8.00),(2,1,'2026-03-14 17:05:00','lunch','Chicken rice bowl',640,42.00,68.00,18.00),(3,1,'2026-03-14 23:10:00','dinner','Salmon and vegetables',710,46.00,40.00,32.00),(4,2,'2026-03-14 16:20:00','lunch','Turkey wrap',520,31.00,49.00,17.00),(5,2,'2026-03-14 20:10:00','snack','Protein shake',210,30.00,9.00,4.00),(6,3,'2026-03-14 11:50:00','breakfast','Oatmeal with banana',410,14.00,72.00,7.00),(7,4,'2026-03-15 00:00:00','dinner','Steak and sweet potato',780,52.00,48.00,35.00),(8,5,'2026-03-14 22:40:00','dinner','Tofu stir-fry',560,28.00,62.00,20.00),(9,6,'2026-03-16 16:00:00','lunch','Chicken bowl',580,42.00,55.00,18.00),(10,6,'2026-03-17 16:00:00','lunch','Salmon salad',520,38.00,28.00,24.00),(11,6,'2026-03-18 16:00:00','lunch','Turkey wrap',510,32.00,48.00,16.00),(12,6,'2026-03-19 16:00:00','lunch','Tofu bowl',540,30.00,62.00,18.00),(13,6,'2026-03-20 16:00:00','lunch','Greek yogurt plate',480,28.00,40.00,14.00),(14,6,'2026-03-21 16:00:00','lunch','Steak salad',620,45.00,22.00,35.00),(15,6,'2026-03-22 16:00:00','lunch','Lentil soup + bread',560,24.00,78.00,12.00),(16,6,'2026-03-23 16:00:00','lunch','Sushi combo',590,32.00,70.00,14.00),(17,6,'2026-03-24 16:00:00','lunch','Chicken Caesar',550,40.00,30.00,28.00),(18,6,'2026-03-25 16:00:00','lunch','Buddha bowl',530,22.00,68.00,16.00),(19,6,'2026-03-26 16:00:00','lunch','Tuna melt',540,35.00,42.00,22.00),(20,6,'2026-03-27 16:00:00','lunch','Burrito bowl',640,36.00,72.00,20.00),(21,6,'2026-03-28 16:00:00','lunch','Pho',480,28.00,58.00,12.00),(22,6,'2026-03-29 16:00:00','lunch','Mediterranean plate',560,34.00,45.00,22.00);
/*!40000 ALTER TABLE `nutrition_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `progress_snapshots`
--

DROP TABLE IF EXISTS `progress_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `progress_snapshots` (
  `snapshot_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `snapshot_date` date NOT NULL,
  `avg_weight_lbs_7d` decimal(5,2) NOT NULL,
  `total_workouts_7d` int NOT NULL,
  `avg_steps_7d` decimal(8,2) DEFAULT NULL,
  `avg_sleep_hours_7d` decimal(4,2) DEFAULT NULL,
  `avg_protein_g_7d` decimal(6,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`snapshot_id`),
  UNIQUE KEY `unique_snapshot_per_day` (`user_id`,`snapshot_date`),
  CONSTRAINT `progress_snapshots_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progress_snapshots`
--

LOCK TABLES `progress_snapshots` WRITE;
/*!40000 ALTER TABLE `progress_snapshots` DISABLE KEYS */;
INSERT INTO `progress_snapshots` VALUES (1,1,'2026-03-15',182.20,4,9900.00,7.70,132.50,'2026-04-03 21:37:04'),(2,2,'2026-03-15',140.00,5,12420.00,6.80,118.00,'2026-04-03 21:37:04'),(3,3,'2026-03-15',168.70,3,8100.00,8.10,102.40,'2026-04-03 21:37:04'),(4,4,'2026-03-15',175.10,2,14100.00,6.40,125.70,'2026-04-03 21:37:04'),(5,5,'2026-03-15',128.50,3,9300.00,7.90,97.30,'2026-04-03 21:37:04'),(6,6,'2026-03-27',171.35,18,10120.00,7.45,36.50,'2026-04-03 21:37:04'),(7,6,'2026-03-29',171.05,22,10380.00,7.42,38.20,'2026-04-03 21:37:04');
/*!40000 ALTER TABLE `progress_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_groups`
--

DROP TABLE IF EXISTS `support_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_groups` (
  `group_id` int NOT NULL AUTO_INCREMENT,
  `group_name` varchar(255) NOT NULL,
  `description` text,
  `created_by_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `group_name` (`group_name`),
  KEY `created_by_user_id` (`created_by_user_id`),
  CONSTRAINT `support_groups_ibfk_1` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_groups`
--

LOCK TABLES `support_groups` WRITE;
/*!40000 ALTER TABLE `support_groups` DISABLE KEYS */;
INSERT INTO `support_groups` VALUES (1,'Progress Crew','Share wins and stay accountable week to week.',6,'2026-04-03 21:37:04'),(2,'Family Wellness','Home workouts and meal ideas for the household.',2,'2026-04-03 21:37:04'),(3,'Morning Accountability','Early risers checking in before the day starts.',3,'2026-04-03 21:37:04');
/*!40000 ALTER TABLE `support_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_achievements`
--

DROP TABLE IF EXISTS `user_achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievements` (
  `user_achievement_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `achievement_def_id` int NOT NULL,
  `achieved_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_achievement_id`),
  UNIQUE KEY `unique_user_achievement` (`user_id`,`achievement_def_id`),
  KEY `achievement_def_id` (`achievement_def_id`),
  CONSTRAINT `user_achievements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_achievements_ibfk_2` FOREIGN KEY (`achievement_def_id`) REFERENCES `achievement_definitions` (`achievement_def_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_achievements`
--

LOCK TABLES `user_achievements` WRITE;
/*!40000 ALTER TABLE `user_achievements` DISABLE KEYS */;
INSERT INTO `user_achievements` VALUES (1,1,1,'2026-03-15 13:00:00'),(2,2,2,'2026-03-15 01:00:00'),(3,3,3,'2026-03-14 00:30:00'),(4,3,4,'2026-03-14 00:30:00'),(5,5,4,'2026-03-15 02:15:00'),(6,6,1,'2026-03-29 12:00:00'),(7,6,2,'2026-03-29 12:01:00'),(8,6,3,'2026-03-29 12:02:00'),(9,6,4,'2026-03-29 12:03:00');
/*!40000 ALTER TABLE `user_achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `date_of_birth` date NOT NULL,
  `gender` enum('male','female','other') NOT NULL,
  `height_inches` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `users_chk_1` CHECK (((`height_inches` > 0) and (`height_inches` < 120)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'alex_fit','alex.fit@example.com','hash_alex','Alex','Turner','1998-04-12','male',71,'2026-04-03 21:37:04'),(2,'mia_runner','mia.runner@example.com','hash_mia','Mia','Lopez','2001-09-03','female',65,'2026-04-03 21:37:04'),(3,'sam_strength','sam.strength@example.com','hash_sam','Sam','Patel','1995-01-28','other',70,'2026-04-03 21:37:04'),(4,'jordan_cycle','jordan.cycle@example.com','hash_jordan','Jordan','Kim','1992-06-17','male',68,'2026-04-03 21:37:04'),(5,'ava_balance','ava.balance@example.com','hash_ava','Ava','Nguyen','1999-11-22','female',64,'2026-04-03 21:37:04'),(6,'testuser','testuser@example.com','testuser','Test','User','1998-07-14','male',70,'2026-04-03 21:37:04');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_users_before_insert_dob` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `tr_users_before_update_dob` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `workout_logs`
--

DROP TABLE IF EXISTS `workout_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workout_logs` (
  `workout_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `exercise_id` int NOT NULL,
  `log_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `duration_minutes` int NOT NULL,
  `calories_burned` decimal(6,2) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`workout_id`),
  KEY `user_id` (`user_id`),
  KEY `exercise_id` (`exercise_id`),
  CONSTRAINT `workout_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `workout_logs_ibfk_2` FOREIGN KEY (`exercise_id`) REFERENCES `exercise_types` (`exercise_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `workout_logs_chk_1` CHECK ((`duration_minutes` > 0)),
  CONSTRAINT `workout_logs_chk_2` CHECK ((`calories_burned` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workout_logs`
--

LOCK TABLES `workout_logs` WRITE;
/*!40000 ALTER TABLE `workout_logs` DISABLE KEYS */;
INSERT INTO `workout_logs` VALUES (1,1,4,'2026-03-14 10:30:00',45,525.00,'Steady pace run'),(2,1,1,'2026-03-15 22:00:00',20,140.00,'Bodyweight circuit'),(3,2,5,'2026-03-14 11:00:00',60,600.00,'Outdoor cycling'),(4,3,6,'2026-03-14 23:00:00',50,216.70,'Recovery yoga session'),(5,4,2,'2026-03-14 21:15:00',25,208.30,'Pull-up progression'),(6,5,3,'2026-03-14 20:45:00',35,262.50,'Lower body focus'),(7,6,6,'2026-03-05 12:00:00',40,173.30,'Yoga flow'),(8,6,6,'2026-03-06 12:10:00',40,173.30,'Yoga flow'),(9,6,6,'2026-03-07 23:00:00',45,195.00,'Yin yoga'),(10,6,6,'2026-03-08 11:05:00',35,151.70,'Sun salutations'),(11,6,6,'2026-03-09 11:15:00',40,173.30,'Yoga flow'),(12,6,6,'2026-03-10 21:30:00',50,216.70,'Power yoga'),(13,6,6,'2026-03-11 11:00:00',40,173.30,'Morning yoga'),(14,6,6,'2026-03-12 11:20:00',45,195.00,'Vinyasa'),(15,6,6,'2026-03-13 12:00:00',30,130.00,'Stretch'),(16,6,6,'2026-03-14 13:00:00',40,173.30,'Yoga flow'),(17,6,6,'2026-03-15 11:30:00',45,195.00,'Yoga'),(18,6,6,'2026-03-16 22:15:00',40,173.30,'Evening yoga'),(19,6,6,'2026-03-17 11:00:00',35,151.70,'Yoga'),(20,6,6,'2026-03-18 23:00:00',50,216.70,'Hot yoga'),(21,6,6,'2026-03-19 11:10:00',40,173.30,'Yoga flow'),(22,6,6,'2026-03-20 11:00:00',45,195.00,'Yoga'),(23,6,6,'2026-03-21 14:00:00',40,173.30,'Weekend yoga'),(24,6,6,'2026-03-22 11:15:00',40,173.30,'Yoga flow'),(25,6,6,'2026-03-23 21:45:00',35,151.70,'Yoga'),(26,6,6,'2026-03-24 11:00:00',45,195.00,'Yoga'),(27,6,6,'2026-03-25 22:00:00',40,173.30,'Recovery yoga'),(28,6,6,'2026-03-26 11:30:00',40,173.30,'Yoga flow'),(29,6,6,'2026-03-27 11:00:00',45,195.00,'Yoga'),(30,6,6,'2026-03-28 12:30:00',40,173.30,'Yoga'),(31,6,6,'2026-03-29 11:00:00',45,195.00,'Yoga');
/*!40000 ALTER TABLE `workout_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'fitness_db'
--

--
-- Dumping routines for database 'fitness_db'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_est_calories_burned` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_est_calories_burned`(
    p_calories_per_hour DECIMAL(5,2),
    p_duration_minutes INT
) RETURNS decimal(10,2)
    NO SQL
    DETERMINISTIC
BEGIN
    IF p_duration_minutes IS NULL OR p_duration_minutes < 1 THEN
        RETURN NULL;
    END IF;
    IF p_calories_per_hour IS NULL OR p_calories_per_hour <= 0 THEN
        RETURN NULL;
    END IF;
    RETURN ROUND((p_calories_per_hour / 60.0) * p_duration_minutes, 2);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_group_member` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_group_member`(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_role ENUM('owner', 'member')
)
BEGIN
    INSERT INTO group_memberships (group_id, user_id, role)
    VALUES (p_group_id, p_user_id, p_role);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_goal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_goal`(
    IN p_user_id INT,
    IN p_goal_type ENUM('weight_loss', 'weight_gain', 'muscle_gain', 'endurance'),
    IN p_target_value DECIMAL(6,2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    INSERT INTO goals (user_id, goal_type, target_value, start_date, end_date, status)
    VALUES (p_user_id, p_goal_type, p_target_value, p_start_date, p_end_date, p_status);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_group_post` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_group_post`(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    INSERT INTO group_posts (group_id, user_id, content)
    SELECT p_group_id, p_user_id, p_content
    FROM group_memberships gm
    WHERE gm.group_id = p_group_id
      AND gm.user_id = p_user_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_support_group` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_support_group`(
    IN p_group_name VARCHAR(255),
    IN p_description TEXT,
    IN p_created_by_user_id INT
)
BEGIN
    DECLARE v_group_id INT;

    INSERT INTO support_groups (group_name, description, created_by_user_id)
    VALUES (p_group_name, p_description, p_created_by_user_id);

    SET v_group_id = LAST_INSERT_ID();

    INSERT INTO group_memberships (group_id, user_id, role)
    VALUES (v_group_id, p_created_by_user_id, 'owner');

    SELECT v_group_id AS group_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_daily_metric` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_daily_metric`(IN p_metric_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM daily_metrics
    WHERE metric_id = p_metric_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_goal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_goal`(IN p_goal_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM goals
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_nutrition_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_nutrition_entry`(IN p_nutrition_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM nutrition_logs
    WHERE nutrition_id = p_nutrition_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_workout_log` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_workout_log`(IN p_workout_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM workout_logs
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_group_members` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_group_members`(IN p_group_id INT)
BEGIN
    SELECT u.user_id, u.username, gm.role
    FROM group_memberships gm
    JOIN users u ON gm.user_id = u.user_id
    WHERE gm.group_id = p_group_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_group_posts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_group_posts`(IN p_group_id INT, IN p_limit INT)
BEGIN
    SELECT
        gp.post_id,
        gp.group_id,
        gp.user_id,
        u.username,
        gp.content,
        gp.created_at
    FROM group_posts gp
    JOIN users u ON u.user_id = gp.user_id
    WHERE gp.group_id = p_group_id
    ORDER BY gp.created_at DESC, gp.post_id DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_achievements` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_achievements`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        ua.user_achievement_id,
        ua.user_id,
        ua.achievement_def_id,
        d.code,
        d.title,
        d.description,
        ua.achieved_at
    FROM user_achievements ua
    JOIN achievement_definitions d ON d.achievement_def_id = ua.achievement_def_id
    WHERE ua.user_id = p_user_id
    ORDER BY ua.achieved_at DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_auth_by_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_auth_by_username`(IN p_username VARCHAR(255))
BEGIN
    SELECT user_id, username, email, password
    FROM users
    WHERE username = p_username;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_by_id`(IN p_user_id INT)
BEGIN
    SELECT user_id, username, email, first_name, last_name, gender, height_inches, date_of_birth
    FROM users
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_daily_checkins` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_daily_checkins`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        checkin_id,
        user_id,
        record_date,
        eating_quality,
        energy_level,
        adherence_to_plan,
        notes
    FROM daily_checkins
    WHERE user_id = p_user_id
    ORDER BY record_date DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_daily_metrics` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_daily_metrics`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        metric_id,
        user_id,
        record_date,
        weight_lbs,
        steps,
        sleep_hours,
        water_intake_cups
    FROM daily_metrics
    WHERE user_id = p_user_id
    ORDER BY record_date DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_goals` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_goals`(IN p_user_id INT)
BEGIN
    SELECT
        goal_id,
        user_id,
        goal_type,
        target_value,
        start_date,
        end_date,
        status
    FROM goals
    WHERE user_id = p_user_id
    ORDER BY start_date DESC, goal_id DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_groups` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_groups`(IN p_user_id INT)
BEGIN
    SELECT sg.group_id, sg.group_name, gm.role
    FROM group_memberships gm
    JOIN support_groups sg ON gm.group_id = sg.group_id
    WHERE gm.user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_nutrition_logs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_nutrition_logs`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        nutrition_id,
        user_id,
        log_date,
        meal_type,
        food_item,
        calories,
        protein_g,
        carbs_g,
        fat_g
    FROM nutrition_logs
    WHERE user_id = p_user_id
    ORDER BY log_date DESC, nutrition_id DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_progress_snapshots` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_progress_snapshots`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        snapshot_id,
        user_id,
        snapshot_date,
        avg_weight_lbs_7d,
        total_workouts_7d,
        avg_steps_7d,
        avg_sleep_hours_7d,
        avg_protein_g_7d,
        created_at
    FROM progress_snapshots
    WHERE user_id = p_user_id
    ORDER BY snapshot_date DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_workout_logs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_workout_logs`(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        w.workout_id,
        w.user_id,
        w.exercise_id,
        w.log_date,
        w.duration_minutes,
        w.calories_burned,
        w.notes,
        e.name AS exercise_name
    FROM workout_logs w
    JOIN exercise_types e ON e.exercise_id = w.exercise_id
    WHERE w.user_id = p_user_id
    ORDER BY w.log_date DESC, w.workout_id DESC
    LIMIT p_limit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_grant_user_achievement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grant_user_achievement`(
    IN p_user_id INT,
    IN p_achievement_def_id INT,
    IN p_achieved_at TIMESTAMP
)
BEGIN
    INSERT IGNORE INTO user_achievements (user_id, achievement_def_id, achieved_at)
    VALUES (p_user_id, p_achievement_def_id, p_achieved_at);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_grant_user_achievement_by_code` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_grant_user_achievement_by_code`(
    IN p_user_id INT,
    IN p_code VARCHAR(64),
    IN p_achieved_at TIMESTAMP
)
BEGIN
    DECLARE v_def_id INT;

    SELECT achievement_def_id INTO v_def_id
    FROM achievement_definitions
    WHERE code = p_code
    LIMIT 1;

    IF v_def_id IS NOT NULL THEN
        INSERT IGNORE INTO user_achievements (user_id, achievement_def_id, achieved_at)
        VALUES (p_user_id, v_def_id, p_achieved_at);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_list_achievement_definitions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_list_achievement_definitions`()
BEGIN
    SELECT achievement_def_id, code, title, description
    FROM achievement_definitions
    ORDER BY achievement_def_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_list_exercise_types` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_list_exercise_types`()
BEGIN
    SELECT exercise_id, name, category, muscle_group, calories_per_hour
    FROM exercise_types
    ORDER BY name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_log_nutrition_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_log_nutrition_entry`(
    IN p_user_id INT,
    IN p_log_date TIMESTAMP,
    IN p_meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    IN p_food_item VARCHAR(255),
    IN p_calories INT,
    IN p_protein_g DECIMAL(6,2),
    IN p_carbs_g DECIMAL(6,2),
    IN p_fat_g DECIMAL(6,2)
)
BEGIN
    INSERT INTO nutrition_logs (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
    VALUES (p_user_id, p_log_date, p_meal_type, p_food_item, p_calories, p_protein_g, p_carbs_g, p_fat_g);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_log_workout` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_log_workout`(
    IN p_user_id INT,
    IN p_exercise_id INT,
    IN p_log_date TIMESTAMP,
    IN p_duration_minutes INT,
    IN p_calories_burned DECIMAL(6,2),
    IN p_notes TEXT
)
BEGIN
    DECLARE v_cal DECIMAL(6,2);
    DECLARE v_cph DECIMAL(5,2);

    IF p_calories_burned IS NOT NULL THEN
        SET v_cal = p_calories_burned;
    ELSE
        SELECT calories_per_hour INTO v_cph
        FROM exercise_types
        WHERE exercise_id = p_exercise_id
        LIMIT 1;
        SET v_cal = fn_est_calories_burned(v_cph, p_duration_minutes);
    END IF;

    INSERT INTO workout_logs (user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
    VALUES (p_user_id, p_exercise_id, p_log_date, p_duration_minutes, v_cal, p_notes);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_register_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_register_user`(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_date_of_birth DATE,
    IN p_gender ENUM('male', 'female', 'other'),
    IN p_height_inches INT
)
BEGIN
    INSERT INTO users (
        username, email, password, first_name, last_name, date_of_birth, gender, height_inches
    )
    VALUES (
        p_username, p_email, p_password, p_first_name, p_last_name, p_date_of_birth, p_gender, p_height_inches
    );
    SELECT LAST_INSERT_ID() AS user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remove_group_member` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_remove_group_member`(IN p_group_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM group_memberships
    WHERE group_id = p_group_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_goal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_goal`(
    IN p_goal_id INT,
    IN p_user_id INT,
    IN p_goal_type ENUM('weight_loss', 'weight_gain', 'muscle_gain', 'endurance'),
    IN p_target_value DECIMAL(6,2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    UPDATE goals
    SET
        goal_type = p_goal_type,
        target_value = p_target_value,
        start_date = p_start_date,
        end_date = p_end_date,
        status = p_status
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_goal_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_goal_status`(
    IN p_goal_id INT,
    IN p_user_id INT,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    UPDATE goals
    SET status = p_status
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_nutrition_entry` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_nutrition_entry`(
    IN p_nutrition_id INT,
    IN p_user_id INT,
    IN p_log_date TIMESTAMP,
    IN p_meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    IN p_food_item VARCHAR(255),
    IN p_calories INT,
    IN p_protein_g DECIMAL(6,2),
    IN p_carbs_g DECIMAL(6,2),
    IN p_fat_g DECIMAL(6,2)
)
BEGIN
    UPDATE nutrition_logs
    SET
        log_date = p_log_date,
        meal_type = p_meal_type,
        food_item = p_food_item,
        calories = p_calories,
        protein_g = p_protein_g,
        carbs_g = p_carbs_g,
        fat_g = p_fat_g
    WHERE nutrition_id = p_nutrition_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_password`(
    IN p_user_id INT,
    IN p_password VARCHAR(255)
)
BEGIN
    UPDATE users
    SET password = p_password
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_profile`(
    IN p_user_id INT,
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_gender ENUM('male', 'female', 'other'),
    IN p_height_inches INT,
    IN p_date_of_birth DATE
)
BEGIN
    UPDATE users
    SET
        first_name = p_first_name,
        last_name = p_last_name,
        email = p_email,
        gender = p_gender,
        height_inches = p_height_inches,
        date_of_birth = p_date_of_birth
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_workout_log` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_workout_log`(
    IN p_workout_id INT,
    IN p_user_id INT,
    IN p_exercise_id INT,
    IN p_log_date TIMESTAMP,
    IN p_duration_minutes INT,
    IN p_calories_burned DECIMAL(6,2),
    IN p_notes TEXT
)
BEGIN
    DECLARE v_cal DECIMAL(6,2);
    DECLARE v_cph DECIMAL(5,2);

    IF p_calories_burned IS NOT NULL THEN
        SET v_cal = p_calories_burned;
    ELSE
        SELECT calories_per_hour INTO v_cph
        FROM exercise_types
        WHERE exercise_id = p_exercise_id
        LIMIT 1;
        SET v_cal = fn_est_calories_burned(v_cph, p_duration_minutes);
    END IF;

    UPDATE workout_logs
    SET
        exercise_id = p_exercise_id,
        log_date = p_log_date,
        duration_minutes = p_duration_minutes,
        calories_burned = v_cal,
        notes = p_notes
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_upsert_daily_checkin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_upsert_daily_checkin`(
    IN p_user_id INT,
    IN p_record_date DATE,
    IN p_eating_quality ENUM('poor', 'average', 'good'),
    IN p_energy_level ENUM('low', 'medium', 'high'),
    IN p_adherence_to_plan ENUM('poor', 'average', 'good'),
    IN p_notes TEXT
)
BEGIN
    INSERT INTO daily_checkins (user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes)
    VALUES (p_user_id, p_record_date, p_eating_quality, p_energy_level, p_adherence_to_plan, p_notes) AS new
    ON DUPLICATE KEY UPDATE
        eating_quality = new.eating_quality,
        energy_level = new.energy_level,
        adherence_to_plan = new.adherence_to_plan,
        notes = new.notes;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_upsert_daily_metric` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_upsert_daily_metric`(
    IN p_user_id INT,
    IN p_record_date DATE,
    IN p_weight_lbs DECIMAL(5,2),
    IN p_steps INT,
    IN p_sleep_hours DECIMAL(5,2),
    IN p_water_intake_cups DECIMAL(5,2)
)
BEGIN
    INSERT INTO daily_metrics (user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
    VALUES (p_user_id, p_record_date, p_weight_lbs, p_steps, p_sleep_hours, p_water_intake_cups) AS new
    ON DUPLICATE KEY UPDATE
        weight_lbs = new.weight_lbs,
        steps = new.steps,
        sleep_hours = new.sleep_hours,
        water_intake_cups = new.water_intake_cups;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_upsert_exercise_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_upsert_exercise_type`(
    IN p_name VARCHAR(255),
    IN p_category VARCHAR(255),
    IN p_muscle_group VARCHAR(255),
    IN p_calories_per_hour DECIMAL(5,2)
)
BEGIN
    INSERT INTO exercise_types (name, category, muscle_group, calories_per_hour)
    VALUES (p_name, p_category, p_muscle_group, p_calories_per_hour) AS new
    ON DUPLICATE KEY UPDATE
        category = new.category,
        muscle_group = new.muscle_group,
        calories_per_hour = new.calories_per_hour;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-03 17:39:19
