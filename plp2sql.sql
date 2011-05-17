/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
DROP DATABASE `plp2sql`;
CREATE DATABASE `plp2sql` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `plp2sql`;

DROP TABLE IF EXISTS arrival;
CREATE TABLE IF NOT EXISTS arrival (
  server varchar(32) NOT NULL DEFAULT '',
  mailid varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  timestamp varchar(20) DEFAULT NULL,
  messageid varchar(255) DEFAULT NULL,
  envelope_from varchar(255) DEFAULT NULL,
  message_from varchar(255) DEFAULT NULL,
  message_for varchar(255) DEFAULT NULL,
  subject varchar(255) DEFAULT NULL,
  size bigint(20) DEFAULT NULL,
  hostname varchar(255) DEFAULT NULL,
  hostip varchar(15) DEFAULT NULL,
  hostport int(5) DEFAULT NULL,
  protocol varchar(32) DEFAULT NULL,
  localuser varchar(128) DEFAULT NULL,
  PRIMARY KEY (server,mailid,timestamp),
  KEY message_id (messageid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


DROP TABLE IF EXISTS delivery;
CREATE TABLE IF NOT EXISTS delivery (
  server varchar(32) NOT NULL DEFAULT '',
  mailid varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  timestamp varchar(20) DEFAULT NULL,
  envelope_to varchar(255) DEFAULT NULL,
	senders_address varchar(255) DEFAULT NULL,
	return_path varchar(255) DEFAULT NULL,
  size bigint(20) DEFAULT NULL,
  hostname varchar(255) DEFAULT NULL,
  hostip varchar(15) DEFAULT NULL,
  hostport int(5) DEFAULT NULL,
  transport varchar(255) DEFAULT NULL,
  router varchar(255) DEFAULT NULL,
  PRIMARY KEY (server,mailid,timestamp,envelope_to)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


DROP TABLE IF EXISTS error;
CREATE TABLE IF NOT EXISTS error (
  server varchar(32) NOT NULL DEFAULT '',
  mailid varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  timestamp varchar(20) DEFAULT NULL,
  envelope_to varchar(255) DEFAULT NULL,
	return_path varchar(255) DEFAULT NULL,
  transport varchar(255) DEFAULT NULL,
  router varchar(255) DEFAULT NULL,
  status TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL, 
PRIMARY KEY (server,mailid,timestamp,envelope_to)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

DROP TABLE IF EXISTS messages;
CREATE TABLE IF NOT EXISTS messages (
  server varchar(32) NOT NULL DEFAULT '',
  mailid varchar(16) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  timestamp varchar(20) DEFAULT NULL,
  status varchar(32) DEFAULT NULL,
  completed tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (server,mailid),
  KEY timestamp (timestamp)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
