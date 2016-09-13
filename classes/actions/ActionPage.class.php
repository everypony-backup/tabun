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
class ActionPage extends Action
{

    public function Init()
    {
        /**
         * Получаем текущего пользователя
         */
        $this->oUserCurrent = $this->User_GetUserCurrent();
    }

    /**
     * Регистрируем евенты
     *
     */
    protected function RegisterEvent()
    {
        $this->AddEventPreg('/^[\w\-\_]*$/i', 'EventShowPage');
    }

    /**
     * Обработка детального вывода страницы
     */
    protected function EventShowPage()
    {
        /**
         * Составляем полный URL страницы для поиска по нему в БД
         */
        $sUrlFull = join('/', $this->GetParams());
        if ($sUrlFull != '') {
            $sUrlFull = $this->sCurrentEvent . '/' . $sUrlFull;
        } else {
            $sUrlFull = $this->sCurrentEvent;
        }
        /**
         * Ищем страничку в БД
         */
        if (!($oPage = $this->Page_GetPageByFilter(array('url_full' => $sUrlFull, 'active' => 1)))) {
            return $this->EventNotFound();
        }
        /**
         * Заполняем HTML теги и SEO
         */
        $this->Viewer_AddHtmlTitle($oPage->getTitle());
        if ($oPage->getSeoKeywords()) {
            $this->Viewer_SetHtmlKeywords($oPage->getSeoKeywords());
        }
        if ($oPage->getSeoDescription()) {
            $this->Viewer_SetHtmlDescription($oPage->getSeoDescription());
        }

        $this->Viewer_Assign('oPage', $oPage);
        $this->Viewer_Assign('sMenuHeadItemSelect', 'page_' . $oPage->getUrl());
        /**
         * Добавляем блок
         */
        if (Config::Get('page.show_block_structure')) {
            $this->Viewer_AddBlock('right', 'structure',
                array('plugin' => Plugin::GetPluginCode($this), 'current_page' => $oPage));
        }
        /**
         * Устанавливаем шаблон для вывода
         */
        $this->SetTemplateAction('view');
    }
}