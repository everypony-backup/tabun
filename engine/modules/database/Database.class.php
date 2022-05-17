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

require_once(Config::Get('path.root.engine').'/lib/external/DbSimple/Generic.php');
require_once('DbSimpleWrapper.class.php');
/**
 * Модуль для работы с базой данных
 * Создаёт объект БД библиотеки DbSimple Дмитрия Котерова
 * Модуль используется в основном для создания коннекта к БД и передачи его в маппер
 * @see Mapper::__construct
 * Так же предоставляет методы для быстрого выполнения запросов/дампов SQL, актуально для плагинов
 * @see Plugin::ExportSQL
 *
 * @package engine.modules
 * @since 1.0
 */
class ModuleDatabase extends Module
{
    /**
     * Массив инстанцируемых объектов БД, или проще говоря уникальных коннектов к БД
     *
     * @var array
     */
    protected $aInstance=array();

    protected $aReplicaInstanceSlave=array();
    protected $aReplicaMasterByTable=array();
    protected $sQueryLog = '';

    /**
     * Инициализация модуля
     *
     */
    public function Init()
    {
    }

    public function GetReplicaInstanceSlaveByHash($sHash)
    {
        return isset($this->aReplicaInstanceSlave[$sHash]) ? $this->aReplicaInstanceSlave[$sHash] : null;
    }
    public function SetReplicaInstanceSlave($sHash, $oReplicaInstanceSlave)
    {
        return $this->aReplicaInstanceSlave[$sHash]=$oReplicaInstanceSlave;
    }

    public function GetReplicaMasterByTable()
    {
        return $this->aReplicaMasterByTable;
    }
    public function SetReplicaMasterByTable($aReplicaMasterByTable)
    {
        $this->aReplicaMasterByTable=$aReplicaMasterByTable;
    }
    /**
     * Получает объект БД
     *
     * @param array|null $aConfig - конфиг подключения к БД(хост, логин, пароль, тип бд, имя бд), если null, то используются параметры из конфига Config::Get('db.params')
     * @return DbSimple_Database DbSimple
     */
    public function GetConnect($aConfig = null)
    {
        /**
         * Получаем DSN
         */
        $sDSN = $this->GetDSNByConfig($aConfig);

        /**
         * Создаём хеш подключения, уникальный для каждого конфига
         */
        $sDSNKey = md5($sDSN);

        /**
         * Проверяем создавали ли уже коннект с такими параметрами подключения(DSN)
         */
        if (isset($this->aInstance[$sDSNKey])) {
            return $this->aInstance[$sDSNKey];
        } else {
            /**
             * Если такого коннекта еще не было то создаём его
             */
            $oDbSimple = DbSimple_Generic::connect($sDSN);
            /**
             * Устанавливаем хук на перехват ошибок при работе с БД
             */
            $oDbSimple->setErrorHandler('databaseErrorHandler');
            /**
             * Если нужно логировать все SQL запросы то подключаем логгер
             */
            if (Config::Get('sys.logs.sql_query')) {
                $oDbSimple->setLogger('databaseLogger');
            }
            /**
             * Устанавливаем настройки соединения, по хорошему этого здесь не должно быть :)
             * считайте это костылём
             */
            $oDbSimple->query("set character_set_client='utf8', character_set_results='utf8', collation_connection='utf8_bin' ");
            $oWrapper = new ModuleDatabase_DbSimpleWrapper($oDbSimple);
            /**
             * Сохраняем коннект
             */
            $this->aInstance[$sDSNKey] = $oWrapper;
            /**
             * Возвращаем коннект
             */
            return $oWrapper;
        }
    }
    /**
     * Возвращает статистику использования БД - время и количество запросов
     *
     * @return array
     */
    public function GetStats()
    {
        $aQueryStats=array('time'=>0,'count'=>-1); // не считаем тот самый костыльный запрос, который устанавливает настройки DB соединения
        foreach ($this->aInstance as $oDb) {
            $aStats=$oDb->getStatistics();
            $aQueryStats['time']+=$aStats['time'];
            $aQueryStats['count']+=$aStats['count'];
        }
        $aQueryStats['time']=round($aQueryStats['time'], 3);
        $aQueryStats['query_log'] = $this->sQueryLog;
        return $aQueryStats;
    }
    /**
     * Экспорт SQL дампа в БД
     * @see ExportSQLQuery
     *
     * @param string $sFilePath	Полный путь до файла SQL
     * @param array|null $aConfig	Конфиг подключения к БД
     * @return array
     */
    public function ExportSQL($sFilePath, $aConfig=null)
    {
        if (!is_file($sFilePath)) {
            return array('result'=>false,'errors'=>array("cant find file '$sFilePath'"));
        } elseif (!is_readable($sFilePath)) {
            return array('result'=>false,'errors'=>array("cant read file '$sFilePath'"));
        }
        $sFileQuery = file_get_contents($sFilePath);
        return $this->ExportSQLQuery($sFileQuery, $aConfig);
    }

