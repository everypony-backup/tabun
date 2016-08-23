<?php

use Predis\Connection\ConnectionException;

/**
 * Модуль для работы Elasticsearch
 *
 * @package modules.elastic
 * @since 1.0
 */
class ModuleSearchIndexer extends Module {
	/**
	 * Экземпляр Celery
	 *
	 * @var Celery
	 */
	protected $oCeleryClient;

	/**
	 * Название общего индекса в Elasticsearch
	 */
	protected $eIndex;

	/**
	 * Тип записи топика
	 */
	protected $eTopic;

	/**
	 * Тип записи комментария
	 */
	protected $eComment;


	/**
	 * Инициализация модуля
	 *
	 */
	public function Init() {
		/**
		 * Настройки Celery клиента для взаимодействия с Elasticsearch
		 */
		try{
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

		$this->eIndex = Config::get('module.elastic.index');
		$this->eTopic = Config::get('module.elastic.topic_key');
		$this->eComment = Config::get('module.elastic.comment_key');
	}
	/**
	 * Индексирует топик
	 *
	 * @param string $oTopic сущность топика с данными
	 */
	public function TopicIndex(ModuleTopic_EntityTopic $oTopic) {
		if ($this->oCeleryClient == null) {
			return;
		}
		$this->oCeleryClient->PostTask(
			'tasks.topic_index',
			[
				'index' => $this->eIndex,
				'key' => $this->eTopic,
				'topic_id' => $oTopic->getId(),
				'topic_blog_id' => $oTopic->getBlogId(),
				'topic_user_id' => $oTopic->getUserId(),
				'topic_type' => $oTopic->getType(),
				'topic_title' => $oTopic->getTitle(),
				'topic_text' => $oTopic->getText(),
				'topic_tags' => $oTopic->getTags(),
				'topic_date' => $oTopic->getDateAdd(),
				'topic_publish' => $oTopic->getPublish(),
			]
		);
	}
}
