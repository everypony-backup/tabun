<?php

return [
    'default' => [
        // Разрешённые теги
        'cfgAllowTags' => [
            // вызов метода с параметрами
            [[
                'strong', 'em', 'u', 's', 'sup', 'sub', 'small',
                'h4', 'h5', 'h6', 'br', 'li', 'ol', 'ul',
                'a', 'img', 'blockquote', 'cut', 'smile',
                'ls', 'pre', 'iframe', 'span', 'text', 'p', 'hr'
            ]],

        ],
        // Коротие теги типа
        'cfgSetTagShort' => [
            [['hr', 'br', 'img', 'cut', 'ls', 'smile']],
        ],
        // Преформатированные теги
        'cfgSetTagPreformatted' => [
            [
                ['pre']
            ],
        ],
        // Разрешённые параметры тегов
        'cfgAllowTagParams' => [
            [
                'br',
                ['class' => ['clear']]
            ],
            [
                'img',
                [
                    'src',
                    'data-src',
                    'alt' => '#text',
                    'title' => '#text',
                    'width' => '#int',
                    'height' => '#int',
                    'class' => [
                        'h-top',
                        'h-bottom',
                        'h-right',
                        'h-left',
                        'h-center'
                    ]
                ]
            ],
            [
                'a',
                [
                    'href',
                    'rel' => '#text',
                    'id' => ['cut'],
                    'title' => '#text',
                    'target' => ['_blank'],
                    'class' => ['ls-user'],
                ]
            ],
            [
                'cut',
                ['name' => '#text']
            ],
            [
                'iframe',
                [
                    'src' => [
                        '#domain' => [
                            'youtube.com' => 'embed/[\w\d\-_]+$',
                            'player.vimeo.com' => '',
                            'dailymotion.com' => '',
                            'coub.com' => '',
                            'rutube.ru' => '',
                            'w.soundcloud.com' => '',
                            'vk.com' => "video_ext\.php",
                            'radio.everypony.ru' => '',
                            'pony.fm' => '',
                            'eqbeats.org' => '',
                            'imgur.com' => '',
                            'ponyvillelive.com' => '',
                            'giphy.com' => 'embed/',
                            'gfycat.com' => 'ifr/',
                            'vault.mle.party' => 'videos/embed/',
                        ],
                    ],
                    'data-src' => [
                        '#domain' => [
                            'youtube.com' => 'embed/[\w\d\-_]+$',
                            'player.vimeo.com' => '',
                            'dailymotion.com' => '',
                            'coub.com' => '',
                            'rutube.ru' => '',
                            'w.soundcloud.com' => '',
                            'vk.com' => "video_ext\.php",
                            'radio.everypony.ru' => '',
                            'pony.fm' => '',
                            'eqbeats.org' => '',
                            'imgur.com' => '',
                            'ponyvillelive.com' => '',
                            'giphy.com' => 'embed/',
                            'gfycat.com' => 'ifr/',
                            'vault.mle.party' => 'videos/embed/',
                        ],
                    ],
                    'allowscriptaccess' => '#text',
                    'allowfullscreen' => '#text',
                    'width' => '#int',
                    'height' => '#int'
                ]
            ],
            [
                'ls',
                ['user' => '#text']
            ],
            [

                'smile',
                ['id' => '#text', 'name' => '#text']
            ],
            [
                'span',
                [
                    'class' => [
                        'spoiler',
                        'spoiler-title',
                        'spoiler-body',
                        'spoiler-gray',
                        'spoiler spoiler-media',
                        'h-top',
                        'h-bottom',
                        'h-right',
                        'h-left',
                        'h-center',
                    ],
                    'onclick' => [
                        'return true;',
                        ''
                    ]
                ]
            ],
        ],
        // Параметры тегов являющиеся обязательными
        'cfgSetTagParamsRequired' => [],
        // Теги которые необходимо вырезать из текста вместе с контентом
        'cfgSetTagCutWithContent' => [
            [
                ['script', 'style']
            ],
        ],
        // Вложенные теги
        'cfgSetTagChilds' => [
            ['ul', ['li'], false, true],
            ['ol', ['li'], false, true],
            ['text', ['p'], false, true],

        ],
        // Если нужно оставлять пустые не короткие теги
        'cfgSetTagIsEmpty' => [
            [
                ['a', 'iframe']
            ],
        ],
        // Не нужна авто-расстановка <br>
        'cfgSetTagNoAutoBr' => [
            [
                ['ul', 'ol', 'blockquote', 'text', 'hr']
            ]
        ],
        // Теги с обязательными параметрами
        'cfgSetTagParamDefault' => [],
        // Отключение авто-добавления <br>
        'cfgSetAutoBrMode' => [
            [true]
        ],
        // Автозамена
        'cfgSetAutoReplace' => [
            [
                ['+/-', '(c)', '(с)', '(r)', '(C)', '(С)', '(R)'],
                ['±', '©', '©', '®', '©', '©', '®']
            ]
        ],
        'cfgSetTagNoTypography' => [
            [
                ['pre']
            ],
        ],
        // Теги, после которых необходимо пропускать одну пробельную строку
        'cfgSetTagBlockType' => [
            [
                ['h4', 'h5', 'h6', 'ol', 'ul']
            ]
        ],
        'cfgSetTagCallbackFull' => [
            ['ls', ['_this_', 'CallbackTagLs'],],
            ['smile', ['_this_', 'CallbackTagSmp'],],
        ],
    ],

    // настройки для обработки текста в результатах поиска
    'search' => [
        // Разрешённые теги
        'cfgAllowTags' => [
            // вызов метода с параметрами
            [
                ['span'],
            ],
        ],
        // Разрешённые параметры тегов
        'cfgAllowTagParams' => [
            [
                'span',
                ['class' => '#text']
            ],
        ],
    ],
];
