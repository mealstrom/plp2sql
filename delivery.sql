SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

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
