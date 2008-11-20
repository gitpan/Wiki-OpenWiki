


CREATE TABLE `announcements` (
  `a_id` smallint(5) unsigned NOT NULL auto_increment,
  `a_announcement` text NOT NULL,
  `a_dated` datetime NOT NULL,
  `a_from` datetime NOT NULL,
  `a_till` datetime NOT NULL,
  PRIMARY KEY  (`a_id`)
)ENGINE=MyISAM DEFAULT CHARSET=latin1;



CREATE TABLE `content` (
  `node_id` int(11) NOT NULL,
  `version` int(10) NOT NULL default '0',
  `text` mediumtext NOT NULL,
  `modified` datetime default NULL,
  `comment` mediumtext NOT NULL,
  `moderated` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`node_id`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `internal_links` (
  `link_from` varchar(200) NOT NULL default '',
  `link_to` varchar(200) NOT NULL default '',
  PRIMARY KEY  (`link_from`,`link_to`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `metadata` (
  `node_id` int(11) NOT NULL,
  `version` int(10) NOT NULL default '0',
  `metadata_type` varchar(200) NOT NULL default '',
  `metadata_value` mediumtext NOT NULL,
  KEY `metadata_index` (`node_id`,`version`,`metadata_type`,`metadata_value`(10))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `node` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(200) NOT NULL default '',
  `version` int(10) NOT NULL default '0',
  `text` mediumtext NOT NULL,
  `modified` datetime default NULL,
  `moderate` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`id`)
)ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(10) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


CREATE TABLE `siindex` (
  `ii_key` char(128) NOT NULL,
  `ii_val` longblob,
  PRIMARY KEY  (`ii_key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO schema_info VALUES (8);
INSERT INTO schema_info VALUES (9);
INSERT INTO schema_info VALUES (10);

