CREATE TABLE IF NOT EXISTS `ls_comment_change_history` (
  `id`              INT(16) UNSIGNED     NOT NULL AUTO_INCREMENT,
  `flags`           SMALLINT(5) UNSIGNED NOT NULL,
  `comment`         INT(16) UNSIGNED     NOT NULL,
  `text`            TEXT                 NOT NULL,
  `text_crc32`      INT(10) UNSIGNED     NOT NULL,
  `validFrom`       DATETIME             NOT NULL,
  `validator`       INT(10) UNSIGNED     NOT NULL,
  `invalidFrom`     DATETIME             NOT NULL,
  `invalidator`     INT(10) UNSIGNED     NOT NULL,
  `invalidatorType` TINYINT(3) UNSIGNED  NOT NULL,
  PRIMARY KEY (`id`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 1;
