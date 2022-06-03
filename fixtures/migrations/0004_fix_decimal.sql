ALTER TABLE `ls_blog`
    MODIFY COLUMN `blog_rating` decimal(10,3) NOT NULL DEFAULT '0.000',
    MODIFY COLUMN `blog_limit_rating_topic` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_blog` SET `blog_rating` = '999999.999' WHERE `blog_rating` > '999999.999';
UPDATE `ls_blog` SET `blog_rating` = '-999999.999' WHERE `blog_rating` < '-999999.999';
UPDATE `ls_blog` SET `blog_limit_rating_topic` = '999999.999' WHERE `blog_limit_rating_topic` > '999999.999';
UPDATE `ls_blog` SET `blog_limit_rating_topic` = '-999999.999' WHERE `blog_limit_rating_topic` < '-999999.999';
ALTER TABLE `ls_blog`
    MODIFY COLUMN `blog_rating` decimal(9,3) NOT NULL DEFAULT '0.000',
    MODIFY COLUMN `blog_limit_rating_topic` decimal(9,3) NOT NULL DEFAULT '0.000';

ALTER TABLE `ls_comment`
    MODIFY COLUMN `comment_rating` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_comment` SET `comment_rating` = '999999.999' WHERE `comment_rating` > '999999.999';
UPDATE `ls_comment` SET `comment_rating` = '-999999.999' WHERE `comment_rating` < '-999999.999';
ALTER TABLE `ls_comment`
    MODIFY COLUMN `comment_rating` decimal(9,3) NOT NULL DEFAULT '0.000';

ALTER TABLE `ls_role`
    MODIFY COLUMN `role_rating` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_role` SET `role_rating` = '999999.999' WHERE `role_rating` > '999999.999';
UPDATE `ls_role` SET `role_rating` = '-999999.999' WHERE `role_rating` < '-999999.999';
ALTER TABLE `ls_role`
    MODIFY COLUMN `role_rating` decimal(9,3) NOT NULL DEFAULT '0.000';

ALTER TABLE `ls_topic`
    MODIFY COLUMN `topic_rating` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_topic` SET `topic_rating` = '999999.999' WHERE `topic_rating` > '999999.999';
UPDATE `ls_topic` SET `topic_rating` = '-999999.999' WHERE `topic_rating` < '-999999.999';
ALTER TABLE `ls_topic`
    MODIFY COLUMN `topic_rating` decimal(9,3) NOT NULL DEFAULT '0.000';

ALTER TABLE `ls_user`
    MODIFY COLUMN `user_skill` decimal(10,3) unsigned NOT NULL DEFAULT '0.000',
    MODIFY COLUMN `user_rating` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_user` SET `user_skill` = '999999.999' WHERE `user_skill` > '999999.999';
UPDATE `ls_user` SET `user_rating` = '999999.999' WHERE `user_rating` > '999999.999';
UPDATE `ls_user` SET `user_rating` = '-999999.999' WHERE `user_rating` < '-999999.999';
ALTER TABLE `ls_user`
    MODIFY COLUMN `user_skill` decimal(9,3) unsigned NOT NULL DEFAULT '0.000',
    MODIFY COLUMN `user_rating` decimal(9,3) NOT NULL DEFAULT '0.000';

ALTER TABLE `ls_vote`
    MODIFY COLUMN `vote_value` decimal(10,3) NOT NULL DEFAULT '0.000';
UPDATE `ls_vote` SET `vote_value` = '999999.999' WHERE `vote_value` > '999999.999';
UPDATE `ls_vote` SET `vote_value` = '-999999.999' WHERE `vote_value` < '-999999.999';
ALTER TABLE `ls_vote`
    MODIFY COLUMN `vote_value` decimal(9,3) NOT NULL DEFAULT '0.000';