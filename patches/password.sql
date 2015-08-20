UPDATE ls_user SET user_password = '';
ALTER TABLE ls_user MODIFY COLUMN user_password VARCHAR(128);
