<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class LoginController extends Controller
{
    protected $helpers = ['form', 'url'];

    public function index()
    {
        return view('login');
    }

    public function login()
    {
        $rules = [
            'nickname' => 'required|min_length[3]|max_length[50]',
            'password' => 'required|min_length[4]|max_length[72]',
        ];

        if (!$this->validate($rules)) {
            return redirect()->to('/login')
                ->withInput()
                ->with('flash_error', 'Hibás űrlap: ' . implode(' ', $this->validator->getErrors()));
        }

        $nickname = (string) $this->request->getPost('nickname');
        $password = (string) $this->request->getPost('password');

        $db = db_connect();
        $user = $db->table('users')
            ->select('id, nickname, password_hash, is_active')
            ->where('nickname', $nickname)
            ->get()
            ->getRowArray();

        // Biztonság: ne áruld el, melyik a rossz
        if (!$user || (int)$user['is_active'] !== 1) {
            return redirect()->to('/login')
                ->withInput()
                ->with('flash_error', 'Hibás nickname vagy jelszó.');
        }

        if (!password_verify($password, $user['password_hash'])) {
            return redirect()->to('/login')
                ->withInput()
                ->with('flash_error', 'Hibás nickname vagy jelszó.');
        }

        session()->regenerate(true);
        session()->set([
            'user_id' => $user['id'],
            'nickname' => $user['nickname'],
        ]);

        return redirect()->to('/admin')->with('flash_success', 'Sikeres bejelentkezés!');
    }

    public function dashboard()
    {
        // Egyelőre csak egy minimál page, következő lépésben védjük sessionnel
        return view('admin');
    }

    public function logout()
    {
        session()->destroy();
        return redirect()->to('/login')->with('flash_success', 'Kijelentkezve.');
    }

    public function menuList()
    {
        $db = db_connect();
        $rows = $db->table('menus')
            ->orderBy('parent_id', 'ASC')
            ->orderBy('sort_order', 'ASC')
            ->get()
            ->getResultArray();

        return $this->response->setJSON(['data' => $rows]);
    }

    public function menuTree()
    {
        $db = db_connect();
        $rows = $db->table('menus')
            ->where('is_active', 1)
            ->orderBy('sort_order', 'ASC')
            ->get()
            ->getResultArray();

        return $this->response->setJSON(['data' => $this->buildMenuTree($rows)]);
    }

    public function menuCreate()
    {
        $payload = $this->request->getJSON(true) ?? $this->request->getPost();

        $rules = [
            'title' => 'required|min_length[2]|max_length[120]',
            'url' => 'permit_empty|max_length[255]',
            'parent_id' => 'permit_empty|is_natural_no_zero',
            'sort_order' => 'permit_empty|integer',
            'is_active' => 'permit_empty|in_list[0,1]',
        ];

        if (!$this->validateData($payload, $rules)) {
            return $this->response->setStatusCode(422)->setJSON([
                'message' => 'Validation error',
                'errors' => $this->validator->getErrors(),
            ]);
        }

        $data = [
            'title' => (string)$payload['title'],
            'url' => isset($payload['url']) && $payload['url'] !== '' ? (string)$payload['url'] : null,
            'parent_id' => !empty($payload['parent_id']) ? (int)$payload['parent_id'] : null,
            'sort_order' => isset($payload['sort_order']) ? (int)$payload['sort_order'] : 0,
            'is_active' => isset($payload['is_active']) ? (int)$payload['is_active'] : 1,
        ];

        $db = db_connect();

        if ($data['parent_id']) {
            $exists = $db->table('menus')->select('id')->where('id', $data['parent_id'])->get()->getRowArray();
            if (!$exists) {
                return $this->response->setStatusCode(422)->setJSON([
                    'message' => 'Validation error',
                    'errors' => ['parent_id' => 'A megadott parent_id nem létezik.'],
                ]);
            }
        }

        $db->table('menus')->insert($data);

        return $this->response->setStatusCode(201)->setJSON([
            'message' => 'Created',
            'id' => $db->insertID(),
        ]);
    }

    public function menuUpdate(int $id)
    {
        $payload = $this->request->getJSON(true) ?? [];

        $rules = [
            'title' => 'permit_empty|min_length[2]|max_length[120]',
            'url' => 'permit_empty|max_length[255]',
            'parent_id' => 'permit_empty|is_natural_no_zero',
            'sort_order' => 'permit_empty|integer',
            'is_active' => 'permit_empty|in_list[0,1]',
        ];

        if (!$this->validateData($payload, $rules)) {
            return $this->response->setStatusCode(422)->setJSON([
                'message' => 'Validation error',
                'errors' => $this->validator->getErrors(),
            ]);
        }

        $db = db_connect();
        $row = $db->table('menus')->where('id', $id)->get()->getRowArray();
        if (!$row) {
            return $this->response->setStatusCode(404)->setJSON(['message' => 'Not found']);
        }

        if (!empty($payload['parent_id']) && (int)$payload['parent_id'] === $id) {
            return $this->response->setStatusCode(422)->setJSON([
                'message' => 'Validation error',
                'errors' => ['parent_id' => 'Egy menüpont nem lehet saját maga a szülője.'],
            ]);
        }

        $data = array_intersect_key($payload, array_flip(['title', 'url', 'parent_id', 'sort_order', 'is_active']));
        $db->table('menus')->where('id', $id)->update($data);

        return $this->response->setJSON(['message' => 'Updated']);
    }

    public function menuDelete(int $id)
    {
        $db = db_connect();
        $row = $db->table('menus')->where('id', $id)->get()->getRowArray();
        if (!$row) {
            return $this->response->setStatusCode(404)->setJSON(['message' => 'Not found']);
        }

        $db->table('menus')->where('id', $id)->delete();

        return $this->response->setJSON(['message' => 'Deleted']);
    }

    private function buildMenuTree(array $rows): array
    {
        $byParent = [];
        foreach ($rows as $r) {
            $pid = $r['parent_id'] ?? null;
            $key = $pid === null ? 'root' : (string)$pid;
            $byParent[$key][] = $r;
        }

        $walker = function ($parentKey) use (&$walker, &$byParent): array {
            $children = $byParent[$parentKey] ?? [];
            $out = [];

            foreach ($children as $c) {
                $out[] = [
                    'id' => (int)$c['id'],
                    'title' => $c['title'],
                    'url' => $c['url'],
                    'sort_order' => (int)$c['sort_order'],
                    'children' => $walker((string)$c['id']),
                ];
            }

            return $out;
        };

        return $walker('root');
    }

}
