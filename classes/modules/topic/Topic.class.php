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
 * Модуль для работы с топиками
 *
 * @package modules.topic
 * @since 1.0
 */
class ModuleTopic extends Module
{
    /**
     * Объект маппера
     *
     * @var ModuleTopic_MapperTopic
     */
    protected $oMapperTopic;
    /**
     * Объект текущего пользователя
     *
     * @var ModuleUser_EntityUser|null
     */
    protected $oUserCurrent=null;
    /**
     * Список типов топика
     *
     * @var array
     */
    protected $aTopicTypes=array(
        'topic','question'
    );

    protected $sUserAgent = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0";

    /**
     * Инициализация
     *
     */
    public function Init()
    {
        $this->oMapperTopic=Engine::GetMapper(__CLASS__);
        $this->oUserCurrent=$this->User_GetUserCurrent();
    }
    /**
     * Возвращает список типов топика
     *
     * @return array
     */
    public function GetTopicTypes()
    {
        return $this->aTopicTypes;
    }
    /**
     * Добавляет в новый тип топика
     *
     * @param string $sType	Новый тип
     * @return bool
     */
    public function AddTopicType($sType)
    {
        if (!in_array($sType, $this->aTopicTypes)) {
            $this->aTopicTypes[]=$sType;
            return true;
        }
        return false;
    }
    /**
     * Проверяет разрешен ли данный тип топика
     *
     * @param string $sType	Тип
     * @return bool
     */
    public function IsAllowTopicType($sType)
    {
        return in_array($sType, $this->aTopicTypes);
    }
    /**
     * Получает дополнительные данные(объекты) для топиков по их ID
     *
     * @param array $aTopicId	Список ID топиков
     * @param array|null $aAllowData Список типов дополнительных данных, которые нужно подключать к топикам
     * @return array
     */
    public function GetTopicsAdditionalData($aTopicId, $aAllowData=null)
    {
        if (is_null($aAllowData)) {
            $aAllowData=array('user'=>array(),'blog'=>array('owner'=>array(),'relation_user'),'vote','favourite','comment_new');
        }
        func_array_simpleflip($aAllowData);
        if (!is_array($aTopicId)) {
            $aTopicId=array($aTopicId);
        }
        /**
         * Получаем "голые" топики
         */
        $aTopics=$this->GetTopicsByArrayId($aTopicId);
        /**
         * Формируем ID дополнительных данных, которые нужно получить
         */
        $aUserId=array();
        $aBlogId=array();
        $aTopicIdQuestion=array();
        foreach ($aTopics as $oTopic) {
            if (isset($aAllowData['user'])) {
                $aUserId[]=$oTopic->getUserId();
            }
            if (isset($aAllowData['blog'])) {
                $aBlogId[]=$oTopic->getBlogId();
            }
            if ($oTopic->getType()=='question') {
                $aTopicIdQuestion[]=$oTopic->getId();
            }
        }
        /**
         * Получаем дополнительные данные
         */
        $aTopicsVote=array();
        $aFavouriteTopics=array();
        $aTopicsQuestionVote=array();
        $aTopicsRead=array();
        $aUsers=isset($aAllowData['user']) && is_array($aAllowData['user']) ? $this->User_GetUsersAdditionalData($aUserId, $aAllowData['user']) : $this->User_GetUsersAdditionalData($aUserId);
        $aBlogs=isset($aAllowData['blog']) && is_array($aAllowData['blog']) ? $this->Blog_GetBlogsAdditionalData($aBlogId, $aAllowData['blog']) : $this->Blog_GetBlogsAdditionalData($aBlogId);
        if (isset($aAllowData['vote']) and $this->oUserCurrent) {
            $aTopicsVote=$this->Vote_GetVoteByArray($aTopicId, 'topic', $this->oUserCurrent->getId());
            $aTopicsQuestionVote=$this->GetTopicsQuestionVoteByArray($aTopicIdQuestion, $this->oUserCurrent->getId());
        }
        if (isset($aAllowData['favourite']) and $this->oUserCurrent) {
            $aFavouriteTopics=$this->GetFavouriteTopicsByArray($aTopicId, $this->oUserCurrent->getId());
        }
        if (isset($aAllowData['comment_new']) and $this->oUserCurrent) {
            $aTopicsRead=$this->GetTopicsReadByArray($aTopicId, $this->oUserCurrent->getId());
        }
        /**
         * Добавляем данные к результату - списку топиков
         */
        foreach ($aTopics as $oTopic) {
            if (isset($aUsers[$oTopic->getUserId()])) {
                $oTopic->setUser($aUsers[$oTopic->getUserId()]);
            } else {
                $oTopic->setUser(null); // или $oTopic->setUser(new ModuleUser_EntityUser());
            }
            if (isset($aBlogs[$oTopic->getBlogId()])) {
                $oTopic->setBlog($aBlogs[$oTopic->getBlogId()]);
            } else {
                $oTopic->setBlog(null); // или $oTopic->setBlog(new ModuleBlog_EntityBlog());
            }
            if (isset($aTopicsVote[$oTopic->getId()])) {
                $oTopic->setVote($aTopicsVote[$oTopic->getId()]);
            } else {
                $oTopic->setVote(null);
            }
            if (isset($aFavouriteTopics[$oTopic->getId()])) {
                $oTopic->setFavourite($aFavouriteTopics[$oTopic->getId()]);
            } else {
                $oTopic->setFavourite(null);
            }
            if (isset($aTopicsQuestionVote[$oTopic->getId()])) {
                $oTopic->setUserQuestionIsVote(true);
            } else {
                $oTopic->setUserQuestionIsVote(false);
            }
            if (isset($aTopicsRead[$oTopic->getId()])) {
                $oTopic->setCountCommentNew($oTopic->getCountComment()-$aTopicsRead[$oTopic->getId()]->getCommentCountLast());
                $oTopic->setDateRead($aTopicsRead[$oTopic->getId()]->getDateRead());
            } else {
                $oTopic->setCountCommentNew($oTopic->getCountComment());
                $oTopic->setDateRead($oTopic->getDateAdd());
            }
        }
        return $aTopics;
    }
    /**
     * Добавляет топик
     *
     * @param ModuleTopic_EntityTopic $oTopic	Объект топика
     * @return ModuleTopic_EntityTopic|bool
     */
    public function AddTopic(ModuleTopic_EntityTopic $oTopic)
    {
        if ($sId=$this->oMapperTopic->AddTopic($oTopic)) {
            $oTopic->setId($sId);
            if ($oTopic->getPublish() and $oTopic->getTags()) {
                $aTags=explode(',', $oTopic->getTags());
                foreach ($aTags as $sTag) {
                    $oTag=Engine::GetEntity('Topic_TopicTag');
                    $oTag->setTopicId($oTopic->getId());
                    $oTag->setUserId($oTopic->getUserId());
                    $oTag->setBlogId($oTopic->getBlogId());
                    $oTag->setText($sTag);
                    $this->AddTopicTag($oTag);
                }
            }
            //чистим зависимые кеши
            $this->Cache_Clean(
                Zend_Cache::CLEANING_MODE_MATCHING_ANY_TAG,
                [
                    'topic_new',
                    "topic_update_user_{$oTopic->getUserId()}",
                    "topic_new_blog_{$oTopic->getBlogId()}"
                ]
            );
            $this->SearchIndexer_TopicIndex($oTopic);
            return $oTopic;
        }
        return false;
    }
    /**
     * Добавление тега к топику
     *
     * @param ModuleTopic_EntityTopicTag $oTopicTag	Объект тега топика
     * @return int
     */
    public function AddTopicTag(ModuleTopic_EntityTopicTag $oTopicTag)
    {
        return $this->oMapperTopic->AddTopicTag($oTopicTag);
    }
    /**
     * Удаляет теги у топика
     *
     * @param int $sTopicId	ID топика
     * @return bool
     */
    public function DeleteTopicTagsByTopicId($sTopicId)
    {
        return $this->oMapperTopic->DeleteTopicTagsByTopicId($sTopicId);
    }
    /**
     * Удаляет топик.
     * Если тип таблиц в БД InnoDB, то удалятся всё связи по топику(комменты,голосования,избранное)
     *
     * @param ModuleTopic_EntityTopic|int $oTopicId Объект топика или ID
     * @return bool
     */
    public function DeleteTopic($oTopicId)
    {
        if ($oTopicId instanceof ModuleTopic_EntityTopic) {
            $sTopicId=$oTopicId->getId();
            $this->Cache_Clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                [
                    "topic_update_user_{$oTopicId->getUserId()}"
                ]
            );
        } else {
            $sTopicId=$oTopicId;
        }
        /**
         * Чистим зависимые кеши
         */
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_TAG,
            [
                'topic_update'
            ]
        );
        $this->Cache_Delete("topic_{$sTopicId}");
        /**
         * Если топик успешно удален, удаляем связанные данные
         */
        if ($bResult=$this->oMapperTopic->DeleteTopic($sTopicId)) {
            // Удаление из ElasticSearch
            $this->SearchIndexer_TopicDelete($sTopicId);
            // Удаление прочих данных
            return $this->DeleteTopicAdditionalData($sTopicId);
        }

        return false;
    }
    /**
     * Удаляет свзяанные с топика данные
     *
     * @param  int  $iTopicId	ID топика
     * @return bool
     */
    public function DeleteTopicAdditionalData($iTopicId)
    {
        /**
         * Чистим зависимые кеши
         */
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_TAG,
            [
                'topic_update'
            ]
        );
        $this->Cache_Delete("topic_{$iTopicId}");
        /**
         * Удаляем контент топика
         */
        $this->DeleteTopicContentByTopicId($iTopicId);
        /**
         * Удаляем комментарии к топику.
         * При удалении комментариев они удаляются из избранного,прямого эфира и голоса за них
         */
        $this->Comment_DeleteCommentByTargetId($iTopicId, 'topic');
        /**
         * Удаляем топик из избранного
         */
        $this->DeleteFavouriteTopicByArrayId($iTopicId);
        /**
         * Удаляем топик из прочитанного
         */
        $this->DeleteTopicReadByArrayId($iTopicId);
        /**
         * Удаляем голосование к топику
         */
        $this->Vote_DeleteVoteByTarget($iTopicId, 'topic');
        /**
         * Удаляем теги
         */
        $this->DeleteTopicTagsByTopicId($iTopicId);
        return true;
    }
    /**
     * Обновляет топик
     *
     * @param ModuleTopic_EntityTopic $oTopic	Объект топика
     * @return bool
     */
    public function UpdateTopic(ModuleTopic_EntityTopic $oTopic)
    {
        /**
         * Получаем топик ДО изменения
         */
        $oTopicOld=$this->GetTopicById($oTopic->getId());
        $oTopic->setDateEdit(date("Y-m-d H:i:s"));
        if ($this->oMapperTopic->UpdateTopic($oTopic)) {
            // Переиндексирование топика в ElasticSearch
            $this->SearchIndexer_TopicIndex($oTopic);
            /**
             * Если топик изменил видимость(publish) или локацию (BlogId) или список тегов
             */
            if (($oTopic->getPublish()!=$oTopicOld->getPublish()) || ($oTopic->getBlogId()!=$oTopicOld->getBlogId()) || ($oTopic->getTags()!=$oTopicOld->getTags())) {
                /**
                 * Обновляем теги
                 */
                $this->DeleteTopicTagsByTopicId($oTopic->getId());
                if ($oTopic->getPublish() and $oTopic->getTags()) {
                    $aTags=explode(',', $oTopic->getTags());
                    foreach ($aTags as $sTag) {
                        $oTag=Engine::GetEntity('Topic_TopicTag');
                        $oTag->setTopicId($oTopic->getId());
                        $oTag->setUserId($oTopic->getUserId());
                        $oTag->setBlogId($oTopic->getBlogId());
                        $oTag->setText($sTag);
                        $this->AddTopicTag($oTag);
                    }
                }
            }
            if ($oTopic->getPublish()!=$oTopicOld->getPublish()) {
                /**
                 * Обновляем избранное
                 */
                $this->SetFavouriteTopicPublish($oTopic->getId(), $oTopic->getPublish());
                /**
                 * Удаляем комментарий топика из прямого эфира
                 */
                if ($oTopic->getPublish()==0) {
                    $this->Comment_DeleteCommentOnlineByTargetId($oTopic->getId(), 'topic');
                }
                /**
                 * Изменяем видимость комментов
                 */
                $this->Comment_SetCommentsPublish($oTopic->getId(), 'topic', $oTopic->getPublish());
            }
            //чистим зависимые кеши
            $this->Cache_Clean(
                Zend_Cache::CLEANING_MODE_MATCHING_ANY_TAG,
                [
                    'topic_update',
                    "topic_update_user_{$oTopic->getUserId()}"
                ]
            );
            $this->Cache_Delete("topic_{$oTopic->getId()}");
            return true;
        }
        return false;
    }
    /**
     * Удаление контента топика по его номеру
     *
     * @param int $iTopicId	ID топика
     * @return bool
     */
    public function DeleteTopicContentByTopicId($iTopicId)
    {
        return $this->oMapperTopic->DeleteTopicContentByTopicId($iTopicId);
    }
    /**
     * Получить топик по айдишнику
     *
     * @param int $sId	ID топика
     * @return ModuleTopic_EntityTopic|null
     */
    public function GetTopicById($sId)
    {
        if (!is_numeric($sId)) {
            return null;
        }
        $aTopics=$this->GetTopicsAdditionalData($sId);
        if (isset($aTopics[$sId])) {
            return $aTopics[$sId];
        }
        return null;
    }
    /**
     * Получить список топиков по списку айдишников
     *
     * @param array $aTopicId	Список ID топиков
     * @return array
     */
    public function GetTopicsByArrayId($aTopicId)
    {
        if (!$aTopicId) {
            return array();
        }
        if (!is_array($aTopicId)) {
            $aTopicId=array($aTopicId);
        }
        $aTopicId=array_unique($aTopicId);
        $aTopics=array();
        $aTopicIdNotNeedQuery=array();
        /**
         * Делаем мульти-запрос к кешу
         */
        $aCacheKeys=func_build_cache_keys($aTopicId, 'topic_');
        if (false !== ($data = $this->Cache_Get($aCacheKeys))) {
            /**
             * проверяем что досталось из кеша
             */
            foreach ($aCacheKeys as $sValue => $sKey) {
                if (array_key_exists($sKey, $data)) {
                    if ($data[$sKey]) {
                        $aTopics[$data[$sKey]->getId()]=$data[$sKey];
                    } else {
                        $aTopicIdNotNeedQuery[]=$sValue;
                    }
                }
            }
        }
        /**
         * Смотрим каких топиков не было в кеше и делаем запрос в БД
         */
        $aTopicIdNeedQuery=array_diff($aTopicId, array_keys($aTopics));
        $aTopicIdNeedQuery=array_diff($aTopicIdNeedQuery, $aTopicIdNotNeedQuery);
        $aTopicIdNeedStore=$aTopicIdNeedQuery;
        if ($data = $this->oMapperTopic->GetTopicsByArrayId($aTopicIdNeedQuery)) {
            foreach ($data as $oTopic) {
                /**
                 * Добавляем к результату и сохраняем в кеш
                 */
                $aTopics[$oTopic->getId()]=$oTopic;
                $this->Cache_Set($oTopic, "topic_{$oTopic->getId()}", array());
                $aTopicIdNeedStore=array_diff($aTopicIdNeedStore, array($oTopic->getId()));
            }
        }
        /**
         * Сохраняем в кеш запросы не вернувшие результата
         */
        foreach ($aTopicIdNeedStore as $sId) {
            $this->Cache_Set(null, "topic_{$sId}", array());
        }
        /**
         * Сортируем результат согласно входящему массиву
         */
        $aTopics=func_array_sort_by_keys($aTopics, $aTopicId);
        return $aTopics;
    }
    /**
     * Получает список топиков из избранного
     *
     * @param  int $sUserId	ID пользователя
     * @param  int    $iCurrPage	Номер текущей страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @return array('collection'=>array,'count'=>int)
     */
    public function GetTopicsFavouriteByUserId($sUserId, $iCurrPage, $iPerPage)
    {
        $aCloseTopics =array();
        /**
         * Получаем список идентификаторов избранных записей
         */
        $data = ($this->oUserCurrent && $sUserId==$this->oUserCurrent->getId())
            ? $this->Favourite_GetFavouritesByUserId($sUserId, 'topic', $iCurrPage, $iPerPage, $aCloseTopics)
            : $this->Favourite_GetFavouriteOpenTopicsByUserId($sUserId, $iCurrPage, $iPerPage);
        /**
         * Получаем записи по переданому массиву айдишников
         */
        $data['collection']=$this->GetTopicsAdditionalData($data['collection']);
        return $data;
    }
    /**
     * Возвращает число топиков в избранном
     *
     * @param  int $sUserId	ID пользователя
     * @return int
     */
    public function GetCountTopicsFavouriteByUserId($sUserId)
    {
        $aCloseTopics = array();
        return ($this->oUserCurrent && $sUserId==$this->oUserCurrent->getId())
            ? $this->Favourite_GetCountFavouritesByUserId($sUserId, 'topic', $aCloseTopics)
            : $this->Favourite_GetCountFavouriteOpenTopicsByUserId($sUserId);
    }
    /**
     * Список топиков по фильтру
     *
     * @param  array $aFilter	Фильтр
     * @param  int   $iPage	Номер страницы
     * @param  int   $iPerPage	Количество элементов на страницу
     * @param  array|null   $aAllowData	Список типов данных для подгрузки в топики
     * @return array('collection'=>array,'count'=>int)
     */
    public function GetTopicsByFilter($aFilter, $iPage=1, $iPerPage=10, $aAllowData=null)
    {
        if (!is_numeric($iPage) or $iPage<=0) {
            $iPage=1;
        }
        $s=serialize($aFilter);
        $sCacheKey = "topic_filter_{$s}_{$iPage}_{$iPerPage}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = array(
                'collection'=>$this->oMapperTopic->GetTopics($aFilter, $iCount, $iPage, $iPerPage),
                'count'=>$iCount
            );
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update',
                    'topic_new'
                ]
            );
        }
        $data['collection']=$this->GetTopicsAdditionalData($data['collection'], $aAllowData);
        return $data;
    }
    /**
     * Количество топиков по фильтру
     *
     * @param array $aFilter	Фильтр
     * @return int
     */
    public function GetCountTopicsByFilter($aFilter)
    {
        $s=serialize($aFilter);
        $sCacheKey = "topic_count_{$s}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetCountTopics($aFilter);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update',
                    'topic_new'
                ]
            );
        }
        return 	$data;
    }
    /**
     * Количество черновиков у пользователя
     *
     * @param int $iUserId	ID пользователя
     * @return int
     */
    public function GetCountDraftTopicsByUserId($iUserId)
    {
        return $this->GetCountTopicsByFilter(array(
                                                 'user_id' => $iUserId,
                                                 'topic_publish' => 0
                                             ));
    }
    /**
     * Получает список хороших топиков для вывода на главную страницу(из всех блогов, как коллективных так и персональных)
     *
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsGood($iPage, $iPerPage, $bAddAccessible=true)
    {
        $aFilter=array(
            'blog_type' => array(
                'open'
            ),
            'topic_publish' => 1,
            'topic_rating'  => array(
                'value' => Config::Get('module.blog.index_good'),
                'type'  => 'top',
                'publish_index'  => 1,
            ),
            // Orhideous mod by selective filtering
            'blog_filter' => Config::Get('module.blog.selective_filter'),
        );
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $bAddAccessible) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }

        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает список новых топиков, ограничение новизны по дате из конфига
     *
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsNew($iPage, $iPerPage, $bAddAccessible=true)
    {
        $sDate=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
        $aFilter=array(
            'blog_type' => array(
                'personal',
                'open',
            ),
            'topic_publish' => 1,
            'topic_new' => $sDate,
        );
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $bAddAccessible) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает список ВСЕХ новых топиков
     *
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsNewAll($iPage, $iPerPage, $bAddAccessible=true)
    {
        $aFilter=array(
            'blog_type' => array(
                'personal',
                'open',
            ),
            'topic_publish' => 1,
        );
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $bAddAccessible) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает список ВСЕХ обсуждаемых топиков
     *
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  int|string   $sPeriod	Период в виде секунд или конкретной даты
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsDiscussed($iPage, $iPerPage, $sPeriod=null, $bAddAccessible=true)
    {
        if (is_numeric($sPeriod)) {
            // количество последних секунд
            $sPeriod=date("Y-m-d H:00:00", time()-$sPeriod);
        }

        $aFilter=array(
            'blog_type' => array(
                'personal',
                'open',
            ),
            'topic_publish' => 1
        );
        if ($sPeriod) {
            $aFilter['topic_date_more'] = $sPeriod;
        }
        $aFilter['order']=' t.topic_count_comment desc, t.topic_id desc ';
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $bAddAccessible) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает список ВСЕХ рейтинговых топиков
     *
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  int|string   $sPeriod	Период в виде секунд или конкретной даты
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsTop($iPage, $iPerPage, $sPeriod=null, $bAddAccessible=true)
    {
        if (is_numeric($sPeriod)) {
            // количество последних секунд
            $sPeriod=date("Y-m-d H:00:00", time()-$sPeriod);
        }

        $aFilter=array(
            'blog_type' => array(
                'personal',
                'open',
            ),
            'topic_publish' => 1
        );
        if ($sPeriod) {
            $aFilter['topic_date_more'] = $sPeriod;
        }
        $aFilter['order']=array('t.topic_rating desc','t.topic_id desc');
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $bAddAccessible) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает заданое число последних топиков
     *
     * @param int $iCount	Количество
     * @return array
     */
    public function GetTopicsLast($iCount)
    {
        $aFilter=array(
            'blog_type' => array(
                'personal',
                'open',
            ),
            'topic_publish' => 1,
        );
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        $aReturn=$this->GetTopicsByFilter($aFilter, 1, $iCount);
        if (isset($aReturn['collection'])) {
            return $aReturn['collection'];
        }
        return false;
    }
    /**
     * список топиков из персональных блогов
     *
     * @param int $iPage	Номер страницы
     * @param int $iPerPage	Количество элементов на страницу
     * @param string $sShowType	Тип выборки топиков
     * @param string|int $sPeriod	Период в виде секунд или конкретной даты
     * @return array
     */
    public function GetTopicsPersonal($iPage, $iPerPage, $sShowType='good', $sPeriod=null)
    {
        if (is_numeric($sPeriod)) {
            // количество последних секунд
            $sPeriod=date("Y-m-d H:00:00", time()-$sPeriod);
        }
        $aFilter=array(
            'blog_type' => array(
                'personal',
            ),
            'topic_publish' => 1,
        );
        if ($sPeriod) {
            $aFilter['topic_date_more'] = $sPeriod;
        }
        switch ($sShowType) {
            case 'good':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.personal_good'),
                    'type'  => 'top',
                );
                break;
            case 'bad':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.personal_good'),
                    'type'  => 'down',
                );
                break;
            case 'new':
                $aFilter['topic_new']=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
                break;
            case 'newall':
                // нет доп фильтра
                break;
            case 'discussed':
                $aFilter['order']=array('t.topic_count_comment desc','t.topic_id desc');
                break;
            case 'top':
                $aFilter['order']=array('t.topic_rating desc','t.topic_id desc');
                break;
            default:
                break;
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает число новых топиков в персональных блогах
     *
     * @return int
     */
    public function GetCountTopicsPersonalNew()
    {
        $sDate=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
        $aFilter=array(
            'blog_type' => array(
                'personal',
            ),
            'topic_publish' => 1,
            'topic_new' => $sDate,
        );
        return $this->GetCountTopicsByFilter($aFilter);
    }
    /**
     * Получает список топиков по юзеру
     *
     * @param int $sUserId	ID пользователя
     * @param int $iPublish	Флаг публикации топика
     * @param int $iPage	Номер страницы
     * @param int $iPerPage	Количество элементов на страницу
     * @return array
     */
    public function GetTopicsPersonalByUser($sUserId, $iPublish, $iPage, $iPerPage)
    {
        $aFilter=array(
            'topic_publish' => $iPublish,
            'user_id' => $sUserId,
            'blog_type' => array('open','personal'),
        );
        /**
         * Если пользователь смотрит свой профиль, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $this->oUserCurrent->getId()==$sUserId) {
            $aFilter['blog_type'][]='close';
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Возвращает количество топиков которые создал юзер
     *
     * @param int $sUserId	ID пользователя
     * @param int $iPublish	Флаг публикации топика
     * @return array
     */
    public function GetCountTopicsPersonalByUser($sUserId, $iPublish)
    {
        $aFilter=array(
            'topic_publish' => $iPublish,
            'user_id' => $sUserId,
            'blog_type' => array('open','personal'),
        );
        /**
         * Если пользователь смотрит свой профиль, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent && $this->oUserCurrent->getId()==$sUserId) {
            $aFilter['blog_type'][]='close';
        }
        $s=serialize($aFilter);
        $sCacheKey = "topic_count_user_{$s}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetCountTopics($aFilter);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    "topic_update_user_{$sUserId}"
                ]
            );
        }
        return 	$data;
    }
    /**
     * Получает список топиков из указанного блога
     *
     * @param  int   $iBlogId	ID блога
     * @param  int   $iPage	Номер страницы
     * @param  int   $iPerPage	Количество элементов на страницу
     * @param  array $aAllowData	Список типов данных для подгрузки в топики
     * @param  bool  $bIdsOnly	Возвращать только ID или список объектов
     * @return array
     */
    public function GetTopicsByBlogId($iBlogId, $iPage=0, $iPerPage=0, $aAllowData=array(), $bIdsOnly=true)
    {
        $aFilter=array('blog_id'=>$iBlogId);

        if (!$aTopics = $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage, $aAllowData)) {
            return false;
        }

        return ($bIdsOnly)
            ? array_keys($aTopics['collection'])
            : $aTopics;
    }
    /**
     * Список топиков из коллективных блогов
     *
     * @param int $iPage	Номер страницы
     * @param int $iPerPage	Количество элементов на страницу
     * @param string $sShowType	Тип выборки топиков
     * @param string $sPeriod	Период в виде секунд или конкретной даты
     * @return array
     */
    public function GetTopicsCollective($iPage, $iPerPage, $sShowType='good', $sPeriod=null)
    {
        if (is_numeric($sPeriod)) {
            // количество последних секунд
            $sPeriod=date("Y-m-d H:00:00", time()-$sPeriod);
        }
        $aFilter=array(
            'blog_type' => array(
                'open',
            ),
            'topic_publish' => 1,
        );
        if ($sPeriod) {
            $aFilter['topic_date_more'] = $sPeriod;
        }
        switch ($sShowType) {
            case 'good':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.collective_good'),
                    'type'  => 'top',
                );
                break;
            case 'bad':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.collective_good'),
                    'type'  => 'down',
                );
                break;
            case 'new':
                $aFilter['topic_new']=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
                break;
            case 'newall':
                // нет доп фильтра
                break;
            case 'discussed':
                $aFilter['order']=array('t.topic_count_comment desc','t.topic_id desc');
                break;
            case 'top':
                $aFilter['order']=array('t.topic_rating desc','t.topic_id desc');
                break;
            default:
                break;
        }
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }
    /**
     * Получает число новых топиков в коллективных блогах
     *
     * @return int
     */
    public function GetCountTopicsCollectiveNew()
    {
        $sDate=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
        $aFilter=array(
            'blog_type' => array(
                'open',
            ),
            'topic_publish' => 1,
            'topic_new' => $sDate,
        );
        /**
         * Если пользователь авторизирован, то добавляем в выдачу
         * закрытые блоги в которых он состоит
         */
        if ($this->oUserCurrent) {
            $aOpenBlogs = $this->Blog_GetAccessibleBlogsByUser($this->oUserCurrent);
            if (count($aOpenBlogs)) {
                $aFilter['blog_type']['close'] = $aOpenBlogs;
            }
        }
        return $this->GetCountTopicsByFilter($aFilter);
    }
    /**
     * Получает топики по рейтингу и дате
     *
     * @param string $sDate	Дата
     * @param int $iLimit	Количество
     * @return array
     */
    public function GetTopicsRatingByDate($sDate, $iLimit=20)
    {
        /**
         * Получаем список блогов, топики которых нужно исключить из выдачи
         */
        $aCloseBlogs = ($this->oUserCurrent)
            ? $this->Blog_GetInaccessibleBlogsByUser($this->oUserCurrent)
            : $this->Blog_GetInaccessibleBlogsByUser();

        $s=serialize($aCloseBlogs);

        $sCacheKey = "topic_rating_{$sDate}_{$iLimit}_{$s}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetTopicsRatingByDate($sDate, $iLimit, $aCloseBlogs);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update'
                ]
            );
        }
        $data=$this->GetTopicsAdditionalData($data);
        return $data;
    }
    /**
     * Список топиков из блога
     *
     * @param ModuleBlog_EntityBlog $oBlog	Объект блога
     * @param int $iPage	Номер страницы
     * @param int $iPerPage	Количество элементов на страницу
     * @param string $sShowType	Тип выборки топиков
     * @param string $sPeriod	Период в виде секунд или конкретной даты
     * @return array
     */
    public function GetTopicsByBlog($oBlog, $iPage, $iPerPage, $sShowType='good', $sPeriod=null)
    {
        if (is_numeric($sPeriod)) {
            // количество последних секунд
            $sPeriod=date("Y-m-d H:00:00", time()-$sPeriod);
        }
        $aFilter=array(
            'topic_publish' => 1,
            'blog_id' => $oBlog->getId(),
        );
        if ($sPeriod) {
            $aFilter['topic_date_more'] = $sPeriod;
        }
        switch ($sShowType) {
            case 'good':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.collective_good'),
                    'type'  => 'top',
                );
                break;
            case 'bad':
                $aFilter['topic_rating']=array(
                    'value' => Config::Get('module.blog.collective_good'),
                    'type'  => 'down',
                );
                break;
            case 'new':
                $aFilter['topic_new']=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
                break;
            case 'newall':
                // нет доп фильтра
                break;
            case 'discussed':
                $aFilter['order']=array('t.topic_count_comment desc','t.topic_id desc');
                break;
            case 'top':
                $aFilter['order']=array('t.topic_rating desc','t.topic_id desc');
                break;
            default:
                break;
        }
        return $this->GetTopicsByFilter($aFilter, $iPage, $iPerPage);
    }

    /**
     * Получает число новых топиков из блога
     *
     * @param ModuleBlog_EntityBlog $oBlog Объект блога
     * @return int
     */
    public function GetCountTopicsByBlogNew($oBlog)
    {
        $sDate=date("Y-m-d H:00:00", time()-Config::Get('module.topic.new_time'));
        $aFilter=array(
            'topic_publish' => 1,
            'blog_id' => $oBlog->getId(),
            'topic_new' => $sDate,

        );
        return $this->GetCountTopicsByFilter($aFilter);
    }
    /**
     * Получает список топиков по тегу
     *
     * @param  string $sTag	Тег
     * @param  int    $iPage	Номер страницы
     * @param  int    $iPerPage	Количество элементов на страницу
     * @param  bool   $bAddAccessible Указывает на необходимость добавить в выдачу топики,
     *                                из блогов доступных пользователю. При указании false,
     *                                в выдачу будут переданы только топики из общедоступных блогов.
     * @return array
     */
    public function GetTopicsByTag($sTag, $iPage, $iPerPage, $bAddAccessible=true)
    {
        $aCloseBlogs = ($this->oUserCurrent && $bAddAccessible)
            ? $this->Blog_GetInaccessibleBlogsByUser($this->oUserCurrent)
            : $this->Blog_GetInaccessibleBlogsByUser();

        $s = serialize($aCloseBlogs);
        $sCacheKey = "topic_tag_{$sTag}_{$iPage}_{$iPerPage}_{$s}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = array('collection'=>$this->oMapperTopic->GetTopicsByTag($sTag, $aCloseBlogs, $iCount, $iPage, $iPerPage),'count'=>$iCount);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update',
                    'topic_new'
                ]
            );
        }
        $data['collection']=$this->GetTopicsAdditionalData($data['collection']);
        return $data;
    }
    /**
     * Получает список тегов топиков
     *
     * @param int $iLimit	Количество
     * @param array $aExcludeTopic	Список ID топиков для исключения
     * @return array
     */
    public function GetTopicTags($iLimit, $aExcludeTopic=array())
    {
        $s=serialize($aExcludeTopic);
        $sCacheKey = "tag_{$iLimit}_{$s}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetTopicTags($iLimit, $aExcludeTopic);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update',
                    'topic_new'
                ]
            );
        }
        return $data;
    }
    /**
     * Получает список тегов из топиков открытых блогов (open,personal)
     *
     * @param  int $iLimit	Количество
     * @param  int|null $iUserId	ID пользователя, чью теги получаем
     * @return array
     */
    public function GetOpenTopicTags($iLimit, $iUserId=null)
    {
        $sCacheKey = "tag_{$iLimit}_{$iUserId}_open";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetOpenTopicTags($iLimit, $iUserId);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    'topic_update',
                    'topic_new'
                ]
            );
        }
        return $data;
    }
    /**
     * Увеличивает у топика число комментов
     *
     * @param int $sTopicId	ID топика
     * @return bool
     */
    public function increaseTopicCountComment($sTopicId)
    {
        $this->Cache_Delete("topic_{$sTopicId}");
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_TAG,
            [
                "topic_update"
            ]
        );
        return $this->oMapperTopic->increaseTopicCountComment($sTopicId);
    }
    /**
     * Получает привязку топика к ибранному(добавлен ли топик в избранное у юзера)
     *
     * @param int $sTopicId	ID топика
     * @param int $sUserId	ID пользователя
     * @return ModuleFavourite_EntityFavourite
     */
    public function GetFavouriteTopic($sTopicId, $sUserId)
    {
        return $this->Favourite_GetFavourite($sTopicId, 'topic', $sUserId);
    }
    /**
     * Получить список избранного по списку айдишников
     *
     * @param array $aTopicId	Список ID топиков
     * @param int $sUserId	ID пользователя
     * @return array
     */
    public function GetFavouriteTopicsByArray($aTopicId, $sUserId)
    {
        return $this->Favourite_GetFavouritesByArray($aTopicId, 'topic', $sUserId);
    }
    /**
     * Добавляет топик в избранное
     *
     * @param ModuleFavourite_EntityFavourite $oFavouriteTopic	Объект избранного
     * @return bool
     */
    public function AddFavouriteTopic(ModuleFavourite_EntityFavourite $oFavouriteTopic)
    {
        return $this->Favourite_AddFavourite($oFavouriteTopic);
    }
    /**
     * Удаляет топик из избранного
     *
     * @param ModuleFavourite_EntityFavourite $oFavouriteTopic	Объект избранного
     * @return bool
     */
    public function DeleteFavouriteTopic(ModuleFavourite_EntityFavourite $oFavouriteTopic)
    {
        return $this->Favourite_DeleteFavourite($oFavouriteTopic);
    }
    /**
     * Устанавливает переданный параметр публикации таргета (топика)
     *
     * @param  int $sTopicId	ID топика
     * @param  int    $iPublish	Флаг публикации топика
     * @return bool
     */
    public function SetFavouriteTopicPublish($sTopicId, $iPublish)
    {
        return $this->Favourite_SetFavouriteTargetPublish($sTopicId, 'topic', $iPublish);
    }
    /**
     * Удаляет топики из избранного по списку
     *
     * @param  array $aTopicId	Список ID топиков
     * @return bool
     */
    public function DeleteFavouriteTopicByArrayId($aTopicId)
    {
        return $this->Favourite_DeleteFavouriteByTargetId($aTopicId, 'topic');
    }
    /**
     * Получает список тегов по первым буквам тега
     *
     * @param string $sTag	Тэг
     * @param int $iLimit	Количество
     * @return bool
     */
    public function GetTopicTagsByLike($sTag, $iLimit)
    {
        $sCacheKey = "tag_like_{$sTag}_{$iLimit}";
        if (false === ($data = $this->Cache_Get($sCacheKey))) {
            $data = $this->oMapperTopic->GetTopicTagsByLike($sTag, $iLimit);
            $this->Cache_Set(
                $data,
                $sCacheKey,
                [
                    "topic_update",
                    "topic_new"
                ]
            );
        }
        return $data;
    }
    /**
     * Обновляем/устанавливаем дату прочтения топика, если читаем его первый раз то добавляем
     *
     * @param ModuleTopic_EntityTopicRead $oTopicRead	Объект факта чтения топика
     * @return bool
     */
    public function SetTopicRead(ModuleTopic_EntityTopicRead $oTopicRead)
    {
        if ($this->GetTopicRead($oTopicRead->getTopicId(), $oTopicRead->getUserId())) {
            $this->Cache_Delete("topic_read_{$oTopicRead->getTopicId()}_{$oTopicRead->getUserId()}");
            $this->Cache_Clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                [
                    "topic_read_user_{$oTopicRead->getUserId()}"
                ]
            );
            $this->oMapperTopic->UpdateTopicRead($oTopicRead);
        } else {
            $this->Cache_Delete("topic_read_{$oTopicRead->getTopicId()}_{$oTopicRead->getUserId()}");
            $this->Cache_Clean(
                Zend_Cache::CLEANING_MODE_MATCHING_TAG,
                [
                    "topic_read_user_{$oTopicRead->getUserId()}"
                ]
            );
            $this->oMapperTopic->AddTopicRead($oTopicRead);
        }
        return true;
    }
    /**
     * Получаем дату прочтения топика юзером
     *
     * @param int $sTopicId	ID топика
     * @param int $sUserId	ID пользователя
     * @return ModuleTopic_EntityTopicRead|null
     */
    public function GetTopicRead($sTopicId, $sUserId)
    {
        $data=$this->GetTopicsReadByArray($sTopicId, $sUserId);
        if (isset($data[$sTopicId])) {
            return $data[$sTopicId];
        }
        return null;
    }
    /**
     * Удаляет записи о чтении записей по списку идентификаторов
     *
     * @param  array|int $aTopicId	Список ID топиков
     * @return bool
     */
    public function DeleteTopicReadByArrayId($aTopicId)
    {
        if (!is_array($aTopicId)) {
            $aTopicId = array($aTopicId);
        }
        return $this->oMapperTopic->DeleteTopicReadByArrayId($aTopicId);
    }
    /**
     * Получить список просмотром/чтения топиков по списку айдишников
     *
     * @param array $aTopicId	Список ID топиков
     * @param int $sUserId	ID пользователя
     * @return array
     */
    public function GetTopicsReadByArray($aTopicId, $sUserId)
    {
        if (!$aTopicId) {
            return array();
        }
        if (!is_array($aTopicId)) {
            $aTopicId=array($aTopicId);
        }
        $aTopicId=array_unique($aTopicId);
        $aTopicsRead=array();
        $aTopicIdNotNeedQuery=array();
        /**
         * Делаем мульти-запрос к кешу
         */
        $aCacheKeys=func_build_cache_keys($aTopicId, 'topic_read_', '_'.$sUserId);
        if (false !== ($data = $this->Cache_Get($aCacheKeys))) {
            /**
             * проверяем что досталось из кеша
             */
            foreach ($aCacheKeys as $sValue => $sKey) {
                if (array_key_exists($sKey, $data)) {
                    if ($data[$sKey]) {
                        $aTopicsRead[$data[$sKey]->getTopicId()]=$data[$sKey];
                    } else {
                        $aTopicIdNotNeedQuery[]=$sValue;
                    }
                }
            }
        }
        /**
         * Смотрим каких топиков не было в кеше и делаем запрос в БД
         */
        $aTopicIdNeedQuery=array_diff($aTopicId, array_keys($aTopicsRead));
        $aTopicIdNeedQuery=array_diff($aTopicIdNeedQuery, $aTopicIdNotNeedQuery);
        $aTopicIdNeedStore=$aTopicIdNeedQuery;
        if ($data = $this->oMapperTopic->GetTopicsReadByArray($aTopicIdNeedQuery, $sUserId)) {
            foreach ($data as $oTopicRead) {
                /**
                 * Добавляем к результату и сохраняем в кеш
                 */
                $aTopicsRead[$oTopicRead->getTopicId()]=$oTopicRead;
                $this->Cache_Set(
                    $oTopicRead,
                    "topic_read_{$oTopicRead->getTopicId()}_{$oTopicRead->getUserId()}",
                    []
                );
                $aTopicIdNeedStore=array_diff($aTopicIdNeedStore, array($oTopicRead->getTopicId()));
            }
        }
        /**
         * Сохраняем в кеш запросы не вернувшие результата
         */
        foreach ($aTopicIdNeedStore as $sId) {
            $this->Cache_Set(
                null,
                "topic_read_{$sId}_{$sUserId}",
                []
            );
        }
        /**
         * Сортируем результат согласно входящему массиву
         */
        $aTopicsRead=func_array_sort_by_keys($aTopicsRead, $aTopicId);
        return $aTopicsRead;
    }
    /**
     * Проверяет голосовал ли юзер за топик-вопрос
     *
     * @param int $sTopicId	ID топика
     * @param int $sUserId	ID пользователя
     * @return ModuleTopic_EntityTopicQuestionVote|null
     */
    public function GetTopicQuestionVote($sTopicId, $sUserId)
    {
        $data=$this->GetTopicsQuestionVoteByArray($sTopicId, $sUserId);
        if (isset($data[$sTopicId])) {
            return $data[$sTopicId];
        }
        return null;
    }
    /**
     * Получить список голосований в топике-опросе по списку айдишников
     *
     * @param array $aTopicId	Список ID топиков
     * @param int $sUserId	ID пользователя
     * @return array
     */
    public function GetTopicsQuestionVoteByArray($aTopicId, $sUserId)
    {
        if (!$aTopicId) {
            return array();
        }
        if (!is_array($aTopicId)) {
            $aTopicId=array($aTopicId);
        }
        $aTopicId=array_unique($aTopicId);
        $aTopicsQuestionVote=array();
        $aTopicIdNotNeedQuery=array();
        /**
         * Делаем мульти-запрос к кешу
         */
        $aCacheKeys=func_build_cache_keys($aTopicId, 'topic_question_vote_', '_'.$sUserId);
        if (false !== ($data = $this->Cache_Get($aCacheKeys))) {
            /**
             * проверяем что досталось из кеша
             */
            foreach ($aCacheKeys as $sValue => $sKey) {
                if (array_key_exists($sKey, $data)) {
                    if ($data[$sKey]) {
                        $aTopicsQuestionVote[$data[$sKey]->getTopicId()]=$data[$sKey];
                    } else {
                        $aTopicIdNotNeedQuery[]=$sValue;
                    }
                }
            }
        }
        /**
         * Смотрим каких топиков не было в кеше и делаем запрос в БД
         */
        $aTopicIdNeedQuery=array_diff($aTopicId, array_keys($aTopicsQuestionVote));
        $aTopicIdNeedQuery=array_diff($aTopicIdNeedQuery, $aTopicIdNotNeedQuery);
        $aTopicIdNeedStore=$aTopicIdNeedQuery;
        if ($data = $this->oMapperTopic->GetTopicsQuestionVoteByArray($aTopicIdNeedQuery, $sUserId)) {
            foreach ($data as $oTopicVote) {
                /**
                 * Добавляем к результату и сохраняем в кеш
                 */
                $aTopicsQuestionVote[$oTopicVote->getTopicId()]=$oTopicVote;
                $this->Cache_Set(
                    $oTopicVote,
                    "topic_question_vote_{$oTopicVote->getTopicId()}_{$oTopicVote->getVoterId()}",
                    []
                );
                $aTopicIdNeedStore=array_diff($aTopicIdNeedStore, array($oTopicVote->getTopicId()));
            }
        }
        /**
         * Сохраняем в кеш запросы не вернувшие результата
         */
        foreach ($aTopicIdNeedStore as $sId) {
            $this->Cache_Set(
                null,
                "topic_question_vote_{$sId}_{$sUserId}",
                []
            );
        }
        /**
         * Сортируем результат согласно входящему массиву
         */
        $aTopicsQuestionVote=func_array_sort_by_keys($aTopicsQuestionVote, $aTopicId);
        return $aTopicsQuestionVote;
    }
    /**
     * Добавляет факт голосования за топик-вопрос
     *
     * @param ModuleTopic_EntityTopicQuestionVote $oTopicQuestionVote	Объект голосования в топике-опросе
     * @return bool
     */
    public function AddTopicQuestionVote(ModuleTopic_EntityTopicQuestionVote $oTopicQuestionVote)
    {
        $this->Cache_Delete("topic_question_vote_{$oTopicQuestionVote->getTopicId()}_{$oTopicQuestionVote->getVoterId()}");
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_TAG,
            [
                "topic_question_vote_user_{$oTopicQuestionVote->getVoterId()}"
            ]
        );
        return $this->oMapperTopic->AddTopicQuestionVote($oTopicQuestionVote);
    }
    /**
     * Получает топик по уникальному хешу(текст топика)
     *
     * @param int $sUserId
     * @param string $sHash
     * @return ModuleTopic_EntityTopic|null
     */
    public function GetTopicUnique($sUserId, $sHash)
    {
        $sId=$this->oMapperTopic->GetTopicUnique($sUserId, $sHash);
        return $this->GetTopicById($sId);
    }
    /**
     * Рассылает уведомления о новом топике подписчикам блога
     *
     * @param ModuleBlog_EntityBlog $oBlog	Объект блога
     * @param ModuleTopic_EntityTopic $oTopic	Объект топика
     * @param ModuleUser_EntityUser $oUserTopic	Объект пользователя
     */
    public function SendNotifyTopicNew($oBlog, $oTopic, $oUserTopic)
    {
        $aBlogUsersResult=$this->Blog_GetBlogUsersByBlogId($oBlog->getId(), null, null); // нужно постранично пробегаться по всем
        $aBlogUsers=$aBlogUsersResult['collection'];
        foreach ($aBlogUsers as $oBlogUser) {
            if ($oBlogUser->getUserId()==$oUserTopic->getId()) {
                continue;
            }
            $this->Notify_SendTopicNewToSubscribeBlog($oBlogUser->getUser(), $oTopic, $oBlog, $oUserTopic);
        }
        //отправляем создателю блога
        if ($oBlog->getOwnerId()!=$oUserTopic->getId()) {
            $this->Notify_SendTopicNewToSubscribeBlog($oBlog->getOwner(), $oTopic, $oBlog, $oUserTopic);
        }
    }
    /**
     * Возвращает список последних топиков пользователя, опубликованных не более чем $iTimeLimit секунд назад
     *
     * @param  int $sUserId	ID пользователя
     * @param  int    $iTimeLimit	Число секунд
     * @param  int    $iCountLimit	Количество
     * @param  array    $aAllowData	Список типов данных для подгрузки в топики
     * @return array
     */
    public function GetLastTopicsByUserId($sUserId, $iTimeLimit, $iCountLimit=1, $aAllowData=array())
    {
        $aFilter = array(
            'topic_publish' => 1,
            'user_id' => $sUserId,
            'topic_new' => date("Y-m-d H:i:s", time()-$iTimeLimit),
        );
        $aTopics = $this->GetTopicsByFilter($aFilter, 1, $iCountLimit, $aAllowData);

        return $aTopics;
    }
    /**
     * Перемещает топики в другой блог
     *
     * @param  array  $aTopics	Список ID топиков
     * @param  int $sBlogId	ID блога
     * @return bool
     */
    public function MoveTopicsByArrayId($aTopics, $sBlogId)
    {
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_ANY_TAG,
            [
                "topic_update",
                "topic_new_blog_{$sBlogId}"
            ]
        );
        // TODO: ElasticSearch, если вдруг будет использоваться (в данный момент метод не используется)
        if ($res=$this->oMapperTopic->MoveTopicsByArrayId($aTopics, $sBlogId)) {
            // перемещаем теги
            $this->oMapperTopic->MoveTopicsTagsByArrayId($aTopics, $sBlogId);
            // меняем target parent у комментов
            $this->Comment_UpdateTargetParentByTargetId($sBlogId, 'topic', $aTopics);
            // меняем target parent у комментов в прямом эфире
            $this->Comment_UpdateTargetParentByTargetIdOnline($sBlogId, 'topic', $aTopics);
            return $res;
        }
        return false;
    }
    /**
     * Перемещает топики в другой блог
     *
     * @param  int $sBlogId	ID старого блога
     * @param  int $sBlogIdNew	ID нового блога
     * @return bool
     */
    public function MoveTopics($sBlogId, $sBlogIdNew)
    {
        $this->Cache_Clean(
            Zend_Cache::CLEANING_MODE_MATCHING_ANY_TAG,
            [
                "topic_update",
                "topic_new_blog_{$sBlogId}",
                "topic_new_blog_{$sBlogIdNew}"
            ]
        );
        if ($res=$this->oMapperTopic->MoveTopics($sBlogId, $sBlogIdNew)) {
            // Перемещаем посты в другой блог в ElasticSearch
            $this->SearchIndexer_TopicMoveToBlog($sBlogId, $sBlogIdNew);
            // перемещаем теги
            $this->oMapperTopic->MoveTopicsTags($sBlogId, $sBlogIdNew);
            // меняем target parent у комментов
            $this->Comment_MoveTargetParent($sBlogId, 'topic', $sBlogIdNew);
            // меняем target parent у комментов в прямом эфире
            $this->Comment_MoveTargetParentOnline($sBlogId, 'topic', $sBlogIdNew);
            return $res;
        }
        return false;
    }
    /**
     * Загрузка изображений при написании топика
     *
     * @param  array           $aFile	Массив $_FILES
     * @param  ModuleUser_EntityUser $oUser	Объект пользователя
     * @return string|bool
     */
    public function UploadTopicImageFile($aFile, $oUser)
    {
        if (!is_array($aFile) || !isset($aFile['tmp_name'])) {
            return ModuleImage::UPLOAD_IMAGE_ERROR_READ;
        }
        $sFileTmp=Config::Get('sys.cache.dir').func_generator();
        if (!move_uploaded_file($aFile['tmp_name'], $sFileTmp)) {
            return ModuleImage::UPLOAD_IMAGE_ERROR_FS;
        }
        $sDirUpload=$this->Image_GetIdDir($oUser->getId());
        $sExt = $this->Image_ValidateImageFile($sFileTmp);
        if (is_string($sExt)) {
            $fileMode = Config::Get('uploads.file_permission');
            $sFileImage = $this->Image_SaveFile($sFileTmp, $sDirUpload, func_generator().".".$sExt, $fileMode, true);
            return $this->Image_GetWebPath($sFileImage);
        } else {
            @unlink($sFileTmp);
            return $sExt;
        }
    }
    /**
     * Загрузка изображений по переданному URL
     *
     * @param  string          $sUrl	URL изображения
     * @param  ModuleUser_EntityUser $oUser
     * @return string|int
     */
    public function UploadTopicImageUrl($sUrl, $oUser)
    {
        $ch = curl_init();
        // Filter requests to private ranges
        $host = parse_url($sUrl, PHP_URL_HOST);
	    if (
            $host === 'localhost' || (
	            (filter_var($host, FILTER_VALIDATE_IP) !== false) && (filter_var($host, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false)
            )
        ) return ModuleImage::UPLOAD_IMAGE_ERROR;
        // Url
        curl_setopt($ch, CURLOPT_URL, $sUrl);
        // Browser/user agent
        curl_setopt($ch, CURLOPT_USERAGENT, $this->sUserAgent);
        // Automatically follow Location: headers (ie redirects)
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        // Auto set the referer in the event of a redirect
        curl_setopt($ch, CURLOPT_AUTOREFERER, true);
        // Make sure we dont get stuck in a loop
        curl_setopt($ch, CURLOPT_MAXREDIRS, 5);
        // 10s timeout time for cURL connection
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
        // allow https verification if true
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        // check common name and verify with host name
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
        // Set SSL version
        curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_DEFAULT);
        // Return data to variable
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        // Set buffer to 100k
        curl_setopt($ch, CURLOPT_BUFFERSIZE, 1024*100);
        // Protocol whitelist
        curl_setopt($ch, CURLOPT_PROTOCOLS, CURLPROTO_HTTP | CURLPROTO_HTTPS);
        // Manual progress handling
        curl_setopt($ch, CURLOPT_NOPROGRESS, false);
        // Abort upload too large files
        curl_setopt($ch, CURLOPT_PROGRESSFUNCTION, function (
            $DownloadSize,
            $Downloaded,
            $UploadSize,
            $Uploaded
        ) {
            return ($Downloaded > (Config::Get('module.image.max_size') * 1024)) ? 1 : 0;
        });
        $data = curl_exec($ch);
        $error = curl_error($ch);
        if ($error) {
            if (curl_errno($ch) == CURLE_ABORTED_BY_CALLBACK) {
                return ModuleImage::UPLOAD_IMAGE_ERROR_SIZE;
            }
            return ModuleImage::UPLOAD_IMAGE_ERROR_READ;
        }
        curl_close($ch);
        if (!$data) {
            return ModuleImage::UPLOAD_IMAGE_ERROR_NETWORK;
        }
        /**
         * Создаем tmp-файл, для временного хранения изображения
         */
        $sFileTmp=Config::Get('sys.cache.dir').func_generator();
        $fp=fopen($sFileTmp, 'w');
        if (!fwrite($fp, $data)) {
            return ModuleImage::UPLOAD_IMAGE_ERROR_FS;
        }
        fclose($fp);

        $sDirUpload=$this->Image_GetIdDir($oUser->getId());
        $sExt = $this->Image_ValidateImageFile($sFileTmp);
        if (is_string($sExt)) {
            $fileMode = Config::Get('uploads.file_permission');
            $sFileImage = $this->Image_SaveFile($sFileTmp, $sDirUpload, func_generator().".".$sExt, $fileMode, true);
            return $this->Image_GetWebPath($sFileImage);
        } else {
            @unlink($sFileTmp);
            return $sExt;
        }
    }
    /**
     * Пересчитывает счетчик избранных топиков
     *
     * @return bool
     */
    public function RecalculateFavourite()
    {
        return $this->oMapperTopic->RecalculateFavourite();
    }
    /**
     * Пересчитывает счетчики голосований
     *
     * @return bool
     */
    public function RecalculateVote()
    {
        return $this->oMapperTopic->RecalculateVote();
    }
    /**
     * Алиас для корректной работы ORM
     *
     * @param array $aTopocId	Список ID топиков
     * @return array
     */
    public function GetTopicItemsByArrayId($aTopocId)
    {
        return $this->GetTopicsByArrayId($aTopocId);
    }
}
