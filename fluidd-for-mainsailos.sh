#!/bin/bash
#download fluidd
cd ~
LATEST_VERSION=$(curl -L -s -H 'Accept: application/json' https://github.com/fluidd-core/fluidd/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
ARTIFACT_URL="https://github.com/fluidd-core/fluidd/releases/download/$LATEST_VERSION/fluidd.zip"
echo Downloading fluidd $LATEST_VERSION
echo $ARTIFACT_URL
curl $ARTIFACT_URL -L --output /tmp/fluidd.zip
unzip -qo /tmp/fluidd.zip -d ~/fluidd
rm /tmp/fluidd.zip
rm -rf ~/mainsail
ln -sf ~/fluidd ~/mainsail
 
#modfify moonraker.conf
if [[ $(grep -L fluidd-core/fluidd $HOME/printer_data/config/moonraker.conf) ]]; then
 Updating $HOME/printer_data/config/moonraker.conf
 cp $HOME/printer_data/config/moonraker.conf $HOME/printer_data/config/moonraker.conf.backup
 awk '/^\[update_manager/{
  if($0~/update_manager mainsail]/){
    found=1
  }
  else{
    found=""
  }
 }
 !found' $HOME/printer_data/config/moonraker.conf.backup > $HOME/printer_data/config/moonraker.conf
 
 cat >> $HOME/printer_data/config/moonraker.conf << EOF
[update_manager fluidd]
type: web
repo: fluidd-core/fluidd
path: ~/fluidd
EOF
 
fi

echo Restaring moonraker
systemctl restart moonraker.service
echo Finished
