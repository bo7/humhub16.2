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
        'mailer' => [
            'class' => 'yii\swiftmailer\Mailer',
            'viewPath' => '@app/mail',
            'useFileTransport' => false,
            'transport' => [
                'class' => 'Swift_SmtpTransport',
                'host' => getenv('HUMHUB_MAILER_HOSTNAME'),
                'username' => getenv('HUMHUB_MAILER_USERNAME'),
                'password' => getenv('HUMHUB_MAILER_PASSWORD'),
                'port' => getenv('HUMHUB_MAILER_PORT'),
                'encryption' => getenv('HUMHUB_MAILER_ENCRYPTION'),
            ],
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
