(function () {
  var toggle = document.querySelector('[data-nav-toggle]');
  var navigation = document.querySelector('[data-site-nav]');
  if (!toggle || !navigation) return;

  function close() {
    toggle.setAttribute('aria-expanded', 'false');
    navigation.dataset.open = 'false';
  }

  toggle.addEventListener('click', function () {
    var open = toggle.getAttribute('aria-expanded') !== 'true';
    toggle.setAttribute('aria-expanded', String(open));
    navigation.dataset.open = String(open);
  });

  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape' || navigation.dataset.open !== 'true') return;
    var focusWasInMenu = navigation.contains(document.activeElement);
    close();
    if (focusWasInMenu) toggle.focus();
  });

  navigation.addEventListener('click', function (event) {
    if (event.target.closest('a')) close();
  });
}());
