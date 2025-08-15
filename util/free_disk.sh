#!/bin/bash

df -h 

if [[ "$RUNNER_NAME" != github-actions* ]]; then
  exit 0
fi

sudo apt-get clean 
docker system prune -a -f 
sudo rm -rf /usr/local/lib/android /usr/share/dotnet /opt/ghc 
df -h
