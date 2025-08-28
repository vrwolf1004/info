#!/usr/bin/env bash
#code-server --list-extensions | while read extension;
#sed -n '2,$p' : 1 - first line, 2 - second line, $p - last line
code-server --list-extensions | sed -n '2,$p' | while read extension;
do 
  #echo $extension
  code-server --uninstall-extension $extension --force
done