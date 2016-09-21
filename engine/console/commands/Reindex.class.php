<?php

use Predis\Connection\ConnectionException;

class Reindex extends LSC
{
    private $celeryClient;
    private $databaseHandler;
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
        }
        try {
            $this->databaseHandler = new PDO(
                sprintf(
                    "%s:host=%s;port=%d;dbname=%s",
                    Config::Get("db.params.type"),
                    Config::Get("db.params.host"),
                    Config::Get("db.params.port"),
                    Config::Get("db.params.dbname")
                ),
                Config::Get("db.params.user"),
                Config::Get("db.params.pass")
            );
        } catch (PDOException $exc) {
            echo $exc->getMessage();
        }

        $this->sIndex = Config::Get('module.search.index');
        $this->sTopic = Config::Get('module.search.topic_key');
        $this->sComment = Config::Get('module.search.comment_key');
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
            topic_type,
            topic_title,
            ls_topic_content.topic_text,
            topic_tags,
            topic_date_add AS topic_date,
            topic_publish AS topic_publish
          FROM
            ls_topic
          LEFT JOIN 
            ls_topic_content 
          ON 
            ls_topic.topic_id = ls_topic_content.topic_id
        ";

        $statement = $this->databaseHandler->prepare($sql, [PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY]);
        $statement->execute();

        while ($row = $statement->fetch(PDO::FETCH_ASSOC, PDO::FETCH_ORI_NEXT)) {
            $this->celeryClient->PostTask(
                'tasks.topic_index',
                array_merge(
                    [
                        'index' => $this->sIndex,
                        'key' => $this->sTopic
                    ],
                    $row
                )
            );
        }
    }

    public function actionComments()
    {
        $sql = "
          SELECT
            comment_id,
            target_id AS comment_target_id,
            target_type AS comment_target_type,
            user_id AS comment_user_id,
            comment_text,
            comment_date,
            comment_publish
          FROM
            ls_comment
        ";

        $statement = $this->databaseHandler->prepare($sql, [PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY]);
        $statement->execute();

        while ($row = $statement->fetch(PDO::FETCH_ASSOC, PDO::FETCH_ORI_NEXT)) {
            $this->celeryClient->PostTask(
                'tasks.comment_index',
                array_merge(
                    [
                        'index' => $this->sIndex,
                        'key' => $this->sTopic
                    ],
                    $row
                )
            );
        var_dump($row);
        }
    }
}
