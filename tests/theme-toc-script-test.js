const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");

const source = fs.readFileSync(process.argv[2], "utf8");
const listeners = {};
const positions = { introduction: -80, details: 480, conclusion: 880 };
const linkPositions = { "#introduction": 120, "#details": 700, "#conclusion": 980 };

const makeItem = (parentElement) => {
  const attributes = {};
  return {
    tagName: "LI",
    parentElement,
    attributes,
    setAttribute(name, value) {
      attributes[name] = value;
    },
    removeAttribute(name) {
      delete attributes[name];
    }
  };
};

const rootList = { tagName: "UL", parentElement: null };
const introductionItem = makeItem(rootList);
const nestedList = { tagName: "UL", parentElement: introductionItem };
const detailsItem = makeItem(nestedList);
const conclusionItem = makeItem(rootList);
const items = [introductionItem, detailsItem, conclusionItem];
const toc = {
  clientHeight: 412,
  scrollTop: 0,
  getBoundingClientRect: () => ({ top: 88, bottom: 500 }),
  querySelectorAll: (selector) => selector === 'a[href^="#"]' ? links : items.filter((item) => item.attributes["data-toc-active"])
};
rootList.parentElement = toc;

const makeLink = (hash, parentElement) => {
  const attributes = {};
  return {
    hash,
    parentElement,
    attributes,
    getAttribute(name) {
      return name === "href" ? hash : attributes[name];
    },
    setAttribute(name, value) {
      attributes[name] = value;
    },
    removeAttribute(name) {
      delete attributes[name];
    },
    getBoundingClientRect() {
      const top = linkPositions[hash] - toc.scrollTop;
      return { top, bottom: top + 24 };
    }
  };
};

const links = [
  makeLink("#introduction", introductionItem),
  makeLink("#details", detailsItem),
  makeLink("#conclusion", conclusionItem)
];
const headings = Object.fromEntries(Object.keys(positions).map((id) => [
  id,
  { getBoundingClientRect: () => ({ top: positions[id] }) }
]));

const context = {
  document: {
    querySelector: (selector) => selector === "[data-toc]" ? toc : null,
    getElementById: (id) => headings[id] || null
  },
  window: {
    innerHeight: 800,
    addEventListener: (name, handler) => {
      listeners[name] = handler;
    }
  },
  decodeURIComponent,
  requestAnimationFrame: (callback) => callback()
};

vm.runInNewContext(source, context);

assert.equal(links[0].attributes["aria-current"], "location");
assert.equal(links[1].attributes["aria-current"], undefined);
assert.equal(introductionItem.attributes["data-toc-active"], "true");
assert.equal(detailsItem.attributes["data-toc-active"], undefined);

positions.details = 120;
listeners.scroll();

assert.equal(links[0].attributes["aria-current"], undefined);
assert.equal(links[1].attributes["aria-current"], "location");
assert.equal(introductionItem.attributes["data-toc-active"], "true");
assert.equal(detailsItem.attributes["data-toc-active"], "true");
assert.equal(toc.scrollTop, 232);

positions.conclusion = 120;
listeners.scroll();

assert.equal(introductionItem.attributes["data-toc-active"], undefined);
assert.equal(detailsItem.attributes["data-toc-active"], undefined);
assert.equal(conclusionItem.attributes["data-toc-active"], "true");
