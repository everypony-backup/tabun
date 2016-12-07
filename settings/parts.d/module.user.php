<?php

return [
    'per_page' => 50,
    'friend_on_profile' => 50,
    'friend_notice' => [
        'delete' => false,
        'accept' => true,
        'reject' => false
    ],
    'avatar_size' => [100, 64, 48, 24, 0],
    'login' => [
        'min_size' => 3,
        'max_size' => 30,
        'charset' => '0-9a-z_\-'
    ],
    'time_active' => 60 * 60 * 24 * 30 * 3,
    'usernote_text_max' => 64000,
    'usernote_per_page' => 100,
    'profile_photo_width' => 250,
    'name_max' => 30,
    'about_max' => 3000,
    'userfield_max_identical' => 4,
    'captcha_use_registration' => false,
    'recaptcha_use_registration' => true,
    'bad_rating' => -10
];