CREATE SCHEMA IF NOT EXISTS `chathello` DEFAULT CHARACTER SET utf8 ;
--
-- Table structure for table `chat`
--
USE chathello;

DROP TABLE IF EXISTS `message`;
DROP TABLE IF EXISTS `chatuser`;
DROP TABLE IF EXISTS `chat`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=big5;

--
-- Table structure for table `chatuser`
--

CREATE TABLE `chatuser` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `chat_id` int(11) NOT NULL,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_user_has_chat_chat1_idx` (`chat_id`),
  KEY `fk_user_has_chat_user_idx` (`user_id`),
  CONSTRAINT `fk_user_has_chat_chat1` FOREIGN KEY (`chat_id`) REFERENCES `chat` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for table `message`
--


CREATE TABLE `message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chatuser_id` int(11) NOT NULL,
  `message` longtext,
  `creationdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_message_chatuser1_idx` (`chatuser_id`),
  CONSTRAINT `fk_message_chatuser1` FOREIGN KEY (`chatuser_id`) REFERENCES `chatuser` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--
-- Table structure for view `message_v`
--

CREATE OR REPLACE ALGORITHM = MERGE
    DEFINER = `root`@`localhost`
    SQL SECURITY DEFINER
VIEW `message_v` AS
    SELECT
        `c`.`id` AS `chat_id`,
        `c`.`name` AS `name`,
        `u`.`name` AS `user`,
        `m`.`message` AS `message`,
        `m`.`creationdate` AS `creationdate`
    FROM
        (((`chatuser` `cu`
        JOIN `chat` `c` ON ((`cu`.`chat_id` = `c`.`id`)))
        JOIN `users` `u` ON ((`cu`.`user_id` = `u`.`id`)))
        JOIN `message` `m` ON ((`cu`.`id` = `m`.`chatuser_id`)))
    ORDER BY `m`.`creationdate`;

--
-- Table structure for view `chatuser_v`
--

CREATE OR REPLACE ALGORITHM = MERGE
    DEFINER = `root`@`localhost`
    SQL SECURITY DEFINER
VIEW `chatuser_v` AS
    SELECT DISTINCT
        `c`.`id` AS `chat_id`,
        `c`.`name` AS `name`,
        `cu`.`user_id` AS `user_id`
    FROM
        (`chatuser` `cu`
        JOIN `chat` `c` ON ((`cu`.`chat_id` = `c`.`id`)));