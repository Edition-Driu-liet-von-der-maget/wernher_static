(function () {
  'use strict';

  var GLOBAL_KEY = 'edition-hide-global-versnr'; // "1" = hidden
  var LOCAL_KEY = 'edition-show-local-versnr';   // "1" = shown

  function init() {
    var globalBtn = document.getElementById('toggle-global-vers-numbers');
    var localBtn = document.getElementById('toggle-local-vers-numbers');

    function applyState() {
      document.body.classList.toggle('hide-global-vers-numbers', hideGlobal);
      document.body.classList.toggle('show-local-vers-numbers', showLocal);
      if (globalBtn) {
        globalBtn.setAttribute('aria-pressed', hideGlobal ? 'false' : 'true');
      }
      if (localBtn) {
        localBtn.setAttribute('aria-pressed', showLocal ? 'true' : 'false');
      }
    }

    applyState();

    if (globalBtn) {
      globalBtn.addEventListener('click', function () {
        hideGlobal = !hideGlobal;
        applyState();
      });
    }

    if (localBtn) {
      localBtn.addEventListener('click', function () {
        showLocal = !showLocal;
        applyState();
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
