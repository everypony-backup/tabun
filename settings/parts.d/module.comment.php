<?php

  return [
      // Комментарии с указанным рейтингом или ниже считаются плохими и отображаются более бледно
      'bad_rating' => -5,
      // Комментарии с указанным рейтингом или ниже полностью скрываются
      'hidden_rating' => -10,
      'per_page' => 50,
      'max_tree' => 40,
      'favourite_target_allow' => ['topic'],
      'comment_max_length' => 64000
  ];
