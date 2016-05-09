<?php
$config['db']['params']['host'] = '127.0.0.1';
$config['db']['params']['port'] = '3306';
$config['db']['params']['user'] = 'tabun';
$config['db']['params']['pass'] = 'tabun';
$config['db']['params']['type']   = 'mysql';
$config['db']['params']['dbname'] = 'tabun';
$config['db']['tables']['engine'] = 'InnoDB';
$config['db']['table']['prefix'] = 'ls_';

$config['path']['offset_request_url'] = '0';
$config['sys']['logs']['dir'] = '/log';

$config['path']['uploads']['storage'] = '/storage';
$config['path']['uploads']['url'] = '//localhost/storage';

$config['path']['smarty']['compiled'] = '/tmp/smarty/compiled';
$config['path']['smarty']['cache'] = '/tmp/smarty/cache';

$config['misc']['debug'] = true;

$config['misc']['ver']['code'] = 'trunk';
$config['misc']['ver']['front'] = 'ba0952a008d21b500faa';

return $config;
