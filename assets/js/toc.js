(function () {
  var toc = document.querySelector('[data-toc]');
  if (!toc) return;

  var links = Array.prototype.slice.call(toc.querySelectorAll('a[href^="#"]'));
  var sections = links.map(function (link) {
    var id = decodeURIComponent(link.getAttribute('href').slice(1));
    return { link: link, heading: document.getElementById(id) };
  }).filter(function (section) {
    return section.heading;
  });
  if (!sections.length) return;

  var scheduled = false;

  function keepActiveLinkVisible(link) {
    var tocRect = toc.getBoundingClientRect();
    if (tocRect.bottom <= 0 || tocRect.top >= window.innerHeight) return;

    var linkRect = link.getBoundingClientRect();
    if (linkRect.top < tocRect.top) toc.scrollTop -= tocRect.top - linkRect.top + 8;
    else if (linkRect.bottom > tocRect.bottom) toc.scrollTop += linkRect.bottom - tocRect.bottom + 8;
  }

  function updateActiveBranch(link) {
    Array.prototype.forEach.call(toc.querySelectorAll('li[data-toc-active]'), function (item) {
      item.removeAttribute('data-toc-active');
    });

    var parent = link.parentElement;
    while (parent && parent !== toc) {
      if (parent.tagName === 'LI') parent.setAttribute('data-toc-active', 'true');
      parent = parent.parentElement;
    }
  }

  function updateActiveLink() {
    var activationLine = Math.min(200, window.innerHeight * 0.25);
    var active = sections[0];

    sections.forEach(function (section) {
      if (section.heading.getBoundingClientRect().top <= activationLine) active = section;
    });

    links.forEach(function (link) {
      if (link === active.link) link.setAttribute('aria-current', 'location');
      else link.removeAttribute('aria-current');
    });
    updateActiveBranch(active.link);
    keepActiveLinkVisible(active.link);
    scheduled = false;
  }

  function scheduleUpdate() {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(updateActiveLink);
  }

  window.addEventListener('scroll', scheduleUpdate, { passive: true });
  window.addEventListener('resize', scheduleUpdate);
  window.addEventListener('hashchange', scheduleUpdate);
  updateActiveLink();
}());
