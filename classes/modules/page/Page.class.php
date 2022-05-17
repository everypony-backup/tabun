<?php

/**
 * LiveStreet CMS
 * Copyright © 2013 OOO "ЛС-СОФТ"
 *
 * ------------------------------------------------------
 *
 * Official site: www.livestreetcms.com
 * Contact e-mail: office@livestreetcms.com
 *
 * GNU General Public License, version 2:
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
 *
 * ------------------------------------------------------
 *
 * @link http://www.livestreetcms.com
 * @copyright 2013 OOO "ЛС-СОФТ"
 * @author Maxim Mzhelskiy <rus.engine@gmail.com>
 *
 */
class ModulePage extends ModuleORM
{
    /**
     * Пересобирает полные URL дочерних страниц
     *
     * @param      $oPageStart
     * @param bool $bStart
     */
    public function RebuildPageUrlFull($oPageStart, $bStart = true)
    {
        static $aRebuildIds;
        if ($bStart) {
            $aRebuildIds = array();
        }

        if (is_null($oPageStart->getId())) {
            $aPages = $this->GetPageItemsByFilter(array('#where' => array('pid is null' => array())));
        } else {
            $aPages = $this->GetPageItemsByFilter(array('pid' => $oPageStart->getId()));
        }

        foreach ($aPages as $oPage) {
            if ($oPage->getId() == $oPageStart->getId()) {
                continue;
            }
            if (in_array($oPage->getId(), $aRebuildIds)) {
                continue;
            }
            $aRebuildIds[] = $oPage->getId();
            $oPage->setUrlFull($oPageStart->getUrlFull() . '/' . $oPage->getUrl());
            $oPage->Update();
            $this->RebuildPageUrlFull($oPage, false);
        }
    }

    public function GetNextPageBySort($iSort, $sPid, $sWay)
    {
        $aFilter = array();
        if (is_null($sPid)) {
            $aFilter['#where'] = array('pid is null' => array());
        } else {
            $aFilter['pid'] = $sPid;
        }

        if ($sWay == 'up') {
            $aFilter['sort >'] = $iSort;
            $aFilter['#order'] = array('sort' => 'asc');
        } else {
            $aFilter['sort <'] = $iSort;
            $aFilter['#order'] = array('sort' => 'desc');
        }
        return $this->GetPageByFilter($aFilter);
    }
}
