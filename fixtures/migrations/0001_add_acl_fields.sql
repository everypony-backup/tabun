ALTER TABLE `ls_blog_user`
  ADD COLUMN `user_blog_permissions`    INT UNSIGNED  NULL  DEFAULT NULL,
  ADD COLUMN `user_topic_permissions`   INT UNSIGNED  NULL  DEFAULT NULL,
  ADD COLUMN `user_comment_permissions` INT UNSIGNED  NULL  DEFAULT NULL,
  ADD COLUMN `user_vote_permissions`    INT UNSIGNED  NULL  DEFAULT NULL;
