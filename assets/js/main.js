document.addEventListener('DOMContentLoaded', function () {
  // Mobile navigation
  const toggle = document.querySelector('.nav-toggle');
  const nav = document.getElementById('site-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      const open = nav.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', open);
    });
  }

  // Blog: filter posts by tag, hiding years left empty
  const chips = document.querySelectorAll('.filter .chip');
  chips.forEach(function (chip) {
    chip.addEventListener('click', function () {
      const tag = chip.dataset.tag;
      chips.forEach(function (c) {
        c.classList.toggle('is-active', c === chip);
        c.setAttribute('aria-pressed', c === chip);
      });
      document.querySelectorAll('.year-group').forEach(function (group) {
        let visible = 0;
        group.querySelectorAll('.post-row').forEach(function (row) {
          const show = tag === 'all' || row.dataset.tags.split(',').includes(tag);
          row.hidden = !show;
          if (show) visible++;
        });
        group.hidden = visible === 0;
      });
    });
  });

  // Post: table of contents and reading progress
  const article = document.querySelector('.post-content');
  if (!article) return;

  const headings = Array.from(article.querySelectorAll('h2, h3'))
    .filter(function (h) { return h.textContent.trim() !== ''; });
  const tocNav = document.getElementById('toc');
  const links = [];

  if (tocNav && headings.length >= 2) {
    const list = document.createElement('ul');
    headings.forEach(function (h, i) {
      if (!h.id) h.id = 'section-' + i;
      const li = document.createElement('li');
      li.className = 'toc-' + h.tagName.toLowerCase();
      const a = document.createElement('a');
      a.href = '#' + h.id;
      a.textContent = h.textContent.trim();
      li.appendChild(a);
      list.appendChild(li);
      links.push(a);
    });
    tocNav.appendChild(list);
    tocNav.closest('.post-toc').hidden = false;
  }

  const bar = document.querySelector('.reading-progress');
  let ticking = false;

  function update() {
    const start = article.offsetTop;
    const end = start + article.offsetHeight - window.innerHeight;
    const progress = end > start ? (window.scrollY - start) / (end - start) : 1;
    if (bar) bar.style.transform = 'scaleX(' + Math.max(0, Math.min(1, progress)) + ')';

    let current = -1;
    headings.forEach(function (h, i) {
      if (h.getBoundingClientRect().top < 120) current = i;
    });
    links.forEach(function (a, i) { a.classList.toggle('is-current', i === current); });
    ticking = false;
  }

  window.addEventListener('scroll', function () {
    if (!ticking) {
      window.requestAnimationFrame(update);
      ticking = true;
    }
  }, { passive: true });
  update();
});
