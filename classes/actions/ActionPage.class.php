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
        $this->AddEventPreg('/^edit$/i', '/^.+$/i', 'EventEditPage');
        $this->AddEventPreg('/^.+$/i', 'EventShowPage');
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
            $this->Viewer_AddBlock(
                'right',
                'structure',
                array('plugin' => Plugin::GetPluginCode($this), 'current_page' => $oPage)
            );
        }
        /**
         * Устанавливаем шаблон для вывода
         */
        $this->SetTemplateAction('view');
    }

    /**
     * Проверка полей формы
     *
     * @return bool
     */
    protected function checkPageFields($oPage)
    {
        $this->Security_ValidateSendForm();

        $bOk=true;
        /**
         * Валидируем страницу
         */
        if (!$oPage->_Validate()) {
            $this->Message_AddError($oPage->_getValidateError(), $this->Lang_Get('error'));
            $bOk=false;
        }

        return $bOk;
    }
    /**
     * Обработка редактирования страницы
     *
     * @param ModulePage_EntityPage $oPage
     * @return mixed
     */
    protected function SubmitEdit($oPage)
    {
        $oPage->setTitle(strip_tags(getRequestStr('page_title')));
        $oPage->setText(getRequestStr('page_text'));
        /**
         * Проверка корректности полей формы
         */
        if (!$this->checkPageFields($oPage)) {
            return false;
        }
        /**
         * Сохраняем страницу
         */
        if ($this->Page_UpdatePage($oPage)) {
            Router::Location($oPage->getWebUrl());
        } else {
            $this->Message_AddErrorSingle($this->Lang_Get('system_error'));
            return Router::Action('error');
        }
    }
    /**
     * Редактирование страницы
     */
    protected function EventEditPage()
    {
        /**
         * Составляем полный URL страницы для поиска по нему в БД
         */
        $sUrlFull=$this->GetParam(0);
        /**
         * Ищем страничку в БД
         */
        if (!($oPage = $this->Page_GetPageByFilter(array('url_full' => $sUrlFull, 'active' => 1)))) {
            return $this->EventNotFound();
        }
        /**
         * Если нет прав доступа - перекидываем на 404 страницу
         */
        if (!$this->User_IsAuthorization() or !$oUserCurrent=$this->User_GetUserCurrent() or !$oUserCurrent->isAdministrator()) {
            return parent::EventNotFound();
        }

        /**
         * Заполняем HTML теги
         */
        $this->Viewer_Assign('oPage', $oPage);
        /**
         * Устанавливаем шаблон для вывода
         */
        $this->SetTemplateAction('edit');
        /**
         * Проверяем отправлена ли форма с данными
         */
        if (isset($_REQUEST['submit_page_publish'])) {
            /**
             * Обрабатываем отправку формы
             */
            return $this->SubmitEdit($oPage);
        } else {
            /**
             * Заполняем поля формы для редактирования
             * Только перед отправкой формы!
             */
            $_REQUEST['page_title']=$oPage->getTitle();
            $_REQUEST['page_text']=$oPage->getText();
        }
    }
}
