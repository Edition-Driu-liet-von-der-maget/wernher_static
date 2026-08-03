(function () {
  'use strict';

  // Path to the JSON with witness snippet metadata, relative to the HTML files
  var SNIPPET_JSON_PATH = 'witness_snippets/snippet_paths.json';
  function buildSiglumMap(data) {
    var map = {};
    Object.keys(data || {}).forEach(function (witnessId) {
      var entry = data[witnessId] || {};
      var filepath = entry.filepath || '';
      if (!filepath) {
        return;
      }
      // Extract basename, e.g. "witness_snippets/E.html" -> "E"
      var parts = filepath.split('/');
      var basename = parts[parts.length - 1] || '';
      var dotIndex = basename.lastIndexOf('.');
      if (dotIndex !== -1) {
        basename = basename.substring(0, dotIndex);
      }
      if (!basename) {
        return;
      }
      // Use basename as siglum key
      map[basename] = witnessId;
    });
    return map;
  }

  function initDoubleClickHandler(siglumToId) {
    if (!siglumToId) {
      return;
    }

    document.addEventListener('dblclick', function (event) {
      var lineEl = event.target.closest('.tei-line');
      if (!lineEl) {
        return;
      }

      // Line id from id attribute (set in XSLT from @xml:id)
      var lineId = lineEl.getAttribute('id');
      if (!lineId) {
        return;
      }

      // Witness siglum from closest witness container
      var witnessContainer = lineEl.closest('.tei-lg-witness');
      if (!witnessContainer) {
        return;
      }
      var siglum = witnessContainer.getAttribute('data-siglum');
      if (!siglum) {
        return;
      }

      var witnessId = siglumToId[siglum];
      if (!witnessId) {
        console.warn('No witness id found for siglum:', siglum);
        return;
      }

      var url = 'column_viewer.html?witnessIds=' + encodeURIComponent(witnessId) +
                '&currentLine=' + encodeURIComponent(lineId);

      // Open in a new tab/window
      window.open(url, '_blank');
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    fetch(SNIPPET_JSON_PATH)
      .then(function (response) {
        if (!response.ok) {
          throw new Error('Failed to load snippet_paths.json: ' + response.status);
        }
        return response.json();
      })
      .then(function (data) {
        var siglumMap = buildSiglumMap(data);
        initDoubleClickHandler(siglumMap);
      })
      .catch(function (err) {
        console.error(err);
      });
  });
})();
