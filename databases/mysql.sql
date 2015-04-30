-- phpMyAdmin SQL Dump
-- version 4.0.10.9
-- http://www.phpmyadmin.net
--
-- Host: 127.12.211.2:3306
-- Generation Time: Apr 30, 2015 at 01:01 PM
-- Server version: 5.5.41
-- PHP Version: 5.3.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `happycowgame`
--

-- --------------------------------------------------------

--
-- Table structure for table `actions`
--

CREATE TABLE IF NOT EXISTS `actions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `round_id` int(10) DEFAULT NULL,
  `phase` int(10) DEFAULT NULL,
  `game_user_id` int(10) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=400 ;

-- --------------------------------------------------------

--
-- Table structure for table `carddecks`
--

CREATE TABLE IF NOT EXISTS `carddecks` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `user_id` int(10) NOT NULL,
  `rating` int(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `carddecks_cards`
--

CREATE TABLE IF NOT EXISTS `carddecks_cards` (
  `carddeck_id` int(10) NOT NULL,
  `card_id` int(10) NOT NULL,
  KEY `carddeck_id` (`carddeck_id`,`card_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `cards`
--

CREATE TABLE IF NOT EXISTS `cards` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `rating` int(10) NOT NULL,
  `user_id` int(11) NOT NULL,
  `points` int(10) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=20 ;

-- --------------------------------------------------------

--
-- Table structure for table `cows`
--

CREATE TABLE IF NOT EXISTS `cows` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ph_marker` decimal(10,0) NOT NULL DEFAULT '7',
  `body_condition` int(10) NOT NULL DEFAULT '0',
  `welfare` int(10) NOT NULL DEFAULT '0',
  `oligos_marker` int(10) NOT NULL DEFAULT '0',
  `muck_marker` int(10) NOT NULL DEFAULT '0',
  `disease_id` int(10) DEFAULT NULL,
  `weather_id` int(10) DEFAULT NULL,
  `pregnancy_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=57 ;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE IF NOT EXISTS `events` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `rating` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `uri` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

--
-- Table structure for table `game_cards`
--

CREATE TABLE IF NOT EXISTS `game_cards` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `game_id` int(10) NOT NULL,
  `card_id` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1080 ;

-- --------------------------------------------------------

--
-- Table structure for table `game_user_cards`
--

CREATE TABLE IF NOT EXISTS `game_user_cards` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `game_user_id` int(10) NOT NULL,
  `game_card_id` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=920 ;

-- --------------------------------------------------------

--
-- Table structure for table `game_users`
--

CREATE TABLE IF NOT EXISTS `game_users` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `score` int(10) NOT NULL,
  `colour` varchar(255) NOT NULL,
  `user_id` int(10) NOT NULL,
  `game_id` int(10) NOT NULL,
  `network` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=124 ;

-- --------------------------------------------------------

--
-- Table structure for table `games`
--

CREATE TABLE IF NOT EXISTS `games` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `stage` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `round_id` int(10) DEFAULT NULL,
  `cow_id` int(10) DEFAULT NULL,
  `rounds_min` int(3) DEFAULT NULL,
  `rounds_max` int(3) DEFAULT NULL,
  `carddeck_id` int(10) DEFAULT NULL,
  `creater_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=74 ;

-- --------------------------------------------------------

--
-- Table structure for table `ingredient_cats`
--

CREATE TABLE IF NOT EXISTS `ingredient_cats` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `game_id` int(10) NOT NULL,
  `milk_score` int(10) NOT NULL DEFAULT '1',
  `meat_score` int(10) NOT NULL DEFAULT '1',
  `muck_score` int(10) NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=276 ;

-- --------------------------------------------------------

--
-- Table structure for table `ingredients`
--

CREATE TABLE IF NOT EXISTS `ingredients` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ration_id` int(10) NOT NULL,
  `ingredient_cat_id` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=397 ;

-- --------------------------------------------------------

--
-- Table structure for table `motiles`
--

CREATE TABLE IF NOT EXISTS `motiles` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `position_id` int(10) DEFAULT NULL,
  `game_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=107 ;

-- --------------------------------------------------------

--
-- Table structure for table `moves`
--

CREATE TABLE IF NOT EXISTS `moves` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `game_user_id` int(10) NOT NULL,
  `round_id` int(10) NOT NULL,
  `ration_id` int(10) DEFAULT NULL,
  `dice1` int(1) DEFAULT NULL,
  `dice2` int(1) DEFAULT NULL,
  `dice3` int(1) DEFAULT NULL,
  `selected_die` int(1) DEFAULT NULL,
  `movements_left` int(10) DEFAULT NULL,
  `movements_made` int(10) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1224 ;

-- --------------------------------------------------------

--
-- Table structure for table `next_positions`
--

CREATE TABLE IF NOT EXISTS `next_positions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `position_from_id` int(10) NOT NULL,
  `position_to_id` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=222 ;

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE IF NOT EXISTS `positions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `area_id` int(10) NOT NULL,
  `order` int(10) NOT NULL,
  `centre_x` int(10) NOT NULL,
  `centre_y` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=96 ;

-- --------------------------------------------------------

--
-- Table structure for table `rations`
--

CREATE TABLE IF NOT EXISTS `rations` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `position_id` int(10) NOT NULL,
  `game_user_id` int(10) NOT NULL,
  `round_created_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=151 ;

-- --------------------------------------------------------

--
-- Table structure for table `round_records`
--

CREATE TABLE IF NOT EXISTS `round_records` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `round_id` int(10) NOT NULL,
  `game_user_id` int(10) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `value` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=586 ;

-- --------------------------------------------------------

--
-- Table structure for table `rounds`
--

CREATE TABLE IF NOT EXISTS `rounds` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `event_id` int(10) NOT NULL,
  `number` int(3) NOT NULL,
  `current_phase` int(1) NOT NULL,
  `game_user_id` int(10) NOT NULL,
  `game_id` int(10) NOT NULL,
  `starting_user_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=701 ;

-- --------------------------------------------------------

--
-- Table structure for table `schema_migrations`
--

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `colour` varchar(255) NOT NULL,
  `experience` int(10) NOT NULL DEFAULT '0',
  `password` varchar(255) NOT NULL,
  `key` varchar(255) DEFAULT NULL,
  `last_logged_in` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=18 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
