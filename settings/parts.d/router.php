<?php

return [
    'rewrite' => [],
    'uri' => [
        '~^(\d+)\.html~i' => "blog/\\1.html",
    ],

    'page' => [
        'error' => 'ActionError',
        'registration' => 'ActionRegistration',
        'profile' => 'ActionProfile',
        'my' => 'ActionMy',
        'blog' => 'ActionBlog',
        'personal_blog' => 'ActionPersonalBlog',
        'index' => 'ActionIndex',
        'topic' => 'ActionTopic',
        'login' => 'ActionLogin',
        'people' => 'ActionPeople',
        'settings' => 'ActionSettings',
        'talk' => 'ActionTalk',
        'comments' => 'ActionComments',
        'rss' => 'ActionRss',
        'question' => 'ActionQuestion',
        'blogs' => 'ActionBlogs',
        'search' => 'ActionSearch',
        'admin' => 'ActionAdmin',
        'ajax' => 'ActionAjax',
        'feed' => 'ActionUserfeed',
        'stream' => 'ActionStream',
        'subscribe' => 'ActionSubscribe',
        'page' => 'ActionPage'
    ],

    'config' => [
        'action_default' => 'index',
        'action_not_found' => 'error'
    ]
];
