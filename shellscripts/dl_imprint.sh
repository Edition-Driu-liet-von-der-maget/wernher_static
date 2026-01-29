#!/bin/bash

REDMINE_ID="18716?format=xhtml&locale="

# Resolve imprint.xml relative to this script's location (works from any CWD)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMPRINT_XML="${SCRIPT_DIR}/../data/imprint.xml"
IMPRINT_DIR="$(dirname "${IMPRINT_XML}")"

mkdir -p "${IMPRINT_DIR}"

if [[ -f ${IMPRINT_XML} ]]; then
    rm "${IMPRINT_XML}"
fi

# Start XML document
echo '<?xml version="1.0" encoding="UTF-8"?>' > "${IMPRINT_XML}"
echo "<root>" >> "${IMPRINT_XML}"
echo '<div lang="de">' >> "${IMPRINT_XML}"
curl https://imprint.acdh.oeaw.ac.at/${REDMINE_ID}de >> "${IMPRINT_XML}"
echo "</div>"  >> "${IMPRINT_XML}"
echo '<div lang="en">' >> "${IMPRINT_XML}"
curl https://imprint.acdh.oeaw.ac.at/${REDMINE_ID}en >> "${IMPRINT_XML}"
echo "</div>" >> "${IMPRINT_XML}"
echo "</root>" >> "${IMPRINT_XML}"