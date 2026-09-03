(function () {
  'use strict';

  var VIEWER_ID = 'edition-facs-viewer';
  var DISCLAIMER_ID = 'edition-facs-disclaimer';
  var LABEL_ID = 'edition-facs-label';
  var PREV_ID = 'edition-facs-prev';
  var NEXT_ID = 'edition-facs-next';
  var TOOLBAR_SELECTOR = '.edition-toolbar';
  // Extra breathing room below the sticky toolbar so the first lines of a
  // page are still readable (not flush against the toolbar) before the
  // switch/landing logic considers them "current".
  var TOOLBAR_BUFFER = 24;
  // Distance from the viewport top below which a page break counts as the
  // "current" page. Recomputed from the sticky toolbar's actual height (see
  // updateToolbarOffset), since that height can change (wrapping, added
  // controls). Also drives .edition-facs-sticky { top } via a CSS variable
  // so the image flips as the previous page scrolls out from under it.
  var TOP_OFFSET = 72;
  // Landing position (px from viewport top) when the prev/next buttons jump
  // the text. Kept clearly below TOP_OFFSET so the sync logic can never
  // mistake the target page for the previous one due to subpixel rounding.
  var LANDING_OFFSET = TOP_OFFSET - 32;

  function updateToolbarOffset() {
    var toolbar = document.querySelector(TOOLBAR_SELECTOR);
    var toolbarHeight = toolbar ? toolbar.getBoundingClientRect().height : 0;
    TOP_OFFSET = toolbarHeight + TOOLBAR_BUFFER;
    LANDING_OFFSET = toolbarHeight + 8;
    document.documentElement.style.setProperty(
      '--edition-toolbar-offset',
      TOP_OFFSET + 'px'
    );
  }

  function init() {
    updateToolbarOffset();
    var viewerEl = document.getElementById(VIEWER_ID);
    if (!viewerEl || !window.OpenSeadragon) {
      return;
    }

    // Page-break markers in document order. Each carries the folio label
    // (data-curr) and the IIIF info.json URL (data-src) emitted by the XSLT.
    var pages = Array.prototype.slice
      .call(document.querySelectorAll('.pb[data-src]'))
      .filter(function (el) {
        return !!el.getAttribute('data-src');
      })
      .map(function (el) {
        return {
          label: el.getAttribute('data-curr') || '',
          facs: el.getAttribute('data-facs') || '',
          src: el.getAttribute('data-src'),
          el: el
        };
      });

    if (!pages.length) {
      return;
    }

    var labelEl = document.getElementById(LABEL_ID);
    var disclaimerEl = document.getElementById(DISCLAIMER_ID);
    var prevBtn = document.getElementById(PREV_ID);
    var nextBtn = document.getElementById(NEXT_ID);
    var syncBtn = document.getElementById('toggle-facs-sync');
    var currentIndex = -1;
    var syncEnabled = true;
    var disclaimerCache = Object.create(null);
    var disclaimerRequestToken = 0;
    // While decoupled, tracks which side the user last moved ('text' via
    // scrolling, 'image' via the prev/next buttons), so re-enabling sync
    // knows which side should follow the other.
    var lastAction = null;

    var viewer = window.OpenSeadragon({
      id: VIEWER_ID,
      prefixUrl: 'vendor/openseadragon-bin-4.1.1/images/',
      showNavigationControl: false,
      showHomeControl: false,
      showZoomControl: true,
      showFullPageControl: false,
      immediateRender: true,
      animationTime: 0,
      blendTime: 0,
      visibilityRatio: 1,
      constrainDuringPan: true
    });

    function iiifText(value) {
      if (!value) {
        return '';
      }
      if (typeof value === 'string') {
        return value.trim();
      }
      if (Array.isArray(value)) {
        for (var i = 0; i < value.length; i++) {
          var arrayText = iiifText(value[i]);
          if (arrayText) {
            return arrayText;
          }
        }
        return '';
      }
      if (typeof value === 'object') {
        if (value['@value']) {
          return iiifText(value['@value']);
        }
        var keys = Object.keys(value);
        for (var j = 0; j < keys.length; j++) {
          var objectText = iiifText(value[keys[j]]);
          if (objectText) {
            return objectText;
          }
        }
      }
      return '';
    }

    function firstDisclaimer(info) {
      if (!info || typeof info !== 'object') {
        return '';
      }
      var candidates = [
        iiifText(info.requiredStatement && info.requiredStatement.value),
        iiifText(info.attribution),
        iiifText(info.rights),
        iiifText(info.license)
      ];
      for (var i = 0; i < candidates.length; i++) {
        if (candidates[i]) {
          return candidates[i];
        }
      }
      if (Array.isArray(info.metadata)) {
        var firstUrlValue = '';
        for (var j = 0; j < info.metadata.length; j++) {
          var entry = info.metadata[j] || {};
          var label = iiifText(entry.label).toLowerCase();
          var value = iiifText(entry.value);
          if (!value) {
            continue;
          }
          if (/copyright|rights|license|lizenz|attribution|nachweis|quelle|source/.test(label)) {
            return value;
          }
          if (!firstUrlValue && value.indexOf('http') !== -1) {
            firstUrlValue = value;
          }
        }
        if (firstUrlValue) {
          return firstUrlValue;
        }
      }
      return '';
    }

    function renderDisclaimer(text) {
      if (!disclaimerEl) {
        return;
      }
      disclaimerEl.textContent = '';
      if (!text) {
        return;
      }
      var last = 0;
      var urlRegex = /https?:\/\/[^\s<>"')]+/g;
      var match = null;
      while ((match = urlRegex.exec(text)) !== null) {
        if (match.index > last) {
          disclaimerEl.appendChild(document.createTextNode(text.slice(last, match.index)));
        }
        var link = document.createElement('a');
        link.href = match[0];
        link.textContent = match[0];
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
        disclaimerEl.appendChild(link);
        last = match.index + match[0].length;
      }
      if (last < text.length) {
        disclaimerEl.appendChild(document.createTextNode(text.slice(last)));
      }
    }

    function updateDisclaimer(src) {
      if (!disclaimerEl || !src) {
        return;
      }
      if (Object.prototype.hasOwnProperty.call(disclaimerCache, src)) {
        renderDisclaimer(disclaimerCache[src]);
        return;
      }
      var requestToken = ++disclaimerRequestToken;
      fetch(src)
        .then(function (response) {
          if (!response.ok) {
            throw new Error('Failed to load IIIF info.json');
          }
          return response.json();
        })
        .then(function (info) {
          var text = firstDisclaimer(info);
          disclaimerCache[src] = text;
          if (requestToken === disclaimerRequestToken) {
            renderDisclaimer(text);
          }
        })
        .catch(function () {
          disclaimerCache[src] = '';
          if (requestToken === disclaimerRequestToken) {
            renderDisclaimer('');
          }
        });
    }

    function showPage(index) {
      index = Math.max(0, Math.min(pages.length - 1, index));
      if (index === currentIndex) {
        return;
      }
      currentIndex = index;
      var page = pages[index];

      if (labelEl) {
        labelEl.textContent = page.label ? 'Bl. ' + page.label : '';
      }
      if (prevBtn) {
        prevBtn.disabled = index === 0;
      }
      if (nextBtn) {
        nextBtn.disabled = index === pages.length - 1;
      }

      // Pass the info.json URL; OSD fetches it and detects the IIIF Image
      // API v3 service. Switching pages re-opens the viewer with that page.
      viewer.open(page.src);
      updateDisclaimer(page.src);
    }

    // Jump the text to the position of the given page. The viewer is then
    // synced from the actual scroll position (single source of truth), so the
    // scroll event that follows can never revert the image to another page.
    function scrollToPage(index) {
      index = Math.max(0, Math.min(pages.length - 1, index));
      if (index === currentIndex) {
        return;
      }
      var page = pages[index];
      var y = Math.max(0, page.el.getBoundingClientRect().top + window.scrollY - LANDING_OFFSET);
      window.scrollTo({ top: y, behavior: 'instant' });
      showPage(getActiveIndex());
    }

    function getActiveIndex() {
      var active = 0;
      // Markers follow the reading order (top to bottom), so the first marker
      // below the offset ends the scan.
      for (var i = 0; i < pages.length; i++) {
        if (pages[i].el.getBoundingClientRect().top <= TOP_OFFSET) {
          active = i;
        } else {
          break;
        }
      }
      return active;
    }

    function update() {
      // Runs synchronously: scroll events are already coalesced to the frame
      // rate, and this also works when the page first paints in a background
      // tab (where requestAnimationFrame would be paused).
      if (!syncEnabled) {
        return;
      }
      showPage(getActiveIndex());
    }

    // Re-align the text with whatever page the facsimile currently shows,
    // bypassing scrollToPage's "already there" guard (text may have drifted
    // while sync was off).
    function resyncTextToImage() {
      var page = pages[currentIndex];
      if (!page) {
        return;
      }
      var y = Math.max(0, page.el.getBoundingClientRect().top + window.scrollY - LANDING_OFFSET);
      window.scrollTo({ top: y, behavior: 'instant' });
    }

    function setSync(enabled) {
      syncEnabled = enabled;
      if (syncBtn) {
        syncBtn.setAttribute('aria-pressed', enabled ? 'true' : 'false');
      }
      if (enabled) {
        // Whichever side moved last while decoupled now drives the other;
        // with no prior action, default to the old "text follows image".
        if (lastAction === 'text') {
          showPage(getActiveIndex());
        } else {
          resyncTextToImage();
        }
        lastAction = null;
      }
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', function () {
        if (syncEnabled) {
          scrollToPage(currentIndex - 1);
        } else {
          lastAction = 'image';
          showPage(currentIndex - 1);
        }
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', function () {
        if (syncEnabled) {
          scrollToPage(currentIndex + 1);
        } else {
          lastAction = 'image';
          showPage(currentIndex + 1);
        }
      });
    }
    if (syncBtn) {
      syncBtn.addEventListener('click', function () {
        setSync(!syncEnabled);
      });
    }

    window.addEventListener('scroll', function () {
      if (!syncEnabled) {
        lastAction = 'text';
        return;
      }
      update();
    }, { passive: true });
    window.addEventListener('resize', function () {
      // Toolbar can wrap onto a second line at narrow widths, changing its
      // height, so the offset must be recomputed (not just re-applied).
      updateToolbarOffset();
      update();
    });

    // Anchor-link loads: the browser may already have scrolled to #v_N before
    // this script runs, so recompute once the page and its layout are ready.
    window.addEventListener('load', update);
    // Also fires on bfcache restore / after scroll position is restored.
    window.addEventListener('pageshow', update);
    window.addEventListener('hashchange', function () {
      window.setTimeout(update, 0);
    });

    // First paint: render the page for the current scroll position now.
    update();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
