<?php
/*-------------------------------------------------------
*
*   LiveStreet Engine Social Networking
*   Copyright © 2008 Mzhelskiy Maxim
*
*--------------------------------------------------------
*
*   Official site: www.livestreet.ru
*   Contact e-mail: rus.engine@gmail.com
*
*   GNU General Public License, version 2:
*   http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
*
---------------------------------------------------------
*/

/**
 * Экшен обработки поиска по сайту
 *
 * @package actions
 * @since 1.0
 */
class ActionSearch extends Action {
	/**
	 * Допустимые типы поиска с параметрами
	 *
	 * @var array
	 */
	protected $sTypesEnabled = array('topics' => array('topic_publish' => 1), 'comments' => array('comment_delete' => 0));
	protected $aTypes = array('t' => 'topic', 'c' => 'comment');
	/**
	 * Массив результата от Сфинкса
	 *
	 * @var null|array
	 */
	protected $aSphinxRes = null;
	/**
	 * Поиск вернул результат или нет
	 *
	 * @var bool
	 */
	protected $bIsResults = FALSE;

	/**
	 * Инициализация
	 */
	public function Init() {
		$this->SetDefaultEvent('index');
		$this->Viewer_AddHtmlTitle($this->Lang_Get('search'));
	}
	/**
	 * Регистрация евентов
	 */
	protected function RegisterEvent() {
		$this->AddEvent('index','EventIndex');
        $this->AddEventPreg('/^(page([1-9]\d{0,5}))?$/i','EventIndex');
		$this->AddEvent('opensearch','EventOpenSearch');
	}
	/**
	 * Отображение формы поиска
	 */
	function EventIndex(){
        $sType = getRequestStr('t');
        if($sType == "") $sType = "t";
        if(!array_key_exists($sType, $this->aTypes)) return;

        $sQuery = getRequestStr('q');
        if($sQuery !== "") {
            $iPage = intval(preg_replace('#^page([1-9]\d{0,5})$#', '\1', Router::GetActionEvent()));
            if($iPage == 0) $iPage = 1;
            
            $this->Viewer_Assign('sQuery', $sQuery);
            $this->Viewer_Assign('sType', $sType);
            $this->Viewer_AddHtmlTitle($sQuery);

            /**
             * Проверяем, чтоб длина запроса была в допустимых пределах
             */
            if (!func_check($sQuery, 'text', 2, 255)) {
                $this->Message_AddErrorSingle($this->Lang_Get('search_error_length'), $this->Lang_Get('error'));
                return false;
            }

            /**
             * Направляем запрос в ElasticSearch, получаем результаты
             */
            $aResults = $this->Search_RunQuery($this->aTypes[$sType], $sQuery, $iPage - 1);
            if($aResults === false) {
                /**
                 * Произошла ошибка при поиске
                 */
                $this->Message_AddErrorSingle($this->Lang_Get('search_error'), $this->Lang_Get('error'));
                return false;
            }

            /*
             * Устанавливаем количество найденых результатов
             */
            $this->Viewer_Assign('iResCount', $aResults['total']);

            if($aResults['total'] > 0) {
                /*
                * Конфигурируем парсер
                */
                $this->Text_LoadJevixConfig('search');

                if($sType == 't') {
                    $aTopics = $this->Topic_GetTopicsAdditionalData(array_column($aResults['hits'], '_id'));
                    foreach($aTopics AS $oTopic){
                        $oTopic->setTextShort($this->Text_JevixParser($oTopic->getText()));
                    }
                    $this->Viewer_Assign('aTopics', $aTopics);
                } else {
                    $aComments = $this->Comment_GetCommentsAdditionalData(array_column($aResults['hits'], '_id'));
                    foreach($aComments AS $oComment){
                        $oComment->setText($this->Text_JevixParser(htmlspecialchars($oComment->getText())));
                    }
                    $this->Viewer_Assign('aComments', $aComments);
                }

                /**
                 * Конфигурируем пагинацию
                 */
                $aPaging = $this->Viewer_MakePaging(
                    $aResults['total'],
                    $iPage,
                    Config::Get('module.search.per_page'),
                    Config::Get('pagination.pages.count'),
                    Router::GetPath('search'),
                    array(
                        'q' => $sQuery,
                        't' => $sType
                    )
                );
                $this->Viewer_Assign('aPaging', $aPaging);

            }
            $this->SetTemplateAction('index');
        }
	}

	/**
	 * Обработка стандарта для браузеров Open Search
	 */
	function EventOpenSearch(){
		Router::SetIsShowStats(false);
		$this->Viewer_Assign('sAdminMail', Config::Get('sys.mail.from_email'));
	}

}
?>