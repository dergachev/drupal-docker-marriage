<?php

/**
 * Implements hook_views_data_alter().
 */
function bean_views_data_alter(&$data) {
  $data['bean']['type'] = array(
    'title' => t('Type'),
    'help' => t('The block type'),
    'filter' => array(
      'handler' => 'views_handler_filter_bean_type',
    ),
  );
}
