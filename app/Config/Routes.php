<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->get('/', 'LoginController::index');
$routes->get('/login', 'LoginController::index');
$routes->post('/login', 'LoginController::login');
$routes->get('/logout', 'LoginController::logout');
$routes->get('/admin', 'LoginController::dashboard', ['filter' => 'auth']);

$routes->group('api', ['filter' => 'auth'], static function ($routes) {
    $routes->get('menus/tree', 'LoginController::menuTree');
    $routes->get('menus', 'LoginController::menuList');
    $routes->post('menus', 'LoginController::menuCreate');
    $routes->put('menus/(:num)', 'LoginController::menuUpdate/$1');
    $routes->delete('menus/(:num)', 'LoginController::menuDelete/$1');
});