    /**
     * Экспорт SQL в БД
     *
     * @param string $sFileQuery	Строка с SQL запросом
     * @param array|null $aConfig	Конфиг подключения к БД
     * @return array	Возвращает массив вида array('result'=>bool,'errors'=>array())
     */
    public function ExportSQLQuery($sFileQuery, $aConfig=null)
    {
        /**
         * Замена префикса таблиц
         */
        $sFileQuery = str_replace('prefix_', Config::Get('db.table.prefix'), $sFileQuery);

        /**
         * Массивы запросов и пустой контейнер для сбора ошибок
         */
        $aErrors = array();
        $aQuery=explode(';', $sFileQuery);
        /**
         * Выполняем запросы по очереди
         */
        foreach ($aQuery as $sQuery) {
            $sQuery = trim($sQuery);
            /**
             * Заменяем движек, если таковой указан в запросе
             */
            if (Config::Get('db.tables.engine')!='InnoDB') {
                $sQuery=str_ireplace('ENGINE=InnoDB', "ENGINE=".Config::Get('db.tables.engine'), $sQuery);
            }

            if ($sQuery!='') {
                $bResult=$this->GetConnect($aConfig)->query($sQuery);
                if ($bResult===false) {
                    $aErrors[] = mysql_error();
                }
            }
        }
        /**
         * Возвращаем результат выполнения, взависимости от количества ошибок
         */
        if (count($aErrors)==0) {
            return array('result'=>true,'errors'=>null);
        }
        return array('result'=>false,'errors'=>$aErrors);
    }

    /**
     * Возвращает DSN строку из конфига
     *
     * @param null $aConfig
     *
     * @return string
     */
    protected function GetDSNByConfig($aConfig=null) {
        /**
         * Если конфиг не передан то используем главный конфиг БД из config.php
         */
        if (is_null($aConfig)) {
            $aConfig = Config::Get('db.params');
        }
        $sParams = '';
        if (isset($aConfig['params']) and is_array($aConfig['params'])) {
            $sParams = '?' . http_build_query($aConfig['params'], '', '&');
        }
        return $aConfig['type'] . '://' . $aConfig['user'] . ':' . $aConfig['pass'] . '@' . $aConfig['host'] . ':' . $aConfig['port'] . '/' . $aConfig['dbname'] . $sParams;
    }

