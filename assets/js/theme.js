(function () {
  var storageKey = 'color-theme';
  var query = window.matchMedia('(prefers-color-scheme: dark)');
  var button = document.querySelector('[data-theme-toggle]');
  var status = button && button.querySelector('[data-theme-status]');
  var saved;

  try {
    saved = localStorage.getItem(storageKey);
  } catch (error) {
    saved = null;
  }

  var followsSystem = saved !== 'light' && saved !== 'dark';
  var mode = followsSystem ? (query.matches ? 'dark' : 'light') : saved;

  function nextLabel() {
    if (mode === 'light') return 'Switch color theme to dark';
    return 'Switch color theme to light';
  }

  function update() {
    document.documentElement.dataset.theme = mode;
    if (!button) return;
    button.dataset.themeMode = mode;
    button.setAttribute('aria-label', nextLabel());
    button.title = button.getAttribute('aria-label');
    if (status) status.textContent = (mode === 'dark' ? 'Dark' : 'Light') + ' color theme';
  }

  function persist() {
    try {
      localStorage.setItem(storageKey, mode);
    } catch (error) {
      // Theme selection remains usable when storage is unavailable.
    }
  }

  if (button) {
    button.addEventListener('click', function () {
      mode = mode === 'light' ? 'dark' : 'light';
      followsSystem = false;
      persist();
      update();
    });
  }

  query.addEventListener('change', function () {
    if (!followsSystem) return;
    mode = query.matches ? 'dark' : 'light';
    update();
  });
  update();
}());
