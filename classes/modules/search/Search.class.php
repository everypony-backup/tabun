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
        $this->iPerPage = Config::Get('module.search.per_page');
        $this->oElasticsearch = Elastic\Elasticsearch\ClientBuilder::create()->setHosts($this->aHosts)->build();
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
            'index' => $aSearchParams['type'],
            'size' => $this->iPerPage,
            'from' => $this->iPerPage * $iPage,
            'body' => [
                'query' => [
                    'bool' => [
                        'must' => [
                            'multi_match' => [ 'query' => $sQuery ],
                        ],
                        'filter' => [
                        ]
                    ]
                ]
            ]
        ];

        if (is_array($aSearchParams['terms'])) {
            $aParams['body']['query']['bool']['filter'][] = [ 'terms' => $aSearchParams['terms'] ];
        }

        switch ($aSearchParams['sort_by']) {
            default:
                $aParams['body']['sort'] = [
                    '_score' => [
                        'order' => $aSearchParams['sort_dir']
                    ]
                ];
                break;
        }

        if ($aSearchParams['topic_type_title'] == true) {
            $aParams['body']['query']['bool']['must']['multi_match']['fields'][] = 'title';
        }
        if ($aSearchParams['topic_type_text'] == true) {
            $aParams['body']['query']['bool']['must']['multi_match']['fields'][] = 'text';
        }
        if ($aSearchParams['topic_type_tags'] == true) {
            $aParams['body']['query']['bool']['must']['multi_match']['fields'][] = 'tags';
        }

        try {
            $aResponse = $this->oElasticsearch->search($aParams)['hits'];
        } catch (Exception $e) {
            return false;
        }

        return $aResponse;
    }
}
