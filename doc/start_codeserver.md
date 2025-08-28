## setting
``` shell
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install build-essential
sudo apt-get install nodejs npm python3 python3-pip golang
sudo apt-get install wget subversion

sudo apt-get autoclean
sudo apt-get autoremove

node -v; npm -v; python3 -V; pip3 -V; go version

#2025-07-01, 07-17, 08-06 현재
v18.19.1
9.2.0
Python 3.12.3
pip 24.0 from /usr/lib/python3/dist-packages/pip (python 3.12)
go version go1.22.2 linux/amd64
```

## node 가상환경 : nodeenv
```sh
pip install nodeenv

#error 1 
error: externally-managed-environment
× This environment is externally managed

#error 2
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: nodeenv in /config/.local/lib/python3.12/site-packages (1.9.1)

## solved
sudo pip install nodeenv --break-system-packages

Collecting nodeenv
  Downloading nodeenv-1.9.1-py2.py3-none-any.whl.metadata (21 kB)
Downloading nodeenv-1.9.1-py2.py3-none-any.whl (22 kB)
Installing collected packages: nodeenv
Successfully installed nodeenv-1.9.1
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

#env 생성
nodeenv env

#nodeenv --node=<버전> <환경_이름>
nodeenv --node=21.1.0 node_env_21
nodeenv --node=18.19.1 node_env_18

#가상환경 들어가기 in code-server
source ./node_env_21/bin/activate

#가상환경 나오기 in code-server
deactivate_node

```

## make extension list 
``` shell
code-server --list-extensions > extension_list.txt
```
``` txt
chamboug.js-auto-backticks
christian-kohler.npm-intellisense
eg2.vscode-npm-script
kevinrose.vsc-python-indent
kimlimjustin.jsdoc-generator
ms-ceintl.vscode-language-pack-ko
ms-python.debugpy
ms-python.python
oderwat.indent-rainbow
pflannery.vscode-versionlens
rintoj.json-organizer
tobermory.es6-string-html
wix.vscode-import-cost
xabikos.javascriptsnippets
```

## make extension-install.sh
``` sh
#!/usr/bin/env bash
#change execute : chmod +x ./extension-install.sh 
#excute sh : ./extension-install.sh extension_list.txt

#cat $1 | sed -n '2,$p' | while read extension || [[ -n $extension ]];
cat $1 | while read extension || [[ -n $extension ]];
do
  code-server --install-extension $extension
done
```

## make extension-uninstall.sh
``` sh
#!/usr/bin/env bash
#code-server --list-extensions | while read extension;
#sed -n '2,$p' : 1 - first line, 2 - second line, $p - last line

#code-server --list-extensions | sed -n '2,$p' | while read extension;
code-server --list-extensions | while read extension;
do 
  #echo $extension
  code-server --uninstall-extension $extension --force
done
```

## keybindings.json 추가 : command-runner 설치후 json 추가후 실행
```json
    {
        "key": "ctrl+alt+0",
        "command": "command-runner.run",
        "args": {
          "command": "cd '${fileDirname}'; python3 '${file}'",
          "terminal": "runCommand"
        }
      }
```

## change react native Port 
```json
...
"scripts": {
    "start": "expo start --port 15581",
...
```