<?php

/**
 * Модуль для работы с ElasticSearch
 *
 * @package modules.search
 * @since 1.0
 */
class ModuleSearch extends Module {
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
	 * Инициализация
	 *
	 */
	public function Init() {
        $this->aHosts = Config::Get('sys.elastic.hosts');
        $this->sIndex = Config::Get('sys.elastic.index');
        $this->sTopic = Config::Get('sys.elastic.topic_key');
        $this->sComment = Config::Get('sys.elastic.comment_key');
        $this->oElasticsearch = Elasticsearch\ClientBuilder::create()->setHosts($this->aHosts)->build();
	}

    /**
     * Делает указанный запрос
     *
     * @param string $sType    Тип элемента (topic, comment)
     * @param string $sQuery    Строка запроса
     * @return array
     */
    public function RunQuery($sType, $sQuery) {
        $aParams = [
            'index' => $this->sIndex,
            'type' => $sType,
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
        } catch (Exception $e) {
            return false;
        }

        return $aResponse;
    }

	/**
	 * Возвращает число найденых элементов в зависимоти от их типа
	 *
	 * @param string $sTerms	Поисковый запрос
	 * @param string $sObjType	Тип поиска
	 * @param array $aExtraFilters	Список фильтров
	 * @return int
	 */
	public function GetNumResultsByType($sTerms, $sObjType = 'topics', $aExtraFilters){
		$aResults = $this->FindContent($sTerms, $sObjType, 1, 1, $aExtraFilters);
		return $aResults['total_found'];
	}
	/**
	 * Непосредственно сам поиск
	 *
	 * @param string $sTerms	Поисковый запрос
	 * @param string $sObjType	Тип поиска
	 * @param int $iOffset	Сдвиг элементов
	 * @param int $iLimit	Количество элементов
	 * @param array $aExtraFilters	Список фильтров
	 * @return array
	 */
	public function FindContent($sTerms, $sObjType, $iOffset, $iLimit, $aExtraFilters){
		/**
		 * используем кеширование при поиске
		 */
		$sExtraFilters = serialize($aExtraFilters);
		$cacheKey = Config::Get('module.search.entity_prefix')."searchResult_{$sObjType}_{$sTerms}_{$iOffset}_{$iLimit}_{$sExtraFilters}";
		if (false === ($data = $this->Cache_Get($cacheKey))) {
			/**
			 * Параметры поиска
			 */
			$this->oSphinx->SetMatchMode(SPH_MATCH_ALL);
			$this->oSphinx->SetLimits($iOffset, $iLimit);
			/**
			 * Устанавливаем атрибуты поиска
			 */
			$this->oSphinx->ResetFilters();
			if(!is_null($aExtraFilters)){
				foreach($aExtraFilters AS $sAttribName => $sAttribValue){
					$this->oSphinx->SetFilter(
						$sAttribName,
						(is_array($sAttribValue)) ? $sAttribValue : array($sAttribValue)
					);
				}
			}
			/**
			 * Ищем
			 */
			if(!is_array($data = $this->oSphinx->Query($sTerms, Config::Get('module.search.entity_prefix').$sObjType.'Index'))) {
				return FALSE; // Скорее всего недоступен демон searchd
			}
			/**
			 * Если результатов нет, то и в кеш писать не стоит...
			 * хотя тут момент спорный
			 */
			if ($data['total'] > 0) {
				$this->Cache_Set($data, $cacheKey, array(), 60*15);
			}
		}
		return $data;
	}
	/**
	 * Получить ошибку при последнем обращении к поиску
	 *
	 * @return string
	 */
	public function GetLastError(){
		return $this->oSphinx->GetLastError();
	}
	/**
	 * Получаем сниппеты(превью найденых элементов)
	 *
	 * @param string $sText	Текст
	 * @param string $sIndex	Название индекса
	 * @param string $sTerms	Поисковый запрос
	 * @param string $before_match	Добавляемый текст перед ключом
	 * @param string $after_match	Добавляемый текст после ключа
	 * @return array
	 */
	public function GetSnippet($sText, $sIndex, $sTerms, $before_match, $after_match){
		$aReturn = $this->oSphinx->BuildExcerpts(array($sText), Config::Get('module.search.entity_prefix').$sIndex.'Index', $sTerms, array(
																  'before_match' => $before_match,
																  'after_match' => $after_match,
															  )
		);
		return $aReturn[0];
	}
}
