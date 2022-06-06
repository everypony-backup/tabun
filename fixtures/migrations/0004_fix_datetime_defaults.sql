ALTER TABLE `ls_reminder`
  MODIFY COLUMN `reminder_date_used` datetime DEFAULT NULL;

ALTER TABLE `ls_role`
  MODIFY COLUMN `role_date_add` datetime NOT NULL DEFAULT '1970-01-01 00:00:00',
  MODIFY COLUMN `role_date_edit` datetime NOT NULL DEFAULT '1970-01-01 00:00:00';

ALTER TABLE `ls_role_avatar`
  MODIFY COLUMN `avatar_date_create` datetime NOT NULL DEFAULT '1970-01-01 00:00:00';

ALTER TABLE `ls_session`
  MODIFY COLUMN `session_date_create` datetime NOT NULL;
