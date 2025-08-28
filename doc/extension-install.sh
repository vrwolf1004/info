#!/usr/bin/env bash
#change execute : chmod +x ./vscode-extension-install.sh 
#excute sh : ./extension-install.sh "FileName.txt"
cat $1 | sed -n '2,$p' | while read extension || [[ -n $extension ]];
do
  code-server --install-extension $extension
done