<!doctype html>
<html lang="hu">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div id="app" class="container py-5" style="max-width: 520px;">
  <div class="card shadow-sm">
    <div class="card-body p-4">
      <h1 class="h4 mb-3">Bejelentkezés</h1>

      <form method="post" action="/login" @submit="onSubmit">
        <?= csrf_field() ?>

        <div class="mb-3">
          <label class="form-label">Nickname</label>
          <input name="nickname" class="form-control" v-model.trim="nickname" value="<?= esc(old('nickname')) ?>" />
          <div v-if="errors.nickname" class="text-danger small mt-1">{{ errors.nickname }}</div>
        </div>

        <div class="mb-3">
          <label class="form-label">Jelszó</label>
          <input type="password" name="password" class="form-control" v-model="password" />
          <div v-if="errors.password" class="text-danger small mt-1">{{ errors.password }}</div>
        </div>

        <button class="btn btn-primary w-100">Belépés</button>
      </form>
    </div>
  </div>

  <!-- Bootstrap Toasts (growl) -->
  <div class="toast-container position-fixed top-0 end-0 p-3">
    <?php if (session()->getFlashdata('flash_success')): ?>
      <div class="toast align-items-center text-bg-success border-0 show" role="alert">
        <div class="d-flex">
          <div class="toast-body"><?= esc(session()->getFlashdata('flash_success')) ?></div>
          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
      </div>
    <?php endif; ?>

    <?php if (session()->getFlashdata('flash_error')): ?>
      <div class="toast align-items-center text-bg-danger border-0 show" role="alert">
        <div class="d-flex">
          <div class="toast-body"><?= esc(session()->getFlashdata('flash_error')) ?></div>
          <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
      </div>
    <?php endif; ?>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/vue@3.4.38/dist/vue.global.prod.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const { createApp } = Vue;

createApp({
  data() {
    return {
      nickname: "<?= esc(old('nickname') ?? '') ?>",
      password: "",
      errors: {}
    };
  },
  methods: {
    onSubmit(e) {
      this.errors = {};

      if (!this.nickname || this.nickname.length < 3) {
        this.errors.nickname = "A nickname kötelező (min. 3 karakter).";
      }

      if (!this.password || this.password.length < 4) {
        this.errors.password = "A jelszó kötelező (min. 4 karakter).";
      }

      if (Object.keys(this.errors).length > 0) {
        // kliens oldali validáció - maradunk az oldalon
        e.preventDefault();
      }
    }
  }
}).mount("#app");
</script>
</body>
</html>
