<?php
return [
    'components' => [
        'db' => [
            'class' => 'yii\db\Connection',
            'dsn' => 'mysql:host=' . getenv('HUMHUB_DB_HOST') . ';dbname=' . getenv('HUMHUB_DB_NAME'),
            'username' => getenv('HUMHUB_DB_USERNAME'),
            'password' => getenv('HUMHUB_DB_PASSWORD'),
            'charset' => 'utf8mb4',
        ],
    ],
    'params' => [
        'installer' => [
            'db' => [
                'installer_hostname' => getenv('HUMHUB_DB_HOST'),
                'installer_database' => getenv('HUMHUB_DB_NAME'),
                'installer_username' => getenv('HUMHUB_DB_USERNAME'),
                'installer_password' => getenv('HUMHUB_DB_PASSWORD'),
            ],
        ],
    ],
];
