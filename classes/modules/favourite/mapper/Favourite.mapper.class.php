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
 * Объект маппера для работы с БД
 *
 * @package modules.favourite
 * @since 1.0
 */
class ModuleFavourite_MapperFavourite extends Mapper
{
    /**
     * Добавляет таргет в избранное
     *
     * @param  ModuleFavourite_EntityFavourite $oFavourite Объект избранного
     * @return bool
     */
    public function AddFavourite(ModuleFavourite_EntityFavourite $oFavourite)
    {
        $sql = "
			INSERT INTO ".Config::Get('db.table.favourite')." 
				( target_id, target_type, user_id, tags )
			VALUES
				(?d, ?, ?d, ?)
		";
        if ($this->oDb->query(
            $sql,
            $oFavourite->getTargetId(),
            $oFavourite->getTargetType(),
            $oFavourite->getUserId(),
            $oFavourite->getTags()
        )===0) {
            return true;
        }
        return false;
    }
    /**
     * Обновляет запись об избранном
     *
     * @param ModuleFavourite_EntityFavourite $oFavourite	Объект избранного
     * @return bool
     */
    public function UpdateFavourite(ModuleFavourite_EntityFavourite $oFavourite)
    {
        $sql = "
			UPDATE ".Config::Get('db.table.favourite')."
				SET tags = ? WHERE user_id = ?d and target_id = ?d and target_type = ?
		";
        if ($this->oDb->query(
            $sql,
            $oFavourite->getTags(),
            $oFavourite->getUserId(),
            $oFavourite->getTargetId(),
            $oFavourite->getTargetType()
        )!==false) {
            return true;
        }
        return false;
    }
    /**
     * Получить список избранного по списку айдишников
     *
     * @param  array  $aArrayId	Список ID владельцев
     * @param  string $sTargetType	Тип владельца
     * @param  int $sUserId	ID пользователя
     * @return array
     */
    public function GetFavouritesByArray($aArrayId, $sTargetType, $sUserId)
    {
        if (!is_array($aArrayId) or count($aArrayId)==0) {
            return array();
        }
        $sql = "SELECT *							 
				FROM ".Config::Get('db.table.favourite')."
				WHERE 			
					user_id = ?d
					AND		
					target_id IN(?a) 	
					AND
					target_type = ? ";
        $aFavourites=array();
        if ($aRows=$this->oDb->select($sql, $sUserId, $aArrayId, $sTargetType)) {
            foreach ($aRows as $aRow) {
                $aFavourites[]=Engine::GetEntity('Favourite', $aRow);
            }
        }
        return $aFavourites;
    }
    /**
     * Удаляет таргет из избранного
     *
     * @param  ModuleFavourite_EntityFavourite $oFavourite	Объект избранного
     * @return bool
     */
    public function DeleteFavourite(ModuleFavourite_EntityFavourite $oFavourite)
    {
        $sql = "
			DELETE FROM ".Config::Get('db.table.favourite')." 
			WHERE
				user_id = ?d
			AND
				target_id = ?d
			AND 
				target_type = ?				
		";
        if ($this->oDb->query(
            $sql,
            $oFavourite->getUserId(),
            $oFavourite->getTargetId(),
            $oFavourite->getTargetType()
        )) {
            return true;
        }
        return false;
    }
    /**
     * Удаляет теги
     *
     * @param ModuleFavourite_EntityFavourite $oFavourite	Объект избранного
     * @return bool
     */
    public function DeleteTags($oFavourite)
    {
        $sql = "
			DELETE FROM ".Config::Get('db.table.favourite_tag')."
			WHERE
				user_id = ?d
				AND
				target_type = ?
				AND
				target_id = ?d
		";
        if ($this->oDb->query(
            $sql,
            $oFavourite->getUserId(),
            $oFavourite->getTargetType(),
            $oFavourite->getTargetId()
        )) {
            return true;
        }
        return false;
    }
    /**
     * Добавляет тег
     *
     * @param ModuleFavourite_EntityTag $oTag	Объект тега
     * @return bool
     */
    public function AddTag($oTag)
    {
        $sql = "
			INSERT INTO ".Config::Get('db.table.favourite_tag')."
				SET target_id = ?d, target_type = ?, user_id = ?d, is_user = ?d, text =?
		";
        if ($this->oDb->query(
            $sql,
            $oTag->getTargetId(),
            $oTag->getTargetType(),
            $oTag->getUserId(),
            $oTag->getIsUser(),
            $oTag->getText()
        )===0) {
            return true;
        }
        return false;
    }
    /**
     * Меняет параметры публикации у таргета
     *
     * @param  array|int $aTargetId	Список ID владельцев
     * @param  string $sTargetType 	Тип владельца
     * @param  int $iPublish	Флаг публикации
     * @return bool
     */
    public function SetFavouriteTargetPublish($aTargetId, $sTargetType, $iPublish)
    {
        $sql = "
			UPDATE ".Config::Get('db.table.favourite')." 
			SET 
				target_publish = ?d
			WHERE				
				target_id IN(?a)
			AND
				target_type = ?				
		";
        return $this->oDb->query($sql, $iPublish, $aTargetId, $sTargetType);
    }
    /**
     * Получает список таргетов из избранного, исключая те таргеты, в блогах которых юзер забанен или не состоит
     *
     * @param  int $sUserId	ID пользователя
     * @param  string $sTargetType	Тип владельца: topic, comment, talk
     * @param  int $iCount	Возвращает количество элементов
     * @param  int $iCurrPage	Номер страницы
     * @param  int $iPerPage	Количество элементов на страницу
     * @param  array $aExcludeTarget	Список ID владельцев для исклчения
     * @return array
     */
    public function GetFavouritesByUserId($sUserId, $sTargetType, &$iCount, $iCurrPage, $iPerPage, $aExcludeTarget=array())
    {
        if ($sTargetType == "comment") {
            $sql = "
            SELECT f.target_id
            FROM (".Config::Get('db.table.favourite')." AS f,
                 ".Config::Get('db.table.comment')." AS c,
                 ".Config::Get('db.table.topic')." AS t,
                 ".Config::Get('db.table.blog')." AS b)
            LEFT JOIN ".Config::Get('db.table.blog_user')." AS u
                ON u.blog_id = b.blog_id AND u.user_id = f.user_id
            WHERE
                    f.user_id = ?
                AND
                    f.target_publish = 1
                AND
                    f.target_type = ?
                AND
                    f.target_id = c.comment_id
                AND 
                    c.target_id = t.topic_id
                AND 
                    t.blog_id = b.blog_id  
                AND 
                (
                    b.blog_type IN ('open', 'personal')
                OR
                    u.user_role >= ".ModuleBlog::BLOG_USER_ROLE_GUEST."
                OR
                    b.user_owner_id = f.user_id
                )
                { AND target_id NOT IN (?a) }
            ORDER BY target_id DESC
            LIMIT ?d, ?d ";
        } elseif ($sTargetType == 'topic')
        {
            $sql = "
            SELECT f.target_id
            FROM (".Config::Get('db.table.favourite')." AS f,
                 ".Config::Get('db.table.topic')." AS t,
                 ".Config::Get('db.table.blog')." AS b)
                LEFT JOIN ".Config::Get('db.table.blog_user')." AS u
                    ON u.blog_id = b.blog_id AND u.user_id = f.user_id
            WHERE 
                    f.user_id = ?
                AND
                    f.target_publish = 1
                AND
                    f.target_type = ?
                AND
                    f.target_id = t.topic_id
                AND 
                    t.blog_id = b.blog_id
                AND
                (
                    b.blog_type IN ('open', 'personal')
                OR
                    u.user_role >= ".ModuleBlog::BLOG_USER_ROLE_GUEST."
                OR
                    b.user_owner_id = f.user_id
                )
                { AND target_id NOT IN (?a) }
            ORDER BY target_id DESC
            LIMIT ?d, ?d ";
        }
        else {
            $sql = "
			SELECT target_id
			FROM " . Config::Get('db.table.favourite') . "
			WHERE
					user_id = ?
				AND
					target_publish = 1
				AND
					target_type = ?
				{ AND target_id NOT IN (?a) }
            ORDER BY target_id DESC
            LIMIT ?d, ?d ";
        }

        $aFavourites=array();
        if ($aRows=$this->oDb->selectPage(
            $iCount,
            $sql,
            $sUserId,
            $sTargetType,
            (count($aExcludeTarget) ? $aExcludeTarget : DBSIMPLE_SKIP),
            ($iCurrPage-1)*$iPerPage,
            $iPerPage
        )) {
            foreach ($aRows as $aFavourite) {
                $aFavourites[]=$aFavourite['target_id'];
            }
        }
        return $aFavourites;
    }
    /**
     * Возвращает число таргетов определенного типа в избранном по ID пользователя,
     * вычитая те таргеты, которые находятся в блогах, в которых юзер забанен или не состоит
     *
     * @param  int $sUserId	ID пользователя
     * @param  string $sTargetType	Тип владельца
     * @param  array $aExcludeTarget	Список ID владельцев для исклчения
     * @return array
     */
    public function GetCountFavouritesByUserId($sUserId, $sTargetType, $aExcludeTarget)
    {
        $sql = "SELECT 		
					count(target_id) as count									
				FROM 
					".Config::Get('db.table.favourite')."								
				WHERE 
						user_id = ?
					AND
						target_publish = 1
					AND
						target_type = ?
					{ AND target_id NOT IN (?a) }		
					;";
        return ($aRow=$this->oDb->selectRow(
            $sql,
            $sUserId,
            $sTargetType,
            (count($aExcludeTarget) ? $aExcludeTarget : DBSIMPLE_SKIP)
        )
        )
            ? $aRow['count']
            : false;
    }
    /**
     * Получает список комментариев к записям открытых блогов
     * из избранного указанного пользователя
     *
     * @param  int $sUserId	ID пользователя
     * @param  int $iCount	Возвращает количество элементов
     * @param  int $iCurrPage	Номер страницы
     * @param  int $iPerPage	Количество элементов на страницу
     * @return array
     */
    public function GetFavouriteOpenCommentsByUserId($sUserId, &$iCount, $iCurrPage, $iPerPage)
    {
        $sql = "
			SELECT f.target_id										
			FROM 
				".Config::Get('db.table.favourite')." AS f,
				".Config::Get('db.table.comment')." AS c,
				".Config::Get('db.table.topic')." AS t,
				".Config::Get('db.table.blog')." AS b	
			WHERE 
					f.user_id = ?d
				AND
					f.target_publish = 1
				AND
					f.target_type = 'comment'
				AND
					f.target_id = c.comment_id
				AND 
					c.target_id = t.topic_id
				AND 
					t.blog_id = b.blog_id
				AND 
					b.blog_type IN ('open', 'personal')	
            ORDER BY target_id DESC	
            LIMIT ?d, ?d ";

        $aFavourites=array();
        if ($aRows=$this->oDb->selectPage(
            $iCount,
            $sql,
            $sUserId,
            ($iCurrPage-1)*$iPerPage,
            $iPerPage
        )) {
            foreach ($aRows as $aFavourite) {
                $aFavourites[]=$aFavourite['target_id'];
            }
        }
        return $aFavourites;
    }
    /**
     * Возвращает число комментариев к открытым блогам в избранном по ID пользователя
     *
     * @param  int $sUserId	ID пользователя
     * @return array
     */
    public function GetCountFavouriteOpenCommentsByUserId($sUserId)
    {
        $sql = "SELECT 		
					count(f.target_id) as count									
				FROM 
					".Config::Get('db.table.favourite')." AS f,
					".Config::Get('db.table.comment')." AS c,
					".Config::Get('db.table.topic')." AS t,
					".Config::Get('db.table.blog')." AS b	
				WHERE 
						f.user_id = ?d
					AND
						f.target_publish = 1
					AND
						f.target_type = 'comment'
					AND
						f.target_id = c.comment_id
					AND 
						c.target_id = t.topic_id
					AND 
						t.blog_id = b.blog_id
					AND 
						b.blog_type IN ('open', 'personal')		
					;";
        return ($aRow=$this->oDb->selectRow($sql, $sUserId))
            ? $aRow['count']
            : false;
    }
    /**
     * Получает список топиков из открытых блогов
     * из избранного указанного пользователя
     *
     * @param  int $sUserId	ID пользователя
     * @param  int $iCount	Возвращает количество элементов
     * @param  int $iCurrPage	Номер страницы
     * @param  int $iPerPage	Количество элементов на страницу
     * @return array
     */
    public function GetFavouriteOpenTopicsByUserId($sUserId, &$iCount, $iCurrPage, $iPerPage)
    {
        $sql = "
			SELECT f.target_id										
			FROM 
				".Config::Get('db.table.favourite')." AS f,
				".Config::Get('db.table.topic')." AS t,
				".Config::Get('db.table.blog')." AS b	
			WHERE 
					f.user_id = ?d
				AND
					f.target_publish = 1
				AND
					f.target_type = 'topic'
				AND
					f.target_id = t.topic_id
				AND 
					t.blog_id = b.blog_id
				AND 
					b.blog_type IN ('open', 'personal')	
            ORDER BY target_id DESC	
            LIMIT ?d, ?d ";

        $aFavourites=array();
        if ($aRows=$this->oDb->selectPage(
            $iCount,
            $sql,
            $sUserId,
            ($iCurrPage-1)*$iPerPage,
            $iPerPage
        )) {
            foreach ($aRows as $aFavourite) {
                $aFavourites[]=$aFavourite['target_id'];
            }
        }
        return $aFavourites;
    }
    /**
     * Возвращает число топиков в открытых блогах из избранного по ID пользователя
     *
     * @param  string $sUserId	ID пользователя
     * @return array
     */
    public function GetCountFavouriteOpenTopicsByUserId($sUserId)
    {
        $sql = "SELECT 		
					count(f.target_id) as count									
				FROM 
					".Config::Get('db.table.favourite')." AS f,
					".Config::Get('db.table.topic')." AS t,
					".Config::Get('db.table.blog')." AS b	
				WHERE 
						f.user_id = ?d
					AND
						f.target_publish = 1
					AND
						f.target_type = 'topic'
					AND
						f.target_id = t.topic_id
					AND 
						t.blog_id = b.blog_id
					AND 
						b.blog_type IN ('open', 'personal')		
					;";
        return ($aRow=$this->oDb->selectRow($sql, $sUserId))
            ? $aRow['count']
            : false;
    }
    /**
     * Удаляет избранное по списку идентификаторов таргетов
     *
     * @param  array|int $aTargetId	Список ID владельцев
     * @param  string    $sTargetType	Тип владельца
     * @return bool
     */
    public function DeleteFavouriteByTargetId($aTargetId, $sTargetType)
    {
        $sql = "
			DELETE FROM ".Config::Get('db.table.favourite')." 
			WHERE 
				target_id IN(?a) 
				AND 
				target_type = ? ";
        if ($this->oDb->query($sql, $aTargetId, $sTargetType)) {
            return true;
        }
        return false;
    }
    /**
     * Удаление тегов по таргету
     *
     * @param array $aTargetId	Список ID владельцев
     * @param string $sTargetType	Тип владельца
     * @return bool
     */
    public function DeleteTagByTarget($aTargetId, $sTargetType)
    {
        $sql = "
			DELETE FROM ".Config::Get('db.table.favourite_tag')."
			WHERE
				target_type = ?
				AND
				target_id IN(?a)
				";
        if ($this->oDb->query($sql, $sTargetType, $aTargetId)) {
            return true;
        }
        return false;
    }
    /**
     * Возвращает наиболее часто используемые теги
     *
     * @param int $iUserId	ID пользователя
     * @param string $sTargetType	Тип владельца
     * @param bool $bIsUser	Возвращает все теги ли только пользовательские
     * @param int $iLimit	Количество элементов
     * @return array
     */
    public function GetGroupTags($iUserId, $sTargetType, $bIsUser, $iLimit)
    {
        $sql = "SELECT
			text,
			count(text)	as count
			FROM
				".Config::Get('db.table.favourite_tag')."
			WHERE
				1=1
				{AND user_id = ?d }
				{AND target_type = ? }
				{AND is_user = ?d }
			GROUP BY
				text
			ORDER BY
				count desc
			LIMIT 0, ?d
				";
        $aReturn=array();
        $aReturnSort=array();
        if ($aRows=$this->oDb->select($sql, $iUserId, $sTargetType, is_null($bIsUser) ? DBSIMPLE_SKIP : $bIsUser, $iLimit)) {
            foreach ($aRows as $aRow) {
                $aReturn[mb_strtolower($aRow['text'], 'UTF-8')]=$aRow;
            }
            ksort($aReturn);
            foreach ($aReturn as $aRow) {
                $aReturnSort[]=Engine::GetEntity('ModuleFavourite_EntityTag', $aRow);
            }
        }
        return $aReturnSort;
    }
    /**
     * Возвращает список тегов по фильтру
     *
     * @param array $aFilter	Фильтр
     * @param array $aOrder	Сортировка
     * @param int $iCount	Возвращает количество элементов
     * @param int $iCurrPage	Номер страницы
     * @param int $iPerPage	Количество элементов на страницу
     * @return array
     */
    public function GetTags($aFilter, $aOrder, &$iCount, $iCurrPage, $iPerPage)
    {
        $aOrderAllow=array('target_id','user_id','is_user');
        $sOrder='';
        foreach ($aOrder as $key=>$value) {
            if (!in_array($key, $aOrderAllow)) {
                unset($aOrder[$key]);
            } elseif (in_array($value, array('asc','desc'))) {
                $sOrder.=" {$key} {$value},";
            }
        }
        $sOrder=trim($sOrder, ',');
        if ($sOrder=='') {
            $sOrder=' target_id desc ';
        }

        $sql = "SELECT
                    tag.*
                FROM ".Config::Get('db.table.favourite_tag')." AS tag
                    LEFT JOIN ".Config::Get('db.table.favourite')." AS f
                        ON tag.target_type = f.target_type AND tag.target_id = f.target_id AND tag.user_id = f.user_id
                    LEFT JOIN ".Config::Get('db.table.topic')." AS t
                        ON f.target_id = t.topic_id
                    LEFT JOIN ".Config::Get('db.table.blog')." AS b
                        ON b.blog_id = t.blog_id
                    LEFT JOIN ".Config::Get('db.table.blog_user')." AS u
                        ON u.blog_id = b.blog_id AND u.user_id = f.user_id
                WHERE
                    1 = 1
                    { AND tag.user_id = ?d }
                    { AND tag.target_type = ? }
                    { AND tag.target_id = ?d }
                    { AND tag.is_user = ?d }
                    { AND tag.text = ? }
                    { AND f.target_publish = 1 }
                    { AND
                    (
                        b.blog_type IN ('open', 'personal')
                    OR
                        u.user_role >= ".ModuleBlog::BLOG_USER_ROLE_GUEST."
                    OR
                        b.user_owner_id = f.user_id
                    ) }
                ORDER by {$sOrder}
                LIMIT ?d, ?d ;
                    ";
        $aResult=array();
        if ($aRows=$this->oDb->selectPage(
            $iCount,
            $sql,
                                          isset($aFilter['user_id']) ? $aFilter['user_id'] : DBSIMPLE_SKIP,
                                          isset($aFilter['target_type']) ? $aFilter['target_type'] : DBSIMPLE_SKIP,
                                          isset($aFilter['target_id']) ? $aFilter['target_id'] : DBSIMPLE_SKIP,
                                          isset($aFilter['is_user']) ? $aFilter['is_user'] : DBSIMPLE_SKIP,
                                          isset($aFilter['text']) ? $aFilter['text'] : DBSIMPLE_SKIP,
                                          ($iCurrPage-1)*$iPerPage,
            $iPerPage
        )) {
            foreach ($aRows as $aRow) {
                $aResult[]=Engine::GetEntity('ModuleFavourite_EntityTag', $aRow);
            }
        }
        return $aResult;
    }
}
