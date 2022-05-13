<?php

use Predis\Connection\ConnectionException;

class Reindex extends LSC
{
    private $celeryClient;
    private $oDb;
    private $sIndex;
    private $sComment;
    private $sTopic;

    public function __construct()
    {
        try {
            $this->celeryClient = new Celery(
                Config::Get('sys.celery.host'),
                Config::Get('sys.celery.login'),
                Config::Get('sys.celery.password'),
                Config::Get('sys.celery.db'),
                Config::Get('sys.celery.exchange'),
                Config::Get('sys.celery.binding'),
                Config::Get('sys.celery.port'),
                Config::Get('sys.celery.backend')
            );
        } catch (ConnectionException $exc) {
            echo $exc->getMessage();
            exit();
        }
        try {
            $this->oDb = Engine::getInstance()->Database_GetConnect();
        } catch (Exception $exc) {
            echo $exc->getMessage();
            exit();
        }
    }

    public function getHelp()
    {
        return "Usage: reindex (topics | comments)";
    }

    public function actionTopics()
    {
        $sql = "
          SELECT
            ls_topic.topic_id,
            blog_id AS topic_blog_id,
            user_id AS topic_user_id,
            topic_title,
            ls_topic_content.topic_text,
            topic_tags,
            topic_date_add AS topic_date
          FROM
            ls_topic
          LEFT JOIN 
            ls_topic_content 
          ON 
            ls_topic.topic_id = ls_topic_content.topic_id
          WHERE
            topic_type = 'topic'
          AND
            topic_publish = 1
        ";

        $topics = $this->oDb->select($sql);
        if(is_array($topics) && count($topics)) {
            // Инициализация
            $this->celeryClient->PostTask('tasks.topic_init', []);
            // Добавление постов в ElasticSearch
            foreach ($topics as $topic) {
                echo "Pushing topic [".$topic['topic_id']."] from blog [".$topic['topic_blog_id']."]\n";
                $this->celeryClient->PostTask(
                    'tasks.topic_index',
                    [
                        'topic_id' => $topic['topic_id'],
                        'topic_blog_id' => $topic['topic_blog_id'],
                        'topic_user_id' => $topic['topic_user_id'],
                        'topic_title' => $topic['topic_title'],
                        'topic_text' => $topic['topic_text'],
                        'topic_tags' => $topic['topic_tags'],
                        'topic_date' => $topic['topic_date']
                    ]
                );
            }
        }
    }

    public function actionComments()
    {
        $sql = "
          SELECT
            comment_id,
            target_id AS comment_target_id,
            target_parent_id AS comment_blog_id,
            user_id AS comment_user_id,
            comment_text,
            comment_date,
            comment_publish
          FROM
            ls_comment
          WHERE
            target_type = 'topic'
          AND
            comment_delete = 0
          AND
            comment_publish = 1
        ";

        $comments = $this->oDb->select($sql);
        if(is_array($comments) && count($comments)) {
            // Инициализация
            $this->celeryClient->PostTask('tasks.comment_init', []);
            // Добавление комментариев в ElasticSearch
            foreach ($comments as $comment) {
                echo "Pushing comment [".$comment['comment_id']."] from blog [".$comment['comment_blog_id']."]\n";
                $this->celeryClient->PostTask(
                    'tasks.comment_index',
                    [
                        'comment_id' => $comment['comment_id'],
                        'comment_blog_id' => $comment['comment_blog_id'],
                        'comment_target_id' => $comment['comment_target_id'],
                        'comment_user_id' => $comment['comment_user_id'],
                        'comment_text' => $comment['comment_text'],
                        'comment_date' => $comment['comment_date']
                    ]
                );
            }
        }
    }
}
