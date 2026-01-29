# bin/bash
EDITIONS_FOLDER="data/editions"
ZIP_URL="https://github.com/Edition-Driu-liet-von-der-maget/initial_parsing/archive/refs/heads/main.zip"
ZIP_MAIN_FOLDER="./initial_parsing-main"
ZIP_EDITIONS_FOLDER="${ZIP_MAIN_FOLDER}/tei"


echo "fetching transkriptions from data_repo"
rm -rf ${EDITIONS_FOLDER}
curl -LO ${ZIP_URL}
unzip main.zip

mv ${ZIP_EDITIONS_FOLDER} ${EDITIONS_FOLDER}
rm main.zip
rm -rf ${ZIP_MAIN_FOLDER}

echo "fetch imprint"
./shellscripts/dl_imprint.sh

echo "fetch metadata"
./shellscripts/dl_metadata.sh