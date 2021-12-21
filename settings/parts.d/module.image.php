<?php

return [
    'allowed_mime' => [
        "image/bmp" => "bmp",
        "image/x-bmp" => "bmp",
        "image/x-ms-bmp" => "bmp",
        "image/gif" => "gif",
        "image/png" => "png",
        "image/jpeg" => "jpg",
        "image/pjpeg" => "jpg",
        "image/svg+xml" => "svg",
        "image/tiff" => "tiff",
        "image/x-tiff" => "tiff"
    ],
    'max_x' => 10000,
    'max_y' => 20000,
    'max_size' => 30000 // максимальный размер картинки в kB для загрузки по URL
];
