<?php

use Predis\Connection\ConnectionException;

/**
 * Модуль для индексирования записей
 *
 * @package modules.searchindexer
 * @since 1.0
 */
class ModuleSearchIndexer extends Module
{
    /**
     * Экземпляр Celery
     *
     * @var Celery
     */
    protected $oCeleryClient;


    /**
     * Инициализация модуля
     *
     */
    public function Init()
    {
        /**
         * Настройки Celery клиента для взаимодействия с Elasticsearch
         */
        try {
            $this->oCeleryClient = new Celery(
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
            error_log($exc->getMessage());
        }
    }

    /**
     * Индексирует топик
     *
     * @param ModuleTopic_EntityTopic $oTopic сущность топика с данными
     */
    public function TopicIndex(ModuleTopic_EntityTopic $oTopic)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.topic_index',
            [
                'topic_id' => $oTopic->getId(),
                'topic_blog_id' => $oTopic->getBlogId(),
                'topic_user_id' => $oTopic->getUserId(),
                'topic_title' => $oTopic->getTitle(),
                'topic_text' => $oTopic->getText(),
                'topic_tags' => $oTopic->getTags(),
                'topic_date' => $oTopic->getDateAdd()
            ]
        );
    }

    /**
     * Изменяет блог топика
     */
    public function TopicUpdateBlog($iTopicID, $iTopicBlog)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.topic_updateblog',
            [
                'topic_id' => $iTopicID,
                'topic_blog_id' => $iTopicBlog
            ]
        );
    }

    /**
     * Изменяет блог топиков
     */
    public function TopicMoveToBlog($old_blog_id, $new_blog_id)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.topic_movetoblog',
            [
                'old_blog_id' => $old_blog_id,
                'new_blog_id' => $new_blog_id
            ]
        );
    }

    /**
     * Удаляет топик
     */
    public function TopicDelete($oTopicId)
    {
        if ($oTopicId instanceof ModuleTopic_EntityTopic) {
            $sTopicId=$oTopicId->getId();
        } else {
            $sTopicId=$oTopicId;
        }

        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.topic_delete',
            [
                'topic_id' => $sTopicId
            ]
        );
    }

    /**
     * Индексирует комментарий
     *
     * @param ModuleComment_EntityComment $oComment сущность комментария с данными
     */
    public function CommentIndex(ModuleComment_EntityComment $oComment)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.comment_index',
            [
                'comment_id' => $oComment->getId(),
                'comment_target_id' => $oComment->getTargetId(),
                'comment_blog_id' => $oComment->getTargetParentId(),
                'comment_user_id' => $oComment->getUserId(),
                'comment_text' => $oComment->getText(),
                'comment_date' => $oComment->getDate()
            ]
        );
    }

    /**
     * Изменяет блог комментария
     */
    public function CommentUpdateBlog($iCommentID, $iCommentBlog)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.comment_updateblog',
            [
                'comment_id' => $iCommentID,
                'comment_blog_id' => $iCommentBlog
            ]
        );
    }

    /**
     * Изменяет блог комментариев
     */
    public function CommentMoveToBlog($old_blog_id, $new_blog_id)
    {
        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.comment_movetoblog',
            [
                'old_blog_id' => $old_blog_id,
                'new_blog_id' => $new_blog_id
            ]
        );
    }

    /**
     * Удаляет комментарий
     */
    public function CommentDelete($oCommentId)
    {
        if ($oCommentId instanceof ModuleComment_EntityComment) {
            $sCommentId=$oCommentId->getId();
        } else {
            $sCommentId=$oCommentId;
        }

        if ($this->oCeleryClient == null) {
            return;
        }
        $this->oCeleryClient->PostTask(
            'tasks.comment_delete',
            [
                'comment_id' => $sCommentId
            ]
        );
    }
}
