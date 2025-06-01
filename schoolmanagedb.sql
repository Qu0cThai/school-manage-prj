DROP TABLE IF EXISTS `classes`;
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
  CONSTRAINT `classes_chk_2` CHECK ((`day_of_week` in ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'))),
  CONSTRAINT `valid_time` CHECK ((`time_end` > `time_begin`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `classes` WRITE;
INSERT INTO `classes` VALUES 
('C001','Math','104','T001','08:00:00','20:00:00','2024-2025',1,'Monday'),
('C002','English','101','T002','08:00:00','20:00:00','2024-2025',1,'Tuesday'),
('C003','Physics','103','T005','08:00:00','20:00:00','2026-2027',2,'Monday'),
('C004','Chemistry','104','T006','08:00:00','20:00:00','2024-2025',1,'Thursday');
UNLOCK TABLES;

DROP TABLE IF EXISTS `notices`;
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `notices` WRITE;
INSERT INTO `notices` VALUES 
(1,'School Holiday','School will be closed on December 25, 2025, for Christmas.','2025-12-01','A001','2025-05-28 12:49:08'),
(2,'Parent-Teacher Meeting','Meeting scheduled for January 15, 2026, at 10 AM.','2026-01-01','A001','2025-05-28 12:49:08'),
(3,'Science Fair','Annual Science Fair on February 10, 2026.','2026-02-01','A001','2025-05-28 12:49:08'),
(4,'Job Fair','Annual Job Fair on February 11, 2026.','2026-02-02','A001','2025-05-28 12:49:08'),
(6,'Job Fair?','Job Fair?','2027-02-01','A003','2025-05-31 02:24:49'),
(7,'Job Fair??','Job Fair??','2028-02-20','A004','2025-05-31 02:25:27');
UNLOCK TABLES;

DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `r_id` int NOT NULL,
  `r_name` varchar(50) NOT NULL,
  PRIMARY KEY (`r_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `roles` WRITE;
INSERT INTO `roles` VALUES (1,'Admin'),(2,'Teacher'),(3,'Student');
UNLOCK TABLES;

DROP TABLE IF EXISTS `student_classes`;
CREATE TABLE `student_classes` (
  `s_id` varchar(10) NOT NULL,
  `class_id` varchar(10) NOT NULL,
  PRIMARY KEY (`s_id`,`class_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `student_classes_ibfk_1` FOREIGN KEY (`s_id`) REFERENCES `students` (`s_id`),
  CONSTRAINT `student_classes_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `student_classes` WRITE;
INSERT INTO `student_classes` VALUES 
('S003','C001'),
('S005','C001'),
('S005','C002'),
('S005','C003'),
('S005','C004');
UNLOCK TABLES;

DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `s_id` varchar(10) NOT NULL,
  `s_name` varchar(100) NOT NULL,
  `roll_no` varchar(20) DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `age` int DEFAULT NULL,
  `f_name` varchar(100) DEFAULT NULL,
  `m_name` varchar(100) DEFAULT NULL,
  `mobile_no` varchar(20) DEFAULT NULL,
  `present_address` text,
  `permanent_address` text,
  PRIMARY KEY (`s_id`),
  CONSTRAINT `fk_students_u_id` FOREIGN KEY (`s_id`) REFERENCES `users` (`u_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `students` WRITE;
INSERT INTO `students` VALUES 
('S001','John Doe','001','Male','2005-03-15',20,'James Doe','Mary Doe','123-456-7890','123 Main St, City','123 Main St, Cit'),
('S002','Jane Roe','002','Female','2004-07-22',21,'Richard Roe','Susan Roe','987-654-3210','456 Elm St, Town','456 Elm St, Town'),
('S003','a','S009','Male','2003-07-11',25,'Oz','Izu','0948029974','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
('S004','b','S004','Male','1111-01-11',20,'asd','adasdae','0948029974','asdasdaasd','asdasdas'),
('S005','thieng','S0010','Male','5050-05-01',50,'Oz','asd','0948029976','asdads','asdsad');
UNLOCK TABLES;

DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers` (
  `t_id` varchar(10) NOT NULL,
  `t_name` varchar(100) NOT NULL,
  `t_email` varchar(100) NOT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text,
  `sub_name` varchar(50) DEFAULT NULL,
  `join_date` date DEFAULT NULL,
  PRIMARY KEY (`t_id`),
  CONSTRAINT `fk_teachers_u_id` FOREIGN KEY (`t_id`) REFERENCES `users` (`u_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `teachers` WRITE;
INSERT INTO `teachers` VALUES 
('T001','Alice Smith','alice.smith@example.com','Female','555-123-4567','456 Oak Ave, Town','Mathematics','2019-09-01'),
('T002','Bob Johnson','bob.johnson@example.com','Male','555-987-6543','789 Pine Rd, Village','Science','2019-01-15'),
('T003','Carol White','carol.white@example.com','Female','555-456-7890','123 Elm St, City','English','2020-03-10'),
('T004','d','d@gmail.com','Female','0948029974','asddadada','dsadasdasdasdasd','1441-11-22'),
('T005','f','f@gmail.com','Male','0948029979','yougay','Physics','2020-02-10'),
('T006','s','s@gmail.com','Male','0948029974','s','dsadasdasdasdasds','2002-02-01');
UNLOCK TABLES;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `u_id` varchar(10) NOT NULL,
  `u_name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `r_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
 
