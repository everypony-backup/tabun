<?php

// Для эмуляции работы, т.к используется в конфиге
$_SERVER['HTTP_HOST']='localhost';

require_once(dirname(__FILE__)."/../../settings/loader.php");
require_once(Config::Get('path.root.engine')."/classes/Engine.class.php");
require_once(dirname(__FILE__).'/lsc.php');


LSC::Start();
