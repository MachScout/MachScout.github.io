const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");

const source = fs.readFileSync(process.argv[2], "utf8");

const eventTarget = (extra = {}) => {
  const listeners = {};
  return Object.assign({
    listeners,
    addEventListener(name, handler) {
      listeners[name] = handler;
    }
  }, extra);
};

const attributeTarget = (extra = {}) => {
  const attributes = {};
  return eventTarget(Object.assign({
    attributes,
    hidden: false,
    setAttribute(name, value) {
      attributes[name] = value;
    },
    removeAttribute(name) {
      delete attributes[name];
    }
  }, extra));
};

const triggerState = [
  {
    lightboxSrc: "/full/first.jpg",
    lightboxAlt: "First photo",
    lightboxCaption: "First caption."
  },
  {
    lightboxSrc: "/full/second.jpg",
    lightboxAlt: "Second photo",
    lightboxCaption: "Second caption."
  },
  {
    lightboxSrc: "/full/third.jpg",
    lightboxAlt: "Third photo",
    lightboxCaption: "Third caption."
  }
];

let openerFocused = false;
let navigationPrevented = false;
let focusedTrigger = "";
let activeElementBlurred = false;
const pendingTasks = [];
const triggers = triggerState.map((dataset) => eventTarget({
  dataset,
  focus() {
    openerFocused = true;
    focusedTrigger = dataset.lightboxSrc;
  }
}));
const standaloneTrigger = eventTarget({
  dataset: {
    lightboxSrc: "/full/standalone.jpg",
    lightboxAlt: "Standalone photo"
  },
  focus() {
    openerFocused = true;
  }
});
const slides = triggers.map((trigger) => attributeTarget({
  querySelector(selector) {
    return selector === "[data-lightbox-trigger]" ? trigger : null;
  }
}));
const previous = eventTarget();
const next = eventTarget();
const current = { textContent: "" };
const total = { textContent: "" };
const controls = { hidden: true };
const carousel = eventTarget({
  querySelectorAll(selector) {
    return selector === "[data-carousel-slide]" ? slides : [];
  },
  querySelector(selector) {
    return {
      "[data-carousel-previous]": previous,
      "[data-carousel-next]": next,
      "[data-carousel-current]": current,
      "[data-carousel-total]": total,
      ".media-carousel__controls": controls
    }[selector] || null;
  }
});
const lightboxImage = attributeTarget({ src: "", alt: "" });
const lightboxCaption = { textContent: "", hidden: true };
const close = eventTarget();
const lightboxPrevious = eventTarget();
const lightboxNext = eventTarget();
const lightboxCurrent = { textContent: "" };
const lightboxTotal = { textContent: "" };
const lightboxControls = { hidden: true };
const lightboxClasses = new Set();
const lightbox = eventTarget({
  open: false,
  classList: {
    toggle(name, force) {
      if (force) lightboxClasses.add(name);
      else lightboxClasses.delete(name);
    },
    remove(name) {
      lightboxClasses.delete(name);
    }
  },
  querySelector(selector) {
    return {
      "[data-lightbox-image]": lightboxImage,
      "[data-lightbox-caption]": lightboxCaption,
      "[data-lightbox-close]": close,
      "[data-lightbox-previous]": lightboxPrevious,
      "[data-lightbox-next]": lightboxNext,
      "[data-lightbox-current]": lightboxCurrent,
      "[data-lightbox-total]": lightboxTotal,
      "[data-lightbox-controls]": lightboxControls
    }[selector] || null;
  },
  showModal() {
    this.open = true;
  },
  close() {
    this.open = false;
    this.listeners.close();
  }
});

const context = {
  setTimeout(handler) {
    pendingTasks.push(handler);
  },
  document: {
    activeElement: {
      blur() {
        activeElementBlurred = true;
      }
    },
    querySelectorAll(selector) {
      return {
        "[data-carousel]": [carousel],
        "[data-lightbox-trigger]": triggers.concat([standaloneTrigger])
      }[selector] || [];
    },
    querySelector(selector) {
      return selector === "[data-lightbox]" ? lightbox : null;
    }
  }
};

vm.runInNewContext(source, context);

assert.equal(slides[0].hidden, false);
assert.equal(slides[1].hidden, true);
assert.equal(slides[0].attributes["aria-hidden"], "false");
assert.equal(slides[0].attributes["aria-label"], "1 of 3");
assert.equal(current.textContent, "1");
assert.equal(total.textContent, "3");
assert.equal(controls.hidden, false);

next.listeners.click();
assert.equal(slides[0].hidden, true);
assert.equal(slides[1].hidden, false);
assert.equal(current.textContent, "2");

carousel.listeners.keydown({ key: "ArrowLeft", preventDefault() {} });
assert.equal(slides[0].hidden, false);
assert.equal(current.textContent, "1");

carousel.listeners.touchstart({ changedTouches: [{ clientX: 200 }] });
carousel.listeners.touchend({ changedTouches: [{ clientX: 100 }] });
assert.equal(slides[1].hidden, false);

triggers[1].listeners.click({ detail: 1, preventDefault() { navigationPrevented = true; } });
assert.equal(navigationPrevented, true);
assert.equal(lightbox.open, true);
assert.equal(lightboxImage.src, "/full/second.jpg");
assert.equal(lightboxImage.alt, "Second photo");
assert.equal(lightboxCaption.textContent, "Second caption.");
assert.equal(lightboxCaption.hidden, false);
assert.equal(lightboxControls.hidden, false);
assert.equal(lightboxCurrent.textContent, "2");
assert.equal(lightboxTotal.textContent, "3");
assert.equal(lightboxClasses.has("media-lightbox--pointer"), true);

lightboxNext.listeners.click();
assert.equal(lightboxImage.src, "/full/third.jpg");
assert.equal(lightboxCurrent.textContent, "3");
assert.equal(slides[2].hidden, false);
assert.equal(current.textContent, "3");

lightboxPrevious.listeners.click();
assert.equal(lightboxImage.src, "/full/second.jpg");
assert.equal(lightboxCurrent.textContent, "2");

lightbox.listeners.keydown({ key: "ArrowLeft", preventDefault() {} });
assert.equal(lightboxImage.src, "/full/first.jpg");
assert.equal(lightboxCurrent.textContent, "1");

lightbox.listeners.touchstart({ changedTouches: [{ clientX: 200 }] });
lightbox.listeners.touchend({ changedTouches: [{ clientX: 100 }] });
assert.equal(lightboxImage.src, "/full/second.jpg");

close.listeners.click();
assert.equal(lightbox.open, false);
assert.equal(pendingTasks.length, 1);
pendingTasks.shift()();
assert.equal(activeElementBlurred, true);
assert.equal(openerFocused, false);

activeElementBlurred = false;
standaloneTrigger.listeners.click({ detail: 1, preventDefault() {} });
assert.equal(lightboxImage.src, "/full/standalone.jpg");
assert.equal(lightboxControls.hidden, true);
assert.equal(lightboxCurrent.textContent, "1");
assert.equal(lightboxTotal.textContent, "1");
close.listeners.click();
assert.equal(pendingTasks.length, 1);
pendingTasks.shift()();
assert.equal(activeElementBlurred, true);

triggers[0].listeners.click({ detail: 0, preventDefault() {} });
assert.equal(lightboxClasses.has("media-lightbox--pointer"), false);
lightboxNext.listeners.click();
close.listeners.click();
assert.equal(openerFocused, false);
assert.equal(pendingTasks.length, 1);
pendingTasks.shift()();
assert.equal(openerFocused, true);
assert.equal(focusedTrigger, "/full/second.jpg");
