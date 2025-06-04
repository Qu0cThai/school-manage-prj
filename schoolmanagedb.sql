-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: schoolmanagedb
-- ------------------------------------------------------
-- Server version	8.0.41

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
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `classes` (
  `class_id` varchar(10) NOT NULL,
  `subject` varchar(50) NOT NULL,
  `room` varchar(20) NOT NULL,
  `t_id` varchar(10) NOT NULL,
  `time_begin` time NOT NULL,
  `time_end` time NOT NULL,
  `academic_session` varchar(10) NOT NULL,
  `semester` int NOT NULL,
  `day_of_week` varchar(10) NOT NULL,
  PRIMARY KEY (`class_id`),
  KEY `t_id` (`t_id`),
  CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`t_id`) REFERENCES `teachers` (`t_id`),
  CONSTRAINT `classes_chk_1` CHECK ((`semester` in (1,2,3))),
  CONSTRAINT `classes_chk_2` CHECK ((`day_of_week` in (_utf8mb4'Monday',_utf8mb4'Tuesday',_utf8mb4'Wednesday',_utf8mb4'Thursday',_utf8mb4'Friday',_utf8mb4'Saturday',_utf8mb4'Sunday'))),
  CONSTRAINT `valid_time` CHECK ((`time_end` > `time_begin`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES ('C001','Math','102','T001','08:00:00','09:00:00','2024-2025',1,'Monday'),('C002','Physics','105','T005','08:00:00','21:00:00','2024-2025',1,'Monday');
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notices`
--

DROP TABLE IF EXISTS `notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notices` (
  `n_id` int NOT NULL AUTO_INCREMENT,
  `n_title` varchar(255) NOT NULL,
  `n_description` text,
  `publish_date` date NOT NULL,
  `created_by` varchar(10) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`n_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `notices_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`u_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notices`
--

LOCK TABLES `notices` WRITE;
/*!40000 ALTER TABLE `notices` DISABLE KEYS */;
INSERT INTO `notices` VALUES (1,'School Holiday','School will be closed on December 25, 2025, for Christmas.','2025-12-01','A001','2025-06-04 03:27:00'),(2,'Parent-Teacher Meeting','Meeting scheduled for January 15, 2026, at 10 AM.','2026-01-01','A001','2025-06-04 03:27:00'),(3,'Science Fair','Annual Science Fair on February 10, 2026.','2026-02-01','A001','2025-06-04 03:27:00'),(4,'Job Fair','Annual Job Fair on February 11, 2026.','2026-02-02','A001','2025-06-04 03:27:00'),(5,'Job Fair?z','Job Fair?z','2061-10-20','A002','2025-06-04 03:27:54');
/*!40000 ALTER TABLE `notices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `r_id` int NOT NULL,
  `r_name` varchar(50) NOT NULL,
  PRIMARY KEY (`r_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Admin'),(2,'Teacher'),(3,'Student');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_classes`
--

DROP TABLE IF EXISTS `student_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_classes` (
  `s_id` varchar(10) NOT NULL,
  `class_id` varchar(10) NOT NULL,
  PRIMARY KEY (`s_id`,`class_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `student_classes_ibfk_1` FOREIGN KEY (`s_id`) REFERENCES `students` (`s_id`),
  CONSTRAINT `student_classes_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_classes`
--

LOCK TABLES `student_classes` WRITE;
/*!40000 ALTER TABLE `student_classes` DISABLE KEYS */;
INSERT INTO `student_classes` VALUES ('S001','C001'),('S002','C001'),('S003','C001');
/*!40000 ALTER TABLE `student_classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `s_id` varchar(10) NOT NULL,
  `s_name` varchar(100) NOT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `age` int DEFAULT NULL,
  `f_name` varchar(100) DEFAULT NULL,
  `m_name` varchar(100) DEFAULT NULL,
  `mobile_no` varchar(20) DEFAULT NULL,
  `present_address` text,
  `permanent_address` text,
  PRIMARY KEY (`s_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('S001','John Doe','Male','2005-03-15',20,'James Doe','Mary Doe','123-456-7890','123 Main St, City','123 Main St, City'),('S002','Jane Roe','Female','2004-07-22',21,'Richard Roe','Susan Roe','987-654-3210','456 Elm St, Town','456 Elm St, Town'),('S003','thieng','Male','2003-10-20',60,'a','b','0948029976','a','bb');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `t_id` varchar(10) NOT NULL,
  `t_name` varchar(100) NOT NULL,
  `t_email` varchar(100) NOT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text,
  `sub_name` varchar(50) DEFAULT NULL,
  `join_date` date DEFAULT NULL,
  PRIMARY KEY (`t_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES ('T001','Alice Smith','alice.smith@example.com','Female','555-123-4567','456 Oak Ave, Town','Mathematics','2018-09-01'),('T002','Bob Johnson','bob.johnson@example.com','Male','555-987-6543','789 Pine Rd, Village','Science','2019-01-15'),('T003','Carol White','carol.white@example.com','Female','555-456-7890','123 Elm St, City','English','2020-03-10'),('T004','f','f@gmail.com','Female','0948029977','fad','Math','2023-10-20'),('T005','s','s@gmail.com','Male','0948029977','adssas','Physics','1233-12-31');
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `u_id` varchar(10) NOT NULL,
  `u_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `r_id` int NOT NULL,
  `is_profile_complete` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`u_id`),
  UNIQUE KEY `u_name` (`u_name`),
  UNIQUE KEY `email` (`email`),
  KEY `r_id` (`r_id`),
  KEY `idx_users_u_name` (`u_name`),
  KEY `idx_users_email` (`email`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`r_id`) REFERENCES `roles` (`r_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('A001','admin','5d41402abc4b2a76b9719d911017c592','admin@example.com','555-000-0001',1,1,'2025-06-04 03:26:51'),('A002','user1','24c9e15e52afc47c225b757e7bee1f9d','user1@gmail.com','0948029974',1,0,'2025-06-04 03:27:39'),('S001','john','5d41402abc4b2a76b9719d911017c592','john.doe@example.com','123-456-7890',3,0,'2025-06-04 03:26:51'),('S002','jane','5d41402abc4b2a76b9719d911017c592','jane.roe@example.com','987-654-3210',3,1,'2025-06-04 03:26:51'),('S003','thieng','202cb962ac59075b964b07152d234b70','thieng@gmail.com','0948029976',3,1,'2025-06-04 03:28:46'),('T001','alice','5d41402abc4b2a76b9719d911017c592','alice.smith@example.com','555-123-4567',2,0,'2025-06-04 03:26:51'),('T002','bob','5d41402abc4b2a76b9719d911017c592','bob.johnson@example.com','555-987-6543',2,1,'2025-06-04 03:26:51'),('T003','carol','5d41402abc4b2a76b9719d911017c592','carol.white@example.com','555-456-7890',2,1,'2025-06-04 03:26:51'),('T004','f','202cb962ac59075b964b07152d234b70','f@gmail.com','0948029977',2,1,'2025-06-04 03:38:27'),('T005','s','202cb962ac59075b964b07152d234b70','s@gmail.com','0948029977',2,1,'2025-06-04 03:51:11');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-04 11:32:32
