-- MySQL dump 9.11
--
-- Host: localhost    Database: userstamp_test
-- ------------------------------------------------------
-- Server version	4.0.24

--
-- Table structure for table `entries`
--

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
) TYPE=MyISAM;

DROP TABLE IF EXISTS customers;
CREATE TABLE users (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
) TYPE=MyISAM;

DROP TABLE IF EXISTS entries;
CREATE TABLE entries (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  created_by int(11) default 0,
  updated_by int(11) default 0,
  PRIMARY KEY  (id)
) TYPE=MyISAM;

DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  created_by int(11) default 0,
  updated_by int(11) default 0,
  PRIMARY KEY  (id)
) TYPE=MyISAM;
