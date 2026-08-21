#!/usr/bin/env bash
set -euo pipefail
DATA_FOLDER="data"
META_DATA_FOLDER="${DATA_FOLDER}/meta"
EDITIONS_FOLDER="${DATA_FOLDER}/editions"
ZIP_URL="https://github.com/Edition-Driu-liet-von-der-maget/initial_parsing/archive/refs/heads/main.zip"
ZIP_MAIN_FOLDER="./initial_parsing-main"
ZIP_EDITIONS_FOLDER="${ZIP_MAIN_FOLDER}/tei"
ZIP_WITNESS_FILE="${ZIP_MAIN_FOLDER}/metadata/snippet_paths.json"

echo "fetching transkriptions from data_repo"
rm -rf "${EDITIONS_FOLDER}"
curl -LO "${ZIP_URL}"
unzip -q main.zip

if [ ! -d "${ZIP_EDITIONS_FOLDER}" ]; then
	echo "ERROR: ${ZIP_EDITIONS_FOLDER} not found in downloaded ZIP (does initial_parsing/main contain the tei/ directory?)" >&2
	exit 1
fi

if [ ! -d "${DATA_FOLDER}" ]; then
    mkdir "${DATA_FOLDER}"
fi

if [ ! -d "${META_DATA_FOLDER}" ]; then
    mkdir "${META_DATA_FOLDER}"
fi

mv "${ZIP_EDITIONS_FOLDER}" "${EDITIONS_FOLDER}"
mv "${ZIP_WITNESS_FILE}" "${META_DATA_FOLDER}/snippet_paths.json"
rm main.zip
rm -rf "${ZIP_MAIN_FOLDER}"

echo "fetch imprint"
./shellscripts/dl_imprint.sh

echo "fetch metadata"
./shellscripts/dl_metadata.sh