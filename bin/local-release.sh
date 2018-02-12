#!/bin/bash

#Move to the folder where ep-lite is installed
cd `dirname $0`

#Was this script started in the bin folder? if yes move out
if [ -d "../bin" ]; then
  cd "../"
fi

sed -i 's/npm install --loglevel warn/npm install --no-bin-links --loglevel warn/g' bin/installDeps.sh
./bin/installDeps.sh
echo "web: bin/run.sh" > Procfile
mv node_modules/ep_etherpad-lite/node_modules/ep_* node_modules
cp -R node_modules/ep_etherpad-lite/node_modules/log4js node_modules/
rm node_modules/ep_etherpad-lite
rm src/package.json && mv src/package-no-plugin.json src/package.json
npm install --no-bin-link
sed -i 's/npm install --no-bin-links --loglevel warn//g' bin/installDeps.sh
# zip -r etherpad-lite-cf ./*

