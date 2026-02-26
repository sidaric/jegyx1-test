<?php

namespace App\Commands;

use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;

class SeedAdminUser extends BaseCommand
{
    protected $group       = 'Custom';
    protected $name        = 'seed:admin';
    protected $description = 'Create demo admin user (nickname: admin, password: admin1234)';

    public function run(array $params)
    {
        $db = db_connect();

        $nickname = 'admin';
        $exists = $db->table('users')->select('id')->where('nickname', $nickname)->get()->getRowArray();
        if ($exists) {
            CLI::write('User already exists: admin', 'yellow');
            return;
        }

        $db->table('users')->insert([
            'nickname' => $nickname,
            'password_hash' => password_hash('admin1234', PASSWORD_DEFAULT),
            'is_active' => 1
        ]);

        CLI::write('Created admin user: admin / admin1234', 'green');
    }
}
