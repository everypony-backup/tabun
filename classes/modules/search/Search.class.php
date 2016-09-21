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
     * @param string $aSearchParams Параметры поиска
     * @param string $sQuery Строка запроса
     * @param int $iPage Страница поиска
     * @return array
     */
    public function RunQuery($aSearchParams, $sQuery, $iPage)
    {
        // Выполняем его и сохраняем
        $aParams = [
            'index' => $this->sIndex,
            'type' => $aSearchParams['type'],
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
                ]
            ]
        ];

        switch ($aSearchParams['sort']) {
            case 'date':
                $aParams['body']['sort'] = [
                    'date' => [
                        'order' => 'desc'
                    ]
                ];
                break;
        }
        try {
            $aResponse = $this->oElasticsearch->search($aParams)['hits'];
        } catch (Exception $e) {
            return false;
        }

        return $aResponse;
    }
}
