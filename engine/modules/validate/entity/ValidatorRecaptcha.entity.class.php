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
 * Валидатор гугл-рекаптчи
 *
 * @package engine.modules.validate
 * @since 1.0
 */
class ModuleValidate_EntityValidatorRecaptcha extends ModuleValidate_EntityValidator {
    /**
     * Запуск валидации
     *
     * @param mixed $sValue	Данные для валидации
     *
     * @return bool|string
     */
    public function validate($sValue) {
        $secret = Config::Get('recaptcha.secret');
        $url = Config::Get('recaptcha.url');

        $response = json_decode(file_get_contents($url."?secret=".$secret."&response=".$sValue), true);

        if ($response['success'] != false) {
            return true;
        } else {
            return gettext('recaptcha_error');
        }
    }
}
?>