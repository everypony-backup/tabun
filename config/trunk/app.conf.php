<?php
$config['db']['params']['host'] = '127.0.0.1';
$config['db']['params']['port'] = '4406';
$config['db']['params']['user'] = 'tabun_trunk';
$config['db']['params']['pass'] = 'tabun_trunk';
$config['db']['params']['dbname'] = 'tabun_trunk';
$config['db']['tables']['engine'] = 'InnoDB';
$config['db']['table']['prefix'] = 'ls_';

$config['path']['uploads']['storage'] = '/storage';
$config['path']['uploads']['url'] = '//cdn.everypony.ru/tabun-trunk-storage';
$config['path']['static']['url'] = '//cdn.everypony.ru/tabun-trunk-static';
$config['path']['smarty']['compiled'] = '/tmp/smarty/compiled';
$config['path']['smarty']['cache'] = '/tmp/smarty/cache';

$config['sys']['elastic']['hosts'] = ["127.0.0.1:9210"];

$config['sys']['celery']['host'] = '127.0.0.1';
$config['sys']['celery']['port'] = 6579;
$config['sys']['celery']['db'] = 1;

$config['sys']['cache']['servers'] = [
    [
        'host' => '127.0.0.1',
        'port' => 6579,
        'dbindex' => 4,
    ],
];

$config['sys']['mail']['from_email'] = 'tabun-trunk@everypony.info';
$config['sys']['mail']['from_name'] = 'Tabun [trunk]';

$config['sys']['logs']['dir'] = '/log';

$config['misc']['debug'] = true;

$config['misc']['services']['twicher'] = 'http://127.0.0.1:5000/quotes/twitchy';
$config['misc']['services']['donations'] = 'https://everypony.ru/donate_api/';
$config['misc']['services']['banners'] = 'https://projects.everypony.ru/banners/';


return $config;
