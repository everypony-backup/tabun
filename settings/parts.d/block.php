<?php

return [
    'rule_index_blog' => [
        'action' => ['index', 'blog' => ['{topics}', '{topic}', '{blog}']],
        'blocks' => [
            'right' => ['sidetop', 'search', 'stream', 'donate', 'banners', 'herdmind', 'blogs'],
        ]
    ],
    'rule_topic_type' => [
        'action' => [
            'question' => ['add', 'edit'],
            'topic' => ['add', 'edit'],
        ],
        'blocks' => ['right' => ['blogInfo']],
    ],
    'rule_people' => [
        'action' => ['people'],
        'blocks' => ['right' => ['actions/ActionPeople/sidebar.tpl']],
    ],
    'rule_personal_blog' => [
        'action' => ['personal_blog'],
        'blocks' => ['right' => ['sidetop', 'search', 'stream', 'donate', 'herdmind']],
    ],
    'rule_profile' => [
        'action' => ['profile', 'talk', 'settings'],
        'blocks' => ['right' => ['actions/ActionProfile/sidebar.tpl']],
    ],
    'rule_tag' => [
        'action' => ['tag'],
        'blocks' => ['right' => ['sidetop', 'search', 'stream', 'donate', 'herdmind']],
    ],
    'rule_blogs' => [
        'action' => ['blogs'],
        'blocks' => ['right' => ['sidetop', 'search', 'stream', 'donate', 'herdmind']],
    ],
    'userfeedBlogs' => [
        'action' => ['feed'],
        'blocks' => ['right' => ['userfeedBlogs']]
    ],
    'userfeedUsers' => [
        'action' => ['feed'],
        'blocks' => ['right' => ['userfeedUsers']]
    ],
    'rule_blog_info' => [
        'action' => ['blog' => ['{topic}']],
        'blocks' => ['right' => ['blog']],
    ],
    'rule_search' => [
        'action' => ['search'],
        'blocks' => ['right' => ['sidetop', 'search', 'donate', 'herdmind']],
    ],
    'stream' => [
        'row' => 20
    ],
    'blogs' => [
        'row' => 20
    ],
    'tags' => [
        'tags_count' => 20,
        'personal_tags_count' => 20
    ]
];