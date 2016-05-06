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

require_once(Config::Get('path.root.engine').'/lib/external/Jevix/jevix.class.php');

/**
 * Модуль обработки текста на основе типографа Jevix
 * Позволяет вырезать из текста лишние HTML теги и предотвращает различные попытки внедрить в текст JavaScript
 * <pre>
 * $sText=$this->Text_Parser($sTestSource);
 * </pre>
 * Настройки парсинга находятся в конфиге /config/jevix.php
 *
 * @package engine.modules
 * @since 1.0
 */
class ModuleText extends Module {
	/**
	 * Объект типографа
	 *
	 * @var Jevix
	 */
	protected $oJevix;

	/**
	 * Инициализация модуля
	 *
	 */
	public function Init() {
		/**
		 * Создаем объект типографа и запускаем его конфигурацию
		 */
		$this->oJevix = new Jevix();
		$this->JevixConfig();
	}
	/**
	 * Конфигурирует типограф
	 *
	 */
	protected function JevixConfig() {
		// загружаем конфиг
		$this->LoadJevixConfig();
	}
	/**
	 * Загружает конфиг Jevix'а
	 *
	 * @param string $sType Тип конфига
	 * @param bool $bClear	Очищать предыдущий конфиг или нет
	 */
	public function LoadJevixConfig($sType='default',$bClear=true) {
		if ($bClear) {
			$this->oJevix->tagsRules=array();
		}
		$aConfig=Config::Get('jevix.'.$sType);
		if (is_array($aConfig)) {
			foreach ($aConfig as $sMethod => $aExec) {
				foreach ($aExec as $aParams) {
					if (in_array(strtolower($sMethod),array_map("strtolower",array('cfgSetTagCallbackFull','cfgSetTagCallback')))) {
						if (isset($aParams[1][0]) and $aParams[1][0]=='_this_') {
							$aParams[1][0]=$this;
						}
					}
					call_user_func_array(array($this->oJevix,$sMethod), $aParams);
				}
			}
			/**
			 * Хардкодим некоторые параметры
			 */
			unset($this->oJevix->entities1['&']); // разрешаем в параметрах символ &
			if (Config::Get('view.noindex') and isset($this->oJevix->tagsRules['a'])) {
				$this->oJevix->cfgSetTagParamDefault('a','rel','nofollow',true);
			}
		}
	}
	/**
	 * Возвращает объект Jevix
	 *
	 * @return Jevix
	 */
	public function GetJevix() {
		return $this->oJevix;
	}
	/**
	 * Парсинг текста с помощью Jevix
	 *
	 * @param string $sText	Исходный текст
	 * @param array $aError	Возвращает список возникших ошибок
	 * @return string
	 */
	public function JevixParser($sText,&$aError=null) {
		// Если конфиг пустой, то загружаем его
		if (!count($this->oJevix->tagsRules)) {
			$this->LoadJevixConfig();
		}
		$sResult=$this->oJevix->parse($sText,$aError);
		return $sResult;
	}
	/**
	 * Парсинг текста на предмет видео
	 * Находит теги <pre><video></video></pre> и реобразовываетих в видео
	 *
	 * @param string $sText	Исходный текст
	 * @return string
	 */
	public function VideoParser($sText) {
		/**
		 * youtube.com
		 */

		$y_video_pattern = "/<video>(?:https?:\/\/)?(?:(?:www\.))?(?:youtube\.com\/\S*(?:(?:\/e(?:mbed))?\/|watch\?(?:\S*?&?v\=))|youtu\.be\/)([a-zA-Z0-9_-]{6,11})(?:\?(?:t|start)=((?:[0-9]{1,10}[hms]?){1,4}))?<\/video>/i";
		preg_match($y_video_pattern, $sText, $output_array);

		if (count($output_array) == 2) {
			$y_tpl = '<iframe width="560" height="310" src="//www.youtube.com/embed/$1" frameborder="0" allowfullscreen></iframe>';
			$sText = preg_replace($y_video_pattern, $y_tpl, $sText);
		} elseif (count($output_array) == 3 ) {
			$y_tpl = '<iframe width="560" height="310" src="//www.youtube.com/embed/$1?start=$2" frameborder="0" allowfullscreen></iframe>';
			$sText = preg_replace($y_video_pattern, $y_tpl, $sText);
		}
		/**
		 * vimeo.com
		*/
		$v_video_pattern = '/<video>(?:https?:\/\/)?(?:www\.)?vimeo\.com\/(\d+).*<\/video>/i';
		$v_tpl = '<iframe src="//player.vimeo.com/video/$1" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>';
		$sText = preg_replace($v_video_pattern, $v_tpl, $sText);

		/**
		* dailymotion.com
		*/

		$d_video_pattern = "/(<video>)(?:https?:\/\/)?(?:www\.)?dailymotion.com\/video\/(\w+)(?:_.*?)?(<\/video>)/ui";
		$d_video_pattern_short = "/(<video>)(?:https?:\/\/)?(?:www\.)?dai.ly\/(\w+)(?:_.*?)?(<\/video>)/ui";
		$d_tpl = '<iframe frameborder="0" width="560" height="315" src="//www.dailymotion.com/embed/video/$2" allowfullscreen></iframe>';
		$sText = preg_replace($d_video_pattern, $d_tpl, $sText);
		$sText = preg_replace($d_video_pattern_short, $d_tpl, $sText);

		/**
		* coub.com
		*/
		$c_video_pattern = "/(<video>)(?:https?:\/\/)?(?:www\.)?coub.com\/view\/(\w+)(<\/video>)/ui";
		$c_tpl = '<iframe src="//coub.com/embed/$2?muted=false&autostart=false&originalSize=false&hideTopBar=true&noSiteButtons=true&startWithHD=false" allowfullscreen="true" frameborder="0" width="400" height="400"></iframe>';
		$sText = preg_replace($c_video_pattern, $c_tpl, $sText);
		/**
		* rutube.ru
		*/

		$r_video_pattern = "/(<video>)(?:https?:\/\/)?(?:www\.)?rutube.ru\/video\/(\w+)\/?(<\/video>)/ui";
		$r_tpl = '<iframe src="//rutube.ru/video/embed/$2" allowfullscreen="true" frameborder="0" width="560" height="315"></iframe>';
		$sText = preg_replace($r_video_pattern, $r_tpl, $sText);

		return $sText;
	}
	/**
	 * Парсит текст, применя все парсеры
	 *
	 * @param string $sText Исходный текст
	 * @return string
	 */
	public function Parser($sText) {
		if (!is_string($sText)) {
			return '';
		}
		$sResult=$this->JevixParser($sText);
		$sResult=$this->VideoParser($sResult);
		return $sResult;
	}
	/**
	 * Производить резрезание текста по тегу cut.
	 * Возвращаем массив вида:
	 * <pre>
	 * array(
	 * 		$sTextShort - текст до тега <cut>
	 * 		$sTextNew   - весь текст за исключением удаленного тега
	 * 		$sTextCut   - именованное значение <cut>
	 * )
	 * </pre>
	 *
	 * @param  string $sText Исходный текст
	 * @return array
	 */
	public function Cut($sText) {
		$sTextShort = $sText;
		$sTextNew   = $sText;
		$sTextCut   = null;

		$sTextTemp=str_replace("\r\n",'[<rn>]',$sText);
		$sTextTemp=str_replace("\n",'[<n>]',$sTextTemp);

		if (preg_match("/^(.*)<cut(.*)>(.*)$/Ui",$sTextTemp,$aMatch)) {
			$aMatch[1]=str_replace('[<rn>]',"\r\n",$aMatch[1]);
			$aMatch[1]=str_replace('[<n>]',"\r\n",$aMatch[1]);
			$aMatch[3]=str_replace('[<rn>]',"\r\n",$aMatch[3]);
			$aMatch[3]=str_replace('[<n>]',"\r\n",$aMatch[3]);
			$sTextShort=$aMatch[1];
			$sTextNew=$aMatch[1].' <a name="cut"></a> '.$aMatch[3];
			if (preg_match('/^\s*name\s*=\s*"(.+)"\s*\/?$/Ui',$aMatch[2],$aMatchCut)) {
				$sTextCut=trim($aMatchCut[1]);
			}
		}

		return array($sTextShort,$sTextNew,$sTextCut ? htmlspecialchars($sTextCut) : null);
	}
	/**
	 * Обработка тега ls в тексте
	 * <pre>
	 * <ls user="admin" />
	 * </pre>
	 *
	 * @param string $sTag	Тег на котором сработал колбэк
	 * @param array $aParams Список параметров тега
	 * @return string
	 */
	public function CallbackTagLs($sTag,$aParams) {
		$sText='';
		if (isset($aParams['user'])) {
			if ($oUser=$this->User_getUserByLogin($aParams['user'])) {
				$sText.="<a href=\"{$oUser->getUserWebPath()}\" class=\"ls-user\">{$oUser->getLogin()}</a> ";
			}
		}
		return $sText;
	}
        /**
        * Смайлопак Табуна
        */
        public function CallbackTagSmp($sTag, $aParams) {
                $sText='';
                if (isset($aParams['id']) && isset($aParams['name'])) {
                        $sText.="<img class=\"smp\" src=\"//files.everypony.ru/smiles/".$aParams['name']."/".$aParams['id'].".gif\" />";
                }
			return $sText;
        }
}
?>