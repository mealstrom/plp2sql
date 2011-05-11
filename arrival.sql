SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

DROP TABLE IF EXISTS arrival;
CREATE TABLE IF NOT EXISTS arrival (
  `server` varchar(32) NOT NULL DEFAULT '',
  mailid varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `timestamp` varchar(20) DEFAULT NULL,
  messageid varchar(255) DEFAULT NULL,
  envelope_from varchar(255) DEFAULT NULL,
  message_from varchar(255) DEFAULT NULL,
  message_for varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  size bigint(20) DEFAULT NULL,
   `name` varchar(255) DEFAULT NULL,
  ip varchar(15) DEFAULT NULL,
  `port` int(5) DEFAULT NULL,
  protocol varchar(32) DEFAULT NULL,
  localuser varchar(128) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`server`,mailid),
  KEY message_id (messageid),
  KEY `timestamp` (`timestamp`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

