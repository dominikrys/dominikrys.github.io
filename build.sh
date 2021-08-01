#!/bin/bash

echo "==> Updating themes"
git submodule update --recursive --remote &

for theme in themes/*/; do
  printf "${theme%/}\n"
  git -C "$theme" pull &
done

echo "==> Clearing docs directory"
rm -rf docs

echo "==> Running Hugo"
hugo

wait
