<?php

use Predis\Connection\ConnectionException;

require_once(Config::Get('path.root.engine').'/lib/external/celery_bundle/vendor/autoload.php');
require_once(Config::Get('path.root.engine').'/lib/external/celery_bundle/celery.php');
/**
 * Модуль для работы с машиной полнотекстового поиска Sphinx
 *
 * @package modules.sphinx
 * @since 1.0
 */
class ModuleElastic extends Module {
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
	public function Init() {
		/**
		 * Настройки Celery клиента для отправки писем
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
				'topic_id' => $oTopic->getId(),
				'topic_blog_id' => $oTopic->getBlogId(),
				'topic_user_id' => $oTopic->getUserId(),
				'topic_type' => $oTopic->getType(),
				'topic_title' => $oTopic->getTitle(),
				'topic_text' => $oTopic->getText(), // TODO: clean text
				'topic_tags' => $oTopic->getTags(),
				'topic_date' => $oTopic->getDateAdd(),
				'topic_publish' => $oTopic->getPublish(),
			]
		);
	}
}
?>