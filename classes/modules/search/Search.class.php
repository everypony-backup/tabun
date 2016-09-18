<?php

/**
 * Модуль для работы с ElasticSearch
 *
 * @package modules.search
 * @since 1.0
 */
class ModuleSearch extends Module
{
    /**
     * Объект Elasticsearch
     */
    protected $oElasticsearch = null;

    /**
     * Адреса серверов Elasticsearch
     */
    protected $aHosts;

    /**
     * Название общего индекса в Elasticsearch
     */
    protected $sIndex;

    /**
     * Тип записи топика
     */
    protected $sTopic;

    /**
     * Тип записи комментария
     */
    protected $sComment;

    /**
     * Количество элементов на странице
     */
    protected $iPerPage;

    /**
     * Инициализация
     *
     */
    public function Init()
    {
        $this->aHosts = Config::Get('sys.elastic.hosts');
        $this->sIndex = Config::Get('module.search.index');
        $this->sTopic = Config::Get('module.search.topic_key');
        $this->sComment = Config::Get('module.search.comment_key');
        $this->iPerPage = Config::Get('module.search.per_page');
        $this->oElasticsearch = Elasticsearch\ClientBuilder::create()->setHosts($this->aHosts)->build();
    }

    /**
     * Делает указанный запрос
     *
     * @param string $sType Тип элемента (topic, comment)
     * @param string $sQuery Строка запроса
     * @param int $iPage Страница поиска
     * @return array
     */
    public function RunQuery($sType, $sQuery, $iPage)
    {
        $cacheKey = Config::Get('sys.cache.prefixes.search.key') . "_{$sType}_{$sQuery}";

        if (($aResponse = $this->Cache_Get($cacheKey)) === false) { // В кэше не нашлось такого запроса
            // Выполняем его и сохраняем
            $aParams = [
                'index' => $this->sIndex,
                'type' => $sType,
                'size' => $this->iPerPage,
                'from' => $this->iPerPage * $iPage,
                'body' => [
                    'query' => [
                        'multi_match' => [
                            'query' => $sQuery,
                            'fields' => [
                                'title', 'text', 'tags'
                            ]
                        ]
                    ],
                    'highlight' => [
                        'fields' => [
                            'text' => []
                        ]
                    ]
                ]
            ];
            try {
                $aResponse = $this->oElasticsearch->search($aParams)['hits'];
                //$this->Cache_Set($aResponse, $cacheKey, array(), Config::Get('sys.cache.prefixes.search.time'));
            } catch (Exception $e) {
                return false;
            }
        }

        return $aResponse;
    }
}
