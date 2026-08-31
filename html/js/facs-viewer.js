(function () {
  'use strict';

  var VIEWER_ID = 'edition-facs-viewer';
  var LABEL_ID = 'edition-facs-label';
  var PREV_ID = 'edition-facs-prev';
  var NEXT_ID = 'edition-facs-next';
  // Distance from the viewport top below which a page break counts as the
  // "current" page. Keep in sync with .edition-facs-sticky { top } so the
  // image flips as the previous page scrolls out from under the sticky viewer.
  var TOP_OFFSET = 72;
  // Landing position (px from viewport top) when the prev/next buttons jump
  // the text. Kept clearly below TOP_OFFSET so the sync logic can never
  // mistake the target page for the previous one due to subpixel rounding.
  var LANDING_OFFSET = TOP_OFFSET - 32;

  function init() {
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
    var prevBtn = document.getElementById(PREV_ID);
    var nextBtn = document.getElementById(NEXT_ID);
    var currentIndex = -1;

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
      showPage(getActiveIndex());
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', function () {
        scrollToPage(currentIndex - 1);
      });
    }
    if (nextBtn) {
      nextBtn.addEventListener('click', function () {
        scrollToPage(currentIndex + 1);
      });
    }

    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);

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
