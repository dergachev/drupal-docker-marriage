<?php 

function wedding_preprocess_html(&$variables) {
  drupal_add_css('http://fonts.googleapis.com/css?family=Roboto:100,300,600&subset=latin,cyrillic', array('type' => 'external'));
  drupal_add_css('http://fonts.googleapis.com/css?family=Josefin+Slab:100,300,600,700', array('type' => 'external'));
}
