<?php

return [
    'comment' => [
        'oa_end' => 0 /*test*/+strtotime('2017-03-05'),
        'oa_enable_level' => 0,
        'na_enable_level' => 6,	// Allow all admitted users to listen New Age
    ],
    'topic' => [
        'oa_end' => 0,
        'oa_enable_level' => 0,
        'na_enable_level' => 6,	// Allow all admitted users to listen New Age
    ],
    'blog' => [
        'oa_end' => 0,
        'oa_enable_level' => 0,
        'na_enable_level' => 6,	// Allow all admitted users to listen New Age
    ],
    'user' => [
        'oa_end' => 0,
        'oa_enable_level' => 0,
        'na_enable_level' => 6,	// Allow all users to listen New Age
    ],
];
// oa_end — точка завершения "старого" периода, unix timestamp
// oa_enable_level — кому разрешено видеть юзеров оценок за "старый" период
// na_enable_level — кому разрешено видеть юзеров оценок за "новый" период и запрашивать список оценок в целом
//	0 — никто
//	1 — администраторы сайта
//	3 — администраторы сайта, администраторы блогов
//	4 — администраторы сайта, администраторы блогов, модераторы блогов
//	5 — администраторы сайта, администраторы блогов, модераторы блогов, автор объекта (если он может видеть объект)
//	6 — все пользователи, которые могут видеть объект
//	7 — все пользователи
//	8 — все
//		^ не работает для комментариев
// см. также ModuleACL::CheckSimpleAccessLevel
