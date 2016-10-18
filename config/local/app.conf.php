<?php
$config['path']['root']['web'] = 'http://' . $_SERVER['HTTP_HOST'];

$config['db']['params']['host'] = '127.0.0.1';
$config['db']['params']['port'] = '3306';
$config['db']['params']['user'] = 'tabun';
$config['db']['params']['pass'] = 'tabun';
$config['db']['params']['type']   = 'mysql';
$config['db']['params']['dbname'] = 'tabun';
$config['db']['tables']['engine'] = 'InnoDB';
$config['db']['table']['prefix'] = 'ls_';

$config['path']['uploads']['storage'] = '/storage';
$config['path']['uploads']['url'] = '//localhost:8000/storage';

$config['path']['smarty']['compiled'] = '/tmp/smarty/compiled';
$config['path']['smarty']['cache'] = '/tmp/smarty/cache';

$config['sys']['elastic']['hosts'] = ["127.0.0.1:9200"];

$config['sys']['celery']['host'] = '127.0.0.1';
$config['sys']['celery']['port'] = 6379;
$config['sys']['celery']['db'] = 1;

$config['sys']['cache']['servers'] = [
    [
        'host' => '127.0.0.1',
        'port' => 6379,
        'dbindex' => 4,
    ],
];

$config['sys']['mail']['from_email'] = 'tabun-local@everypony.info';
$config['sys']['mail']['from_name'] = 'Tabun [local]';

$config['sys']['logs']['dir'] = '/log';

$config['misc']['debug'] = true;

$config['misc']['services']['twicher'] = 'http://127.0.0.1:5000/quotes/twitchy';


return $config;
