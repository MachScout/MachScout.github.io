(function () {
  var carouselControllers = [];

  Array.prototype.forEach.call(document.querySelectorAll('[data-carousel]'), function (carousel) {
    var slides = Array.prototype.slice.call(carousel.querySelectorAll('[data-carousel-slide]'));
    var triggers = slides.map(function (slide) { return slide.querySelector('[data-lightbox-trigger]'); });
    var previous = carousel.querySelector('[data-carousel-previous]');
    var next = carousel.querySelector('[data-carousel-next]');
    var current = carousel.querySelector('[data-carousel-current]');
    var total = carousel.querySelector('[data-carousel-total]');
    var controls = carousel.querySelector('.media-carousel__controls');
    var activeIndex = 0;
    var touchStartX = null;

    if (!slides.length) return;

    function showSlide(index) {
      activeIndex = (index + slides.length) % slides.length;
      slides.forEach(function (slide, slideIndex) {
        var isActive = slideIndex === activeIndex;
        slide.hidden = !isActive;
        slide.setAttribute('aria-hidden', isActive ? 'false' : 'true');
        slide.setAttribute('aria-label', String(slideIndex + 1) + ' of ' + String(slides.length));
      });
      if (current) current.textContent = String(activeIndex + 1);
      if (total) total.textContent = String(slides.length);
    }

    if (previous) previous.addEventListener('click', function () { showSlide(activeIndex - 1); });
    if (next) next.addEventListener('click', function () { showSlide(activeIndex + 1); });

    carousel.addEventListener('keydown', function (event) {
      if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
      event.preventDefault();
      showSlide(activeIndex + (event.key === 'ArrowRight' ? 1 : -1));
    });

    carousel.addEventListener('touchstart', function (event) {
      touchStartX = event.changedTouches[0].clientX;
    });

    carousel.addEventListener('touchend', function (event) {
      if (touchStartX === null) return;
      var distance = event.changedTouches[0].clientX - touchStartX;
      touchStartX = null;
      if (Math.abs(distance) < 50) return;
      showSlide(activeIndex + (distance < 0 ? 1 : -1));
    });

    showSlide(0);
    if (controls) controls.hidden = false;
    carouselControllers.push({
      triggers: triggers,
      showSlide: showSlide
    });
  });

  var lightbox = document.querySelector('[data-lightbox]');
  if (!lightbox) return;

  var image = lightbox.querySelector('[data-lightbox-image]');
  var caption = lightbox.querySelector('[data-lightbox-caption]');
  var close = lightbox.querySelector('[data-lightbox-close]');
  var lightboxPrevious = lightbox.querySelector('[data-lightbox-previous]');
  var lightboxNext = lightbox.querySelector('[data-lightbox-next]');
  var lightboxCurrent = lightbox.querySelector('[data-lightbox-current]');
  var lightboxTotal = lightbox.querySelector('[data-lightbox-total]');
  var lightboxControls = lightbox.querySelector('[data-lightbox-controls]');
  var opener = null;
  var openedByKeyboard = false;
  var lightboxItems = [];
  var lightboxIndex = 0;
  var activeCarousel = null;
  var lightboxTouchStartX = null;

  function showLightboxItem(index) {
    var trigger;

    if (!lightboxItems.length) return;
    lightboxIndex = (index + lightboxItems.length) % lightboxItems.length;
    trigger = lightboxItems[lightboxIndex];
    opener = trigger;
    image.src = trigger.dataset.lightboxSrc;
    image.alt = trigger.dataset.lightboxAlt || '';
    caption.textContent = trigger.dataset.lightboxCaption || '';
    caption.hidden = !caption.textContent;
    if (lightboxCurrent) lightboxCurrent.textContent = String(lightboxIndex + 1);
    if (lightboxTotal) lightboxTotal.textContent = String(lightboxItems.length);
    if (lightboxControls) lightboxControls.hidden = lightboxItems.length < 2;
    if (activeCarousel) activeCarousel.showSlide(lightboxIndex);
  }

  Array.prototype.forEach.call(document.querySelectorAll('[data-lightbox-trigger]'), function (trigger) {
    trigger.addEventListener('click', function (event) {
      var itemIndex = -1;

      event.preventDefault();
      opener = trigger;
      openedByKeyboard = event.detail === 0;
      lightbox.classList.toggle('media-lightbox--pointer', !openedByKeyboard);
      activeCarousel = null;
      carouselControllers.some(function (controller) {
        itemIndex = controller.triggers.indexOf(trigger);
        if (itemIndex < 0) return false;
        activeCarousel = controller;
        return true;
      });
      lightboxItems = activeCarousel ? activeCarousel.triggers : [trigger];
      showLightboxItem(activeCarousel ? itemIndex : 0);
      lightbox.showModal();
    });
  });

  if (lightboxPrevious) lightboxPrevious.addEventListener('click', function () { showLightboxItem(lightboxIndex - 1); });
  if (lightboxNext) lightboxNext.addEventListener('click', function () { showLightboxItem(lightboxIndex + 1); });

  lightbox.addEventListener('keydown', function (event) {
    if (lightboxItems.length < 2 || (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight')) return;
    event.preventDefault();
    showLightboxItem(lightboxIndex + (event.key === 'ArrowRight' ? 1 : -1));
  });

  lightbox.addEventListener('touchstart', function (event) {
    lightboxTouchStartX = event.changedTouches[0].clientX;
  });

  lightbox.addEventListener('touchend', function (event) {
    var distance;

    if (lightboxTouchStartX === null || lightboxItems.length < 2) return;
    distance = event.changedTouches[0].clientX - lightboxTouchStartX;
    lightboxTouchStartX = null;
    if (Math.abs(distance) < 50) return;
    showLightboxItem(lightboxIndex + (distance < 0 ? 1 : -1));
  });

  close.addEventListener('click', function () { lightbox.close(); });
  lightbox.addEventListener('click', function (event) {
    if (event.target === lightbox) lightbox.close();
  });
  lightbox.addEventListener('close', function () {
    var focusTarget = opener;
    var restoreKeyboardFocus = openedByKeyboard;

    image.removeAttribute('src');
    lightbox.classList.remove('media-lightbox--pointer');
    lightboxItems = [];
    activeCarousel = null;
    setTimeout(function () {
      if (restoreKeyboardFocus && focusTarget) focusTarget.focus();
      else if (document.activeElement && document.activeElement.blur) document.activeElement.blur();
    }, 0);
  });
}());