    public function LogQuery($sStr)
    {
        $this->sQueryLog  .= ("\n" . $sStr);
    }
    /**
     * Проверяет существование таблицы
     *
     * @param string $sTableName	Название таблицы, необходимо перед именем таблицы добавлять "prefix_", это позволит учитывать произвольный префикс таблиц у пользователя
     * @param array|null $aConfig	Конфиг подключения к БД
     * @return bool
     */
    public function isTableExists($sTableName, $aConfig=null)
    {
        $sTableName = str_replace('prefix_', Config::Get('db.table.prefix'), $sTableName);
        $sQuery="SHOW TABLES LIKE '{$sTableName}'";
        if ($aRows=$this->GetConnect($aConfig)->select($sQuery)) {
            return true;
        }
        return false;
    }
    /**
     * Проверяет существование поля в таблице
     *
     * @param string $sTableName	Название таблицы, необходимо перед именем таблицы добавлять "prefix_", это позволит учитывать произвольный префикс таблиц у пользователя
     * @param string $sFieldName	Название поля в таблице
     * @param array|null $aConfig	Конфиг подключения к БД
     * @return bool
     */
    public function isFieldExists($sTableName, $sFieldName, $aConfig=null)
    {
        $sTableName = str_replace('prefix_', Config::Get('db.table.prefix'), $sTableName);
        $sQuery="SHOW FIELDS FROM `{$sTableName}`";
        if ($aRows=$this->GetConnect($aConfig)->select($sQuery)) {
            foreach ($aRows as $aRow) {
                if ($aRow['Field'] == $sFieldName) {
                    return true;
                }
            }
        }
        return false;
    }
    /**
     * Доавляет новый тип в поле таблицы с типом enum
     *
     * @param string $sTableName	Название таблицы, необходимо перед именем таблицы добавлять "prefix_", это позволит учитывать произвольный префикс таблиц у пользователя
     * @param string $sFieldName	Название поля в таблице
     * @param string $sType	Название типа
     * @param array|null $aConfig	Конфиг подключения к БД
     */
    public function addEnumType($sTableName, $sFieldName, $sType, $aConfig=null)
    {
        $sTableName = str_replace('prefix_', Config::Get('db.table.prefix'), $sTableName);
        $sQuery="SHOW COLUMNS FROM  `{$sTableName}`";

        if ($aRows=$this->GetConnect($aConfig)->select($sQuery)) {
            foreach ($aRows as $aRow) {
                if ($aRow['Field'] == $sFieldName) {
                    break;
                }
            }
            if (strpos($aRow['Type'], "'{$sType}'") === false) {
                $aRow['Type'] =str_ireplace('enum(', "enum('{$sType}',", $aRow['Type']);
                $sQuery="ALTER TABLE `{$sTableName}` MODIFY `{$sFieldName}` ".$aRow['Type'];
                $sQuery.= ($aRow['Null']=='NO') ? ' NOT NULL ' : ' NULL ';
                $sQuery.= is_null($aRow['Default']) ? ' DEFAULT NULL ' : " DEFAULT '{$aRow['Default']}' ";
                $this->GetConnect($aConfig)->select($sQuery);
            }
        }
    }
}

/**
 * Функция хука для перехвата SQL ошибок
 *
 * @param string $message	Сообщение об ошибке
 * @param array $info	Список информации об ошибке
 */
function databaseErrorHandler($message, $info)
{
    /**
     * Записываем информацию об ошибке в переменную $msg
     */
    $msg="SQL Error: $message<br>\n";
    $msg.=print_r($info, true);
    /**
     * Если нужно логировать SQL ошибке то пишем их в лог
     */
    if (Config::Get('sys.logs.sql_error')) {
        /**
         * Получаем ядро
         */
        $oEngine=Engine::getInstance();
        /**
         * Меняем имя файла лога на нужное, записываем в него ошибку и меняем имя обратно :)
         */
        $sOldName=$oEngine->Logger_GetFileName();
        $oEngine->Logger_SetFileName(Config::Get('sys.logs.sql_error_file'));
        $oEngine->Logger_Error($msg);
        $oEngine->Logger_SetFileName($sOldName);
    }
    /**
     * Если стоит вывод ошибок то выводим ошибку на экран(браузер)
     */
    if (error_reporting() && ini_get('display_errors')) {
        exit($msg);
    }
}

/**
 * Функция логгирования SQL запросов
 *
 * @param object $db
 * @param array $sql
 */
function databaseLogger($db, $sql)
{
    /**
     * Получаем ядро и сохраняем в логе SQL запрос
     */
    $oEngine=Engine::getInstance();
    $oEngine->Database_LogQuery(print_r($sql, true));
}
