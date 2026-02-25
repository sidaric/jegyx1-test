<!doctype html>
<html lang="hu">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div id="app" class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h1 class="h4 m-0">Menürendszer</h1>
    <div class="d-flex gap-2 align-items-center">
      <span class="text-muted small">Bejelentkezve: <?= esc(session('nickname')) ?></span>
      <a class="btn btn-outline-secondary btn-sm" href="/logout">Logout</a>
    </div>
  </div>

  <div class="row g-3">
    <!-- Tree -->
    <div class="col-lg-6">
      <div class="card shadow-sm">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h2 class="h6 m-0">Menü fa (rekurzív)</h2>
            <button class="btn btn-primary btn-sm" @click="loadTree">Frissítés</button>
          </div>

          <div v-if="loading" class="text-muted small">Betöltés...</div>
          <div v-else>
            <div v-if="tree.length === 0" class="text-muted small">Nincs menüpont.</div>
            <ul class="list-unstyled mb-0" v-else>
              <menu-node v-for="n in tree" :key="n.id" :node="n"></menu-node>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Create -->
    <div class="col-lg-6">
      <div class="card shadow-sm">
        <div class="card-body">
          <h2 class="h6">Új menüpont</h2>

          <div class="mb-2">
            <label class="form-label">Cím</label>
            <input class="form-control" v-model.trim="form.title" />
            <div v-if="errors.title" class="text-danger small mt-1">{{ errors.title }}</div>
          </div>

          <div class="mb-2">
            <label class="form-label">URL (opcionális)</label>
            <input class="form-control" v-model.trim="form.url" />
            <div v-if="errors.url" class="text-danger small mt-1">{{ errors.url }}</div>
          </div>

          <div class="row g-2 mb-2">
            <div class="col-6">
              <label class="form-label">Parent ID (opcionális)</label>
              <input class="form-control" v-model.trim="form.parent_id" />
              <div v-if="errors.parent_id" class="text-danger small mt-1">{{ errors.parent_id }}</div>
            </div>
            <div class="col-6">
              <label class="form-label">Sorrend</label>
              <input class="form-control" v-model.trim="form.sort_order" />
              <div v-if="errors.sort_order" class="text-danger small mt-1">{{ errors.sort_order }}</div>
            </div>
          </div>

          <button class="btn btn-success btn-sm" @click="createMenu" :disabled="saving">
            {{ saving ? 'Mentés...' : 'Létrehozás' }}
          </button>

          <div v-if="serverMsg" class="small mt-2" :class="serverMsgType === 'ok' ? 'text-success' : 'text-danger'">
            {{ serverMsg }}
          </div>
        </div>
      </div>
    </div>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/vue@3.4.38/dist/vue.global.prod.js"></script>
<script>
const { createApp } = Vue;

const MenuNode = {
  name: 'MenuNode',
  props: { node: { type: Object, required: true } },
  template: `
    <li class="mb-2">
      <div class="d-flex gap-2 align-items-center">
        <span class="badge text-bg-light border">#{{ node.id }}</span>
        <strong>{{ node.title }}</strong>
        <span v-if="node.url" class="text-muted small">{{ node.url }}</span>
      </div>
      <ul v-if="node.children && node.children.length" class="list-unstyled ms-4 mt-2">
        <menu-node v-for="c in node.children" :key="c.id" :node="c"></menu-node>
      </ul>
    </li>
  `
};

createApp({
  components: { 'menu-node': MenuNode },
  data() {
    return {
      tree: [],
      loading: false,
      saving: false,
      serverMsg: '',
      serverMsgType: 'ok',
      errors: {},
      form: {
        title: '',
        url: '',
        parent_id: '',
        sort_order: '0',
        is_active: 1
      }
    };
  },
  methods: {
    async loadTree() {
      this.loading = true;
      this.serverMsg = '';
      try {
        const res = await fetch('/api/menus/tree');
        const json = await res.json();
        this.tree = json.data || [];
      } finally {
        this.loading = false;
      }
    },

    validateForm() {
      this.errors = {};

      if (!this.form.title || this.form.title.length < 2) {
        this.errors.title = 'A cím kötelező (min. 2 karakter).';
      }

      if (this.form.url && this.form.url.length > 255) {
        this.errors.url = 'Az URL túl hosszú.';
      }

      if (this.form.parent_id && !/^[1-9]\d*$/.test(this.form.parent_id)) {
        this.errors.parent_id = 'A parent_id csak pozitív egész lehet.';
      }

      if (this.form.sort_order && !/^-?\d+$/.test(this.form.sort_order)) {
        this.errors.sort_order = 'A sort_order csak egész szám lehet.';
      }

      return Object.keys(this.errors).length === 0;
    },

    async createMenu() {
      this.serverMsg = '';
      this.serverMsgType = 'ok';

      if (!this.validateForm()) return;

      this.saving = true;

      const payload = {
        title: this.form.title,
        url: this.form.url || '',
        parent_id: this.form.parent_id || null,
        sort_order: parseInt(this.form.sort_order || '0', 10),
        is_active: 1
      };

      try {
        const res = await fetch('/api/menus', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        const json = await res.json();

        if (!res.ok) {
          this.serverMsgType = 'err';
          if (json && json.errors) {
            this.errors = { ...this.errors, ...json.errors };
            this.serverMsg = 'Mentési hiba (validáció).';
          } else {
            this.serverMsg = 'Mentési hiba.';
          }
          return;
        }

        this.serverMsgType = 'ok';
        this.serverMsg = 'Mentve, ID: ' + json.id;

        this.form.title = '';
        this.form.url = '';
        this.form.parent_id = '';
        this.form.sort_order = '0';

        await this.loadTree();
      } finally {
        this.saving = false;
      }
    }
  },
  mounted() {
    this.loadTree();
  }
}).mount('#app');
</script>
</body>
</html>
