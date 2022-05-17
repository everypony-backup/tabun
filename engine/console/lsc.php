<?php

abstract class LSC
{

    /*
     * Запускаем работу консоли
     */
    public static function Start()
    {
        $aArgs = $_SERVER['argv'];

        // Если не передана команда выводим помощь
        if (count($aArgs)==1) {
            echo self::getHelp()."\n";
            return ;
        }

        $sCommandClassName = ucwords($aArgs[1]);
        $sCommandClassPath = dirname(__FILE__).'/commands/'.$sCommandClassName.'.class.php';

        // Существует ли такой класс, а следовательно и команда
        if (file_exists($sCommandClassPath)) {
            // Подключаем класс команды
            require_once $sCommandClassPath;
            $oCommand = new $sCommandClassName();
            $oCommand->run($aArgs);
        } else {
            die("Command not isset\n");
        }
    }

    /*
     * Отдаем управление вызванной команде
     */
    public function run($aArgs)
    {
        // Если не передана подкоманда или передана подкоманда help выводим помощь
        if (!isset($aArgs[2]) or $aArgs[2]=='help') {
            echo $this->getHelp()."\n";
            return ;
        }

        $sMethodName = 'action'.ucwords($aArgs[2]);

        // Оставляем в массиве только параметры для подкоманды
        array_shift($aArgs);
        array_shift($aArgs);
        array_shift($aArgs);

        $this->$sMethodName($aArgs);
    }

    /*
     * Выводит помощь и список возможных команд
     */
    public function getHelp()
    {
        $aList=array();
        $handle=opendir(dirname(__FILE__).'/commands/');
        while (($file=readdir($handle))!==false) {
            if ($file==='.' || $file==='..') {
                continue;
            }
            if (is_file(dirname(__FILE__).'/commands/'.$file)) {
                $aList[]=strtolower(preg_replace("/^(.*)\.(.*)\.(.*)/i", "$1", $file));
            }
        }
        closedir($handle);

        echo "USAGE\n
  ls ";

        foreach ($aList as $iKey=>$sName) {
            if ($iKey>0) {
                echo "     ";
            }
            echo $sName."\n";
        }
    }
}
