<?php
$config['path']['root']['web'] = $_SERVER['HTTP_HOST'];
$config['db']['params']['host'] = '127.0.0.1';
$config['db']['params']['port'] = '4406';
$config['db']['params']['user'] = 'tabun_trunk';
$config['db']['params']['pass'] = 'tabun_trunk';
$config['db']['params']['type']   = 'mysql';
$config['db']['params']['dbname'] = 'tabun_trunk';
$config['db']['tables']['engine'] = 'InnoDB';
$config['db']['table']['prefix'] = 'ls_';

$config['path']['offset_request_url'] = '0';
$config['sys']['logs']['dir'] = '/log';

$config['path']['uploads']['storage'] = '/storage';
$config['path']['uploads']['url'] = '//cdn.everypony.ru/tabun-trunk-storage';
$config['path']['static']['url'] = '//cdn.everypony.ru/tabun-trunk-static';

$config['path']['smarty']['compiled'] = '/tmp/smarty/compiled';
$config['path']['smarty']['cache'] = '/tmp/smarty/cache';

$config['misc']['debug'] = true;
$config['misc']['twicher']['url'] = 'http://127.0.0.1:5000/quotes/twitchy';
$config['sys']['elastic']['hosts'] = ["127.0.0.1"];

return $config;
